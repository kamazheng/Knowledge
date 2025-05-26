To check disk space on a CentOS system, you can use the `df` command. Here’s how you can do it:

1. **Open a terminal**.
2. **Type the following command** and press Enter:
   ```sh
   df -h
   ```
   
   The `-h` flag stands for "human-readable" and displays the sizes in a more understandable format (e.g., MB, GB).

This command will show you the disk space usage for all mounted filesystems. If you need more detailed information, you can use the `du` command:

1. **For a summary of disk usage in a specific directory**, use:
   ```sh
   du -sh /path/to/directory
   ```
   
   Replace `/path/to/directory` with the path you want to check.

Feel free to ask if you need more help with CentOS!

<br/>

要查看未分配的磁盘空间，你可以使用`lsblk`命令来列出所有的块设备及其分区情况。以下是具体步骤：

1. **打开终端**。
2. **输入以下命令**并按回车：
   ```sh
   lsblk
   ```

这个命令会显示所有的块设备及其挂载点。未分配的空间通常会显示为未挂载的分区或未使用的部分。

例如，输出可能类似于以下内容：

```plaintext
NAME        MAJ:MIN RM  SIZE RO TYPE MOUNTPOINT
sda           8:0    0    1T  0 disk 
├─sda1        8:1    0  599M  0 part /boot/efi
├─sda2        8:2    0  960M  0 part /boot
├─sda3        8:3    0   70G  0 part 
│ └─cs-root 253:0    0   70G  0 lvm  /
├─sda4        8:4    0   53G  0 part 
│ └─cs-home 253:1    0   53G  0 lvm  /home
└─sda5        8:5    0 876.4G  0 part 
```

在这个例子中，`sda5`是未分配的空间（876.4G），因为它没有挂载点。

如果你发现有未分配的空间，可以使用`fdisk`或`parted`等工具来创建新的分区，或者使用`lvextend`和`resize2fs`等工具来扩展现有的逻辑卷。

如果你需要进一步的帮助或有其他问题，请告诉我！

<br/>

好的，以下是更详细的步骤来创建新的分区：

1. **打开终端**并输入以下命令启动`fdisk`工具：
   ```sh
   fdisk /dev/sda
   ```
2. **在`fdisk`中**，按照以下步骤操作：
   - 输入`n`并按回车，创建新分区。
   - 输入`p`并按回车，选择主分区。
   - 输入分区号（例如`4`）并按回车。
   - 按回车接受默认的起始扇区。
   - 按回车接受默认的结束扇区，这样会使用所有剩余的空间。
   - 输入`w`并按回车，写入分区表并退出。

以下是一个示例交互：

```plaintext
Command (m for help): n
Partition type:
   p   primary (3 primary, 0 extended, 1 free)
   e   extended
Select (default p): p
Partition number (4-128, default 4): 4
First sector (2048-209715199, default 2048): [按回车]
Last sector, +sectors or +size{K,M,G,T,P} (2048-209715199, default 209715199): [按回车]

Command (m for help): w
```

3. **创建物理卷**：
   ```sh
   pvcreate /dev/sda4
   ```
4. **扩展卷组**：
将新的物理卷添加到现有的卷组（假设卷组名为`cs`）。
   ```sh
   vgextend cs /dev/sda4
   ```
5. **扩展逻辑卷**：
将新的空间的80%分配给根逻辑卷（`/dev/cs/root`）。
   ```sh
   lvextend -l +80%FREE /dev/cs/root
   ```
6. **扩展文件系统**：
扩展文件系统以使用新的空间。
   ```sh
   resize2fs /dev/cs/root
   ```

完成这些步骤后，你的根文件系统应该会扩展到包含新的空间。如果你在任何步骤中遇到问题或需要进一步的帮助，请告诉我！

<br/>

看起来你已经成功地创建了新的分区并扩展了逻辑卷，但在扩展文件系统时遇到了问题。`resize2fs`命令报告了一个错误，提示无法找到有效的文件系统超级块。

这个问题可能是由于文件系统类型不匹配引起的。让我们尝试使用`xfs_growfs`命令来扩展文件系统，因为你的根文件系统可能是XFS而不是ext4。

请按照以下步骤操作：

1. **确认文件系统类型**：
   ```sh
   df -T / | grep -i xfs
   ```
   
   如果输出显示文件系统类型是XFS，那么继续下一步。
2. **使用`xfs_growfs`扩展文件系统**：
   ```sh
   xfs_growfs /
   ```

这个命令会扩展挂载在根目录（`/`）上的XFS文件系统。

如果文件系统类型不是XFS，请告诉我，我们可以进一步排查问题。如果你有更多问题或需要进一步的帮助，请告诉我！

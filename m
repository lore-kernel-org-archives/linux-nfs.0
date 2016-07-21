Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-wm0-f45.google.com ([74.125.82.45]:38274 "EHLO
	mail-wm0-f45.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753079AbcGUOy6 convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 21 Jul 2016 10:54:58 -0400
Received: by mail-wm0-f45.google.com with SMTP id o80so28624820wme.1
        for <linux-nfs@vger.kernel.org>; Thu, 21 Jul 2016 07:54:57 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20160718140915.GD11071@fieldses.org>
References: <CAN63_cbcrKWYuim5NZHSfYWFXFFmcssMpiT0H2PATEu_K=FEPw@mail.gmail.com>
 <20160713132601.GA8856@fieldses.org> <CAN63_caHoS68rSdWeHfYxx_5bBiiqetY5NgYrL-+-Kvs=sX3RQ@mail.gmail.com>
 <20160718140915.GD11071@fieldses.org>
From: Thomas Gambier <thomas.gambier@gmail.com>
Date: Thu, 21 Jul 2016 16:54:36 +0200
Message-ID: <CAN63_cY=qLZ4DsyXrUuxP7cF2LO-ZxUrN6Pmtps8Y8hZZGS=Aw@mail.gmail.com>
Subject: Re: open a file in 0100444 mode in NFSv4 may fail
To: "J. Bruce Fields" <bfields@fieldses.org>
Cc: linux-nfs@vger.kernel.org
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, Jul 18, 2016 at 4:09 PM, J. Bruce Fields <bfields@fieldses.org> wrote:
> On Mon, Jul 18, 2016 at 03:44:48PM +0200, Thomas Gambier wrote:
>> Hello,
>>
>> thanks for your answer. See my comments below.
>>
>> On Wed, Jul 13, 2016 at 3:26 PM, J. Bruce Fields <bfields@fieldses.org> wrote:
>> > On Mon, Jul 11, 2016 at 07:40:11PM +0200, Thomas Gambier wrote:
>> >> Hello,
>> >>
>> >> I just discovered a problem with NFSv4 file system. I was using TCL
>> >> scripts that were doing some file manipulation (mkdir, copy, ...) on
>> >> my NFSv4 file system and sometimes the scripts failed with "permission
>> >> denied" error.
>> >>
>> >> I ran strace and I found that the system call returning the error was:
>> >> open("d1/in.txt", O_WRONLY|O_CREAT|O_TRUNC, 0100444) = -1 EACCES
>> >> (Permission denied)
>> >
>> > Is that even allowed?  The open(2) man page says posix leaves behavior
>> > in that case unspecified, and doesn't say anything I can find about
>> > Linux behavior in this case.
>> >
>> You're right. I will send a mail to TCL mailing list to know why they
>> put this flag in the open call.
>>
>> > I guess it would be nicer for client or server to do something
>> > predictable, though.  First steps might be to confirm what happens other
>> > filesystems, then do a network trace (watch the traffic in wireshark) to
>> > see if it's the client rejecting this open, or the client passing
>> > through that bit in the mode and the server returning the error.
>>
>> I agree. For other filesystem, I only tested with ext4 which works
>> fine. Let me know if you want me to test specific filesystems.
>>
>> I attach the wireshark capture of a test with 8 open call working fine
>> and the 9th one failing. For me, it seems the activity on the network
>> is exactly the same for the failing case (same call from client to
>> server and same answer from server to client). It would mean that the
>> client itself is messing things up...
>
> Agreed, sounds like the client's only deciding to fail the open after
> the OPEN call to the server succeeds.
>
> Unfortunately, the client open logic is (necessarily) pretty
> complicated--a few minutes digging around wasn't enough for me to figure
> uot where the error's coming from.
>

I'm not sure if I can help... I don't know the NFS source code at all.
I can do more tests if you need, though.

Regards.

Thomas.

> --b.
>
>>
>> Regards.
>>
>> Thomas.
>>
>> >
>> > --b.
>> >
>> >>
>> >> And indeed the error was happening only when TCL wanted to copy files
>> >> where permission were 444 (user don't have write permission).
>> >>
>> >> You can reproduce the error with the small C code attached. I tested
>> >> with a fresh install of xubuntu 16.04 for both NFS client and NFS
>> >> server and it fails. You can find all the logs and the version info
>> >> attached.
>> >>
>> >> It seems that the error is not happening when we are using mode = 444
>> >> instead of mode = 0100444 (no S_IFREG flag).
>> >>
>> >> It seems a bug in NFS to me since it doesn't happen in NFSv3, and the
>> >> error is random with NFSv4. Also I found that the error doesn't happen
>> >> at all with NFSv4 if both server and client are on Ubuntu 14.04.
>> >>
>> >> Let me know if you need more information. Also let me know if I should
>> >> open a bug on kernel bugzilla.
>> >>
>> >> Thank you.
>> >>
>> >> Regards.
>> >>
>> >> Thomas.
>> >
>> >> sigma@VM-tomo:~$ uname -a
>> >> Linux VM-tomo 4.4.0-21-generic #37-Ubuntu SMP Mon Apr 18 18:33:37 UTC 2016 x86_64 x86_64 x86_64 GNU/Linux
>> >>
>> >>
>> >> sigma@VM-tomo:~$ sudo mount  testNFS:/export /mnt
>> >>
>> >>
>> >> sigma@VM-tomo:~$ mount
>> >> sysfs on /sys type sysfs (rw,nosuid,nodev,noexec,relatime)
>> >> proc on /proc type proc (rw,nosuid,nodev,noexec,relatime)
>> >> udev on /dev type devtmpfs (rw,nosuid,relatime,size=230708k,nr_inodes=57677,mode=755)
>> >> devpts on /dev/pts type devpts (rw,nosuid,noexec,relatime,gid=5,mode=620,ptmxmode=000)
>> >> tmpfs on /run type tmpfs (rw,nosuid,noexec,relatime,size=50028k,mode=755)
>> >> /dev/sda1 on / type ext4 (rw,relatime,errors=remount-ro,data=ordered)
>> >> securityfs on /sys/kernel/security type securityfs (rw,nosuid,nodev,noexec,relatime)
>> >> tmpfs on /dev/shm type tmpfs (rw,nosuid,nodev)
>> >> tmpfs on /run/lock type tmpfs (rw,nosuid,nodev,noexec,relatime,size=5120k)
>> >> tmpfs on /sys/fs/cgroup type tmpfs (ro,nosuid,nodev,noexec,mode=755)
>> >> cgroup on /sys/fs/cgroup/systemd type cgroup (rw,nosuid,nodev,noexec,relatime,xattr,release_agent=/lib/systemd/systemd-cgroups-agent,name=systemd,nsroot=/)
>> >> pstore on /sys/fs/pstore type pstore (rw,nosuid,nodev,noexec,relatime)
>> >> cgroup on /sys/fs/cgroup/cpu,cpuacct type cgroup (rw,nosuid,nodev,noexec,relatime,cpu,cpuacct,nsroot=/)
>> >> cgroup on /sys/fs/cgroup/perf_event type cgroup (rw,nosuid,nodev,noexec,relatime,perf_event,nsroot=/)
>> >> cgroup on /sys/fs/cgroup/cpuset type cgroup (rw,nosuid,nodev,noexec,relatime,cpuset,nsroot=/)
>> >> cgroup on /sys/fs/cgroup/freezer type cgroup (rw,nosuid,nodev,noexec,relatime,freezer,nsroot=/)
>> >> cgroup on /sys/fs/cgroup/net_cls,net_prio type cgroup (rw,nosuid,nodev,noexec,relatime,net_cls,net_prio,nsroot=/)
>> >> cgroup on /sys/fs/cgroup/pids type cgroup (rw,nosuid,nodev,noexec,relatime,pids,nsroot=/)
>> >> cgroup on /sys/fs/cgroup/devices type cgroup (rw,nosuid,nodev,noexec,relatime,devices,nsroot=/)
>> >> cgroup on /sys/fs/cgroup/memory type cgroup (rw,nosuid,nodev,noexec,relatime,memory,nsroot=/)
>> >> cgroup on /sys/fs/cgroup/hugetlb type cgroup (rw,nosuid,nodev,noexec,relatime,hugetlb,nsroot=/)
>> >> cgroup on /sys/fs/cgroup/blkio type cgroup (rw,nosuid,nodev,noexec,relatime,blkio,nsroot=/)
>> >> systemd-1 on /proc/sys/fs/binfmt_misc type autofs (rw,relatime,fd=24,pgrp=1,timeout=0,minproto=5,maxproto=5,direct)
>> >> debugfs on /sys/kernel/debug type debugfs (rw,relatime)
>> >> mqueue on /dev/mqueue type mqueue (rw,relatime)
>> >> hugetlbfs on /dev/hugepages type hugetlbfs (rw,relatime)
>> >> fusectl on /sys/fs/fuse/connections type fusectl (rw,relatime)
>> >> tmpfs on /run/user/1000 type tmpfs (rw,nosuid,nodev,relatime,size=50028k,mode=700,uid=1000,gid=1000)
>> >> gvfsd-fuse on /run/user/1000/gvfs type fuse.gvfsd-fuse (rw,nosuid,nodev,relatime,user_id=1000,group_id=1000)
>> >> testNFS:/export on /mnt type nfs4 (rw,relatime,vers=4.0,rsize=262144,wsize=262144,namlen=255,hard,proto=tcp,port=0,timeo=600,retrans=2,sec=sys,clientaddr=172.27.64.79,local_lock=none,addr=172.27.64.74)
>> >>
>> >>
>> >> sigma@VM-tomo:~$ gcc create.c -o create
>> >> sigma@VM-tomo:~$ cd /mnt
>> >> sigma@VM-tomo:/mnt$ strace -v ~/create
>> >> execve("/home/sigma/create", ["/home/sigma/create"], ["XDG_VTNR=7", "LC_PAPER=fr_FR.UTF-8", "LC_ADDRESS=fr_FR.UTF-8", "XDG_SESSION_ID=c1", "XDG_GREETER_DATA_DIR=/var/lib/li"..., "LC_MONETARY=fr_FR.UTF-8", "CLUTTER_IM_MODULE=", "QT_STYLE_OVERRIDE=gtk", "SESSION=xubuntu", "GLADE_PIXMAP_PATH=:", "XDG_MENU_PREFIX=xfce-", "SHELL=/bin/bash", "TERM=xterm", "QT_LINUX_ACCESSIBILITY_ALWAYS_ON"..., "WINDOWID=52428804", "LC_NUMERIC=fr_FR.UTF-8", "OLDPWD=/home/sigma", "UPSTART_SESSION=unix:abstract=/c"..., "GNOME_KEYRING_CONTROL=", "USER=sigma", "LS_COLORS=rs=0:di=01;34:ln=01;36"..., "LC_TELEPHONE=fr_FR.UTF-8", "CLUTTER_BACKEND=x11", "QT_ACCESSIBILITY=1", "XDG_SESSION_PATH=/org/freedeskto"..., "GLADE_MODULE_PATH=:", "XDG_SEAT_PATH=/org/freedesktop/D"..., "SSH_AUTH_SOCK=/run/user/1000/key"..., "DEFAULTS_PATH=/usr/share/gconf/x"..., "SESSION_MANAGER=local/VM-tomo:@/"..., "XDG_CONFIG_DIRS=/etc/xdg/xdg-xub"..., "DESKTOP_SESSION=xubuntu", "PATH=/usr/local/sbin:/usr/local/"..., "QT_IM_MO!
 DULE=", "
 LC_IDENTIFICATION=fr_FR.UTF-8", "XDG_SESSION_TYPE=x11", "PWD=/mnt", "JOB=dbus", "XMODIFIERS=", "GNOME_KEYRING_PID=", "LANG=en_US.UTF-8", "GDM_LANG=en_US", "MANDATORY_PATH=/usr/share/gconf/"..., "LC_MEASUREMENT=fr_FR.UTF-8", "IM_CONFIG_PHASE=1", "GDMSESSION=xubuntu", "SESSIONTYPE=", "SHLVL=1", "HOME=/home/sigma", "XDG_SEAT=seat0", "LANGUAGE=en_US", "UPSTART_INSTANCE=", "GTK_OVERLAY_SCROLLING=0", "UPSTART_EVENTS=started xsession", "XDG_SESSION_DESKTOP=xubuntu", "LOGNAME=sigma", "DBUS_SESSION_BUS_ADDRESS=unix:ab"..., "XDG_DATA_DIRS=/usr/share/xubuntu"..., "QT4_IM_MODULE=", "LESSOPEN=| /usr/bin/lesspipe %s", "INSTANCE=", "UPSTART_JOB=startxfce4", "XDG_RUNTIME_DIR=/run/user/1000", "DISPLAY=:0.0", "GLADE_CATALOG_PATH=:", "XDG_CURRENT_DESKTOP=XFCE", "GTK_IM_MODULE=", "LESSCLOSE=/usr/bin/lesspipe %s %"..., "LC_TIME=fr_FR.UTF-8", "LC_NAME=fr_FR.UTF-8", "XAUTHORITY=/home/sigma/.Xauthori"..., "COLORTERM=xfce4-terminal", "_=/usr/bin/strace"]) = 0
>> >> brk(NULL)                               = 0x8c7000
>> >> access("/etc/ld.so.nohwcap", F_OK)      = -1 ENOENT (No such file or directory)
>> >> mmap(NULL, 8192, PROT_READ|PROT_WRITE, MAP_PRIVATE|MAP_ANONYMOUS, -1, 0) = 0x7ff533ae6000
>> >> access("/etc/ld.so.preload", R_OK)      = -1 ENOENT (No such file or directory)
>> >> open("/etc/ld.so.cache", O_RDONLY|O_CLOEXEC) = 3
>> >> fstat(3, {st_dev=makedev(8, 1), st_ino=273511, st_mode=S_IFREG|0644, st_nlink=1, st_uid=0, st_gid=0, st_blksize=4096, st_blocks=152, st_size=75920, st_atime=2016/07/11-19:24:38.838829302, st_mtime=2016/07/11-19:24:38.734829064, st_ctime=2016/07/11-19:24:38.734829064}) = 0
>> >> mmap(NULL, 75920, PROT_READ, MAP_PRIVATE, 3, 0) = 0x7ff533ad3000
>> >> close(3)                                = 0
>> >> access("/etc/ld.so.nohwcap", F_OK)      = -1 ENOENT (No such file or directory)
>> >> open("/lib/x86_64-linux-gnu/libc.so.6", O_RDONLY|O_CLOEXEC) = 3
>> >> read(3, "\177ELF\2\1\1\3\0\0\0\0\0\0\0\0\3\0>\0\1\0\0\0P\t\2\0\0\0\0\0"..., 832) = 832
>> >> fstat(3, {st_dev=makedev(8, 1), st_ino=3412686, st_mode=S_IFREG|0755, st_nlink=1, st_uid=0, st_gid=0, st_blksize=4096, st_blocks=3648, st_size=1864888, st_atime=2016/07/11-18:13:54.616900188, st_mtime=2016/04/15-00:16:46, st_ctime=2016/07/11-18:07:12.442702138}) = 0
>> >> mmap(NULL, 3967488, PROT_READ|PROT_EXEC, MAP_PRIVATE|MAP_DENYWRITE, 3, 0) = 0x7ff5334fa000
>> >> mprotect(0x7ff5336ba000, 2093056, PROT_NONE) = 0
>> >> mmap(0x7ff5338b9000, 24576, PROT_READ|PROT_WRITE, MAP_PRIVATE|MAP_FIXED|MAP_DENYWRITE, 3, 0x1bf000) = 0x7ff5338b9000
>> >> mmap(0x7ff5338bf000, 14848, PROT_READ|PROT_WRITE, MAP_PRIVATE|MAP_FIXED|MAP_ANONYMOUS, -1, 0) = 0x7ff5338bf000
>> >> close(3)                                = 0
>> >> mmap(NULL, 4096, PROT_READ|PROT_WRITE, MAP_PRIVATE|MAP_ANONYMOUS, -1, 0) = 0x7ff533ad2000
>> >> mmap(NULL, 4096, PROT_READ|PROT_WRITE, MAP_PRIVATE|MAP_ANONYMOUS, -1, 0) = 0x7ff533ad1000
>> >> mmap(NULL, 4096, PROT_READ|PROT_WRITE, MAP_PRIVATE|MAP_ANONYMOUS, -1, 0) = 0x7ff533ad0000
>> >> arch_prctl(ARCH_SET_FS, 0x7ff533ad1700) = 0
>> >> mprotect(0x7ff5338b9000, 16384, PROT_READ) = 0
>> >> mprotect(0x600000, 4096, PROT_READ)     = 0
>> >> mprotect(0x7ff533ae8000, 4096, PROT_READ) = 0
>> >> munmap(0x7ff533ad3000, 75920)           = 0
>> >> open("testfile0.txt", O_WRONLY|O_CREAT|O_TRUNC, 0100444) = 3
>> >> open("testfile1.txt", O_WRONLY|O_CREAT|O_TRUNC, 0100444) = 4
>> >> open("testfile2.txt", O_WRONLY|O_CREAT|O_TRUNC, 0100444) = -1 EACCES (Permission denied)
>> >> dup(2)                                  = 5
>> >> fcntl(5, F_GETFL)                       = 0x8002 (flags O_RDWR|O_LARGEFILE)
>> >> brk(NULL)                               = 0x8c7000
>> >> brk(0x8e8000)                           = 0x8e8000
>> >> fstat(5, {st_dev=makedev(0, 14), st_ino=7, st_mode=S_IFCHR|0620, st_nlink=1, st_uid=1000, st_gid=5, st_blksize=1024, st_blocks=0, st_rdev=makedev(136, 4), st_atime=2016/07/11-19:31:12.028895038, st_mtime=2016/07/11-19:31:12.028895038, st_ctime=2016/07/11-18:35:39.028895038}) = 0
>> >> write(5, "Open failed\n", 12Open failed
>> >> )           = 12
>> >> write(5, ": Permission denied\n", 20: Permission denied
>> >> )   = 20
>> >> close(5)                                = 0
>> >> write(2, "Error creating testfile2.txt\n", 29Error creating testfile2.txt
>> >> ) = 29
>> >> exit_group(1)                           = ?
>> >> +++ exited with 1 +++
>> >>
>> >
>> >> #include <unistd.h>
>> >> #include <fcntl.h>
>> >> #include <stdio.h>
>> >>
>> >>
>> >> int main()
>> >> {
>> >>     int filedesc, i;
>> >>     char filename[100];
>> >>
>> >>     for (i=0; i<1000; i++)
>> >>     {
>> >>       sprintf(filename, "testfile%d.txt", i);
>> >>
>> >>       filedesc = open(filename, O_WRONLY|O_CREAT|O_TRUNC, 0100444);
>> >>       if(filedesc < 0)
>> >>       {
>> >>         perror("Open failed\n");
>> >>         fprintf(stderr, "Error creating %s\n", filename);
>> >>         return 1;
>> >>       }
>> >>     }
>> >>
>> >>     return 0;
>> >> }
>> >>
>> >
>> >> sigma@testNFS:~$ uname -a
>> >> Linux testNFS 4.4.0-21-generic #37-Ubuntu SMP Mon Apr 18 18:33:37 UTC 2016 x86_64 x86_64 x86_64 GNU/Linux
>> >>
>> >>
>> >> sigma@testNFS:~$ apt-cache policy nfs-common
>> >> nfs-common:
>> >>   Installed: 1:1.2.8-9ubuntu12
>> >>   Candidate: 1:1.2.8-9ubuntu12
>> >>   Version table:
>> >>  *** 1:1.2.8-9ubuntu12 500
>> >>         500 http://fr.archive.ubuntu.com/ubuntu xenial/main amd64 Packages
>> >>         100 /var/lib/dpkg/status
>> >>
>> >>
>> >> sigma@testNFS:~$ apt-cache policy nfs-kernel-server
>> >> nfs-kernel-server:
>> >>   Installed: 1:1.2.8-9ubuntu12
>> >>   Candidate: 1:1.2.8-9ubuntu12
>> >>   Version table:
>> >>  *** 1:1.2.8-9ubuntu12 500
>> >>         500 http://fr.archive.ubuntu.com/ubuntu xenial/main amd64 Packages
>> >>         100 /var/lib/dpkg/status
>> >>
>> >>
>> >> sigma@testNFS:~$ cat /etc/exports
>> >> # /etc/exports: the access control list for filesystems which may be exported
>> >> #             to NFS clients.  See exports(5).
>> >> #
>> >> # Example for NFSv2 and NFSv3:
>> >> # /srv/homes       hostname1(rw,sync,no_subtree_check) hostname2(ro,sync,no_subtree_check)
>> >> #
>> >> # Example for NFSv4:
>> >> # /srv/nfs4        gss/krb5i(rw,sync,fsid=0,crossmnt,no_subtree_check)
>> >> # /srv/nfs4/homes  gss/krb5i(rw,sync,no_subtree_check)
>> >> #
>> >>
>> >> /export  172.27.0.0/255.255.0.0(rw,fsid=1,async,insecure,no_subtree_check)
>> >>
>> >>
>> >> sigma@testNFS:~$ ls -al /export
>> >> total 12
>> >> drwxrwxrwx  3 root  root  4096 juil. 11 18:58 .
>> >> drwxr-xr-x 25 root  root  4096 juil. 11 18:55 ..
>> >>
>> >>
>> >> sigma@testNFS:~$ sudo exportfs -v
>> >> [sudo] password for sigma:
>> >> /export               172.27.0.0/255.255.0.0(rw,async,wdelay,insecure,root_squash,no_subtree_check,fsid=1,sec=sys,rw,root_squash,no_all_squash)
>> >>
>> >>
>> >>
>> >
>
>

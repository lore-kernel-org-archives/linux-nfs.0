From: Toni Zimmer <T.Zimmer@science-computing.de>
Subject: NFSv3-Client creates empty files on AIX 5.1/5.3 file server
Date: Wed, 28 Mar 2007 14:54:55 +0200 (CEST)
Message-ID: <Pine.LNX.4.61.0703281442310.31576@bender.science-computing.de>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
To: nfs@lists.sourceforge.net
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1HWXg9-0003WZ-Jp
	for nfs@lists.sourceforge.net; Wed, 28 Mar 2007 05:55:06 -0700
Received: from smtp1.belwue.de ([129.143.2.12])
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1HWXgA-0000tB-9B
	for nfs@lists.sourceforge.net; Wed, 28 Mar 2007 05:55:08 -0700
Received: from mx4.science-computing.de (mx4.science-computing.de
	[193.197.16.30]) by smtp1.belwue.de with ESMTP id l2SCt12o004177
	for <nfs@lists.sourceforge.net>; Wed, 28 Mar 2007 14:55:02 +0200 (MEST)
	env-from (T.Zimmer@science-computing.de)
Received: from localhost (localhost [127.0.0.1])
	by scmail.science-computing.de (Postfix) with ESMTP id 1B27B71A9EF6
	for <nfs@lists.sourceforge.net>; Wed, 28 Mar 2007 14:55:01 +0200 (CEST)
Received: from scmail.science-computing.de ([127.0.0.1])
	by localhost (obitest [127.0.0.1]) (amavisd-new, port 10024)
	with ESMTP id 01436-09 for <nfs@lists.sourceforge.net>;
	Wed, 28 Mar 2007 14:54:55 +0200 (CEST)
Received: from bender.science-computing.de (bender.science-computing.de
	[10.10.24.25])
	by scmail.science-computing.de (Postfix) with ESMTP id E42E971A9EFA
	for <nfs@lists.sourceforge.net>; Wed, 28 Mar 2007 14:54:55 +0200 (CEST)
Received: from localhost (localhost [127.0.0.1])
	by bender.science-computing.de (Postfix) with ESMTP id D4FB74128F27
	for <nfs@lists.sourceforge.net>; Wed, 28 Mar 2007 14:54:55 +0200 (CEST)
List-Id: "Discussion of NFS under Linux development, interoperability,
	and testing." <nfs.lists.sourceforge.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=nfs>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
Sender: nfs-bounces@lists.sourceforge.net
Errors-To: nfs-bounces@lists.sourceforge.net

Hi,

we have some trouble with NFSv3 clients editing files exported by 
an aix file server:

If a user wants to edit a file which he doesn't own but belongs to the 
group he's in with vim, he gets after trying to write (:w) the error 
message:
                 E212: Can't open file for writing

and after trying to quit this process without writing (:q!) this file is 
empty (0 bytes)!

If the user edits the file and quits the vim with ":wq!" the file  is okay 
but belongs now to the new user.

This happens on open SUSE 10.2 workstations (2.6.18.8-0.1-default x86_64) 
and AIX 5.1/5.3 file servers.

To debug this problem I wrote a small c programm (sctestfile02 is the 
file which is located in a directory mounted per nfs on the client):

#include <stdio.h>
#include <fcntl.h>

int main (void)
{
  int fd;
  fd = open ("sctestfile02", O_WRONLY|O_CREAT|O_TRUNC, 0660);
  close (fd);
  return 0;
}



and after compiling I tried to "trace" it on the suse 10.2 client:

> strace ./justopen
execve("./justopen", ["./justopen"], [/* 68 vars */]) = 0
brk(0)                                  = 0x501000
mmap(NULL, 4096, PROT_READ|PROT_WRITE, MAP_PRIVATE|MAP_ANONYMOUS, -1, 0) = 
0x2ae40ef67000
uname({sys="Linux", node="wu0c0135", ...}) = 0
access("/etc/ld.so.preload", R_OK)      = -1 ENOENT (No such file or 
directory)
open("/etc/ld.so.cache", O_RDONLY)      = 3
fstat(3, {st_mode=S_IFREG|0644, st_size=179794, ...}) = 0
mmap(NULL, 179794, PROT_READ, MAP_PRIVATE, 3, 0) = 0x2ae40ef68000
close(3)                                = 0
open("/lib64/libc.so.6", O_RDONLY)      = 3
read(3, "\177ELF\2\1\1\0\0\0\0\0\0\0\0\0\3\0>\0\1\0\0\0\340\333"..., 832) 
= 832
fstat(3, {st_mode=S_IFREG|0755, st_size=1595305, ...}) = 0
mmap(NULL, 4096, PROT_READ|PROT_WRITE, MAP_PRIVATE|MAP_ANONYMOUS, -1, 0) = 
0x2ae40ef94000
mmap(NULL, 3412216, PROT_READ|PROT_EXEC, MAP_PRIVATE|MAP_DENYWRITE, 3, 0) 
= 0x2ae40f169000
fadvise64(3, 0, 3412216, POSIX_FADV_WILLNEED) = 0
mprotect(0x2ae40f2a2000, 2093056, PROT_NONE) = 0
mmap(0x2ae40f4a1000, 20480, PROT_READ|PROT_WRITE, 
MAP_PRIVATE|MAP_FIXED|MAP_DENYWRITE, 3, 0x138000) = 0x2ae40f4a1000
mmap(0x2ae40f4a6000, 16632, PROT_READ|PROT_WRITE, 
MAP_PRIVATE|MAP_FIXED|MAP_ANONYMOUS, -1, 0) = 0x2ae40f4a6000
close(3)                                = 0
mmap(NULL, 4096, PROT_READ|PROT_WRITE, MAP_PRIVATE|MAP_ANONYMOUS, -1, 0) = 
0x2ae40f4ab000
arch_prctl(ARCH_SET_FS, 0x2ae40f4ab6f0) = 0
mprotect(0x2ae40f4a1000, 12288, PROT_READ) = 0
munmap(0x2ae40ef68000, 179794)          = 0
open("sctestfile02", O_WRONLY|O_CREAT|O_TRUNC, 0660) = -1 EPERM (Operation 
not permitted)
close(4294967295)                       = -1 EBADF (Bad file descriptor)
exit_group(0)                           = ?
Process 15970 detached



If I trace the same "program" on a SuSE 9.3 workstation (2.6.11.4-21.8-smp 
x86_64), everything seems to be fine:

> strace ./justopen
execve("./justopen", ["./justopen"], [/* 86 vars */]) = 0
uname({sys="Linux", node="wu0c0245", ...}) = 0
brk(0)                                  = 0x501000
mmap(NULL, 4096, PROT_READ|PROT_WRITE, MAP_PRIVATE|MAP_ANONYMOUS, -1, 0) = 
0x2aaaaaac1000
access("/etc/ld.so.preload", R_OK)      = -1 ENOENT (No such file or 
directory)
open("/etc/ld.so.cache", O_RDONLY)      = 3
fstat(3, {st_mode=S_IFREG|0644, st_size=176481, ...}) = 0
mmap(NULL, 176481, PROT_READ, MAP_PRIVATE, 3, 0) = 0x2aaaaaac2000
close(3)                                = 0
open("/lib64/tls/libc.so.6", O_RDONLY)  = 3
read(3, "\177ELF\2\1\1\0\0\0\0\0\0\0\0\0\3\0>\0\1\0\0\0\360\305"..., 640) 
= 640
lseek(3, 64, SEEK_SET)                  = 64
read(3, "\6\0\0\0\5\0\0\0@\0\0\0\0\0\0\0@\0\0\0\0\0\0\0@\0\0\0\0"..., 616) 
= 616
lseek(3, 680, SEEK_SET)                 = 680
read(3, "\4\0\0\0\20\0\0\0\1\0\0\0GNU\0\0\0\0\0\2\0\0\0\6\0\0\0"..., 32) = 
32
fstat(3, {st_mode=S_IFREG|0755, st_size=1446783, ...}) = 0
lseek(3, 64, SEEK_SET)                  = 64
read(3, "\6\0\0\0\5\0\0\0@\0\0\0\0\0\0\0@\0\0\0\0\0\0\0@\0\0\0\0"..., 616) 
= 616
mmap(NULL, 2252744, PROT_READ|PROT_EXEC, MAP_PRIVATE|MAP_DENYWRITE, 3, 0) 
= 0x2aaaaabc2000
madvise(0x2aaaaabc2000, 2252744, MADV_SEQUENTIAL|0x1) = 0
mprotect(0x2aaaaacdf000, 1085384, PROT_NONE) = 0
mmap(0x2aaaaadde000, 24576, PROT_READ|PROT_WRITE, 
MAP_PRIVATE|MAP_FIXED|MAP_DENYWRITE, 3, 0x11c000) = 0x2aaaaadde000
mmap(0x2aaaaade4000, 16328, PROT_READ|PROT_WRITE, 
MAP_PRIVATE|MAP_FIXED|MAP_ANONYMOUS, -1, 0) = 0x2aaaaade4000
close(3)                                = 0
mmap(NULL, 4096, PROT_READ|PROT_WRITE, MAP_PRIVATE|MAP_ANONYMOUS, -1, 0) = 
0x2aaaaade8000
mmap(NULL, 4096, PROT_READ|PROT_WRITE, MAP_PRIVATE|MAP_ANONYMOUS, -1, 0) = 
0x2aaaaade9000
mprotect(0x2aaaaadde000, 12288, PROT_READ) = 0
arch_prctl(ARCH_SET_FS, 0x2aaaaade8b00) = 0
munmap(0x2aaaaaac2000, 176481)          = 0
open("sctestfile02", O_WRONLY|O_CREAT|O_TRUNC, 0660) = 3
close(3)                                = 0
exit_group(0)                           = ?


In the next step I changed the /etc/amd.conf on the "buggy" workstation 
(suse 10.2), so it should use NFS v2:

# cat /etc/amd.conf
#
#
########################################################################
#
# file /etc/amd.conf
#
########################################################################
#
# GLOBAL OPTIONS SECTION
[ global ]
# Log in /var/adm
#log_options =            all
log_options =            all,noinfo
plock =                  yes
selectors_on_default =   yes
print_version =          yes
nfs_vers = 2
nfs_proto = udp
#
#map_options =                   cache:=all
#
#browsable_dirs =                yes
#show_statfs_entries =           yes
log_file = /var/adm/amdlog


and restarted the automounter. Now I tried the same strace:

> strace ./justopen
execve("./justopen", ["./justopen"], [/* 68 vars */]) = 0
brk(0)                                  = 0x501000
mmap(NULL, 4096, PROT_READ|PROT_WRITE, MAP_PRIVATE|MAP_ANONYMOUS, -1, 0) = 
0x2b1ba404a000
uname({sys="Linux", node="wu0c0135", ...}) = 0
access("/etc/ld.so.preload", R_OK)      = -1 ENOENT (No such file or 
directory)
open("/etc/ld.so.cache", O_RDONLY)      = 3
fstat(3, {st_mode=S_IFREG|0644, st_size=179794, ...}) = 0
mmap(NULL, 179794, PROT_READ, MAP_PRIVATE, 3, 0) = 0x2b1ba404b000
close(3)                                = 0
open("/lib64/libc.so.6", O_RDONLY)      = 3
read(3, "\177ELF\2\1\1\0\0\0\0\0\0\0\0\0\3\0>\0\1\0\0\0\340\333"..., 832) 
= 832
fstat(3, {st_mode=S_IFREG|0755, st_size=1595305, ...}) = 0
mmap(NULL, 4096, PROT_READ|PROT_WRITE, MAP_PRIVATE|MAP_ANONYMOUS, -1, 0) = 
0x2b1ba4077000
mmap(NULL, 3412216, PROT_READ|PROT_EXEC, MAP_PRIVATE|MAP_DENYWRITE, 3, 0) 
= 0x2b1ba424c000
fadvise64(3, 0, 3412216, POSIX_FADV_WILLNEED) = 0
mprotect(0x2b1ba4385000, 2093056, PROT_NONE) = 0
mmap(0x2b1ba4584000, 20480, PROT_READ|PROT_WRITE, 
MAP_PRIVATE|MAP_FIXED|MAP_DENYWRITE, 3, 0x138000) = 0x2b1ba4584000
mmap(0x2b1ba4589000, 16632, PROT_READ|PROT_WRITE, 
MAP_PRIVATE|MAP_FIXED|MAP_ANONYMOUS, -1, 0) = 0x2b1ba4589000
close(3)                                = 0
mmap(NULL, 4096, PROT_READ|PROT_WRITE, MAP_PRIVATE|MAP_ANONYMOUS, -1, 0) = 
0x2b1ba458e000
arch_prctl(ARCH_SET_FS, 0x2b1ba458e6f0) = 0
mprotect(0x2b1ba4584000, 12288, PROT_READ) = 0
munmap(0x2b1ba404b000, 179794)          = 0
open("sctestfile02", O_WRONLY|O_CREAT|O_TRUNC, 0660) = 3
close(3)                                = 0
exit_group(0)                           = ?
Process 16783 detached

So it seems to be okay now but we can't use NFSv2 because of file size 
limitations. BTW: If I let my little programm open the file on the nfs 
server without the option O_TRUNC everything is fine too (on suse 9.3 and 
10.2).

After changing back to NFSv3 on this client, I tried to dump the network 
traffic and discovered an error while executing the small c programm.
And the only difference between the SuSE 9.3 client and open SUSE 10.2 
client dump is the last frame on the suse 10.2:

No.     Time        Source                Destination           Protocol 
Info
424 2.812985    53.60.5.101           53.60.149.36          NFS      V3 
SETATTR Reply (Call In 423) Error:NFS3ERR_PERM
...
...
Network File System, SETATTR Reply  Error:NFS3ERR_PERM
[Program Version: 3]
     [V3 Procedure: SETATTR (2)]
     Status: NFS3ERR_PERM (1)
     obj_wcc
         before
             attributes_follow: value follows (1)
             attributes
                 size: 0
                 mtime: Mar 27, 2007 12:57:37.872617455
                     seconds: 1174993057
                     nano seconds: 872617455
                 ctime: Mar 27, 2007 12:57:37.872617455
                     seconds: 1174993057
                     nano seconds: 872617455
         after  Regular File mode:0660 uid:50124 gid:50079
             attributes_follow: value follows (1)
             attributes  Regular File mode:0660 uid:50124 gid:50079
                 Type: Regular File (1)
                 mode: 0500660
                     0... .... .... = not SUID
                     .0.. .... .... = not SGID
                     ..0. .... .... = not save swapped text
                     ...1 .... .... = Read permission for owner
                     .... 1... .... = Write permission for owner
                     .... .0.. .... = no Execute permission for owner
                     .... ..1. .... = Read permission for group
                     .... ...1 .... = Write permission for group
                     .... .... 0... = no Execute permission for group
                     .... .... .0.. = no Read permission for others
                     .... .... ..0. = no Write permission for others
                     .... .... ...0 = no Execute permission for others
                 nlink: 1
                 uid: 50124
                 gid: 50079
                 size: 0
                 used: 0
                 rdev: 0,0
                     specdata1: 0
                     specdata2: 0
                 fsid: 0x8000006400000007
                 fileid: 25650
                 atime: Mar 26, 2007 18:29:42.000000000
                     seconds: 1174926582
                     nano seconds: 0
                 mtime: Mar 27, 2007 12:57:37.872617455
                     seconds: 1174993057
                     nano seconds: 872617455
                 ctime: Mar 27, 2007 12:57:37.872617455
                     seconds: 1174993057
                     nano seconds: 872617455


A little bit of searching the internet explained this error and tells me 
that the "caller doesn't have the correct ownership to perform the 
requested operation", but the user is in the same _group_ as the owner and 
the file has reading and writing permissions for owner and group.

Is there anything I could do to prevent the "creation of zero byte files" 
or to get more information for debugging purpose?


Greetings

Toni

-- 
Toni Zimmer                     science + computing ag
IT Services                     Hagellocher Weg 73
phone +49 7071 9457 485         72070 Tuebingen, Germany
fax   +49 7071 9457 411         www.science-computing.de

-------------------------------------------------------------------------
Take Surveys. Earn Cash. Influence the Future of IT
Join SourceForge.net's Techsay panel and you'll get the chance to share your
opinions on IT & business topics through brief surveys-and earn cash
http://www.techsay.com/default.php?page=join.php&p=sourceforge&CID=DEVDEV
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs

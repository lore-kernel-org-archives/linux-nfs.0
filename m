From: Frank Mattauch <frank.mattauch@informatik.stud.uni-erlangen.de>
Subject: Found NFSD bug???
Date: Mon, 21 Jun 2004 16:46:32 +0200
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <200406211646.32064.frank.mattauch@informatik.stud.uni-erlangen.de>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="us-ascii"
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1BcP7N-0008Re-No
	for nfs@lists.sourceforge.net; Mon, 21 Jun 2004 06:45:49 -0700
Received: from postman4.arcor-online.net ([151.189.20.158] helo=postman.arcor.de)
	by sc8-sf-mx1.sourceforge.net with esmtp (TLSv1:DES-CBC3-SHA:168)
	(Exim 4.30)
	id 1BcP7N-0005yh-1e
	for nfs@lists.sourceforge.net; Mon, 21 Jun 2004 06:45:49 -0700
Received: from framatt..fammatt.de (pD9E539D1.dip.t-dialin.net [217.229.57.209])
	(authenticated bits=0)
	by postman.arcor.de (8.13.0.PreAlpha4/8.13.0.PreAlpha4) with ESMTP id i5LDjhER023869
	(version=TLSv1/SSLv3 cipher=RC4-MD5 bits=128 verify=NO)
	for <nfs@lists.sourceforge.net>; Mon, 21 Jun 2004 15:45:45 +0200 (MEST)
To: nfs@lists.sourceforge.net
Errors-To: nfs-admin@lists.sourceforge.net
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Id: Discussion of NFS under Linux development,
	interoperability,
	and testing. <nfs.lists.sourceforge.net>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=nfs>

i!
I am observing a very strange problem with nfs-utils-1.0.6 and kernel version
2.6.6 or 2.6.7.

Symptom:
  rpc.nfsd exits with exit status 1.

Failure source:
I traced down the problem to the file support/nfs/nfssvc.c. In this file
the write system call fails. Why is it not possible to write to a proc file?
Strange enough ... . In oder to avoid any questions, so far: I am executing 
this program as root.

Problematic code from support/nfs/nfssvc.c :

... (Skipping code)

int
 nfssvc(int port, int nrservs)
 {
         struct nfsctl_arg       arg;
         int fd;

fd = open("/proc/fs/nfsd/threads", O_WRONLY);
         if (fd < 0)
                 fd = open("/proc/fs/nfs/threads", O_WRONLY);
         if (fd >= 0) {
                 /* 2.5+ kernel with nfsd filesystem mounted.
                  * Just write the number in.
                  * Cannot handle port number yet, but does anyone care?
                  */

                 char buf[20];
                 int n;
                 snprintf(buf, 20,"%d\n", nrservs);

                 /***************************
                  * This system call fails. *
                  ***************************/
                 n = write(fd, buf, strlen(buf));

                 if (n != strlen(buf))
                       return -1;
                 else
                      return 0;

... (Skipping code)

Diagnosis:
"write(fd, buf, strlen(buf)" returns a value of -1 (system call fails,
nothing written) and sets errno to "Permission denied". "buf" has a length
of 2. In the following code "if (n != strlen(buf))" evaluates to true and
returns -1. The result is, that rpc.nfsd exits with status 1 (failure).

Bug fix: Unknown

Possible bug sources:
1. Found NFS bug. (unlikely, NFS would not work anywhere).
2. Found kernel bug
3. Found libc bug, due to too old libc version
4. Misconfigured system

Information about my system:
System: Debian Linux stable (woody)
Kernelversion: 2.6.7 and 2.6.6

NFS built as modules  (taken from menuconfig):
<M> NFS file system support
[*]   Provide NFSv3 client support
[ ]   Provide NFSv4 client support (EXPERIMENTAL)
[*]   Allow direct I/O on NFS files (EXPERIMENTAL)
<M> NFS server support
[*]   Provide NFSv3 server support
[ ]     Provide NFSv4 server support (EXPERIMENTAL)
[*]   Provide NFS server over TCP support (EXPERIMENTAL)

Loaded modules:
# lsmod
Module                  Size  Used by
nfs                   110380  0
nfsd                   95392  1
exportfs                6304  1 nfsd
lockd                  62048  2 nfs,nfsd
sunrpc                148448  3 nfs,nfsd,lockd

Mounted filesystems:
# mount
/dev/hda1 on / type ext3 (rw,bsddf,nocheck,nogrpid,data=journal,errors=panic)
proc on /proc type proc (rw)
devpts on /dev/pts type devpts (rw,gid=5,mode=620)
/sysfs on /sysfs type sysfs (rw)
nfsd on /proc/fs/nfsd type nfsd (rw)
tmpfs on /dev/shm type tmpfs (rw)
usbfs on /proc/bus/usb type usbfs (rw)

Messages in /var/log/syslog:
Jun 21 15:40:06 gatematt portmap[3791]: connect from 127.0.0.1 to unset(nfs): 
request from non-local host
Jun 21 15:40:06 gatematt portmap[3792]: connect from 127.0.0.1 to set(nfs): 
request from non-local host
Jun 21 15:40:06 gatematt portmap[3793]: connect from 127.0.0.1 to unset(nfs): 
request from non-local host
Jun 21 15:40:06 gatematt portmap[3794]: connect from 127.0.0.1 to unset(nfs): 
request from non-local host
Jun 21 15:40:06 gatematt nfsd[3789]: nfssvc: Permission denied

# rpcinfo -p
   Program Vers Proto   Port
    100000    2   tcp    111  portmapper
    100000    2   udp    111  portmapper
    100007    2   udp    824  ypbind
    100007    1   udp    824  ypbind
    100007    2   tcp    827  ypbind
    100007    1   tcp    827  ypbind
    100024    1   udp    730  status
    100024    1   tcp    733  status

libc6 version:
#dpkg -l libc6
(...)
||/ Name           Version        Beschreibung
+++-==============-==============-============================================
ii  libc6          2.2.5-11.5     GNU C Library: Shared libraries and Timezone


I hope, that anybody can help me with that problem.
Bye
 Frank


-------------------------------------------------------
This SF.Net email is sponsored by The 2004 JavaOne(SM) Conference
Learn from the experts at JavaOne(SM), Sun's Worldwide Java Developer
Conference, June 28 - July 1 at the Moscone Center in San Francisco, CA
REGISTER AND SAVE! http://java.sun.com/javaone/sf Priority Code NWMGYKND
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs

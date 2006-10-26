From: Andrew Ryan <andrewr@nam-shub.com>
Subject: stale file handles with linux NFS server, not with NetApp
Date: Thu, 26 Oct 2006 07:56:33 -0700 (PDT)
Message-ID: <Pine.LNX.4.58.0610260756050.5475@bolt.sonic.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1Gd6ep-0006DK-VI
	for nfs@lists.sourceforge.net; Thu, 26 Oct 2006 07:56:36 -0700
Received: from a.mail.sonic.net ([64.142.16.245])
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1Gd6en-0000JK-Pw
	for nfs@lists.sourceforge.net; Thu, 26 Oct 2006 07:56:37 -0700
Received: from bolt.sonic.net (bolt.sonic.net [208.201.242.19])
	by a.mail.sonic.net (8.13.8.Beta0-Sonic/8.13.7) with ESMTP id
	k9QEuXQ3001292
	(version=TLSv1/SSLv3 cipher=EDH-RSA-DES-CBC3-SHA bits=168 verify=NO)
	for <nfs@lists.sourceforge.net>; Thu, 26 Oct 2006 07:56:33 -0700
To: nfs@lists.sourceforge.net
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

I've recently tried using a RHEL3 machine as an NFS server. The server is
2 CPU Xeon, running 2.4.21-37.ELsmp kernel. The client is also RHEL3,
running 2.4.21-40.ELsmp. The clients are automounting homedirs from the
server. For years we've been using a Netapp server (currently running
ONTAP 7.0.1) and it's worked just fine. Trying the RHEL3 server though,
I'm experiencing a weird issue that I can't explain or fix.

1. Log in as user with an automounted homedir
2. cd in to some subdirectory (Foo/Bar/bax in example below) of homedir
   (can't duplicate the problem in the homedir itself)
3. Wait a few minutes (automount timeout is 60 seconds)
4. Try to access cwd:
[grue@cu015 bax]$ ls -l /proc/$$/cwd
lrwxrwxrwx    1 grue     __cubitu        0 Oct 26 06:48 /proc/16280/cwd ->
/home/grue/Foo/Bar/bax
5. So far so good, now *really* try to access this:
[grue@cu015 bax]$ sudo mkdir -p /tmp/gasd/dfsdf/sdf/
Password:
mkdir: cannot open current directory: Stale NFS file handle
[grue@cu015 bax]$ ls -l /proc/$$/cwd
lrwxrwxrwx    1 grue     __cubitu        0 Oct 26 06:48 /proc/16280/cwd ->
/home/grue/Foo/Bar/bax (deleted)

At this point I need to cd out of this directory and then back into the
directory in order to get the Stale NFS file handle message to go away.
According to /proc/mounts the filesystem is still mounted.

My first inclination would be to blame autofs here, except that the exact
same automount config works fine against our NetApp filer: no "Stale file
handle" message is ever received no matter how long we wait.

The export on the server is done "rw,sync".
On the client, auto.master is one line:
/home       /etc/auto.sharedhome --debug
and /etc/auto.sharedhome is also one line:
grue   -fstype=nfs,rw,tcp,nfsvers=3,rsize=32768,wsize=32768,intr,hard,fg
mgr:/u1/chroot/home/&

This seems like such an obvious problem that I'm wondering what I'm doing
wrong, but can't figure out anything. I can provide any
additional debugging detail needed. Switching to 2.6/RHEL4 is not really
an option for us at this point, so we haven't tried it to see if that
fixes it.


Thanks
--andrew

-------------------------------------------------------------------------
Using Tomcat but need to do more? Need to support web services, security?
Get stuff done quickly with pre-integrated technology to make your job easier
Download IBM WebSphere Application Server v.1.0.1 based on Apache Geronimo
http://sel.as-us.falkag.net/sel?cmd=lnk&kid=120709&bid=263057&dat=121642
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs

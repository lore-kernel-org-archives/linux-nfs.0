From: Terrence Martin <tmartin@physics.ucsd.edu>
Subject: Failure to Unmount NFS FS cause Client Hangs on Reboot
Date: Thu, 02 Sep 2004 15:14:58 -0700
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <41379B62.5050300@physics.ucsd.edu>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1C2zrU-00080P-QU
	for nfs@lists.sourceforge.net; Thu, 02 Sep 2004 15:15:20 -0700
Received: from newport.ucsd.edu ([132.239.73.89])
	by sc8-sf-mx1.sourceforge.net with esmtp (TLSv1:AES256-SHA:256)
	(Exim 4.34)
	id 1C2zrT-00059m-CA
	for nfs@lists.sourceforge.net; Thu, 02 Sep 2004 15:15:20 -0700
Received: from physics.ucsd.edu (newport.ucsd.edu [127.0.0.1])
	by newport.ucsd.edu (8.12.10/8.12.10) with ESMTP id i82MEwq0003107
	for <nfs@lists.sourceforge.net>; Thu, 2 Sep 2004 15:14:58 -0700
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

Hi,

I am having a problem where my client machines are not able to reboot 
correctly because the NFS mounted file systems are hanging at shutdown 
time and refuse to unmount.

I am running RHEL3 (Rocks Cluster 3.1) nodes with the latest RH RHEL3 
kernel in a cluster environment.  The problem occured with older kernels 
as well.

Relatively little information is actually shared over NFS, and clients 
almost never have to write to the same files. Mostly clients read some 
code and configurations files over NFS and then maybe writing a bit of 
data to isolated locations (no two clients write to the same files).

Even when I shutdown the processes that actually use my nfs file systems 
and confirm via lsof that no files are open on those file systems manual 
unmount commands also hang.  Autofs also fails to stop correctly 
claiming that the file systems are busy.

Most of the clients mount filesystems from 3 or 4 servers via autofs. My 
timeouts are 600 seconds.

The problem is not always consistent. The other day I was able to 
unmount properly and reboot after various strategies of manual unmounts 
and shutting off autofs. Today I could not.

So my questions are, if there are no files open on these mounted file 
systems why would I have such problems? Can you force the NFS file 
systems to unmount anyway? This is a particular problem because a hang 
requires manual intervention to power cycle the machine. I would even be 
happy to have the NFS unmounting be ignored completely and just reboot 
the system after properly unmounting the local filesystems and ensuring 
all programs are shutdown.

I would be interested also in any suggestions of how to find what is 
hanging up my NFS mounts and preventing unmounting...

Thanks for any suggestions,

Terrence Martin
UCSD Physics

A few command outputs


root@compute-2-5 ~# df
Filesystem           1K-blocks      Used Available Use% Mounted on
/dev/hda1              4127076   3454252    463180  89% /
/dev/hda3             71789596  21607120  46535724  32% /state/data
none                   1030816         0   1030816   0% /dev/shm
192.168.20.3:/home/cdfcaf
                    101161396  34167296  66994100  34% /home/cdfcaf
192.168.20.3:/home/cdfcaf
                    101161396  34167296  66994100  34% /home/cdfcaf
192.168.10.5:/falcon/0/users
                    1463382364 618177588 845204776  43% /home/users
frontend-3.local:/export/home/install
                     10080520   5781204   3787248  61% /home/install

root@compute-2-5 ~# mount
/dev/hda1 on / type ext3 (rw)
none on /proc type proc (rw)
usbdevfs on /proc/bus/usb type usbdevfs (rw)
/dev/hda3 on /state/data type ext3 (rw)
none on /dev/shm type tmpfs (rw)
none on /dev/pts type devpts (rw,gid=5,mode=620)
automount(pid2592) on /home type autofs 
(rw,fd=5,pgrp=2592,minproto=2,maxproto=3)
192.168.20.3:/home/cdfcaf on /home/cdfcaf type nfs (rw,addr=192.168.20.3)
automount(pid3119) on /home type autofs 
(rw,fd=5,pgrp=3119,minproto=2,maxproto=3)
automount(pid3149) on /netstor type autofs 
(rw,fd=5,pgrp=3149,minproto=2,maxproto=3)
automount(pid3180) on /afs type autofs 
(rw,fd=5,pgrp=3180,minproto=2,maxproto=3)
192.168.20.3:/home/cdfcaf on /home/cdfcaf type nfs (rw,addr=192.168.20.3)
192.168.10.5:/falcon/0/users on /home/users type nfs (rw,addr=192.168.10.5)
frontend-3.local:/export/home/install on /home/install type nfs 
(rw,addr=192.168.21.1)

cat /etc/auto.master
# $411id: /etc/auto.master$
# Retrieved: 02-Sep-2004 21:41
# Master server: 192.168.21.1
# Last modified on master: 04-Aug-2004 04:04
# Encrypted file size: 490 bytes
#
# Owner: 0.0
# Name: etc.auto..master
# Mode: 0100644
/home auto.home --timeout 600
/netstor auto.net --timeout 600
/afs    auto.afs --timeout 600
/groot   auto.grid3      --timeout 600

On one of the servers
cat /etc/exports
/export 192.168.0.0/255.255.0.0(rw,sync)



-------------------------------------------------------
This SF.Net email is sponsored by BEA Weblogic Workshop
FREE Java Enterprise J2EE developer tools!
Get your free copy of BEA WebLogic Workshop 8.1 today.
http://ads.osdn.com/?ad_id=5047&alloc_id=10808&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs

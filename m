From: "Daniel G. Pruitt" <pruitt@lanl.gov>
Subject: nfsroot via NetApp F840
Date: Fri, 20 Sep 2002 15:09:38 -0600
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <02092015093803.22012@mavericks>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from mavericks.lanl.gov ([128.165.87.180])
	by usw-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 17sV1v-0003Jb-00
	for <nfs@lists.sourceforge.net>; Fri, 20 Sep 2002 14:09:39 -0700
Received: from localhost (localhost [[UNIX: localhost]])
	by mavericks.lanl.gov (8.11.6/8.11.6) id g8KL9cP24762
	for nfs@lists.sourceforge.net; Fri, 20 Sep 2002 15:09:38 -0600
To: nfs@lists.sourceforge.net
Errors-To: nfs-admin@lists.sourceforge.net
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
List-Id: Discussion of NFS under Linux development,
	interoperability,
	and testing. <nfs.lists.sourceforge.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchives/forum.php?forum=nfs>

Hi,

I'm having difficulties getting nfsroot to mount "/" via a NetApp 
filer.  Are there any tricks to this, patches I need, etc.?

Here's what I'm using...

PXEConfig File:

---
DEFAULT netapp

LABEL netapp
  KERNEL linux-2.4.19smp
  APPEND root=/dev/nfs 
nfsroot=128.165.87.20:/vol/vol1/rfs/128.165.87.181,rsize=8192,wsize=8192,nfsvers=3
  IPAPPEND 1

---

I have tried nfsvers 2 and 3.  I have tried tcp and udp nfs.  I have 
tried all combinations of these, and the NetApp won't mount to root 
in the kernel.

I have successfully mounted nfsroot from a Linux NFS Server with 
these options.

Also, once the diskless client is booted (via Linux NFS Server), I 
can successfully mount the NetApp file system to /mnt/tmp.

Any help would be much appreciated.

Thanks,
Daniel



-------------------------------------------------------
This sf.net email is sponsored by:ThinkGeek
Welcome to geek heaven.
http://thinkgeek.com/sf
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs

From: "Lisa Williams" <lisa@fastclick.com>
Subject: Data Corruption Issues
Date: Wed, 27 Aug 2003 10:51:44 -0700
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <008601c36cc3$e1ae87c0$d501010a@Lisa>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="iso-8859-1"
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list1.sourceforge.net with esmtp
	(Cipher TLSv1:DES-CBC3-SHA:168) (Exim 3.31-VA-mm2 #1 (Debian))
	id 19s4Sw-0005cU-00
	for <nfs@lists.sourceforge.net>; Wed, 27 Aug 2003 10:52:18 -0700
Received: from [205.180.85.17] (helo=mail.fastclick.net)
	by sc8-sf-mx1.sourceforge.net with esmtp (Exim 4.22)
	id 19s4Sw-0001dC-73
	for nfs@lists.sourceforge.net; Wed, 27 Aug 2003 10:52:18 -0700
Received: from Lisa (ip193.fastclick.net [205.180.85.193])
	by mail.fastclick.net (8.12.9/8.12.5) with SMTP id h7RHpWd2003692
	for <nfs@lists.sourceforge.net>; Wed, 27 Aug 2003 17:51:32 GMT
To: <nfs@lists.sourceforge.net>
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
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=nfs>

Hi all,

We are finding corruption in mysql database files that are being copied from
16 Linux 2.4.20 servers to a Linux 2.4.21 backup server on an hourly basis.

Here are the details:

The backup server was originally a FreeBSD box that was having some hardware
issues.  We decided to swap it out and replace with a Linux server (running
2.4.21).  We had no issues of data corruption until we swapped machines.

The 16 linux 2.4.20 servers have the backup machine mounted locally and
after each hour a script is run that flushes the tables and then copies them
to the mounted backup drive.  There's no real pattern of which machines
create a corrupt file on the backup machine.  It appears fairly random.  We
are seeing about 20% of them corrupted.

Our network is running at 100MB.

The files are around 25MB each.

We have tried the following settings:

    Increasing the number of nfsd server threads to 20 on the backup
machine.

Changes in the mount options in the 16 fstabs:

    specifying:  tcp, nfsvers=3
    specifying:  udp, nfsvers=2
    specifying:  rsize=1024,wsize=1024

There was no real change in the corruption rate after any of these changes.

Any ideas of what we should try next are appreciated.

Thank you,

-Lisa



-------------------------------------------------------
This sf.net email is sponsored by:ThinkGeek
Welcome to geek heaven.
http://thinkgeek.com/sf
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs

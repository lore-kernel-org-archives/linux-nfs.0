From: Niall  O Broin <niall@magicgoeshere.com>
Subject: NFS filename case problem with Netware server
Date: Mon,  2 Feb 2004 10:15:47 +0000
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <r02010100-1032-C52C0DCC556811D89983000393B4AF7E@[192.168.0.100]>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1Anb8k-0000h8-7P
	for nfs@lists.sourceforge.net; Mon, 02 Feb 2004 02:17:14 -0800
Received: from java.makalumedia.com ([209.61.187.47] helo=makalumedia.com)
	by sc8-sf-mx1.sourceforge.net with esmtp (Exim 4.30)
	id 1Anb8j-0004jD-Pz
	for nfs@lists.sourceforge.net; Mon, 02 Feb 2004 02:17:13 -0800
Received: from [213.79.32.23] (account niall HELO 192.168.0.100)
  by makalumedia.com (CommuniGate Pro SMTP 3.5.7)
  with ESMTP id 3960472 for nfs@lists.sourceforge.net; Mon, 02 Feb 2004 11:15:49 +0100
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

I have a strange NFS problem and I'm wondering if anyone can shed any
light. I have some Linux boxes which need to mount some volumes from a
Netware server via NFS. The appropriate bit of Novell software has been
installed and configured, and the Linux box can mount the volumes.
However, I get errors like this when I do an 'ls' in a particular
directory:

ls: /mnt/netware/CONTRACT/MDAVIS/A700.TST: No such file or directory

I get maybe about 20 of these errors, in a directory which has about
2500 files. Investigation reveals that in each case, there is a
corresponding file whose name is all lower case e.g.

/mnt/netware/CONTRACT/MDAVIS/a700.tst


What appears to happen is that ls does an opendir, then repeated readdir
calls which get it a list of filenames. Then it does a stat call for
each filename to get details.

=46or some reason, for some of the files, it is getting wrong case on the
filename. I was quite convinced that this was a server issue, but now
I'm not so sure, because I see subtly different behaviour with different
NFS clients. The operational clients are RH9 boxes with 2.4.20 as
supplied with RH9. I also tried an OS-X Panther box (to have a NFS
different client stack) and it gave me similar errors, but with a
slightly different set of files. And then oddest of all - I tried with
SuSE 9.0 box which had 2.4.21 as supplied with SuSE and got no errors.
SuSE displayed VERY odd behaviour - for some files whose names were in
upper case, it would return the same information (including inode
number) for a stat on the filename in either upper OR lower case.

I then tried installing a kernel.org 2.4.24 on the RH9 box but this gave
the exact same results as 2.4.20.

So, this odd behaviour gives rise to a number of questions

1) What the hell is going on ?  :-)
2) Is it really a server or client issue ?
3) What's happening with the SuSE box ?
4) Why does ls do the stat call at all ? Indeed, if I do=20

ls -1 /mnt/netware/CONTRACT/MDAVIS > /dev/null I don't see the error at
all, showing that ls doesn't do the stat if stdout is not a tty - but I
don't see why it bothers when stdout IS in fact a tty.



Niall



-------------------------------------------------------
The SF.Net email is sponsored by EclipseCon 2004
Premiere Conference on Open Tools Development and Integration
See the breadth of Eclipse activity. February 3-5 in Anaheim, CA.
http://www.eclipsecon.org/osdn
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs

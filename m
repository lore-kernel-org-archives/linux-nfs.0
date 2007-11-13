From: Gerd Bavendiek <gerd.bavendiek@googlemail.com>
Subject: Differences between 2.6.5 und 2.6.16: getattr with actimeo=0
 and O_DIRECT
Date: Tue, 13 Nov 2007 10:03:42 +0100
Message-ID: <4739686E.8080501@googlemail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
To: nfs@lists.sourceforge.net
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1IrrgP-0005VG-H4
	for nfs@lists.sourceforge.net; Tue, 13 Nov 2007 01:03:45 -0800
Received: from ug-out-1314.google.com ([66.249.92.174])
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1IrrgV-0005d4-3a
	for nfs@lists.sourceforge.net; Tue, 13 Nov 2007 01:03:51 -0800
Received: by ug-out-1314.google.com with SMTP id m2so50845uge
	for <nfs@lists.sourceforge.net>; Tue, 13 Nov 2007 01:03:48 -0800 (PST)
List-Id: "Discussion of NFS under Linux development, interoperability,
	and testing." <nfs.lists.sourceforge.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=nfs>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
Sender: nfs-bounces@lists.sourceforge.net
Errors-To: nfs-bounces@lists.sourceforge.net

Hi,

analyzing performance issues with Oracle databases on an NFS client
running on SLES9 SP3 and NetApp as NFS server, I found that in SLES9
SP3 each write call is followed by an getattr. This is not the case
with SLES10 SP1.

Mount options in use are:

rw,v3,rsize=32768,wsize=32768,acregmin=0,acregmax=0,acdirmin=0,acdirmax=0,hard,lock,proto=tcp,addr=172.18.131.134

I do

dd if=/dev/zero of=/mnt/qqq oflag=direct bs=8k count=100000

and using tcpdump (BTW, is there an easier way ?) I see with SLES9 SP3
(i.e. 2.6.5-7.244) each single 8k write followed by an getattr (which
comes at some cost).

Using SLES10 SP1 (2.6.16.46-0.12) there is only one getattr when dd
closes the file.

Is there anything I can do to avoid the getattr calls in SLES9 SP3
(no, sorry, can't update to SLES10 SP1) ?

Thanks

Gerd


-------------------------------------------------------------------------
This SF.net email is sponsored by: Splunk Inc.
Still grepping through log files to find problems?  Stop.
Now Search log events and configuration files using AJAX and a browser.
Download your FREE copy of Splunk now >> http://get.splunk.com/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs

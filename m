From: John Goerzen <jgoerzen@complete.org>
Subject: Live performance tools?
Date: Mon, 13 Aug 2007 16:25:28 -0500
Message-ID: <slrnfc1j28.fcc.jgoerzen@katherina.lan.complete.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
To: nfs@lists.sourceforge.net
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1IKnGH-00079w-FT
	for nfs@lists.sourceforge.net; Mon, 13 Aug 2007 20:40:05 -0700
Received: from main.gmane.org ([80.91.229.2] helo=ciao.gmane.org)
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1IKnGL-0002U2-Cb
	for nfs@lists.sourceforge.net; Mon, 13 Aug 2007 20:40:09 -0700
Received: from root by ciao.gmane.org with local (Exim 4.43)
	id 1IKnGE-0008Dj-11
	for nfs@lists.sourceforge.net; Tue, 14 Aug 2007 05:40:02 +0200
Received: from 63-245-179-205.kitusa.com ([63.245.179.205])
	by main.gmane.org with esmtp (Gmexim 0.1 (Debian))
	id 1AlnuQ-0007hv-00
	for <nfs@lists.sourceforge.net>; Tue, 14 Aug 2007 05:40:02 +0200
Received: from jgoerzen by 63-245-179-205.kitusa.com with local (Gmexim 0.1
	(Debian)) id 1AlnuQ-0007hv-00
	for <nfs@lists.sourceforge.net>; Tue, 14 Aug 2007 05:40:02 +0200
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

We are deploying a number of Linux desktop clients running NFS against
our Linux NFS server.  We are seeing occasional odd spikes in traffic
that are causing performance troubles for all users.  We are trying to
isolate the cause of these spikes, but to date haven't been able to.
The best we can do is use iostat and verify that yes, the disk we
expected is seeing a lot of traffic.

nfsd threads seem to be impervious to lsof.  top also doesn't show much
about them, and of course you can't strace them.

Is there any tool out there that could give us any of this sort of info:

 * What IP addresses are generating high volumes of read or write
   traffic

 * What files on disk are being accessed frequently via NFS

 * Anything else that could help us pinpoint the trouble

nfsstat does not seem to provide fine enough detail for this.

Thanks,

-- John


-------------------------------------------------------------------------
This SF.net email is sponsored by: Splunk Inc.
Still grepping through log files to find problems?  Stop.
Now Search log events and configuration files using AJAX and a browser.
Download your FREE copy of Splunk now >>  http://get.splunk.com/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs

From: Christoph Hellwig <hch@infradead.org>
Subject: [hch@infradead.org: Re: Mounting DVDs via NFS problem]
Date: Mon, 23 Jan 2006 13:43:10 +0000
Message-ID: <20060123134310.GB13321@infradead.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91] helo=mail.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1F11yX-0001Re-Fn
	for nfs@lists.sourceforge.net; Mon, 23 Jan 2006 05:43:17 -0800
Received: from pentafluge.infradead.org ([213.146.154.40])
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44)
	id 1F11yV-0007Fl-PX
	for nfs@lists.sourceforge.net; Mon, 23 Jan 2006 05:43:17 -0800
To: nfs@lists.sourceforge.net, ed@biased.org
Sender: nfs-admin@lists.sourceforge.net
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

sorry, this should have been sent to the list aswell.

----- Forwarded message from Christoph Hellwig <hch@infradead.org> -----

Date: Mon, 23 Jan 2006 13:42:30 +0000
From: Christoph Hellwig <hch@infradead.org>
Subject: Re: [NFS] Mounting DVDs via NFS problem
To: Piers Kittel <ed@biased.org>

There is no support for eporting ufs filesystems.  Unfortunately exporting
filesystems that don't support this doesn't fail early but only once a client
tries to mount them.

----- End forwarded message -----


-------------------------------------------------------
This SF.net email is sponsored by: Splunk Inc. Do you grep through log files
for problems?  Stop!  Download the new AJAX search engine that makes
searching your log files as easy as surfing the  web.  DOWNLOAD SPLUNK!
http://sel.as-us.falkag.net/sel?cmd=lnk&kid=103432&bid=230486&dat=121642
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs

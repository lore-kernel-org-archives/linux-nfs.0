From: Christoph Hellwig <hch@infradead.org>
Subject: Re: [PATCH kNFSd 014 of 26] nfsd4: recovery lookup dir check
Date: Fri, 13 Jan 2006 09:35:25 +0000
Message-ID: <20060113093525.GA10814@infradead.org>
References: <20060113115744.22704.patches@notabene> <1060113010059.23096@cse.unsw.edu.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91] helo=mail.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1ExLLG-0007n0-1F
	for nfs@lists.sourceforge.net; Fri, 13 Jan 2006 01:35:30 -0800
Received: from pentafluge.infradead.org ([213.146.154.40])
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44)
	id 1ExLLE-0002Jf-PJ
	for nfs@lists.sourceforge.net; Fri, 13 Jan 2006 01:35:30 -0800
To: NeilBrown <neilb@cse.unsw.edu.au>
In-Reply-To: <1060113010059.23096@cse.unsw.edu.au>
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

On Fri, Jan 13, 2006 at 12:00:59PM +1100, NeilBrown wrote:
> 
> Make sure we get a directory when we look up the recovery directory.
> 
> Thanks to Christoph Hellwig for the bug report.
> 
> Based on feedback from Christoph and others, we may remove the need for
> this lookup and just pass in a file descriptor from userspace instead,
> and/or completely move the directory handling to userspace.  For now we're
> just fixing the obvious bugs.

So can you please work on this real fix now?  It's bad enough the current
crappy state has been in mainline for so long.



-------------------------------------------------------
This SF.net email is sponsored by: Splunk Inc. Do you grep through log files
for problems?  Stop!  Download the new AJAX search engine that makes
searching your log files as easy as surfing the  web.  DOWNLOAD SPLUNK!
http://ads.osdn.com/?ad_id=7637&alloc_id=16865&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs

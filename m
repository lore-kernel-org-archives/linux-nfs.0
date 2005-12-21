From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: kernel BUG at fs/locks.c:1932!
Date: Tue, 20 Dec 2005 21:54:02 -0500
Message-ID: <1135133642.7937.22.camel@lade.trondhjem.org>
References: <20051221020027.82238.qmail@web34115.mail.mud.yahoo.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91] helo=mail.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1Eou7R-0002RE-Br
	for nfs@lists.sourceforge.net; Tue, 20 Dec 2005 18:54:21 -0800
Received: from pat.uio.no ([129.240.130.16] ident=7411)
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44)
	id 1Eou7Q-0002YJ-3V
	for nfs@lists.sourceforge.net; Tue, 20 Dec 2005 18:54:21 -0800
To: Kenny Simpson <theonetruekenny@yahoo.com>
In-Reply-To: <20051221020027.82238.qmail@web34115.mail.mud.yahoo.com>
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

On Tue, 2005-12-20 at 18:00 -0800, Kenny Simpson wrote:
> While running some tests (in this case sio) on 2.6.15-rc5 kernel with a recent NFS_ALL patch
> applied, I got this:
> 
> [ 1543.034595]  ------------[ cut here ]------------
> [ 2687.686724] kernel BUG at fs/locks.c:1932!

Hmm... That indicates that some posix locks are somehow still managing
to survive a close().

How did you trigger this problem? Were you signalling the process?

Cheers,
  Trond



-------------------------------------------------------
This SF.net email is sponsored by: Splunk Inc. Do you grep through log files
for problems?  Stop!  Download the new AJAX search engine that makes
searching your log files as easy as surfing the  web.  DOWNLOAD SPLUNK!
http://ads.osdn.com/?ad_id=7637&alloc_id=16865&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs

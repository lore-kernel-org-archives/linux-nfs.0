From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: NFS TCP settings
Date: Tue, 20 Dec 2005 10:47:06 -0500
Message-ID: <1135093627.7955.36.camel@lade.trondhjem.org>
References: <20051220153837.63707.qmail@web34102.mail.mud.yahoo.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92] helo=mail.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1EojiE-00069w-H8
	for nfs@lists.sourceforge.net; Tue, 20 Dec 2005 07:47:38 -0800
Received: from pat.uio.no ([129.240.130.16] ident=7411)
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44)
	id 1EojiA-0002Kw-Hf
	for nfs@lists.sourceforge.net; Tue, 20 Dec 2005 07:47:38 -0800
To: Kenny Simpson <theonetruekenny@yahoo.com>
In-Reply-To: <20051220153837.63707.qmail@web34102.mail.mud.yahoo.com>
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

On Tue, 2005-12-20 at 07:38 -0800, Kenny Simpson wrote:
> Hello,
>   Why does the Linux NFS client force the rsize ans wsize to be a power of 2, and why is the TCP
> window size equal to the rsize or wsize?

The NFS/RPC code has no direct control over the TCP window size. That
would be an issue for the networking people.

As for the issue of forcing the rsize/wsize to be a power of two, then 2
reasons come to mind:

 1) We want to make it easy to match PAGE_CACHE_SIZE and read/write
request sizes.
 2) server block sizes are usually powers of two.

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

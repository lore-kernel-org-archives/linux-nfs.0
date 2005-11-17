From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: Periodic NFS client cache flushing?
Date: Thu, 17 Nov 2005 15:42:39 -0500
Message-ID: <1132260159.8025.16.camel@lade.trondhjem.org>
References: <9E621559095AA746B22B21CD4FAF99A5573A1D@EDINMAIL1.ad.datcon.co.uk>
Mime-Version: 1.0
Content-Type: text/plain
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92] helo=mail.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1Ecqb4-00016u-38
	for nfs@lists.sourceforge.net; Thu, 17 Nov 2005 12:43:06 -0800
Received: from pat.uio.no ([129.240.130.16] ident=7411)
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44)
	id 1Ecqb0-0004Q1-JA
	for nfs@lists.sourceforge.net; Thu, 17 Nov 2005 12:43:06 -0800
To: Edward Hibbert <Edward.Hibbert@dataconnection.com>
In-Reply-To: <9E621559095AA746B22B21CD4FAF99A5573A1D@EDINMAIL1.ad.datcon.co.uk>
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

On Thu, 2005-11-17 at 19:18 +0000, Edward Hibbert wrote:
> Bit speculative, this one.  Is there any code which would cause a
> Linux NFS client to periodically flush lots of data to the server?  If
> so, can you control the interval of this, and hence smooth out the
> impact?

There is even a POSIX function to help you do this in a fully portable
fashion: fdatasync

Cheers,
  Trond



-------------------------------------------------------
This SF.Net email is sponsored by the JBoss Inc.  Get Certified Today
Register for a JBoss Training Course.  Free Certification Exam
for All Training Attendees Through End of 2005. For more info visit:
http://ads.osdn.com/?ad_id=7628&alloc_id=16845&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs

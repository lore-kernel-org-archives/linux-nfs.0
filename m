From: Neil Brown <neilb@suse.de>
Subject: Re: [PATCH] Memory leak in mountd
Date: Fri, 11 May 2007 21:09:39 +1000
Message-ID: <17988.20211.594570.156375@notabene.brown>
References: <20070511104906.GA21288@uio.no>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net
To: "Steinar H. Gunderson" <sesse@debian.org>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1HmT0l-0001MD-Gu
	for nfs@lists.sourceforge.net; Fri, 11 May 2007 04:10:11 -0700
Received: from ns2.suse.de ([195.135.220.15] helo=mx2.suse.de)
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1HmT0n-0006Ma-Rh
	for nfs@lists.sourceforge.net; Fri, 11 May 2007 04:10:14 -0700
In-Reply-To: message from Steinar H. Gunderson on Friday May 11
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

On Friday May 11, sesse@debian.org wrote:
> Hi,
> 
> A user complained that mountd was slowly eating up all available memory with
> about a mount per second. We tracked it down, and ended up with the following
> patch:

Bother - I should have delayed 1.1.0 one more day.... but such is
life.

Thanks.  I've applied the patch.

> The patch was against 1.0.10 (Debian stable), but should be equivalently
> applied for 1.1.0. (Also, we backported the add_name() leak fix.) In
> addition, there's a leak in innetgr() (in glibc) that hits mountd quite hard
> when using netgroups, but it appears to already be fixed in at least Red Hat,
> and I guess this is the wrong place to complain about glibc issues :-)

I guess, but it is good to know it nonetheless.

NeilBrown

-------------------------------------------------------------------------
This SF.net email is sponsored by DB2 Express
Download DB2 Express C - the FREE version of DB2 express and take
control of your XML. No limits. Just data. Click to get it now.
http://sourceforge.net/powerbar/db2/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs

From: David Jeffery <david_jeffery@adaptec.com>
Subject: Re: linux 2.4.18-5 nfs/rpc problem
Date: 13 Oct 2003 10:17:15 -0400
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <1066054635.669.9.camel@blackmagic>
References: <shsk77c27yl.fsf@charged.uio.no>
Mime-Version: 1.0
Content-Type: text/plain
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list1.sourceforge.net with esmtp
	(Cipher TLSv1:DES-CBC3-SHA:168) (Exim 3.31-VA-mm2 #1 (Debian))
	id 1A93U2-000292-00
	for <nfs@lists.sourceforge.net>; Mon, 13 Oct 2003 07:15:38 -0700
Received: from magic-mail.adaptec.com ([216.52.22.10] helo=magic.adaptec.com)
	by sc8-sf-mx1.sourceforge.net with esmtp (Exim 4.22)
	id 1A93U1-0005dy-10
	for nfs@lists.sourceforge.net; Mon, 13 Oct 2003 07:15:37 -0700
Received: from redfish.adaptec.com (redfish.adaptec.com [162.62.50.11])
	by magic.adaptec.com (8.11.6/8.11.6) with ESMTP id h9DEF6s02491
	for <nfs@lists.sourceforge.net>; Mon, 13 Oct 2003 07:15:06 -0700
Received: from rtpexc01.adaptec.com (rtpexc01.adaptec.com [10.110.12.22])
	by redfish.adaptec.com (8.8.8p2+Sun/8.8.8) with ESMTP id HAA22728
	for <nfs@lists.sourceforge.net>; Mon, 13 Oct 2003 07:15:05 -0700 (PDT)
To: "nfs@lists.sourceforge.net" <nfs@lists.sourceforge.net>
In-Reply-To: <shsk77c27yl.fsf@charged.uio.no>
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

On Fri, 2003-10-10 at 15:44, Trond Myklebust wrote:
> >>>>> " " == Trond Myklebust <trond.myklebust@fys.uio.no> writes:
> 
>      > There is indeed one case where this is not being done: in
>      > page_launder() you only have a lock on the page. This means
>      > that you may end up calling nfs_wait_on_request() in order to
>      > flush out a page only to discover that it called iput() from
>      > beneath you and is now waiting in clear_inode() on your page
>      > lock.
> 
> Sorry. I meant 'shrink_cache()'. page_launder() probably disappeared
> around 2.4.10 8-).
> 
> The point was that writepage() should be the only case where the above
> is a problem. I believe readpage does not suffer from the same issue
> since it can only be called while the file is still open...
> 
> Cheers,
>   Trond

Trond,

I don't see any holes in your much simpler patch.  I'm glad you spotted
a much simpler approach than mine.  I really didn't like the ugly
-EDEADLK game I was playing in my second patch. I'll post something if I
see a problem but I doubt I will. Thanks Trond.

David Jeffery






-------------------------------------------------------
This SF.net email is sponsored by: SF.net Giveback Program.
SourceForge.net hosts over 70,000 Open Source Projects.
See the people who have HELPED US provide better services:
Click here: http://sourceforge.net/supporters.php
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs

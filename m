From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: [PATCH] Minor problem in nfsv3 write
Date: Tue, 20 Sep 2005 19:46:16 -0400
Message-ID: <20050920234616.GH31948@fieldses.org>
References: <20050920011046.23A07F4@dead.void.org> <20050920012525.GA26729@fieldses.org> <432FFFC7.7010803@redhat.com> <20050920183054.BCB62F4@dead.void.org> <20050920192640.GD31948@fieldses.org> <20050920221910.323E8F4@dead.void.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Peter Staubach <staubach@redhat.com>, nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92] helo=mail.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1EHroc-0005bB-AF
	for nfs@lists.sourceforge.net; Tue, 20 Sep 2005 16:46:22 -0700
Received: from dsl093-002-214.det1.dsl.speakeasy.net ([66.93.2.214] helo=pickle.fieldses.org)
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44)
	id 1EHroZ-0001cR-SQ
	for nfs@lists.sourceforge.net; Tue, 20 Sep 2005 16:46:22 -0700
To: Steven <steven@void.org>
In-Reply-To: <20050920221910.323E8F4@dead.void.org>
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

On Tue, Sep 20, 2005 at 03:19:10PM -0700, Steven wrote:
> 
> The following changes the nfs write procedure so that it reports the
> number of bytes written correctly when the requested write size execeeds
> the server's maximum write transfer size.  The server was reporting that
> it wrote the number of bytes the client requested, but in fact it only
> wrote the max transfer size.
> 
> For linux-2.6.13.2.
> 
> --Steven Procter

Thanks.  For next time; note that these should apply with -p1, so should
have another pathname component at the beginning:

> --- fs/nfsd/nfs3xdr.c.orig	2005-09-20 13:49:52.000000000 -0700
> +++ fs/nfsd/nfs3xdr.c	2005-09-20 13:49:53.000000000 -0700

Again, this is in Documentation/SubmittingPatches.

(We all have scripts to automate the process, which are happier if
everyone follows the same conventions.)

--b.


-------------------------------------------------------
SF.Net email is sponsored by:
Tame your development challenges with Apache's Geronimo App Server. 
Download it for free - -and be entered to win a 42" plasma tv or your very
own Sony(tm)PSP.  Click here to play: http://sourceforge.net/geronimo.php
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs

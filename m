From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: [PATCH kNFSd 1 of 9] Calls to break_lease in nfsd should be O_NONBLOCKing.
Date: Thu, 7 Oct 2004 16:18:56 -0400
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <20041007201856.GA30356@fieldses.org>
References: <20040903122815.15453.patches@notabene> <E1C33uD-00042m-VA@notabene.cse.unsw.edu.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Andrew Morton <akpm@osdl.org>, nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.12] helo=sc8-sf-mx2.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1CFej8-0004C5-LI
	for nfs@lists.sourceforge.net; Thu, 07 Oct 2004 13:19:02 -0700
Received: from dsl093-002-214.det1.dsl.speakeasy.net ([66.93.2.214] helo=pickle.fieldses.org)
	by sc8-sf-mx2.sourceforge.net with esmtp (TLSv1:RC4-SHA:128)
	(Exim 4.41)
	id 1CFej7-0000TB-5k
	for nfs@lists.sourceforge.net; Thu, 07 Oct 2004 13:19:02 -0700
To: NeilBrown <neilb@cse.unsw.edu.au>
In-Reply-To: <E1C33uD-00042m-VA@notabene.cse.unsw.edu.au>
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

On Fri, Sep 03, 2004 at 12:34:25PM +1000, NeilBrown wrote:
> 
> If we would block, we return "err-jukebox" for nfsv3,
> or just drop the request for v2.

Sorry, only just noticed there's a problem here:

> diff ./fs/nfsd/nfsproc.c~current~ ./fs/nfsd/nfsproc.c
> --- ./fs/nfsd/nfsproc.c~current~	2004-09-03 11:34:26.000000000 +1000
> +++ ./fs/nfsd/nfsproc.c	2004-09-03 11:34:29.000000000 +1000
> @@ -586,6 +586,7 @@ nfserrno (int errno)
>  		{ nfserr_dquot, -EDQUOT },
>  #endif
>  		{ nfserr_stale, -ESTALE },
> +		{ nfserr_jukebox, -EWOULDBLOCK },
>  		{ nfserr_jukebox, -ETIMEDOUT },
>  		{ nfserr_dropit, -EAGAIN },
>  		{ nfserr_dropit, -ENOMEM },

Note that EWOULDBLOCK is defined to be EAGAIN in
include/asm-generic/errno.h, so the effect of this is to map EAGAIN to
nfserr_jukebox instead of nfserr_dropit.

The cache upcall deferral code depends on EAGAIN being mapped to
nfserr_dropit.  So now whenever cache upcall deferral happens, the
client gets a nfserr_jukebox response, which isn't what we want.

--b.


-------------------------------------------------------
This SF.net email is sponsored by: IT Product Guide on ITManagersJournal
Use IT products in your business? Tell us what you think of them. Give us
Your Opinions, Get Free ThinkGeek Gift Certificates! Click to find out more
http://productguide.itmanagersjournal.com/guidepromo.tmpl
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs

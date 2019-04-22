Return-Path: <SRS0=DK+G=SY=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 4038CC282CE
	for <linux-nfs@archiver.kernel.org>; Mon, 22 Apr 2019 23:47:18 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 1AC3F2075A
	for <linux-nfs@archiver.kernel.org>; Mon, 22 Apr 2019 23:47:18 +0000 (UTC)
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1730786AbfDVXrR (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Mon, 22 Apr 2019 19:47:17 -0400
Received: from mx2.suse.de ([195.135.220.15]:56698 "EHLO mx1.suse.de"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1730585AbfDVXrQ (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Mon, 22 Apr 2019 19:47:16 -0400
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
        by mx1.suse.de (Postfix) with ESMTP id 5D1A0AD65;
        Mon, 22 Apr 2019 23:47:15 +0000 (UTC)
From:   NeilBrown <neilb@suse.com>
To:     Jeff Layton <jlayton@kernel.org>, bfields@fieldses.org
Date:   Tue, 23 Apr 2019 09:47:06 +1000
Cc:     slawek1211@gmail.com, linux-nfs@vger.kernel.org
Subject: Re: [PATCH v2 1/2] nfsd: wake waiters blocked on file_lock before deleting it
In-Reply-To: <20190422163424.19402-2-jlayton@kernel.org>
References: <20190422163424.19402-1-jlayton@kernel.org> <20190422163424.19402-2-jlayton@kernel.org>
Message-ID: <87wojl61s5.fsf@notabene.neil.brown.name>
MIME-Version: 1.0
Content-Type: multipart/signed; boundary="=-=-=";
        micalg=pgp-sha256; protocol="application/pgp-signature"
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

--=-=-=
Content-Type: text/plain
Content-Transfer-Encoding: quoted-printable

On Mon, Apr 22 2019, Jeff Layton wrote:

> After a blocked nfsd file_lock request is deleted, knfsd will send a
> callback to the client and then free the request. Commit 16306a61d3b7
> ("fs/locks: always delete_block after waiting.") changed it such that
> locks_delete_block is always called on a request after it is awoken,
> but that patch missed fixing up blocked nfsd request handling.
>
> Call locks_delete_block on the block to wake up any locks still blocked
> on the nfsd lock request before freeing it. Some of its callers already
> do this however, so just remove those calls.
>
> URL: https://bugzilla.kernel.org/show_bug.cgi?id=3D203363
> Fixes: 16306a61d3b7 ("fs/locks: always delete_block after waiting.")
> Reported-by: Slawomir Pryczek <slawek1211@gmail.com>
> Cc: Neil Brown <neilb@suse.com>
> Cc: stable@vger.kernel.org
> Signed-off-by: Jeff Layton <jlayton@kernel.org>
> ---
>  fs/nfsd/nfs4state.c | 3 +--
>  1 file changed, 1 insertion(+), 2 deletions(-)
>
> diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
> index 6a45fb00c5fc..e87e15df2044 100644
> --- a/fs/nfsd/nfs4state.c
> +++ b/fs/nfsd/nfs4state.c
> @@ -265,6 +265,7 @@ find_or_allocate_block(struct nfs4_lockowner *lo, str=
uct knfsd_fh *fh,
>  static void
>  free_blocked_lock(struct nfsd4_blocked_lock *nbl)
>  {
> +	locks_delete_block(&nbl->nbl_lock);
>  	locks_release_private(&nbl->nbl_lock);

Thanks for tracking this down.

An implication of this bug and fix is that we need to be particularly
careful to make sure locks_delete_block() is called on all relevant
paths.
Can we make that easier?  My first thought was to include the call in
locks_release_private, but lockd calls the two quite separately and it
certainly seems appropriate that locks_delete_block should be called
asap, but locks_release_private() can be delayed.

Also cifs calls locks_delete_block, but never calls
locks_release_private, so it wouldn't help there.

Looking at cifs, I think there is a call missing there too.
cifs_posix_lock_set() *doesn't* always call locks_delete_block() after
waiting.  In particular, if ->can_cache_brlcks becomes true while
waiting then I don't think the behaviour is right.... though I'm not
sure it is right for other reasons.  It looks like the return value
should be 1 in that case, but it'll be zero.

But back to my question about making it easier, move the BUG_ON()
calls from locks_free_lock() into locks_release_private().

??

Thanks,
NeilBrown


>  	kfree(nbl);
>  }
> @@ -293,7 +294,6 @@ remove_blocked_locks(struct nfs4_lockowner *lo)
>  		nbl =3D list_first_entry(&reaplist, struct nfsd4_blocked_lock,
>  					nbl_lru);
>  		list_del_init(&nbl->nbl_lru);
> -		locks_delete_block(&nbl->nbl_lock);
>  		free_blocked_lock(nbl);
>  	}
>  }
> @@ -4863,7 +4863,6 @@ nfs4_laundromat(struct nfsd_net *nn)
>  		nbl =3D list_first_entry(&reaplist,
>  					struct nfsd4_blocked_lock, nbl_lru);
>  		list_del_init(&nbl->nbl_lru);
> -		locks_delete_block(&nbl->nbl_lock);
>  		free_blocked_lock(nbl);
>  	}
>  out:
> --=20
> 2.20.1

--=-=-=
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----

iQIzBAEBCAAdFiEEG8Yp69OQ2HB7X0l6Oeye3VZigbkFAly+UnsACgkQOeye3VZi
gbkUsQ/9F9aJ4nlzK7eMnIxdvvIf4zrwLE9rnpOk1lEYl3cHMGfWi887M1reca64
c8v+XGTgRSCK7Aave+YPaElmpU2lv7uXTTXKZQ5qexBE7qKVDLXe/vM7XAPZRRAG
AjxgZLdED2jqMZYae8eElPQyFXhstfiuWAZIltKKiQhCy3IDEViCle6yvAAJDiPe
e+sOlFCllxpb4lJkp9NS0p0UkXlqHEGstsGOeptyShC6k+e1KY3qYSXIhs4pVldq
Dk6lC0srFWR6OZjMNi0GkBRigTUVWZ6Oa+HDTQ9nMio3WH6JpUDh9Bgz2rZyKImt
rgCFHvsd8tSz7EI5v/LFXx8+DoXjkmVw1xVoFaCgFLjx1CqMIoAq5g5aYOnOiD0p
TD2K/kHy0Avz9Cr0uqVgYxzo+Atpw0FnUYaf2WXZfa1mT5g2WT94On2qNm/e8JKo
RZrd36cWsEY+tsU2+jgMegdE+lMSMzsb9+4GauW2kwZh79xNCMv7XghSRW8+mioV
Pu9PhOT28+xeaX0so57UMoVeRVvMii07+V0yr4jCv2tBA2SW33UzblhRkKyvPxCY
0GXHRDI+A0KOxs4sylMxSWm/ztRTkzVfKGqhGK0G4g4WWkJUEiFF+DcRCyE616hT
f7o3EXZsvnf67HDhBAEtXHjLy3ShIe7/GpeQHd4UPJN2kn9TcRA=
=z7Sy
-----END PGP SIGNATURE-----
--=-=-=--

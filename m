Return-Path: <SRS0=2kk+=YV=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.8 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS autolearn=no autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 5BFA4CA9EAF
	for <linux-nfs@archiver.kernel.org>; Mon, 28 Oct 2019 03:24:33 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 3201B20B7C
	for <linux-nfs@archiver.kernel.org>; Mon, 28 Oct 2019 03:24:33 +0000 (UTC)
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1728550AbfJ1DYc (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Sun, 27 Oct 2019 23:24:32 -0400
Received: from mx2.suse.de ([195.135.220.15]:54336 "EHLO mx1.suse.de"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1727119AbfJ1DYc (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Sun, 27 Oct 2019 23:24:32 -0400
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
        by mx1.suse.de (Postfix) with ESMTP id ECAA9AB9B;
        Mon, 28 Oct 2019 03:24:30 +0000 (UTC)
From:   NeilBrown <neilb@suse.de>
To:     "J. Bruce Fields" <bfields@redhat.com>
Date:   Mon, 28 Oct 2019 14:24:23 +1100
Cc:     linux-nfs@vger.kernel.org
Subject: Re: uncollected nfsd open owners
In-Reply-To: <20191025152047.GB16053@pick.fieldses.org>
References: <87mudpfwkj.fsf@notabene.neil.brown.name> <20191025152047.GB16053@pick.fieldses.org>
Message-ID: <87a79lft7c.fsf@notabene.neil.brown.name>
MIME-Version: 1.0
Content-Type: multipart/signed; boundary="=-=-=";
        micalg=pgp-sha256; protocol="application/pgp-signature"
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

--=-=-=
Content-Type: text/plain

On Fri, Oct 25 2019, J. Bruce Fields wrote:
>
>>  Also, should we put a cond_resched() in some or all of those loops in
>>  __destroy_client() ??
>
> Looks like it helped find a bug in this case....
>
> Destroying a client that has a ton of active state should be an unusual
> situation.
>
> I don't know, maybe?  I'm sure this isn't the only spinlock-protected
> kernel code where we don't have a strict bound on a loop, what's been
> the practice elsewhere?  Worst case, the realtime code allows preempting
> spinlocks, right?

 git grep cond_resched_lock

But most of __destroy_client isn't protected by a spinlock....

I dunno - maybe it doesn't matter.


> Might be nice to have some sort of limits on the number of objects (like
> stateowners) that can be created.  But it's a pain when we get one of
> those limits wrong. (See
> git log -L :nfsd4_get_drc_mem:fs/nfsd/nfs4state.c.)

Grin...
>

NeilBrown

--=-=-=
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----

iQIzBAEBCAAdFiEEG8Yp69OQ2HB7X0l6Oeye3VZigbkFAl22X2gACgkQOeye3VZi
gbnS/A//QqM+iymbvanXHUWRO7eLpNpEZ9oY9QrBd48yIlVBlfmAhAo1pfRq4Du0
ujXRge4W9MCABilWFL6U+ZITUa/CJciGprdGkgCbqyYJOYFxryNAgKV9U+wfEnO1
PAfIWiwIrFGJey8r+eAEinj8j4fD1uSUbvH846Mh2DtXSpjiLwoNAcSa2ib9xLLd
BUia80cXTaX9wRfsr+dL8Ovq4Uy/rdSnVBaEs2TqiJLZKdJaJJbZearMsCmNo5JU
EIzgahepHhGA6Zp0v+UXSR1drHEC9DUOu+qoeTgULTxPyqNdu07D/Cq2TKcJ2vVR
gm7Kd5GCbdZa923V4sTOdvN9J4VcorLkxNx5O2j2G0FvtZhqWCyV1Lsz8P1PylSG
yxKsi8qRy9KQ1JtN7wjNSSEO4EXbYp8mkngwmqcCTmCrO8pck+oblPQLFtXVXWO5
GQqKASoIgezFk2M0O/xz35RNNsae15Af/NJRb0b1XYEa1Ik0V8JaEdxQB4uWAXou
b1jya8qHTyTY8OODnr2MSnaw+wVNKeCeaAqpWgac/g3PDGM3NB4b3W14Y1w4ZJPI
meqa1IJGKstvBxbXjVUZvwzs61jgNgCji56kdYzca2OkYLdhhjqm7V27Rm6eyt27
ECmvDkfxEi7Uk9xRPGXjpzEwssdt6MZrwIyVHlilG7xaOmxZs48=
=qx9v
-----END PGP SIGNATURE-----
--=-=-=--

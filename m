From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: Fixes for NFS in environments with large group memberships
Date: Tue, 5 Apr 2011 19:35:52 -0400
Message-ID: <20110405233552.GB27961@fieldses.org>
References: <A50602A820F61543B29992A418BB321B66E18F8A4A@seldmbx01.corpusers.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
To: "Finney, Sean" <Sean.Finney@sonyericsson.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([174.143.236.118]:58282 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751859Ab1DEXfw convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 5 Apr 2011 19:35:52 -0400
In-Reply-To: <A50602A820F61543B29992A418BB321B66E18F8A4A-g6SuDuYnGwoBLpZRX7oUTsm4BeyDBExM@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, Apr 04, 2011 at 10:02:59AM +0200, Finney, Sean wrote:
> Hi There!
>=20
> Last week I fired off a couple patches to this list and in hindsight =
I
> realize that I might not have been totally clear for the motivation
> behind the patches:
>=20
> [PATCH] Use a named constant for max number of managed groups, and in=
c
> [PATCH] Increase the default buffer size for cachelist channel files.

I can't find those; could you resend?

--b.

>=20
> Since nobody has reviewed them yet, I thought I'd make it clear that
> these changes (or something along such lines) are required for NFS
> access to mountpoints when users are in largeish (>100) numbers of
> groups.  There are actually two problems:
>=20
> * Hard-coded limit for group membership at 100 groups in mountd sourc=
e
> * Large server-side procfs writes are split into mulitple writes due =
to
> stdio buffering in mountd and svcgssd sources, resulting in client
> hangs.
>=20
> The patches in question solve this in as non-intrusive a manner as
> possible, though I'm of course open to changing things up if you feel=
 it
> should be done otherwise.  So please let me know what you think, or i=
f
> it would be better for me to first go and open a bug, start a
> discussion, etc.
>=20
>=20
> Thanks,
> Sean=20
> N?????r??y????b?X??=C7=A7v?^?)=DE=BA{.n?+????{???"??^n?r???z?=1A??h??=
???&??=1E?G???h?=03(?=E9=9A=8E?=DD=A2j"??=1A?=1Bm??????z?=DE=96???f???h=
???~?m

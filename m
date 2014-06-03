Return-Path: linux-nfs-owner@vger.kernel.org
Received: from bombadil.infradead.org ([198.137.202.9]:53202 "EHLO
	bombadil.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751202AbaFCKse (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 3 Jun 2014 06:48:34 -0400
Date: Tue, 3 Jun 2014 12:48:23 +0200
From: Peter Zijlstra <peterz@infradead.org>
To: Trond Myklebust <trond.myklebust@primarydata.com>
Cc: John Stultz <john.stultz@linaro.org>,
        Jeff Layton <jeff.layton@primarydata.com>,
        Linus Torvalds <torvalds@linux-foundation.org>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>,
        Linux Kernel mailing list <linux-kernel@vger.kernel.org>,
        Ingo Molnar <mingo@elte.hu>
Subject: Re: nfs4_do_reclaim lockdep pop in v3.15.0-rc1
Message-ID: <20140603104823.GU11096@twins.programming.kicks-ass.net>
References: <20140602104948.4faf0bc2@tlielax.poochiereds.net>
 <CAHQdGtRR6SvEhXiqWo24hoUh9AU9cL82Z8Z-d8-7u951F_d+5g@mail.gmail.com>
 <CALAqxLVmRdv3eVaf_ue-NutDmjxJA2NNAXnH-Tm4a6ud2U7Q4g@mail.gmail.com>
 <CAHQdGtSn9RwdgaFgEDQXjrxSA_Bg=rNWux+96-5f43dyUwXLRw@mail.gmail.com>
 <CALAqxLUwtMnE9eB_dfV=C5CLuXpEdB9+mK7pw2jgo5Yg2ACKPA@mail.gmail.com>
 <CAHQdGtQhurcOsAii7PYNZwEL4Xm-8a2CKBkS4OhrS0FhaAX3Aw@mail.gmail.com>
MIME-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="0ynlhraTE7dg5hjP"
In-Reply-To: <CAHQdGtQhurcOsAii7PYNZwEL4Xm-8a2CKBkS4OhrS0FhaAX3Aw@mail.gmail.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


--0ynlhraTE7dg5hjP
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Mon, Jun 02, 2014 at 08:59:21PM -0400, Trond Myklebust wrote:
>=20
> I can change the write seqcount to use raw_write_seqcount(), but that
> doesn't answer the question of why raw_seqcount_begin() is the _only_
> object out there with a "raw_" prefix, that doesn't explicitly disable
> lockdep checking.

raw_spinlock_t has lockdep too.. just to add to the confusion.



--0ynlhraTE7dg5hjP
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.12 (GNU/Linux)

iQIcBAEBAgAGBQJTjaf3AAoJEHZH4aRLwOS6Z08P/1o/nFfk6dd1wHXP7M9PMXec
HD/y0pI8CYTwshkOcozQEEiFjUTQ1Ul13NXAudnaXdzNwZSHsjTn1L3ihcCIBZXp
uS2rbau0XCxe/XbhRQKLndiXkDJoHa7FoyKRJbZTj+QX3UAnIwAG9pYX/72bzmCB
jb4J6YbEbM13TKXF/z3mwGkbcKFQQ5b5z4uXLaEHBQh6Lm7i4PtxVKNq32UB5f4J
45uApiQW+yzctJzK1YQyHwBwey/Uu5HnSsG8QDCSSXZ+gNpWwFpgyG75XD6uSd+y
rl4VZxRLHL47Q/Go32J8OGvzwmq1riYifRbLpe6kthbp6tYZQbbBSg2QlXQaBQj4
0spZd4EkBg+YZcZd30up+XgowXkj0wjTMw5BSnqksmtU/F3PXRqtW9VpaHHThdzi
1N2k6L9PTPJopIU8AE60YV94CKA0g6QlLYQ2rxQMYXinzdy4zvbuhsGKKFXUdsCT
iBNjSVmu1x9i7wqkFahudu7qBpkFxCKuL4grXEy2JR6g0w6ycGI9d2ZuTJdqLP7y
qnqaK1DfUL2dtiZMcX/dO9e2i5XCV5uGu2WGc+VHw05zsKRP+1+aeT8YU/hBuy8M
cTaHaFrtjdj+u7TUI8n4FyUE8/kVafHFoOdd2ApHfu3gpmsD195F4/CixLY/ATub
2LTZO77hXANVcX5UlqKE
=rFBX
-----END PGP SIGNATURE-----

--0ynlhraTE7dg5hjP--

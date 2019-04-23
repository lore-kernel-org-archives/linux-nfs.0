Return-Path: <SRS0=AvAq=SZ=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,MENTIONS_GIT_HOSTING,SPF_PASS autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 8E05AC10F11
	for <linux-nfs@archiver.kernel.org>; Tue, 23 Apr 2019 00:22:01 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 4A3AB2075A
	for <linux-nfs@archiver.kernel.org>; Tue, 23 Apr 2019 00:22:01 +0000 (UTC)
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1729478AbfDWAWA (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Mon, 22 Apr 2019 20:22:00 -0400
Received: from mx2.suse.de ([195.135.220.15]:32988 "EHLO mx1.suse.de"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1728922AbfDWAWA (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Mon, 22 Apr 2019 20:22:00 -0400
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
        by mx1.suse.de (Postfix) with ESMTP id 89415AEE2;
        Tue, 23 Apr 2019 00:21:59 +0000 (UTC)
From:   NeilBrown <neilb@suse.com>
To:     Doug Nazar <nazard@nazar.ca>,
        "J. Bruce Fields" <bfields@redhat.com>, linux-nfs@vger.kernel.org
Date:   Tue, 23 Apr 2019 10:21:53 +1000
Subject: Re: nfsd bug after f875a792abe9 (nfsd: allow nfsv3 readdir request to be larger.)
In-Reply-To: <5b98d3d5-4b80-8783-b212-4fd7ab9b1006@nazar.ca>
References: <5b98d3d5-4b80-8783-b212-4fd7ab9b1006@nazar.ca>
Message-ID: <87tvep6066.fsf@notabene.neil.brown.name>
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

On Sat, Apr 20 2019, Doug Nazar wrote:

> After recently upgrading the kernel on one of my servers I was getting=20
> the below crashes. Tracked it down to an NFSv3 root client, bisection=20
> points to f875a792abe9. A revert of that on top of=20
> 5.1.0-rc5-00289-gee2725f711fa works fine.

hi Doug,
 thanks for the report and for bisecting!

I think this bug has been fixed, but the fix hasn't landed upstream yet.
If you
   git pull git://git.linux-nfs.org/~bfields/linux.git nfs-next

you should get

Commit 3c86794ac0e6 ("nfsd/nfsd3_proc_readdir: fix buffer count and page po=
inters")

which should fix this.


Bruce:  I don't see that patch in your "for-5.1" branch, but you said
   "Queuing up for 5.1."
Did something go awry?

Thanks,
NeilBrown

--=-=-=
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----

iQIzBAEBCAAdFiEEG8Yp69OQ2HB7X0l6Oeye3VZigbkFAly+WqEACgkQOeye3VZi
gblyKw/8DYhkWZhSN81BVdoQXyQaC6Edq1ECIBblHpN2Ard9LVz7vnPpQVipzlZm
NnL0aa/dvL3JQR8wx94iYXZ9ZpHbs2A4jBowHXTZeaj1+L+k6p9fK6PkszDut2yR
KgMFzqyLWffYrZvf1Z7eDL9ZE2hUOWejqhtMSWGz5l4vRATUAC2eEQUWJ0vZw9TZ
aIDxJcT7Kc34+zQK5SEgf2nw6BKzn1/fG1WeTfcOdxLOpAt+FkA8rdb2gxRb7/wi
d2/xfORBVLZypALOcxqIhXnLP0JNg9y/ZYbPCAdmRrVELRF9GuXCiD6M9YvZkpfk
OoWbaIcCy8FU7q3u+l9EK7syDI8Y8N2NfowqCwFu2jAW8mwj50tKg1nGXNeQi95P
v62riuZAAFh6K0vrhYy/+rtsD7NwQwNCJsXQfIhYWXU+Q5U6dvE0SQylIP7Q+EXE
xyxXujNWrLwMMPNTf8eRATP51sXAVgAVhLKS5xs15h0MdJ+Vk128TOu8OOQ2T+GD
KLa2kvYRiLIEz5VSrO7++/ATVwdrdfmN38e3iLKmF4zlCumU4DL9sl15reGuWdUN
JKULfm511FLC/ru97K2m+dgcJFeg4PqB/jbCPSMlhcOvcGmX0jVLrXoaauEebzJg
TlYHYfqNbBfwST8mzl/ARFB45wEHYLRDOkZz6YpE1SlvN3ATx5I=
=pZkd
-----END PGP SIGNATURE-----
--=-=-=--

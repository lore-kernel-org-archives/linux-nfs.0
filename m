Return-Path: <SRS0=XDbB=OV=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.9 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS,URIBL_BLOCKED autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 02D83C65BAF
	for <linux-nfs@archiver.kernel.org>; Wed, 12 Dec 2018 22:45:43 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id C539920645
	for <linux-nfs@archiver.kernel.org>; Wed, 12 Dec 2018 22:45:42 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org C539920645
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=suse.com
Authentication-Results: mail.kernel.org; spf=none smtp.mailfrom=linux-nfs-owner@vger.kernel.org
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1728443AbeLLWpl (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Wed, 12 Dec 2018 17:45:41 -0500
Received: from mx2.suse.de ([195.135.220.15]:55188 "EHLO mx1.suse.de"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1726297AbeLLWpl (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Wed, 12 Dec 2018 17:45:41 -0500
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
        by mx1.suse.de (Postfix) with ESMTP id 7F807ADED;
        Wed, 12 Dec 2018 22:45:39 +0000 (UTC)
From:   NeilBrown <neilb@suse.com>
To:     Ashish Sangwan <ashishsangwan2@gmail.com>,
        linux-nfs@vger.kernel.org
Date:   Thu, 13 Dec 2018 09:45:32 +1100
Subject: Re: Handling of duplicate inode numbers for the directories in the nfs v3 kernel client
In-Reply-To: <CAOiN93mX240ijc8mcX1OSKrQaP12At9t5c9cE3-T0gEuLC9RkA@mail.gmail.com>
References: <CAOiN93mX240ijc8mcX1OSKrQaP12At9t5c9cE3-T0gEuLC9RkA@mail.gmail.com>
Message-ID: <878t0uuzxv.fsf@notabene.neil.brown.name>
MIME-Version: 1.0
Content-Type: multipart/signed; boundary="=-=-=";
        micalg=pgp-sha256; protocol="application/pgp-signature"
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

--=-=-=
Content-Type: text/plain

On Thu, Dec 13 2018, Ashish Sangwan wrote:

> Hi,
>
> Our NFS filer can sometimes return same inode number for different directories.

Why?

> For example /mnt/dir1/dir2 and /mnt/dir3/dir4, in same rare cases dir2
> and dir4 might end up returning the same inode number to the client.
> Though it can never happen that inode numbers will be same for two
> directories and also there parent is same. Can linux client handle
> this case? What issues it can cause?

As long as the file handles are different, the Linux client won't really
notice.
Problems might occur with applications which check inode numbers.
I don't know of any that would be confused by directories having the
same inode number, but that doesn't mean there aren't any.

> https://lkml.org/lkml/2006/10/2/346

This is ancient!  It is mostly about the NFS server, not the client.
Filesystems that NFSd is exporting need to be careful to provide unique
file handles.

> I stumbled upon this thread where it is written that nfs client can
> handle this but userspace will see inode collisions. Given that this
> will happen only for directories, userspace utils logic might not get
> affected from this as hardlinks on directories are not possible. But
> the thread is really old. Wanted to confirm if this holds true even
> now.

I don't think anything important has changed.  The server must return
unquie filehandles.  It should return unique inode numbers.  User-space
may or may not get confused if it doesn't.

NeilBrown

--=-=-=
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----

iQIzBAEBCAAdFiEEG8Yp69OQ2HB7X0l6Oeye3VZigbkFAlwRj40ACgkQOeye3VZi
gbllZQ/+JHc0D/Mqf0N6NUlRBexPooiAtkDbdUF2qLAEvBQZtU3pteEyFTHm52S8
+mUmYOONKg75Ifjkc2D1q4GX4bXBEFxnM5KoefJskB9LWc6zCVZd+vJ4FjfR9u3w
RiBOUJ+q2J5UUMVZ11padYI9qptZ1XY6hwcRazQ3+9Xej5WgnobT9F8M4GUPOQNZ
VjB0kGQr/tiuMeKRGwGuxbf75m9Md6o4KXzbXaexkdnlg4y0nlC3XamfIZvcfxwM
RXQzodHG3ynk3EazfUa7tVAHiypSdRmko2qvSLQFt0dOCB9pkuY2TxKiJkfwdDCT
qLcnZztfc0wcbsZG+ykU4o4ZwpG9IVeWpMrW3b9QZ+Qx/pB4OaIysYxsqn7ROqTd
KD49VTx0SttKiKWB7gqfmUJrdam0jUPrKDf0IsHdq6YWlAXpIqxNLq61KYnNr14r
O4HakZHgCjFvDs9LpqwOkfQHEiCpQ5A6DWC85nTKb9ab1TRDXsR8+QyWYzOUqGqN
F51fPJje1LuObd1h0rzOPhap/b/9Fejb1ysBXix/wSdcLpBaJWtel9ZgMW9qPZ7Q
q77NG9gLz+IAcaCIiKVE+C5MshyBsaj0XGBx/oHApmuOW6Qd0DKPy0Ni/BWx3zXb
nHCvg+b79U77cKvs1bJ9I7X8lSp8YbEJJMIIgx5Ak+bycTYCF/Y=
=CsES
-----END PGP SIGNATURE-----
--=-=-=--

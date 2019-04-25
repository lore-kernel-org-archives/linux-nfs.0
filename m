Return-Path: <SRS0=LIrp=S3=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 47E30C43218
	for <linux-nfs@archiver.kernel.org>; Thu, 25 Apr 2019 23:20:20 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 6E08B20717
	for <linux-nfs@archiver.kernel.org>; Thu, 25 Apr 2019 23:20:20 +0000 (UTC)
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1728158AbfDYXUT (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Thu, 25 Apr 2019 19:20:19 -0400
Received: from mx2.suse.de ([195.135.220.15]:60208 "EHLO mx1.suse.de"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1727562AbfDYXUT (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Thu, 25 Apr 2019 19:20:19 -0400
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
        by mx1.suse.de (Postfix) with ESMTP id A53B3AF6E;
        Thu, 25 Apr 2019 23:20:16 +0000 (UTC)
From:   NeilBrown <neilb@suse.com>
To:     Andreas Dilger <adilger@dilger.ca>,
        "J. Bruce Fields" <bfields@redhat.com>
Date:   Fri, 26 Apr 2019 09:20:06 +1000
Cc:     linux-nfs <linux-nfs@vger.kernel.org>,
        linux-fsdevel <linux-fsdevel@vger.kernel.org>, abe@purdue.edu,
        lsof-l@lists.purdue.edu, util-linux@vger.kernel.org,
        Jeff Layton <jlayton@redhat.com>,
        James Simmons <uja.ornl@gmail.com>
Subject: Re: [PATCH 00/10] exposing knfsd opens to userspace
In-Reply-To: <B37B2837-E8C8-41EA-9A2D-3F8B93304FDD@dilger.ca>
References: <1556201060-7947-1-git-send-email-bfields@redhat.com> <B37B2837-E8C8-41EA-9A2D-3F8B93304FDD@dilger.ca>
Message-ID: <87lfzx65ax.fsf@notabene.neil.brown.name>
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

On Thu, Apr 25 2019, Andreas Dilger wrote:

> On Apr 25, 2019, at 4:04 PM, J. Bruce Fields <bfields@redhat.com> wrote:
>>=20
>> From: "J. Bruce Fields" <bfields@redhat.com>
>>=20
>> The following patches expose information about NFSv4 opens held by knfsd
>> on behalf of NFSv4 clients.  Those are currently invisible to userspace,
>> unlike locks (/proc/locks) and local proccesses' opens (/proc/<pid>/).
>>=20
>> The approach is to add a new directory /proc/fs/nfsd/clients/ with
>> subdirectories for each active NFSv4 client.  Each subdirectory has an
>> "info" file with some basic information to help identify the client and
>> an "opens" directory that lists the opens held by that client.
>>=20
>> I got it working by cobbling together some poorly-understood code I
>> found in libfs, rpc_pipefs and elsewhere.  If anyone wants to wade in
>> and tell me what I've got wrong, they're more than welcome, but at this
>> stage I'm more curious for feedback on the interface.
>
> Is this in procfs, sysfs, or a separate NFSD-specific filesystem?
> My understanding is that "complex" files are verboten in procfs and sysfs?
> We've been going through a lengthy process to move files out of procfs
> into sysfs and debugfs as a result (while trying to maintain some kind of
> compatibility in the user tools), but if it is possible to use a separate
> filesystem to hold all of the stats/parameters I'd much rather do that
> than use debugfs (which has become root-access-only in newer kernels).

/proc/fs/nfsd is the (standard) mount point for a separate NFSD-specific
filesystem, originally created to replace the nfsd-specific
systemcall.
So the nfsd developers have a fair degree of latitude as to what can go
in there.

But I *don't* think it is a good idea to follow this pattern.  Creating
a separate control filesystem for every different module that thinks it
has different needs doesn't scale well.  We could end up with dozens of
tiny filesystems that all need to be mounted at just the right place.  I
don't think that is healthy for Linus.

Nor do I think we should be stuffing stuff into debugfs that isn't
really for debugging.  That isn't healthy either.

If sysfs doesn't meet our needs, then we need to raise that in
appropriate fora and present a clear case and try to build consensus -
because if we see a problem, then it is likely that others do to.

This is all presumably in the context of Lustre and while lustre is
out-of-tree we don't have a lot of leverage.  So I wouldn't consider
pursuing anything here until we get back upstream.

NeilBrown

--=-=-=
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----

iQIzBAEBCAAdFiEEG8Yp69OQ2HB7X0l6Oeye3VZigbkFAlzCQKcACgkQOeye3VZi
gblmoRAAvxEWtmGXHnuYRl8pPrshc7vA/9rtQp0ee08p93/xlhQgxKzhRkJzLTFO
wj2dbz+GxWG+/PRIVoEtZaGWfPRGZJeH1VPUmPmaz1MmUNg3VbPUYsHUjgYLLl3+
kohgvjK81qalrwlqtmFLX6H2coRIuPDNLtC1E+wZEa2M1XL01sBOxa+9dJ6jYy1n
wGzoHeRAxDojmsmgCJysB6U7Ih4BtgXCA0P7M+sUcZ+DznG2ZVww4MdY1W6NMJbX
lR/VfXwdI2bpJLeZx3e6EFa5Jge52VBagKelmH/qfUbTyuYr80SL8Gmrw1YA1oOU
QlBy+EJ4pL6BZkxNdb3gfQpb3MFgBpavv4G8Eb6aNkbsv8sEEYBPHoteAqTzS8Bg
x2YJkW++sSwyIXq4mRoZrgfXqZj/rk0ncZ/84BqQeqdwe+FCsb9uCz75f4Nj6/TP
Ln2h8+fgXhci/fu+oYoW+OXwSgxnmSnsMnEIFd85OcrYcjSK7Ar/lKrM3/kXWnaf
U99IrlC6SmBvlQdiSyy8nivgds6xwLjBp3G8TGoYkUNd9HpqayvRHM/6p2RrzxxV
sDZkOdTeb73/7GX5AT/GaLPNbuJlp0n5U1WSz38wSRBSSD6dGPyJtHq/RlRcGHui
F+l0wdXVLFlCcrYXTfOrxva/Fa507NnHWyOWtLGDNnPGzf37a0Y=
=IBjP
-----END PGP SIGNATURE-----
--=-=-=--

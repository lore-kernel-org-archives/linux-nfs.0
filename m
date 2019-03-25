Return-Path: <SRS0=29O7=R4=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id EEC9CC43381
	for <linux-nfs@archiver.kernel.org>; Mon, 25 Mar 2019 23:01:03 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id BEA9620828
	for <linux-nfs@archiver.kernel.org>; Mon, 25 Mar 2019 23:01:03 +0000 (UTC)
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1729714AbfCYXBD (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Mon, 25 Mar 2019 19:01:03 -0400
Received: from mx2.suse.de ([195.135.220.15]:48906 "EHLO mx1.suse.de"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1726010AbfCYXBD (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Mon, 25 Mar 2019 19:01:03 -0400
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
        by mx1.suse.de (Postfix) with ESMTP id 2034AB16C;
        Mon, 25 Mar 2019 23:01:01 +0000 (UTC)
From:   NeilBrown <neilb@suse.com>
To:     "J. Bruce Fields" <bfields@fieldses.org>
Date:   Tue, 26 Mar 2019 10:00:54 +1100
Cc:     Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH] sunrpc/cache: handle missing listeners better.
In-Reply-To: <20190325222108.GB22644@fieldses.org>
References: <87pnqj64br.fsf@notabene.neil.brown.name> <20190322165338.GB7692@fieldses.org> <87bm225ymv.fsf@notabene.neil.brown.name> <20190325222108.GB22644@fieldses.org>
Message-ID: <87h8bq4l09.fsf@notabene.neil.brown.name>
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

On Mon, Mar 25 2019, J. Bruce Fields wrote:

> On Sat, Mar 23, 2019 at 09:32:08AM +1100, NeilBrown wrote:
>> On Fri, Mar 22 2019, J. Bruce Fields wrote:
>> > I've gotten complaints about the same thing and said "well, in
>> > retrospect we shouldn't have designed the interface this way, but we
>> > did, so just stop opening those files".
>>=20
>> As the fool who actually "designed" this,
>
> Pretty sure I was there too and had my chance to object.  In any case,
> hope you didn't take that as a personal complaint about your work, it
> (along with lots of maintenance since then) is much appreciated.

Not at all, I was just feeling in a self-deprecatory mood.

>
>> I can say with some confidence that the intention was always the
>> requests would block for at most 30 seconds.
> ...
>> > One advantage of waiting for mountd to come back is that you could
>> > upgrade mountd in place.  That shouldn't take 30 seconds, though.  And=
 I
>> > haven't heard of anyone actually doing that.
>>=20
>> Surely upgrading of mountd in-place happens whenever you install a new
>> version.
>
> I didn't think distros restarted mountd on upgrade, but I haven't
> actually checked that.  I agree that it's something we should allow,
> anyway.

I just had a look at the openSUSE nfs-kernel-server package.  It
declares

  %service_add_post nfs-mountd.service nfs-server.service

where %service_add_post is an rpm macro which does various things that I
struggle to understand, but it does reference a setting in
/etc/sysconfig/services, which contains

#
# Do you want to disable the automatic restart of services when
# a new version gets installed?
#
DISABLE_RESTART_ON_UPDATE=3D"no"

So I'm going to guess that openSUSE does restart mountd on upgrade.

>
>> > It's too bad that not opening auth.unix.gid is the only way for mountd
>> > to communicate that gids shouldn't be mapped.
>>=20
>> I have a general preference for reusing existing functionality rather
>> than creating new special-purpose functionality.  I think this has
>> served me well more often than not.  Maybe this is one case of "not".
>>=20
>> If you want to restart mountd without --managed-gids (where previously
>> it had that option), there is a chance that you will hit this problem.
>> That is a case where the answer "just stop opening those files" doesn't
>> really apply.
>
> Yeah.  OK, applying.
>
> (But I'm traveling and may not get this tested and pushed out till next
> week.)

No rush.  Safe travels.

Thanks,
NeilBrown


>
> --b.

--=-=-=
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----

iQIzBAEBCAAdFiEEG8Yp69OQ2HB7X0l6Oeye3VZigbkFAlyZXacACgkQOeye3VZi
gblGaQ/9Hqg6VIn8gkmMn/5j5zHVS50ra+8+BVYK9VI45ddv9UNEhj8JY8Wk3HoI
xtwmbejafzvdZopsk8gtd3aS2YfCUESFYoE2/TtVHyRuGq9nQUVs1Zzsevfr1B0M
u9MXJ78hr2GTtDE/MDo9RXz1EUdOrP1YHgb00Qd4r8Y2toMWOpwTOxHGfFJxHNDn
7tCifNv3PW7oXATUwzXCU3E99JUEaNXWwBonLwC4pLKNFCn4yOUguhdTMy6el7FC
96D1WfHwP8hYs2YZryWN+fPv/Is88aL87DIxiENBdktyxae8F064268QREpsObEr
i9Kc92nCzxnEc6sff1WJOWOno2GFZZYmey2yHdjn/na4DK4aZqaJWHyxevC4EFu7
dDTRGEgD1ii1RsBEqdy4F2veC2glyLXDz36YnEyQEefqASVn+mwI/nuqrqTL+arr
fxcXx1LWZRiFfcXtekGpPvuCjG1Ojjmhwv5k8O6L7/t3L0y0ZvVjPw5XeQXxP9yn
id6YFeCmwQ94N8txlZpKBmeqC4qWe535YjNCGy6oHU2w5WFCzJfqVVxHgD5W+pvI
tJRPixvHTcHk6JNiEi3hHkFLbgvX6sFEfQP+fTyFs+/fD4re0Ki8TTMPBbT5fy9U
0A5pcpols5KAKErzU6KFWhJ6sY1+q5n4glPQ30SITg3TGJxnoBs=
=fsdv
-----END PGP SIGNATURE-----
--=-=-=--

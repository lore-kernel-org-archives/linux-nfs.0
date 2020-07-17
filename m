Return-Path: <SRS0=EZRz=A4=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.0 required=3.0 tests=BAYES_00,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SPF_HELO_NONE,
	SPF_PASS autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id D02E1C433DF
	for <linux-nfs@archiver.kernel.org>; Fri, 17 Jul 2020 01:31:27 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [23.128.96.18])
	by mail.kernel.org (Postfix) with ESMTP id A7E0D207BC
	for <linux-nfs@archiver.kernel.org>; Fri, 17 Jul 2020 01:31:27 +0000 (UTC)
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1726238AbgGQBb0 (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Thu, 16 Jul 2020 21:31:26 -0400
Received: from mx2.suse.de ([195.135.220.15]:48598 "EHLO mx2.suse.de"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1726138AbgGQBb0 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Thu, 16 Jul 2020 21:31:26 -0400
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.221.27])
        by mx2.suse.de (Postfix) with ESMTP id 241B0AF73;
        Fri, 17 Jul 2020 01:31:29 +0000 (UTC)
From:   NeilBrown <neilb@suse.de>
To:     "J. Bruce Fields" <bfields@fieldses.org>
Date:   Fri, 17 Jul 2020 11:31:17 +1000
Cc:     Jeff Layton <jlayton@kernel.org>, linux-nfs@vger.kernel.org
Subject: Re: nfs4_show_superblock considered harmful :-)
In-Reply-To: <20200717010301.GC18568@fieldses.org>
References: <871rn38suc.fsf@notabene.neil.brown.name> <20200529220608.GA22758@fieldses.org> <87a71n7dek.fsf@notabene.neil.brown.name> <20200715185456.GE15543@fieldses.org> <20200716171958.GB18568@fieldses.org> <87tuy7vxeb.fsf@notabene.neil.brown.name> <20200717010301.GC18568@fieldses.org>
Message-ID: <87r1tbvsey.fsf@notabene.neil.brown.name>
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

On Thu, Jul 16 2020, J. Bruce Fields wrote:

> On Fri, Jul 17, 2020 at 09:43:40AM +1000, NeilBrown wrote:
>> On Thu, Jul 16 2020, J. Bruce Fields wrote:
>> > --- a/fs/nfsd/nfs4state.c
>> > +++ b/fs/nfsd/nfs4state.c
>> > @@ -507,6 +507,16 @@ find_any_file(struct nfs4_file *f)
>> >  	return ret;
>> >  }
>> >=20=20
>> > +static struct nfsd_file *find_deleg_file(struct nfs4_file *f)
>> > +{
>> > +	struct nfsd_file *ret;
>> > +
>> > +	spin_lock(&f->fi_lock);
>> > +	ret =3D nfsd_file_get(f->fi_deleg_file);
>>=20
>> A test on f->fi_deleg_file being non-NULL would make this look safer.
>> It would  also make the subsequent test on the return value appear sane.
>
> Yes, thanks!-b.
>
> diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
> index c2a2e56c896d..6e8811e7c134 100644
> --- a/fs/nfsd/nfs4state.c
> +++ b/fs/nfsd/nfs4state.c
> @@ -509,10 +509,11 @@ find_any_file(struct nfs4_file *f)
>=20=20
>  static struct nfsd_file *find_deleg_file(struct nfs4_file *f)
>  {
> -	struct nfsd_file *ret;
> +	struct nfsd_file *ret =3D NULL;
>=20=20
>  	spin_lock(&f->fi_lock);
> -	ret =3D nfsd_file_get(f->fi_deleg_file);
> +	if (f->fi_deleg_file)
> +		ret =3D nfsd_file_get(f->fi_deleg_file);
>  	spin_unlock(&f->fi_lock);
>  	return ret;
>  }

Reviewed-by: NeilBrown <neilb@suse.de>

for the whole patch.
Thanks,
NeilBrown

--=-=-=
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----

iQIzBAEBCAAdFiEEG8Yp69OQ2HB7X0l6Oeye3VZigbkFAl8Q/2UACgkQOeye3VZi
gbk8JRAAixYbaorls05aJDqYVwSKTysBTCJCPKEQFtEjRcmOuCQeVwgQWfonJxag
1Wp9irpv3BT+X2117rZqt47V9wBUFKCJPoPZlHNRevncWUgooq1oNDtC550HjSac
HQy9fMGNy3LCj4DgB9bLIFLIKKhRAkxxgzhc8ROzn3bbjQm11ie6gxPpXl7WBh9K
o3nzi96dsfP5tIE/qi1NcEG1qgRlQVdRslPZV9ZuGFGZ5kSez3dQvGZzBg2YHu9K
d1k/WZoxiH+mw/SG+pTELokYqRmRkHVtJlYQgpsCy9Fk9uMtEImWQNVWjHAQzHEK
cy6Rq3oMf4SaTZnBfa+c/Z+cfCoAlb41FMXpgv2SpKAC3wh18s/7kyrdhFfGN0Mh
8/1W7rH7SqxRDpDqsPx4AMn66KwR7o95rDZ03sa/aLuRYhK/Tw4BKHwj7yAZASgL
1l30Hc+WWqE5F1oEptas9wpKxZCOasZpgjqsXtwTdwnZwMbzi2Ft2+Go2RcSIJv4
WOQMY8D0h1F3pw/atY3mpZXotqcdeDG2pcWaOkP+nQnPYmwOqlV8yosa2fqNaqsS
1d8xztD0LMm7J2vng/iPsSyRoF4JDDxIhdyuxsGJx9sdprWdPF1uvFZNgNh+bg6u
xFtbQwoy99p19iCmWIageDwc/1FmHS8M2Hhku2k5AlG4nlWi/IE=
=Uzyt
-----END PGP SIGNATURE-----
--=-=-=--

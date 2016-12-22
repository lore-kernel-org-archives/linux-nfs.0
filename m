Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.suse.de ([195.135.220.15]:49839 "EHLO mx2.suse.de"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S941873AbcLVXRL (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Thu, 22 Dec 2016 18:17:11 -0500
From: NeilBrown <neilb@suse.com>
To: "J. Bruce Fields" <bfields@fieldses.org>
Date: Fri, 23 Dec 2016 10:16:57 +1100
Cc: Steve Dickson <SteveD@redhat.com>, linux-nfs@vger.kernel.org
Subject: Re: [PATCH 4/4] mountd: delay reading etab until first request arrives.
In-Reply-To: <20161222203501.GA31461@fieldses.org>
References: <148227940052.31345.1974080582264239934.stgit@noble> <148227955423.31345.17642862410755193193.stgit@noble> <20161222203501.GA31461@fieldses.org>
Message-ID: <87mvfnpn9y.fsf@notabene.neil.brown.name>
MIME-Version: 1.0
Content-Type: multipart/signed; boundary="=-=-=";
        micalg=pgp-sha256; protocol="application/pgp-signature"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

--=-=-=
Content-Type: text/plain
Content-Transfer-Encoding: quoted-printable

On Fri, Dec 23 2016, J. Bruce Fields wrote:

> On Wed, Dec 21, 2016 at 11:19:14AM +1100, NeilBrown wrote:
>> Reading etab may require hostname lookup, so it is not reliable
>> until the network is active.
>> But we want mountd to start before that so that it is ready
>> when the very first NFS request arrives.
>> So delay reading etab until that request arrives, by which time
>> the network must be online so hopefully hostname look will be reliable.
>>=20
>> An alternate would be to delay starting mountd and nfsd until the
>> network is on-line, but that will often be an unnecessary delay.
>
> One argument for that delay would be to get the grace period right: it's
> not really correct to start timing the grace period before you start
> accepting requests.
>
> In practice, with grace periods by default a minute and (I'm guessing)
> the delay here not even a few seconds, maybe it's a minor point.
>
> And in theory I guess knfsd could account for that by waiting to start
> the grace period timer until it receives its first rpc.

Interesting idea.  One would need to be careful about the case where
there are no clients wanting to recover state, so some timeout without
seeing any RPC would be needed.

It's times like this that I wish the grace period was a lot shorter, but
was auto-extended whenever a state-recovery request arrived (maybe with
some limit).  But that isn't what the spec say :-(

Thanks,
NeilBrown


>
> Anyway, that's not an objection to applying this patch.
>
> --b.
>
>>=20
>> Signed-off-by: NeilBrown <neilb@suse.com>
>> ---
>>  utils/mountd/mountd.c |    2 --
>>  1 file changed, 2 deletions(-)
>>=20
>> diff --git a/utils/mountd/mountd.c b/utils/mountd/mountd.c
>> index 5d9466f5c651..61699e62a6f0 100644
>> --- a/utils/mountd/mountd.c
>> +++ b/utils/mountd/mountd.c
>> @@ -852,8 +852,6 @@ main(int argc, char **argv)
>>  	sa.sa_handler =3D sig_hup;
>>  	sigaction(SIGHUP, &sa, NULL);
>>=20=20
>> -	auth_init();
>> -
>>  	if (!foreground) {
>>  		/* We first fork off a child. */
>>  		if ((c =3D fork()) > 0)
>>=20

--=-=-=
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----

iQIzBAEBCAAdFiEEG8Yp69OQ2HB7X0l6Oeye3VZigbkFAlhcXukACgkQOeye3VZi
gbnl1Q//dXmWAQvw9A+6gJQlt71+DGnQJva2BLY3luOLapn3JLwnqpPp/BTHJqkb
jgRJFOdaQKz+TeZlhnfNFR0kvGMqrYpNWETU0qyPoy2Eyg1BAS9GP1IEJ1gO0hxK
kVIMgY9rkQmIGKsJvgCMyHdEvpqqW58HktaQ5/eYsk5fKuZ8JuEBnTKuu1+fQL6v
VJ+2qKn48ktaHghGGe29Qg6HDmoZA3+KEkf4h3s068mjnbg6w2j+eGAw6stRKbJX
+z6aAreUnMQ1wsmNwQxOwk4UBdx9K3kasfdAEaiwlfaBGyklfT/n8dXqbH1hLmf7
hRmINQU9e/NmNNwKLf4ObN/3cjwjy4m/Rq/pYx1o1rxLv2E/aK4/QFedzo9sgU+l
b7cmtoRNguOVca+5zTVPFYZ2N7B9msz2TbRckqW//bi9Cb8JmyaFeujDDoD3vCBl
EPqBK/nOqi40TWX4+3k6+4LxhCBJC15LbjGN6q1b9mkzrsDVxJhnS28ry3D7bQS8
0k+LR/nsJIuV20f/BDgNQwhMUQl6sc3GUAEvQiopGgUSfR46aeAN3KZbng6eCjbx
A2S6dV7yv+cIefot4zdhup/cKryL2/b+InMlakZ6cmH+Q2zpVhKyNvqqj4NpgqMQ
0XQ7dOrt1YCKZ28F4e2bOCLqwfi+8hhCsYc39Di63VV/Oise0w4=
=dxA7
-----END PGP SIGNATURE-----
--=-=-=--

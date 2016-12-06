Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.suse.de ([195.135.220.15]:41422 "EHLO mx2.suse.de"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752492AbcLFWiy (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Tue, 6 Dec 2016 17:38:54 -0500
From: NeilBrown <neilb@suse.com>
To: Steve Dickson <SteveD@redhat.com>,
        "J. Bruce Fields" <bfields@redhat.com>
Date: Wed, 07 Dec 2016 09:38:45 +1100
Cc: linux-nfs@vger.kernel.org
Subject: Re: [RFC PATCH 00/15] Enhance /etc/nfs.conf usage and remove nfs-config.service
In-Reply-To: <748c0cb1-cc3b-362a-3c97-46917dd7dabc@RedHat.com>
References: <148065078775.28046.5506130555300891075.stgit@noble> <748c0cb1-cc3b-362a-3c97-46917dd7dabc@RedHat.com>
Message-ID: <87oa0o4r9m.fsf@notabene.neil.brown.name>
MIME-Version: 1.0
Content-Type: multipart/signed; boundary="=-=-=";
        micalg=pgp-sha256; protocol="application/pgp-signature"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

--=-=-=
Content-Type: text/plain
Content-Transfer-Encoding: quoted-printable

On Wed, Dec 07 2016, Steve Dickson wrote:

> On 12/01/2016 10:58 PM, NeilBrown wrote:
>> This is an RFC series.  A little voice at the back of my head keeps
>> telling me that I'm over-engineering, but there isn't really that much
>> new code, and I think the result has a lot to recommend it.
>>=20
>> But please tell me if I'm wrong.
>>=20
>> - Various daemons (not all) are enhance to accept configuration
>>   information from /etc/nfs.conf
>> - the conffile reader is enhanced to support include files, and
>>   particularly to be able to include /etc/sysconf/X or /etc/defaults/X
>>   files usefully
>> - nfs-config.service is removed, because it isn't really needed with
>>   the above.
>> - documentation for all the above is provided, including a new
>>   nfs.systemd man page which gives the bigger picture.
> This is some nice work! Its definitely a step in the right=20
> direction... IMHO... I especially like the idea of the include
> statement, I'm very curious to see how that work!=20
>
> If this is finished, I'll start testing and hopefully=20
> get it in... soon.

I would be happy for this to go in as-is.  There are certainly some
changes needed (port, debug, host, etc) but they can be additions.
I people are happy with the overall approach, then let's do it.

Thanks,
NeilBrown

--=-=-=
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----

iQIzBAEBCAAdFiEEG8Yp69OQ2HB7X0l6Oeye3VZigbkFAlhHPfYACgkQOeye3VZi
gbkz1BAAn684VVPsZhVrvpSo6L+krrj+xV8QglD/WRql01dsk12VEcWl+UiiD4jc
/w1v07EbFXNcbUlrN+rUl+77WuNrpQTM4HQSEe4bu2Ind0Br6w/5Qp5V/nYzOoNk
u7e3toi+c4FILX3xRpbwZptwoyG0YrdVi0UZFPjRkh9NYO362yZxHcdZ1nfFhFsF
tzSA/VyGRu6mehtzJ3qmuhXm9d+HznqxSrSb+D/JsDZJKl33udwlbU2UdscoCv4v
XQyr9ONUPUy8f68Pug/Pwq732E1uUdZ49jDRcIbwepVmmpnUWGD3uUfpVBsII02f
Em0JnS5tTbLhv2vHZ0xzBsDlUIh2m4CHrMp+vgiVwuxQZJVBsOYGFnlzirbwSADT
k0Xa+rhL7WhE/0JNuUibSKrU0TQZSoav/vyJ/Gstb2AQtQJtcKyZhHjpJ7mnrLN8
7s3SzvCRV0sZMloA2kF2DEYs2aqu0Q7Sgtd4fVH3ElVe8FEI18ZMX8LOjESWR/tM
d3961uQmwYNMTxqp7lIXHfcxP3Q0Exfl5N0rW2x0obtn7G2FkYjnGOuCZjcQ0pEr
gdQlSK2zrvePXQHThNbIPeFUNdmVE7gQ5Ty8yXa3rTrFNGcHC7rQe2RdLR1DHEi2
5Jtk522wkklQgE8GOvj99UTpMs61opPPg160BKEh4V1ulxp/OCo=
=Ga7P
-----END PGP SIGNATURE-----
--=-=-=--

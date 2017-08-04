Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.suse.de ([195.135.220.15]:39477 "EHLO mx1.suse.de"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1751845AbdHDDZp (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Thu, 3 Aug 2017 23:25:45 -0400
From: NeilBrown <neilb@suse.com>
To: Matt Benjamin <mbenjami@redhat.com>
Date: Fri, 04 Aug 2017 13:25:33 +1000
Cc: Stefan Hajnoczi <stefanha@redhat.com>,
        Chuck Lever <chuck.lever@oracle.com>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>,
        Jeff Layton <jlayton@redhat.com>,
        Abbas Naderi <abiusx@google.com>,
        Steve Dickson <steved@redhat.com>
Subject: Re: [PATCH nfs-utils v2 05/12] getport: recognize "vsock" netid
In-Reply-To: <CAKOnarmMT2FRF8U84tQDZnm-GMeZrEU2UXZHmNXUeqTHpMYo9w@mail.gmail.com>
References: <20170630132120.31578-1-stefanha@redhat.com> <20170630132120.31578-6-stefanha@redhat.com> <952499A1-FBBA-4FD8-97A6-B0014FA5065D@oracle.com> <87wp7lvst9.fsf@notabene.neil.brown.name> <87tw2ox4st.fsf@notabene.neil.brown.name> <20170725100513.GA5073@stefanha-x1.localdomain> <87eft2wjfy.fsf@notabene.neil.brown.name> <20170727105835.GF10129@stefanha-x1.localdomain> <8760edwk4l.fsf@notabene.neil.brown.name> <20170803152446.GA24890@stefanha-x1.localdomain> <87tw1otjf1.fsf@notabene.neil.brown.name> <CAKOnarmMT2FRF8U84tQDZnm-GMeZrEU2UXZHmNXUeqTHpMYo9w@mail.gmail.com>
Message-ID: <87r2wst3o2.fsf@notabene.neil.brown.name>
MIME-Version: 1.0
Content-Type: multipart/signed; boundary="=-=-=";
        micalg=pgp-sha256; protocol="application/pgp-signature"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

--=-=-=
Content-Type: text/plain

On Thu, Aug 03 2017, Matt Benjamin wrote:

> Hi Neil,
>
> On Thu, Aug 3, 2017 at 5:45 PM, NeilBrown <neilb@suse.com> wrote:
>> On Thu, Aug 03 2017, Stefan Hajnoczi wrote:
>
> Since the vsock address family is in the tin since 4.8, this argument
> appears to be about, precisely, tying existing pieces together.

No, it is about adding new, unnecessary pieces into various places.

>                                                                  The
> ceph developers working on openstack manila did find the nfs over
> vsock use case compelling.  I appreciate this because it has
> encouraged more interest in the cephfs community around using the
> standardized NFS protocol for deployment.

I'm sure the ceph developers find zero-conf NFS a compelling use case.
I would be surprised if they care whether it is over vsock or IPv6.

But I'm losing interest here.  I'm not a gate-keeper.  If you can
convince Steve/Trond/Anna/Brice to accept your code, then good luck to
you.  I don't think a convincing case has been made though.

NeilBrown


>
> Matt
>
>>
>> I think we all agree that providing something that "just works" is a
>> worth goal.  In only question is about how much new code can be
>> justified, and where it should be put.
>>
>> Given that almost everything you need already exists, it seems best to
>> just tie those pieces together.
>>
>> NeilBrown
>>
>>
>>>
>>> The changes required to Linux and nfs-utils are related to the sunrpc
>>> transport and configuration.  They do not introduce risks to core NFS or
>>> TCP/IP.  I would really like to get patches merged because I currently
>>> have to direct interested users to building Linux and nfs-utils from
>>> source to try this out.
>>>
>>> Stefan

--=-=-=
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----

iQIzBAEBCAAdFiEEG8Yp69OQ2HB7X0l6Oeye3VZigbkFAlmD6S8ACgkQOeye3VZi
gblQ/xAAn+EdHkxJAuuvam5nLquE1cyI30lzH10/2JU6lutB8X/50KTUuVL+RdtD
Nc0PYe+kiABr2hIuU//Fp7ndRs7H0ULpit5eSH1I6jmHNlTf7mgGyKJlEkKd3lCZ
Lfk8H/xZhJ95bKxIWj9eOQrkMecEtamTBOcIr1iRybzacGKer3oGVIEl1B3xtgax
kgVkp5qJhUYTu1SlpPrYcxo+6R4UYXHmqADOdhVQQlZ9ys2ltbt5PenFxe7fuRHD
TG3h1IWr/hzdmY/reJSDiJrCYV+dIQ/5ikS0u3/4LD+OWtfxrrnhLM/tgA9Ggb3g
LqqhQY+0TpmP+02vtkW4Zf1fjSioBHxGG33HoGPLuzKwACLSfdQ+L8D7S5EsvLwU
M095qOYFhZxlGj3i7hKkeW34hVv/bOfa/oUdrkDZjZfnUsEhLzSphyE/Gx44ccdX
5I6/LU4R2feSdLkVJYHNkkcKUmcO37Rp7kT4YDag5HCOBns0CbLxChDyRDkZ/QUS
OHk23LX+UmhYvO6hbL2ZHkCmF47DpbODI7S6l7LodTURJ/0KdsMea71eCHYI4JMD
fOPQ2Zb70RFdKrAery9lDOWVpFe5B69U0wwdrVxQ5n3KVt+DRHamd4axaYGDt5BF
d8Rg7PEBScWkyTscG0Szq/8g1UgU8vNlXMVeYIOSsVx968kTFNI=
=gvpT
-----END PGP SIGNATURE-----
--=-=-=--

Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.suse.de ([195.135.220.15]:53602 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932903AbcDSVYc (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 19 Apr 2016 17:24:32 -0400
From: NeilBrown <neilb@suse.com>
To: "J. Bruce Fields" <bfields@fieldses.org>
Date: Wed, 20 Apr 2016 07:24:24 +1000
Cc: linux-nfs@vger.kernel.org
Subject: Re: AUTH_NONE at top of SECINFO_NONAME reply.
In-Reply-To: <20160418182633.GA3193@fieldses.org>
References: <87k2k1jd8d.fsf@notabene.neil.brown.name> <20160418182633.GA3193@fieldses.org>
Message-ID: <871t61i96f.fsf@notabene.neil.brown.name>
MIME-Version: 1.0
Content-Type: multipart/signed; boundary="=-=-=";
	micalg=pgp-sha256; protocol="application/pgp-signature"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

--=-=-=
Content-Type: text/plain
Content-Transfer-Encoding: quoted-printable

On Tue, Apr 19 2016, J. Bruce Fields wrote:

> On Thu, Apr 14, 2016 at 09:33:22AM +1000, NeilBrown wrote:
>>  I have an NFSv4.1 server (Netapp, don't know about version numbers)
>>  which responds to
>>     PUT_ROOTFH
>>     SECINFO_NONAME
>>=20
>> with:
>>=20
>> flavor: AUTH_NULL (0)
>> flavor: RPCSEC_GSS (6)
>>     service: rpcsec_gss_svc_integrity (2)
>> flavor: RPCSEC_GSS (6)
>>     service: rpcsec_gss_svc_none (1)
>> flavor: AUTH_UNIX (1)
>>=20
>> This causes the Linux client to use AUTH_NULL, which doesn't end well
>>    Opcode: ACCESS (3), [Access Denied: RD LU MD XT DL]
>>=20
>> I suspect this is a server bug, because the first flavor is meant to be
>> the most preferred.  However I wonder if there might be something else
>> going on.
>>=20
>> 1/ I note that for NFSv3 AUTH_NULL means something a bit different
>>   in this context:
>>=20
>> 	 * AUTH_NULL has a special meaning when it's in the server list - it
>> 	 * means that the server will ignore the rpc creds, so any flavor
>> 	 * can be used.
>>=20
>>   Is there any chance that servers might reasonably expect that
>>   behavior for NFSv4.1 as well??
>
> I'll admit it seems a trap for the unwary implementor, but I think this
> case is really clear:
>
> 	http://tools.ietf.org/html/rfc5661#section-18.29.3
>
> 	The result will contain an array that represents the security
> 	mechanisms available, with an order corresponding to the
> 	server's preferences, the most preferred being first in the
> 	array.  The client is free to pick whatever security mechanism
> 	it both desires and supports, or to pick in the server's
> 	preference order the first one it supports.
>
> So we should be leaning on the server vendor to fix and/or explain
> what's going on there.

That was the direction I was leaning, but it is nice to have it
confirmed - particularly given the interesting rules with NFSv3.

My colleague subsequently discovered that there were setting on the
Netapp which could change the behavior.   He fiddled things and the
problem went away, but he noted:

	On the netapp side, I have three of these settings: rorule,rwrule,superuse=
r, and for
	each of these I can set
	from the list: "any   none  krb5  krb5i ntlm  sys". So with
	"ro=3Dsys,rw=3Dnone,superuser=3Dany" I'm still in the
	situation where I can get the AUTH_NULL first ...

("AUTH_NULL first" being the problematic situation).
I wonder if "none" means "no authentication needed" or "no access
given".

Still seems strange behavior for the server, but as it can be avoided it
probably isn't worth any more consideration.

Thanks a lot,

NeilBrown

--=-=-=
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQIcBAEBCAAGBQJXFqIIAAoJEDnsnt1WYoG5Xg0QAL6fBOYwvmoodQ4/9NDmVFGX
W15DfIX0Qd/7qcH3vuCPPeqN8VRQHW7dHZUF//F3EwNKami20xyz6u9TUl/txrV6
13LYrZxa6TyqVRQS8yeBWkL5VwEi87Vbj+7ttK8BKTcrk5wXWRD9daUn/ecLO19L
0qXHDOCX0+4aO0OuRyNyR0lC4TpTYNe3Qbvq78NRQsInYd0q6M51195a2H9pjzzW
BFhYwE2YOso37MZkHMRI2VN+bLYdT0zrPGv4+cjT6JqJ50Djj1SwMXzZKtKPUczZ
lL7Xqqo/WWXFj+osZnQ2kzT9jBv97b6wJl5oIX4AI6GN8fyBRxIaJ4l8pAFAgtHw
LUO6A3iSQ1MdYaHXsKQO3lrh39yRNdPMaPXOhfIU0kcBB4vjFavjP3li0z4ulZlZ
EpEryDRCfZOMtWnOTFWhTztYq7XKNTTO0dyzaTVOBk3jIK68z39QeXzoaYtWTK43
GetFD0XrkeGpcLdlHL7g6DUIIgpUu0IvBfDl5um4Pblvj2XOzhWdNkRx9GO7UF4H
MYUaOi9nRMJFrfbPc+eEIlTpRNLkhc5tZ6Wcqh9w9UaspL5ymlcEnmorjrJZVrk0
gZMkrLBstpGKlSxrMyxUgYfR0ykKZpvJSMbhQM7hXGJFLDPnZ/4bF/MMz4naod95
oOwfxAHyHCimyo9OjioE
=14XA
-----END PGP SIGNATURE-----
--=-=-=--

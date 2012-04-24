Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx2.netapp.com ([216.240.18.37]:10041 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755770Ab2DXQSO (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 24 Apr 2012 12:18:14 -0400
From: "Adamson, Dros" <Weston.Adamson@netapp.com>
To: "Myklebust, Trond" <Trond.Myklebust@netapp.com>
CC: "Adamson, Dros" <Weston.Adamson@netapp.com>,
        "chuck.lever@oracle.com" <chuck.lever@oracle.com>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH] nfs4: fix referrals on mounts that use IPv6 addrs
Date: Tue, 24 Apr 2012 16:17:57 +0000
Message-ID: <E3473B22-0223-452B-AA8E-3A6E613F4D43@netapp.com>
References: <1335279471-46782-1-git-send-email-dros@netapp.com>
 <1335281584.3792.30.camel@lade.trondhjem.org>
In-Reply-To: <1335281584.3792.30.camel@lade.trondhjem.org>
Content-Type: multipart/signed;
	boundary="Apple-Mail=_801FFC00-1A04-4562-B37A-FF5DF023DD42";
	protocol="application/pkcs7-signature"; micalg=sha1
MIME-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

--Apple-Mail=_801FFC00-1A04-4562-B37A-FF5DF023DD42
Content-Transfer-Encoding: quoted-printable
Content-Type: text/plain;
	charset=us-ascii


On Apr 24, 2012, at 11:33 AM, Myklebust, Trond wrote:

> On Tue, 2012-04-24 at 10:57 -0400, Weston Andros Adamson wrote:
>> All referrals (IPv4 addr, IPv6 addr, and DNS) are broken on mounts of
>> IPv6 addresses, because validation code uses a path that is parsed
>> from the dev_name ("<server>:<path>") by splitting on the first colon =
and
>> colons are used in IPv6 addrs.
>> This patch ignores colons within IPv6 addresses that are escaped by =
'[' and ']'.
>>=20
>> Signed-off-by: Weston Andros Adamson <dros@netapp.com>
>> ---
>>=20
>> This depends on commit 2f8e4bd91488f286e83e8abb14683102efaafb05
>> "nfs: Enclose hostname in brackets when needed in nfs_do_root_mount".
>>=20
>> fs/nfs/nfs4namespace.c |   35 ++++++++++++++++++++++++++++++++---
>> 1 files changed, 32 insertions(+), 3 deletions(-)
>>=20
>> diff --git a/fs/nfs/nfs4namespace.c b/fs/nfs/nfs4namespace.c
>> index 9c8eca3..307743d 100644
>> --- a/fs/nfs/nfs4namespace.c
>> +++ b/fs/nfs/nfs4namespace.c
>> @@ -52,6 +52,35 @@ Elong:
>> }
>>=20
>> /*
>> + * parse the path component of an nfs path ("<server>:<path>").
>> + *  nfspath - the "<server>:<path>" string
>> + *  end - pointer to end of devname component of 'nfspath'
>> + * returns NULL on failure
>> + */
>> +static inline char *nfs_parse_path_component(char *nfspath, char =
*end)
>=20
> Nit: this is really parsing the server name component of the devname.
>=20
> Also, please make the 'end' argument 'const char *', and  drop the
> 'inline' declaration.

OK.

>=20
>> +{
>> +	bool ipv6_esc =3D false;
>> +	char *p;
>> +
>> +	/* find first colon not in IPv6 addr */
>> +	for (p =3D nfspath; p < end && *p; p++) {
>> +		switch (*p) {
>> +		case '[':
>> +			ipv6_esc =3D true;
>=20
> Note that if p !=3D nfspath, then we have a problem. The '[' _must_ be =
the
> first character in the server name, and there _must_ be a matching ']'
> at the end.
> So how about optimising this using something along the lines of:
>=20
> 	p =3D nfspath;
> 	/* Handle escaped hostnames */
> 	if (*p =3D=3D '[') {
> 		p =3D strchr(p, ']');
> 		if (p =3D=3D NULL)
> 			return NULL;
> 	}
> 	p =3D strchr(p, ':');
> 	if (p !=3D NULL)
> 		p++;
> 	return p;

OK, I'll change it to be more strict.  Note that your suggestion doesn't =
enforce that the matching ']' is at the end of the hostname (next char =
':').

>> +			break;
>> +		case ':':
>> +			if (!ipv6_esc)
>> +				return (p + 1);
>> +			break;
>> +		}
>> +	}
>> +	return NULL;
>> +}
>> +
>> +/*
>>  * Determine the mount path as a string
>>  */
>> static char *nfs4_path(struct dentry *dentry, char *buffer, ssize_t =
buflen)
>> @@ -59,9 +88,9 @@ static char *nfs4_path(struct dentry *dentry, char =
*buffer, ssize_t buflen)
>> 	char *limit;
>> 	char *path =3D nfs_path(&limit, dentry, buffer, buflen);
>> 	if (!IS_ERR(path)) {
>> -		char *colon =3D strchr(path, ':');
>> -		if (colon && colon < limit)
>> -			path =3D colon + 1;
>> +		char *path_component =3D nfs_parse_path_component(path, =
limit);
>> +		if (path_component)
>> +			return path_component;
>> 	}
>> 	return path;
>> }
>=20
> So this fixes the problem of parsing the devname, but how about the
> issue of setting the correct devname if the server supplies an IPv6
> address as the hostname?

That is covered by the patch you sent me (commit =
2f8e4bd91488f286e83e8abb14683102efaafb05).  I thought you'd just use =
that patch - it's what I tested with.

-dros=

--Apple-Mail=_801FFC00-1A04-4562-B37A-FF5DF023DD42
Content-Disposition: attachment; filename="smime.p7s"
Content-Type: application/pkcs7-signature; name="smime.p7s"
Content-Transfer-Encoding: base64

MIAGCSqGSIb3DQEHAqCAMIACAQExCzAJBgUrDgMCGgUAMIAGCSqGSIb3DQEHAQAAoIIDTzCCA0sw
ggIzoAMCAQICAQEwCwYJKoZIhvcNAQEFMEYxFzAVBgNVBAMMDldlc3RvbiBBZGFtc29uMQswCQYD
VQQGEwJVUzEeMBwGCSqGSIb3DQEJARYPZHJvc0BuZXRhcHAuY29tMB4XDTExMDYwODIyMDc0NloX
DTEyMDYwNzIyMDc0NlowRjEXMBUGA1UEAwwOV2VzdG9uIEFkYW1zb24xCzAJBgNVBAYTAlVTMR4w
HAYJKoZIhvcNAQkBFg9kcm9zQG5ldGFwcC5jb20wggEiMA0GCSqGSIb3DQEBAQUAA4IBDwAwggEK
AoIBAQC8/tJxtovJEXYRfSsrFOWKHxIZGY7/2mBee1DpWuoGDbVNapefCC7WXe+Nqxz609w2J/Mk
/k3trZ3Ge2NXK0tGnP9NzjkzpGA7rSpM3wUFsvbLMUEGfQpvV24/nYvcLHTvOOEUaDPpHduN94bD
dwvyowzDIRIpF2MeRnOzBNeHkrGHlZdzPmGjm8tkhrDRRkDYHhlxaiG4z30KCfAazxomuINiy1kj
vbndXooYMDoh9H63hgW4NkOedtLdflLa322DXQ3nFU7YbyOIjHVl1tgWJLDWf7WT3lsAB8KvuJZ5
zhsUB+fqxCKPJVRPDO1gjChvvtGiG1tGUUZz0H9Wx00zAgMBAAGjRjBEMA4GA1UdDwEB/wQEAwIH
gDAWBgNVHSUBAf8EDDAKBggrBgEFBQcDBDAaBgNVHREEEzARgQ9kcm9zQG5ldGFwcC5jb20wDQYJ
KoZIhvcNAQEFBQADggEBACv0niZSmW+psB1sJXULh3mecDbN2mj0bFpN1YNdjcV7BiOLJ1Rs1ibV
f13h73z8C7SBsPXTM5si8gmJtOnXM5jsgtlql44h/RrjUr8+mtK5DPCZls9J7iz3cGthzwOPvxUj
nMSv3BpRX5oJom5ESgCM9Nn4u/ECTlLMhEIOYnBFiN0eDxcxz+r1cpbHg3r0otIKyxLpeaCjP6AH
F93EHp4T8Rb63y3CcDgxrQGHlTdVi3QvxaMUexUXD81fiA+UqsB/MKmRxB1Hs4Vf3Q/+ejcm78K1
ROF8TNPmNWRlKg3Y7cSFjZGzLuzXsvSsCbw4HLn0oZe/OfgSbarTAxttL5IxggHRMIIBzQIBATBL
MEYxFzAVBgNVBAMMDldlc3RvbiBBZGFtc29uMQswCQYDVQQGEwJVUzEeMBwGCSqGSIb3DQEJARYP
ZHJvc0BuZXRhcHAuY29tAgEBMAkGBSsOAwIaBQCgXTAYBgkqhkiG9w0BCQMxCwYJKoZIhvcNAQcB
MBwGCSqGSIb3DQEJBTEPFw0xMjA0MjQxNjE3NTdaMCMGCSqGSIb3DQEJBDEWBBR9G5qaCzCmG5cM
mtWkVaTUQltwCjANBgkqhkiG9w0BAQEFAASCAQCPpd91P7gt64Y+EnryYcYmKjm2DZMa/JDYAt26
KUSsOwWguhRYLnL7HNQ11Q3yWPRDF0TCl7OlKOjirwjYs91Nzs57MMXx2QoqoGrjw4ZB4XyqrCu1
m/qp9IGX0LGTMPrzngdqMJyxdreVzlN9oyY+TsAX7dUaajsRDaAbOadW+wgBqP/Iq5749RKTjyU5
kSu8q9/pqUcaiEHgDnkgQP1F4xVcYgf71nOP9moY4BHIAkKc/F/ct2X7weThIam43Dn4lauMCSF9
12i7KVUIBeYEz+hrqBqnvxg3oYr4XQHnD0eng8Q0bVvxyV6VbmfnyfINn6UEG7eNKKiBNlT8N+Z4
AAAAAAAA

--Apple-Mail=_801FFC00-1A04-4562-B37A-FF5DF023DD42--

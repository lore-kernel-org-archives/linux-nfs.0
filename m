Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx2.netapp.com ([216.240.18.37]:36589 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755049Ab2DTVbe (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 20 Apr 2012 17:31:34 -0400
From: "Adamson, Dros" <Weston.Adamson@netapp.com>
To: "Adamson, Dros" <Weston.Adamson@netapp.com>
CC: Chuck Lever <chuck.lever@oracle.com>,
        "Myklebust, Trond" <Trond.Myklebust@netapp.com>,
        "<linux-nfs@vger.kernel.org>" <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH] NFS4: fix referrals with IPv6 mounts
Date: Fri, 20 Apr 2012 21:31:33 +0000
Message-ID: <41440F4B-99AC-48AC-A1F8-C9A3DED9E76E@netapp.com>
References: <1334949705-33393-1-git-send-email-dros@netapp.com>
 <B1E9AAB3-6739-46D5-999A-130494131031@oracle.com>
 <79682769-1052-4392-A63D-F686A81C2BBE@netapp.com>
In-Reply-To: <79682769-1052-4392-A63D-F686A81C2BBE@netapp.com>
Content-Type: multipart/signed;
	boundary="Apple-Mail=_75C6B499-A385-4B08-88B2-25A512E40D40";
	protocol="application/pkcs7-signature"; micalg=sha1
MIME-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

--Apple-Mail=_75C6B499-A385-4B08-88B2-25A512E40D40
Content-Transfer-Encoding: quoted-printable
Content-Type: text/plain;
	charset=us-ascii

On Apr 20, 2012, at 5:25 PM, Adamson, Dros wrote:

> On Apr 20, 2012, at 3:30 PM, Chuck Lever wrote:
>=20
>>=20
>> On Apr 20, 2012, at 3:21 PM, Weston Andros Adamson wrote:
>>=20
>>> nfs4_path() was parsing the path component by splitting on the first =
colon.
>>> This is wrong when an IPv6 address is used to mount a server.
>>>=20
>>> For example, having mounted 'fc00::10:/export', nfs4_path() returned
>>> ':10:/export'.  This causes referrals (using IPv4 or IPv6 addresses) =
to fail
>>> in nfs4_validate_fspath().
>>>=20
>>> Parsing the path component by using the *last* colon works with
>>> IPv6 as well as IPv4 addrs.
>>=20
>> These ad hoc fixes give me the willies.
>>=20
>> During a referral, how is the server name and export path getting =
recombined?  In fs_locations data, these are separate.  In the forward =
mount path, IPv6 addresses are escaped via square brackets.
>=20
> Again, the string that needs to be split into (server, path) is not =
the fs_locations side -- those are already separated.  What's not =
separated is the result of nfs_path().
>=20
>> (Having not looked at this code in years), is there some way we can =
keep the server name and path separate here so we don't have to reparse?
>=20
> nfs_path() walks up the dentry tree until it hits the root dentry of =
the nfs mount, then it uses dentry.d_fsdata to get the "dev_name" of the =
mountpoint (<server>:<path>) to make <server>:<rootpath + path to the =
dentry>.
>=20
> The problem I'm having is how we can generate the string "<rootpath of =
parent mount>/<path-to-current-dentry>" without adding [] escaping to =
dev_name, or adding another variable to dentry (not likely!).
>=20

To be clear: the problem is *not* with IPv6 addrs in FS_LOCATIONS attrs. =
 They work if the parent mount is IPv4/dns.  The problem is when the =
parent mount is IPv6 *no* referrals work (IPv4, IPv6 or DNS), because of =
the issue described above.

> -dros
>=20
>>=20
>>> Signed-off-by: Weston Andros Adamson <dros@netapp.com>
>>> ---
>>> fs/nfs/nfs4namespace.c |    2 +-
>>> 1 files changed, 1 insertions(+), 1 deletions(-)
>>>=20
>>> diff --git a/fs/nfs/nfs4namespace.c b/fs/nfs/nfs4namespace.c
>>> index 9c8eca3..dd3dd30 100644
>>> --- a/fs/nfs/nfs4namespace.c
>>> +++ b/fs/nfs/nfs4namespace.c
>>> @@ -59,7 +59,7 @@ static char *nfs4_path(struct dentry *dentry, char =
*buffer, ssize_t buflen)
>>> 	char *limit;
>>> 	char *path =3D nfs_path(&limit, dentry, buffer, buflen);
>>> 	if (!IS_ERR(path)) {
>>> -		char *colon =3D strchr(path, ':');
>>> +		char *colon =3D strrchr(path, ':');
>>> 		if (colon && colon < limit)
>>> 			path =3D colon + 1;
>>> 	}
>>> --=20
>>> 1.7.4.4
>>>=20
>>> --
>>> To unsubscribe from this list: send the line "unsubscribe linux-nfs" =
in
>>> the body of a message to majordomo@vger.kernel.org
>>> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>=20


--Apple-Mail=_75C6B499-A385-4B08-88B2-25A512E40D40
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
MBwGCSqGSIb3DQEJBTEPFw0xMjA0MjAyMTMxMzNaMCMGCSqGSIb3DQEJBDEWBBSbwQ7NjQlkqzzH
C8JlNxDSBJ0/yjANBgkqhkiG9w0BAQEFAASCAQCxGFZ/BROX58tpHd1K87lmEC2m/EMOT3yPpe2v
nqMSPMA1YpnIyuqR8MpcOxjiiiBLdPwsE6cG2p5Q1OgUH/V2ocfjOsIted1Bm6Hs+NNB8nuAJisp
U7o8h/kiogJvOXkpbABOdaj+6eF8qoXVSN86q8DezG+nHErXXnzz1vTFoSqIBuz5/Pg7B9TsBCyA
DKCfEg/Ca5MebGeszxIhEgGu7PWH2yvmCuBcqoQbXDo5OXcu/A48b5FDL5YD4aA6MVLDhUFxaRu8
8e29faZcRUAgIZIhKklq8Wh4cjpEVj81baqowI5JjIlbxQfsYyrWBtHjDFWiof3nCoPEvNpBiRs7
AAAAAAAA

--Apple-Mail=_75C6B499-A385-4B08-88B2-25A512E40D40--

Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx2.netapp.com ([216.240.18.37]:33092 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753229Ab2DTVif (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 20 Apr 2012 17:38:35 -0400
From: "Adamson, Dros" <Weston.Adamson@netapp.com>
To: "Myklebust, Trond" <Trond.Myklebust@netapp.com>
CC: "Adamson, Dros" <Weston.Adamson@netapp.com>, Jim Rees <rees@umich.edu>,
        "<linux-nfs@vger.kernel.org>" <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH] NFS4: fix referrals with IPv6 mounts
Date: Fri, 20 Apr 2012 21:38:33 +0000
Message-ID: <9AAD6718-5A17-482C-8AC1-A6F676838AF0@netapp.com>
References: <1334949705-33393-1-git-send-email-dros@netapp.com>
 <20120420194504.GA10259@umich.edu>
 <EA178ED0-5813-4235-A0CF-CF9D54AFB04F@netapp.com>
 <1334952788.3295.24.camel@lade.trondhjem.org>
 <A3FAE1E4-2AB8-4AF0-AC46-77EA3E4B9AB2@netapp.com>
 <1334957730.3295.35.camel@lade.trondhjem.org>
In-Reply-To: <1334957730.3295.35.camel@lade.trondhjem.org>
Content-Type: multipart/signed;
	boundary="Apple-Mail=_7F264C63-4A68-4958-AE09-6AAABA3688B9";
	protocol="application/pkcs7-signature"; micalg=sha1
MIME-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

--Apple-Mail=_7F264C63-4A68-4958-AE09-6AAABA3688B9
Content-Transfer-Encoding: quoted-printable
Content-Type: text/plain;
	charset=windows-1252


On Apr 20, 2012, at 5:35 PM, Myklebust, Trond wrote:

> On Fri, 2012-04-20 at 20:51 +0000, Adamson, Dros wrote:
>> On Apr 20, 2012, at 4:13 PM, Myklebust, Trond wrote:
>>=20
>>> On Fri, 2012-04-20 at 19:57 +0000, Adamson, Dros wrote:
>>>> On Apr 20, 2012, at 3:45 PM, Jim Rees wrote:
>>>>=20
>>>>> Weston Andros Adamson wrote:
>>>>>=20
>>>>> nfs4_path() was parsing the path component by splitting on the =
first colon.
>>>>> This is wrong when an IPv6 address is used to mount a server.
>>>>>=20
>>>>> For example, having mounted 'fc00::10:/export', nfs4_path() =
returned
>>>>> ':10:/export'.  This causes referrals (using IPv4 or IPv6 =
addresses) to fail
>>>>> in nfs4_validate_fspath().
>>>>>=20
>>>>> Parsing the path component by using the *last* colon works with
>>>>> IPv6 as well as IPv4 addrs.
>>>>>=20
>>>>> What if your mount is:
>>>>>=20
>>>>> server.edu:/export/:I-like-colons:
>>>>>=20
>>>>> It seems to me something has to give.  Either we require v6 =
addresses be
>>>>> enclosed in [], export dirs start with "/", or exports have no =
":".
>>>>=20
>>>>=20
>>>> Yeah, you're right.
>>>>=20
>>>> Although IPv6 addrs must be enclosed in [] to work with mount, it's =
always displayed in the kernel without the [].
>>>>=20
>>>> I suppose the correct fix is to always display IPv6 addresses =
enclosed in [], which might touch a *lot* of places.
>>>>=20
>>>> Thoughts?  I'll wait for others to chime in before I go fixing =
this. I have a set of nfsd and mountd patches that deal with similar =
issues on the server side.  I'll clean those up and submit them before =
getting back to this.
>>>=20
>>> We do know which part is the hostname, and which is the pathname. If =
you
>>> look at "try_location()", you'll see that the hostname is stored in
>>> location->servers, and is then copied into this empty buffer.
>>>=20
>>> If you want to test if that is an IPv6 address so that you can =
enclose
>>> it in [], then that should be fairly easy to do right there=85
>>=20
>> Right, we have separate hostname and pathname for each fs_location4, =
but I'm talking about the return value of nfs_path() which is used to =
determine the server-side path on an arbitrary dentry on the *current* =
mountpoint (not the referral server).
>> The path part of nfs_path() is then compared against the fs_path of =
the nfs4_fs_locations struct (this is all in nfs4_validate_fspath).
>>=20
>> Having nfs_path return [] wrapped IPv6 addresses basically means =
changing the devname to that format (d_fsdata is used by nfs_path()).  =
I'm concerned about changing the format of devname - its used all over =
the place.
>>=20
>> So the options are:
>> 1) change the format of devname
>> 2) change how nfs4_validate_fspath gets the server-side path =
component of the current mount (don't use nfs_path())
>>=20
>> I'll try option 1 and see what breaks.
>=20
> That really should not be necessary.
>=20
> If you are using an IPv6 address, you are supposed to mount using the =
[]
> format. If not, then expect things to break.
>=20

Yes, I am mounting with a [] escaped IPv6 addr.

> The real bug here is in nfs4_path: it tries to parse the ':' that are
> part of the IPv6 address even if we use the square bracket delimiters.
> Instead, we should be following the example of nfs_parse_devname.

The [] escaping is stripped well before nfs4_path.

>=20
> I suggest breaking out the first half of nfs_parse_devname into a
> function that returns the host name part of a mount path, and that can
> be called by nfs4_path too.

Yes, something like that could work, but we still have the same issue - =
dentry->d_fsdata never has [] escaping.

-dros


--Apple-Mail=_7F264C63-4A68-4958-AE09-6AAABA3688B9
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
MBwGCSqGSIb3DQEJBTEPFw0xMjA0MjAyMTM4MzRaMCMGCSqGSIb3DQEJBDEWBBQeD+3E7uPKCgU4
ekZ2XFSJ57kTmTANBgkqhkiG9w0BAQEFAASCAQBhME5st7mJgruu2gKx8xUXayyby9bWlbMcXW9N
XWbvWLQSw+GcQXsGM/v5Wr+pch6NQD5yj9HQTzs/ee37gW/LVEoaKMkEQk7O+Teob8EzHMAWM2bT
H8bt42rMnQ9vwT0bZbZHiAQMi3L+LLsirFhsrp+e6BmCPuo/H8y9G++DE7PNq0MVXG7GxejDtGXP
C2s6mjqhJ8Hx0QIwbZi5veu0hGBXGVzkkKHKll/vaTEQ56wr+b3Oly4+JHRj9759cCnIPAagxb6v
Mb8ojk3GvAdyACc4n8S/Lq0kca7uQWh/AG1ACSGp6WThUye45GKTEcr+sARS6pZk8XoGx8FhTmOb
AAAAAAAA

--Apple-Mail=_7F264C63-4A68-4958-AE09-6AAABA3688B9--

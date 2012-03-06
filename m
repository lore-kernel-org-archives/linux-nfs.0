Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx2.netapp.com ([216.240.18.37]:14604 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755697Ab2CFQzz (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 6 Mar 2012 11:55:55 -0500
From: "Adamson, Dros" <Weston.Adamson@netapp.com>
To: Steve Dickson <steved@redhat.com>
CC: Chuck Lever <chuck.lever@oracle.com>,
        "Myklebust, Trond" <Trond.Myklebust@netapp.com>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH 09/15] NFS: Add a client-side function to display NFS
 file handles
Date: Tue, 6 Mar 2012 16:55:39 +0000
Message-ID: <33F7F34A-4CEF-4395-8F9C-74C703FF31FC@netapp.com>
References: <20120301215755.2138.73488.stgit@degas.1015granger.net>
  <20120301220131.2138.63609.stgit@degas.1015granger.net>
 <1330640881.15828.9.camel@lade.trondhjem.org> <4F51009E.6030906@RedHat.com>
 <A558B81B-F666-4783-8FC8-7C2929BBBCE8@oracle.com>
 <4F511675.8000500@RedHat.com>
In-Reply-To: <4F511675.8000500@RedHat.com>
Content-Type: multipart/signed;
	boundary="Apple-Mail=_2B811E89-1943-4176-89A6-9336AB5F0E60";
	protocol="application/pkcs7-signature"; micalg=sha1
MIME-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

--Apple-Mail=_2B811E89-1943-4176-89A6-9336AB5F0E60
Content-Transfer-Encoding: quoted-printable
Content-Type: text/plain;
	charset=iso-8859-1


On Mar 2, 2012, at 1:50 PM, Steve Dickson wrote:

>=20
>=20
> On 03/02/2012 12:19 PM, Chuck Lever wrote:
>>=20
>> On Mar 2, 2012, at 12:17 PM, Steve Dickson wrote:
>>=20
>>>=20
>>>=20
>>> On 03/01/2012 05:28 PM, Myklebust, Trond wrote:
>>>> On Thu, 2012-03-01 at 17:01 -0500, Chuck Lever wrote:
>>>>> For debugging, introduce a simplistic function to print NFS file
>>>>> handles on the system console.  The main function is hooked into =
the
>>>>> dprintk debugging facility, but you can directly call the helper,
>>>>> _nfs_display_fhandle(), if you want to print a handle =
unconditionally.
>>>>>=20
>>>>> Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
>>>>> ---
>>>>>=20
>>>>=20
>>>> One of the things that I really like about wireshark is that it =
also
>>>> displays a 32-bit hexadecimal hash of the filehandle. That allows =
you to
>>>> compare 2 filehandles _much_ faster than trying to look at the full
>>>> shebang.
>>>>=20
>>>>=20
>>> +1 Being able to easily trace filehandle in both the kernel debug =
and
>>> wireshark would be huge.... IMHO...
>>=20
>> Dros mentioned a possible follow-on patch last night at the pub that =
would add exactly this functionality.
>>=20
> And they say good things don't come out of debauchery!!! 8-) =20

Thanks for reminding me!  Patch soon.

-dros=

--Apple-Mail=_2B811E89-1943-4176-89A6-9336AB5F0E60
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
MBwGCSqGSIb3DQEJBTEPFw0xMjAzMDYxNjU1MzlaMCMGCSqGSIb3DQEJBDEWBBQQJlmsnDs/HqXe
alry+4MsTeyltjANBgkqhkiG9w0BAQEFAASCAQCctz0dHada5ioGIfYQfR74nsZn4kLshsHLf0rh
SXfJHnKq2b3jFqeogb3AcL7BHbUkjcbr1U/gDtnMcebYPcZc7OdfuV2cPslJoViN0w0QT5wN0zNH
XJVrf/Paj8z/hJ2154vYqgBgACZmt3kwmrlg+KTmbYF/bG/0yFP+q5P05XuaW8oUrt9iBEW3r+d1
M1OxgZ7pDzujt4Hp7cqeKq7ahl+KnwNwlSdwXdnbXaTvHhySnlkMAdhMeW6KhcR8oiPKwQiFO9j4
M+QzeRyIvdKUWGoHdChx+pl6bxUXcf43Ay4bqfZPHMF40KU+fjdg7j9qv9TYD6uktdIlpYtdqNc9
AAAAAAAA

--Apple-Mail=_2B811E89-1943-4176-89A6-9336AB5F0E60--

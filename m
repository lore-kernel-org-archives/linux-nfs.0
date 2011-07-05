From: "Mol, Xavier" <xavier.mol-Qicz5VY8OY0@public.gmane.org>
Subject: RE: git repo corrupted
Date: Tue, 5 Jul 2011 07:43:15 +0200
Message-ID: <610AEC155EE2F04B99BDA23E6CAE1F1E18DA3955C3@KIT-MSX-07.kit.edu>
References: <610AEC155EE2F04B99BDA23E6CAE1F1E18DA3955C2@KIT-MSX-07.kit.edu>
 <4E11ED73.2020405@panasas.com>
Mime-Version: 1.0
Content-Type: multipart/signed; protocol="application/x-pkcs7-signature";
	micalg=SHA1; boundary="----=_NextPart_000_0000_01CC3AE7.31DB1700"
Cc: "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
To: Benny Halevy <bhalevy@panasas.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from scc-mailout.scc.kit.edu ([129.13.185.202]:60678 "EHLO
	scc-mailout.scc.kit.edu" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753220Ab1GEFnU (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 5 Jul 2011 01:43:20 -0400
In-Reply-To: <4E11ED73.2020405@panasas.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

------=_NextPart_000_0000_01CC3AE7.31DB1700
Content-Type: text/plain;
	charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable

Now it's working for me, too.

Previously, I did not even reach the downloading phase, but the error
message appeared when counting the remote objects reached 2 millions. =
Well,
anyway, thanks for your response on this!

Ciao,
Xavier.

> -----Original Message-----
> From: Benny Halevy [mailto:bhalevy.lists@gmail.com] On Behalf Of Benny
Halevy
> Sent: Monday, July 04, 2011 6:42 PM
> To: Mol, Xavier
> Cc: linux-nfs@vger.kernel.org
> Subject: Re: git repo corrupted
>=20
> I'm not sure what went wrong earlier but cloning seems to be working
> fine on my side right now so far (in "Receiving objects:" ...)
>=20
> Can you please try again?
>=20
> Thanks,
>=20
> Benny
>=20
> On 2011-07-04 18:11, Mol, Xavier wrote:
> > Dear readers,
> >
> > I'm sorry if I'm wrong sending this notice to this list. I'm afraid, =
the
> > last update of Benny Halevy for his project linux-pnfs.git (nfs41, =
pnfs)
> > somewhere went wrong:
> >
> > $ git clone git://linux-nfs.org/~bhalevy/linux-pnfs.git
> > Cloning into linux-pnfs...
> > remote: fatal: Out of memory, realloc failed
> > remote: aborting due to possible repository corruption on the remote
side.
> > fatal: early EOF
> > fatal: index-pack failed
> >
> > This error occurred on two separate machines.
> >
> > Best regards,
> > Xavier Mol
> >
> > ****
> > Karlsruhe Institute of Technology (KIT)
> > Steinbuch Centre for Computing (SCC)
> >
> > B.Sc. Xavier Mol
> > GridKa Storage Support Manager and
> > Head of the D-Grid dCache competence centre
> >
> > Hermann-von-Helmholtz-Platz 1
> > Building 441
> > 76344 Eggenstein-Leopoldshafen, Germany
> > Telefon: +49 721 608 23041
> > E-Mail: xavier.mol-Qicz5VY8OY0@public.gmane.org
> > www.kit.edu
> > KIT =96 University of the State of Baden-W=FCrttemberg and National
Large-scale
> > Research Center of the Helmholtz Association
> > ****
> >


------=_NextPart_000_0000_01CC3AE7.31DB1700
Content-Type: application/x-pkcs7-signature; name="smime.p7s"
Content-Transfer-Encoding: base64
Content-Disposition: attachment; filename="smime.p7s"

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
MBEGA1UEChMKR2VybWFuR3JpZDESMBAGA1UEAxMJR3JpZEthLUNBggEAMB0GA1UdEQQWMBSBEnhh
dmllci5tb2xAa2l0LmVkdTAfBgNVHRIEGDAWgRRncmlka2EtY2FAaXdyLmZ6ay5kZTA1BgNVHR8E
LjAsMCqgKKAmhiRodHRwOi8vZ3JpZC5memsuZGUvY2EvZ3JpZGthLWNybC5kZXIwGgYDVR0gBBMw
ETAPBg0rBgEEAZQ2qywBAQEFMBEGCWCGSAGG+EIBAQQEAwIFoDBOBglghkgBhvhCAQ0EQRY/Q2Vy
dGlmaWNhdGUgaXNzdWVkIHVuZGVyIENQL0NQUyB2LiAxLjUgYXQgaHR0cDovL2dyaWQuZnprLmRl
L2NhMCQGCWCGSAGG+EIBAgQXFhVodHRwOi8vZ3JpZC5memsuZGUvY2EwMwYJYIZIAYb4QgEIBCYW
JGh0dHA6Ly9ncmlkLmZ6ay5kZS9jYS9ncmlka2EtY3BzLnBkZjAzBglghkgBhvhCAQMEJhYkaHR0
cDovL2dyaWQuZnprLmRlL2NhL2dyaWRrYS1jcmwuZGVyMA0GCSqGSIb3DQEBBQUAA4IBAQDRWl6I
GIXMsStbyt9ZmUrR1tI1okKBlvQmeO3bIVUJAU3aZm5ws6Wpmd60apVz4hDo4R9Q6n91TfCKL04Y
Y1urzp8BpBvUDB7lu1p+s3j2lOmcH/fiM4m2eQhzrAyKga2r7fn4umgESuPkhdErZTdmbsILGPcu
47JCxM68SbEPbBubuIYhZiu77n1Wo+VFXMaSw/YnOuxNupwDTleyCu15exfa3O1Hy+oqluzAEHuX
7OYQowucIJLyf56kZHvB2uJh+nAEbwPOUBmaznBriUraGhztUi9Ke1vUY6bry844v59j9jju9mSr
Vxe5m3DtBJMOm7BZg2BYehTrL4NZbq/EMYICyTCCAsUCAQEwPDA2MQswCQYDVQQGEwJERTETMBEG
A1UEChMKR2VybWFuR3JpZDESMBAGA1UEAxMJR3JpZEthLUNBAgI2mDAJBgUrDgMCGgUAoIIBYjAY
BgkqhkiG9w0BCQMxCwYJKoZIhvcNAQcBMBwGCSqGSIb3DQEJBTEPFw0xMTA3MDUwNTQzMTNaMCMG
CSqGSIb3DQEJBDEWBBSBxZ1SLfRaVMo7sNxzXQkHCyQ6FzBLBgkrBgEEAYI3EAQxPjA8MDYxCzAJ
BgNVBAYTAkRFMRMwEQYDVQQKEwpHZXJtYW5HcmlkMRIwEAYDVQQDEwlHcmlkS2EtQ0ECAjaYME0G
CyqGSIb3DQEJEAILMT6gPDA2MQswCQYDVQQGEwJERTETMBEGA1UEChMKR2VybWFuR3JpZDESMBAG
A1UEAxMJR3JpZEthLUNBAgI2mDBnBgkqhkiG9w0BCQ8xWjBYMAoGCCqGSIb3DQMHMA4GCCqGSIb3
DQMCAgIAgDANBggqhkiG9w0DAgIBQDAHBgUrDgMCBzANBggqhkiG9w0DAgIBKDAHBgUrDgMCGjAK
BggqhkiG9w0CBTANBgkqhkiG9w0BAQEFAASCAQCil+IlBCKKg4CmhrN8IGQdTPF3033+G9ToI6LQ
g8Gk79rcAlgq9q9FW1mGfyOERRlBH3DXwNY6KR7WN1etbzZTtLWZzFl4rY4q3ME4JOW95/7Ka3+M
MTBp7mTdk51D76zW4zX1/ngybQT5tBgKf24Ht+5EWGwYG1X+rrPae7hmOdVs1g+FEwakybzkkGW+
lVDkWROjtPZIHoHst23midf7y7JZQT7XnpdhxPb11XgtcMg4endJ4tYIF9nkqwwtNmoT9swdOhGt
ESnjTCDxhQ/7OY4FdzN56O4tYtkafj/r/z3+YuUuENe1WiqmpGQ9N2kfFz9SzLqE8zp8fg4PnmhW
AAAAAAAA

------=_NextPart_000_0000_01CC3AE7.31DB1700--

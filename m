Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx2.netapp.com ([216.240.18.37]:50232 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1759438Ab2FAV5g (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 1 Jun 2012 17:57:36 -0400
Received: from vmwexceht02-prd.hq.netapp.com (vmwexceht02-prd.hq.netapp.com [10.106.76.240])
	by smtp1.corp.netapp.com (8.13.1/8.13.1/NTAP-1.6) with ESMTP id q51LvaPD022201
	for <linux-nfs@vger.kernel.org>; Fri, 1 Jun 2012 14:57:36 -0700 (PDT)
From: "Adamson, Dros" <Weston.Adamson@netapp.com>
To: "Adamson, Andy" <William.Adamson@netapp.com>
CC: "Isaman, Fred" <Fred.Isaman@netapp.com>,
        "<linux-nfs@vger.kernel.org>" <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH 3/6] PYNFS use loopback addresses for MDS<->DS
 communication
Date: Fri, 1 Jun 2012 21:57:35 +0000
Message-ID: <C9B04468-8ABF-4160-96D4-E8B264A8EC8C@netapp.com>
References: <1338328679-28837-1-git-send-email-andros@netapp.com>
 <1338328679-28837-4-git-send-email-andros@netapp.com>
In-Reply-To: <1338328679-28837-4-git-send-email-andros@netapp.com>
Content-Type: multipart/signed;
	boundary="Apple-Mail=_F698419F-C50E-4C9D-92C4-1C8D4473E1E8";
	protocol="application/pkcs7-signature"; micalg=sha1
MIME-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

--Apple-Mail=_F698419F-C50E-4C9D-92C4-1C8D4473E1E8
Content-Transfer-Encoding: quoted-printable
Content-Type: text/plain;
	charset=us-ascii

I think I gave this to Fred some time ago.  This patch is a hack that =
only works when the MDS and all data servers are run on the same host.

It's easy enough to use aliases on an interface and bring those down, =
but the ordering problem remains:=20
The pynfs MDS <-> DS backchannel uses the first address in the address =
list and most clients (including linux) will use the first address that =
works when communicating with data servers, so bringing down the alias =
that the DS is communicating on will also break the pynfs backchannel.

I'll rework the patch to allow this testing on both localhost and across =
hosts.

-dros
=20
On May 29, 2012, at 5:57 PM, <andros@netapp.com>
 <andros@netapp.com> wrote:

> From: Weston Andros Adamson <dros@netapp.com>
>=20
> if a loopback addresses is specified for a DS, use that address for =
MDS to DS
> communication and remove it from the advertised addresses in =
getdeviceinfo
> (it obviously would never work).
>=20
> this is useful for testing network partitions - you can bring down / =
firewall
> off an interface without breaking MDS<->DS communications.
>=20
> an example dataservers.conf:
>=20
> 192.168.55.1:12345,127.0.0.1:12345/pynfs_mds
> 192.168.55.1:12346,127.0.0.1:12346/pynfs_mds
>=20
> Signed-off-by: Weston Andros Adamson <dros@netapp.com>
> ---
> nfs4.1/dataserver.py |   28 ++++++++++++++++++++++------
> 1 files changed, 22 insertions(+), 6 deletions(-)
>=20
> diff --git a/nfs4.1/dataserver.py b/nfs4.1/dataserver.py
> index 65e4f55..dd2a535 100644
> --- a/nfs4.1/dataserver.py
> +++ b/nfs4.1/dataserver.py
> @@ -187,9 +187,27 @@ class DSDevice(object):
>                     log.critical("Could not parse line: %r" % line)
>                     sys.exit(1)
>=20
> -                # for now, just use the last path for local =
connections
> -                server, port =3D server_list[-1]
> -                server_list =3D server_list[:-1]
> +                # if there is a (IPv4) loopback address in the =
multipath list,
> +                # use that as the connection to the DS, but dont =
advertise it
> +                loopback_idx =3D -1
> +                for i, serverport in enumerate(server_list):
> +                    if serverport[0] =3D=3D '127.0.0.1':
> +                        loopback_idx =3D i
> +                        break
> +
> +                if loopback_idx >=3D 0:
> +                    print "Using loopback address for MDS->DS =
communication only"
> +                    server_list =3D list(server_list)
> +                    server, port =3D server_list.pop(loopback_idx)
> +                else:
> +                    # just use the last path for local connections
> +                    server, port =3D server_list[-1]
> +
> +                if not server_list:
> +                    log.critical("At least one non-loopback address =
must " +
> +                                 "be specified for each DS")
> +                    sys.exit(1)
> +
>                 print server, port, path
>                 try:
>                     log.info("Adding dataserver ip:%s port:%s path:%s" =
%
> @@ -210,9 +228,7 @@ class DSDevice(object):
>         index =3D 0
>         for d in self.list:
>             if d.active:
> -                multipath =3D []
> -                multipath.extend(d.get_multipath_netaddr4s())
> -                multipath.append(d.get_netaddr4())
> +                multipath =3D d.get_multipath_netaddr4s()
>                 netaddrs.append(multipath)
>                 stripe_indices.append(index)
>                 index =3D index + 1
> --=20
> 1.7.7.6
>=20


--Apple-Mail=_F698419F-C50E-4C9D-92C4-1C8D4473E1E8
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
MBwGCSqGSIb3DQEJBTEPFw0xMjA2MDEyMTU3MzVaMCMGCSqGSIb3DQEJBDEWBBSDI4nB2nLxQGjc
2YqI2B+la1EwnjANBgkqhkiG9w0BAQEFAASCAQAGPnrzy4dagDd9FFyJac4+5ZOVHAOathreIIvd
5QCcS3EALYHr1xX0O18UnSzwuAeMWkPIrvzD7rgt9X0ARMNOI7e+n4Q2HKuurF4PMGKoUjCQJ/OD
j/IXfTQyc/GC0DDqXH+eD6A1xHXo5F0ysmeBBxKQq+LnWe/H8JtrR8N6HCJbg4//XzDTU6w5zqvX
4/qO3V36RFK6NLwu8ODZyvTy1e1bfWh51oA8RvfBX19VX9ttUfqoht5FwLCvvADywX/RyHAHMByK
1/2tKlL0V4bNmODPinj7eT5il6LRnFdqTZT20xka2N7jBSWH+H6o2FRuti7g7r3U3YoFfyhLlp9n
AAAAAAAA

--Apple-Mail=_F698419F-C50E-4C9D-92C4-1C8D4473E1E8--

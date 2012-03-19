Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx2.netapp.com ([216.240.18.37]:26146 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1759053Ab2CSPgD (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 19 Mar 2012 11:36:03 -0400
From: "Adamson, Dros" <Weston.Adamson@netapp.com>
To: Paul Gortmaker <paul.gortmaker@windriver.com>,
        "Myklebust, Trond" <Trond.Myklebust@netapp.com>
CC: linux-nfs list <linux-nfs@vger.kernel.org>
Subject: Re: _nfs_display_fhandle_hash: undefined reference to `crc32_le'
Date: Mon, 19 Mar 2012 15:35:11 +0000
Message-ID: <194578ED-EA46-479D-A61A-08D1A92FF80C@netapp.com>
References: <20120318181304.GA2095@windriver.com>
In-Reply-To: <20120318181304.GA2095@windriver.com>
Content-Type: multipart/signed;
	boundary="Apple-Mail=_F7D1902D-060C-42A2-B8AA-173794F1903F";
	protocol="application/pkcs7-signature"; micalg=sha1
MIME-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

--Apple-Mail=_F7D1902D-060C-42A2-B8AA-173794F1903F
Content-Transfer-Encoding: quoted-printable
Content-Type: text/plain;
	charset=us-ascii

Oops!  The fix is ok, in that it will work, but I'm not sure we want to =
pull in that type of dependency for a debug message.

Maybe it'd be more appropriate to do something like this:

=46rom 371ebd38717cd34a58d167909b56a216db288f83 Mon Sep 17 00:00:00 2001
From: Weston Andros Adamson <dros@netapp.com>
Date: Mon, 19 Mar 2012 11:31:12 -0400
Subject: [PATCH] if CRC32 isn't defined just return 0 for fh hash


Signed-off-by: Weston Andros Adamson <dros@netapp.com>
---
 fs/nfs/inode.c |    4 ++++
 1 files changed, 4 insertions(+), 0 deletions(-)

diff --git a/fs/nfs/inode.c b/fs/nfs/inode.c
index 1a19f8d..0c1ca6a 100644
--- a/fs/nfs/inode.c
+++ b/fs/nfs/inode.c
@@ -1060,7 +1060,11 @@ u32 _nfs_display_fhandle_hash(const struct nfs_fh =
*fh)
 {
        /* wireshark uses 32-bit AUTODIN crc and does a bitwise
         * not on the result */
+#ifdef CONFIG_CRC32
        return ~crc32(0xFFFFFFFF, &fh->data[0], fh->size);
+#else
+       return 0;
+#endif
 }

 /*
--=20
1.7.4.4

Or (if possible) define the dependency iff NFS_FS and RPC_DEBUG are =
defined.

I'm sure Trond has an opinion on this.

-dros

On Mar 18, 2012, at 2:13 PM, Paul Gortmaker wrote:

> This started showing up in linux-next last week:
>=20
>  LD      .tmp_vmlinux1
> fs/built-in.o: In function `_nfs_display_fhandle_hash':
> /scratch/kisskb/src/fs/nfs/inode.c:1063: undefined reference to =
`crc32_le'
> make[1]: *** [.tmp_vmlinux1] Error 1
>=20
> Target is an mpc8xx board:
>=20
> http://kisskb.ellerman.id.au/kisskb/target/2679/
>=20
> I tried to run an automated bisect on it, but there appears to
> be build failures in the bisection range, in addition to the
> above link error (i.e. points I'd use "skip" on if I wasn't
> using "git bisect run ...")
>=20
> # good: [b030fb0bb113316cc6f56779388b8572ab0699da] SUNRPC: use proper =
network namespace in rpcbind RPCBPROC_GETADDR procedure
> git bisect good b030fb0bb113316cc6f56779388b8572ab0699da
> # bad: [5247fab5c82779174d50590e0200bf532248a8a1] SUNRPC: pass network =
namespace to service registering routines
> git bisect bad 5247fab5c82779174d50590e0200bf532248a8a1
>=20
> Even without the concrete trigger commit, a suggested possible
> fix (tested locally) is below.
>=20
> Paul.
> ---
>=20
> =46rom 21b77ae0373725bd2c60eca065e77c4d2f0fdbfa Mon Sep 17 00:00:00 =
2001
> From: Paul Gortmaker <paul.gortmaker@windriver.com>
> Date: Sun, 18 Mar 2012 14:07:42 -0400
> Subject: [PATCH] nfs: select CRC32 for when NFS is enabled for =
crc32_le
>=20
> To avoid the following link errors:
>=20
>  LD      .tmp_vmlinux1
> fs/built-in.o: In function `_nfs_display_fhandle_hash':
> fs/nfs/inode.c:1063: undefined reference to `crc32_le'
> make[1]: *** [.tmp_vmlinux1] Error 1
>=20
> Signed-off-by: Paul Gortmaker <paul.gortmaker@windriver.com>
>=20
> diff --git a/fs/nfs/Kconfig b/fs/nfs/Kconfig
> index 7bce64c..9acdfb0 100644
> --- a/fs/nfs/Kconfig
> +++ b/fs/nfs/Kconfig
> @@ -3,6 +3,7 @@ config NFS_FS
> 	depends on INET && FILE_LOCKING
> 	select LOCKD
> 	select SUNRPC
> +	select CRC32
> 	select NFS_ACL_SUPPORT if NFS_V3_ACL
> 	help
> 	  Choose Y here if you want to access files residing on other
> --=20
> 1.7.9.1
>=20
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" =
in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html


--Apple-Mail=_F7D1902D-060C-42A2-B8AA-173794F1903F
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
MBwGCSqGSIb3DQEJBTEPFw0xMjAzMTkxNTM1MTNaMCMGCSqGSIb3DQEJBDEWBBT5A8C6NTN2CCFs
/b6rf/sCdJX8hTANBgkqhkiG9w0BAQEFAASCAQCia/TJ4W63jt8x5Zpu6yS2zT2ULKCs2dBeegGi
qz0xtvmcetXGKvGs/DXeKLii2Ha2x2pk+/cqxDM88nh6aTUjy/uts9W1ONN6vmkC6Xs9kYAq/7kC
iDo3JsPMAf0IGWkR7peknBizYP7ehYCj35/3jipkW6N8sunr7MJiNNXGazd4vqWrGHmBLN6+nO8g
cl4ojcBH1cYR3tZDzY59Vog1+i5ylH+rfWh2O/WYsfH8443IVSAYxrNfhkleaMMYv+WRxQNcimZK
ax1/coCR3mjLnh0Dz5ytrZY4sFB+OBcxwYWWKCcKUAwecEKtVPqQsw5HbysU3p+uBfbQQWouZ0NT
AAAAAAAA

--Apple-Mail=_F7D1902D-060C-42A2-B8AA-173794F1903F--

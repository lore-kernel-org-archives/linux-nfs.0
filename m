Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx2.netapp.com ([216.240.18.37]:43925 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1758942Ab2CSSse (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 19 Mar 2012 14:48:34 -0400
From: "Adamson, Dros" <Weston.Adamson@netapp.com>
To: "Myklebust, Trond" <Trond.Myklebust@netapp.com>
CC: "Adamson, Dros" <Weston.Adamson@netapp.com>,
        Paul Gortmaker <paul.gortmaker@windriver.com>,
        linux-nfs list <linux-nfs@vger.kernel.org>
Subject: Re: _nfs_display_fhandle_hash: undefined reference to `crc32_le'
Date: Mon, 19 Mar 2012 18:48:15 +0000
Message-ID: <370D7412-07DA-4668-B78E-CC73CC982BDB@netapp.com>
References: <20120318181304.GA2095@windriver.com>
 <194578ED-EA46-479D-A61A-08D1A92FF80C@netapp.com>
 <1332181221.2636.12.camel@lade.trondhjem.org>
In-Reply-To: <1332181221.2636.12.camel@lade.trondhjem.org>
Content-Type: multipart/signed;
	boundary="Apple-Mail=_D9F3C859-8F03-4C1C-974B-C635F67979EA";
	protocol="application/pkcs7-signature"; micalg=sha1
MIME-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

--Apple-Mail=_D9F3C859-8F03-4C1C-974B-C635F67979EA
Content-Transfer-Encoding: quoted-printable
Content-Type: text/plain;
	charset=us-ascii

I like this solution.

-dros

On Mar 19, 2012, at 2:20 PM, Myklebust, Trond wrote:

> On Mon, 2012-03-19 at 15:35 +0000, Adamson, Dros wrote:
>> Oops!  The fix is ok, in that it will work, but I'm not sure we want =
to pull in that type of dependency for a debug message.
>>=20
>> Maybe it'd be more appropriate to do something like this:
>>=20
>> =46rom 371ebd38717cd34a58d167909b56a216db288f83 Mon Sep 17 00:00:00 =
2001
>> From: Weston Andros Adamson <dros@netapp.com>
>> Date: Mon, 19 Mar 2012 11:31:12 -0400
>> Subject: [PATCH] if CRC32 isn't defined just return 0 for fh hash
>>=20
>>=20
>> Signed-off-by: Weston Andros Adamson <dros@netapp.com>
>> ---
>> fs/nfs/inode.c |    4 ++++
>> 1 files changed, 4 insertions(+), 0 deletions(-)
>>=20
>> diff --git a/fs/nfs/inode.c b/fs/nfs/inode.c
>> index 1a19f8d..0c1ca6a 100644
>> --- a/fs/nfs/inode.c
>> +++ b/fs/nfs/inode.c
>> @@ -1060,7 +1060,11 @@ u32 _nfs_display_fhandle_hash(const struct =
nfs_fh *fh)
>> {
>>        /* wireshark uses 32-bit AUTODIN crc and does a bitwise
>>         * not on the result */
>> +#ifdef CONFIG_CRC32
>>        return ~crc32(0xFFFFFFFF, &fh->data[0], fh->size);
>> +#else
>> +       return 0;
>> +#endif
>> }
>>=20
>> /*
>=20
> That was my first thought, but the problem with the above is that it
> hides the CRC32 dependency deep down in the bowels of the NFS code.
>=20
> OK. What say we just bite the bullet, and add the dprintk() interface =
to
> Kbuild. That will allow distros that don't ship the 'rpcdebug' utility
> to turn off dprintk() and will allow us to select CRC32 if and only if
> we really need it.
> IOW: Something like the following:
>=20
>=20
> 8<--------------------------------------------------------------------
> =46rom 855fa894a2b24b9872b535b75b04b82121f93b73 Mon Sep 17 00:00:00 =
2001
> From: Trond Myklebust <Trond.Myklebust@netapp.com>
> Date: Sun, 18 Mar 2012 14:07:42 -0400
> Subject: [PATCH] SUNRPC/NFS: Add Kbuild dependencies for =
NFS_DEBUG/RPC_DEBUG
>=20
> This allows us to turn on/off the dprintk() debugging interfaces for
> those distributions that don't ship the 'rpcdebug' utility.
> It also allows us to add Kbuild dependencies. Specifically, we already
> know that dprintk() in general relies on CONFIG_SYSCTL. Now it turns =
out
> that the NFS dprintks depend on CONFIG_CRC32 after we added support
> for the filehandle hash.
>=20
> Reported-by: Paul Gortmaker <paul.gortmaker@windriver.com>
> Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
> ---
> fs/nfs/Kconfig               |    6 ++++++
> fs/nfs/inode.c               |    2 +-
> fs/nfs/mount_clnt.c          |    2 +-
> fs/nfs/nfsroot.c             |    2 +-
> include/linux/nfs_fs.h       |   17 ++++++++---------
> include/linux/sunrpc/debug.h |    2 +-
> net/sunrpc/Kconfig           |   13 +++++++++++++
> 7 files changed, 31 insertions(+), 13 deletions(-)
>=20
> diff --git a/fs/nfs/Kconfig b/fs/nfs/Kconfig
> index 7bce64c..2a0e6c5 100644
> --- a/fs/nfs/Kconfig
> +++ b/fs/nfs/Kconfig
> @@ -144,3 +144,9 @@ config NFS_USE_KERNEL_DNS
> 	depends on NFS_V4 && !NFS_USE_LEGACY_DNS
> 	select DNS_RESOLVER
> 	default y
> +
> +config NFS_DEBUG
> +	bool
> +	depends on NFS_FS && SUNRPC_DEBUG
> +	select CRC32
> +	default y
> diff --git a/fs/nfs/inode.c b/fs/nfs/inode.c
> index 1a19f8d..7bb4d13 100644
> --- a/fs/nfs/inode.c
> +++ b/fs/nfs/inode.c
> @@ -1047,7 +1047,7 @@ struct nfs_fh *nfs_alloc_fhandle(void)
> 	return fh;
> }
>=20
> -#ifdef RPC_DEBUG
> +#ifdef NFS_DEBUG
> /*
>  * _nfs_display_fhandle_hash - calculate the crc32 hash for the =
filehandle
>  *                             in the same way that wireshark does
> diff --git a/fs/nfs/mount_clnt.c b/fs/nfs/mount_clnt.c
> index b37ca34..8e65c7f 100644
> --- a/fs/nfs/mount_clnt.c
> +++ b/fs/nfs/mount_clnt.c
> @@ -16,7 +16,7 @@
> #include <linux/nfs_fs.h>
> #include "internal.h"
>=20
> -#ifdef RPC_DEBUG
> +#ifdef NFS_DEBUG
> # define NFSDBG_FACILITY	NFSDBG_MOUNT
> #endif
>=20
> diff --git a/fs/nfs/nfsroot.c b/fs/nfs/nfsroot.c
> index c4744e1..cd3c910 100644
> --- a/fs/nfs/nfsroot.c
> +++ b/fs/nfs/nfsroot.c
> @@ -104,7 +104,7 @@ static char nfs_export_path[NFS_MAXPATHLEN + 1] =
__initdata =3D "";
> /* server:export path string passed to super.c */
> static char nfs_root_device[NFS_MAXPATHLEN + 1] __initdata =3D "";
>=20
> -#ifdef RPC_DEBUG
> +#ifdef NFS_DEBUG
> /*
>  * When the "nfsrootdebug" kernel command line option is specified,
>  * enable debugging messages for NFSROOT.
> diff --git a/include/linux/nfs_fs.h b/include/linux/nfs_fs.h
> index 0a63ab2..8f27c2e 100644
> --- a/include/linux/nfs_fs.h
> +++ b/include/linux/nfs_fs.h
> @@ -38,6 +38,13 @@
>=20
> #ifdef __KERNEL__
>=20
> +/*
> + * Enable dprintk() debugging support for nfs client.
> + */
> +#ifdef CONFIG_NFS_DEBUG
> +# define NFS_DEBUG
> +#endif
> +
> #include <linux/in.h>
> #include <linux/mm.h>
> #include <linux/pagemap.h>
> @@ -391,7 +398,7 @@ static inline void nfs_free_fhandle(const struct =
nfs_fh *fh)
> 	kfree(fh);
> }
>=20
> -#ifdef RPC_DEBUG
> +#ifdef NFS_DEBUG
> extern u32 _nfs_display_fhandle_hash(const struct nfs_fh *fh);
> static inline u32 nfs_display_fhandle_hash(const struct nfs_fh *fh)
> {
> @@ -650,14 +657,6 @@ nfs_fileid_to_ino_t(u64 fileid)
>=20
> #ifdef __KERNEL__
>=20
> -/*
> - * Enable debugging support for nfs client.
> - * Requires RPC_DEBUG.
> - */
> -#ifdef RPC_DEBUG
> -# define NFS_DEBUG
> -#endif
> -
> # undef ifdebug
> # ifdef NFS_DEBUG
> #  define ifdebug(fac)		if (unlikely(nfs_debug & =
NFSDBG_##fac))
> diff --git a/include/linux/sunrpc/debug.h =
b/include/linux/sunrpc/debug.h
> index 6cb2517..9448eb5 100644
> --- a/include/linux/sunrpc/debug.h
> +++ b/include/linux/sunrpc/debug.h
> @@ -31,7 +31,7 @@
> /*
>  * Enable RPC debugging/profiling.
>  */
> -#ifdef CONFIG_SYSCTL
> +#ifdef CONFIG_SUNRPC_DEBUG
> #define  RPC_DEBUG
> #endif
> #ifdef CONFIG_TRACEPOINTS
> diff --git a/net/sunrpc/Kconfig b/net/sunrpc/Kconfig
> index ffd243d..9fe8857 100644
> --- a/net/sunrpc/Kconfig
> +++ b/net/sunrpc/Kconfig
> @@ -39,3 +39,16 @@ config RPCSEC_GSS_KRB5
> 	  Kerberos support should be installed.
>=20
> 	  If unsure, say Y.
> +
> +config SUNRPC_DEBUG
> +	bool "RPC: Enable dprintk debugging"
> +	depends on SUNRPC && SYSCTL
> +	help
> +	  This option enables a sysctl-based debugging interface
> +	  that is be used by the 'rpcdebug' utility to turn on or off
> +	  logging of different aspects of the kernel RPC activity.
> +
> +	  Disabling this option will make your kernel slightly smaller,
> +	  but makes troubleshooting NFS issues significantly harder.
> +
> +	  If unsure, say Y.
> --=20
> 1.7.7.6
>=20
>=20
> --=20
> Trond Myklebust
> Linux NFS client maintainer
>=20
> NetApp
> Trond.Myklebust@netapp.com
> www.netapp.com
>=20


--Apple-Mail=_D9F3C859-8F03-4C1C-974B-C635F67979EA
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
MBwGCSqGSIb3DQEJBTEPFw0xMjAzMTkxODQ4MTZaMCMGCSqGSIb3DQEJBDEWBBRqfqCpwKP1Y/if
gKAz91aJPkDM2TANBgkqhkiG9w0BAQEFAASCAQBGdjhn3J3EoKGW/KPgHO7o4BEZsGRpiOAqbkcs
ugcIZjbi3Wgt7RT3AHSAJr4AnDF2UBQMIkRPADhnfKEHLCCADbWPeb4FoRPdEsWo+hwIhEXigl10
ON89WiVLz/fuOfvPE0CyR1PjuywFE2OURqtjHunMazQWwqVDPkqdqaQgsc7GN3fyfehTqqdZ3qWh
IO0LAwJj2iqsutDw71w55KCNDe4GwZPnSje6/BQHazxpPUyCLkV2qICaK0RpeSUB2l0vw3KYbDmS
37ryevz8zcp5k/+CmY3sHyWAbIrSBaAdOwyVHzih39XiBVtQhcjmU+hUEj1Tt7hyHM8oieIR9gFe
AAAAAAAA

--Apple-Mail=_D9F3C859-8F03-4C1C-974B-C635F67979EA--

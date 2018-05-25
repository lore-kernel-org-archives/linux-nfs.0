Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from aserp2130.oracle.com ([141.146.126.79]:48040 "EHLO
        aserp2130.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S970030AbeEYAuw (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Thu, 24 May 2018 20:50:52 -0400
Content-Type: text/plain;
        charset=us-ascii
Mime-Version: 1.0 (Mac OS X Mail 11.3 \(3445.6.18\))
Subject: Re: [PATCH 1/1] nfs-utils: Add check of clientaddr argument
From: Chuck Lever <chuck.lever@oracle.com>
In-Reply-To: <20180524200542.22685-1-kolga@netapp.com>
Date: Thu, 24 May 2018 17:50:44 -0700
Cc: Steve Dickson <steved@redhat.com>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Message-Id: <48E7EEA0-C804-4AB3-9C08-10A5B14B8976@oracle.com>
References: <20180524200542.22685-1-kolga@netapp.com>
To: Olga Kornievskaia <kolga@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi Olga-

> On May 24, 2018, at 1:05 PM, Olga Kornievskaia <kolga@netapp.com> =
wrote:
>=20
> If the user supplies a clientaddr value,

Please say "NFS client administrator" not "user". A
"user" is any non-privileged user, so saying that a
"user" can set this value is misleading.


> it should be either
> a special value of either IPV4/IPV6 any address or a local address
> on the same network that the server being mounted.

This option should allow any local address the client has,
not just an address that is on the same network as the
server. See below for further explanation.


> Otherwise, we
> disallow the client to use an arbitrary value of the clientaddr value.
> This value is used to construct a client id of SETCLIENTID and
> providing a false value can interfere with the real owner's mount.

The patch description is misleading:

Interference occurs only if the real owner's lease is
not protected by Kerberos AND this client has the same
client ID string as another client.

The Linux client's client ID string also contains the
system's cl_nodename. Both the cl_nodename and the
callback address have to be the same as some other
client's, and they both have to be Linux, for this to
be a problem.

It's more likely that the customer's clients are all
named the same (maybe they are copied from the same
system image), and reverse DNS lookup is giving them
all the same clientaddr=3D . That's an unsupported
configuration and there are already ways to address
this.

Or perhaps I don't understand the use case that is
causing the problem. Can the patch description explain
why your customer is trying to set clientaddr=3D ?


> Signed-off-by: Olga Kornievskaia <kolga@netapp.com>
> ---
> utils/mount/stropts.c | 24 ++++++++++++++++++++----
> 1 file changed, 20 insertions(+), 4 deletions(-)
>=20
> diff --git a/utils/mount/stropts.c b/utils/mount/stropts.c
> index d1b0708..44a6ff5 100644
> --- a/utils/mount/stropts.c
> +++ b/utils/mount/stropts.c
> @@ -229,7 +229,8 @@ static int nfs_append_addr_option(const struct =
sockaddr *sap,
>=20
> /*
>  * Called to discover our address and append an appropriate =
'clientaddr=3D'
> - * option to the options string.
> + * option to the options string. If the supplied 'clientaddr=3D' =
value does
> + * not match either IPV4/IPv6 any or a local address, then fail the =
mount.
>  *
>  * Returns 1 if 'clientaddr=3D' option created successfully or if
>  * 'clientaddr=3D' option is already present; otherwise zero.
> @@ -242,11 +243,26 @@ static int nfs_append_clientaddr_option(const =
struct sockaddr *sap,
> 	struct sockaddr *my_addr =3D &address.sa;
> 	socklen_t my_len =3D sizeof(address);
>=20
> -	if (po_contains(options, "clientaddr") =3D=3D PO_FOUND)
> -		return 1;
> -
> 	nfs_callback_address(sap, salen, my_addr, &my_len);
>=20
> +	if (po_contains(options, "clientaddr") =3D=3D PO_FOUND) {
> +		char *addr =3D po_get(options, "clientaddr");
> +		char address[NI_MAXHOST];
> +
> +		if (!strcmp(addr, "0.0.0.0") || !strcmp(addr, "::"))
> +			return 1;

IN6ADDR_ANY can be spelled in other ways than "::".

Please don't compare presentation address strings.
First step is to convert the clientaddr=3D value to an
nfs_sockaddr. If that cannot be done, then clearly
this is not a valid mount option.


> +		if (!nfs_present_sockaddr(my_addr, my_len, address,
> +						sizeof(address)))
> +			goto out;
> +
> +		if (strcmp(addr, address)) {
> +			nfs_error(_("%s: failed to validate clientaddr "
> +					"address"), progname);
> +			return 0;
> +		}

This needs to check whether the supplied address is a
local address on _any_ of the client's interfaces. That's
the point of allowing an admin to set clientaddr=3D ...
sometimes the automatic setting (which comes from
nfs_callback_address) is wrong.

Think of a multi-homed client, or a client with public and
private interfaces, or a weird firewall configuration.
This check will break all those cases.

So here, use a reliable mechanism for determining whether
the passed-in clientaddr=3D value specifies the address of
one of the local interfaces on the client.


> +		return 1;
> +	}
> +out:
> 	return nfs_append_generic_address_option(my_addr, my_len,
> 							"clientaddr", =
options);
> }

--
Chuck Lever




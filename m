From: Chuck Lever <chuck.lever@oracle.com>
Subject: Re: NFSD IPv6 support for 2.6.29
Date: Mon, 17 Nov 2008 13:19:47 -0500
Message-ID: <AF604C91-2F1B-48A3-8E1D-84D5CBBB2856@oracle.com>
References: <9BBD5BD5-C461-43C4-AEB0-69D3E31F92B7@oracle.com> <4917C380.9040703@linux.vnet.ibm.com> <C44F9C62-2770-4879-8AC7-B1C8D81F9AB6@oracle.com> <491AFE09.2010803@bull.net> <2BF8FCDB-0C6D-430E-B2AE-4C293E30A1AE@oracle.com> <4921AF45.4070009@bull.net>
Mime-Version: 1.0 (Apple Message framework v929.2)
Content-Type: text/plain; charset=ISO-8859-1;
	format=flowed	delsp=yes
Cc: Varun Chandramohan <varunc@linux.vnet.ibm.com>,
	Linux NFS Mailing List <linux-nfs@vger.kernel.org>
To: Le Rouzic <aime.le-rouzic@bull.net>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from rcsinet12.oracle.com ([148.87.113.124]:61730 "EHLO
	rgminet12.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751738AbYKQSU2 convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 17 Nov 2008 13:20:28 -0500
In-Reply-To: <4921AF45.4070009@bull.net>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Nov 17, 2008, at Nov 17, 2008, 12:52 PM, Le Rouzic wrote:
> Chuck Lever a =E9crit :
>
>>>> On Nov 10, 2008, at 12:15 AM, Varun Chandramohan wrote:
>>>>
>>>>> Chuck Lever wrote:
>>>>>
>>>>>> Hi Aime, Varun-
>>>>>>
>>>>>> Bruce asked me to collect server-side IPv6 patches for upstream.
>>>>>> I've collected the patches that have been posted on the list, an=
d
>>>>>> added some fixes of my own.
>>>>>>
>>>>>> Can you have a look at
>>>>>>
>>>>>> http://git.linux-nfs.org/?p=3Dcel/cel-2.6.git;a=3Dsummary
>>>>>>
>>>>>> tag cel-ipv6-10292008
>>>>>>
>>>>>> These have been build tested, but I haven't done any run-time
>>>>>> testing yet.
>>>>>>
>>>>>> --
>>>>>> Chuck Lever
>>>>>> chuck[dot]lever[at]oracle[dot]com
>>>>>
>>>>>
>>>>> Hi Chuck,
>>>>>
>>>>>              I just realized that i forgot to update you about th=
e
>>>>> test result of your tree. I found NFSv4 over ipv6 working well. S=
o
>>>>> it can be pulled into the mainline soon.
>>>>
> Hi
> I have tested the "tag cel-ipv6-10292008" and some robustness tests
> started simultaneously (connectathon, fsx, iozone, fss_stress, ffsb) =
=20
> have
> been running fine during several hours in IPV6 and IPV4.
> I used the my nfs-utils package based on nfs-utils.1.1.2
> (http://nfsv4.bullopensource.org/)

Thanks for the review and testing.

> Nevertheless I may have missed something during the last mails about =
=20
> IPV6
> but I don't find in your tree changes about IPV6 in fs/nfsd/nfsctl.c

> I join the patch I submitted for that.

write_getfs() and write_getfd() use a fixed size field in the down =20
call that is too small for IPv6 addresses.  That field is defined as a =
=20
"struct sockaddr", but that type is meant only to be used for a =20
pointer (as in "struct sockaddr *").  It happens to be the same size =20
as a sockaddr_in, but it is much smaller than an IPv6 address.

The modern preferred interface is /proc/fs/nfsd/filehandle.  See the =20
comments I added in fs/nfsd/nfsctl.c that describe the whole NFSD =20
interface.  As far as I can tell, no changes are needed in =20
write_filehandle() to support IPv6.

> --
> -----------------------------------------------------------------
> Company : Bull, Architect of an Open World TM (www.bull.com)
> Name    : Aime Le Rouzic
> Mail    : Bull - BP 208 - 38432 Echirolles Cedex - France
> E-Mail  : aime.le-rouzic@bull.net
> Phone   : 33 (4) 76.29.75.51
> Fax     : 33 (4) 76.29.75.18
> -----------------------------------------------------------------
>
>
> NFSV4 IPV6: Adds AF_INET6 domain processing when AF_INET processing =20
> only available in nfsd/nfsctl.c
>
> ---
>
> fs/nfsd/nfsctl.c     |   41 +++++++++++++++++++++++++++++++----------
>
> Signed-off-by: Aime Le Rouzic <aime.le-rouzic@bull.net>
> ---
> diff -Nru rpcbindv4/fs/nfsd/nfsctl.c ipv6overrpcbindv4/fs/nfsd/=20
> nfsctl.c
> --- rpcbindv4/fs/nfsd/nfsctl.c	2008-09-15 14:50:09.000000000 +0200
> +++ ipv6overrpcbindv4/fs/nfsd/nfsctl.c	2008-09-15 15:18:24.000000000 =
=20
> +0200
> @@ -230,6 +230,7 @@
> {
> 	struct nfsctl_fsparm *data;
> 	struct sockaddr_in *sin;
> +	struct sockaddr_in6 *sin6;
> 	struct auth_domain *clp;
> 	int err =3D 0;
> 	struct knfsd_fh *res;
> @@ -239,9 +240,19 @@
> 		return -EINVAL;
> 	data =3D (struct nfsctl_fsparm*)buf;
> 	err =3D -EPROTONOSUPPORT;
> -	if (data->gd_addr.sa_family !=3D AF_INET)
> +	switch (data->gd_addr.sa_family) {
> +	case AF_INET:
> +		sin =3D (struct sockaddr_in *)&data->gd_addr;
> +		ipv6_addr_set_v4mapped(sin->sin_addr.s_addr, &in6);
> +		break;
> +	case AF_INET6:
> +		sin6 =3D (struct sockaddr_in6 *)&data->gd_addr;
> +		ipv6_addr_copy(&in6, &sin6->sin6_addr);
> +		break;
> +	default:
> 		goto out;
> -	sin =3D (struct sockaddr_in *)&data->gd_addr;
> +	}
> +
> 	if (data->gd_maxlen > NFS3_FHSIZE)
> 		data->gd_maxlen =3D NFS3_FHSIZE;
>
> @@ -249,8 +260,6 @@
>
> 	exp_readlock();
>
> -	ipv6_addr_set_v4mapped(sin->sin_addr.s_addr, &in6);
> -
> 	clp =3D auth_unix_lookup(&in6);
> 	if (!clp)
> 		err =3D -EPERM;
> @@ -269,6 +278,7 @@
> {
> 	struct nfsctl_fdparm *data;
> 	struct sockaddr_in *sin;
> +	struct sockaddr_in6 *sin6;
> 	struct auth_domain *clp;
> 	int err =3D 0;
> 	struct knfsd_fh fh;
> @@ -279,20 +289,31 @@
> 		return -EINVAL;
> 	data =3D (struct nfsctl_fdparm*)buf;
> 	err =3D -EPROTONOSUPPORT;
> -	if (data->gd_addr.sa_family !=3D AF_INET)
> +	if (data->gd_addr.sa_family !=3D AF_INET &&
> +	    data->gd_addr.sa_family !=3D AF_INET6)
> 		goto out;
> +
> 	err =3D -EINVAL;
> 	if (data->gd_version < 2 || data->gd_version > NFSSVC_MAXVERS)
> 		goto out;
>
> 	res =3D buf;
> -	sin =3D (struct sockaddr_in *)&data->gd_addr;
> 	exp_readlock();
>
> -	ipv6_addr_set_v4mapped(sin->sin_addr.s_addr, &in6);
> +	switch (data->gd_addr.sa_family) {
> +	case AF_INET:
> +		sin =3D (struct sockaddr_in *)&data->gd_addr;
> +		ipv6_addr_set_v4mapped(sin->sin_addr.s_addr, &in6);
> +		break;
> +	case AF_INET6:
> +		sin6 =3D (struct sockaddr_in6 *)&data->gd_addr;
> +		ipv6_addr_copy(&in6, &sin6->sin6_addr);
> +		break;
> +	default:
> +		goto out;
> +	}
>
> -	clp =3D auth_unix_lookup(&in6);
> -	if (!clp)
> +	if (!(clp =3D auth_unix_lookup(&in6)))
> 		err =3D -EPERM;
> 	else {
> 		err =3D exp_rootfh(clp, data->gd_path, &fh, NFS_FHSIZE);
> @@ -305,7 +326,7 @@
> 		memcpy(res, &fh.fh_base, fh.fh_size);
> 		err =3D NFS_FHSIZE;
> 	}
> - out:
> +out:
> 	return err;
> }

--=20
Chuck Lever
chuck[dot]lever[at]oracle[dot]com
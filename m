Return-Path: <SRS0=cCtV=Q2=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.2 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,UNPARSEABLE_RELAY autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id E142CC4360F
	for <linux-nfs@archiver.kernel.org>; Tue, 19 Feb 2019 19:43:01 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 964A12146F
	for <linux-nfs@archiver.kernel.org>; Tue, 19 Feb 2019 19:43:01 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=oracle.com header.i=@oracle.com header.b="eQ1CMmlY"
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1726089AbfBSTnA (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Tue, 19 Feb 2019 14:43:00 -0500
Received: from userp2120.oracle.com ([156.151.31.85]:46986 "EHLO
        userp2120.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1725963AbfBSTm7 (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Tue, 19 Feb 2019 14:42:59 -0500
Received: from pps.filterd (userp2120.oracle.com [127.0.0.1])
        by userp2120.oracle.com (8.16.0.27/8.16.0.27) with SMTP id x1JJfPZh070147;
        Tue, 19 Feb 2019 19:42:51 GMT
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=oracle.com; h=content-type :
 mime-version : subject : from : in-reply-to : date : cc :
 content-transfer-encoding : message-id : references : to;
 s=corp-2018-07-02; bh=kiHdbmXGAM04IzklaOafFsA//v7dpgx+tcj97ut/5Y4=;
 b=eQ1CMmlY7pX3c4abM/MePeP1eZYVqqCitFJMOlyGxTu+tvV96vnGujegpr2tbc86FAFs
 Wju5YqHE7SskGaaTwprbD05P1OvakPtTRg0M+RbLdgUnwPet+2Glg5ocRNYV3OdHNPqO
 N5eN/5ay3R6cog8xay0KKPB+VOMGKUByyxbrYmISagP0dqQjJn4Qs9NdF0wWgxzXQ043
 dX/hKTHqUIYSwE9n4MfLHK51NIngRMqsSMp73vkLtut8OcasIUZIJf6n/5+/ySAYVIm/
 yPMHWXULo1jKmysGgy5DsIjzKjzVXV0TTja7lC+OOAgIUMoJ0+dMzLKgO/TMfPSsHP1B Uw== 
Received: from aserv0022.oracle.com (aserv0022.oracle.com [141.146.126.234])
        by userp2120.oracle.com with ESMTP id 2qpb5rd9q8-1
        (version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
        Tue, 19 Feb 2019 19:42:51 +0000
Received: from userv0122.oracle.com (userv0122.oracle.com [156.151.31.75])
        by aserv0022.oracle.com (8.14.4/8.14.4) with ESMTP id x1JJgnGW007708
        (version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
        Tue, 19 Feb 2019 19:42:49 GMT
Received: from abhmp0009.oracle.com (abhmp0009.oracle.com [141.146.116.15])
        by userv0122.oracle.com (8.14.4/8.14.4) with ESMTP id x1JJgno1016463;
        Tue, 19 Feb 2019 19:42:49 GMT
Received: from anon-dhcp-171.1015granger.net (/68.61.232.219)
        by default (Oracle Beehive Gateway v4.0)
        with ESMTP ; Tue, 19 Feb 2019 11:42:48 -0800
Content-Type: text/plain;
        charset=us-ascii
Mime-Version: 1.0 (Mac OS X Mail 12.2 \(3445.102.3\))
Subject: Re: [PATCH v2] nfs-utils: fix addrinfo usage with musl-1.1.21
From:   Chuck Lever <chuck.lever@oracle.com>
In-Reply-To: <20190219200333.4782a656@onion.lan>
Date:   Tue, 19 Feb 2019 14:42:47 -0500
Cc:     Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Content-Transfer-Encoding: quoted-printable
Message-Id: <09637295-A46D-4C29-BF0B-B205206BF993@oracle.com>
References: <20190219200333.4782a656@onion.lan>
To:     Peter Wagner <tripolar@gmx.at>, Steve Dickson <SteveD@RedHat.com>
X-Mailer: Apple Mail (2.3445.102.3)
X-Proofpoint-Virus-Version: vendor=nai engine=5900 definitions=9172 signatures=668683
X-Proofpoint-Spam-Details: rule=notspam policy=default score=0 priorityscore=1501 malwarescore=0
 suspectscore=2 phishscore=0 bulkscore=0 spamscore=0 clxscore=1015
 lowpriorityscore=0 mlxscore=0 impostorscore=0 mlxlogscore=999 adultscore=0
 classifier=spam adjust=0 reason=mlx scancount=1 engine=8.0.1-1810050000
 definitions=main-1902190138
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org



> On Feb 19, 2019, at 2:03 PM, Peter Wagner <tripolar@gmx.at> wrote:
>=20
> =46rom 877184f733d13d7db0ec9265a53ede9c30d03ba4 Mon Sep 17 00:00:00 =
2001
> From: Peter Wagner <tripolar@gmx.at>
> Date: Tue, 19 Feb 2019 20:00:22 +0100
> Subject: [PATCH] [PATCH] define and use wrapper function =
nfs_freeaddrinfo to
> handle freeaddrinfo versions that don't tolerate NULL pointers
>=20
> Signed-off-by: Peter Wagner <tripolar@gmx.at>

Reviewed-by: Chuck Lever <chuck.lever@oracle.com>


> ---
> support/export/client.c       |  6 +++---
> support/export/hostname.c     |  4 ++--
> support/include/exportfs.h    | 11 +++++++++++
> support/nfs/getport.c         |  7 ++++---
> support/nfs/svc_create.c      |  8 +++++---
> support/nfsidmap/umich_ldap.c |  2 +-
> tests/nsm_client/nsm_client.c |  2 +-
> utils/exportfs/exportfs.c     | 10 +++++-----
> utils/gssd/gssd.c             |  4 ++--
> utils/gssd/krb5_util.c        |  2 +-
> utils/mount/network.c         |  7 ++++---
> utils/mount/stropts.c         |  3 ++-
> utils/mountd/auth.c           |  2 +-
> utils/mountd/cache.c          | 10 +++++-----
> utils/mountd/mountd.c         |  4 ++--
> utils/mountd/rmtab.c          |  2 +-
> utils/nfsd/nfssvc.c           |  4 ++--
> utils/statd/hostname.c        | 11 ++++++-----
> utils/statd/sm-notify.c       | 14 +++++++-------
> 19 files changed, 65 insertions(+), 48 deletions(-)
>=20
> diff --git a/support/export/client.c b/support/export/client.c
> index baf59c8..a1fba01 100644
> --- a/support/export/client.c
> +++ b/support/export/client.c
> @@ -210,7 +210,7 @@ init_subnetwork(nfs_client *clp)
> 	set_addrlist(clp, 0, ai->ai_addr);
> 	family =3D ai->ai_addr->sa_family;
>=20
> -	freeaddrinfo(ai);
> +	nfs_freeaddrinfo(ai);
>=20
> 	switch (family) {
> 	case AF_INET:
> @@ -309,7 +309,7 @@ client_lookup(char *hname, int canonical)
> 		init_addrlist(clp, ai);
>=20
> out:
> -	freeaddrinfo(ai);
> +	nfs_freeaddrinfo(ai);
> 	return clp;
> }
>=20
> @@ -674,7 +674,7 @@ check_netgroup(const nfs_client *clp, const struct =
addrinfo *ai)
> 	tmp =3D host_pton(hname);
> 	if (tmp !=3D NULL) {
> 		char *cname =3D host_canonname(tmp->ai_addr);
> -		freeaddrinfo(tmp);
> +		nfs_freeaddrinfo(tmp);
>=20
> 		/* The resulting FQDN may be in our netgroup. */
> 		if (cname !=3D NULL) {
> diff --git a/support/export/hostname.c b/support/export/hostname.c
> index 96c5449..be4d7f6 100644
> --- a/support/export/hostname.c
> +++ b/support/export/hostname.c
> @@ -130,7 +130,7 @@ host_pton(const char *paddr)
> 		if (!inet4 && ai->ai_addr->sa_family =3D=3D AF_INET) {
> 			xlog(D_GENERAL, "%s: failed to convert %s",
> 					__func__, paddr);
> -			freeaddrinfo(ai);
> +			nfs_freeaddrinfo(ai);
> 			break;
> 		}
> 		return ai;
> @@ -292,7 +292,7 @@ host_reliable_addrinfo(const struct sockaddr *sap)
> 		if (nfs_compare_sockaddr(a->ai_addr, sap))
> 			break;
>=20
> -	freeaddrinfo(ai);
> +	nfs_freeaddrinfo(ai);
> 	ai =3D NULL;
> 	if (!a)
> 		goto out;
> diff --git a/support/include/exportfs.h b/support/include/exportfs.h
> index 4e0d9d1..b81f963 100644
> --- a/support/include/exportfs.h
> +++ b/support/include/exportfs.h
> @@ -47,6 +47,17 @@ typedef struct mclient {
> 	int			m_count;
> } nfs_client;
>=20
> +/*
> + * Some versions of freeaddrinfo(3) do not tolerate being
> + * passed a NULL pointer.
> + */
> +static inline void nfs_freeaddrinfo(struct addrinfo *ai)
> +{
> +	if (ai) {
> +		freeaddrinfo(ai);
> +	}
> +}
> +
> static inline const struct sockaddr *
> get_addrlist(const nfs_client *clp, const int i)
> {
> diff --git a/support/nfs/getport.c b/support/nfs/getport.c
> index 081594c..26ec85e 100644
> --- a/support/nfs/getport.c
> +++ b/support/nfs/getport.c
> @@ -47,6 +47,7 @@
>=20
> #include "sockaddr.h"
> #include "nfsrpc.h"
> +#include "exportfs.h"
>=20
> /*
>  * Try a local socket first to access the local rpcbind daemon
> @@ -109,7 +110,7 @@ static int nfs_gp_loopback_address(struct sockaddr =
*sap, socklen_t *salen)
> 		ret =3D 1;
> 	}
>=20
> -	freeaddrinfo(gai_results);
> +	nfs_freeaddrinfo(gai_results);
> 	return ret;
> }
>=20
> @@ -134,8 +135,8 @@ static in_port_t nfs_gp_getservbyname(const char =
*service,
>=20
> 	sin =3D (const struct sockaddr_in *)gai_results->ai_addr;
> 	port =3D sin->sin_port;
> -=09
> -	freeaddrinfo(gai_results);
> +
> +	nfs_freeaddrinfo(gai_results);
> 	return port;
> }
>=20
> diff --git a/support/nfs/svc_create.c b/support/nfs/svc_create.c
> index ef7ff05..d0b747b 100644
> --- a/support/nfs/svc_create.c
> +++ b/support/nfs/svc_create.c
> @@ -39,6 +39,8 @@
> #include <rpc/rpc.h>
> #include <rpc/svc.h>
>=20
> +#include "exportfs.h"
> +
> #ifdef HAVE_TCP_WRAPPER
> #include "tcpwrapper.h"
> #endif
> @@ -273,7 +275,7 @@ svc_create_nconf_rand_port(const char *name, const =
rpcprog_t program,
> 	bindaddr.qlen =3D SOMAXCONN;
>=20
> 	xprt =3D svc_tli_create(RPC_ANYFD, nconf, &bindaddr, 0, 0);
> -	freeaddrinfo(ai);
> +	nfs_freeaddrinfo(ai);
> 	if (xprt =3D=3D NULL) {
> 		xlog(L_ERROR, "Failed to create listener xprt "
> 			"(%s, %u, %s)", name, version, nconf->nc_netid);
> @@ -364,11 +366,11 @@ svc_create_nconf_fixed_port(const char *name, =
const rpcprog_t program,
>=20
> 	svc_create_cache_xprt(xprt);
>=20
> -	freeaddrinfo(ai);
> +	nfs_freeaddrinfo(ai);
> 	return 1;
>=20
> out_free:
> -	freeaddrinfo(ai);
> +	nfs_freeaddrinfo(ai);
> 	return 0;
> }
>=20
> diff --git a/support/nfsidmap/umich_ldap.c =
b/support/nfsidmap/umich_ldap.c
> index b661110..b8ee184 100644
> --- a/support/nfsidmap/umich_ldap.c
> +++ b/support/nfsidmap/umich_ldap.c
> @@ -1089,7 +1089,7 @@ get_canonical_hostname(const char *inname)
> 	return_name =3D strdup (tmphost);
>=20
> out_free:
> -	freeaddrinfo(ap);
> +	nfs_freeaddrinfo(ap);
> out_err:
> 	return return_name;
> }
> diff --git a/tests/nsm_client/nsm_client.c =
b/tests/nsm_client/nsm_client.c
> index 0fa3422..8dc0591 100644
> --- a/tests/nsm_client/nsm_client.c
> +++ b/tests/nsm_client/nsm_client.c
> @@ -243,7 +243,7 @@ nsm_client_get_rpcclient(const char *node)
> 		printf("RPC client creation failed\n");
> 	}
> out:
> -	freeaddrinfo(ai);
> +	nfs_freeaddrinfo(ai);
> 	return client;
> }
>=20
> diff --git a/utils/exportfs/exportfs.c b/utils/exportfs/exportfs.c
> index cd3c979..333eadc 100644
> --- a/utils/exportfs/exportfs.c
> +++ b/utils/exportfs/exportfs.c
> @@ -282,7 +282,7 @@ exportfs_parsed(char *hname, char *path, char =
*options, int verbose)
> 	validate_export(exp);
>=20
> out:
> -	freeaddrinfo(ai);
> +	nfs_freeaddrinfo(ai);
> }
>=20
> static int exportfs_generic(char *arg, char *options, int verbose)
> @@ -395,7 +395,7 @@ unexportfs_parsed(char *hname, char *path, int =
verbose)
> 	if (!success)
> 		xlog(L_ERROR, "Could not find '%s:%s' to unexport.", =
hname, path);
>=20
> -	freeaddrinfo(ai);
> +	nfs_freeaddrinfo(ai);
> }
>=20
> static int unexportfs_generic(char *arg, int verbose)
> @@ -588,7 +588,7 @@ address_list(const char *hostname)
> 	if (ai !=3D NULL) {
> 		/* @hostname was a presentation address */
> 		cname =3D host_canonname(ai->ai_addr);
> -		freeaddrinfo(ai);
> +		nfs_freeaddrinfo(ai);
> 		if (cname !=3D NULL)
> 			goto out;
> 	}
> @@ -639,8 +639,8 @@ matchhostname(const char *hostname1, const char =
*hostname2)
> 			}
>=20
> out:
> -	freeaddrinfo(results1);
> -	freeaddrinfo(results2);
> +	nfs_freeaddrinfo(results1);
> +	nfs_freeaddrinfo(results2);
> 	return result;
> }
>=20
> diff --git a/utils/gssd/gssd.c b/utils/gssd/gssd.c
> index 2e92f28..7eeb05f 100644
> --- a/utils/gssd/gssd.c
> +++ b/utils/gssd/gssd.c
> @@ -172,14 +172,14 @@ gssd_addrstr_to_sockaddr(struct sockaddr *sa, =
const char *node, const char *port
> 		if (sin6->sin6_scope_id) {
> 			printerr(0, "ERROR: address %s has non-zero "
> 				    "sin6_scope_id!\n", node);
> -			freeaddrinfo(res);
> +			nfs_freeaddrinfo(res);
> 			return false;
> 		}
> 	}
> #endif /* IPV6_SUPPORTED */
>=20
> 	memcpy(sa, res->ai_addr, res->ai_addrlen);
> -	freeaddrinfo(res);
> +	nfs_freeaddrinfo(res);
> 	return true;
> }
>=20
> diff --git a/utils/gssd/krb5_util.c b/utils/gssd/krb5_util.c
> index eba1aac..adbde93 100644
> --- a/utils/gssd/krb5_util.c
> +++ b/utils/gssd/krb5_util.c
> @@ -587,7 +587,7 @@ get_full_hostname(const char *inhost, char =
*outhost, int outhostlen)
> 		goto out;
> 	}
> 	strncpy(outhost, addrs->ai_canonname, outhostlen);
> -	freeaddrinfo(addrs);
> +	nfs_freeaddrinfo(addrs);
> 	for (c =3D outhost; *c !=3D '\0'; c++)
> 	    *c =3D tolower(*c);
>=20
> diff --git a/utils/mount/network.c b/utils/mount/network.c
> index 356f663..fcb0b9f 100644
> --- a/utils/mount/network.c
> +++ b/utils/mount/network.c
> @@ -53,6 +53,7 @@
> #include <net/if.h>
> #include <ifaddrs.h>
>=20
> +#include "exportfs.h"
> #include "sockaddr.h"
> #include "xcommon.h"
> #include "mount.h"
> @@ -250,7 +251,7 @@ int nfs_lookup(const char *hostname, const =
sa_family_t family,
> 		break;
> 	}
>=20
> -	freeaddrinfo(gai_results);
> +	nfs_freeaddrinfo(gai_results);
> 	return ret;
> }
>=20
> @@ -307,7 +308,7 @@ int nfs_string_to_sockaddr(const char *address, =
struct sockaddr *sap,
> 			}
> 			break;
> 		}
> -		freeaddrinfo(gai_results);
> +		nfs_freeaddrinfo(gai_results);
> 	}
>=20
> 	return ret;
> @@ -1180,7 +1181,7 @@ static int nfs_ca_gai(const struct sockaddr =
*sap,
> 	*buflen =3D gai_results->ai_addrlen;
> 	memcpy(buf, gai_results->ai_addr, *buflen);
>=20
> -	freeaddrinfo(gai_results);
> +	nfs_freeaddrinfo(gai_results);
>=20
> 	return 1;
> }
> diff --git a/utils/mount/stropts.c b/utils/mount/stropts.c
> index 0a25b1f..b170552 100644
> --- a/utils/mount/stropts.c
> +++ b/utils/mount/stropts.c
> @@ -35,6 +35,7 @@
> #include <netinet/in.h>
> #include <arpa/inet.h>
>=20
> +#include "exportfs.h"
> #include "sockaddr.h"
> #include "xcommon.h"
> #include "mount.h"
> @@ -1268,7 +1269,7 @@ int nfsmount_string(const char *spec, const char =
*node, char *type,
> 	} else
> 		nfs_error(_("%s: internal option parsing error"), =
progname);
>=20
> -	freeaddrinfo(mi.address);
> +	nfs_freeaddrinfo(mi.address);
> 	free(mi.hostname);
> 	return retval;
> }
> diff --git a/utils/mountd/auth.c b/utils/mountd/auth.c
> index cb4848c..67627f7 100644
> --- a/utils/mountd/auth.c
> +++ b/utils/mountd/auth.c
> @@ -297,7 +297,7 @@ auth_authenticate(const char *what, const struct =
sockaddr *caller,
> 		     what, buf, nfs_get_port(caller), path, epath, =
error);
> 	}
>=20
> -	freeaddrinfo(ai);
> +	nfs_freeaddrinfo(ai);
> 	return exp;
> }
>=20
> diff --git a/utils/mountd/cache.c b/utils/mountd/cache.c
> index 7e8d403..2cb370f 100644
> --- a/utils/mountd/cache.c
> +++ b/utils/mountd/cache.c
> @@ -113,7 +113,7 @@ static void auth_unix_ip(int f)
> 		ai =3D client_resolve(tmp->ai_addr);
> 		if (ai) {
> 			client =3D client_compose(ai);
> -			freeaddrinfo(ai);
> +			nfs_freeaddrinfo(ai);
> 		}
> 	}
> 	bp =3D buf; blen =3D sizeof(buf);
> @@ -133,7 +133,7 @@ static void auth_unix_ip(int f)
> 	xlog(D_CALL, "auth_unix_ip: client %p '%s'", client, =
client?client: "DEFAULT");
>=20
> 	free(client);
> -	freeaddrinfo(tmp);
> +	nfs_freeaddrinfo(tmp);
>=20
> }
>=20
> @@ -667,7 +667,7 @@ static struct addrinfo *lookup_client_addr(char =
*dom)
> 	if (tmp =3D=3D NULL)
> 		return NULL;
> 	ret =3D client_resolve(tmp->ai_addr);
> -	freeaddrinfo(tmp);
> +	nfs_freeaddrinfo(tmp);
> 	return ret;
> }
>=20
> @@ -834,7 +834,7 @@ static void nfsd_fh(int f)
> out:
> 	if (found_path)
> 		free(found_path);
> -	freeaddrinfo(ai);
> +	nfs_freeaddrinfo(ai);
> 	free(dom);
> 	xlog(D_CALL, "nfsd_fh: found %p path %s", found, found ? =
found->e_path : NULL);
> }
> @@ -1355,7 +1355,7 @@ static void nfsd_export(int f)
> 	xlog(D_CALL, "nfsd_export: found %p path %s", found, path ? path =
: NULL);
> 	if (dom) free(dom);
> 	if (path) free(path);
> -	freeaddrinfo(ai);
> +	nfs_freeaddrinfo(ai);
> }
>=20
>=20
> diff --git a/utils/mountd/mountd.c b/utils/mountd/mountd.c
> index 086c39b..fb7bba4 100644
> --- a/utils/mountd/mountd.c
> +++ b/utils/mountd/mountd.c
> @@ -578,10 +578,10 @@ static void prune_clients(nfs_export *exp, =
struct exportnode *e)
> 				*cp =3D c->gr_next;
> 				xfree(c->gr_name);
> 				xfree(c);
> -				freeaddrinfo(ai);
> +				nfs_freeaddrinfo(ai);
> 				continue;
> 			}
> -			freeaddrinfo(ai);
> +			nfs_freeaddrinfo(ai);
> 		}
> 		cp =3D &(c->gr_next);
> 	}
> diff --git a/utils/mountd/rmtab.c b/utils/mountd/rmtab.c
> index 3ae0dbb..c896243 100644
> --- a/utils/mountd/rmtab.c
> +++ b/utils/mountd/rmtab.c
> @@ -226,7 +226,7 @@ mountlist_list(void)
> 				ai =3D host_pton(rep->r_client);
> 				if (ai !=3D NULL) {
> 					m->ml_hostname =3D =
host_canonname(ai->ai_addr);
> -					freeaddrinfo(ai);
> +					nfs_freeaddrinfo(ai);
> 				}
> 			}
> 			if (m->ml_hostname =3D=3D NULL)
> diff --git a/utils/nfsd/nfssvc.c b/utils/nfsd/nfssvc.c
> index 1e6ffd6..47b1882 100644
> --- a/utils/nfsd/nfssvc.c
> +++ b/utils/nfsd/nfssvc.c
> @@ -25,6 +25,7 @@
> #include "nfslib.h"
> #include "xlog.h"
> #include "nfssvc.h"
> +#include "exportfs.h"
> #include "../mount/version.h"
>=20
> #ifndef NFSD_FS_DIR
> @@ -246,8 +247,7 @@ error:
> 		close(fd);
> 	if (sockfd >=3D 0)
> 		close(sockfd);
> -	if (addrhead)
> -		freeaddrinfo(addrhead);
> +	nfs_freeaddrinfo(addrhead);
> 	return (bounded ? 0 : rc);
> }
>=20
> diff --git a/utils/statd/hostname.c b/utils/statd/hostname.c
> index 8cccdb8..c9e22d3 100644
> --- a/utils/statd/hostname.c
> +++ b/utils/statd/hostname.c
> @@ -35,6 +35,7 @@
> #include <netdb.h>
> #include <arpa/inet.h>
>=20
> +#include "exportfs.h"
> #include "sockaddr.h"
> #include "statd.h"
> #include "xlog.h"
> @@ -203,7 +204,7 @@ statd_canonical_name(const char *hostname)
> 		_Bool result;
> 		result =3D get_nameinfo(ai->ai_addr, ai->ai_addrlen,
> 					buf, (socklen_t)sizeof(buf));
> -		freeaddrinfo(ai);
> +		nfs_freeaddrinfo(ai);
> 		if (!result || buf[0] =3D=3D '\0')
> 			/* OK to use presentation address,
> 			 * if no reverse map exists */
> @@ -217,7 +218,7 @@ statd_canonical_name(const char *hostname)
> 	if (ai =3D=3D NULL)
> 		return NULL;
> 	strcpy(buf, ai->ai_canonname);
> -	freeaddrinfo(ai);
> +	nfs_freeaddrinfo(ai);
>=20
> 	return strdup(buf);
> }
> @@ -253,7 +254,7 @@ statd_canonical_list(const char *hostname)
> 		_Bool result;
> 		result =3D get_nameinfo(ai->ai_addr, ai->ai_addrlen,
> 					buf, (socklen_t)sizeof(buf));
> -		freeaddrinfo(ai);
> +		nfs_freeaddrinfo(ai);
> 		if (result)
> 			goto out;
> 	}
> @@ -308,8 +309,8 @@ statd_matchhostname(const char *hostname1, const =
char *hostname2)
> 			}
>=20
> out:
> -	freeaddrinfo(results2);
> -	freeaddrinfo(results1);
> +	nfs_freeaddrinfo(results2);
> +	nfs_freeaddrinfo(results1);
>=20
> 	xlog(D_CALL, "%s: hostnames %s and %s %s", __func__,
> 			hostname1, hostname2,
> diff --git a/utils/statd/sm-notify.c b/utils/statd/sm-notify.c
> index 29dad38..05d72a3 100644
> --- a/utils/statd/sm-notify.c
> +++ b/utils/statd/sm-notify.c
> @@ -37,6 +37,7 @@
> #include "xlog.h"
> #include "nsm.h"
> #include "nfsrpc.h"
> +#include "exportfs.h"
>=20
> /* glibc before 2.3.4 */
> #ifndef AI_NUMERICSERV
> @@ -179,7 +180,7 @@ smn_verify_my_name(const char *name)
> 	case 0:
> 		/* @name was a presentation address */
> 		retval =3D smn_get_hostname(ai->ai_addr, ai->ai_addrlen, =
name);
> -		freeaddrinfo(ai);
> +		nfs_freeaddrinfo(ai);
> 		if (retval =3D=3D NULL)
> 			return NULL;
> 		break;
> @@ -253,8 +254,7 @@ static void smn_forget_host(struct nsm_host *host)
> 	free((void *)host->my_name);
> 	free((void *)host->mon_name);
> 	free(host->name);
> -	if (host->ai)
> -		freeaddrinfo(host->ai);
> +	nfs_freeaddrinfo(host->ai);
>=20
> 	free(host);
> }
> @@ -430,7 +430,7 @@ retry:
> 	if (srcport) {
> 		if (bind(sock, ai->ai_addr, ai->ai_addrlen) =3D=3D -1) {
> 			xlog(L_ERROR, "Failed to bind RPC socket: %m");
> -			freeaddrinfo(ai);
> +			nfs_freeaddrinfo(ai);
> 			(void)close(sock);
> 			return -1;
> 		}
> @@ -440,7 +440,7 @@ retry:
> 		if (smn_bindresvport(sock, ai->ai_addr) =3D=3D -1) {
> 			xlog(L_ERROR,
> 				"bindresvport on RPC socket failed: =
%m");
> -			freeaddrinfo(ai);
> +			nfs_freeaddrinfo(ai);
> 			(void)close(sock);
> 			return -1;
> 		}
> @@ -449,13 +449,13 @@ retry:
> 		se =3D getservbyport((int)nfs_get_port(ai->ai_addr), =
"udp");
> 		if (se !=3D NULL && retry_cnt < 100) {
> 			retry_cnt++;
> -			freeaddrinfo(ai);
> +			nfs_freeaddrinfo(ai);
> 			(void)close(sock);
> 			goto retry;
> 		}
> 	}
>=20
> -	freeaddrinfo(ai);
> +	nfs_freeaddrinfo(ai);
> 	return sock;
> }
>=20
> --=20
> 2.20.1
>=20

--
Chuck Lever




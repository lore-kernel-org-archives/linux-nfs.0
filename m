Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:63704 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753941AbaCMOgA (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 13 Mar 2014 10:36:00 -0400
Message-ID: <5321C24D.8030101@RedHat.com>
Date: Thu, 13 Mar 2014 10:35:57 -0400
From: Steve Dickson <SteveD@redhat.com>
MIME-Version: 1.0
To: NeilBrown <neilb@suse.de>
CC: Linux NFS Mailing list <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH - v3] mount.nfs: Fix fallback from tcp to udp
References: <1394551050-14571-1-git-send-email-steved@redhat.com>
In-Reply-To: <1394551050-14571-1-git-send-email-steved@redhat.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>



On 03/11/2014 11:17 AM, Steve Dickson wrote:
> From: NeilBrown <neilb@suse.de>
> 
> Protocol negotiation in mount.nfs does not correctly negotiate with a
> server which only supports NFSv3 and UDP.
> 
> When mount.nfs attempts an NFSv4 mount and fails with ECONNREFUSED
> it does not fall back to NFSv3, as this is not recognised as a
> "does not support NFSv4" error.
> However ECONNREFUSED is a clear indication that the server doesn't
> support TCP, and ipso facto does not support NFSv4.
> So ECONNREFUSED should trigger a fallback from v4 to v2/3.
> 
> However ECONNREFUSED may simply indicate that NFSv4 isn't supported
> *yet*.  i.e. the server is still booting and isn't responding to NFS
> requests yet.  So if we subsequently find that NFSv3 is supported, we
> need to check with the server to confirm that NFSv4 really isn't
> supported.
> 
> If server reports that v4 is not supported after reporting that v3
> is, we can safely use v4.  If it reports that v4 is supported, we need
> to retry v4.
> 
> Signed-off-by: Steve Dickson <steved@redhat.com>
> Reported-by: Carsten Ziepke <kieltux@gmail.com>
Committed...

steved.
> ---
>  utils/mount/network.c | 34 ++++++++++++++++++++++++++--------
>  utils/mount/network.h |  2 +-
>  utils/mount/stropts.c | 32 +++++++++++++++++++++++---------
>  3 files changed, 50 insertions(+), 18 deletions(-)
> 
> diff --git a/utils/mount/network.c b/utils/mount/network.c
> index 2fdd2c0..4f8c15c 100644
> --- a/utils/mount/network.c
> +++ b/utils/mount/network.c
> @@ -611,18 +611,33 @@ out_ok:
>   * returned; rpccreateerr.cf_stat is set to reflect the nature of the error.
>   */
>  static int nfs_probe_nfsport(const struct sockaddr *sap, const socklen_t salen,
> -				struct pmap *pmap)
> +			     struct pmap *pmap, int checkv4)
>  {
>  	if (pmap->pm_vers && pmap->pm_prot && pmap->pm_port)
>  		return 1;
>  
>  	if (nfs_mount_data_version >= 4) {
>  		const unsigned int *probe_proto;
> +		int ret;
> +		struct sockaddr_storage save_sa;
>  
>  		probe_proto = nfs_default_proto();
> -
> -		return nfs_probe_port(sap, salen, pmap,
> -					probe_nfs3_only, probe_proto);
> +		memcpy(&save_sa, sap, salen);
> +
> +		ret = nfs_probe_port(sap, salen, pmap,
> +				     probe_nfs3_only, probe_proto);
> +		if (!ret || !checkv4 || probe_proto != probe_tcp_first)
> +			return ret;
> +
> +		nfs_set_port((struct sockaddr *)&save_sa, NFS_PORT);
> +		ret =  nfs_rpc_ping((struct sockaddr *)&save_sa, salen, 
> +			NFS_PROGRAM, 4, IPPROTO_TCP, NULL);
> +		if (ret) {
> +			rpc_createerr.cf_stat = RPC_FAILED;
> +			rpc_createerr.cf_error.re_errno = EAGAIN;
> +			return 0;
> +		}
> +		return 1;
>  	} else
>  		return nfs_probe_port(sap, salen, pmap,
>  					probe_nfs2_only, probe_udp_only);
> @@ -671,7 +686,7 @@ static int nfs_probe_version_fixed(const struct sockaddr *mnt_saddr,
>  			const socklen_t nfs_salen,
>  			struct pmap *nfs_pmap)
>  {
> -	if (!nfs_probe_nfsport(nfs_saddr, nfs_salen, nfs_pmap))
> +	if (!nfs_probe_nfsport(nfs_saddr, nfs_salen, nfs_pmap, 0))
>  		return 0;
>  	return nfs_probe_mntport(mnt_saddr, mnt_salen, mnt_pmap);
>  }
> @@ -686,6 +701,8 @@ static int nfs_probe_version_fixed(const struct sockaddr *mnt_saddr,
>   * @nfs_salen:	length of NFS server's address
>   * @nfs_pmap:	IN: partially filled-in NFS RPC service tuple;
>   *		OUT: fully filled-in NFS RPC service tuple
> + * @checkv4:	Flag indicating that if v3 is available we must also
> + *		check v4, and if that is available, set re_errno to EAGAIN.
>   *
>   * Returns 1 and fills in both @pmap structs if the requested service
>   * ports are unambiguous and pingable.  Otherwise zero is returned;
> @@ -696,7 +713,8 @@ int nfs_probe_bothports(const struct sockaddr *mnt_saddr,
>  			struct pmap *mnt_pmap,
>  			const struct sockaddr *nfs_saddr,
>  			const socklen_t nfs_salen,
> -			struct pmap *nfs_pmap)
> +			struct pmap *nfs_pmap,
> +			int checkv4)
>  {
>  	struct pmap save_nfs, save_mnt;
>  	const unsigned long *probe_vers;
> @@ -717,7 +735,7 @@ int nfs_probe_bothports(const struct sockaddr *mnt_saddr,
>  
>  	for (; *probe_vers; probe_vers++) {
>  		nfs_pmap->pm_vers = mntvers_to_nfs(*probe_vers);
> -		if (nfs_probe_nfsport(nfs_saddr, nfs_salen, nfs_pmap) != 0) {
> +		if (nfs_probe_nfsport(nfs_saddr, nfs_salen, nfs_pmap, checkv4) != 0) {
>  			mnt_pmap->pm_vers = *probe_vers;
>  			if (nfs_probe_mntport(mnt_saddr, mnt_salen, mnt_pmap) != 0)
>  				return 1;
> @@ -757,7 +775,7 @@ int probe_bothports(clnt_addr_t *mnt_server, clnt_addr_t *nfs_server)
>  	return nfs_probe_bothports(mnt_addr, sizeof(mnt_server->saddr),
>  					&mnt_server->pmap,
>  					nfs_addr, sizeof(nfs_server->saddr),
> -					&nfs_server->pmap);
> +					&nfs_server->pmap, 0);
>  }
>  
>  /**
> diff --git a/utils/mount/network.h b/utils/mount/network.h
> index 9c75856..d7636d7 100644
> --- a/utils/mount/network.h
> +++ b/utils/mount/network.h
> @@ -42,7 +42,7 @@ static const struct timeval RETRY_TIMEOUT = { 3, 0 };
>  int probe_bothports(clnt_addr_t *, clnt_addr_t *);
>  int nfs_probe_bothports(const struct sockaddr *, const socklen_t,
>  			struct pmap *, const struct sockaddr *,
> -			const socklen_t, struct pmap *);
> +			const socklen_t, struct pmap *, int);
>  int nfs_gethostbyname(const char *, struct sockaddr_in *);
>  int nfs_lookup(const char *hostname, const sa_family_t family,
>  		struct sockaddr *sap, socklen_t *salen);
> diff --git a/utils/mount/stropts.c b/utils/mount/stropts.c
> index a642394..2d72d5b 100644
> --- a/utils/mount/stropts.c
> +++ b/utils/mount/stropts.c
> @@ -484,7 +484,7 @@ static int nfs_construct_new_options(struct mount_options *options,
>   * FALSE is returned if some failure occurred.
>   */
>  static int
> -nfs_rewrite_pmap_mount_options(struct mount_options *options)
> +nfs_rewrite_pmap_mount_options(struct mount_options *options, int checkv4)
>  {
>  	union nfs_sockaddr nfs_address;
>  	struct sockaddr *nfs_saddr = &nfs_address.sa;
> @@ -534,7 +534,7 @@ nfs_rewrite_pmap_mount_options(struct mount_options *options)
>  	 * negotiate.  Bail now if we can't contact it.
>  	 */
>  	if (!nfs_probe_bothports(mnt_saddr, mnt_salen, &mnt_pmap,
> -				 nfs_saddr, nfs_salen, &nfs_pmap)) {
> +				 nfs_saddr, nfs_salen, &nfs_pmap, checkv4)) {
>  		errno = ESPIPE;
>  		if (rpc_createerr.cf_stat == RPC_PROGNOTREGISTERED)
>  			errno = EOPNOTSUPP;
> @@ -595,7 +595,8 @@ static int nfs_sys_mount(struct nfsmount_info *mi, struct mount_options *opts)
>  }
>  
>  static int nfs_do_mount_v3v2(struct nfsmount_info *mi,
> -		struct sockaddr *sap, socklen_t salen)
> +			     struct sockaddr *sap, socklen_t salen,
> +			     int checkv4)
>  {
>  	struct mount_options *options = po_dup(mi->options);
>  	int result = 0;
> @@ -637,7 +638,7 @@ static int nfs_do_mount_v3v2(struct nfsmount_info *mi,
>  		printf(_("%s: trying text-based options '%s'\n"),
>  			progname, *mi->extra_opts);
>  
> -	if (!nfs_rewrite_pmap_mount_options(options))
> +	if (!nfs_rewrite_pmap_mount_options(options, checkv4))
>  		goto out_fail;
>  
>  	result = nfs_sys_mount(mi, options);
> @@ -653,13 +654,13 @@ out_fail:
>   * Returns TRUE if successful, otherwise FALSE.
>   * "errno" is set to reflect the individual error.
>   */
> -static int nfs_try_mount_v3v2(struct nfsmount_info *mi)
> +static int nfs_try_mount_v3v2(struct nfsmount_info *mi, int checkv4)
>  {
>  	struct addrinfo *ai;
>  	int ret = 0;
>  
>  	for (ai = mi->address; ai != NULL; ai = ai->ai_next) {
> -		ret = nfs_do_mount_v3v2(mi, ai->ai_addr, ai->ai_addrlen);
> +		ret = nfs_do_mount_v3v2(mi, ai->ai_addr, ai->ai_addrlen, checkv4);
>  		if (ret != 0)
>  			return ret;
>  
> @@ -793,7 +794,8 @@ static int nfs_autonegotiate(struct nfsmount_info *mi)
>  	result = nfs_try_mount_v4(mi);
>  	if (result)
>  		return result;
> -		
> +
> +check_errno:
>  	switch (errno) {
>  	case EPROTONOSUPPORT:
>  		/* A clear indication that the server or our
> @@ -807,12 +809,24 @@ static int nfs_autonegotiate(struct nfsmount_info *mi)
>  		/* Linux servers prior to 2.6.25 may return
>  		 * EPERM when NFS version 4 is not supported. */
>  		goto fall_back;
> +	case ECONNREFUSED:
> +		/* UDP-Only servers won't support v4, but maybe it
> +		 * just isn't ready yet.  So try v3, but double-check
> +		 * with rpcbind for v4. */
> +		result = nfs_try_mount_v3v2(mi, TRUE);
> +		if (result == 0 && errno == EAGAIN) {
> +			/* v4 server seems to be registered now. */
> +			result = nfs_try_mount_v4(mi);
> +			if (result == 0 && errno != ECONNREFUSED)
> +				goto check_errno;
> +		}
> +		return result;
>  	default:
>  		return result;
>  	}
>  
>  fall_back:
> -	return nfs_try_mount_v3v2(mi);
> +	return nfs_try_mount_v3v2(mi, FALSE);
>  }
>  
>  /*
> @@ -831,7 +845,7 @@ static int nfs_try_mount(struct nfsmount_info *mi)
>  		break;
>  	case 2:
>  	case 3:
> -		result = nfs_try_mount_v3v2(mi);
> +		result = nfs_try_mount_v3v2(mi, FALSE);
>  		break;
>  	case 4:
>  		result = nfs_try_mount_v4(mi);
> 

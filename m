Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:7655 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751020Ab0K3Vsg convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 30 Nov 2010 16:48:36 -0500
Subject: Re: [PATCH v3 5/5] NFSv4: Send unmapped uid/gids to the server
 when using auth_sys
From: Trond Myklebust <Trond.Myklebust@netapp.com>
To: "J. Bruce Fields" <bfields@fieldses.org>
Cc: linux-nfs@vger.kernel.org
In-Reply-To: <20101130194805.GE29091@fieldses.org>
References: <1291128211-7961-1-git-send-email-Trond.Myklebust@netapp.com>
	 <1291128211-7961-2-git-send-email-Trond.Myklebust@netapp.com>
	 <1291128211-7961-3-git-send-email-Trond.Myklebust@netapp.com>
	 <1291128211-7961-4-git-send-email-Trond.Myklebust@netapp.com>
	 <1291128211-7961-5-git-send-email-Trond.Myklebust@netapp.com>
	 <1291128211-7961-6-git-send-email-Trond.Myklebust@netapp.com>
	 <20101130194805.GE29091@fieldses.org>
Content-Type: text/plain; charset="UTF-8"
Date: Tue, 30 Nov 2010 16:48:23 -0500
Message-ID: <1291153703.2998.13.camel@heimdal.trondhjem.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Tue, 2010-11-30 at 14:48 -0500, J. Bruce Fields wrote:
> On Tue, Nov 30, 2010 at 09:43:31AM -0500, Trond Myklebust wrote:
> > The new behaviour is enabled using the new module parameter
> > 'nfs4_disable_idmapping'.
> > 
> > Note that if the server rejects an unmapped uid or gid, then
> > the client will automatically switch back to using the idmapper.
> > 
> > Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
> > ---
> >  Documentation/kernel-parameters.txt |    8 ++++++++
> >  fs/nfs/client.c                     |   16 ++++++++++++++++
> >  fs/nfs/idmap.c                      |   21 +++++++++++++--------
> >  fs/nfs/nfs4proc.c                   |   13 ++++++++++++-
> >  include/linux/nfs_fs_sb.h           |    1 +
> >  5 files changed, 50 insertions(+), 9 deletions(-)
> > 
> > diff --git a/Documentation/kernel-parameters.txt b/Documentation/kernel-parameters.txt
> > index cdd2a6e..51a74a3 100644
> > --- a/Documentation/kernel-parameters.txt
> > +++ b/Documentation/kernel-parameters.txt
> > @@ -1573,6 +1573,14 @@ and is between 256 and 4096 characters. It is defined in the file
> >  			of returning the full 64-bit number.
> >  			The default is to return 64-bit inode numbers.
> >  
> > +	nfs.nfs4_disable_idmapping=
> > +			[NFSv4] When set, this option disables the NFSv4
> > +			idmapper on the client, but only if the mount
> > +			is using the 'sec=sys' security flavour. This may
> > +			make migration from legacy NFSv2/v3 systems easier
> > +			provided that the server has the appropriate support.
> > +			The default is to always enable NFSv4 idmapping.
> > +
> >  	nmi_debug=	[KNL,AVR32,SH] Specify one or more actions to take
> >  			when a NMI is triggered.
> >  			Format: [state][,regs][,debounce][,die]
> > diff --git a/fs/nfs/client.c b/fs/nfs/client.c
> > index 0870d0d..fb84771 100644
> > --- a/fs/nfs/client.c
> > +++ b/fs/nfs/client.c
> > @@ -58,6 +58,11 @@ static LIST_HEAD(nfs_volume_list);
> >  static DECLARE_WAIT_QUEUE_HEAD(nfs_client_active_wq);
> >  
> >  /*
> > + * Turn off NFSv4 uid/gid mapping when using AUTH_SYS
> > + */
> > +static int nfs4_disable_idmapping = 0;
> > +
> > +/*
> >   * RPC cruft for NFS
> >   */
> >  static struct rpc_version *nfs_version[5] = {
> > @@ -1387,6 +1392,13 @@ static int nfs4_init_server(struct nfs_server *server,
> >  	if (error < 0)
> >  		goto error;
> >  
> > +	/*
> > +	 * Don't use NFS uid/gid mapping if we're using AUTH_SYS or lower
> > +	 * authentication.
> > +	 */
> > +	if (nfs4_disable_idmapping && data->auth_flavors[0] == RPC_AUTH_UNIX)
> > +		server->caps |= NFS_CAP_UIDGID_NOMAP;
> > +
> >  	if (data->rsize)
> >  		server->rsize = nfs_block_size(data->rsize, NULL);
> >  	if (data->wsize)
> > @@ -1808,3 +1820,7 @@ void nfs_fs_proc_exit(void)
> >  }
> >  
> >  #endif /* CONFIG_PROC_FS */
> > +
> > +module_param(nfs4_disable_idmapping, bool, 0644);
> > +MODULE_PARM_DESC(nfs4_disable_idmapping,
> > +		"Turn off NFSv4 idmapping when using 'sec=sys'");
> > diff --git a/fs/nfs/idmap.c b/fs/nfs/idmap.c
> > index 114de76..d816bba 100644
> > --- a/fs/nfs/idmap.c
> > +++ b/fs/nfs/idmap.c
> > @@ -257,17 +257,20 @@ int nfs_map_group_to_gid(const struct nfs_server *server, const char *name, size
> >  
> >  int nfs_map_uid_to_name(const struct nfs_server *server, __u32 uid, char *buf, size_t buflen)
> >  {
> > -	int ret;
> > -	ret = nfs_idmap_lookup_name(uid, "user", buf, buflen);
> > +	int ret = -EINVAL;
> > +
> > +	if (!(server->caps & NFS_CAP_UIDGID_NOMAP))
> > +		ret = nfs_idmap_lookup_name(uid, "user", buf, buflen);
> >  	if (ret < 0)
> >  		ret = nfs_map_numeric_to_string(uid, buf, buflen);
> >  	return ret;
> >  }
> >  int nfs_map_gid_to_group(const struct nfs_server *server, __u32 gid, char *buf, size_t buflen)
> >  {
> > -	int ret;
> > +	int ret = -EINVAL;
> >  
> > -	ret = nfs_idmap_lookup_name(gid, "group", buf, buflen);
> > +	if (!(server->caps & NFS_CAP_UIDGID_NOMAP))
> > +		ret = nfs_idmap_lookup_name(gid, "group", buf, buflen);
> >  	if (ret < 0)
> >  		ret = nfs_map_numeric_to_string(gid, buf, buflen);
> >  	return ret;
> > @@ -750,9 +753,10 @@ int nfs_map_group_to_gid(const struct nfs_server *server, const char *name, size
> >  int nfs_map_uid_to_name(const struct nfs_server *server, __u32 uid, char *buf, size_t buflen)
> >  {
> >  	struct idmap *idmap = server->nfs_client->cl_idmap;
> > -	int ret;
> > +	int ret = -EINVAL;
> >  
> > -	ret = nfs_idmap_name(idmap, &idmap->idmap_user_hash, uid, buf);
> > +	if (!(server->caps & NFS_CAP_UIDGID_NOMAP))
> > +		ret = nfs_idmap_name(idmap, &idmap->idmap_user_hash, uid, buf);
> >  	if (ret < 0)
> >  		ret = nfs_map_numeric_to_string(uid, buf, buflen);
> >  	return ret;
> > @@ -760,9 +764,10 @@ int nfs_map_uid_to_name(const struct nfs_server *server, __u32 uid, char *buf, s
> >  int nfs_map_gid_to_group(const struct nfs_server *server, __u32 uid, char *buf, size_t buflen)
> >  {
> >  	struct idmap *idmap = server->nfs_client->cl_idmap;
> > -	int ret;
> > +	int ret = -EINVAL;
> >  
> > -	ret = nfs_idmap_name(idmap, &idmap->idmap_group_hash, uid, buf);
> > +	if (!(server->caps & NFS_CAP_UIDGID_NOMAP))
> > +		ret = nfs_idmap_name(idmap, &idmap->idmap_group_hash, uid, buf);
> >  	if (ret < 0)
> >  		ret = nfs_map_numeric_to_string(uid, buf, buflen);
> >  	return ret;
> 
> OK, so on both send and receive sides: if the new option is on, then we
> use *purely* numeric id's; if off, then we may still use numeric
> id's/gid's, but only as a fallback.
> 
> Looks OK to me.

Yup, but this really wants a corresponding server side option if it is
to solve the nfsroot problem. Otherwise we can still deadlock when the
server sends us a name@domain owner/group string that we need to
translate by means of an upcall to the idmapper. :-)

-- 
Trond Myklebust
Linux NFS client maintainer

NetApp
Trond.Myklebust@netapp.com
www.netapp.com


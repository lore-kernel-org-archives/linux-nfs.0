From: Neil Brown <neilb@suse.de>
Subject: Re: [PATCH 1/4 Revised] NLM failover - nlm_unlock
Date: Tue, 26 Sep 2006 10:39:39 +1000
Message-ID: <17688.30411.484871.224188@cse.unsw.edu.au>
References: <4508DE13.6030705@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: cluster-devel@redhat.com, lhh@redhat.com,
	nfs@lists.sourceforge.net
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1GS0zN-0000V2-Pu
	for nfs@lists.sourceforge.net; Mon, 25 Sep 2006 17:39:57 -0700
Received: from ns1.suse.de ([195.135.220.2] helo=mx1.suse.de)
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1GS0zN-0001Eu-4H
	for nfs@lists.sourceforge.net; Mon, 25 Sep 2006 17:39:58 -0700
To: wcheng@redhat.com
In-Reply-To: message from Wendy Cheng on Thursday September 14
List-Id: "Discussion of NFS under Linux development, interoperability,
	and testing." <nfs.lists.sourceforge.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=nfs>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
Sender: nfs-bounces@lists.sourceforge.net
Errors-To: nfs-bounces@lists.sourceforge.net


Firstly, sorry for the delay in responding to these.


On Thursday September 14, wcheng@redhat.com wrote:
> By writing exported filesytem id into /proc/fs/nfsd/nlm_unlock, this 
> patch walks thru lockd's global nlm_files list to release all the locks 
> associated with the particular id. It is used to enable NFS lock 
> failover with active-active clustered servers.
> 
> Relevant steps:
> 1) Exports filesystem with "fsid" option as:
>    /etc/exports entry> /mnt/ext3/exports *(fsid=1234,sync,rw)
> 2) Drops locks based on fsid by:
>    shell> echo 1234 > /proc/fs/nfsd/nlm_unlock

I actually felt a bit more comfortable with the server-ip based
approach, how I cannot really fault the fsid based approach, and it
does seem to have some advantages, so I guess we go with it.

>  /*
> + * Get fsid from nfs_fh:
> + * return 1 if *fsid contains a valid value.
> + */
> +static inline int
> +nlm_fo_get_fsid(struct nfs_fh *fh, int *fsid)
> +{
> +	struct nfs_fhbase_new *fh_base = (struct nfs_fhbase_new *) fh->data;
> + 	int data_left = fh->size/4;
> + 
> + 	nlm_debug_print_fh("nlm_fo_find_fsid", fh);
> + 
> + 	/* From fb_version to fb_auth - at least two u32 */
> + 	if (data_left < 2)		
> + 		return 0;
> +  
> + 	/* For various types, check out 
> + 	 * inlcude/linux/nfsd/nfsfsh.h
> + 	 */
> + 	if ((fh_base->fb_version != 1) ||  
> + 		(fh_base->fb_auth_type != 0) ||
> + 		(fh_base->fb_fsid_type != 1))
> + 		return 0;
> + 
> + 	/* The fb_auth is 0 bytes long - imply fb_auth[0] has
> + 	 * fsid value.
> + 	 */
> + 	*fsid = (int) fh_base->fb_auth[0];
> + 	return 1;
> +}

It would be really nice if this could be in the nfsd code rather than
in the lockd code.  Maybe if the nlm_fopen call passed back the fsid?

> +
> +/*
>   * Operate on a single file
>   */
>  static inline int
> @@ -234,21 +267,42 @@ nlm_inspect_file(struct nlm_host *host, 
>   * Loop over all files in the file table.
>   */
>  static int
> -nlm_traverse_files(struct nlm_host *host, int action)
> +nlm_traverse_files(struct nlm_host *host, int *fsidp, int action)
>  {
>  	struct nlm_file	*file, **fp;
> -	int i, ret = 0;
> +	int i, ret = 0, found, fsid_in=0, fsid, act=action;

Unfortunately all of this will have to change due to Olaf's recent
changes in lockd.  Should be quite do-able, just needs to be
different.

> +/*
> + * release locks associated with an export fsid upon failover
> + */
> +int
> +nlmsvc_fo_unlock(int *fsid)
> +{
> +	/* drop the locks */
> +	return (nlm_traverse_files(NULL, fsid, NLM_ACT_FO_UNLOCK)); 
> +}
> +

I really don't think fsid should be an 'int *', just an int.
Other callers of nlm_traverse_files can just pass an fsid of 0 - they
don't need to be able to pass NULL.


NeilBrown

-------------------------------------------------------------------------
Take Surveys. Earn Cash. Influence the Future of IT
Join SourceForge.net's Techsay panel and you'll get the chance to share your
opinions on IT & business topics through brief surveys -- and earn cash
http://www.techsay.com/default.php?page=join.php&p=sourceforge&CID=DEVDEV
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs

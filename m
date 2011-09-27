Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:58288 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751464Ab1I0QKJ (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 27 Sep 2011 12:10:09 -0400
Message-ID: <4E81F55F.60306@netapp.com>
Date: Tue, 27 Sep 2011 12:10:07 -0400
From: Bryan Schumaker <bjschuma@netapp.com>
To: "J. Bruce Fields" <bfields@redhat.com>
CC: linux-nfs@vger.kernel.org
Subject: Re: [PATCH 4/5] nfsd4: construct stateid from clientid and counter
References: <20110919131415.GB32498@fieldses.org> <1316438143-1057-4-git-send-email-bfields@redhat.com>
In-Reply-To: <1316438143-1057-4-git-send-email-bfields@redhat.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On 09/19/2011 09:15 AM, J. Bruce Fields wrote:
> Including the full clientid in the on-the-wire stateid allows more
> reliable detection of bad vs. expired stateid's, simplifies code, and
> ensures we won't reuse the opaque part of the stateid (as we currently
> do when the same openowner closes and reopens the same file).
> 
> Signed-off-by: J. Bruce Fields <bfields@redhat.com>
> ---
>  fs/nfsd/nfs4state.c |   58 +++++++++++---------------------------------------
>  fs/nfsd/state.h     |   18 ++++-----------
>  2 files changed, 18 insertions(+), 58 deletions(-)
> 
[ ... ]
> diff --git a/fs/nfsd/state.h b/fs/nfsd/state.h
> index e807abb..d6aec4f 100644
> --- a/fs/nfsd/state.h
> +++ b/fs/nfsd/state.h
> @@ -353,11 +349,9 @@ struct nfs4_replay {
>  */
>  
>  struct nfs4_stateowner {

The comment describing this struct should probably be updated since so_idhash and a few other variables no longer exist.

- Bryan

> -	struct list_head        so_idhash;   /* hash by so_id */
>  	struct list_head        so_strhash;   /* hash by op_name */
>  	struct list_head        so_stateids;
>  	int			so_is_open_owner; /* 1=openowner,0=lockowner */
> -	u32                     so_id;
>  	struct nfs4_client *    so_client;
>  	/* after increment in ENCODE_SEQID_OP_TAIL, represents the next
>  	 * sequence id expected from the client: */
> @@ -415,8 +409,6 @@ struct nfs4_file {
>  	struct file_lock	*fi_lease;
>  	atomic_t		fi_delegees;
>  	struct inode		*fi_inode;
> -	u32                     fi_id;      /* used with stateowner->so_id 
> -					     * for stateid_hashtbl hash */
>  	bool			fi_had_conflict;
>  };
>  


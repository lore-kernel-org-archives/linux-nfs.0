Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-qt0-f182.google.com ([209.85.216.182]:33468 "EHLO
        mail-qt0-f182.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1754379AbcKNQkw (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Mon, 14 Nov 2016 11:40:52 -0500
Received: by mail-qt0-f182.google.com with SMTP id p16so50468743qta.0
        for <linux-nfs@vger.kernel.org>; Mon, 14 Nov 2016 08:40:51 -0800 (PST)
Message-ID: <1479141648.2510.10.camel@redhat.com>
Subject: Re: [PATCH 1/2] NFSv4: Fix CLOSE races with OPEN
From: Jeff Layton <jlayton@redhat.com>
To: Trond Myklebust <trond.myklebust@primarydata.com>,
        linux-nfs@vger.kernel.org
Cc: Benjamin Coddington <bcodding@redhat.com>
Date: Mon, 14 Nov 2016 11:40:48 -0500
In-Reply-To: <1479140396-17779-2-git-send-email-trond.myklebust@primarydata.com>
References: <1479140396-17779-1-git-send-email-trond.myklebust@primarydata.com>
         <1479140396-17779-2-git-send-email-trond.myklebust@primarydata.com>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, 2016-11-14 at 11:19 -0500, Trond Myklebust wrote:
> If the reply to a successful CLOSE call races with an OPEN to the same
> file, we can end up scribbling over the stateid that represents the
> new open state.
> The race looks like:
> 
>   Client				Server
>   ======				======
> 
>   CLOSE stateid A on file "foo"
> 					CLOSE stateid A, return stateid C
>   OPEN file "foo"
> 					OPEN "foo", return stateid B
>   Receive reply to OPEN
>   Reset open state for "foo"
>   Associate stateid B to "foo"
> 
>   Receive CLOSE for A
>   Reset open state for "foo"
>   Replace stateid B with C
> 
> The fix is to examine the argument of the CLOSE, and check for a match
> with the current stateid "other" field. If the two do not match, then
> the above race occurred, and we should just ignore the CLOSE.
> 
> Reported-by: Benjamin Coddington <bcodding@redhat.com>
> Signed-off-by: Trond Myklebust <trond.myklebust@primarydata.com>
> ---
>  fs/nfs/nfs4_fs.h  |  7 +++++++
>  fs/nfs/nfs4proc.c | 12 ++++++------
>  2 files changed, 13 insertions(+), 6 deletions(-)
> 
> diff --git a/fs/nfs/nfs4_fs.h b/fs/nfs/nfs4_fs.h
> index 9b3a82abab07..1452177c822d 100644
> --- a/fs/nfs/nfs4_fs.h
> +++ b/fs/nfs/nfs4_fs.h
> @@ -542,6 +542,13 @@ static inline bool nfs4_valid_open_stateid(const struct nfs4_state *state)
>  	return test_bit(NFS_STATE_RECOVERY_FAILED, &state->flags) == 0;
>  }
>  
> +static inline bool nfs4_state_match_open_stateid_other(const struct nfs4_state *state,
> +		const nfs4_stateid *stateid)
> +{
> +	return test_bit(NFS_OPEN_STATE, &state->flags) &&
> +		nfs4_stateid_match_other(&state->open_stateid, stateid);
> +}
> +
>  #else
>  
>  #define nfs4_close_state(a, b) do { } while (0)
> diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
> index f550ac69ffa0..b7b0080977c0 100644
> --- a/fs/nfs/nfs4proc.c
> +++ b/fs/nfs/nfs4proc.c
> @@ -1458,7 +1458,6 @@ static void nfs_resync_open_stateid_locked(struct nfs4_state *state)
>  }
>  
>  static void nfs_clear_open_stateid_locked(struct nfs4_state *state,
> -		nfs4_stateid *arg_stateid,
>  		nfs4_stateid *stateid, fmode_t fmode)
>  {
>  	clear_bit(NFS_O_RDWR_STATE, &state->flags);
> @@ -1476,10 +1475,9 @@ static void nfs_clear_open_stateid_locked(struct nfs4_state *state,
>  	}
>  	if (stateid == NULL)
>  		return;
> -	/* Handle races with OPEN */
> -	if (!nfs4_stateid_match_other(arg_stateid, &state->open_stateid) ||
> -	    (nfs4_stateid_match_other(stateid, &state->open_stateid) &&
> -	    !nfs4_stateid_is_newer(stateid, &state->open_stateid))) {
> +	/* Handle OPEN+OPEN_DOWNGRADE races */
> +	if (nfs4_stateid_match_other(stateid, &state->open_stateid) &&
> +	    !nfs4_stateid_is_newer(stateid, &state->open_stateid)) {
>  		nfs_resync_open_stateid_locked(state);
>  		return;
>  	}
> @@ -1493,7 +1491,9 @@ static void nfs_clear_open_stateid(struct nfs4_state *state,
>  	nfs4_stateid *stateid, fmode_t fmode)
>  {
>  	write_seqlock(&state->seqlock);
> -	nfs_clear_open_stateid_locked(state, arg_stateid, stateid, fmode);
> +	/* Ignore, if the CLOSE argment doesn't match the current stateid */
> +	if (nfs4_state_match_open_stateid_other(state, arg_stateid))
> +		nfs_clear_open_stateid_locked(state, stateid, fmode);
>  	write_sequnlock(&state->seqlock);
>  	if (test_bit(NFS_STATE_RECLAIM_NOGRACE, &state->flags))
>  		nfs4_schedule_state_manager(state->owner->so_server->nfs_client);

I still don't quite get it. What's the point of paying any attention at
all to the stateid returned by the server in a CLOSE response? It's
either:

a) completely bogus, if the server is following the SHOULD in RFC5661,
section 18.2.4

...or...

b) refers to a now-defunct stateid -- probably a later version of the
one sent in the request, but the spec doesn't really spell that out,
AFAICT.

In either case, I don't think it ought to be trusted. Why not just use
the arg_stateid universally here?

-- 
Jeff Layton <jlayton@redhat.com>

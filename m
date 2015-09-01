Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-qk0-f176.google.com ([209.85.220.176]:36591 "EHLO
	mail-qk0-f176.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752251AbbIANSu (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 1 Sep 2015 09:18:50 -0400
Received: by qkbp67 with SMTP id p67so38001395qkb.3
        for <linux-nfs@vger.kernel.org>; Tue, 01 Sep 2015 06:18:49 -0700 (PDT)
Date: Tue, 1 Sep 2015 09:18:42 -0400
From: Jeff Layton <jlayton@poochiereds.net>
To: Andrew Elble <aweits@rit.edu>
Cc: linux-nfs@vger.kernel.org, etmsys@rit.edu
Subject: Re: [PATCH] nfsd: deal with DELEGRETURN racing with CB_RECALL
Message-ID: <20150901091842.7c40adf3@tlielax.poochiereds.net>
In-Reply-To: <1441037201-78787-1-git-send-email-aweits@rit.edu>
References: <1441037201-78787-1-git-send-email-aweits@rit.edu>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, 31 Aug 2015 12:06:41 -0400
Andrew Elble <aweits@rit.edu> wrote:

> We have observed the server sending recalls for delegation stateids
> that have already been successfully returned. Change
> nfsd4_cb_recall_done() to return success if the client has returned
> the delegation. While this does not completely eliminate the sending
> of recalls for delegations that have already been returned, this
> does prevent unnecessarily declaring the callback path to be down.
> 
> Reported-by: Eric Meddaugh <etmsys@rit.edu>
> Signed-off-by: Andrew Elble <aweits@rit.edu>
> ---
>  fs/nfsd/nfs4state.c | 3 +++
>  1 file changed, 3 insertions(+)
> 
> diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
> index de45c2de1668..ac235a7470e3 100644
> --- a/fs/nfsd/nfs4state.c
> +++ b/fs/nfsd/nfs4state.c
> @@ -3509,6 +3509,9 @@ static int nfsd4_cb_recall_done(struct nfsd4_callback *cb,
>  {
>  	struct nfs4_delegation *dp = cb_to_delegation(cb);
>  
> +	if (dp->dl_stid.sc_type == NFS4_CLOSED_DELEG_STID)
> +	        return 1;
> +
>  	switch (task->tk_status) {
>  	case 0:
>  		return 1;

Yeah, there will always be some potential for a CB_RECALL/DELEGRETURN
race since the former is driven by the server and the latter by the
client.

What error are you usually getting back from the client when you see
this happen? NFS4ERR_BAD_STATEID? If so, then maybe we should confine
this check to that error case?

OTOH, maybe there's no harm in just ignoring the error if the
delegation is already returned...

Acked-by: Jeff Layton <jlayton@poochiereds.net>

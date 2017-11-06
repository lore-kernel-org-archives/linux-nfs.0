Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from discipline.rit.edu ([129.21.6.207]:17451 "HELO
        discipline.rit.edu" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with SMTP id S1751074AbdKFCqD (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Sun, 5 Nov 2017 21:46:03 -0500
From: Andrew W Elble <aweits@rit.edu>
To: Trond Myklebust <trond.myklebust@primarydata.com>
Cc: Benjamin Coddington <bcodding@redhat.com>,
        Anna Schumaker <anna.schumaker@netapp.com>,
        linux-nfs@vger.kernel.org
Subject: Re: [PATCH v6 05/10] NFSv4: Retry CLOSE and DELEGRETURN on NFS4ERR_OLD_STATEID.
References: <20171103165354.15997-1-trond.myklebust@primarydata.com>
        <20171103165354.15997-2-trond.myklebust@primarydata.com>
        <20171103165354.15997-3-trond.myklebust@primarydata.com>
        <20171103165354.15997-4-trond.myklebust@primarydata.com>
        <20171103165354.15997-5-trond.myklebust@primarydata.com>
        <20171103165354.15997-6-trond.myklebust@primarydata.com>
Date: Sun, 05 Nov 2017 21:46:02 -0500
In-Reply-To: <20171103165354.15997-6-trond.myklebust@primarydata.com> (Trond
        Myklebust's message of "Fri, 3 Nov 2017 12:53:49 -0400")
Message-ID: <m2k1z4qg45.fsf@discipline.rit.edu>
MIME-Version: 1.0
Content-Type: text/plain
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


I've been testing these a bit, I think this was causing an issue...

Trond Myklebust <trond.myklebust@primarydata.com> writes:

> diff --git a/fs/nfs/nfs4state.c b/fs/nfs/nfs4state.c
> index d615b7cdfa8f..752b18e88266 100644
> --- a/fs/nfs/nfs4state.c
> +++ b/fs/nfs/nfs4state.c
> @@ -986,6 +986,22 @@ static int nfs4_copy_lock_stateid(nfs4_stateid *dst,
>  	return ret;
>  }
>  
> +bool nfs4_refresh_open_stateid(nfs4_stateid *dst, struct nfs4_state *state)
> +{
> +	bool ret;
> +	int seq;
> +
> +	do {
> +		ret = false;
> +		seq = read_seqbegin(&state->seqlock);
> +		if (nfs4_state_match_open_stateid_other(state, dst)) {
> +			dst->seqid = state->stateid.seqid;

You mean:

                        dst->seqid = state->open_stateid.seqid;

?

> +			ret = true;
> +		}
> +	} while (read_seqretry(&state->seqlock, seq));
> +	return ret;
> +}
> +
>  static void nfs4_copy_open_stateid(nfs4_stateid *dst, struct nfs4_state *state)
>  {
>  	const nfs4_stateid *src;

Thanks,

Andy

-- 
Andrew W. Elble
aweits@discipline.rit.edu
Infrastructure Engineer, Communications Technical Lead
Rochester Institute of Technology
PGP: BFAD 8461 4CCF DC95 DA2C B0EB 965B 082E 863E C912

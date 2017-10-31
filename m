Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:43004 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752335AbdJaRcp (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Tue, 31 Oct 2017 13:32:45 -0400
Reply-To: ffilz@redhat.com
Subject: Re: [PATCH 2/5] nfsd: CLOSE SHOULD return the invalid special stateid
 for NFSv4.x (x>0)
To: Trond Myklebust <trond.myklebust@primarydata.com>,
        bfields@fieldses.org
Cc: linux-nfs@vger.kernel.org
References: <20171031000951.18294-1-trond.myklebust@primarydata.com>
 <20171031000951.18294-2-trond.myklebust@primarydata.com>
 <20171031000951.18294-3-trond.myklebust@primarydata.com>
From: Frank Filz <ffilz@redhat.com>
Message-ID: <a18842ca-ee82-647a-f275-fd29be31e3f5@redhat.com>
Date: Tue, 31 Oct 2017 10:32:44 -0700
MIME-Version: 1.0
In-Reply-To: <20171031000951.18294-3-trond.myklebust@primarydata.com>
Content-Type: text/plain; charset=utf-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 10/30/2017 05:09 PM, Trond Myklebust wrote:
> Signed-off-by: Trond Myklebust <trond.myklebust@primarydata.com>
> ---
>  fs/nfsd/nfs4state.c | 8 ++++++++
>  1 file changed, 8 insertions(+)
>
> diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
> index b246aaa20863..0fa42c704b9a 100644
> --- a/fs/nfsd/nfs4state.c
> +++ b/fs/nfsd/nfs4state.c
> @@ -63,6 +63,9 @@ static const stateid_t zero_stateid = {
>  static const stateid_t currentstateid = {
>  	.si_generation = 1,
>  };
> +static const stateid_t close_stateid = {
> +	.si_generation = 0xffffffffU,
> +};
>  
>  static u64 current_sessionid = 1;
>  
> @@ -5390,6 +5393,11 @@ nfsd4_close(struct svc_rqst *rqstp, struct nfsd4_compound_state *cstate,
>  	nfsd4_close_open_stateid(stp);
>  	mutex_unlock(&stp->st_mutex);
>  
> +	/* See RFC5661 sectionm 18.2.4 */
> +	if (stp->st_stid.sc_client->cl_minorversion)
> +		memcpy(&close->cl_stateid, &close_stateid,
> +				sizeof(close->cl_stateid));
> +
>  	/* put reference from nfs4_preprocess_seqid_op */
>  	nfs4_put_stid(&stp->st_stid);
>  out:

Ooh, I'd never noticed that... Ganesha needs to do that also.


Bruce, can we get a pynfs test case to verify this?


Thanks

Frank


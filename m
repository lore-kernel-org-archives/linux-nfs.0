From: Benny Halevy <bhalevy@panasas.com>
Subject: Re: [PATCH] NFS4.1: Fix bug server don't reply the right fore_channel
 to client at create_session
Date: Thu, 11 Nov 2010 15:32:23 +0200
Message-ID: <4CDBF067.2000904@panasas.com>
References: <4CDBBF7C.90108@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-2022-JP
Cc: "J. Bruce Fields" <bfields@fieldses.org>,
	NFS list <linux-nfs@vger.kernel.org>
To: Mi Jinlong <mijinlong@cn.fujitsu.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from exprod5og111.obsmtp.com ([64.18.0.22]:58656 "HELO
	exprod5og111.obsmtp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with SMTP id S1755732Ab0KKNcZ (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 11 Nov 2010 08:32:25 -0500
In-Reply-To: <4CDBBF7C.90108@cn.fujitsu.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 2010-11-11 12:03, Mi Jinlong wrote:
> At the latest kernel(2.6.37-rc1), server just initialize the forechannel
> at init_forechannel_attrs, but don't reflect it to reply.
> 
> After initialize the session success, we should copy the forechannel info
> to nfsd4_create_session struct.
> 
> Signed-off-by: Mi Jinlong <mijinlong@cn.fujitsu.com>

Yeah, looks necessary to me too.

Benny

> ---
>  fs/nfsd/nfs4state.c |    2 ++
>  1 files changed, 2 insertions(+), 0 deletions(-)
> 
> diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
> index f1e5ec6..3876a9c 100644
> --- a/fs/nfsd/nfs4state.c
> +++ b/fs/nfsd/nfs4state.c
> @@ -1556,6 +1556,8 @@ nfsd4_create_session(struct svc_rqst *rqstp,
>  	status = nfs_ok;
>  	memcpy(cr_ses->sessionid.data, new->se_sessionid.data,
>  	       NFS4_MAX_SESSIONID_LEN);
> +	memcpy(&cr_ses->fore_channel, &new->se_fchannel,
> +		sizeof(struct nfsd4_channel_attrs));
>  	cs_slot->sl_seqid++;
>  	cr_ses->seqid = cs_slot->sl_seqid;
>  

Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-pa0-f49.google.com ([209.85.220.49]:35005 "EHLO
	mail-pa0-f49.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1422843AbbD2MIg (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 29 Apr 2015 08:08:36 -0400
Received: by pabtp1 with SMTP id tp1so26227130pab.2
        for <linux-nfs@vger.kernel.org>; Wed, 29 Apr 2015 05:08:35 -0700 (PDT)
Message-ID: <5540C9BD.2080402@gmail.com>
Date: Wed, 29 Apr 2015 20:08:29 +0800
From: Kinglong Mee <kinglongmee@gmail.com>
MIME-Version: 1.0
To: Christoph Hellwig <hch@infradead.org>,
        Trond Myklebust <trond.myklebust@primarydata.com>
CC: linux-nfs@vger.kernel.org
Subject: Re: [PATCH, RFC] backchannel overflows
References: <20150428202157.GA23972@infradead.org>
In-Reply-To: <20150428202157.GA23972@infradead.org>
Content-Type: text/plain; charset=windows-1252
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 4/29/2015 4:21 AM, Christoph Hellwig wrote:
> Currently the client will just crap out if a CB_NULL comes in at the
> same time as a slot controlled CB_COMPOUND that includes a CB_SEQUENCE.
> 
> I don't really understand how the spec wants to treat CB_NULL in
> relation to the available backchannel slots, but given that it's
> not part of the sequences in CB_SEQUENCE it somehow nees to bypass them.
> 
> If we make sure to overallocate the rpc-level buffers so that we
> have more than the available NFS-level slots we should be safe from
> this condition which makes a 4.1 server doing heavy recalls under
> load very unhapy by not returning an NFS level reply to its layout
> recalls.
> 
> I dont really like this patch much, so any idea for a better solution
> would be highly welcome!
> 
> diff --git a/fs/nfs/callback.h b/fs/nfs/callback.h
> index 84326e9..7afb3ef 100644
> --- a/fs/nfs/callback.h
> +++ b/fs/nfs/callback.h
> @@ -205,7 +205,7 @@ extern int nfs4_set_callback_sessionid(struct nfs_client *clp);
>   * so we limit their concurrency to 1 by setting up the maximum number
>   * of slots for the backchannel.
>   */
> -#define NFS41_BC_MIN_CALLBACKS 1
> +#define NFS41_BC_MIN_CALLBACKS 2
>  #define NFS41_BC_MAX_CALLBACKS 1

Are you sure that's okay without update NFS41_BC_MAX_CALLBACKS?

thanks,
Kinglong Mee

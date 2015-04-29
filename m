Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from userp1040.oracle.com ([156.151.31.81]:44244 "EHLO
	userp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1423035AbbD2Oys convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 29 Apr 2015 10:54:48 -0400
Content-Type: text/plain; charset=us-ascii
Mime-Version: 1.0 (Mac OS X Mail 7.3 \(1878.6\))
Subject: Re: [PATCH, RFC] backchannel overflows
From: Chuck Lever <chuck.lever@oracle.com>
In-Reply-To: <20150428202157.GA23972@infradead.org>
Date: Wed, 29 Apr 2015 10:55:10 -0400
Cc: Trond Myklebust <trond.myklebust@primarydata.com>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Message-Id: <1C0C92C2-FBCF-49D8-BB31-3C23A520B075@oracle.com>
References: <20150428202157.GA23972@infradead.org>
To: Christoph Hellwig <hch@infradead.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


On Apr 28, 2015, at 4:21 PM, Christoph Hellwig <hch@infradead.org> wrote:

> Currently the client will just crap out if a CB_NULL comes in at the
> same time as a slot controlled CB_COMPOUND that includes a CB_SEQUENCE.

Under what circumstances does the server send a CB_NULL while a CB_COMPOUND
is in flight?


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
>  * so we limit their concurrency to 1 by setting up the maximum number
>  * of slots for the backchannel.
>  */
> -#define NFS41_BC_MIN_CALLBACKS 1
> +#define NFS41_BC_MIN_CALLBACKS 2
> #define NFS41_BC_MAX_CALLBACKS 1
> 
> extern unsigned int nfs_callback_set_tcpport;
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

--
Chuck Lever
chuck[dot]lever[at]oracle[dot]com




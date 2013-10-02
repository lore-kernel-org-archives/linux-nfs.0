Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-bk0-f48.google.com ([209.85.214.48]:49143 "EHLO
	mail-bk0-f48.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753207Ab3JBOTm (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 2 Oct 2013 10:19:42 -0400
Received: by mail-bk0-f48.google.com with SMTP id my13so359488bkb.21
        for <linux-nfs@vger.kernel.org>; Wed, 02 Oct 2013 07:19:41 -0700 (PDT)
Message-ID: <524C2B7A.1060203@primarydata.com>
Date: Wed, 02 Oct 2013 17:19:38 +0300
From: Benny Halevy <bhalevy@primarydata.com>
MIME-Version: 1.0
To: Christoph Hellwig <hch@infradead.org>
CC: "J. Bruce Fields" <bfields@redhat.com>, linux-nfs@vger.kernel.org
Subject: Re: [PATCH RFC v0 45/49] nfs: resolve compile dependency in nfs_xdr.h
References: <52447EA0.7070004@primarydata.com> <1380220979-14761-1-git-send-email-bhalevy@primarydata.com> <20130929121951.GH21083@infradead.org>
In-Reply-To: <20130929121951.GH21083@infradead.org>
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 2013-09-29 15:19, Christoph Hellwig wrote:
> On Thu, Sep 26, 2013 at 02:42:59PM -0400, Benny Halevy wrote:
>> From: Benny Halevy <bhalevy@panasas.com>
>>
>> Include headers in nfs_xdr.h required for
>> struct rpc_task, nfs4_verifier, nfs4_stateid
> 
> Is this actually dereferences or would it need a forward declaration?
> 
> Also should go to Trond straight outside of this series.

Hmm, I thought I already replied to this, but I don't see my reply,
so here it is :)

I consulted with Trond about this and there's a better way to
get the definition here by including linux/nfs4.h that doesn't require
the nfs_xdr.h baggage.  So this patch is dropped from the next
version.

Benny

> 
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> 

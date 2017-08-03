Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from smtp-o-1.desy.de ([131.169.56.154]:39434 "EHLO smtp-o-1.desy.de"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751058AbdHCM5M (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Thu, 3 Aug 2017 08:57:12 -0400
Received: from smtp-map-1.desy.de (smtp-map-1.desy.de [131.169.56.66])
        by smtp-o-1.desy.de (DESY-O-1) with ESMTP id 0C4CE2808E8
        for <linux-nfs@vger.kernel.org>; Thu,  3 Aug 2017 14:57:11 +0200 (CEST)
Date: Thu, 3 Aug 2017 14:57:10 +0200 (CEST)
From: "Mkrtchyan, Tigran" <tigran.mkrtchyan@desy.de>
To: Weston Andros Adamson <dros@monkey.org>
Cc: Trond Myklebust <trond.myklebust@primarydata.com>,
        Anna Schumaker <anna.schumaker@netapp.com>,
        linux-nfs <linux-nfs@vger.kernel.org>
Message-ID: <435422355.5999768.1501765030094.JavaMail.zimbra@desy.de>
In-Reply-To: <A49F4A5C-4101-4D60-A14F-FC20D4F53897@monkey.org>
References: <20170801202501.4876-1-dros@primarydata.com> <A49F4A5C-4101-4D60-A14F-FC20D4F53897@monkey.org>
Subject: Re: [PATCH] nfs/flexfiles: fix leak of nfs4_ff_ds_version arrays
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi Dros,

can this leak be the source of issue described here:  http://www.spinics.net/lists/linux-nfs/msg64890.html

Tigran.

----- Original Message -----
> From: "Weston Andros Adamson" <dros@monkey.org>
> To: "Trond Myklebust" <trond.myklebust@primarydata.com>, "Anna Schumaker" <anna.schumaker@netapp.com>
> Cc: "linux-nfs" <linux-nfs@vger.kernel.org>
> Sent: Thursday, August 3, 2017 4:07:28 AM
> Subject: Re: [PATCH] nfs/flexfiles: fix leak of nfs4_ff_ds_version arrays

> This should probably be CCed to some stable releases too. I'll figure it out
> soon.
> 
> -dros
> 
>> On Aug 1, 2017, at 4:25 PM, Weston Andros Adamson <dros@monkey.org> wrote:
>> 
>> The client was freeing the nfs4_ff_layout_ds, but not the contained
>> nfs4_ff_ds_version array.
>> 
>> Signed-off-by: Weston Andros Adamson <dros@primarydata.com>
>> ---
>> fs/nfs/flexfilelayout/flexfilelayoutdev.c | 1 +
>> 1 file changed, 1 insertion(+)
>> 
>> diff --git a/fs/nfs/flexfilelayout/flexfilelayoutdev.c
>> b/fs/nfs/flexfilelayout/flexfilelayoutdev.c
>> index 6df7a0cf5660..f32c58bbe556 100644
>> --- a/fs/nfs/flexfilelayout/flexfilelayoutdev.c
>> +++ b/fs/nfs/flexfilelayout/flexfilelayoutdev.c
>> @@ -32,6 +32,7 @@ void nfs4_ff_layout_free_deviceid(struct nfs4_ff_layout_ds
>> *mirror_ds)
>> {
>> 	nfs4_print_deviceid(&mirror_ds->id_node.deviceid);
>> 	nfs4_pnfs_ds_put(mirror_ds->ds);
>> +	kfree(mirror_ds->ds_versions);
>> 	kfree_rcu(mirror_ds, id_node.rcu);
>> }
>> 
>> --
>> 2.11.0 (Apple Git-81)
>> 
> 
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

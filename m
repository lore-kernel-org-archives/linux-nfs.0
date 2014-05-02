Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-ie0-f180.google.com ([209.85.223.180]:59249 "EHLO
	mail-ie0-f180.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752774AbaEBQW6 convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 2 May 2014 12:22:58 -0400
Received: by mail-ie0-f180.google.com with SMTP id as1so5142800iec.25
        for <linux-nfs@vger.kernel.org>; Fri, 02 May 2014 09:22:58 -0700 (PDT)
Content-Type: text/plain; charset=windows-1252
Mime-Version: 1.0 (Mac OS X Mail 7.2 \(1874\))
Subject: Re: [PATCH 2/3] nfs: rename members of nfs_pgio_data
From: Weston Andros Adamson <dros@primarydata.com>
In-Reply-To: <B1C09779-BB74-433F-8925-B78F1B4B7CC7@primarydata.com>
Date: Fri, 2 May 2014 12:22:55 -0400
Cc: linux-nfs list <linux-nfs@vger.kernel.org>
Message-Id: <07E33EF3-5D17-4B0A-A469-34839C39CFC5@primarydata.com>
References: <1398971693-82399-1-git-send-email-dros@primarydata.com> <1398971693-82399-3-git-send-email-dros@primarydata.com> <6E840B50-223E-462C-B9A7-BC48C6DC5906@primarydata.com> <B1C09779-BB74-433F-8925-B78F1B4B7CC7@primarydata.com>
To: Trond Myklebust <trond.myklebust@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On May 1, 2014, at 4:56 PM, Weston Andros Adamson <dros@primarydata.com> wrote:

> 
> 
> On May 1, 2014, at 4:19 PM, Trond Myklebust <trond.myklebust@primarydata.com> wrote:
> 
>> 
>> On May 1, 2014, at 15:14, Weston Andros Adamson <dros@primarydata.com> wrote:
>> 
>>> diff --git a/include/linux/nfs_xdr.h b/include/linux/nfs_xdr.h
>>> index a7ccc8c..8564539 100644
>>> --- a/include/linux/nfs_xdr.h
>>> +++ b/include/linux/nfs_xdr.h
>>> @@ -1261,13 +1261,13 @@ struct nfs_pgio_data {
>>> 	struct list_head	list;
>>> 	struct rpc_task		task;
>>> 	struct nfs_fattr	fattr;
>>> -	struct nfs_writeverf	verf;		/* Used for writes */
>>> +	struct nfs_writeverf	rpc_verf;	/* Used for writes */
>> 
>> Can we just make this “writeverf"? It isn’t really an rpc object, so the ‘rpc_’ prefix seems a little misleading.
> 
> yes, good point.
> 
> -dros
> 

Actually, having a verf in the header and in pgio_data is redundant now that there is only one pgio_data (the
header verf was used to make sure that all pgio_data verfs matched).

I’ll remove rpc_verf.

-dros

>> 
>>> 	struct nfs_pgio_args	args;		/* argument struct */
>>> 	struct nfs_pgio_res	res;		/* result struct */
>>> 	unsigned long		timestamp;	/* For lease renewal */
>>> 	int (*pgio_done_cb)(struct rpc_task *task, struct nfs_pgio_data *data);
>>> 	__u64			mds_offset;	/* Filelayout dense stripe */
>>> -	struct nfs_page_array	pages;
>>> +	struct nfs_page_array	page_array;
>>> 	struct nfs_client	*ds_clp;	/* pNFS data server */
>>> 	int			ds_idx;		/* ds index if ds_clp is set */
>>> };
>>> -- 
>>> 1.8.5.2 (Apple Git-48)
>>> 
>> 
>> _________________________________
>> Trond Myklebust
>> Linux NFS client maintainer, PrimaryData
>> trond.myklebust@primarydata.com
>> 
> 


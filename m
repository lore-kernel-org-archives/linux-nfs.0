Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-ie0-f173.google.com ([209.85.223.173]:43049 "EHLO
	mail-ie0-f173.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753507AbaEBQZx convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 2 May 2014 12:25:53 -0400
Received: by mail-ie0-f173.google.com with SMTP id rp18so5314443iec.18
        for <linux-nfs@vger.kernel.org>; Fri, 02 May 2014 09:25:52 -0700 (PDT)
Content-Type: text/plain; charset=windows-1252
Mime-Version: 1.0 (Mac OS X Mail 7.2 \(1874\))
Subject: Re: [PATCH 2/3] nfs: rename members of nfs_pgio_data
From: Weston Andros Adamson <dros@primarydata.com>
In-Reply-To: <07E33EF3-5D17-4B0A-A469-34839C39CFC5@primarydata.com>
Date: Fri, 2 May 2014 12:25:49 -0400
Cc: Trond Myklebust <trond.myklebust@primarydata.com>,
        linux-nfs list <linux-nfs@vger.kernel.org>
Message-Id: <669C1A5E-2CD6-46BF-B94A-A843608407FC@primarydata.com>
References: <1398971693-82399-1-git-send-email-dros@primarydata.com> <1398971693-82399-3-git-send-email-dros@primarydata.com> <6E840B50-223E-462C-B9A7-BC48C6DC5906@primarydata.com> <B1C09779-BB74-433F-8925-B78F1B4B7CC7@primarydata.com> <07E33EF3-5D17-4B0A-A469-34839C39CFC5@primarydata.com>
To: Weston Andros Adamson <dros@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On May 2, 2014, at 12:22 PM, Weston Andros Adamson <dros@primarydata.com> wrote:

> On May 1, 2014, at 4:56 PM, Weston Andros Adamson <dros@primarydata.com> wrote:
> 
>> 
>> 
>> On May 1, 2014, at 4:19 PM, Trond Myklebust <trond.myklebust@primarydata.com> wrote:
>> 
>>> 
>>> On May 1, 2014, at 15:14, Weston Andros Adamson <dros@primarydata.com> wrote:
>>> 
>>>> diff --git a/include/linux/nfs_xdr.h b/include/linux/nfs_xdr.h
>>>> index a7ccc8c..8564539 100644
>>>> --- a/include/linux/nfs_xdr.h
>>>> +++ b/include/linux/nfs_xdr.h
>>>> @@ -1261,13 +1261,13 @@ struct nfs_pgio_data {
>>>> 	struct list_head	list;
>>>> 	struct rpc_task		task;
>>>> 	struct nfs_fattr	fattr;
>>>> -	struct nfs_writeverf	verf;		/* Used for writes */
>>>> +	struct nfs_writeverf	rpc_verf;	/* Used for writes */
>>> 
>>> Can we just make this “writeverf"? It isn’t really an rpc object, so the ‘rpc_’ prefix seems a little misleading.
>> 
>> yes, good point.
>> 
>> -dros
>> 
> 
> Actually, having a verf in the header and in pgio_data is redundant now that there is only one pgio_data (the
> header verf was used to make sure that all pgio_data verfs matched).
> 
> I’ll remove rpc_verf.

I should point out that the header verf is also used to compare the WRITE verf(s) with the COMMIT verf
(from nfs_commit_data), but this will stay the same.

-dros


>>> 
>>>> 	struct nfs_pgio_args	args;		/* argument struct */
>>>> 	struct nfs_pgio_res	res;		/* result struct */
>>>> 	unsigned long		timestamp;	/* For lease renewal */
>>>> 	int (*pgio_done_cb)(struct rpc_task *task, struct nfs_pgio_data *data);
>>>> 	__u64			mds_offset;	/* Filelayout dense stripe */
>>>> -	struct nfs_page_array	pages;
>>>> +	struct nfs_page_array	page_array;
>>>> 	struct nfs_client	*ds_clp;	/* pNFS data server */
>>>> 	int			ds_idx;		/* ds index if ds_clp is set */
>>>> };
>>>> -- 
>>>> 1.8.5.2 (Apple Git-48)
>>>> 
>>> 
>>> _________________________________
>>> Trond Myklebust
>>> Linux NFS client maintainer, PrimaryData
>>> trond.myklebust@primarydata.com
>>> 
>> 
> 
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html


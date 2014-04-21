Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-qc0-f178.google.com ([209.85.216.178]:51578 "EHLO
	mail-qc0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751323AbaDUMoF (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 21 Apr 2014 08:44:05 -0400
Received: by mail-qc0-f178.google.com with SMTP id i8so3982144qcq.9
        for <linux-nfs@vger.kernel.org>; Mon, 21 Apr 2014 05:44:04 -0700 (PDT)
Message-ID: <53551292.20003@gmail.com>
Date: Mon, 21 Apr 2014 08:44:02 -0400
From: Anna Schumaker <schumaker.anna@gmail.com>
MIME-Version: 1.0
To: Christoph Hellwig <hch@infradead.org>,
        Anna Schumaker <Anna.Schumaker@netapp.com>
CC: Trond.Myklebust@primarydata.com, linux-nfs@vger.kernel.org
Subject: Re: [PATCH 01/17] NFS: Create a common argument structure for reads
 and writes
References: <1397768981-12856-1-git-send-email-Anna.Schumaker@Netapp.com> <1397768981-12856-2-git-send-email-Anna.Schumaker@Netapp.com> <20140418135612.GA20096@infradead.org>
In-Reply-To: <20140418135612.GA20096@infradead.org>
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 04/18/2014 09:56 AM, Christoph Hellwig wrote:
>>  /*
>> + * Arguments shared by the read and write call.
>> + */
>> +struct nfs_pgio_args {
>> +	struct nfs4_sequence_args	seq_args;
>> +	struct nfs_fh *		fh;
>> +	struct nfs_open_context *context;
>> +	struct nfs_lock_context *lock_context;
>> +	nfs4_stateid		stateid;
>> +	__u64			offset;
>> +	__u32			count;
>> +	enum nfs3_stable_how	stable;		/* used by write */
>> +	unsigned int		pgbase;
>> +	struct page **		pages;
>> +	const u32 *		bitmask;	/* used by write */
>> +};
> It might make sense to keep the arguments only used for writes together
> at the end of the structure.

Makes sense.  I'll fix that up, thanks!

Anna

>
> Otherwise looks good,
>
> Reviewed-by: Christoph Hellwig <hch@lst.de>
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html


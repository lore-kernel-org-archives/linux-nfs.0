From: Benny Halevy <bhalevy@tonian.com>
Subject: Re: [PATCH] pnfsblock: init pg_bsize properly
Date: Wed, 17 Aug 2011 10:15:13 +0300
Message-ID: <4E4B6A81.2010204@tonian.com>
References: <1313197450-4595-1-git-send-email-bergwolf@gmail.com> <4E4ADBA1.1000005@panasas.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: Peng Tao <bergwolf@gmail.com>, benny@tonian.com,
	linux-nfs@vger.kernel.org, Peng Tao <peng_tao@emc.com>
To: Boaz Harrosh <bharrosh@panasas.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-ww0-f44.google.com ([74.125.82.44]:59179 "EHLO
	mail-ww0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751588Ab1HQHOy (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 17 Aug 2011 03:14:54 -0400
Received: by wwf5 with SMTP id 5so709286wwf.1
        for <linux-nfs@vger.kernel.org>; Wed, 17 Aug 2011 00:14:53 -0700 (PDT)
In-Reply-To: <4E4ADBA1.1000005@panasas.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


On 2011-08-17 00:05, Boaz Harrosh wrote:
> On 08/12/2011 06:04 PM, Peng Tao wrote:
>> pg_bsize is server->wsize/rsize by default. We would want to use the lseg length.
>>
> 
> Hi
> 
> What is the problem you are trying to solve with this patch?
> 
> From what I understand the only place that actually cares about
> pg_bsize is nfs_generic_pg_test() which is only used in MDS
> read/write. In the pNFS RW, the LD and pnfs has it's own .pg_test()
> check that should not concern with pg_bsize (Unless for pnfs-files
> which does). So the idea is that pg_bsize is the maximum set by
> MDS server in regard to IO through MDS. And it should not be changed
> by client.
> 
> If it is not what you see then we should fix it. But should never
> override MDS wsize/rsize.

I second that.

Benny

> 
>> Signed-off-by: Peng Tao <peng_tao@emc.com>
>> ---
>>  fs/nfs/blocklayout/blocklayout.c |   20 ++++++++++++++++++--
>>  1 files changed, 18 insertions(+), 2 deletions(-)
>>
>> diff --git a/fs/nfs/blocklayout/blocklayout.c b/fs/nfs/blocklayout/blocklayout.c
>> index 36648e1..9143e61 100644
>> --- a/fs/nfs/blocklayout/blocklayout.c
>> +++ b/fs/nfs/blocklayout/blocklayout.c
>> @@ -919,14 +919,30 @@ bl_clear_layoutdriver(struct nfs_server *server)
>>  	return 0;
>>  }
>>  
>> +static void bl_pg_init_read(struct nfs_pageio_descriptor *pgio,
>> +			    struct nfs_page *req)
>> +{
>> +	pnfs_generic_pg_init_read(pgio, req);
>> +	if (pgio->pg_lseg)
>> +		pgio->pg_bsize = pgio->pg_lseg->pls_range.length;
>> +}
>> +
>> +static void bl_pg_init_write(struct nfs_pageio_descriptor *pgio,
>> +			     struct nfs_page *req)
>> +{
>> +	pnfs_generic_pg_init_write(pgio, req);
>> +	if (pgio->pg_lseg)
>> +		pgio->pg_bsize = pgio->pg_lseg->pls_range.length;
>> +}
>> +
>>  static const struct nfs_pageio_ops bl_pg_read_ops = {
>> -	.pg_init = pnfs_generic_pg_init_read,
>> +	.pg_init = bl_pg_init_read,
>>  	.pg_test = pnfs_generic_pg_test,
> 
> I see here that you do not override .pg_test. This is your problem
> look at objio_osd::objio_pg_test() it checks for similar boundaries
> at the objects side. This is where you need to do these checks
> for blocks as well.
> 
>>  	.pg_doio = pnfs_generic_pg_readpages,
>>  };
>>  
>>  static const struct nfs_pageio_ops bl_pg_write_ops = {
>> -	.pg_init = pnfs_generic_pg_init_write,
>> +	.pg_init = bl_pg_init_write,
>>  	.pg_test = pnfs_generic_pg_test,
> 
> Same here
> 
>>  	.pg_doio = pnfs_generic_pg_writepages,
>>  };
> 
> Thanks
> Boaz
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-pv0-f174.google.com ([74.125.83.174]:54403 "EHLO
	mail-pv0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756775Ab0EMDCA convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 12 May 2010 23:02:00 -0400
Received: by pvg12 with SMTP id 12so113539pvg.19
        for <linux-nfs@vger.kernel.org>; Wed, 12 May 2010 20:01:59 -0700 (PDT)
In-Reply-To: <AANLkTilCfQl5zM9cap4vJSbFfJQ8OvoPNoydif_4DN6T@mail.gmail.com>
References: <20100512074204.GA7643@MDS-78.localdomain>
	 <AANLkTilCfQl5zM9cap4vJSbFfJQ8OvoPNoydif_4DN6T@mail.gmail.com>
Date: Thu, 13 May 2010 11:01:59 +0800
Message-ID: <AANLkTinCK22GlF336-SZhZoboRfyB9Ez_Zo_rPBm90Q0@mail.gmail.com>
Subject: Re: [PATCH] pnfs: set pnfs_curr_ld before calling
	initialize_mountpoint
From: Zhang Jingwang <yyalone@gmail.com>
To: "William A. (Andy) Adamson" <androsadamson@gmail.com>
Cc: linux-nfs@vger.kernel.org, bhalevy@panasas.com
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

2010/5/12 William A. (Andy) Adamson <androsadamson@gmail.com>:
> On Wed, May 12, 2010 at 3:42 AM, Zhang Jingwang
> <zhangjingwang@nrchpc.ac.cn> wrote:
>> initialize_mountpoint will call _nfs4_pnfs_getdevicelist and then
>> pnfs_curr_ld->id is accessed.
>
> Where is pnfs_curr_ld->ld_policy_ops accessed?
In pnfs_set_ds_iosize after set_pnfs_layoutdriver, pnfs_curr_ld is set
in set_pnfs_layoutdriver so it's OK to access
pnfs_curr_ld->ld_policy_ops.

>
> -->Andy
>
>> This introduce a NULL pointer reference.
>>
>> Signed-off-by: Zhang Jingwang <zhangjingwang@nrchpc.ac.cn>
>> ---
>>  fs/nfs/pnfs.c |    2 +-
>>  1 files changed, 1 insertions(+), 1 deletions(-)
>>
>> diff --git a/fs/nfs/pnfs.c b/fs/nfs/pnfs.c
>> index 3739c38..5ad7fc6 100644
>> --- a/fs/nfs/pnfs.c
>> +++ b/fs/nfs/pnfs.c
>> @@ -212,6 +212,7 @@ set_pnfs_layoutdriver(struct nfs_server *server, const struct nfs_fh *mntfh,
>>                return;
>>
>>        if (id > 0 && find_pnfs(id, &mod)) {
>> +               server->pnfs_curr_ld = mod->pnfs_ld_type;
>>                if (mod->pnfs_ld_type->ld_io_ops->initialize_mountpoint(
>>                                                        server, mntfh)) {
>>                        printk(KERN_ERR "%s: Error initializing mount point "
>> @@ -222,7 +223,6 @@ set_pnfs_layoutdriver(struct nfs_server *server, const struct nfs_fh *mntfh,
>>                 * Layout driver succeeded in initializing mountpoint
>>                 * and has taken a reference on the nfs_client cl_devid_cache
>>                 */
>> -               server->pnfs_curr_ld = mod->pnfs_ld_type;
>>                server->nfs_client->rpc_ops = &pnfs_v4_clientops;
>>                dprintk("%s: pNFS module for %u set\n", __func__, id);
>>                return;
>> --
>> 1.6.2.5
>>
>> --
>> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
>> the body of a message to majordomo@vger.kernel.org
>> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>>
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>



-- 
Zhang Jingwang
National Research Centre for High Performance Computers
Institute of Computing Technology, Chinese Academy of Sciences
No. 6, South Kexueyuan Road, Haidian District
Beijing, China

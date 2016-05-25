Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from us-smtp-delivery-194.mimecast.com ([216.205.24.194]:58223 "EHLO
	us-smtp-delivery-194.mimecast.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751853AbcEYOlv convert rfc822-to-8bit
	(ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 25 May 2016 10:41:51 -0400
From: Thomas Haynes <loghyr@primarydata.com>
To: Jeff Layton <jlayton@poochiereds.net>
CC: "J. Bruce Fields" <bfields@fieldses.org>,
        Linux NFS Mailing list <linux-nfs@vger.kernel.org>, hch <hch@lst.de>
Subject: Re: [PATCH 3/4] nfsd: Add a super simple flex file server
Date: Wed, 25 May 2016 14:41:44 +0000
Message-ID: <D723CF25-D851-4523-8960-528700738792@primarydata.com>
References: <1464152979-103988-1-git-send-email-loghyr@primarydata.com>
 <1464152979-103988-4-git-send-email-loghyr@primarydata.com>
 <1464179444.3037.15.camel@poochiereds.net>
In-Reply-To: <1464179444.3037.15.camel@poochiereds.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=WINDOWS-1252
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


> On May 25, 2016, at 5:30 AM, Jeff Layton <jlayton@poochiereds.net> wrote:
> 
> On Tue, 2016-05-24 at 22:09 -0700, Tom Haynes wrote:
>> 
>>  void nfsd4_setup_layout_type(struct svc_export *exp)
>>  {
>> +#if defined(CONFIG_NFSD_BLOCKLAYOUT) || defined(CONFIG_NFSD_SCSILAYOUT)
>>  	struct super_block *sb = exp->ex_path.mnt->mnt_sb;
>> +#endif
>>  
>>  	if (!(exp->ex_flags & NFSEXP_PNFS))
>>  		return;
>> @@ -145,6 +150,11 @@ void nfsd4_setup_layout_type(struct svc_export *exp)
>>  	    sb->s_bdev && sb->s_bdev->bd_disk->fops->pr_ops)
>>  		exp->ex_layout_type = LAYOUT_SCSI;
>>  #endif
>> +#ifdef CONFIG_NFSD_FLEXFILELAYOUT
>> +	// FIXME: How do we "export" this and how does it mingle with
>> +	// the above types?
>> +	exp->ex_layout_type = LAYOUT_FLEX_FILES;
>> +#endif
>>  }
>>  
> 
> Maybe it's time to start thinking about how to support multiple layout types per export? It doesn't look like it would be that hard. I think we could convert ex_layout_type into a bitmap that shows which types are supported.
> 
> The harder work looks to be on the client. You'd need some heuristic to choose when you get back multiple layout types and fix that to work properly.


In thinking about it, if we rearrange the code to be:

void nfsd4_setup_layout_type(struct svc_export *exp)
{
#if defined(CONFIG_NFSD_BLOCKLAYOUT) || defined(CONFIG_NFSD_SCSILAYOUT)
        struct super_block *sb = exp->ex_path.mnt->mnt_sb;
#endif
        
        if (!(exp->ex_flags & NFSEXP_PNFS))
                return;
        
        /*
         * If flex file is configured, use it by default. Otherwise
         * check if the file system supports exporting a block-like layout.
         * If the block device supports reservations prefer the SCSI layout,
         * otherwise advertise the block layout.
         */
#ifdef CONFIG_NFSD_FLEXFILELAYOUT
        // FIXME: How do we "export" this and how does it mingle with
        // the above types? 
        exp->ex_layout_type = LAYOUT_FLEX_FILES;
#endif
#ifdef CONFIG_NFSD_BLOCKLAYOUT
        /* overwrite flex file layout selection if needed */
        if (sb->s_export_op->get_uuid &&
            sb->s_export_op->map_blocks &&
            sb->s_export_op->commit_blocks)
                exp->ex_layout_type = LAYOUT_BLOCK_VOLUME;
#endif
#ifdef CONFIG_NFSD_SCSILAYOUT
        /* overwrite block layout selection if needed */
        if (sb->s_export_op->map_blocks && 
            sb->s_export_op->commit_blocks &&
            sb->s_bdev && sb->s_bdev->bd_disk->fops->pr_ops)
                exp->ex_layout_type = LAYOUT_SCSI;
#endif
}

We get what seems natural.



Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx2.netapp.com ([216.240.18.37]:64859 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S934115Ab2FENgm convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 5 Jun 2012 09:36:42 -0400
From: "Adamson, Andy" <William.Adamson@netapp.com>
To: Boaz Harrosh <bharrosh@panasas.com>
CC: "Myklebust, Trond" <Trond.Myklebust@netapp.com>,
        "<linux-nfs@vger.kernel.org>" <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH 1/3] NFSv4.1 do not call LAYOUTRETURN when there are no
 legs
Date: Tue, 5 Jun 2012 13:36:25 +0000
Message-ID: <AAE6059A-E7A5-4377-A68A-AC6CB90C1666@netapp.com>
References: <1338571178-2096-1-git-send-email-andros@netapp.com>
 <4FCA9B0E.5070304@panasas.com>
In-Reply-To: <4FCA9B0E.5070304@panasas.com>
Content-Type: text/plain; charset="Windows-1252"
MIME-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


On Jun 2, 2012, at 7:00 PM, Boaz Harrosh wrote:

> On 06/01/2012 08:19 PM, andros@netapp.com wrote:
> 
>> From: Andy Adamson <andros@netapp.com>
>> 
> 
> 
> I wish you would send your patches preceded with a [PATCHSET 0/x]
> That gives us a short summery and a little background on its motivation.

I often do. These patches actually stand alone so I didn't this time. 

This patch is totally explained by the patch title, patch comments, and in-line comments. With out this patch, we can end up
sending a LAYOUTRETURN with no layout segments that need to be returned! Why? because as noted in the patch comments, mark_matching_lsegs_invalid does not  indicate when the plh_segs list is empty…etc. When? well, as noted in the in-line code comments, when the pnfs_layout_hdr has an empty plh_segs which an occur when a LAYOUTGET fails, or when LAYOUTGET succeeded, but the deviceid is marked invalid

What else is there to say?!

I guess I can add the --cover-letter to the git format-patch and cut/paste to it.

-->Andy

> 
> For example here, what are the problems you encounter, how did you test
> it and so on...
> 
> Do these actually depend and/or fix your previous "send layout_return ..."
> In files layout?
> 
> (You can still send all patches by git send-email command line just the same
> just add a [PATCHSET 0/x]-xxx-yyy.txt and it will get sent first, right?)
> 
> Thanks
> Boaz
> 
>> mark_matching_lsegs_invalid() does not indicate if the plh_segs list is
>> empty on entrance - and it can be empty on exit.
>> 
>> When the plh_segs list is emtpy, mark_matching_lsegs_invalid removes
>> the pnfs_layout_hdr creation reference.
>> 
>> Signed-off-by: Andy Adamson <andros@netapp.com>
>> ---
>> fs/nfs/pnfs.c |   17 +++++++++++++++--
>> 1 files changed, 15 insertions(+), 2 deletions(-)
>> 
>> diff --git a/fs/nfs/pnfs.c b/fs/nfs/pnfs.c
>> index b8323aa..854df5e 100644
>> --- a/fs/nfs/pnfs.c
>> +++ b/fs/nfs/pnfs.c
>> @@ -646,7 +646,14 @@ out_err_free:
>> 	return NULL;
>> }
>> 
>> -/* Initiates a LAYOUTRETURN(FILE) */
>> +/*
>> + * Initiates a LAYOUTRETURN(FILE), and removes the pnfs_layout_hdr
>> + * when the layout segment list is empty.
>> + *
>> + * Note that a pnfs_layout_hdr can exist with an empty layout segment
>> + * list when LAYOUTGET has failed, or when LAYOUTGET succeeded, but the
>> + * deviceid is marked invalid.
>> + */
>> int
>> _pnfs_return_layout(struct inode *ino)
>> {
>> @@ -655,7 +662,7 @@ _pnfs_return_layout(struct inode *ino)
>> 	LIST_HEAD(tmp_list);
>> 	struct nfs4_layoutreturn *lrp;
>> 	nfs4_stateid stateid;
>> -	int status = 0;
>> +	int status = 0, empty = 0;
>> 
>> 	dprintk("--> %s\n", __func__);
>> 
>> @@ -669,11 +676,17 @@ _pnfs_return_layout(struct inode *ino)
>> 	stateid = nfsi->layout->plh_stateid;
>> 	/* Reference matched in nfs4_layoutreturn_release */
>> 	get_layout_hdr(lo);
>> +	empty = list_empty(&lo->plh_segs);
>> 	mark_matching_lsegs_invalid(lo, &tmp_list, NULL);
>> 	lo->plh_block_lgets++;
>> 	spin_unlock(&ino->i_lock);
>> 	pnfs_free_lseg_list(&tmp_list);
>> 
>> +	if (empty) {
>> +		put_layout_hdr(lo);
>> +		dprintk("%s: no layout segments to return\n", __func__);
>> +		return status;
>> +	}
>> 	WARN_ON(test_bit(NFS_INO_LAYOUTCOMMIT, &nfsi->flags));
>> 
>> 	lrp = kzalloc(sizeof(*lrp), GFP_KERNEL);
> 
> 


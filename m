Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:37227 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751924Ab0LWVJv convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 23 Dec 2010 16:09:51 -0500
Subject: Re: [PATCH 13/15] pnfs: add CB_LAYOUTRECALL handling
Content-Type: text/plain; charset=us-ascii
From: Fred Isaman <iisaman@netapp.com>
In-Reply-To: <1293138328.8958.14.camel@heimdal.trondhjem.org>
Date: Thu, 23 Dec 2010 16:09:50 -0500
Cc: linux-nfs@vger.kernel.org
Message-Id: <4C3168F4-73E5-4A36-97AB-B72C6D2A48F3@netapp.com>
References: <1293125397-30088-1-git-send-email-iisaman@netapp.com> <1293125397-30088-14-git-send-email-iisaman@netapp.com> <1293132324.2938.47.camel@heimdal.trondhjem.org> <035D666D-8867-444D-B0BE-8F2C87D766E1@netapp.com> <1293138328.8958.14.camel@heimdal.trondhjem.org>
To: Trond Myklebust <Trond.Myklebust@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0


On Dec 23, 2010, at 4:05 PM, Trond Myklebust wrote:

> On Thu, 2010-12-23 at 15:08 -0500, Fred Isaman wrote:
>> On Dec 23, 2010, at 2:25 PM, Trond Myklebust wrote:
>> 
>>> On Thu, 2010-12-23 at 12:29 -0500, Fred Isaman wrote:
>>>> +
>>>> +	if (args->cbl_recall_type == RETURN_FILE) {
>>>> +		LIST_HEAD(free_me_list);
>>>> +
>>>> +		args->cbl_inode = NULL;
>>>> +		spin_lock(&clp->cl_lock);
>>>> +		list_for_each_entry(lo, &clp->cl_layouts, plh_layouts) {
>>>> +			if (nfs_compare_fh(&args->cbl_fh,
>>>> +					   &NFS_I(lo->plh_inode)->fh))
>>>> +				continue;
>>>> +			if (test_bit(NFS_LAYOUT_BULK_RECALL, &lo->plh_flags))
>>>> +				rv = NFS4ERR_DELAY;
>>>> +			else {
>>>> +				/* Without this, layout can be freed as soon
>>>> +				 * as we release cl_lock.  Matched in
>>>> +				 * do_callback_layoutrecall.
>>>> +				 */
>>>> +				get_layout_hdr(lo);
>>>> +				args->cbl_inode = lo->plh_inode;
>>>> +				rv = NFS4_OK;
>>>> +			}
>>>> +			break;
>>>> +		}
>>>> +		spin_unlock(&clp->cl_lock);
>>>> +
>>>> +		spin_lock(&lo->plh_inode->i_lock);
>>> 
>>> What guarantees do you have that the inode still exists here? Does the
>>> layout segment hold a reference to it?
>>> 
>> 
>> This section is why I once asked about whether the layout needs to reference the inode.  I believe the answer is nothing.  The lseg/layout definitely does not hold direct references.  I assume doing grab/put of inode here and below is acceptable?
> 
> igrab/iput is fine in this context.
> 
> There is also the question: what if we don't find a match for the layout
> recall arguments? It looks to me as if we end up with 'lo ==
> clp->cl_layouts', with disastrous consequences when we then do
> spin_lock(lo->plh_inode->i_lock)...
> 

gah, you're right.  I'll get that fixed too.

Fred

>>> Also, How do you know that (!test_bit(NFS_LAYOUT_BULK_RECALL,
>>> &lo->plh_flags)) is still valid when you get here?
>>> 
>> 
>> Because it can not be set elsewhere while the NFS4CLNT_LAYOUTRECALL bit is set.
> 
> OK. One race averted :-)
> 
> -- 
> Trond Myklebust
> Linux NFS client maintainer
> 
> NetApp
> Trond.Myklebust@netapp.com
> www.netapp.com
> 


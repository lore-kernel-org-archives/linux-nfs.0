Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from daytona.panasas.com ([67.152.220.89]:31179 "EHLO
	daytona.int.panasas.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1755296Ab0KNLuW (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sun, 14 Nov 2010 06:50:22 -0500
Message-ID: <4CDFCCFB.4000402@panasas.com>
Date: Sun, 14 Nov 2010 13:50:19 +0200
From: Benny Halevy <bhalevy@panasas.com>
To: Benny Halevy <bhalevy@panasas.com>
CC: Trond Myklebust <trond.myklebust@fys.uio.no>,
        Fred Isaman <iisaman@netapp.com>, linux-nfs@vger.kernel.org
Subject: Re: [PATCH 16/22] pnfs-submit: rewrite of layout state handling and
 cb_layoutrecall
References: <1289551724-18575-1-git-send-email-iisaman@netapp.com>	 <1289551724-18575-17-git-send-email-iisaman@netapp.com> <1289639517.3669.9.camel@heimdal.trondhjem.org> <4CDFCB8D.7040209@panasas.com>
In-Reply-To: <4CDFCB8D.7040209@panasas.com>
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On 2010-11-14 13:44, Benny Halevy wrote:
> On 2010-11-13 11:11, Trond Myklebust wrote:
>> On Fri, 2010-11-12 at 03:48 -0500, Fred Isaman wrote:
>>> +	switch (cb_args->cbl_recall_type) {
>>> +	case RETURN_ALL:
>>> +		return true;
>>> +	case RETURN_FSID:
>>> +		return !memcmp(&NFS_SERVER(ino)->fsid, &cb_args->cbl_fsid,
>>> +			       sizeof(struct nfs_fsid));
>>> +	case RETURN_FILE:
>>> +		return (ino == cb_info->pcl_ino) &&
>>> +			should_free_lseg(range, &cb_args->cbl_range);
>>> +	default:
>>> +		BUG();
>>
>> Why should we BUG() just because the server is screwed up? That's not a
>> client bug.
>>
> 
> Agreed.  This should be handled earlier in nfs4_callback_layoutrecall
> or do_callback_layoutrecall so that we can return NFS4ERR_INVALID.
> 

Actually NFS4ERR_BADXDR is the right error to return for a
"value within the input stream that is not valid for the enum"

Benny

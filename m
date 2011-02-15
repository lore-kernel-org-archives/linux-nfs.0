Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:29011 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750857Ab1BOOwH convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 15 Feb 2011 09:52:07 -0500
Subject: Re: [PATCH 01/16] NFS remove unnecessary CONFIG_NFS_V4 from nfs_read_data
Content-Type: text/plain; charset=us-ascii
From: Andy Adamson <andros@netapp.com>
In-Reply-To: <20110215091618.GA29871@infradead.org>
Date: Tue, 15 Feb 2011 09:51:49 -0500
Cc: trond.myklebust@netapp.com, linux-nfs@vger.kernel.org
Message-Id: <2D037026-0D3A-4D8B-B2CF-F0C1DB590756@netapp.com>
References: <1297711116-3139-1-git-send-email-andros@netapp.com> <1297711116-3139-2-git-send-email-andros@netapp.com> <20110215091618.GA29871@infradead.org>
To: Christoph Hellwig <hch@infradead.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0


On Feb 15, 2011, at 4:16 AM, Christoph Hellwig wrote:

> On Mon, Feb 14, 2011 at 02:18:21PM -0500, andros@netapp.com wrote:
>> From: Andy Adamson <andros@netapp.com>
>> 
>> Signed-off-by: Andy Adamson <andros@netapp.com>
> 
> Either the patch or the description is incorrect.  If you actually need
> it for NFSv2/3 the description should say it.  Otherwise it's just a
> "cleanup" which bloats the structure for people not having v4 support
> compiled in.

It is just a clean-up per Trond's request to just get rid of the CONFIG_NFS_V4 and CONFIG_NFS_V4_1 ifdef's in struct nfs_read_data.  I'll change the description to match.

-->Andy

> 
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html


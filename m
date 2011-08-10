Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mailgw1.uni-kl.de ([131.246.120.220]:52022 "EHLO
	mailgw1.uni-kl.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753890Ab1HJTNN (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 10 Aug 2011 15:13:13 -0400
Message-ID: <4E42D845.7060905@itwm.fraunhofer.de>
Date: Wed, 10 Aug 2011 21:13:09 +0200
From: Bernd Schubert <bernd.schubert@itwm.fraunhofer.de>
To: "J. Bruce Fields" <bfields@fieldses.org>
CC: linux-nfs@vger.kernel.org, linux-ext4@vger.kernel.org, hch@infradead.org,
        yong.fan@whamcloud.com, linux-fsdevel@vger.kernel.org, tytso@mit.edu,
        adilger@whamcloud.com
Subject: Re: [PATCH 4/4] nfsd: vfs_llseek() with 32 or 64 bit offsets (hashes)
References: <20110808153432.1872437.85783.stgit@fsdevel3> <20110808153813.1872437.44997.stgit@fsdevel3> <20110809173342.GB16206@fieldses.org>
In-Reply-To: <20110809173342.GB16206@fieldses.org>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On 08/09/2011 07:33 PM, J. Bruce Fields wrote:
> On Mon, Aug 08, 2011 at 05:38:13PM +0200, Bernd Schubert wrote:
>> Use 32-bit or 64-bit llseek() hashes for directory offsets depending on
>> the NFS version. NFSv2 gets 32-bit hashes only.
>>
>> NOTE: This patch got rather complex as Christoph asked to set the
>> filp->f_mode flag in the open call or immediatly after dentry_open()
>> in nfsd_open() to avoid races.
>> Personally I still do not see a reason for that and in my opinion
>> FMODE_32BITHASH/FMODE_64BITHASH flags could be set nfsd_readdir(), as it
>> follows directly after nfsd_open() without a chance of races.
>
> The bulk of the patch seems to be just an access->may_flags rename.
> Could you please split that into a separate patch?

Ok, shall I resend the entire patch series, but already remove the 
32-bit nfsd_readdir() cookie patch? Or only just this patch split into 
to parts?


Thanks,
Bernd

Return-Path: linux-nfs-owner@vger.kernel.org
Received: from static-209-166-131-148.expedient.com ([209.166.131.148]:35449
	"EHLO natasha.panasas.com" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1752771Ab3LCKlZ (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 3 Dec 2013 05:41:25 -0500
Message-ID: <529DB536.7050008@panasas.com>
Date: Tue, 3 Dec 2013 12:40:54 +0200
From: Boaz Harrosh <bharrosh@panasas.com>
MIME-Version: 1.0
To: Christoph Hellwig <hch@infradead.org>
CC: <linux-fsdevel@vger.kernel.org>, <xfs@oss.sgi.com>,
        NFS list <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH] fs: fix iversion handling
References: <20131119151707.GA13412@infradead.org> <20131202173636.GA17724@infradead.org> <529DA5C6.7040403@panasas.com> <20131203094507.GD4906@infradead.org>
In-Reply-To: <20131203094507.GD4906@infradead.org>
Content-Type: text/plain; charset="UTF-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 12/03/2013 11:45 AM, Christoph Hellwig wrote:
> On Tue, Dec 03, 2013 at 11:35:02AM +0200, Boaz Harrosh wrote:
>> Hi Christoph
>>
>> What happens with all other filesystems exported under KNFSD?
>>
>> As I understand inode_inc_iversion() is used in NFSv4 and up,
>> what will increment the inode-version on changed attributes
>> for them?
> 
> It's used by the filesystem for the change attribute that NFSDd
> can optionally use.  Most filesystsems don't support it and work
> okay enough when NFS exported.  No other filesystem will need
> to adopt for this patch specificly, given that no other filesystem
> uses this infrastructure.
> 

OK Thanks, I did not know that. I assumed change-attribute is
naturally supported.

I will look at ext4 example and wire up exofs. Because it is very
important for me to support the change-attribute properly.

Thanks you
Boaz


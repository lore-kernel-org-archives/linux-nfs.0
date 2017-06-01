Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:39824 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751058AbdFALtp (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Thu, 1 Jun 2017 07:49:45 -0400
From: "Benjamin Coddington" <bcodding@redhat.com>
To: "Jeff Layton" <jlayton@redhat.com>
Cc: "kernel test robot" <xiaolong.ye@intel.com>,
        "Alexander Viro" <viro@zeniv.linux.org.uk>, bfields@fieldses.org,
        linux-fsdevel@vger.kernel.org, linux-nfs@vger.kernel.org,
        lkp@01.org, "Christoph Hellwig" <hch@infradead.org>
Subject: Re: [lkp-robot] [fs/locks]  9d21d181d0: will-it-scale.per_process_ops
 -14.1% regression
Date: Thu, 01 Jun 2017 07:49:39 -0400
Message-ID: <8F2C3CFF-5C2D-41B0-A895-B1F074DA7943@redhat.com>
In-Reply-To: <1496317284.2845.4.camel@redhat.com>
References: <20170601020556.GE16905@yexl-desktop>
 <1496317284.2845.4.camel@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; format=flowed
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 1 Jun 2017, at 7:41, Jeff Layton wrote:

> On Thu, 2017-06-01 at 10:05 +0800, kernel test robot wrote:
>> Greeting,
>>
>> FYI, we noticed a -14.1% regression of will-it-scale.per_process_ops 
>> due to commit:
>>
>>
>> commit: 9d21d181d06acab9a8e80eac2ec4eed77b656793 ("fs/locks: Set 
>> fl_nspid at file_lock allocation")
>> url: 
>> https://github.com/0day-ci/linux/commits/Benjamin-Coddington/fs-locks-Alloc-file_lock-where-practical/20170527-050700
>>
>>
>
> Ouch, that's a rather nasty performance hit. In hindsight, maybe we
> shouldn't move those off the stack after all? Heck, if it's that
> significant, maybe we should move the F_SETLK callers to allocate 
> these
> on the stack as well?

We can do that.  But, I think this is picking up the 
locks_mandatory_area()
allocation which is now removed.  The attached config has
CONFIG_MANDATORY_FILE_LOCKING=y,  so there's allocation on every 
read/write.

Ben

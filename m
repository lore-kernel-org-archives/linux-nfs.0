Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-db5eur01on0092.outbound.protection.outlook.com ([104.47.2.92]:54920
        "EHLO EUR01-DB5-obe.outbound.protection.outlook.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S964888AbdDSPOj (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Wed, 19 Apr 2017 11:14:39 -0400
Subject: Re: [PATCH 1/4] fs: fix data invalidation in the cleancache during
 direct IO
To: Andrew Morton <akpm@linux-foundation.org>
References: <20170414140753.16108-1-aryabinin@virtuozzo.com>
 <20170414140753.16108-2-aryabinin@virtuozzo.com>
 <20170418154647.9583bfa06705c614a2640a15@linux-foundation.org>
CC: Alexander Viro <viro@zeniv.linux.org.uk>,
        <linux-fsdevel@vger.kernel.org>,
        Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>,
        Eric Van Hensbergen <ericvh@gmail.com>,
        Ron Minnich <rminnich@sandia.gov>,
        Latchesar Ionkov <lucho@ionkov.net>,
        Steve French <sfrench@samba.org>,
        Matthew Wilcox <mawilcox@microsoft.com>,
        Ross Zwisler <ross.zwisler@linux.intel.com>,
        Trond Myklebust <trond.myklebust@primarydata.com>,
        Anna Schumaker <anna.schumaker@netapp.com>,
        Jan Kara <jack@suse.cz>, Jens Axboe <axboe@kernel.dk>,
        Johannes Weiner <hannes@cmpxchg.org>,
        Alexey Kuznetsov <kuznet@virtuozzo.com>,
        Christoph Hellwig <hch@lst.de>,
        <v9fs-developer@lists.sourceforge.net>,
        <linux-kernel@vger.kernel.org>, <linux-cifs@vger.kernel.org>,
        <linux-nfs@vger.kernel.org>, <linux-mm@kvack.org>
From: Andrey Ryabinin <aryabinin@virtuozzo.com>
Message-ID: <64a3f71f-11af-2ab3-c2b5-8e26e03b0ceb@virtuozzo.com>
Date: Wed, 19 Apr 2017 18:15:43 +0300
MIME-Version: 1.0
In-Reply-To: <20170418154647.9583bfa06705c614a2640a15@linux-foundation.org>
Content-Type: text/plain; charset="windows-1252"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>



On 04/19/2017 01:46 AM, Andrew Morton wrote:
> On Fri, 14 Apr 2017 17:07:50 +0300 Andrey Ryabinin <aryabinin@virtuozzo.com> wrote:
> 
>> Some direct write fs hooks call invalidate_inode_pages2[_range]()
>> conditionally iff mapping->nrpages is not zero. If page cache is empty,
>> buffered read following after direct IO write would get stale data from
>> the cleancache.
>>
>> Also it doesn't feel right to check only for ->nrpages because
>> invalidate_inode_pages2[_range] invalidates exceptional entries as well.
>>
>> Fix this by calling invalidate_inode_pages2[_range]() regardless of nrpages
>> state.
> 
> I'm not understanding this.  I can buy the argument about
> nrexceptional, but why does cleancache require the
> invalidate_inode_pages2_range) call even when ->nrpages is zero?
> 
> I *assume* it's because invalidate_inode_pages2_range() calls
> cleancache_invalidate_inode(), yes?  If so, can we please add this to
> the changelog?  If not then please explain further.
> 

Yes, your assumption is correct. I'll fix the changelog.

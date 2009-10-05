From: "Myklebust, Trond" <Trond.Myklebust@netapp.com>
Subject: Re: [PATCH v2] NFS: introduce writeback wait queue
Date: Mon, 5 Oct 2009 06:55:54 -0400
Message-ID: <F047DA72-75B3-4447-84EB-7115C77ECBA3@netapp.com>
References: <20091004030153.GA20327@localhost> <20091005071026.GA19262@localhost> <20091005073551.GA23102@localhost> <20091005073959.GA23398@localhost>
Mime-Version: 1.0 (iPhone Mail 7C144)
Content-Type: text/plain;
	format=flowed;
	delsp=yes;
	charset="us-ascii"
Cc: <jens.axboe@oracle.com>, "Chris Mason" <chris.mason@oracle.com>,
	"Andrew Morton" <akpm@linux-foundation.org>,
	<linux-fsdevel@vger.kernel.org>,
	"LKML" <linux-kernel@vger.kernel.org>, <linux-nfs@vger.kernel.org>
To: "Wu Fengguang" <fengguang.wu@intel.com>
Return-path: <linux-fsdevel-owner@vger.kernel.org>
In-Reply-To: <20091005073959.GA23398@localhost>
Sender: linux-fsdevel-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Oct 5, 2009, at 3:40, "Wu Fengguang" <fengguang.wu@intel.com> wrote:

> On Mon, Oct 05, 2009 at 03:35:51PM +0800, Wu Fengguang wrote:
>> Trond, I see this trace on linux-next. There are no more dirty pages
>> when `cp' aborts after filling up the partition:
>>
>>        cp: writing `/mnt/test/zero3': No space left on device
>>
>> I noticed that since then nr_writeback is decreased very slowly
>> (~100 pages per second). Looks like an interesting behavior.
>
> In the mean time, there are constant 7-8MB/s writes in the NFS server.
> The network flow is much smaller ~400K/s. How can I debug this issue?

Hi Fengguang

This is deliberate behaviour. When asynchronous writes start recieving  
errors, then we switch to synchronous write mode until the error  
condition clears.

The reason is for doing so is firstly because some filesystems (XFS)  
perform very poorly under ENOSPC, and so it takes forever to write  
back pages (we don't want to cancel all writebacks for temporary  
conditions like ENOSPC). It also allows us to deliver the errors more  
promptly to the application.

Cheers
      Trond

>

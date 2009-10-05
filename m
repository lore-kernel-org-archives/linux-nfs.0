From: Jens Axboe <jens.axboe@oracle.com>
Subject: Re: [PATCH] NFS: introduce writeback wait queue
Date: Mon, 5 Oct 2009 13:00:11 +0200
Message-ID: <20091005110010.GW26573@kernel.dk>
References: <20091004030153.GA20327@localhost> <20091004030504.GA20644@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Trond Myklebust <Trond.Myklebust@netapp.com>,
	Andrew Morton <akpm@linux-foundation.org>,
	linux-fsdevel@vger.kernel.org, LKML <linux-kernel@vger.kernel.org>,
	linux-nfs@vger.kernel.org
To: Wu Fengguang <fengguang.wu@intel.com>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S932673AbZJELAt@vger.kernel.org>
In-Reply-To: <20091004030504.GA20644@localhost>
Sender: linux-kernel-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Sun, Oct 04 2009, Wu Fengguang wrote:
> Hi Jens,
> 
> This is a bug fix for 2.6.32. Maybe other not block-queue based
> filesystems will have similar issues ..

Not that I'm aware of, the NFS use is fairly special. Given that this is
purely in the realm of nfs/, I'll let Trond decide how to include and
push this (when a final patch is agreed upon).

Thanks for looking into this!

-- 
Jens Axboe

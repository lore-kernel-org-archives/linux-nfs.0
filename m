From: Jan Kara <jack@suse.cz>
Subject: Re: [PATCH 1/6] VFS: Ensure that writeback_single_inode() commits
 unstable writes
Date: Wed, 6 Jan 2010 22:38:43 +0100
Message-ID: <20100106213843.GD22781@quack.suse.cz>
References: <20100106205110.22547.85345.stgit@localhost.localdomain>
 <20100106205110.22547.17971.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Wu Fengguang <fengguang.wu@intel.com>,
	Peter Zijlstra <peterz@infradead.org>, Jan Kara <jack@suse.cz>,
	Steve Rago <sar-a+KepyhlMvJWk0Htik3J/w@public.gmane.org>,
	"linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>,
	"jens.axboe" <jens.axboe@oracle.com>,
	Peter Staubach <staubach@redhat.com>,
	Arjan van de Ven <arjan@infradead.org>,
	Ingo Molnar <mingo@elte.hu>,
	"linux-fsdevel@vger.kernel.org" <linux-fsdevel@vger.kernel.org>
To: Trond Myklebust <Trond.Myklebust@netapp.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from cantor2.suse.de ([195.135.220.15]:43864 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755759Ab0AFVin (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 6 Jan 2010 16:38:43 -0500
In-Reply-To: <20100106205110.22547.17971.stgit-bi+AKbBUZKY6gyzm1THtWbp2dZbC/Bob@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed 06-01-10 15:51:10, Trond Myklebust wrote:
...
> diff --git a/include/linux/fs.h b/include/linux/fs.h
> index 9147ca8..ea0b7a3 100644
> --- a/include/linux/fs.h
> +++ b/include/linux/fs.h
> @@ -1635,6 +1637,8 @@ struct super_operations {
>  #define I_CLEAR			64
>  #define __I_SYNC		7
>  #define I_SYNC			(1 << __I_SYNC)
> +#define __I_UNSTABLE_PAGES	9
  Hum, why isn't this 8?

							Honza
-- 
Jan Kara <jack@suse.cz>
SUSE Labs, CR

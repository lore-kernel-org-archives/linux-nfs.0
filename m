From: Trond Myklebust <Trond.Myklebust@netapp.com>
Subject: Re: [PATCH 1/6] VFS: Ensure that writeback_single_inode() commits
 unstable writes
Date: Wed, 06 Jan 2010 16:48:37 -0500
Message-ID: <1262814517.4251.163.camel@localhost>
References: <20100106205110.22547.85345.stgit@localhost.localdomain>
	 <20100106205110.22547.17971.stgit@localhost.localdomain>
	 <20100106213843.GD22781@quack.suse.cz>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: Wu Fengguang <fengguang.wu@intel.com>,
	Peter Zijlstra <peterz@infradead.org>,
	Steve Rago <sar-a+KepyhlMvJWk0Htik3J/w@public.gmane.org>,
	"linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>,
	"jens.axboe" <jens.axboe@oracle.com>,
	Peter Staubach <staubach@redhat.com>,
	Arjan van de Ven <arjan@infradead.org>,
	Ingo Molnar <mingo@elte.hu>,
	"linux-fsdevel@vger.kernel.org" <linux-fsdevel@vger.kernel.org>
To: Jan Kara <jack@suse.cz>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:12210 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756336Ab0AFVt3 convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 6 Jan 2010 16:49:29 -0500
In-Reply-To: <20100106213843.GD22781-+0h/O2h83AeN3ZZ/Hiejyg@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, 2010-01-06 at 22:38 +0100, Jan Kara wrote: 
> On Wed 06-01-10 15:51:10, Trond Myklebust wrote:
> ...
> > diff --git a/include/linux/fs.h b/include/linux/fs.h
> > index 9147ca8..ea0b7a3 100644
> > --- a/include/linux/fs.h
> > +++ b/include/linux/fs.h
> > @@ -1635,6 +1637,8 @@ struct super_operations {
> >  #define I_CLEAR			64
> >  #define __I_SYNC		7
> >  #define I_SYNC			(1 << __I_SYNC)
> > +#define __I_UNSTABLE_PAGES	9
>   Hum, why isn't this 8?
> 
> 							Honza

I missed Christoph's patch that got rid of I_LOCK. I think that was
merged after I started work on these patches.

I'd be quite OK with changing the above value to 8 if that is
preferable.

Cheers
  Trond

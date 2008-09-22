From: Aaron Straus <aaron-bYFJunmd+ZV8UrSeD/g0lQ@public.gmane.org>
Subject: Re: [NFS] blocks of zeros (NULLs) in NFS files in kernels >= 2.6.20
Date: Mon, 22 Sep 2008 11:43:11 -0700
Message-ID: <20080922184311.GI12483@merfinllc.com>
References: <20080905191939.GG22796@merfinllc.com> <56258A29-95D5-4A8C-A097-014B8FEDFB8F@oracle.com> <20080911184951.GB19054@merfinllc.com> <200809221805.48463.hpj@urpla.net> <1222101322.7615.6.camel@localhost> <20080922170414.GC12483@merfinllc.com> <1222104541.7615.23.camel@localhost> <20080922174525.GF12483@merfinllc.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Hans-Peter Jansen <hpj-2x7n3sizJbFeoWH0uzbU5w@public.gmane.org>, linux-kernel@vger.kernel.org,
	Chuck Lever <chuck.lever@oracle.com>,
	Neil Brown <neilb@suse.de>,
	Linux NFS Mailing List <linux-nfs@vger.kernel.org>
To: Trond Myklebust <trond.myklebust@fys.uio.no>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from quackingmoose.com ([63.73.180.143]:46746 "EHLO
	penguin.merfinllc.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1753343AbYIVSnN (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 22 Sep 2008 14:43:13 -0400
In-Reply-To: <20080922174525.GF12483-bYFJunmd+ZV8UrSeD/g0lQ@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi,

On Sep 22 10:45 AM, Aaron Straus wrote:
> > diff --git a/fs/nfs/write.c b/fs/nfs/write.c
> > index 3229e21..eb6b211 100644
> > --- a/fs/nfs/write.c
> > +++ b/fs/nfs/write.c
> > @@ -1428,7 +1428,8 @@ static int nfs_write_mapping(struct address_space *mapping, int how)
> >  		.sync_mode = WB_SYNC_NONE,
> >  		.nr_to_write = LONG_MAX,
> >  		.for_writepages = 1,
> > -		.range_cyclic = 1,
> > +		.range_start = 0,
> > +		.range_end = LLONG_MAX,
> >  	};
> >  	int ret;
> >  
> 
> Also, I should test this, but I thought the VM was calling
> nfs_writepages directly i.e. not going through nfs_write_mapping.  Let
> me test with this patch.

Yes.  This patch doesn't seem to help.  The VM is calling nfs_writepages
directly.   I have debug statements in the nfs_write_mapping() call and it
hasn't been called when the hole appears.

It's the VM dirty page writeout that is happening out of order, *not*
nfs_wb_* stuff.   That's why we can see it so easily.  The dirty pages
are only scanned periodically.  In-between scans is when we see the
hole.

I think :).  I'm obviously not an expert here.

					Thanks,
					=a=


-- 
===================
Aaron Straus
aaron-bYFJunmd+ZV8UrSeD/g0lQ@public.gmane.org

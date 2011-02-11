Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([174.143.236.118]:57863 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754584Ab1BKPhG (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 11 Feb 2011 10:37:06 -0500
Date: Fri, 11 Feb 2011 10:37:02 -0500
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Takashi Iwai <tiwai@suse.de>
Cc: Tino Keitel <tino.keitel@tikei.de>, Neil Brown <neilb@suse.de>,
        Trond Myklebust <Trond.Myklebust@netapp.com>,
        linux-nfs@vger.kernel.org, linux-kernel@vger.kernel.org
Subject: Re: 2.6.38-rc3: kernel BUG at fs/nfsd/nfs4state.c:3132!
Message-ID: <20110211153702.GC3005@fieldses.org>
References: <20110208221235.GA16984@mac.home>
 <s5hsjvuoqqt.wl%tiwai@suse.de>
 <20110211152112.GA3005@fieldses.org>
 <s5h62sqbnd7.wl%tiwai@suse.de>
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <s5h62sqbnd7.wl%tiwai@suse.de>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Fri, Feb 11, 2011 at 04:29:56PM +0100, Takashi Iwai wrote:
> At Fri, 11 Feb 2011 10:21:12 -0500,
> J. Bruce Fields wrote:
> > Again, 2.6.38-rc4 does not have a BUG() on line 3132.  Could you post
> > the full oops message from your machine?
> 
> Well, on vanilla 2.6.38-rc4, it's in nfs4_preprocess_stateid_op():
>                if (filpp) {
>                         *filpp = find_readable_file(dp->dl_file);
> ==>                     BUG_ON(!*filpp);
>                 }

Oh good grief, my apologies--I mistyped "38" as "28"!

This looks like it could be a known delegation bug....  Would it be
possible for you to check whether this is reproduceable on

	git://linux-nfs.org/~bfields/topics.git for-2.6.38-incoming

?

--b.

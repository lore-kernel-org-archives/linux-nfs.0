From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: Possible-Patch: unregister bdi on error path.
Date: Wed, 10 Mar 2010 19:40:33 -0500
Message-ID: <1268268033.22310.5.camel@localhost.localdomain>
References: <19352.6543.377883.277948@notabene.brown>
	 <1268262107.3096.207.camel@localhost.localdomain>
	 <20100311112231.7db30fd5@notabene.brown>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: linux-nfs@vger.kernel.org
To: Neil Brown <neilb@suse.de>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-out2.uio.no ([129.240.10.58]:41793 "EHLO mail-out2.uio.no"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932973Ab0CKAkl (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 10 Mar 2010 19:40:41 -0500
In-Reply-To: <20100311112231.7db30fd5-wvvUuzkyo1EYVZTmpyfIwg@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, 2010-03-11 at 11:22 +1100, Neil Brown wrote: 
> On Wed, 10 Mar 2010 18:01:47 -0500
> Trond Myklebust <trond.myklebust@fys.uio.no> wrote:
> 
> > Yes. It looks as if you have indeed found a bug.
> > 
> > My main comment is that in order to be complete the patch should also
> > address the cases of nfs_xdev_get_sb(), nfs4_remote_get_sb(),
> > nfs4_xdev_get_sb(), and nfs4_remote_referral_get_sb(). They appear to
> > suffer from the same problem...
> > 
> 
> Good point.  Patch follows.
> I have compile-tested this but nothing more.  I'm not even sure how I can
> test it as it only affect error paths that are not easy to force.

Agreed that it is faith based patching :-) but I'm willing to go with
that unless someone can show me that your argument is incorrect.

Will apply...

Cheers
  Trond


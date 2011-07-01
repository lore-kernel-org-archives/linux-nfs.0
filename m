Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([174.143.236.118]:58518 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756716Ab1GAU4S (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 1 Jul 2011 16:56:18 -0400
Date: Fri, 1 Jul 2011 16:56:14 -0400
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Steve Dickson <SteveD@redhat.com>
Cc: NeilBrown <neilb@suse.de>, Prem Karat <prem.karat@linux.vnet.ibm.com>,
        linux-nfs@vger.kernel.org
Subject: Re: [PATCH 1/1] nfs-utils: Don't hard code source and destination
 args
Message-ID: <20110701205614.GB28203@fieldses.org>
References: <20110628104138.GB6600@d6fc318.ibm.com>
 <4E0B3687.6060209@RedHat.com>
 <20110630090932.10caeca6@notabene.brown>
 <4E0C56BC.7010606@RedHat.com>
 <20110630211026.66f1b7b4@notabene.brown>
 <4E0C5BB0.5030004@RedHat.com>
 <20110630174005.GA18713@fieldses.org>
 <4E0E284C.9020802@RedHat.com>
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <4E0E284C.9020802@RedHat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Fri, Jul 01, 2011 at 04:04:28PM -0400, Steve Dickson wrote:
> On 06/30/2011 01:40 PM, J. Bruce Fields wrote:
> > Dumb question, as I haven't been following the libmount stuff, but: how
> > soon before we can throw out the non-libmount code?
> The switch has been throw in Fedora Rawhide/Fedora 16.
> 
> > 
> > Looks like patching and maintaining both is a pain.
> Likes like??  Boy, you have 20/20 8-) 
>  
> > 
> > Could we get away with saying "if you want a non-libmount-based mount,
> > feel free to go checkout 1.2.4 or earlier, and backport security fixes
> > to it yourself if you want", and just rip it out now?
> Well we would not rip it out the code, we would just change the default to 
> always use the libmount code and have a --disable-libmount config flag
> for people that don't have the libmount code.... I'm thinking that
> patch would fairly trivial... 

Yeah, understood, that's why I was asking when we could actually rip out
all the code.  As long as it's still there, people may be tempted to use
it, which means you're stuck maintaining it.

--b.

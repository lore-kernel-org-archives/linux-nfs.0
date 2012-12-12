Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:60349 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754076Ab2LLS6A (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 12 Dec 2012 13:58:00 -0500
Date: Wed, 12 Dec 2012 13:57:57 -0500
To: Sven Geggus <lists@fuchsschwanzdomain.de>
Cc: linux-nfs@vger.kernel.org
Subject: Re: Kernel update 3.5.7 -> 3.6.3 breaks NFS4
Message-ID: <20121212185757.GA17868@fieldses.org>
References: <E1TWxKX-00025I-J2@diesel.geggus.net>
 <20121109232410.GK6171@fieldses.org>
 <20121112091717.GA1610@geggus.net>
 <20121113224005.GA11545@fieldses.org>
 <20121114005815.GA23604@fieldses.org>
 <20121114160712.GG23604@fieldses.org>
 <20121114160808.GH23604@fieldses.org>
 <20121115165823.GA5505@geggus.net>
 <20121116191934.GA6358@fieldses.org>
 <ka9p0f$7nc$1@ultimate100.geggus.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <ka9p0f$7nc$1@ultimate100.geggus.net>
From: "J. Bruce Fields" <bfields@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Please don't drop me off the cc: line.

On Wed, Dec 12, 2012 at 11:15:27AM +0000, Sven Geggus wrote:
> J. Bruce Fields <bfields@fieldses.org> wrote:
> 
> >> OK, so this can be marked as resolved (for now) on my todo list, right? Will
> >> this go into 3.6.7 and of course 3.7?
> > 
> > Yep, I'll pass this along by next week.
> 
> As 3.7 has been relased now:
> 
> It looks like the unreverted Version is still present in Linux 3.7.0 as well
> as 3.6.10
> 
> While it is easy enough to use
> "git revert bbf43dc888833ac0539e437dbaeb28bfd4fbab9f" I would rather be able
> to use vanilla kernels again.

Right, apologies, I ended up deciding to hold that for the merge window.
It's marked for stable so should make it into 3.7.x as well.

--b.

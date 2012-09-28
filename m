Return-Path: linux-nfs-owner@vger.kernel.org
Received: from cantor2.suse.de ([195.135.220.15]:42182 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756000Ab2I1CUB convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 27 Sep 2012 22:20:01 -0400
Subject: Re: [REGRESSION] nfsd crashing with 3.6.0-rc7 on PowerPC
Mime-Version: 1.0 (Apple Message framework v1278)
Content-Type: text/plain; charset=US-ASCII
From: Alexander Graf <agraf@suse.de>
In-Reply-To: <CA+55aFyXwB1QcXE4Z_FAGnXROSgvP2x2+wjnX9OWPa4Dfaaf0A@mail.gmail.com>
Date: Fri, 28 Sep 2012 04:19:55 +0200
Cc: LKML List <linux-kernel@vger.kernel.org>,
        linuxppc-dev <linuxppc-dev@lists.ozlabs.org>,
        Benjamin Herrenschmidt <benh@kernel.crashing.org>,
        linux-nfs@vger.kernel.org, Jan Kara <jack@suse.cz>,
        skinsbursky@parallels.com, bfields@redhat.com
Message-Id: <DC545CD9-8745-47DD-B13B-3385C0EB5B27@suse.de>
References: <3BDA9E62-7031-42D6-8CA9-5327B61700F5@suse.de> <CA+55aFyXwB1QcXE4Z_FAGnXROSgvP2x2+wjnX9OWPa4Dfaaf0A@mail.gmail.com>
To: Linus Torvalds <torvalds@linux-foundation.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


On 28.09.2012, at 04:04, Linus Torvalds wrote:

> On Thu, Sep 27, 2012 at 6:55 PM, Alexander Graf <agraf@suse.de> wrote:
>> 
>> Below are OOPS excerpts from different rc's I tried. All of them crashed - all the way up to current Linus' master branch. I haven't cross-checked, but I don't remember any such behavior from pre-3.6 releases.
> 
> Since you seem to be able to reproduce it easily (and apparently
> reliably), any chance you could just bisect it?
> 
> Since I assume v3.5 is fine, and apparently -rc1 is already busted, a simple
> 
>   git bisect start
>   git bisect good v3.5
>   git bisect bad v3.6-rc1
> 
> will get you started on your adventure..

Heh, will give it a try :). The thing really does look quite bisectable.


It might take a few hours though - the machine isn't exactly fast by today's standards and it's getting late here. But I'll keep you updated.

Alex


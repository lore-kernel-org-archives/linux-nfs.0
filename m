From: Jaswinder Singh Rajput <jaswinder@kernel.org>
Subject: Re: [GIT PULL -tip] fix 33 make headers_check warnings
Date: Fri, 23 Jan 2009 21:26:07 +0530
Message-ID: <1232726167.3504.16.camel@localhost.localdomain>
References: <1232223441.3966.22.camel@localhost.localdomain>
	 <1232228261.27094.0.camel@macbook.infradead.org>
	 <20090117221932.GA4956@uranus.ravnborg.org>
	 <1232247901.3097.12.camel@localhost.localdomain>
	 <20090118033339.GA671@bombadil.infradead.org>
	 <1232249904.3097.15.camel@localhost.localdomain>
	 <20090118041800.GB671@bombadil.infradead.org>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Sam Ravnborg <sam-uyr5N9Q2VtJg9hUCZPvPmw@public.gmane.org>,
	David Woodhouse <dwmw2@infradead.org>,
	Ingo Molnar <mingo@elte.hu>, x86 maintainers <x86@kernel.org>,
	urs.thuermann-l29pVbxQd1IUtdQbppsyvg@public.gmane.org, oliver.hartkopp-l29pVbxQd1IUtdQbppsyvg@public.gmane.org,
	linux-media@vger.kernel.org, netfilter-devel@vger.kernel.org,
	netfilter@vger.kernel.org, bfields@fieldses.org, neilb@suse.de,
	linux-nfs@vger.kernel.org, linux-raid@vger.kernel.org,
	dbrownell@users.sourceforge.net,
	spi-devel-general@lists.sourceforge.net, netdev@vger.kernel.org,
	greg@kroah.com, linux-usb@vger.kernel.org,
	linux-mtd@lists.infradead.org, tiwai@suse.de,
	mchehab@infradead.org, LKML <linux-kernel@vger.kernel.org>,
	Andrew Morton <akpm@linux-foundation.org>
To: Kyle McMartin <kyle@infradead.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from hera.kernel.org ([140.211.167.34]:51980 "EHLO hera.kernel.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1760059AbZAWP5s (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 23 Jan 2009 10:57:48 -0500
In-Reply-To: <20090118041800.GB671-PfSpb0PWhxZc2C7mugBRk2EX/6BAtgUQ@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Sat, 2009-01-17 at 23:18 -0500, Kyle McMartin wrote:
> On Sun, Jan 18, 2009 at 09:08:24AM +0530, Jaswinder Singh Rajput wrote:
> > If this file is _ONLY_ for userspace and kernel cannot use it then what
> > is the point of keeping this file in kernel headers.
> > 
> 
> There is effectively no point, especially when they reference a variable
> that may or may not exist in the userspace code including it... It seems
> entirely mtd-utils dependent.
> 
> Dave, will you queue Adrian's patch to nuke it?

What is the status of include/mtd/jffs2-user.h

--
JSR


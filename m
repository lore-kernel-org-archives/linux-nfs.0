From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: gssapi and nfs4
Date: Thu, 6 Nov 2008 16:50:54 -0500
Message-ID: <20081106215054.GC24916@fieldses.org>
References: <1225813410.2247.279.camel@brian-laptop> <89c397150811041000l93b9831w1e8dce2175c6d51f@mail.gmail.com> <1225824797.2247.345.camel@brian-laptop> <20081104224817.GB16121@fieldses.org> <1225862729.13506.8.camel@pc.interlinx.bc.ca> <20081105190235.GA969@fieldses.org> <1225912734.3785.40.camel@pc.interlinx.bc.ca>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-nfs@vger.kernel.org
To: "Brian J. Murrell" <brian-SquOHqY54CVWr29BmMi2cA@public.gmane.org>,
	Neil Brown <neilb@suse.de>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail.fieldses.org ([66.93.2.214]:37161 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754781AbYKFVu6 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 6 Nov 2008 16:50:58 -0500
In-Reply-To: <1225912734.3785.40.camel-lA68w17JHpfIgqYUaR6mlLDks+cytr/Z@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, Nov 05, 2008 at 02:18:54PM -0500, Brian J. Murrell wrote:
> On Wed, 2008-11-05 at 14:02 -0500, J. Bruce Fields wrote:
> > > It's important to be able to do because I might
> > > want to be able to export /d to certain hosts without giving them access
> > > to mountpoints within /d as I have done above with /d/sub and pc.  If I
> > > use crossmnt which my experience is showing I need, then /d/sub is
> > > exposed to all of 10.75.22.0/24 which is not what I want.
> > 
> > If you add a separate export for /d/sub, I think it should override that
> > behavior.
> 
> That's what I did and still, I have to use crossmnt on /d and that
> exposes /d/sub it to everyone who gets access to /d where my intention
> is to only expose /d/sub to the match/limit I put on /d/sub, which is
> the single host "pc" in my above scneario.

That sounds like a bug we should fix; I can't volunteer to do it
currently, though.

--b.

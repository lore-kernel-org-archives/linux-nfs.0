Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([174.143.236.118]:43019 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754971Ab1BGV7g (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 7 Feb 2011 16:59:36 -0500
Date: Mon, 7 Feb 2011 16:59:35 -0500
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Tom Haynes <tdh@excfb.com>
Cc: linux-nfs@vger.kernel.org
Subject: Re: Debugging mount failure with netgroup
Message-ID: <20110207215935.GB3853@fieldses.org>
References: <20110207195609.GA13225@adept.internal.excfb.com>
 <20110207201202.GA3055@fieldses.org>
 <20110207205306.GA13731@adept.internal.excfb.com>
 <20110207211917.GA3853@fieldses.org>
 <20110207215344.GA15778@adept.internal.excfb.com>
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20110207215344.GA15778@adept.internal.excfb.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Mon, Feb 07, 2011 at 03:53:44PM -0600, Tom Haynes wrote:
> On Mon, Feb 07, 2011 at 04:19:17PM -0500, J. Bruce Fields wrote:
> > On Mon, Feb 07, 2011 at 02:53:06PM -0600, Tom Haynes wrote:
> > > I did google and did not find much on netgroups - but I did find
> > > a bunch on "unmatched host".
> > > 
> > > It seems to be black magic from some of the answers.
> > > 
> > > And I agree:
> > > 
> > > 1) Modified the export:
> > > [root@adept /]# more /etc/exports 
> > > /fooper   @adeptya(rw,insecure,no_root_squash,sync)
> > 
> > So it was probably the "insecure"?
> 
> Sorry, I forgot to mention after every step that I tried
> the mount and it failed. It was only restarting nfs
> that worked.

Changes to /etc/exports aren't automatically detected, so you need a
server restart or an exportfs -ra after any change.

> I'd have to check to see what port number the requests
> are coming in on, but I don't think it is this.
> 
> And I've actually got the system horked up right now -
> I restarted one time too many. Frustrating as there isn't
> anything logged beyond "unmatched host".

I forgot you said that was the error.  And looking at the code we
actually do have a different message for the port number case ("illegal
port").

OK, so maybe the problem was just that mountd never found out about your
original /etc/exports file?

--b.

> 
> > 
> > Are we returning the right error to the mount client in that case?
> > 
> > And I suppose the logged error should be more helpful.  I'm not really
> > sure mountd should be logging every mount failure by default, but if you
> > request it, it should at be able to tell you the reason for the failure.
> > 
> > --b.
> > 
> 
> -- 
> Tom Haynes
> ex-cfb

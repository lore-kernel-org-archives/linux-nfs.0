Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:43533 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752551Ab3A1XSR (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 28 Jan 2013 18:18:17 -0500
Date: Mon, 28 Jan 2013 18:18:03 -0500
From: "J. Bruce Fields" <bfields@redhat.com>
To: Arnd Bergmann <arnd@arndb.de>
Cc: Russell King - ARM Linux <linux@arm.linux.org.uk>,
        "Myklebust, Trond" <Trond.Myklebust@netapp.com>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>,
        "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
        "linux-arm-kernel@lists.infradead.org"
	<linux-arm-kernel@lists.infradead.org>
Subject: Re: [PATCH 15/19] sunrpc: don't warn for unused variable 'buf'
Message-ID: <20130128231803.GG5677@pad.fieldses.org>
References: <1359123276-15833-1-git-send-email-arnd@arndb.de>
 <201301252345.25829.arnd@arndb.de>
 <20130126110321.GE23505@n2100.arm.linux.org.uk>
 <201301261334.56398.arnd@arndb.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <201301261334.56398.arnd@arndb.de>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Sat, Jan 26, 2013 at 01:34:56PM +0000, Arnd Bergmann wrote:
> On Saturday 26 January 2013, Russell King - ARM Linux wrote:
> > On Fri, Jan 25, 2013 at 11:45:25PM +0000, Arnd Bergmann wrote:
> > > On Friday 25 January 2013, Myklebust, Trond wrote:
> > > > > -----Original Message-----
> > > > > From: Arnd Bergmann [mailto:arnd@arndb.de]
> > > > > Marking it as __maybe_unused avoids a harmless gcc warning.
> > > > 
> > > > Alternatively, just declare it using the RPC_IFDEBUG() macro.
> > > 
> > > Right, makes sense: that's more consistent with other functions
> > > doing the same thing. Thanks for taking a look.
> > 
> > NAK.
> > 
> > There is already a fix queued up as a result of a previous report I
> > sent, but for some reason (which I didn't question) it was decided
> > not to queue it for -rc.
> > 
> > See Bruce's reply on lkml: 20130108212816.GA24572@fieldses.org

Apologies, I've seen so many "stop sending me post-rc1 patches that
don't fix serious crashes!" flames.

I guess obviousl compile fixes should be an exception--if nothing else
it'd save a lot of duplicated work as this is something like the 3rd
patch I've seen for this.

--b.

> 
> Ok, makes sense. Then again, if that fix is queued for 3.9, maybe
> it still makes sense to take the simpler fix into 3.8, and remove
> it in 3.9 along with the other instances of RPC_IFDEBUG.



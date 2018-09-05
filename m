Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:49970 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1726046AbeIEU1V (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Wed, 5 Sep 2018 16:27:21 -0400
Date: Wed, 5 Sep 2018 11:56:32 -0400
From: "J. Bruce Fields" <bfields@redhat.com>
To: Olga Kornievskaia <aglo@umich.edu>
Cc: "J. Bruce Fields" <bfields@fieldses.org>,
        Olga Kornievskaia <kolga@netapp.com>,
        linux-nfs <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH v10 0/9] NFSD support for async COPY
Message-ID: <20180905155632.GA10680@parsley.fieldses.org>
References: <20180720221925.50744-1-kolga@netapp.com>
 <20180809203450.GE14104@parsley.fieldses.org>
 <20180823014722.GA24441@fieldses.org>
 <CAN-5tyEsME8YdBvzUczE6N_L3ptV8DTA0a4sZCgmDUfGX99CDA@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <CAN-5tyEsME8YdBvzUczE6N_L3ptV8DTA0a4sZCgmDUfGX99CDA@mail.gmail.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, Sep 05, 2018 at 10:30:59AM -0400, Olga Kornievskaia wrote:
> finally getting back to this...
> 
> On Wed, Aug 22, 2018 at 9:47 PM J. Bruce Fields <bfields@fieldses.org> wrote:
> >
> > On Thu, Aug 09, 2018 at 04:34:50PM -0400, J. Bruce Fields wrote:
> > > Thanks, I've added these to my -next branch, and I want to read through
> > > them tomorrow.
> >
> > Gah, I screwed up and took to long to get around to this and have a few
> > things I'd like to change, so I'm going to queue these up again for
> > 4.20.
> >
> > The way the patches are broken up doesn't really work; for example
> > init_cp_state is used in one but patch not defined till a later patch,
> 
> I don't see what you are seeing.. init_cp_state is defined and used in
> 0006-NFSD-create-new-stateid-for-async-copy.patch

Apologies, you're right.  I remember getting a compile error and
checking against the patches in my inbox to make sure the same
use-before-definition error was there.  But now I can't find any
problem.  That makes me wonder whether I was looking at the wrong
version of the patches or something.

I've checked my latest version against your latest and it looks OK to
me, but you might want to double check as well.

--b.

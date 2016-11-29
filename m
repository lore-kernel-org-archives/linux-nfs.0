Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([173.255.197.46]:35430 "EHLO fieldses.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752046AbcK2Bzz (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Mon, 28 Nov 2016 20:55:55 -0500
Date: Mon, 28 Nov 2016 20:55:54 -0500
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Tom Haynes <loghyr@excfb.com>
Cc: "J. Bruce Fields" <bfields@redhat.com>,
        Tom Haynes <loghyr@primarydata.com>,
        Linux NFS Mailing list <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH pynfs 00/12] Flex File support
Message-ID: <20161129015554.GA2199@fieldses.org>
References: <1480228001-64821-1-git-send-email-loghyr@primarydata.com>
 <20161128163321.GB30805@parsley.fieldses.org>
 <20161128214725.GD30954@fieldses.org>
 <20161128233831.GD30012@psyklo.internal.excfb.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20161128233831.GD30012@psyklo.internal.excfb.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, Nov 28, 2016 at 03:38:31PM -0800, Tom Haynes wrote:
> On Mon, Nov 28, 2016 at 04:47:25PM -0500, J. Bruce Fields wrote:
> > On Mon, Nov 28, 2016 at 11:33:21AM -0500, J. Bruce Fields wrote:
> > > On Sat, Nov 26, 2016 at 10:26:29PM -0800, Tom Haynes wrote:
> > > > I wanted to add client support for the flex file layout.
> > > > 
> > > > Note, I did not add pynfs as a flag because I didn't want to
> > > > mess up with any existing uses of it.
> > > > 
> > > > The other major change here is in closing all opened
> > > > files and destroying all clientids. With all the tests
> > > > which run against my server, there are no longer any
> > > > open files. There are however 11 clientids remaining.
> > > > 
> > > > I will track those down.
> > > > 
> > > > fwiw - these are in my staging branch at git://linux-nfs.org/~loghyr/pynfs.git
> > > 
> > > Thanks!  I'll try these and take a look.
> > 
> > It breaks all the 4.0 tests:
> > 
> > 	ACC3     st_access.testNoFh : FAILURE
> > 	           AttributeError: 'Environment' object has no attribute
> > 		              'clean_clients'
> > 
> > The problem is that nfs4.1/testmod.py is used by 4.0 as well, but
> > there's not a 4.0 version of clean_clients.... Simplest I guess is to do
> > as with clean_sessions and define a dummy method.
> > 
> > --b.
> > 
> > diff --git a/nfs4.0/servertests/environment.py b/nfs4.0/servertests/environment.py
> > index 6fe083a..221c3ed 100644
> > --- a/nfs4.0/servertests/environment.py
> > +++ b/nfs4.0/servertests/environment.py
> > @@ -229,6 +229,9 @@ class Environment(testmod.Environment):
> >      def clean_sessions(self):
> >          return
> >  
> > +    def clean_clients(self):
> > +       return
> > +
> >  #########################################
> >  debug_fail = False
> 
> Yeah, I never run 4.0 tests. Do you want me to add it to the patchset and
> resubmit?

I've just added that patch and pushed it out.  Thanks!

--b.

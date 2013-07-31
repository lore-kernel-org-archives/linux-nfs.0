Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:44033 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751316Ab3GaXsC (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 31 Jul 2013 19:48:02 -0400
Date: Wed, 31 Jul 2013 19:48:00 -0400
From: "J. Bruce Fields" <bfields@fieldses.org>
To: "Adamson, Dros" <Weston.Adamson@netapp.com>
Cc: linux-nfs list <linux-nfs@vger.kernel.org>
Subject: Re: SP4_MACH_CRED
Message-ID: <20130731234800.GC2668@fieldses.org>
References: <A0A1021A-64E6-4E0C-89A5-9F719C8E1AFC@netapp.com>
 <20130731213904.GB2668@fieldses.org>
 <75E5568D-320C-45A1-B7E6-23CE73217BAF@netapp.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <75E5568D-320C-45A1-B7E6-23CE73217BAF@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, Jul 31, 2013 at 10:22:22PM +0000, Adamson, Dros wrote:
> 
> On Jul 31, 2013, at 5:39 PM, "J. Bruce Fields" <bfields@fieldses.org>
>  wrote:
> 
> > This should probably be cc'd to the mailing list.
> 
> Agreed!
> 
> > 
> > On Wed, Jul 31, 2013 at 09:25:29PM +0000, Adamson, Dros wrote:
> >> I have a pretty functional client-side SP4_MACH_CRED implementation
> >> and I'm trying to implement the server side so I can fully test the
> >> client code. I was testing against another server, but that didn't
> >> implement any useful set of operations other than the required ones.
> > 
> > The latest Linux server implements SP4_MACH_CRED but only for the
> > required operations.  (But that hasn't really been tested--any testing
> > even to make sure that basic stuff works would be welcomed.)
> > 
> 
> Right, I'm happy to report that the initial implementation of the required operations seems to work with (at least) one small patch I'll send your way soon.
> 
> >> I'm currently trying to figure out the best way to set nfsd's current cred to that of the user really doing the operation.
> >> 
> >> i.e.:
> >> 
> >> - WRITE, CLOSE, LOCKT, LOCKU are supported by SP4_MACH_CRED.
> > 
> > "are supported by" means they're included in the spo_must_allow list
> > returned by the server?
> > 
> 
> Yes, what I meant was "the client thinks it can use the machine cred for these ops".
> 
> >> - OPEN calls use the user cred
> >> - When cred expires, SP4_MACH_CRED kicks in and cached WRITE calls are sent out using the machine cred.
> >> - nfsd handles request with the machine cred as the current cred
> >> 
> >> Currently, these writes fail in nfsd_permission (after I made a few other
> >> changes) because the current cred (the machine cred of the client) maps to
> >> a UID that is not the owner of the file (even though the io was done as the
> >> user).
> >> 
> >> I think what we need is a way to look up the cred associated with the state owner of the current operation's stateid and use that as the current credential when the machine cred is in use.
> > 
> > Is there a rule that says a stateowner or stateid can only be used with
> > one credential?  If not, I'm not sure what you mean by "the cred
> > associated with the state owner of the current operation's stateid".
> > 
> > Maybe we could just pick "a cred" instead of "the cred"?  So stash the
> > last cred used with a given stateid in the stateid, and use that in this
> > case?
> 
> Yeah... I was a bit confused.  This sounds like a good approach. Thanks!
> 
> > 
> >> Does that make sense to you? Is there something like this already? If
> >> not, any pointers on what you'd like to see?
> > 
> > As a user I'd normally expect that once my credentials have expired, the
> > client will no longer be able to write to my files.
> 
> That's true with unbuffered writes, but what about buffered writes that are already considered written by the application?

Well, the server can't distinguish between these two, all it can do is
say that once you've allowed the client to open a file as you, it's
going to continue allowing the client to access the file without needing
your credentials.

> The problem I'm trying to solve initially with SP4_MACH_CRED is when there are a bunch of buffered writes and the user's credentials expire. Any client side operations initiated after the credentials expire will fail (as expected), but operations that have already been seen as successful still need to be flushed.
> 
> Andy is addressing this in a different way by falling back to unbuffered writes and flushing all data right before a cred expires, but this method is better when available - and it's Trond requested.

I understand the problem it solves, but it is a bit of a change to the
security model and I just wonder what the right thing is to do by
default.

--b.

> 
> > 
> > This violates that assumption, so I wonder if it needs to be
> > configurable, and even off by default.
> > 
> 
> This will fix potential data corruption in a corner case of the way things currently work and doesn't change expected behavior from a user's perspective. 
> 
> -dros
> 

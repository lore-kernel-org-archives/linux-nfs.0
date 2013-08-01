Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:50882 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753087Ab3HASgA (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 1 Aug 2013 14:36:00 -0400
Date: Thu, 1 Aug 2013 14:35:59 -0400
From: "J. Bruce Fields" <bfields@fieldses.org>
To: "Adamson, Dros" <Weston.Adamson@netapp.com>
Cc: linux-nfs list <linux-nfs@vger.kernel.org>
Subject: Re: SP4_MACH_CRED
Message-ID: <20130801183559.GA17581@fieldses.org>
References: <A0A1021A-64E6-4E0C-89A5-9F719C8E1AFC@netapp.com>
 <20130731213904.GB2668@fieldses.org>
 <75E5568D-320C-45A1-B7E6-23CE73217BAF@netapp.com>
 <20130731234800.GC2668@fieldses.org>
 <0E0FF4CB-4388-417B-9D1C-24940472D844@netapp.com>
 <47D6EDEC-B91A-446F-A227-FDA9D37DB618@netapp.com>
 <20130801145617.GA15123@fieldses.org>
 <88EAD768-768D-43A3-8E4D-D9B904C0283C@netapp.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <88EAD768-768D-43A3-8E4D-D9B904C0283C@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, Aug 01, 2013 at 03:24:05PM +0000, Adamson, Dros wrote:
> 
> On Aug 1, 2013, at 10:56 AM, J. Bruce Fields <bfields@fieldses.org> wrote:
> 
> > On Thu, Aug 01, 2013 at 02:09:49PM +0000, Adamson, Dros wrote:
> >> 
> >> On Aug 1, 2013, at 10:03 AM, "Adamson, Dros" <Weston.Adamson@netapp.com>
> >> wrote:
> >> 
> >>> 
> >>> On Jul 31, 2013, at 7:48 PM, J. Bruce Fields <bfields@fieldses.org> wrote:
> >>> 
> >>>> On Wed, Jul 31, 2013 at 10:22:22PM +0000, Adamson, Dros wrote:
> >>>>> 
> >>>>> On Jul 31, 2013, at 5:39 PM, "J. Bruce Fields" <bfields@fieldses.org>
> >>>>> wrote:
> >>>>> 
> >>>>>> This should probably be cc'd to the mailing list.
> >>>>> 
> >>>>> Agreed!
> >>>>> 
> >>>>>> 
> >>>>>> On Wed, Jul 31, 2013 at 09:25:29PM +0000, Adamson, Dros wrote:
> >>>>>>> I have a pretty functional client-side SP4_MACH_CRED implementation
> >>>>>>> and I'm trying to implement the server side so I can fully test the
> >>>>>>> client code. I was testing against another server, but that didn't
> >>>>>>> implement any useful set of operations other than the required ones.
> >>>>>> 
> >>>>>> The latest Linux server implements SP4_MACH_CRED but only for the
> >>>>>> required operations.  (But that hasn't really been tested--any testing
> >>>>>> even to make sure that basic stuff works would be welcomed.)
> >>>>>> 
> >>>>> 
> >>>>> Right, I'm happy to report that the initial implementation of the required operations seems to work with (at least) one small patch I'll send your way soon.
> > 
> > (And I think I forgot to say thanks here!  It's useful to have that
> > tested.)
> 
> I should note it's somewhat useless to use SP4_MACH_CRED in this way from the linux client's perspective. We already use the machine cred with krb5i if possible for state manager ops even in SP4_NONE mode.

Without SP4_MACH_CRED anyone can e.g. destroy your client using just
auth_sys.

On its own all the use of krb5i really does is reassure you that your
rpc replies are from the server.

> > 	- user credentials go away before they're expected to expire.
> > 	(I wonder how this would typically happen?)
> 
> I don't believe this can happen yet.  IIRC a kdestroy isn't noticed by
> gssd, but this is probably going to change soon with Andy's keyring
> work, so it'd be nice to plan for it.

Yes.  I wonder if you could also take advantage of Andy's expiring-cred
emergency mode here?  So when you get the kdestroy notification, you
could try to flush writes before destroying contexts.

--b.

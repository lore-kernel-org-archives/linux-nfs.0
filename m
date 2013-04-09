Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:55661 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932780Ab3DISyq (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 9 Apr 2013 14:54:46 -0400
Date: Tue, 9 Apr 2013 14:54:45 -0400
To: Steve Dickson <SteveD@redhat.com>
Cc: Simo Sorce <simo@redhat.com>,
        Linux NFS Mailing list <linux-nfs@vger.kernel.org>, jlayton@redhat.com
Subject: Re: [PATCH 1/2] Avoid reverse resolution for server name
Message-ID: <20130409185445.GA3800@fieldses.org>
References: <515B2F8D.3030302@RedHat.com>
 <1364931149-18484-2-git-send-email-simo@redhat.com>
 <5162C8A5.4030307@RedHat.com>
 <1365430116.20560.6.camel@willson.li.ssimo.org>
 <51644CC5.3070609@RedHat.com>
 <1365528308.20560.42.camel@willson.li.ssimo.org>
 <5164514A.7020606@RedHat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <5164514A.7020606@RedHat.com>
From: "J. Bruce Fields" <bfields@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, Apr 09, 2013 at 01:35:06PM -0400, Steve Dickson wrote:
> 
> 
> On 09/04/13 13:25, Simo Sorce wrote:
> > On Tue, 2013-04-09 at 13:15 -0400, Steve Dickson wrote:
> >>
> >> On 08/04/13 10:08, Simo Sorce wrote:
> >>> On Mon, 2013-04-08 at 09:39 -0400, Steve Dickson wrote:
> >>>>
> >>>> On 02/04/13 15:32, Simo Sorce wrote:
> >>>>> A NFS client should be able to work properly even if the DNS Reverse record
> >>>>> for the server is not set. There is no excuse to forcefully prevent that
> >>>>> from working when it can.
> >>>>>
> >>>>> This patch adds a new pair of options (-z/-Z) that allow to turn on/off
> >>>>> DNS reverse resolution for determining the server name to use with GSSAPI.
> >>>> Again, please tell me why we need the -Z flag when that is the default?
> >>>
> >>> The idea is to switch the default in the code at some point, so then -Z
> >>> will be needed to get back to the original behavior.
> >> I'm thinking that's what major version number changes are for... not flags...
> >>
> >>>
> >>> The idea is that by having both flags a distribution may choose to
> >>> decide now what behavior they want and use the relative flag. Then even
> >>> if we change the default their configuration will not "break".
> >> I'll do the work to remove the option and repost the patches..
> > 
> > As you wish, I do not have hard preferences, should we take the bait and
> > also by default *not* do PTR lookups ?
> I was thinking no. Leaves the default as is and used the -z to avoid the
> lookup... 
> 
> I'm struggling with how big of a problem this really is, so why should be break
> existing environments? I'm no DNS expert but I thinking not have PTR is 
> a DNS config issue... but again I'm no expert...  

Argh, no, one away or another the default needs to be to not do the PTR
lookup.

The transition Simo's using was Jeff's suggestion.  Let's just stick to
that if we don't have a good reason.

(But I don't have strong opinions about how to do it either.  I'd
actually be OK with being harsh and just switching to the new behavior
without any option.)

--b.

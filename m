From: Jeff Layton <jlayton@redhat.com>
Subject: Re: [PATCH 4/6] nfs-utils: add IPv6 support to nfsd
Date: Tue, 26 May 2009 13:56:08 -0400
Message-ID: <20090526135608.1c003bf0@tlielax.poochiereds.net>
References: <1243350951-13462-1-git-send-email-jlayton@redhat.com>
	<1243350951-13462-5-git-send-email-jlayton@redhat.com>
	<43AF9911-DDC3-47C5-956C-1871ABF019D7@oracle.com>
	<20090526124907.4b711eaa@tlielax.poochiereds.net>
	<4E4834B1-DA6E-4D87-AA7E-747B679CB49F@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Cc: Linux NFS mailing list <linux-nfs@vger.kernel.org>,
	Steve Dickson <steved@redhat.com>, Neil Brown <neilb@suse.de>
To: Chuck Lever <chuck.lever@oracle.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.redhat.com ([66.187.237.31]:48899 "EHLO mx2.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756502AbZEZR4l (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 26 May 2009 13:56:41 -0400
In-Reply-To: <4E4834B1-DA6E-4D87-AA7E-747B679CB49F@oracle.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, 26 May 2009 13:31:47 -0400
Chuck Lever <chuck.lever@oracle.com> wrote:

> 
> On May 26, 2009, at 12:49 PM, Jeff Layton wrote:
> 
> > On Tue, 26 May 2009 11:24:05 -0400
> > Chuck Lever <chuck.lever@oracle.com> wrote:
> >
> >> Hi Jeff-
> >>
> >> On May 26, 2009, at 11:15 AM, Jeff Layton wrote:
> >>
> >>> Add 2 new options to rpc.nfsd -- -4 and -6. -4 makes it an IPv4-only
> >>> server, and -6 makes it IPv6-only. Restructure the -H option so that
> >>> if the address appears to be or resolves to an IPv4 address, that
> >>> IPv6 is disabled. Ditto if it resolves to an IPv6 address.
> >>
> >> The new rpc.statd doesn't have a "-4" or "-6" option.  It looks in /
> >> etc/netconfig to start only the visible transports.  I was suggesting
> >> that rpc.nfsd use /etc/netconfig _instead_ of having a -4/-6 command-
> >> line option.
> >>
> >> Just a thought.
> >>
> >
> > I don't feel strongly about it either way. It seems reasonable that
> > someone might want to disable ipv4 or ipv6 without changing
> > /etc/netconfig. This also has some parity with the -T and -U options
> > too...
> >
> > It would be good however to have nfsd and statd share options and
> > behavior here, so I think we should implement the same convention for
> > both. Do you think it would be better to remove -4/-6 from nfsd, or  
> > add
> > those options to the new statd?
> 
> My sense is statd is a kind of set-it-and-forget-it kind of thing.  It  
> doesn't have a lockd_up() kind of API that, for example, mount.nfs or  
> rpc.nfsd can invoke, to ensure that it's listening for a particular  
> protocol family or protocol (eventually mount.nfs could ping it via  
> IPv6 when mounting an IPv6 server, but it doesn't do that today).  So  
> it starts everything to cover all the bases.  That can change if  
> someone has a cogent argument!
> 
> rpc.nfsd is another kind of beast, as it's starting kernel services,  
> not a user space listener.  Even given rpc.nfsd's past of allowing -T  
> and -U, it's hard to say whether users will want the flexibility of  
> enabling IPv6 or IPv4, or whether they will want whatever families are  
> supported with the option of supporting UDP or TCP on both families.   
> If there's a way to make it all automatic, that might be the best  
> choice.
> 
> But I'd hesitate to introduce -4 and -6 if there's a realistic  
> possibility that we may not want or need that kind of flexibility in  
> the end.  Maybe we can go without for now, and add those options later  
> if needed?
> 
> Plus, do we want a "don't ever use IPv4" or "IPv6" kind of setting, or  
> just a "please start IPv4" or "IPv6" setting?  Does -6 exclude IPv4  
> and vice versa?  What should it mean when neither are present?
> 

The current options that I've implemented are "subtractive" -- they
disable the address families specified. If neither are present, then
nfsd just errors out.

> Once we have everything done, we might look back and say we definitely  
> need these options on all the user space components, and at that point  
> we'd have a clear idea how to make the options behave consistently for  
> all of the pieces.  I guess this is an argument for leaving these  
> options off until we have a better sense of what is needed.
> 

That sounds reasonable. I'll go ahead and rip out support for those
options. It's probably better to not introduce new knobs unless there's
a clear need for them. It's something we can easily add later.

Cheers,
-- 
Jeff Layton <jlayton@redhat.com>

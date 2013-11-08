Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:50935 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756350Ab3KHQRO (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 8 Nov 2013 11:17:14 -0500
Date: Fri, 8 Nov 2013 11:17:07 -0500
To: Steve Dickson <SteveD@redhat.com>
Cc: Jeff Layton <jlayton@redhat.com>, Chuck Lever <chuck.lever@oracle.com>,
        Trond Myklebust <Trond.Myklebust@netapp.com>,
        Linux NFS Mailing list <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH] Adding the nfs4_use_min_auth module parameter
Message-ID: <20131108161707.GD3533@fieldses.org>
References: <1383851364-8370-1-git-send-email-steved@redhat.com>
 <A8E8F2C4-8CB7-434E-8520-B2B53F0582D9@oracle.com>
 <527C07B4.800@RedHat.com>
 <44CA89EA-8B5E-4B83-A622-78A78F760FF1@oracle.com>
 <527CDBFC.3070903@RedHat.com>
 <20131108082202.4032f1a2@tlielax.poochiereds.net>
 <527CFC72.2030907@RedHat.com>
 <20131108101232.10d49851@tlielax.poochiereds.net>
 <527D0CE6.2020401@RedHat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <527D0CE6.2020401@RedHat.com>
From: "J. Bruce Fields" <bfields@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, Nov 08, 2013 at 11:10:14AM -0500, Steve Dickson wrote:
> 
> 
> On 08/11/13 10:12, Jeff Layton wrote:
> > On Fri, 08 Nov 2013 10:00:02 -0500
> > Steve Dickson <SteveD@redhat.com> wrote:
> > 
> >>
> >>
> >> On 08/11/13 08:22, Jeff Layton wrote:
> >>> On Fri, 08 Nov 2013 07:41:32 -0500
> >>> Steve Dickson <SteveD@redhat.com> wrote:
> >>>
> >>>>
> >>>>
> >>>> On 07/11/13 18:05, Chuck Lever wrote:
> >>>>>
> >>>>> On Nov 7, 2013, at 1:35 PM, Steve Dickson <SteveD@redhat.com> wrote:
> >>>>>
> >>>>>> Hey mrchuck... 
> >>>>>>
> >>>>>> On 07/11/13 14:25, Chuck Lever wrote:
> >>>>>>> Hi Steve-
> >>>>>>>
> >>>>>>> On Nov 7, 2013, at 11:09 AM, Steve Dickson <steved@redhat.com> wrote:
> >>>>>>>
> >>>>>>>> This new module parameter makes the v4 client
> >>>>>>>> use the minimal authentication flavor (AUTH_UNIX)
> >>>>>>>> when establishing NFSV4 state and doing the
> >>>>>>>> pseudoroot lookup
> >>>>>>>
> >>>>>>> The patch description doesn't say, but is this change to work 
> >>>>>>> around the 15 second GSSD upcall timeout? 
> >>>>>> Yes. A 15 second delay on every mount due to security that
> >>>>>> nobody is requesting is just not good.. IMHO..
> >>>>>
> >>>>> One thing we haven't discussed is reducing the upcall timeout to 5 seconds or less, 
> >>>>> as a form of immediate relief.  15 seconds is arbitrary, and is onerous even when 
> >>>>> you expect the mount to work (ie why would it be good for any properly configured 
> >>>>> environment to take 15 seconds to establish a GSS context?).
> >>>>>
> >>>>> In other words, there are still cases where users wait 15 seconds unnecessarily, 
> >>>>> and not because of the use of krb5i for lease management.  Aren't those of concern?
> >>>> No. I think the concern here, at least my concern, is the lack of management.
> >>>> We are forcing admins to use krb5i in lease management when its not necessary
> >>>> and there is no way to turn it off.
> >>>>   
> >>>
> >>> I don't think that's really the case. The idea was to have the client
> >>> attempt to use krb5i if it's available, and then to fall back to
> >>> AUTH_SYS if it isn't. This would be *absolutely* no big deal if the
> >>> GSSAPI upcall succeeded or failed immediately instead of requiring this
> >>> timeout when the daemon isn't running.
> >> What server makes krb5i available today in state setup and pseudoroot lookups?
> >>
> > 
> > That I don't know...sorry...
> Then what is the justification to take all these extra steps
> there they going to fail %100 of the time??

Any server can support krb5 for state setup and pseudoroot operations if
it's configured.  This isn't a problem.

--b.

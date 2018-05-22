Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:43236 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1753170AbeEVWBe (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Tue, 22 May 2018 18:01:34 -0400
Date: Tue, 22 May 2018 18:01:33 -0400
From: "J. Bruce Fields" <bfields@redhat.com>
To: Olga Kornievskaia <aglo@umich.edu>
Cc: Olga Kornievskaia <kolga@netapp.com>,
        Steve Dickson <SteveD@redhat.com>,
        linux-nfs <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH v8 0/9] NFSD support for async COPY
Message-ID: <20180522220132.GC32265@parsley.fieldses.org>
References: <20180416214522.GC2634@parsley.fieldses.org>
 <20180417065203.GA15145@infradead.org>
 <CAN-5tyEjCEo+P=p2nPkEiwa3BwM8Nj_N3KmvMXMU+VDmQJcjLA@mail.gmail.com>
 <1b45673f-516d-51ff-a1ef-8b07b9dd8619@RedHat.com>
 <1E0C45FE-2214-41FB-8634-1005CC13AD9E@netapp.com>
 <20180418070842.GC8764@infradead.org>
 <CAN-5tyGVc5myRVrnS0vc3gKq5NbhhrkVVDuLZPn2XxXoO-=T8A@mail.gmail.com>
 <20180427160349.GA22412@parsley.fieldses.org>
 <CAN-5tyH3VAcOXZ87ZGJFn5BffO+Si9A1shEgUsP=H-FUu+K23A@mail.gmail.com>
 <CAN-5tyESMQC6A4wV6Xi7Y-ScDn-eNNa0szqjbjHrQgswje_TmA@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
In-Reply-To: <CAN-5tyESMQC6A4wV6Xi7Y-ScDn-eNNa0szqjbjHrQgswje_TmA@mail.gmail.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, May 22, 2018 at 05:05:10PM -0400, Olga Kornievskaia wrote:
> On Fri, Apr 27, 2018 at 7:11 PM, Olga Kornievskaia <aglo@umich.edu> wrote:
> > On Fri, Apr 27, 2018 at 12:03 PM, J. Bruce Fields <bfields@redhat.com> wrote:
> >> On Tue, Apr 24, 2018 at 04:29:14PM -0400, Olga Kornievskaia wrote:
> >>> On Wed, Apr 18, 2018 at 3:08 AM, Christoph Hellwig <hch@infradead.org> wrote:
> >>> > On Tue, Apr 17, 2018 at 11:19:25AM -0400, Olga Kornievskaia wrote:
> >>> >> Yes I agree. Let’s please decide if this will go in (with whatever code improvements are required) or let’s drop it.
> >>> >
> >>> > Well, my vote is very clearly to drop it.
> >>>
> >>> Bruce, when will you make a decision about this? Is there something
> >>> more that needs to happen before it can be decided if the "async"
> >>> patches are moving forward (and then "inter" patches).
> >>
> >> I'm OK with the patches.
> >>
> >> It could help to have some more information about actual customer use
> >> cases: who specifically is asking for this, and what about their
> >> situation makes them believe they'll benefit?
> >
> > I'm really not involved with customer or know of how exactly they will
> > benefit. I have some knowledge of some company that is interested in
> > using copy offload functionality in game development. I have no
> > details. It has been talked about a case scenario of copying VM
> > images. I don't know if VMware uses copy offload or not.
> >
> >> But to me it seems obvious that server-to-server copy will be faster in
> >> some cases as long there's not some screwup preventing it from using the
> >> server-to-server bandwidth (and your numbers don't show any).  So I'm
> >> not terribly worried about this.
> >>
> >> If we wanted to simplify I think we could ditch the asynchronous
> >> protocol and still make server-to-server copy work as a series of
> >> synchronous calls.  (Or maybe that would make getting good performance
> >> the complicated part.)
> >
> > I'm not in favor of dropping asynchronous piece as I think it's an
> > important performance improvement. It's likely it won't be must of an
> > improvement due to an overhead of establishing clientid/session for
> > every "chuck" of the copy that will be sent synchronously.
> >
> >> The only security issue I'm worried about is the fact that you can make
> >> it try to copy from any arbitrary IP address.  I'd be satisfied if we
> >> document the issue and make server-to-server-copy support require a
> >> runtime switch that defaults to off.  (And with that in place I don't
> >> see a need to also provide a build option.)
> >
> > Ok, runtime option, I'll work on it.
> 
> Hi Bruce,
> 
> I would like to come back to this code and hopefully make progress.
> 
> I heard about the LSF discussion that there was interest in the copy
> offload and async code. If so where do we stand now and what are the
> next steps now?

I actually don't remember that discussion, apologies.

Next steps might be for you to add the runtime option and resend?  And
then I need to give it another read.

--b.

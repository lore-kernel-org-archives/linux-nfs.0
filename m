Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:59540 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1757562AbeD0QDu (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Fri, 27 Apr 2018 12:03:50 -0400
Date: Fri, 27 Apr 2018 12:03:49 -0400
From: "J. Bruce Fields" <bfields@redhat.com>
To: Olga Kornievskaia <aglo@umich.edu>
Cc: Olga Kornievskaia <kolga@netapp.com>,
        Steve Dickson <SteveD@redhat.com>,
        linux-nfs <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH v8 0/9] NFSD support for async COPY
Message-ID: <20180427160349.GA22412@parsley.fieldses.org>
References: <20180413170158.17589-1-kolga@netapp.com>
 <20180414072202.GA6514@infradead.org>
 <20180416214522.GC2634@parsley.fieldses.org>
 <20180417065203.GA15145@infradead.org>
 <CAN-5tyEjCEo+P=p2nPkEiwa3BwM8Nj_N3KmvMXMU+VDmQJcjLA@mail.gmail.com>
 <1b45673f-516d-51ff-a1ef-8b07b9dd8619@RedHat.com>
 <1E0C45FE-2214-41FB-8634-1005CC13AD9E@netapp.com>
 <20180418070842.GC8764@infradead.org>
 <CAN-5tyGVc5myRVrnS0vc3gKq5NbhhrkVVDuLZPn2XxXoO-=T8A@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
In-Reply-To: <CAN-5tyGVc5myRVrnS0vc3gKq5NbhhrkVVDuLZPn2XxXoO-=T8A@mail.gmail.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, Apr 24, 2018 at 04:29:14PM -0400, Olga Kornievskaia wrote:
> On Wed, Apr 18, 2018 at 3:08 AM, Christoph Hellwig <hch@infradead.org> wrote:
> > On Tue, Apr 17, 2018 at 11:19:25AM -0400, Olga Kornievskaia wrote:
> >> Yes I agree. Let’s please decide if this will go in (with whatever code improvements are required) or let’s drop it.
> >
> > Well, my vote is very clearly to drop it.
> 
> Bruce, when will you make a decision about this? Is there something
> more that needs to happen before it can be decided if the "async"
> patches are moving forward (and then "inter" patches).

I'm OK with the patches.

It could help to have some more information about actual customer use
cases: who specifically is asking for this, and what about their
situation makes them believe they'll benefit?

But to me it seems obvious that server-to-server copy will be faster in
some cases as long there's not some screwup preventing it from using the
server-to-server bandwidth (and your numbers don't show any).  So I'm
not terribly worried about this.

If we wanted to simplify I think we could ditch the asynchronous
protocol and still make server-to-server copy work as a series of
synchronous calls.  (Or maybe that would make getting good performance
the complicated part.)

The only security issue I'm worried about is the fact that you can make
it try to copy from any arbitrary IP address.  I'd be satisfied if we
document the issue and make server-to-server-copy support require a
runtime switch that defaults to off.  (And with that in place I don't
see a need to also provide a build option.)

--b.

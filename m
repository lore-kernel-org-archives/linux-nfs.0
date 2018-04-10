Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([173.255.197.46]:50310 "EHLO fieldses.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751546AbeDJVNI (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Tue, 10 Apr 2018 17:13:08 -0400
Date: Tue, 10 Apr 2018 17:13:07 -0400
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Olga Kornievskaia <aglo@umich.edu>
Cc: "J. Bruce Fields" <bfields@redhat.com>,
        Olga Kornievskaia <kolga@netapp.com>,
        linux-nfs <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH v7 10/10] NFSD stop queued async copies on client shutdown
Message-ID: <20180410211307.GB314@fieldses.org>
References: <20180220164229.65404-1-kolga@netapp.com>
 <20180220164229.65404-11-kolga@netapp.com>
 <20180308170511.GF10782@fieldses.org>
 <CAN-5tyFZR7nOKks7nA__rLE3p4Dr7uwm7dHyKb_obOn74NbnHw@mail.gmail.com>
 <20180410202123.GB5685@parsley.fieldses.org>
 <CAN-5tyHrO898GGFgtFELwidJM3O47HGJNHQ=HvFYv22ve51Q5g@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
In-Reply-To: <CAN-5tyHrO898GGFgtFELwidJM3O47HGJNHQ=HvFYv22ve51Q5g@mail.gmail.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, Apr 10, 2018 at 05:07:02PM -0400, Olga Kornievskaia wrote:
> On Tue, Apr 10, 2018 at 4:21 PM, J. Bruce Fields <bfields@redhat.com> wrote:
> > On Tue, Apr 10, 2018 at 04:09:09PM -0400, Olga Kornievskaia wrote:
> >> I have a question. I’m testing how the code works in
> >> nfsd4_shutdown_copy. I have disabled canceling the copy (just
> >> returning ok) and so then the client can stop its copy and do the
> >> close and then I can issue an unmount. What I see is that the server
> >> returns “err_delay” until the copy finishes. That’s because in
> >> nfsd4_destroy_clientid() it calls mark_client_expired_locked() which
> >> checks the refcount on the client structure and since copy holds a
> >> reference server returns err_delay. Once the copy finished and
> >> decrements the reference, and nfsd4_destroy_clientid() gets past that
> >> then calling nfsd4_shutdown_copy() doesn’t find any copies.
> >>
> >> Should the logic of nfsd4_destroy_clientid() be changed to stop copies
> >> then instead of during destruction of the client structure?
> >
> > Oh, good question, I don't know.  Thinking about it....
> >
> > DESTROY_CLIENTID doesn't throw away all the client's state for it, it's
> > only meant to be called after the client has already cleaned up
> > everything else.  So:
> >
> >         https://tools.ietf.org/html/rfc5661#section-18.50.3
> >
> >         If there are sessions (both idle and non-idle), opens, locks,
> >         delegations, layouts, and/or wants (Section 18.49) associated
> >         with the unexpired lease of the client ID, the server MUST
> >         return NFS4ERR_CLIENTID_BUSY.
> >
> > My feeling is that "ongoing copies" also belongs on that list.
> >
> > So the server behavior you're seeing sounds correct to me--the client
> > should cancel any ongoing copies before calling DESTROY_CLIENTID.
> 
> If the behavior of returning ERR_DELAY until the copy is done is
> correct one, then I don't think I need this patch at all. Since copy
> takes a reference on the nfs4_client structure, then in
> __destroy_client() where nfsd4_shutdown_copy() is called the list will
> always be empty.

Actually I guess it should be returning CLIENTID_BUSY.  Maybe that's a
preexisting bug.

We do still need to be able to handle the case where the lease expires.
I guess the copy needs to be forcibly canceled in that case.

--b.

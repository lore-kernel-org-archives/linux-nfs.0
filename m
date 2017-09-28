Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:53272 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1750759AbdI1TYy (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Thu, 28 Sep 2017 15:24:54 -0400
Date: Thu, 28 Sep 2017 15:24:53 -0400
From: "J. Bruce Fields" <bfields@redhat.com>
To: Olga Kornievskaia <aglo@umich.edu>
Cc: Olga Kornievskaia <kolga@netapp.com>,
        linux-nfs <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH v4 07/10] NFSD create new stateid for async copy
Message-ID: <20170928192452.GN10182@parsley.fieldses.org>
References: <20170928172945.50780-1-kolga@netapp.com>
 <20170928172945.50780-8-kolga@netapp.com>
 <20170928191246.GL10182@parsley.fieldses.org>
 <CAN-5tyHKR80CGFsTUTwu24zOhC0beQ=-UcChvvOYmoybywAmxA@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
In-Reply-To: <CAN-5tyHKR80CGFsTUTwu24zOhC0beQ=-UcChvvOYmoybywAmxA@mail.gmail.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, Sep 28, 2017 at 03:21:54PM -0400, Olga Kornievskaia wrote:
> On Thu, Sep 28, 2017 at 3:12 PM, J. Bruce Fields <bfields@redhat.com> wrote:
> > On Thu, Sep 28, 2017 at 01:29:42PM -0400, Olga Kornievskaia wrote:
> >> Generate a new stateid to be used for reply to the asynchronous
> >> COPY (this would also be used later by COPY_NOTIFY as well).
> >> Associate the stateid with the parent OPEN/LOCK/DELEG stateid
> >> that can be freed during the free of the parent stateid. However,
> >> right now deciding to bind the lifetime to when the vfs copy
> >> is done. This way don't need to keep the nfsd_net structure for
> >> the callback. The drawback is that time copy state information
> >> is available for query by OFFLOAD_STATUS is slightly less.
> >
> > I don't think we're under any obligation to handle OFFLOAD_STATUS after
> > the copy is done, are we?
> 
> It depends on how you define “copy is done”. I’d say copy is done once the
> server sent the CB_OFFLOAD. But I’m choosing to clear the state once the
> vfs_copy_file_range() is done. Then the callback is queued up (what if
> there is wait until the callback can be processed) and there is a period
> where if the client were to send a OFFLOAD_STATUS it should get the
> bytes representing the full copy but instead the client will get an error back.
> 
> I was worried about what if some implementation depend on querying for
> the status and stopping to poll only when they received that all bytes were
> copied and they might not get that with how the server is coded right now?

I don't see the spec providing any guarantee that the copy status be
kept around any minimum length of time, so I don't think a client would
be correct to do that.

--b.

Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:50182 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751544AbeBBVpr (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Fri, 2 Feb 2018 16:45:47 -0500
Date: Fri, 2 Feb 2018 16:45:45 -0500
From: "J. Bruce Fields" <bfields@redhat.com>
To: Olga Kornievskaia <aglo@umich.edu>
Cc: "J. Bruce Fields" <bfields@fieldses.org>,
        Olga Kornievskaia <kolga@netapp.com>,
        linux-nfs <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH v6 07/10] NFSD create new stateid for async copy
Message-ID: <20180202214545.GB7229@parsley.fieldses.org>
References: <20171024174752.74910-1-kolga@netapp.com>
 <20171024174752.74910-8-kolga@netapp.com>
 <20180126215942.GC7770@fieldses.org>
 <CAN-5tyGBBfh0i9QmyHTHp-SWa6ncMCz4ZQdZcAuyWKhxtQ9xLA@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <CAN-5tyGBBfh0i9QmyHTHp-SWa6ncMCz4ZQdZcAuyWKhxtQ9xLA@mail.gmail.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, Feb 02, 2018 at 03:45:28PM -0500, Olga Kornievskaia wrote:
> On Fri, Jan 26, 2018 at 4:59 PM, J. Bruce Fields <bfields@fieldses.org> wrote:
> > What is supposed to happen, by the way, if a close arrives for a stateid
> > with a copy in progress?  Do we cancel the copy before returning from
> > the close, or do we fail the close?  (Same question for unlock and
> > delegation return, I guess.)
> 
> Good questions. I think a normal client shouldn't send CLOSE/UNLOCK
> while there is an on-going copy. I could see how a DELEGRETURN could
> be coming in the middle of the copy (because the client received a
> CB_RECALL).
> 
> For an easy solution my proposal is to do the following. Upon
> receiving close, unlock, delegreturn, if the copy list is non-empty,
> then we send an ERR_DELAY back until the copy is done.
> 
> Another proposal is to kill the copy thread but that seems too drastic
> (specially in the case of a delegreturn). Right now when the copy
> thread is killed, it does not send a reply back to the client (as it
> assumes the client sent the OFFLOAD_CANCEL and doesn't need a reply).
> I could change that to send a reply back. In case the copy used a
> delegation stateid, then the next copy would choose a different
> stateid. This could be done for the delegation stateid and ERR_DELAY
> for the close/unlock.
> 
> Is either one acceptable and if so which one sounds better to you?

If we're confident this is something that only a misbehaving client
would do, then I'm OK with choosing whatever's simplest.  I guess we
should double-check with the spec to make sure this case hasn't already
been covered there.  Returning an error on the conflicting operation
sounds good to me.

Is it really OK to do a COPY with a delegation stateid?  That sounds
messy if the delegation is revoked partway through the copy.

--b.

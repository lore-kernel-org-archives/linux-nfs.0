Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:49788 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752064AbeDJUVZ (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Tue, 10 Apr 2018 16:21:25 -0400
Date: Tue, 10 Apr 2018 16:21:24 -0400
From: "J. Bruce Fields" <bfields@redhat.com>
To: Olga Kornievskaia <aglo@umich.edu>
Cc: "J. Bruce Fields" <bfields@fieldses.org>,
        Olga Kornievskaia <kolga@netapp.com>,
        linux-nfs <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH v7 10/10] NFSD stop queued async copies on client shutdown
Message-ID: <20180410202123.GB5685@parsley.fieldses.org>
References: <20180220164229.65404-1-kolga@netapp.com>
 <20180220164229.65404-11-kolga@netapp.com>
 <20180308170511.GF10782@fieldses.org>
 <CAN-5tyFZR7nOKks7nA__rLE3p4Dr7uwm7dHyKb_obOn74NbnHw@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
In-Reply-To: <CAN-5tyFZR7nOKks7nA__rLE3p4Dr7uwm7dHyKb_obOn74NbnHw@mail.gmail.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, Apr 10, 2018 at 04:09:09PM -0400, Olga Kornievskaia wrote:
> I have a question. I’m testing how the code works in
> nfsd4_shutdown_copy. I have disabled canceling the copy (just
> returning ok) and so then the client can stop its copy and do the
> close and then I can issue an unmount. What I see is that the server
> returns “err_delay” until the copy finishes. That’s because in
> nfsd4_destroy_clientid() it calls mark_client_expired_locked() which
> checks the refcount on the client structure and since copy holds a
> reference server returns err_delay. Once the copy finished and
> decrements the reference, and nfsd4_destroy_clientid() gets past that
> then calling nfsd4_shutdown_copy() doesn’t find any copies.
> 
> Should the logic of nfsd4_destroy_clientid() be changed to stop copies
> then instead of during destruction of the client structure?

Oh, good question, I don't know.  Thinking about it....

DESTROY_CLIENTID doesn't throw away all the client's state for it, it's
only meant to be called after the client has already cleaned up
everything else.  So:

	https://tools.ietf.org/html/rfc5661#section-18.50.3

	If there are sessions (both idle and non-idle), opens, locks,
	delegations, layouts, and/or wants (Section 18.49) associated
	with the unexpired lease of the client ID, the server MUST
	return NFS4ERR_CLIENTID_BUSY.

My feeling is that "ongoing copies" also belongs on that list.

So the server behavior you're seeing sounds correct to me--the client
should cancel any ongoing copies before calling DESTROY_CLIENTID.

--b.

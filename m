Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:48714 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751247AbdKNAsG (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Mon, 13 Nov 2017 19:48:06 -0500
Date: Mon, 13 Nov 2017 19:48:05 -0500
From: "J. Bruce Fields" <bfields@redhat.com>
To: Olga Kornievskaia <aglo@umich.edu>
Cc: Olga Kornievskaia <kolga@netapp.com>,
        linux-nfs <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH v6 00/10] NFSD support for asynchronous COPY
Message-ID: <20171114004804.GB14185@parsley.fieldses.org>
References: <20171024174752.74910-1-kolga@netapp.com>
 <CAN-5tyHmrfKTfC8ELHA7RpHmUaVzBRKBqQNTpOYnu3SM7OdCnQ@mail.gmail.com>
 <CAN-5tyHumx9s7nkweA1B4CniPD_NzeGyd9d9FNL5ZxzX6KQ+zw@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <CAN-5tyHumx9s7nkweA1B4CniPD_NzeGyd9d9FNL5ZxzX6KQ+zw@mail.gmail.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, Nov 10, 2017 at 10:01:02AM -0500, Olga Kornievskaia wrote:
> On Fri, Nov 3, 2017 at 3:57 PM, Olga Kornievskaia <aglo@umich.edu> wrote:
> > On Tue, Oct 24, 2017 at 1:47 PM, Olga Kornievskaia <kolga@netapp.com> wrote:
> >> To do asynchronous copies, NFSD creates a new kthread to handle the request.
> >> Upon receiving the COPY, it generates a unique copy stateid (stored in a
> >> global list for keeping track of state for OFFLOAD_STATUS to be queried by),
> >> starts the thread, and replies back to the client. nfsd4_copy arguments that
> >> are allocated on the stack are copies for the kthread.
> >>
> >> For the async copy handler, copy is done in the loop for the requested
> >> number of bytes. If an error is encountered and partial copy has happened,
> >> a successful partial copy is returned in the CB_OFFLOAD. vfs_copy_file_range
> >> is called with 4MB chunks for both async and sync, allowing for 4MB
> >> granularity of OFFLOAD_STATUS queiry. Once copy is done, the results are
> >> queued for the callback workqueue and sent via CB_OFFLOAD.
> >>
> >> When the server received an OFFLOAD_CANCEL, it will find the kthread running
> >> the copy and will send a SIGPENDING and kthread_stop() and it will interrupt
> >> the ongoing do_splice() and once vfs returns we are choosing not to send
> >> the CB_OFFLOAD back to the client.
> >>
> >> When the server receives an OFFLOAD_STATUS, it will find the kthread running
> >> the copy and will locate within the copy state the current number of bytes
> >> copied so far.
> >>
> >> v6:
> >> 1. if an error occured and partial bytes were copied, don't return the error
> >> and instead return the successful partial copy.
> >> 2. OFFLOAD_STATUS locates the on-going copy and looks up the number of bytes
> >> copied so far.
> >>
> >> Olga Kornievskaia (10):
> >>   NFSD CB_OFFLOAD xdr
> >>   NFSD OFFLOAD_STATUS xdr
> >>   NFSD OFFLOAD_CANCEL xdr
> >>   NFSD xdr callback stateid in async COPY reply
> >>   NFSD first draft of async copy
> >>   NFSD return nfs4_stid in nfs4_preprocess_stateid_op
> >>   NFSD create new stateid for async copy
> >>   NFSD handle OFFLOAD_CANCEL op
> >>   NFSD support OFFLOAD_STATUS
> >>   NFSD stop queued async copies on client shutdown
> >>
> >>  fs/nfsd/netns.h        |   8 ++
> >>  fs/nfsd/nfs4callback.c |  97 +++++++++++++++
> >>  fs/nfsd/nfs4proc.c     | 316 ++++++++++++++++++++++++++++++++++++++++++++-----
> >>  fs/nfsd/nfs4state.c    |  77 +++++++++++-
> >>  fs/nfsd/nfs4xdr.c      |  50 ++++++--
> >>  fs/nfsd/nfsctl.c       |   1 +
> >>  fs/nfsd/state.h        |  21 +++-
> >>  fs/nfsd/xdr4.h         |  28 +++++
> >>  fs/nfsd/xdr4cb.h       |  10 ++
> >>  9 files changed, 571 insertions(+), 37 deletions(-)
> >
> > Bruce, any comments on this version?
> 
> Bruce, do you have any comments on this version?

I don't yet, apologies.  It is on my list to look at.

--b.

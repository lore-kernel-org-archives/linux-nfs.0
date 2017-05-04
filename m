Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([173.255.197.46]:49450 "EHLO fieldses.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751472AbdEDT6V (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Thu, 4 May 2017 15:58:21 -0400
Date: Thu, 4 May 2017 15:58:20 -0400
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Chuck Lever <chuck.lever@oracle.com>
Cc: Trond Myklebust <trond.myklebust@primarydata.com>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Subject: Re: [RFC PATCH 2/5] NFS: Add a mount option to specify number of TCP
 connections to use
Message-ID: <20170504195820.GC7023@fieldses.org>
References: <20170428172535.7945-1-trond.myklebust@primarydata.com>
 <20170428172535.7945-2-trond.myklebust@primarydata.com>
 <20170428172535.7945-3-trond.myklebust@primarydata.com>
 <EC0AD66D-D8B5-4912-A2DC-5B9167D2A01A@oracle.com>
 <F87DB5F9-829B-43BD-B823-243A6E1F0A41@oracle.com>
 <20170504173638.GA7023@fieldses.org>
 <F868F692-7CB7-4388-94E7-7D4052CE89F1@oracle.com>
 <20170504174549.GB7023@fieldses.org>
 <D44951CC-9107-425C-9A77-2F513805E93B@oracle.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <D44951CC-9107-425C-9A77-2F513805E93B@oracle.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, May 04, 2017 at 02:55:06PM -0400, Chuck Lever wrote:
> 
> > On May 4, 2017, at 1:45 PM, J. Bruce Fields <bfields@fieldses.org> wrote:
> > 
> > On Thu, May 04, 2017 at 01:38:35PM -0400, Chuck Lever wrote:
> >> 
> >>> On May 4, 2017, at 1:36 PM, bfields@fieldses.org wrote:
> >>> 
> >>> On Thu, May 04, 2017 at 12:01:29PM -0400, Chuck Lever wrote:
> >>>> 
> >>>>> On May 4, 2017, at 9:45 AM, Chuck Lever <chuck.lever@oracle.com> wrote:
> >>>>> 
> >>>>> - Testing with a Linux server shows that the basic NFS/RDMA pieces
> >>>>> work, but any OPEN operation gets NFS4ERR_GRACE, forever, when I use
> >>>>> nconnect > 1. I'm looking into it.
> >>>> 
> >>>> Reproduced with NFSv4.1, TCP, and nconnect=2.
> >>>> 
> >>>> 363         /*
> >>>> 364          * RFC5661 18.51.3
> >>>> 365          * Before RECLAIM_COMPLETE done, server should deny new lock
> >>>> 366          */
> >>>> 367         if (nfsd4_has_session(cstate) &&
> >>>> 368             !test_bit(NFSD4_CLIENT_RECLAIM_COMPLETE,
> >>>> 369                       &cstate->session->se_client->cl_flags) &&
> >>>> 370             open->op_claim_type != NFS4_OPEN_CLAIM_PREVIOUS)
> >>>> 371                 return nfserr_grace;
> >>>> 
> >>>> Server-side instrumentation confirms:
> >>>> 
> >>>> May  4 11:28:29 klimt kernel: nfsd4_open: has_session returns true
> >>>> May  4 11:28:29 klimt kernel: nfsd4_open: RECLAIM_COMPLETE is false
> >>>> May  4 11:28:29 klimt kernel: nfsd4_open: claim_type is 0
> >>>> 
> >>>> Network capture shows the RPCs are interleaved between the two
> >>>> connections as the client establishes its lease, and that appears
> >>>> to be confusing the server.
> >>>> 
> >>>> C1: NULL -> NFS4_OK
> >>>> C1: EXCHANGE_ID -> NFS4_OK
> >>>> C2: CREATE_SESSION -> NFS4_OK
> >>>> C1: RECLAIM_COMPLETE -> NFS4ERR_CONN_NOT_BOUND_TO_SESSION
> >>> 
> >>> What security flavors are involved?  I believe the correct behavior
> >>> depends on whether gss is in use or not.
> >> 
> >> The mount options are "sec=sys" but both sides have a keytab.
> >> So the lease management operations are done with krb5i.
> > 
> > OK.  I'm pretty sure the client needs to send BIND_CONN_TO_SESSION
> > before step C1.
> > 
> > My memory is that over auth_sys you're allowed to treat any SEQUENCE
> > over a new connection as implicitly binding that connection to the
> > referenced session, but over krb5 the server's required to return that
> > NOT_BOUND error if the server skips the BIND_CONN_TO_SESSION.
> 
> Ah, that would explain why nconnect=[234] is working against my
> Solaris 12 server: no keytab on that server means lease management
> is done using plain-old AUTH_SYS.
> 
> Multiple connections are now handled entirely by the RPC layer,
> and are opened and used at rpc_clnt creation time. The NFS client
> is not aware (except for allowing more than one connection to be
> used) and relies on its own recovery mechanisms to deal with
> exceptions that might arise. IOW it doesn't seem to know that an
> extra BC2S is needed, nor does it know where in the RPC stream
> to insert that operation.
> 
> Seems to me a good approach would be to handle server trunking
> discovery and lease establishment using a single connection, and
> then open more connections. A conservative approach might actually
> hold off on opening additional connections until there are enough
> RPC transactions being initiated in parallel to warrant it. Or, if
> @nconnect > 1, use a single connection to perform lease management,
> and open @nconnect additional connections that handle only per-
> mount I/O activity.
> 
> 
> > I think CREATE_SESSION is allowed as long as the principals agree, and
> > that's why the call at C2 succeeds.  Seems a little weird, though.
> 
> Well, there's no SEQUENCE operation in that COMPOUND. No session
> or connection to use there, I think the principal and client ID
> are the only way to recognize the target of the operation?

I'm just not clear why the explicit BIND_CONN_TO_SESSION is required in
the gss case.

Actually, it's not gss exactly, it's the state protection level:

	If, when the client ID was created, the client opted for
	SP4_NONE state protection, the client is not required to use
	BIND_CONN_TO_SESSION to associate the connection with the
	session, unless the client wishes to associate the connection
	with the backchannel.  When SP4_NONE protection is used, simply
	sending a COMPOUND request with a SEQUENCE operation is
	sufficient to associate the connection with the session
	specified in SEQUENCE.

Anyway.

--b.

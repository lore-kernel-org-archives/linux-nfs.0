Return-Path: <bfields@fieldses.org>
Date: Mon, 12 Sep 2016 12:18:41 -0400
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Chuck Lever <chuck.lever@oracle.com>
Cc: Benjamin Coddington <bcodding@redhat.com>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH v1] svcauth_gss: Close connection when dropping an
 incoming message
Message-ID: <20160912161841.GC10827@fieldses.org>
References: <20160907202552.15084.40866.stgit@klimt.1015granger.net>
 <20160909211822.GA25868@fieldses.org>
 <E19D3355-0937-4D59-AEF9-230A5DE8F28E@oracle.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <E19D3355-0937-4D59-AEF9-230A5DE8F28E@oracle.com>
List-ID: <linux-nfs.vger.kernel.org>

On Mon, Sep 12, 2016 at 11:57:13AM -0400, Chuck Lever wrote:
> Hi Bruce-
> 
> 
> > On Sep 9, 2016, at 5:18 PM, J. Bruce Fields <bfields@fieldses.org> wrote:
> > 
> > On Wed, Sep 07, 2016 at 04:36:19PM -0400, Chuck Lever wrote:
> >> S5.3.3.1 of RFC 2203 requires that an incoming GSS-wrapped message
> >> whose sequence number lies outside the current window is dropped.
> >> The rationale is:
> >> 
> >>  The reason for discarding requests silently is that the server
> >>  is unable to determine if the duplicate or out of range request
> >>  was due to a sequencing problem in the client, network, or the
> >>  operating system, or due to some quirk in routing, or a replay
> >>  attack by an intruder.  Discarding the request allows the client
> >>  to recover after timing out, if indeed the duplication was
> >>  unintentional or well intended.
> >> 
> >> However, clients may rely on the server dropping the connection to
> >> indicate that a retransmit is needed. Without a connection reset, a
> >> client can wait forever without retransmitting, and the workload
> >> just stops dead. I've reproduced this behavior by running xfstests
> >> generic/323 on an NFSv4.0 mount with proto=rdma and sec=krb5i.
> >> 
> >> To address this issue, have the server close the connection when it
> >> silently discards an incoming message due to a GSS sequence number
> >> problem.
> >> 
> >> Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
> >> Cc: Benjamin Coddington <bcodding@redhat.com>
> >> ---
> >> Hi-
> >> 
> >> Passed testing with my reproducer: 10 runs of generic/323 with
> >> proto=rdma and sec=krb5i, with NFSv3, NFSv4.0, and NFSv4.1.
> >> generic/323 is 120 seconds or so of a heavy aio workload.
> >> 
> >> I tested with that dprintk replaced with pr_warn to confirm that the
> >> reproducer hits this path one or more times per test run.
> > 
> > Thanks, this is useful, but before applying I'd just like to audit other
> > uses of SVC_DROP in the server rpc code as this probably isn't the only
> > place with this problem.
> 
> Consider this a test result, then.
> 
> So, "I'd just like to audit" means you are doing the auditing now, or
> would you like me to dig into that?

I haven't looked at it, if you can that would be fantastic.

> > Also, this changes behavior for v2/v3 too, does that cause any problems?
> > Is it OK for the server to just always close connections on dropping in
> > the v2/v3 case too?
> 
> I've run the same tests with NFSv3 (NFS/RDMA + krb5i or krb5p) and did
> not see a negative impact. Not much, but there it is.
> 
> What would provide more confidence that NFSv2/3 is not impacted?

I guess I'm not too worried.  Surely NFSv3 clients have always had to
handle reconnecting connections closed by the server.

--b.

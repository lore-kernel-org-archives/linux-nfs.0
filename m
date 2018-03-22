Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([173.255.197.46]:48270 "EHLO fieldses.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751291AbeCVVBf (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Thu, 22 Mar 2018 17:01:35 -0400
Date: Thu, 22 Mar 2018 17:01:35 -0400
From: Bruce Fields <bfields@fieldses.org>
To: Chuck Lever <chuck.lever@oracle.com>
Cc: Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH 09/15] sunrpc: Report per-RPC execution stats
Message-ID: <20180322210135.GD31914@fieldses.org>
References: <20180313154053.21531.86316.stgit@klimt.1015granger.net>
 <20180313154427.21531.85993.stgit@klimt.1015granger.net>
 <20180314205042.GB7241@fieldses.org>
 <D5995467-0177-4E26-8CCF-5E8150F20687@oracle.com>
 <70E04F09-EAD2-46B1-B2E8-F501CB8298AF@oracle.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <70E04F09-EAD2-46B1-B2E8-F501CB8298AF@oracle.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, Mar 22, 2018 at 04:32:36PM -0400, Chuck Lever wrote:
> 
> 
> > On Mar 14, 2018, at 9:11 PM, Chuck Lever <chuck.lever@oracle.com> wrote:
> > 
> > 
> > 
> >> On Mar 14, 2018, at 4:50 PM, J. Bruce Fields <bfields@fieldses.org> wrote:
> >> 
> >> On Tue, Mar 13, 2018 at 11:44:27AM -0400, Chuck Lever wrote:
> >>> Introduce a mechanism to report the server-side execution latency of
> >>> each RPC. The goal is to enable user space to filter the trace
> >>> record for latency outliers, build histograms, etc.
> >> 
> >> Neato.
> >> 
> >> To be useful I'd think you'd want more information about each RPC.
> >> (E.g. you'd like to know that the latency outliers all did reads).  I
> >> guess you could use the address and xid to cross-reference with
> >> information collected from somewhere else?
> > 
> > Yes. You can enable other trace points (like the nfsd_compound ones)
> > to see what class each operation is in.
> > 
> > And yes, I would like to have all the relevant information for each
> > RPC in a single trace record; I just haven't figured out a way to
> > extract it as nicely as I did it on the client (patch forthcoming).
> > On the client side, there is a table set up for each RPC program that
> > contains an RPC procedure name to procedure number mapping. I was not
> > able to find a similar convenience on the server side.
> > 
> > 
> >> What's our commitment to backwards compatibility?  Trace points seem to
> >> be the wild west compared to the rest of the kernel interface, but if
> >> we want to encourage tooling on top of this then I guess we'll need to
> >> be strict.
> > 
> > That has been discussed elsewhere (LWN.net and more recently on
> > linux-rdma). The only compatibility issues are with trace points that
> > have user tools and infrastructure that depends on them, such as the
> > scheduler trace points used for latencyTOP. The NFS and sunrpc trace
> > points do not have this constraint, as they are processed currently
> > only by generic tools like trace-cmd. So we are free to innovate for
> > the time being.
> > 
> > 
> >> Looking at the tcp case, I think it's measuring from the time
> >> tcp_recvfrom receives the last fragment making up an rpc request till
> >> the last sendpage() of the reply returns.  Did you consider other spots?
> >> (E.g. why after the send instead of before?)
> > 
> > Yes, I've considered other spots. I don't consider the spots I'm
> > proposing here to be written in stone. I welcome help for placing the
> > socket-based timestamp capture points.
> > 
> > Some sendto implementations are more complex than others. For instance,
> > RPC/RDMA can post RDMA Writes containing data content first, then in the
> > final step post the RDMA Send carrying the RPC Reply header. The RDMA
> > Write step can be considered server-side processing, and thus is part
> > of the latency. Or, if we ever decide to move the RDMA Write step into
> > the XDR layer, it will definitely be counted as processing latency.
> > 
> > One thing I would like to keep in the latency measurement is how long
> > this rqstp has waited to acquire the send mutex. But otherwise, I'm
> > open to other ideas about how to measure this latency.
> 
> Hi Bruce-
> 
> How about measuring the same way for all transports:
> 
> - Capture a timestamp when xpo_recvfrom returns a positive value
> 
> - Fire the svc_stats_latency event just before invoking xpo_sendto
> 
> Would you be more comfortable with that arrangement?

I honestly don't know.  If I understand right: if we put that event just
before xpo_sendto, then in the case you describe above (RDMA Write step
moved between xdr layer and sendto), the latency number would change for
no really good reason.  So that's a case for your original approach?

I don't know what's likely to contribute to sendto latency in the socket
case.

Really, I've never done latency tracing, and from what I've seen you may
have done more than any of us, so I trust your judgement here....

--b.

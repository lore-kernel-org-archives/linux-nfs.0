Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:58100 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751331AbaC2Av1 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 28 Mar 2014 20:51:27 -0400
Date: Fri, 28 Mar 2014 20:51:26 -0400
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Tom Tucker <tom@opengridcomputing.com>
Cc: Steve Wise <swise@opengridcomputing.com>, trond.myklebust@primarydata.com,
        linux-nfs@vger.kernel.org
Subject: Re: [PATCH] Fix regression in NFSRDMA server
Message-ID: <20140329005126.GM6041@fieldses.org>
References: <20140325201457.6861.21819.stgit@build.ogc.int>
 <20140328020834.GD27633@fieldses.org>
 <53359377.8060502@opengridcomputing.com>
 <20140328212633.GF6041@fieldses.org>
 <53360FCC.4000602@opengridcomputing.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <53360FCC.4000602@opengridcomputing.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, Mar 28, 2014 at 07:11:56PM -0500, Tom Tucker wrote:
> Hi Bruce,
> 
> On 3/28/14 4:26 PM, J. Bruce Fields wrote:
> >On Fri, Mar 28, 2014 at 10:21:27AM -0500, Tom Tucker wrote:
> >>Hi Bruce,
> >>
> >>On 3/27/14 9:08 PM, J. Bruce Fields wrote:
> >>>On Tue, Mar 25, 2014 at 03:14:57PM -0500, Steve Wise wrote:
> >>>>From: Tom Tucker <tom@ogc.us>
> >>>>
> >>>>The server regression was caused by the addition of rq_next_page
> >>>>(afc59400d6c65bad66d4ad0b2daf879cbff8e23e). There were a few places that
> >>>>were missed with the update of the rq_respages array.
> >>>Apologies.  (But, it could happen again--could we set up some regular
> >>>testing?  It doesn't have to be anything fancy, just cthon over
> >>>rdma--really, just read and write over rdma--would probably catch a
> >>>lot.)
> >>I think Chelsio is going to be adding some NFSRDMA regression
> >>testing to their system test.
> >OK.  Do you know who there is setting that up?  I'd be curious exactly
> >what kernels they intend to test and how they plan to report results.
> >
> 
> I don't know, Steve can weigh in on this...
> 
> >>>Also: I don't get why all these rq_next_page initializations are
> >>>required.  Why isn't the initialization at the top of svc_process()
> >>>enough?  Is rdma using it before we get to that point?  The only use of
> >>>it I see off hand is in the while loop that you're deleting.
> >>I didn't apply tremendous deductive powers here, I just added
> >>updates to rq_next_page wherever the transport messed with
> >>rq_respages. That said, NFS WRITE is likely the culprit since the
> >>write is completed as a deferral and therefore the request doesn't
> >>go through svc_process, so if rq_next_page is bogus, the cleanup
> >>will free/re-use pages that are actually in use by the transport.
> >Ugh, OK, without tracing through the code I guess I can see how that
> >would happen.  Remind me why it's using deferrals?
> 
> The server fetches the write data from the client using RDMA READ.
> So the request says ... "here's where the data is in my memory", and
> then the server issues an RDMA READ to fetch it. When the read
> completes, the deferred request is completed.

That makes sense, but maybe I'm not sure what you mean by deferring.

The tcp code can also receive a request over multiple recvfroms.  See
Trond's hack in 31d68ef65c7d4 "SUNRPC: Don't wait for full record to
receive tcp data".

--b.

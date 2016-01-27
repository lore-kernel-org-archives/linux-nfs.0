Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from bedivere.hansenpartnership.com ([66.63.167.143]:41414 "EHLO
	bedivere.hansenpartnership.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S932303AbcA0RCx (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 27 Jan 2016 12:02:53 -0500
Message-ID: <1453914154.2322.23.camel@HansenPartnership.com>
Subject: Re: [Lsf-pc] [LSF/MM TOPIC/ATTEND] RDMA passive target
From: James Bottomley <James.Bottomley@HansenPartnership.com>
To: Boaz Harrosh <boaz@plexistor.com>, Chuck Lever <chuck.lever@oracle.com>,
        lsf-pc@lists.linux-foundation.org,
        Dan Williams <dan.j.williams@intel.com>,
        Yigal Korman <yigal@plexistor.com>
Cc: Linux RDMA Mailing List <linux-rdma@vger.kernel.org>,
        linux-fsdevel <linux-fsdevel@vger.kernel.org>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>,
        Jan Kara <jack@suse.cz>, Ric Wheeler <rwheeler@redhat.com>
Date: Wed, 27 Jan 2016 09:02:34 -0800
In-Reply-To: <56A8F646.5020003@plexistor.com>
References: <06414D5A-0632-4C74-B76C-038093E8AED3@oracle.com>
	 <56A8F646.5020003@plexistor.com>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, 2016-01-27 at 18:54 +0200, Boaz Harrosh wrote:
> On 01/25/2016 11:19 PM, Chuck Lever wrote:
> > I'd like to propose a discussion of how to take advantage of
> > persistent memory in network-attached storage scenarios.
> > 
> > RDMA runs on high speed network fabrics and offloads data
> > transfer from host CPUs. Thus it is a good match to the
> > performance characteristics of persistent memory.
> > 
> > Today Linux supports iSER, SRP, and NFS/RDMA on RDMA
> > fabrics. What kind of changes are needed in the Linux I/O
> > stack (in particular, storage targets) and in these storage
> > protocols to get the most benefit from ultra-low latency
> > storage?
> > 
> > There have been recent proposals about how storage protocols
> > and implementations might need to change (eg. Tom Talpey's
> > SNIA proposals for changing to a push data transfer model,
> > Sagi's proposal to utilize DAX under the NFS/RDMA server,
> > and my proposal for a new pNFS layout to drive RDMA data
> > transfer directly).
> > 
> > The outcome of the discussion would be to understand what
> > people are working on now and what is the desired
> > architectural approach in order to determine where storage
> > developers should be focused.
> > 
> > This could be either a BoF or a session during the main
> > tracks. There is sure to be a narrow segment of each
> > track's attendees that would have interest in this topic.
> > 
> 
> I would like to attend this talk, and also talk about
> a target we have been developing / utilizing that we would like
> to propose as a Linux standard driver.

For everyone who hasn't sent an attend request in, this is a good
example of how not to get an invitation.  When collecting the requests
to attend, the admins tend to fold to the top of thread,  so if you
send a request to attend as a reply to somebody else, it won't be seen
by that process.

You don't need to resend this one, I noticed it, but just in case next
time ...

James


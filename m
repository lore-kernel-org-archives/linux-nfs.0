Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([174.143.236.118]:47465 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752330Ab1I3PF7 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 30 Sep 2011 11:05:59 -0400
Date: Fri, 30 Sep 2011 11:05:58 -0400
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Bryan Schumaker <bjschuma@netapp.com>
Cc: linux-nfs@vger.kernel.org
Subject: Re: [PATCH v3 1/3] NFSD: Added fault injection
Message-ID: <20110930150558.GE19125@fieldses.org>
References: <1317322765-19094-1-git-send-email-bjschuma@netapp.com>
 <20110930143508.GC19125@fieldses.org>
 <4E85D81F.3080108@netapp.com>
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <4E85D81F.3080108@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Fri, Sep 30, 2011 at 10:54:23AM -0400, Bryan Schumaker wrote:
> On 09/30/2011 10:35 AM, J. Bruce Fields wrote:
> > On Thu, Sep 29, 2011 at 02:59:23PM -0400, bjschuma@netapp.com wrote:
> >> From: Bryan Schumaker <bjschuma@netapp.com>
> >>
> >> Fault injection on the NFS server makes it easier to test the client's
> >> state manager and recovery threads.  Simulating errors on the server is
> >> easier than finding the right conditions that cause them naturally.
> > 
> > You also might look at the unlock_ip interface that Wendy Cheng added a
> > few years ago. The fact that it doesn't remove nfsv4 state is really a
> > bug, it should be blowing away any relevant v4 clients as the same time.
> > 
> > (Though note the IP in question is a server IP, not a client IP.)
> 
> I'll take a look.  Thanks for the warning that it looks for a server IP, but would passing the client IP be more useful?

It was designed for people using floating IP's to make their server look
like multiple servers, who want to shut down just the client's using one
of the floating IP's.

> > Is this the forget_n_clients scenario really a useful one to test?
> > I'd've thought that the client would need to deal with the entire client
> > diseappearing (due to network partition, for example), but not normally
> > individual open owners.
> 
> It might not be a normal case, but it still could be interesting to see how the client recovers.
> 
> I was mostly looking at what state the server tracks and deleting what I could find.

I think it would be more interesting to find out what typical failure
scenarios are and then figure out how to simulate them.

--b.

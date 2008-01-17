From: Frank Filz <ffilzlnx@us.ibm.com>
Subject: Re: [PATCH 1/2] NLM failover unlock commands
Date: Thu, 17 Jan 2008 09:35:23 -0800
Message-ID: <1200591323.13670.34.camel@dyn9047022153>
References: <20080110075959.GA9623@infradead.org>
	 <4788665B.4020405@redhat.com> <18315.62909.330258.83038@notabene.brown>
	 <478D14C5.1000804@redhat.com> <18317.7319.443532.62244@notabene.brown>
	 <478D3820.9080402@redhat.com> <20080117151007.GB16581@fieldses.org>
	 <478F78E8.40601@redhat.com> <20080117163105.GG16581@fieldses.org>
	 <478F82DA.4060709@redhat.com>  <20080117164002.GH16581@fieldses.org>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Wendy Cheng <wcheng@redhat.com>, Neil Brown <neilb@suse.de>,
	Christoph Hellwig <hch@infradead.org>,
	NFS list <linux-nfs@vger.kernel.org>, cluster-devel@redhat.com
To: "J. Bruce Fields" <bfields@fieldses.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from e6.ny.us.ibm.com ([32.97.182.146]:54806 "EHLO e6.ny.us.ibm.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750946AbYAQRfr (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 17 Jan 2008 12:35:47 -0500
Received: from d01relay04.pok.ibm.com (d01relay04.pok.ibm.com [9.56.227.236])
	by e6.ny.us.ibm.com (8.13.8/8.13.8) with ESMTP id m0HHbZZ7020079
	for <linux-nfs@vger.kernel.org>; Thu, 17 Jan 2008 12:37:35 -0500
Received: from d01av01.pok.ibm.com (d01av01.pok.ibm.com [9.56.224.215])
	by d01relay04.pok.ibm.com (8.13.8/8.13.8/NCO v8.7) with ESMTP id m0HHZiEs241188
	for <linux-nfs@vger.kernel.org>; Thu, 17 Jan 2008 12:35:44 -0500
Received: from d01av01.pok.ibm.com (loopback [127.0.0.1])
	by d01av01.pok.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id m0HHZhur022591
	for <linux-nfs@vger.kernel.org>; Thu, 17 Jan 2008 12:35:44 -0500
In-Reply-To: <20080117164002.GH16581@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, 2008-01-17 at 11:40 -0500, J. Bruce Fields wrote:
> On Thu, Jan 17, 2008 at 11:31:22AM -0500, Wendy Cheng wrote:
> >> 	it *should* be the case that the set of locks held on the
> >> 	filesystem(s) that are moving are the same as the set of locks
> >> 	held by the virtual ip that is moving.
> >>
> >> is still true in the cluster filesystem case, right?
> >>
> >> --b.
> >>   
> > Yes .... Wendy
> 
> In one situations (buggy client?  Weird network failure?) could that
> fail to be the case?
> 
> Would there be any advantage to enforcing that requirement in the
> server?  (For example, teaching nlm to reject any locking request for a
> certain filesystem that wasn't sent to a certain server IP.)

Trying to dredge up my clustered nfsd/lockd memories from having worked
on an implementation more than 7 years ago...

With a clustered filesystem being exported, it might be the case that
the cluster has a set of IP addresses (probably one per node) that are
used for load balancing clients. Each node exports all file systems. As
nodes fail (and all of this only matters when an interface failing is
the cause of node failure - a node crash need not apply here), ip
addresses are failed-over to other nodes, taking with them the set of
clients that were accessing the cluster via that ip address.

I assume the intent here with this implementation is that the node
taking over will start lock recovery for the ip address? With that
perspective, I guess it would be important that each file system only be
accessed with a single ip address otherwise lock recovery will not work
correctly since another node/ip could accept locks for that filesystem,
possibly "stealing" a lock that is in recovery. As I recall, our
implementation put the entire filesystem cluster-wide into recovery
during fail-over.

Frank



From: Felix Blyakher <felixb@sgi.com>
Subject: Re: [Cluster-devel] Re: [PATCH 1/2] NLM failover unlock commands
Date: Mon, 28 Jan 2008 11:06:08 -0600
Message-ID: <14EB4250-8AC2-4AA1-B856-5308FF3ECAA7@sgi.com>
References: <478D14C5.1000804@redhat.com> <18317.7319.443532.62244@notabene.brown> <478D3820.9080402@redhat.com> <20080117151007.GB16581@fieldses.org> <478F78E8.40601@redhat.com> <20080117163105.GG16581@fieldses.org> <478F82DA.4060709@redhat.com> <20080117164002.GH16581@fieldses.org> <478F9946.9010601@redhat.com> <20080117202342.GA6416@fieldses.org> <20080124160030.GB26164@fieldses.org> <73E1F599-3281-4B3B-8372-1E91C21C8E24@sgi.com> <479DFB2F.104@redhat.com>
Mime-Version: 1.0 (Apple Message framework v752.3)
Content-Type: text/plain; charset=US-ASCII; delsp=yes; format=flowed
Cc: "J.Bruce Fields" <bfields@fieldses.org>,
	Neil Brown <neilb@suse.de>,
	Christoph Hellwig <hch@infradead.org>,
	NFS list <linux-nfs@vger.kernel.org>, cluster-devel@redhat.com
To: Wendy Cheng <wcheng@redhat.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from relay1.sgi.com ([192.48.171.29]:59338 "EHLO relay.sgi.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1755562AbYA1RGL (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 28 Jan 2008 12:06:11 -0500
In-Reply-To: <479DFB2F.104@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


On Jan 28, 2008, at 9:56 AM, Wendy Cheng wrote:

> Felix Blyakher wrote:
>>>
>>> (I think Wendy's pretty close to that api already after adding the
>>> second method to start grace?)
>
> For reclaiming grace period issues, maybe we should move to
> https://www.redhat.com/archives/cluster-devel/2008-January/ 
> msg00340.html thread ?
>
> I view this (unlock) patch set is mostly done and really don't want  
> to add more complications to it.

Heh, that was rather reply to Bruce's looking forward discussion
on related issues. Incidentally it was attached to your unlock
patch thread.

No problem with your patch, Wendy.

Cheers,
Felix


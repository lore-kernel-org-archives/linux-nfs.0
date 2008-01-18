From: Wendy Cheng <wcheng@redhat.com>
Subject: Re: [PATCH 1/2] NLM failover unlock commands
Date: Fri, 18 Jan 2008 09:56:38 -0500
Message-ID: <4790BE26.30304@redhat.com>
References: <478D14C5.1000804@redhat.com> <18317.7319.443532.62244@notabene.brown> <478D3820.9080402@redhat.com> <20080117151007.GB16581@fieldses.org> <478F78E8.40601@redhat.com> <20080117163105.GG16581@fieldses.org> <478F82DA.4060709@redhat.com> <20080117164002.GH16581@fieldses.org> <478F9946.9010601@redhat.com> <20080117202342.GA6416@fieldses.org> <20080118100308.GA26106@janus>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Cc: "J. Bruce Fields" <bfields@fieldses.org>,
	Neil Brown <neilb@suse.de>,
	Christoph Hellwig <hch@infradead.org>,
	NFS list <linux-nfs@vger.kernel.org>, cluster-devel@redhat.com
To: Frank van Maarseveen <frankvm@frankvm.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([66.187.233.31]:54372 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755240AbYARPAo (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 18 Jan 2008 10:00:44 -0500
In-Reply-To: <20080118100308.GA26106@janus>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Frank van Maarseveen wrote:
>
>> 	- We want to be able to move an export to a node with an already
>> 	  active nfs server.  Currently that requires restarting all of
>> 	  nfsd on the target node.  This is what I understand your next
>> 	  patch fixes.
>>     
>
> Maybe a silly question but what about using "exportfs -r" for this?
>   

/me prays we won't go back to our *old* export failover proposal (about 
two years ago) :) ...

Anyway, re-export is part of the required steps that take-over server 
needs to do. It, however, doesn't handle lockd grace period so we will 
have the possibility that other client will steal the locks away. That's 
why Bruce and I are working on the second "resume" patch at this moment.

-- Wendy


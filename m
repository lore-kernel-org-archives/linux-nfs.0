From: James Lentini <jlentini@netapp.com>
Subject: Re: server rdma todo's
Date: Tue, 1 Jul 2008 10:21:40 -0400 (EDT)
Message-ID: <alpine.LFD.1.10.0807011015190.3428@jlentini-linux.nane.netapp.com>
References: <20080630233433.GH15719@fieldses.org>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: linux-nfs@vger.kernel.org, Tom Tucker <tom@opengridcomputing.com>
To: "J. Bruce Fields" <bfields@fieldses.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:40076 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755934AbYGAOVl (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 1 Jul 2008 10:21:41 -0400
In-Reply-To: <20080630233433.GH15719@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


On Mon, 30 Jun 2008, J. Bruce Fields wrote:

> I've got a few very small server-rdma todo's lying around; would you be
> the right person to help with them?
> 
> 	- Documentation on nfsrdma security issues.  (Examples of setup
> 	  that would be secure, under what asssumptions, etc.)

What document would this be for? Is there an example of the format for 
TCP or UDP? 

When do you need this by? We should involve Tom Talpey in this, but he 
is away on vacation this week. I think Tucker is on vacation this week 
too.

> 	- Fix Kconfig rmda help to mention server too.

Tucker or I could do that. Which Kconfig did you want to update?

I also need to incorporate Chuck's suggestions into the updated 
NFS/RDMA readme.

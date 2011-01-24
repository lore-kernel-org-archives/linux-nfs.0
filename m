Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([174.143.236.118]:57698 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753948Ab1AXSFZ (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 24 Jan 2011 13:05:25 -0500
Date: Mon, 24 Jan 2011 13:05:24 -0500
To: Max Veprinsky <max.veprinsky@livetext.com>
Cc: linux-nfs@vger.kernel.org
Subject: Re: releasing space after rapid grwoth
Message-ID: <20110124180524.GA15056@fieldses.org>
References: <AANLkTi=R_j3_hZ-7RpSn0_Mee43nU0njPRBSn=DiEf8R@mail.gmail.com>
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <AANLkTi=R_j3_hZ-7RpSn0_Mee43nU0njPRBSn=DiEf8R@mail.gmail.com>
From: "J. Bruce Fields" <bfields@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Fri, Jan 21, 2011 at 05:06:45PM -0600, Max Veprinsky wrote:
> Hello all,
> 
> I'm trying to reclaim disk space on stable storage which was consumed
> by a crashed apache process at a rate of ~100GB/hour. This issue has
> happened a few times before and normally resolved by discovering a
> .nfsXXXXX file, stopping the process on the the application server
> that was holding the file. Sometimes the used filespace is recovered
> quickly without manual intervention, other times I had to delete the
> .nfsXXXX file manually.
> 
> Last time this happened 3 TB of disk space was consumed and no
> .nfsXXXX file of that size was discovered, nor. I dismounted all of
> the volumes from the clients 1/2 of the space was recovered.
> 
> showmount shows clients connected but there are no network nfs
> connections open to any client.

And all the clients *have* unmounted, right?

> I have not restarted nfs server
> service fearing that the used space would not be recovered.
> 
> Any suggestion greatly appreciated

More details about the setup?  Are clients and server all Linux, and
what kernel versions?

--b.

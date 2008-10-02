From: Peter Staubach <staubach@redhat.com>
Subject: Re: Is NFS v4 stable and recommend to use now?
Date: Thu, 02 Oct 2008 15:15:40 -0400
Message-ID: <48E51DDC.7090503@redhat.com>
References: <beaf78240810020949j703d95cvab1c44f33bff7019@mail.gmail.com> <20081002171719.GA30408@fieldses.org> <20081002174129.GD6039@citi.umich.edu>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Cc: "J. Bruce Fields" <bfields@fieldses.org>,
	"Roy M." <setesting001@gmail.com>, linux-nfs@vger.kernel.org
To: Jim Rees <rees@umich.edu>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.redhat.com ([66.187.237.31]:50261 "EHLO mx2.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753671AbYJBTPq (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 2 Oct 2008 15:15:46 -0400
In-Reply-To: <20081002174129.GD6039@citi.umich.edu>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Jim Rees wrote:
> J. Bruce Fields wrote:
>
>   Raw throughput should be the same.  And I think the little benchmarking
>   I've seen has found that to be true.
>
> Actually v4 is better on fast nets because you can make the iosize bigger.
>   

How is that?  NFSv3 supports a 32 bit transfer size and runs over
TCP, just the same as NFSv4.

The benefits should come via the use of delegations to decrease
some latencies.

       ps

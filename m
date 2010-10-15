From: Tejun Heo <tj@kernel.org>
Subject: Re: [PATCH linux-2.6.36-rc7] sunrpc/xprtrdma: clean up workqueue
 usage
Date: Fri, 15 Oct 2010 21:11:01 +0200
Message-ID: <4CB8A745.5020206@kernel.org>
References: <4CB87807.7050108@kernel.org> <20101015171132.GA18869@fieldses.org> <4CB89393.6000207@opengridcomputing.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: "J. Bruce Fields" <bfields@fieldses.org>,
	Trond Myklebust <Trond.Myklebust@netapp.com>,
	linux-nfs@vger.kernel.org, lkml <linux-kernel@vger.kernel.org>,
	Tom Tucker <tom@ogc.us>
To: Tom Tucker <tom@opengridcomputing.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from hera.kernel.org ([140.211.167.34]:32907 "EHLO hera.kernel.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756401Ab0JOTLy (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 15 Oct 2010 15:11:54 -0400
In-Reply-To: <4CB89393.6000207@opengridcomputing.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 10/15/2010 07:46 PM, Tom Tucker wrote:
>  On 10/15/10 12:11 PM, J. Bruce Fields wrote:
>> Tom, could you take a look?
>>
> This looks reasonable to me.
> 
> My bet is that it wasn't tested though due to hardware
> availability. I'll test it this weekend and let you know how it
> goes.

Yeap, only compile tested.  Testing would be much appreciated.

Thanks.

-- 
tejun

Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-vc0-f178.google.com ([209.85.220.178]:43365 "EHLO
	mail-vc0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750999AbaKKQws convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 11 Nov 2014 11:52:48 -0500
References: <20141109010328.8806.5861.stgit@manet.1015granger.net> <20141109011501.8806.23478.stgit@manet.1015granger.net> <54621D8D.7050508@dev.mellanox.co.il>
Mime-Version: 1.0 (1.0)
In-Reply-To: <54621D8D.7050508@dev.mellanox.co.il>
Content-Type: text/plain;
	charset=us-ascii
Message-Id: <1D304B95-D745-42B2-9324-143A5002FB35@gmail.com>
Cc: Chuck Lever <chuck.lever@oracle.com>,
        "linux-rdma@vger.kernel.org" <linux-rdma@vger.kernel.org>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
From: Chuck Lever <chucklever@gmail.com>
Subject: Re: [PATCH v2 07/10] xprtrdma: Display async errors
Date: Tue, 11 Nov 2014 10:52:49 -0600
To: Sagi Grimberg <sagig@dev.mellanox.co.il>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


> On Nov 11, 2014, at 8:30 AM, Sagi Grimberg <sagig@dev.mellanox.co.il> wrote:
> 
>> On 11/9/2014 3:15 AM, Chuck Lever wrote:
>> An async error upcall is a hard error, and should be reported in
>> the system log.
>> 
> 
> Could be useful to others... Any chance you put this in ib_core for all
> of us?

Eventually. We certainly wouldn't want copies of this array of strings
to appear many times in the kernel. That would be a waste of space.

I have a similar patch that adds an array for CQ status codes, and
xprtrdma has a string array already for connection status. Are those
also interesting?
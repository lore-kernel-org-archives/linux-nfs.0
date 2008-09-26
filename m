From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: [PATCH 10/10] svcrdma: Documentation update for the FastReg
	memory model
Date: Fri, 26 Sep 2008 19:40:06 -0400
Message-ID: <20080926234006.GA9889@fieldses.org>
References: <1221564879-85046-4-git-send-email-tom@opengridcomputing.com> <1221564879-85046-5-git-send-email-tom@opengridcomputing.com> <1221564879-85046-6-git-send-email-tom@opengridcomputing.com> <1221564879-85046-7-git-send-email-tom@opengridcomputing.com> <1221564879-85046-8-git-send-email-tom@opengridcomputing.com> <1221564879-85046-9-git-send-email-tom@opengridcomputing.com> <1221564879-85046-10-git-send-email-tom@opengridcomputing.com> <1221564879-85046-11-git-send-email-tom@opengridcomputing.com> <20080924212102.GD10841@fieldses.org> <48DB939E.4090503@opengridcomputing.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-nfs@vger.kernel.org
To: Tom Tucker <tom@opengridcomputing.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail.fieldses.org ([66.93.2.214]:51850 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752895AbYIZXkI (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 26 Sep 2008 19:40:08 -0400
In-Reply-To: <48DB939E.4090503@opengridcomputing.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, Sep 25, 2008 at 08:35:26AM -0500, Tom Tucker wrote:
> J. Bruce Fields wrote:
>> This explanation is helpful, thanks.  It would also be helpful if we
>> could boil down the advice to just a sentence or two for the busy admin.
>> Something like:  unless you have card XYZ and kernel 2.6.y, do *not* use
>> rdma on a network where you cannot trust every machine....
>
>
> Would it be better to say, "Do not use RDMA on a network where your  
> policy requires a security model stronger than tcp/auth_unix."

I'm not worried about the case where the security provided is roughly
equivalent to that provided by tcp/auth_unix.

I'm worried about the non-"Fast Reg" case where I thought you were
saying that the network could access memory other than that meant to
hold rpc data.

--b.

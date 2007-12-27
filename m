From: Jeff Garzik <jeff@garzik.org>
Subject: Re: read-ahead in NFS server
Date: Thu, 27 Dec 2007 10:07:38 -0500
Message-ID: <4773BFBA.70709@garzik.org>
References: <c70ff3ad0712260351i6583aa8dpbf16ed606a634b1f@mail.gmail.com>	 <47730F2F.3080900@garzik.org>	 <c70ff3ad0712270050u134616d1q459ed073c586dcec@mail.gmail.com>	 <47739288.7000308@garzik.org> <c70ff3ad0712270700h6336b194r7c21834423aeb331@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Cc: linux-kernel@vger.kernel.org, NFS list <linux-nfs@vger.kernel.org>
To: saeed bishara <saeed.bishara@gmail.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:59923 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751934AbXL0PHl (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 27 Dec 2007 10:07:41 -0500
In-Reply-To: <c70ff3ad0712270700h6336b194r7c21834423aeb331-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

saeed bishara wrote:
>>>> Are you using TCP?  Are you using NFSv4, or an older version?
>>> I'm using NFSv3/UDP.
>> IMO, you definitely want TCP and NFSv4.  Much better network behavior,
>> with some of the silly UDP limits (plus greatly improved caching
>> behavior, due to v4 delegations).
> the clients of my system going to be embedded system with low
> performance cpus and I need UDP as it needs less cpu power.

I bet
	TCP + fewer revalidations + greater local pagecache activity
uses less cpu power than
	UDP + revalidations + rx/tx network activity


>>> when I run local dd with bs=4K, I can see that the average IO size is
>>> more than 300KB.
>> Read-ahead is easier in NFSv4, because the client probably has the file
>> delegated locally, and has far less need to constantly revalidate file
>> mapping(s).
> I'll check that.
> but what about the server side? why the issued IO's are only as twice
> as the size of the NFS requests?

No idea.  I bet the source code can tell you :)

	Jeff



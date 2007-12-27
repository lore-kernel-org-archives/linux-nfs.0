From: Jeff Garzik <jeff@garzik.org>
Subject: Re: read-ahead in NFS server
Date: Thu, 27 Dec 2007 06:54:48 -0500
Message-ID: <47739288.7000308@garzik.org>
References: <c70ff3ad0712260351i6583aa8dpbf16ed606a634b1f@mail.gmail.com>	 <47730F2F.3080900@garzik.org> <c70ff3ad0712270050u134616d1q459ed073c586dcec@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Cc: linux-kernel@vger.kernel.org, NFS list <linux-nfs@vger.kernel.org>
To: saeed bishara <saeed.bishara@gmail.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:44102 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751533AbXL0Lyv (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 27 Dec 2007 06:54:51 -0500
In-Reply-To: <c70ff3ad0712270050u134616d1q459ed073c586dcec-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

saeed bishara wrote:
>> (linux-nfs added to cc)
>>
>> I cannot speak for the NFS server code specifically, but 32kb sounds
>> like a network read (or write) data size limit.
> yes
>> Are you using TCP?  Are you using NFSv4, or an older version?
> I'm using NFSv3/UDP.

IMO, you definitely want TCP and NFSv4.  Much better network behavior, 
with some of the silly UDP limits (plus greatly improved caching 
behavior, due to v4 delegations).


> I found that the actual requests size was 16KB, after doing some hacks
> in server&client I managed to make it 60KB, now I see better
> performance, and I see that the average request size is ~130KB which
> means that there is actually read-ahead. but why it's only 130KB? how
> can I make it larger?
> when I run local dd with bs=4K, I can see that the average IO size is
> more than 300KB.

Read-ahead is easier in NFSv4, because the client probably has the file 
delegated locally, and has far less need to constantly revalidate file 
mapping(s).

	Jeff




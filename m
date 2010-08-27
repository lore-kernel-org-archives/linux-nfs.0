Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:26779 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752708Ab0H0NHm (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 27 Aug 2010 09:07:42 -0400
Message-ID: <4C77B873.8010306@netapp.com>
Date: Fri, 27 Aug 2010 09:06:59 -0400
From: Bryan Schumaker <bjschuma@netapp.com>
To: Artem.Bityutskiy@nokia.com
CC: "J. Bruce Fields" <bfields@fieldses.org>, Jens Axboe <jaxboe@fusionio.com>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>,
        Trond Myklebust <trond@netapp.com>, Christoph Hellwig <hch@lst.de>
Subject: Re: hang in writeback code on nfsv4 mount
References: <20100825023425.GA24591@fieldses.org>	 <1282889595.2763.14.camel@localhost> <1282901780.12016.54.camel@localhost>
In-Reply-To: <1282901780.12016.54.camel@localhost>
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

 The patch fixed my unmount hang.

-Bryan

On 08/27/2010 05:36 AM, Artem Bityutskiy wrote:
> On Fri, 2010-08-27 at 09:13 +0300, Artem Bityutskiy wrote:
>> From aa87b87c8555151bb8e083d0dba3fd68c5b0d811 Mon Sep 17 00:00:00 2001
>> From: Artem Bityutskiy <Artem.Bityutskiy@nokia.com>
>> Date: Fri, 27 Aug 2010 08:21:18 +0300
>> Subject: [PATCH] writeback: do not lose wakeup events when forking bdi threads
> Bruce, FYI, with this patch I still cannot reproduce the issue, but
> usually it happens faster. Again, too bad I cannot leave the test
> running for days, because we are relocating and I have to pack all my
> stuff. But when I come back from the conference, if the issue is still
> there, I'll continue.
>
> Please, try the patch I sent.
>


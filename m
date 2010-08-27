Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from smtp.nokia.com ([192.100.105.134]:46194 "EHLO
	mgw-mx09.nokia.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751825Ab0H0J5m (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 27 Aug 2010 05:57:42 -0400
Subject: Re: hang in writeback code on nfsv4 mount
From: Artem Bityutskiy <Artem.Bityutskiy@nokia.com>
Reply-To: Artem.Bityutskiy@nokia.com
To: "J. Bruce Fields" <bfields@fieldses.org>
Cc: Jens Axboe <jaxboe@fusionio.com>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>,
        Trond Myklebust <trond@netapp.com>, Christoph Hellwig <hch@lst.de>
In-Reply-To: <1282889595.2763.14.camel@localhost>
References: <20100825023425.GA24591@fieldses.org>
	 <1282889595.2763.14.camel@localhost>
Content-Type: text/plain; charset="UTF-8"
Date: Fri, 27 Aug 2010 12:36:20 +0300
Message-ID: <1282901780.12016.54.camel@localhost>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Fri, 2010-08-27 at 09:13 +0300, Artem Bityutskiy wrote:
> From aa87b87c8555151bb8e083d0dba3fd68c5b0d811 Mon Sep 17 00:00:00 2001
> From: Artem Bityutskiy <Artem.Bityutskiy@nokia.com>
> Date: Fri, 27 Aug 2010 08:21:18 +0300
> Subject: [PATCH] writeback: do not lose wakeup events when forking bdi threads

Bruce, FYI, with this patch I still cannot reproduce the issue, but
usually it happens faster. Again, too bad I cannot leave the test
running for days, because we are relocating and I have to pack all my
stuff. But when I come back from the conference, if the issue is still
there, I'll continue.

Please, try the patch I sent.

-- 
Best Regards,
Artem Bityutskiy (Артём Битюцкий)


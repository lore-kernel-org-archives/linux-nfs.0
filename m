Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from smtp.nokia.com ([192.100.105.134]:46051 "EHLO
	mgw-mx09.nokia.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751305Ab0H1BUS convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 27 Aug 2010 21:20:18 -0400
From: <Artem.Bityutskiy@nokia.com>
To: <bfields@fieldses.org>
CC: <bjschuma@netapp.com>, <jaxboe@fusionio.com>, <linux-nfs@vger.kernel.org>,
        <trond@netapp.com>, <hch@lst.de>
Date: Sat, 28 Aug 2010 03:17:41 +0200
Subject: RE: [PATCH] Fix lost wake-up shutting down writeback thread
Message-ID: <10B234E0D3A1CA469E00963BF106CA392D0DB78356@NOK-EUMSG-02.mgdnok.nokia.com>
References: <20100825023425.GA24591@fieldses.org>
 <1282889595.2763.14.camel@localhost> <1282901780.12016.54.camel@localhost>
 <4C77B873.8010306@netapp.com> <20100827160912.GA18790@fieldses.org>
 <10B234E0D3A1CA469E00963BF106CA392D0DB78354@NOK-EUMSG-02.mgdnok.nokia.com>
 <20100827210626.GB27694@fieldses.org>,<20100827212842.GC27694@fieldses.org>
In-Reply-To: <20100827212842.GC27694@fieldses.org>
Content-Type: text/plain; charset="us-ascii"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

> From: J. Bruce Fields <bfields@redhat.com>
> 
> Setting the task state here may cause us to miss the wake up from
> kthread_stop(), so we need to recheck kthread_should_stop() or risk
> sleeping forever in the following schedule().

Oh yeah, if my sleepy brain does not lie me, that's it! Thanks a lot and sorry
for troubles. I believe the other patch I sent is also a valid bug fix, but fixes a
different issue.

Acked-by: Artem Bityutskiy <Artem.Bityutskiy@nokia.com>

Artem.

Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:51305 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754937AbbFOLjm (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 15 Jun 2015 07:39:42 -0400
Message-ID: <557EB97D.7010804@RedHat.com>
Date: Mon, 15 Jun 2015 07:39:41 -0400
From: Steve Dickson <SteveD@redhat.com>
MIME-Version: 1.0
To: ditang chen <ditang.c@gmail.com>
CC: linux-nfs@vger.kernel.org
Subject: Re: [BUG]rpcbind crashed when scanning rpcbind port with QualysGuard
References: <CAHnGgyE2yhRBALmoknYq8jFQr6Hx-o4m5NimchqAuBa4r28bNQ@mail.gmail.com>
In-Reply-To: <CAHnGgyE2yhRBALmoknYq8jFQr6Hx-o4m5NimchqAuBa4r28bNQ@mail.gmail.com>
Content-Type: text/plain; charset=utf-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>



On 06/14/2015 09:29 AM, ditang chen wrote:
> In the RHEL6.3GA(libtirpc-0.2.1-5) environment，when scanning rpcbind
> port with QualysGuard
> and rpcbind crashed due to the xprt->xp_ops is NULL.
Yes, this is a know problem
   https://bugzilla.redhat.com/show_bug.cgi?id=1170877
but I don't have the bits to reproduce this

steved.

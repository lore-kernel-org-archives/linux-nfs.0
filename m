From: Benny Halevy <bhalevy@panasas.com>
Subject: Re: [pnfs] mds service state machine
Date: Wed, 07 Jul 2010 08:48:22 +0300
Message-ID: <4C341526.6040005@panasas.com>
References: <AANLkTim7H0ZDIZsOdsizku2cm1ZBdjtK96l5vA4aqLOI@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: linux-pnfs <linux-nfs@vger.kernel.org>
To: quanli gui <gqlxj1987@gmail.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from daytona.panasas.com ([67.152.220.89]:13193 "EHLO
	daytona.int.panasas.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1750937Ab0GGFsZ (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 7 Jul 2010 01:48:25 -0400
In-Reply-To: <AANLkTim7H0ZDIZsOdsizku2cm1ZBdjtK96l5vA4aqLOI-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Jul. 05, 2010, 9:46 +0300, quanli gui <gqlxj1987@gmail.com> wrote:
> I use dprintk to see what mds do when the client write something to ds.
> But dprintk is not full, i don't know the lgoic sequence. I also want to
> know mds use which funtions to service client.

When the client writes to the DS there should not be any client to MDS
communication. Later, you should see a LAYOUTCOMMIT and LAYOUTRETURN
arriving at the server.

Benny

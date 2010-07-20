From: Benny Halevy <bhalevy@panasas.com>
Subject: Re: [pnfs]pnfs4_write_done problem
Date: Tue, 20 Jul 2010 10:51:22 +0300
Message-ID: <4C45557A.5020904@panasas.com>
References: <AANLkTinb6e40HcstWWP0mBQ33Q8sSM_s-s8mJM6Zoggj@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: linux-pnfs <linux-nfs@vger.kernel.org>
To: quanli gui <gqlxj1987@gmail.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from daytona.panasas.com ([67.152.220.89]:50324 "EHLO
	daytona.int.panasas.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1752884Ab0GTHvY (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 20 Jul 2010 03:51:24 -0400
In-Reply-To: <AANLkTinb6e40HcstWWP0mBQ33Q8sSM_s-s8mJM6Zoggj-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Gui, There could be many reasons for what you see
but you must provide more debug information otherwise
we'll just keep guessing.

Thanks for reporting and helping to track this!

Benny

On Jul. 20, 2010, 10:05 +0300, quanli gui <gqlxj1987@gmail.com> wrote:
> When pnfs firstly write, the pnfs would stay at the function
> pnfs4_write_done(), and show that 
> pnfs4_write_done DS write
> <-- pnfs4_write_done status=-11
> This two message would shows many times. At the same time, the data not
> write completely to the DS. This write we would wait long time to
> complete. But after the first write, for other writes we don't have to
> wait, as the same as the fact. Why for the first write, we must wait too
> long time? And staying at the function pnfs4_write_done() means what?
> Please give me some answers. 

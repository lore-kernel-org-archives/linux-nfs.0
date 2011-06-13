Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from daytona.panasas.com ([67.152.220.89]:28941 "EHLO
	daytona.panasas.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754958Ab1FMWSi (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 13 Jun 2011 18:18:38 -0400
Message-ID: <4DF68CB4.3030802@panasas.com>
Date: Mon, 13 Jun 2011 18:18:28 -0400
From: Benny Halevy <bhalevy@panasas.com>
To: quanli gui <gqlxj1987@gmail.com>
CC: linux-pnfs <linux-nfs@vger.kernel.org>
Subject: Re: [pnfs]-10008
References: <BANLkTimEiaA2_9QN9TXiO8PCEmVOTHoesw@mail.gmail.com>
In-Reply-To: <BANLkTimEiaA2_9QN9TXiO8PCEmVOTHoesw@mail.gmail.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

First, please send email to linux-nfs@vger.kernel.org as plain text only.
no html whatsoever (not even as multipart) as it gets bounced off the list.

The 10008 error is NFS4ERR_DELAY and it can be returned from many places,
some of them due to memory allocation failures.

That said, we don't have the resources yet to support old versions of the code
and in order to get to the bottom of that please upgrade to the latest tree,
currently based off of v3.0-rc2, and try to reproduce the problem.

Regards,

Benny

On 2011-06-10 04:16, quanli gui wrote:
> In the kernel of 2.6.36, when I write file every time, there would be a problem in the write process, that is the -10008 error. From the rfc5661, -10008 means that the DS is not ready to server the request. But every time I write a file, the error would appear. Why this error appear every time? Thanks for giving me some help.

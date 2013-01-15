Return-Path: linux-nfs-owner@vger.kernel.org
Received: from ironport2-out.teksavvy.com ([206.248.154.182]:25566 "EHLO
	ironport2-out.teksavvy.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751288Ab3AOEQD (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 14 Jan 2013 23:16:03 -0500
Message-ID: <50F4D800.5040703@teksavvy.com>
Date: Mon, 14 Jan 2013 23:16:00 -0500
From: Mark Lord <kernel@teksavvy.com>
MIME-Version: 1.0
To: "J. Bruce Fields" <bfields@fieldses.org>
CC: linux-nfs@vger.kernel.org, Linux Kernel <linux-kernel@vger.kernel.org>
Subject: Re: BUG at net/sunrpc/svc_xprt.c:921
References: <50F42F85.50907@teksavvy.com> <20130114203711.GA29982@fieldses.org>
In-Reply-To: <20130114203711.GA29982@fieldses.org>
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 13-01-14 03:37 PM, J. Bruce Fields wrote:
> Thanks for the report.
> 
> On Mon, Jan 14, 2013 at 11:17:09AM -0500, Mark Lord wrote:
>> Since upgrading to 3.7, and now 3.7.2, my AMD-450E based server
> 
> It's acting as an NFS client, right?

Client and server, with other Linux boxes all running 3.something kernels.

> What did you upgrade from?

3.4.something, I believe.

>> is getting these BUG complaints.  The .config file is gzip'd/attached.
> 
> Is this easy to reproduce?

So far, it seems to pop up within a day or so of any reboot.
I normally only reboot that system for a kernel upgrade,
but can do so a bit more often if there's useful info to collect.

Cheers

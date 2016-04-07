Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from smtp6-g21.free.fr ([212.27.42.6]:13484 "EHLO smtp6-g21.free.fr"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756432AbcDGWsm (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 7 Apr 2016 18:48:42 -0400
Date: Fri, 8 Apr 2016 00:48:39 +0200
From: YuGiOhJCJ Mailing-List <yugiohjcj-mailinglist@laposte.net>
To: bfields@fieldses.org (J. Bruce Fields)
Cc: linux-nfs@vger.kernel.org
Subject: Re: Sometimes all the applications using sqlite do not work
 correctly
Message-Id: <20160408004839.247958f8c43329122b48d75f@laposte.net>
In-Reply-To: <20160407181422.GB30676@fieldses.org>
References: <20160407010927.bf07f12fa3f62b1586dd11ad@laposte.net>
	<20160407181422.GB30676@fieldses.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

> So when the problem happens, restarting the server fixes the problem?

Indeed, that's it.

> It's probably the kernel version that's most important.  So it might be
> interesting to know what your kernel version was before and what it is
> now.

My Linux kernel was 3.18.20 before and is still 3.18.20 now.
I have not changed of kernel since the problem happens.

> Also: what's your NFS server?  Was it upgraded at the same time, or was
> only your client upgraded?

I have not upgraded the server and not upgraded the client.
They are still the same: nfs-utils-1.2.8.

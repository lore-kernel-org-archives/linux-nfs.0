Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.jrc.it ([139.191.1.110]:56420 "EHLO mx2.jrc.it"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752917Ab1F3HFd (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 30 Jun 2011 03:05:33 -0400
Received: from irelay.jrc.it (irelay.jrc.it [139.191.254.63])
	by mx2.jrc.it (LMC5614Amx2) with ESMTP id p5U75Vii029931
	for <linux-nfs@vger.kernel.org>; Thu, 30 Jun 2011 09:05:31 +0200 (CEST)
Received: from mail-zone.jrc.it (mail-zone.jrc.it [139.191.244.42])
        by irelay.jrc.it (LMC5614Ainternal) with SMTP id p5U75Vs8021128
        for <linux-nfs@vger.kernel.org>; Thu, 30 Jun 2011 09:05:31 +0200 (MEST)
Content-type: text/plain; CHARSET=US-ASCII; format=flowed
Received: from email-02-ext.jrc.it ([unknown] [139.191.244.20])
 by mail-zone.jrc.it
 (Sun Java(tm) System Messaging Server 7.3-11.01 64bit (built Sep  1 2009))
 with ESMTP id <0LNL0043PD12ED20@mail-zone.jrc.it> for
 linux-nfs@vger.kernel.org; Thu, 30 Jun 2011 09:05:26 +0200 (CEST)
Received: from [139.191.142.132] ([unknown] [139.191.229.250])
 by email-02-ext.jrc.it
 (Sun Java(tm) System Messaging Server 7.3-11.01 64bit (built Sep  1 2009))
 with ESMTPA id <0LNL00A81D11WM60@email-02-ext.jrc.it> for
 linux-nfs@vger.kernel.org; Thu, 30 Jun 2011 09:05:25 +0200 (CEST)
Message-id: <4E0C2027.9000807@jrc.ec.europa.eu>
Date: Thu, 30 Jun 2011 09:05:11 +0200
From: Franck Eyraud <franck.eyraud@jrc.ec.europa.eu>
To: Trond Myklebust <Trond.Myklebust@netapp.com>
Cc: linux-nfs@vger.kernel.org
Subject: Re: NFSv4 null request and compatibility with netapp
References: <4E0B3897.40209@jrc.ec.europa.eu>
 <1309366237.12547.13.camel@lade.trondhjem.org>
In-reply-to: <1309366237.12547.13.camel@lade.trondhjem.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

Hi Trond,

On 29/06/2011 18:50, Trond Myklebust wrote:
> On Wed, 2011-06-29 at 16:37 +0200, Franck Eyraud wrote:
>
> Without a trace, it is hard to affirm anything, but please note the
> following:
I can provide one, but it is wuite huge (in fact, we are working with 
big data, and this usually occurs while there is a heavy traffic, but I 
can't say if this is because of some collisions due to too many 
requests, or if just statically it happens when there is traffic)
> IOW: this all looks to me like a storm in a teacup brought about by a
> server implementation that is logging errors in a case where it
> shouldn't.
Yes, I agree, this is what I think from the beginning, but our 
colleagues managing the server are overwhelmed with these messages and 
can't easily detect real problems; the support from netapp didn't 
provide a way to avoid the logging of these messages. And since it has 
been told that the problem is on client side, I was trying to find a 
solution to that.

Franck

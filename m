Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:35668 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1758694Ab0J1Nki (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 28 Oct 2010 09:40:38 -0400
Message-ID: <4CC97D4C.1030007@RedHat.com>
Date: Thu, 28 Oct 2010 09:40:28 -0400
From: Steve Dickson <SteveD@redhat.com>
To: Jim Rees <rees@umich.edu>
CC: Christoph Hellwig <hch@infradead.org>, linux-nfs@vger.kernel.org
Subject: Re: [PATCH] nfs-utils: Check for strlcat/cpy and compile our private
 version only if it's needed.
References: <20101020213554.GA27541@merit.edu> <20101021021437.GA5241@infradead.org> <20101021120110.GA29219@merit.edu>
In-Reply-To: <20101021120110.GA29219@merit.edu>
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On 10/21/2010 08:01 AM, Jim Rees wrote:
> Christoph Hellwig wrote:
> 
>   Not that I'd complain, but what Linux libc provides strlcat/cpy?
> 
> None that I know of.  The patch seems like a good idea to me, but it does
> add a couple of ugly ifdefs to the include file.
> 
> There are already quite a few much sillier checks in configure.ac, like
> memset, socket, and mkdir.
> 
> But I won't object if you want to drop this patch.
I think if/when there is a need for these checks we
can add them in then... Why add to the ugliness
if we don't need to?  

steved.

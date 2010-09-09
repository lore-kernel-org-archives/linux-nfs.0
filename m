From: Steve Dickson <SteveD@redhat.com>
Subject: Re: [PATCH] libexport.a: Refactor init_netmask()
Date: Thu, 09 Sep 2010 10:38:35 -0400
Message-ID: <4C88F16B.10802@RedHat.com>
References: <20100902192350.1755.66184.stgit@matisse.1015granger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: linux-nfs@vger.kernel.org
To: Chuck Lever <chuck.lever@oracle.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:48767 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754086Ab0IIOih (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 9 Sep 2010 10:38:37 -0400
In-Reply-To: <20100902192350.1755.66184.stgit-RytpoXr2tKZ9HhUboXbp9zCvJB+x5qRC@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>



On 09/02/2010 03:23 PM, Chuck Lever wrote:
> Instead of a single function that can handle both AF_INET and AF_INET6
> addresses, two separate functions might be cleaner.
> 
> The original plan was to keep code redundancy at a minimum, but the
> resulting code was cumbersome at best.  I think I've traded a little
> extra code for something that will be much easier to read, understand,
> and maintain.
> 
> I've also eliminated the "#if / #endif" instances inside the functions.
> 
> Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
> ---
Committed...

steved.


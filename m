Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:61522 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751912Ab0HaTng (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 31 Aug 2010 15:43:36 -0400
Message-ID: <4C7D5B63.9060907@RedHat.com>
Date: Tue, 31 Aug 2010 15:43:31 -0400
From: Steve Dickson <SteveD@redhat.com>
To: Chuck Lever <chuck.lever@oracle.com>
CC: linux-nfs@vger.kernel.org
Subject: Re: [PATCH 0/5] Support IPv6 in libexport.a
References: <20100824162926.2433.7535.stgit@matisse.1015granger.net>
In-Reply-To: <20100824162926.2433.7535.stgit@matisse.1015granger.net>
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0



On 08/24/2010 12:35 PM, Chuck Lever wrote:
> Hi Steve-
> 
> This patch set should encapsulate IPv6-related changes needed in
> support/export/client.c .  It updates logic that parses presentation
> addresses and netmasks, and logic that compares socket addresses.
> 
> ---
> 
> Chuck Lever (5):
>       libexport.a: IPv6 support in client_check()
>       libexport.a: IPv6 support for client_init_subnet()
>       libexport.a: Prepare init_subnetwork() for IPv6 support
>       libexport.a: Use host helper to parse address in client_init()
>       libexport.a: Prepare to recognize IPv6 addresses in client_gettype()
> 
> 
>  support/export/client.c |  208 +++++++++++++++++++++++++++++++++++------------
>  1 files changed, 153 insertions(+), 55 deletions(-)
> 
All 5 Committed... As far as "bending the cardinal rule of not
using "#ifdef" inside functions"... I too did not see a cleaner
way of doing it... so I don't think its a big deal.. but maybe
down the road we can rework things were those ifdef are not
needed... but only time will tell...

steved.

Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:27742 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751179Ab0HQWZn (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 17 Aug 2010 18:25:43 -0400
Message-ID: <4C6B0C62.4020509@RedHat.com>
Date: Tue, 17 Aug 2010 18:25:38 -0400
From: Steve Dickson <SteveD@redhat.com>
To: Trond Myklebust <trond.myklebust@fys.uio.no>
CC: Linux NFS Mailing list <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH 1/2] Teach clients to map numeric strings into valid uids
 and gids.
References: <1282073925-18707-1-git-send-email-steved@redhat.com>	 <1282073925-18707-2-git-send-email-steved@redhat.com>	 <1282076855.12506.2.camel@heimdal.trondhjem.org>	 <4C6B00B1.4060206@RedHat.com>	 <1282081633.18385.6.camel@heimdal.trondhjem.org>	 <4C6B081B.2070700@RedHat.com> <1282083199.18385.21.camel@heimdal.trondhjem.org>
In-Reply-To: <1282083199.18385.21.camel@heimdal.trondhjem.org>
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0



On 08/17/2010 06:13 PM, Trond Myklebust wrote:
> 
>> But at this point in time we have people doing the v4 transitioning now and
>> I can get the fix out much quicker, making their transition less painful,
>> if I put these few lines of code in nfs-utils verses the library... 
> 
> I don't see why getting it into nfs-utils is faster. Is CITI being slow
> taking patches for libnfsidmap?
No... That is not the case WRT CITI...  But please remember... 
as soon as you create a new interface you also create a new dependency... 
which means we would have to push out two packages (simultaneously, which 
can be painful) verses just pushing out one package... that's were the
quickness comes from... 

steved.
 

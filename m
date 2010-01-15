From: Steve Dickson <SteveD@redhat.com>
Subject: Re: [PATCH 0/6] IPv6 support for nfs-utils tcpwrapper shim
Date: Fri, 15 Jan 2010 13:37:36 -0500
Message-ID: <4B50B5F0.6020202@RedHat.com>
References: <20100115174426.30104.3492.stgit@localhost.localdomain> <4B50AE34.3020009@RedHat.com> <1FFE8210-7E78-4A65-A56F-A5030BB26600@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: chris.mason@oracle.com, linux-nfs@vger.kernel.org
To: Chuck Lever <chuck.lever@oracle.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:42323 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757655Ab0AOShk (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 15 Jan 2010 13:37:40 -0500
In-Reply-To: <1FFE8210-7E78-4A65-A56F-A5030BB26600@oracle.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>



On 01/15/2010 01:27 PM, Chuck Lever wrote:
> On Jan 15, 2010, at 1:04 PM, Steve Dickson wrote:
>> On 01/15/2010 12:49 PM, Chuck Lever wrote:
>>> These patches provide IPv6 support for the tcpwrapper shim inside
>>> nfs-utils.  It assumes that the generic tcpwrapper library can
>>> support IPv6 addresses.  It has not been extensively tested, but
>>> I think the framework is reasonable, and only minor bug fixes might
>>> be needed as we go along.
>> Did you do any simple "hello world" testing?
> 
> I've build-tested them.  Jeff and I had them applied while doing the
> statd testing.  They don't appear to cause problems when no allow/deny
> sets exist.
> 
> I thought we would have more time to test and review these, so I haven't
> done more extensive testing so far.  In any case, I don't think they
> will be harmful, and can serve as a place marker for that feature as the
> beta moves forward.
Unfortunately I have broken these before and it was awful painful... :-(
Right or wrong... there is still a large number of people that depend
on this archaic routines... we need to be very careful... 

steved.

Return-Path: linux-nfs-owner@vger.kernel.org
Received: from userp1040.oracle.com ([156.151.31.81]:31539 "EHLO
	userp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752066Ab3EEWt0 convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sun, 5 May 2013 18:49:26 -0400
Content-Type: text/plain; charset=us-ascii
Mime-Version: 1.0 (Mac OS X Mail 6.3 \(1503\))
Subject: Re: long delay when mounting due to SETCLIENTID AUTH_GSS attempts
From: Chuck Lever <chuck.lever@oracle.com>
In-Reply-To: <20130503153941.345d3b9a@tlielax.poochiereds.net>
Date: Sun, 5 May 2013 18:49:24 -0400
Cc: "Myklebust, Trond" <Trond.Myklebust@netapp.com>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Message-Id: <8BBFFB78-5E28-4206-AB13-DD84E30EBF1B@oracle.com>
References: <20130503132557.2fdf794d@tlielax.poochiereds.net> <AE700845-4032-4BEC-817C-97EB08A831E8@oracle.com> <20130503142421.19fb3ca6@tlielax.poochiereds.net> <1367606034.3556.25.camel@leira.trondhjem.org> <20130503144437.3a47e476@tlielax.poochiereds.net> <A2E5B3F1-A8F1-4731-A66C-548B9C8FD429@oracle.com> <20130503151727.09d684f4@tlielax.poochiereds.net> <EB1CC0C3-1E31-4A3F-90E7-A79098161D1B@oracle.com> <20130503153941.345d3b9a@tlielax.poochiereds.net>
To: Jeff Layton <jlayton@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


On May 3, 2013, at 3:39 PM, Jeff Layton <jlayton@redhat.com> wrote:

> On Fri, 3 May 2013 15:26:09 -0400
> Chuck Lever <chuck.lever@oracle.com> wrote:
> 
>> I don't expect this issue to last for release after release.  A moment ago you agreed that this shouldn't be intractable, so I fail to see the need to start wiring up long-term workarounds.
>> 
>> Can't we just agree on a fix, and then get that into 3.10 as a regression fix?
>> 
> 
> I'm happy to help...I'm just not sure what you're proposing as the fix
> for the problem. What are you suggesting we do?

The kernel has historically had difficulty determining the status of GSS support in user space.

One way to remedy this would be to have "systemctl disable nfs-server.service" blacklist the kernel's GSS module, and "systemctl enable nfs-server.service" remove the blacklisting.  This mechanism would have to be sensitive to both gssd and svcgssd, of course.

--
Chuck Lever
chuck[dot]lever[at]oracle[dot]com




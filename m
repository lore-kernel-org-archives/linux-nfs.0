Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:29704 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752241AbeBBPG1 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Fri, 2 Feb 2018 10:06:27 -0500
Subject: Re: Question about random UDP port on rpcbind 0.2.3
To: Scott Mayhew <smayhew@redhat.com>,
        Chuck Lever <chuck.lever@oracle.com>
Cc: Naruto Nguyen <narutonguyen2018@gmail.com>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>
References: <CANpxKHE=eKuFc2HBgT0aqDb+Q5EOFWOfCzf=tmmuH7zNyn878g@mail.gmail.com>
 <CANpxKHH3zf_RRnxckHKfvEWL-RNCr_ZePxc0r98Ep0X_JX1BbA@mail.gmail.com>
 <47c040cf-d0a8-eb42-a276-9bc2e264ff6e@RedHat.com>
 <66B30606-7AFE-43C8-8A51-5D031F9D744B@oracle.com>
 <27ec9304-5763-9885-b3c9-246c395e6986@RedHat.com>
 <1165B44B-0D40-42FF-94EE-9B852AD4C8FA@oracle.com>
 <20180201152918.am75vfq776vtj3i3@tonberry.usersys.redhat.com>
From: Steve Dickson <SteveD@RedHat.com>
Message-ID: <11614659-a3c9-b3c9-73e7-886e1f3d50a4@RedHat.com>
Date: Fri, 2 Feb 2018 10:06:18 -0500
MIME-Version: 1.0
In-Reply-To: <20180201152918.am75vfq776vtj3i3@tonberry.usersys.redhat.com>
Content-Type: text/plain; charset=windows-1252
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>



On 02/01/2018 10:29 AM, Scott Mayhew wrote:
> 
> This patch should take care of making rpcbind set up the remote call
> port on demand.  I don't have a whole lot of ways to test it though...
> just 'rpcinfo -b' and a handful of one-off programs I wrote a while back
> trying to mess with the CALLIT/INDIRECT/BCAST procedures.
This is where I spent my afternoon yesterday... figuring
out a way to test this code. rpc_call() is my new BFF!

> 
> I'd still need to add the stuff to retain CAP_NET_BIND_SERVICE.
I think we need to do what nsm_clear_capabilities() does.

> 
> I also like the idea of leaving this off by default and adding a
> command-line flag to enable it because I'm also not sure if anyone
> actually uses it... not to mention there's been at least one CVE in the
> past that exploited it (CVE-2015-7236, not sure if there are others).
I'm not a fan of this idea... I think on demand is a better way
to go... but what do I know?? ;-)

steved.

> 

Return-Path: linux-nfs-owner@vger.kernel.org
Received: from userp1040.oracle.com ([156.151.31.81]:28905 "EHLO
	userp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932632AbaLDRoq (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 4 Dec 2014 12:44:46 -0500
Message-ID: <54809D7F.4020901@oracle.com>
Date: Thu, 04 Dec 2014 09:44:31 -0800
From: Shirley Ma <shirley.ma@oracle.com>
MIME-Version: 1.0
To: Jeff Layton <jeff.layton@primarydata.com>
CC: Trond Myklebust <trond.myklebust@primarydata.com>,
        Tejun Heo <tj@kernel.org>, NeilBrown <neilb@suse.de>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>,
        Linux Kernel mailing list <linux-kernel@vger.kernel.org>,
        Al Viro <viro@zeniv.linux.org.uk>
Subject: Re: [RFC PATCH 00/14] nfsd/sunrpc: add support for a workqueue-based
 nfsd
References: <1417544663-13299-1-git-send-email-jlayton@primarydata.com>	<20141203121118.21a32fe1@notabene.brown>	<20141202202946.1e0f399b@tlielax.poochiereds.net>	<20141203155649.GB5013@htj.dyndns.org>	<20141203110405.5ecc85df@tlielax.poochiereds.net>	<20141203140202.7865bedb@tlielax.poochiereds.net>	<CAHQdGtQzth78BzBo9Gsz8LKe4ippJv6VYtjGCDmES7viByG_gA@mail.gmail.com>	<20141203142034.5c14529d@tlielax.poochiereds.net>	<CAHQdGtSoep_F82tDUoxKar+QvmL1tdHsYgYSrYtktndYJP8g5A@mail.gmail.com>	<20141203152147.2ca6c6fd@tlielax.poochiereds.net>	<CAHQdGtSbkvkGnDykEn0RnDJ5infX39N8cQObhDod+Vy4KX3Gnw@mail.gmail.com>	<20141204064711.72d48317@tlielax.poochiereds.net>	<5480971D.9010102@oracle.com> <20141204122845.3f9e3a04@tlielax.poochiereds.net>
In-Reply-To: <20141204122845.3f9e3a04@tlielax.poochiereds.net>
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 12/04/2014 09:28 AM, Jeff Layton wrote:
> On Thu, 04 Dec 2014 09:17:17 -0800
> Shirley Ma <shirley.ma@oracle.com> wrote:
> 
>> > I am looking at how to reduce total RPC execution time in NFS/RDMA. mountstats output shows that RPC backlog wait is too long, but increasing the credit limit doesn't seem help. Would this patchset help reducing total RPC execution time? 
>> > 
>> > Shirley
>> > 
> I'm not sure. It depends on why you're seeing a backlog.

What's the major factors contributing RPC backlog wait time? I guess I need to probe the backlog wait path to display fine-grained latency cost.
 
> So far, my testing still shows this to be slightly (~2%) slower than the
> same setup running a threaded nfsd, but that could be different with a
> NUMA server or faster disks.
> 
> Probably there is some more tuning to do here before this is quite
> ready for prime-time. It may be worth testing in your environment
> though if you have the time and ability to do so.
> 
>> > On 12/04/2014 03:47 AM, Jeff Layton wrote:
>>> > > I was using ftrace with the sunrpc:* and workqueue:* tracepoints, and
>>> > > had a simple perl script to postprocess the trace info to figure out
>>> > > average/min/max latency.

Return-Path: linux-nfs-owner@vger.kernel.org
Received: from aserp1040.oracle.com ([141.146.126.69]:51249 "EHLO
	aserp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753728Ab3KLRNy convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 12 Nov 2013 12:13:54 -0500
Content-Type: text/plain; charset=us-ascii
Mime-Version: 1.0 (Mac OS X Mail 6.6 \(1510\))
Subject: Re: [PATCH 0/2] sunrpc: more reliable detection of running gssd
From: Chuck Lever <chuck.lever@oracle.com>
In-Reply-To: <1384275379.4779.8.camel@leira.trondhjem.org>
Date: Tue, 12 Nov 2013 12:13:48 -0500
Cc: Jeff Layton <jlayton@redhat.com>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>,
        "steved@redhat.com" <steved@redhat.com>
Message-Id: <DE63408F-9474-4786-9C48-4E3B80CEE78B@oracle.com>
References: <1384261225-28559-1-git-send-email-jlayton@redhat.com> <A0488E98-0DF9-4ECE-A39D-C8E460E4C546@oracle.com> <20131112110831.72234c64@tlielax.poochiereds.net> <B9D2C1A3-ABD1-4A87-9AFD-BC9C2F1BA55C@oracle.com> <1384275379.4779.8.camel@leira.trondhjem.org>
To: "Myklebust, Trond" <Trond.Myklebust@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


On Nov 12, 2013, at 11:56 AM, "Myklebust, Trond" <Trond.Myklebust@netapp.com> wrote:

> On Tue, 2013-11-12 at 11:15 -0500, Chuck Lever wrote:
>> On Nov 12, 2013, at 11:08 AM, Jeff Layton <jlayton@redhat.com> wrote:
>> 
>>> On Tue, 12 Nov 2013 11:02:42 -0500
>>> Chuck Lever <chuck.lever@oracle.com> wrote:
>>> 
>>>> 
>>>> On Nov 12, 2013, at 8:00 AM, Jeff Layton <jlayton@redhat.com> wrote:
>>>> 
>>> What's the module loading solution?
>> 
>> Load auth_rpcgss.ko only when rpc.gssd has been started.  See the "[PATCH] Adding the nfs4_secure_mounts bool" thread... If auth_rpcgss.ko is not loaded, the kernel won't ever try to do an upcall.
>> 
>> Then, systemd can be used to restart rpc.gssd if it crashes, maybe?  Just a thought.
> 
> You can trivially defeat that by compiling the gss code into the kernel.

And also: my preferred solution is to run rpc.gssd unconditionally.  But some find that onerous.

-- 
Chuck Lever
chuck[dot]lever[at]oracle[dot]com





Return-Path: linux-nfs-owner@vger.kernel.org
Received: from acsinet15.oracle.com ([141.146.126.227]:45876 "EHLO
	acsinet15.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751837Ab2IQPKo convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 17 Sep 2012 11:10:44 -0400
Subject: Re: [PATCH 0/3] lockd: use per-net refrence-counted NSM clients
Mime-Version: 1.0 (Apple Message framework v1278)
Content-Type: text/plain; charset=utf-8
From: Chuck Lever <chuck.lever@oracle.com>
In-Reply-To: <50570052.8050205@parallels.com>
Date: Mon, 17 Sep 2012 11:10:30 -0400
Cc: "Myklebust, Trond" <Trond.Myklebust@netapp.com>,
        "bfields@fieldses.org" <bfields@fieldses.org>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>,
        "devel@openvz.org" <devel@openvz.org>,
        "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
        "jlayton@redhat.com" <jlayton@redhat.com>
Message-Id: <D4B752F3-1883-490E-AA5D-B9666472FFF3@oracle.com>
References: <20120914140811.10835.81465.stgit@localhost.localdomain> <4030B8F9-5C67-4AE7-826E-B4B6AD4FAD01@oracle.com> <4FA345DA4F4AE44899BD2B03EEEC2FA908FA7F55@SACEXCMBX04-PRD.hq.netapp.com> <DA466953-BF79-44F7-8870-AC2FD5E3FEC2@oracle.com> <50570052.8050205@parallels.com>
To: Stanislav Kinsbursky <skinsbursky@parallels.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


On Sep 17, 2012, at 6:49 AM, Stanislav Kinsbursky wrote:

> 14.09.2012 23:10, Chuck Lever пишет:
>> 
>> On Sep 14, 2012, at 1:38 PM, Myklebust, Trond wrote:
>> 
>>> On Fri, 2012-09-14 at 13:01 -0400, Chuck Lever wrote:
>>>> What happens if statd is restarted?
>>> 
>>> Nothing unusual. Why?
>> 
>> The NSM upcall transport is a potential application for TCP + softconn, now that a persistent rpc_clnt is used.  It just depends on what failure mode we'd like to optimize for.
>> 
> 
> I don't understand, where the problem is.
> Could you be more specific, please?

I'm suggesting an enhancement.

The change is to use TCP for the NSM upcall transport, and set RPC_TASK_SOFTCONN on the individual RPCs.  The advantage of this is that the kernel could discover when statd is not running and fail the upcall immediately, rather than waiting possibly many seconds for each upcall RPC to time out.

The client already has a check in the mount.nfs command to see that statd is running, likely to avoid this lengthly timeout.  Since the client already has long-standing logic to avoid it, I think the benefit would be mostly on the server side.

But this change can be done at some later point.

-- 
Chuck Lever
chuck[dot]lever[at]oracle[dot]com





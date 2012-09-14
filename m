Return-Path: linux-nfs-owner@vger.kernel.org
Received: from acsinet15.oracle.com ([141.146.126.227]:31093 "EHLO
	acsinet15.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751529Ab2INTKR convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 14 Sep 2012 15:10:17 -0400
Subject: Re: [PATCH 0/3] lockd: use per-net refrence-counted NSM clients
Mime-Version: 1.0 (Apple Message framework v1278)
Content-Type: text/plain; charset=us-ascii
From: Chuck Lever <chuck.lever@oracle.com>
In-Reply-To: <4FA345DA4F4AE44899BD2B03EEEC2FA908FA7F55@SACEXCMBX04-PRD.hq.netapp.com>
Date: Fri, 14 Sep 2012 15:10:02 -0400
Cc: Stanislav Kinsbursky <skinsbursky@parallels.com>,
        "bfields@fieldses.org" <bfields@fieldses.org>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>,
        "devel@openvz.org" <devel@openvz.org>,
        "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
        "jlayton@redhat.com" <jlayton@redhat.com>
Message-Id: <DA466953-BF79-44F7-8870-AC2FD5E3FEC2@oracle.com>
References: <20120914140811.10835.81465.stgit@localhost.localdomain> <4030B8F9-5C67-4AE7-826E-B4B6AD4FAD01@oracle.com> <4FA345DA4F4AE44899BD2B03EEEC2FA908FA7F55@SACEXCMBX04-PRD.hq.netapp.com>
To: "Myklebust, Trond" <Trond.Myklebust@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


On Sep 14, 2012, at 1:38 PM, Myklebust, Trond wrote:

> On Fri, 2012-09-14 at 13:01 -0400, Chuck Lever wrote:
>> What happens if statd is restarted?
> 
> Nothing unusual. Why?

The NSM upcall transport is a potential application for TCP + softconn, now that a persistent rpc_clnt is used.  It just depends on what failure mode we'd like to optimize for.

> 
>> Sent from my iPhone
>> 
>> On Sep 14, 2012, at 10:25 AM, Stanislav Kinsbursky <skinsbursky@parallels.com> wrote:
>> 
>>> This is a bug fix for https://bugzilla.redhat.com/show_bug.cgi?id=830862.
>>> 
>>> The problem is that with NFSv4 mount in container (with separated mount
>>> namesapce) and active lock on it, dying child reaped of this container will
>>> try to umount NFS and doing this will try to create RPC client to send
>>> unmonitor request to statd.
>>> But creation of RCP client requires valid current->nsproxy (for operation with
>>> utsname()) and during umount on child reaper exit it's equal to zero.
>>> 
>>> Proposed solution is to introduce refrence-counter per-net NSM client, which
>>> is created on fist monitor call and destroyed after the lst monitor call.
>>> 
>>> The following series implements...
>>> 
>>> ---
>>> 
>>> Stanislav Kinsbursky (3):
>>>     lockd: use rpc client's cl_nodename for id encoding
>>>     lockd: per-net NSM client creation and destruction helpers introduced
>>>     lockd: create and use per-net NSM RPC clients on MON/UNMON requests
>>> 
>>> 
>>> fs/lockd/mon.c   |   91 +++++++++++++++++++++++++++++++++++++++++++-----------
>>> fs/lockd/netns.h |    4 ++
>>> fs/lockd/svc.c   |    1 +
>>> 3 files changed, 77 insertions(+), 19 deletions(-)
>>> 
>>> 
>>> --
>>> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
>>> the body of a message to majordomo@vger.kernel.org
>>> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> 
> -- 
> Trond Myklebust
> Linux NFS client maintainer
> 
> NetApp
> Trond.Myklebust@netapp.com
> www.netapp.com

-- 
Chuck Lever
chuck[dot]lever[at]oracle[dot]com





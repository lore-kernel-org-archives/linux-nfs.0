From: Chuck Lever <chuck.lever@oracle.com>
Subject: Re: [PATCH 3/3] mountd: fix crossmnt options in v2/v3 case
Date: Mon, 08 Mar 2010 13:45:01 -0500
Message-ID: <4B9545AD.9020601@oracle.com>
References: <20100307200607.GA13006@fieldses.org> <1267992481-13332-1-git-send-email-bfields@citi.umich.edu> <1267992481-13332-2-git-send-email-bfields@citi.umich.edu> <1267992481-13332-3-git-send-email-bfields@citi.umich.edu> <20100308082516.260e5f70@notabene.brown> <20100307215826.GA14104@fieldses.org> <20100308101014.14e635b2@notabene.brown> <20100308182148.GB1675@fieldses.org> <4B95423F.6070805@oracle.com> <20100308184117.GE1675@fieldses.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Cc: Neil Brown <neilb@suse.de>, Steve Dickson <steved@redhat.com>,
	linux-nfs@vger.kernel.org
To: "J. Bruce Fields" <bfields@citi.umich.edu>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from rcsinet12.oracle.com ([148.87.113.124]:40690 "EHLO
	rcsinet12.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755321Ab0CHSrF (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 8 Mar 2010 13:47:05 -0500
In-Reply-To: <20100308184117.GE1675@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 03/08/2010 01:41 PM, J. Bruce Fields wrote:
> On Mon, Mar 08, 2010 at 01:30:23PM -0500, Chuck Lever wrote:
>> On 03/08/2010 01:21 PM, J. Bruce Fields wrote:
>>> Occasionally we seem to hear from a security-conscious administrator
>>> who's running v4-only and is irritated that they have to firewall off
>>> mountd instead of just being able to kill it entirely.  The latter might
>>> reassure them, I suppose.
>>
>> I think Jeff had the idea of having mountd simply not set up its RPC
>> listeners in that case.  That looks easy to do.
>
> Sure, makes sense.
>
> But we might decide we want separate processes for servicing MOUNT
> requests and export upcalls anyway.
>
> In which case, call one rpc.mountd, the other nfsd-cache-helper, don't
> bother running "rpc.mountd" in the v4-only case, and, yay, we never have
> to answer the "why do I still have to run rpc.mountd?" question again.

Heh.

Separating these facilities would make mountd's RPC service 
implementation more standard.  Right now, it has to select() over the 
RPC listeners _and_ the cache upcall fds.  That means it has it's own 
"svc_run()" function, and thus doesn't use the RPC library's.

But it might get complicated if we want to retain functionality in 
mountd for kernels that don't have the new export cache...

-- 
chuck[dot]lever[at]oracle[dot]com

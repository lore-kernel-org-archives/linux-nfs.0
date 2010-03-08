From: "J. Bruce Fields" <bfields@citi.umich.edu>
Subject: Re: [PATCH 3/3] mountd: fix crossmnt options in v2/v3 case
Date: Mon, 8 Mar 2010 13:41:17 -0500
Message-ID: <20100308184117.GE1675@fieldses.org>
References: <20100307200607.GA13006@fieldses.org> <1267992481-13332-1-git-send-email-bfields@citi.umich.edu> <1267992481-13332-2-git-send-email-bfields@citi.umich.edu> <1267992481-13332-3-git-send-email-bfields@citi.umich.edu> <20100308082516.260e5f70@notabene.brown> <20100307215826.GA14104@fieldses.org> <20100308101014.14e635b2@notabene.brown> <20100308182148.GB1675@fieldses.org> <4B95423F.6070805@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Neil Brown <neilb@suse.de>, Steve Dickson <steved@redhat.com>,
	linux-nfs@vger.kernel.org
To: Chuck Lever <chuck.lever@oracle.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([174.143.236.118]:53979 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755164Ab0CHSj5 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 8 Mar 2010 13:39:57 -0500
In-Reply-To: <4B95423F.6070805@oracle.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, Mar 08, 2010 at 01:30:23PM -0500, Chuck Lever wrote:
> On 03/08/2010 01:21 PM, J. Bruce Fields wrote:
>> Occasionally we seem to hear from a security-conscious administrator
>> who's running v4-only and is irritated that they have to firewall off
>> mountd instead of just being able to kill it entirely.  The latter might
>> reassure them, I suppose.
>
> I think Jeff had the idea of having mountd simply not set up its RPC  
> listeners in that case.  That looks easy to do.

Sure, makes sense.

But we might decide we want separate processes for servicing MOUNT
requests and export upcalls anyway.

In which case, call one rpc.mountd, the other nfsd-cache-helper, don't
bother running "rpc.mountd" in the v4-only case, and, yay, we never have
to answer the "why do I still have to run rpc.mountd?" question again.

I dunno.

--b.

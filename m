From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: [PATCH 2/3] NLM per-ip grace period - core
Date: Tue, 29 Jan 2008 12:21:01 -0500
Message-ID: <20080129172101.GA28032@fieldses.org>
References: <479970EA.2060900@redhat.com> <20080129025656.GH16785@fieldses.org> <514B944F-02FC-4164-BFDA-209361F4BD25@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Wendy Cheng <wcheng@redhat.com>,
	NFS list <linux-nfs@vger.kernel.org>, cluster-devel@redhat.com
To: Chuck Lever <chuck.lever@oracle.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail.fieldses.org ([66.93.2.214]:60235 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754062AbYA2RVE (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 29 Jan 2008 12:21:04 -0500
In-Reply-To: <514B944F-02FC-4164-BFDA-209361F4BD25@oracle.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, Jan 29, 2008 at 11:33:08AM -0500, Chuck Lever wrote:
> On Jan 28, 2008, at 9:56 PM, J. Bruce Fields wrote:
>> Also, is that the right choice of types?  Maybe we should just use
>> struct in6_addr?
>
> I agree with Bruce -- just use in_addr, and leave out the unused IPv6  
> stuff for now.
>
> In some places, we just replace in_addr with in6_addr and simply map  
> IPv4 to IPv6 addresses, rather than setting up a union.
>
> If the address is used as a hash and never displayed, using a mapped  
> IPv4 address is sufficient, and keeps things simple.
>
>> +
>>  int
>>  nlmsvc_failover_setgrace(void *server_ip, int ip_size)
>
> Should this be
>
>   int nlmsvc_failover_setgrace(const struct in_addr *server_ip)
>
> for now, and later we can change it to use in6_addr instead?

I could go either way, If it'd be just as easy to use in6_addr's
internally everywhere from the start, that'd be great, and then it'll be
easy enough to tack the ipv6 parsing onto the interfaces later.

But I'd leave that to Wendy's judgement for now--I think it's reasonable
to keep it ipv4 only for now if that keeps the initial implementation
simpler.

(Just drop the union and use in_addr or in6_addr as opposed to the
home-grown types.)

--b.

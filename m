Return-Path: linux-nfs-owner@vger.kernel.org
Received: from acsinet15.oracle.com ([141.146.126.227]:25060 "EHLO
	acsinet15.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758055Ab2EaUTm convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 31 May 2012 16:19:42 -0400
Subject: Re: [PATCH] mount.nfs: try the next address after mount fails with ETIMEDOUT
Mime-Version: 1.0 (Apple Message framework v1278)
Content-Type: text/plain; charset=us-ascii
From: Chuck Lever <chuck.lever@oracle.com>
In-Reply-To: <20120531114021.74b9a607@corrin.poochiereds.net>
Date: Thu, 31 May 2012 16:19:32 -0400
Cc: linux-nfs@vger.kernel.org
Message-Id: <4859D2DF-EA0F-48E1-88C2-0124BFD4E005@oracle.com>
References: <1338469436-5411-1-git-send-email-jlayton@redhat.com> <C16A9517-8334-4B2D-BFB1-D2C02AD66972@oracle.com> <20120531114021.74b9a607@corrin.poochiereds.net>
To: Jeff Layton <jlayton@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


On May 31, 2012, at 11:40 AM, Jeff Layton wrote:

> On Thu, 31 May 2012 10:28:49 -0400
> Chuck Lever <chuck.lever@oracle.com> wrote:
> 
>> 
>> On May 31, 2012, at 9:03 AM, Jeff Layton wrote:
>> 
>>> If a NFS mount attempt fails with an ETIMEDOUT error, the mount.nfs code
>>> doesn't currently attempt the next address in the list. For a NFSv4 mount
>>> the initial mount() call almost always ends up going over
>>> NFS_DEF_FG_TIMEOUT_MINUTES and the mount is never retried.
>>> 
>>> For a v3 mount, it ends up continually retrying against the same IPv6
>>> address, and never tries the IPv4 address. Eventually it gives up once
>>> it hits the NFS_DEF_FG_TIMEOUT_MINUTES timeout.
>>> 
>>> It's possible that a server is just unreachable via IPv6 (due to a
>>> routing misconfiguration for instance), or is dropping IPv6 frames on
>>> the floor. In that situation, it might still be reachable via IPv4 and
>>> trying the next address could have allowed the mount to succeed.
>>> 
>>> Fix this by treating ETIMEDOUT in a similar fashion to ECONNREFUSED.
>>> Have the client try the next address in the list before giving up and
>>> returning an error.
>> 
>> Bzzzzt.  AF fallback is only legal to do if the admin did not specify a netid.
>> 
>> Can you demonstrate that your patch works correctly if an IPv6 netid is specified?  "Correctly" here means that no fallback occurs.
>> 
> 
> If someone specifies an IPv6 netid (via proto= option) then we would
> set AF_INET6 in the addrinfo "hints" and there will be no IPv4
> addresses in the mi->address list. So, this does still work correctly
> when someone specifies an ipv6 netid.
> 
> Chuck also pointed out on IRC that the description was a little
> unclear, since it was specific to my test rig where the server had a
> single IPv6 and IPv4 address in DNS.
> 
> The loop that retries against different addresses doesn't care
> about whether the addrs are v4 or v6.

Correct.

Moreover, we do get the right behavior because the initial DNS lookup populates the list of addresses to try, based on a specified netid (proto=).  Thus, if no netid is specified, the list contains INET and INET6; if a netid is specified, the list contains only one address family.  That properly limits the addresses that can be used when mount.nfs retries.

> What this really tells mount.nfs
> to do is to keep trying different addresses in the list if there are
> any instead of giving up on an ETIMEDOUT error.
> 
> -- 
> Jeff Layton <jlayton@redhat.com>
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

-- 
Chuck Lever
chuck[dot]lever[at]oracle[dot]com





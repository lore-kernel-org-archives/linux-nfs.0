Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:20716 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751420Ab0ICM7A (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 3 Sep 2010 08:59:00 -0400
Date: Fri, 3 Sep 2010 09:02:36 -0400
From: Jeff Layton <jlayton@redhat.com>
To: Ben Greear <greearb@candelatech.com>
Cc: "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>,
        chuck.lever@oracle.com
Subject: Re: bug in match_ipaddr6 ?
Message-ID: <20100903090236.57a4699e@corrin.poochiereds.net>
In-Reply-To: <4C8026F7.10202@candelatech.com>
References: <4C8026F7.10202@candelatech.com>
Content-Type: text/plain; charset=US-ASCII
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Thu, 02 Sep 2010 15:36:39 -0700
Ben Greear <greearb@candelatech.com> wrote:

> static int nfs_sockaddr_match_ipaddr6(const struct sockaddr *sa1,
> 				      const struct sockaddr *sa2)
> {
> 	const struct sockaddr_in6 *sin1 = (const struct sockaddr_in6 *)sa1;
> 	const struct sockaddr_in6 *sin2 = (const struct sockaddr_in6 *)sa2;
> 
> 	if (ipv6_addr_scope(&sin1->sin6_addr) == IPV6_ADDR_SCOPE_LINKLOCAL &&
> 	    sin1->sin6_scope_id != sin2->sin6_scope_id)
> 		return 0;
> 
> 	return ipv6_addr_equal(&sin1->sin6_addr, &sin1->sin6_addr);
> 
> Looks like this last line, second argument should be &sin2->sin6_addr ???
> 
> Thanks,
> Ben
> 

Ouch. Yes, that does look wrong. Care to send a patch to fix it?

-- 
Jeff Layton <jlayton@redhat.com>

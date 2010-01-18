From: Chuck Lever <chuck.lever@oracle.com>
Subject: Re: enabling IPv6
Date: Mon, 18 Jan 2010 16:28:39 -0500
Message-ID: <0FE403CA-9487-485C-9949-FEC072EC2314@oracle.com>
References: <20100118144746.1e05865e@tlielax.poochiereds.net>
Mime-Version: 1.0 (Apple Message framework v936)
Content-Type: text/plain; charset=US-ASCII; format=flowed
Cc: steved@redhat.com, linux-nfs@vger.kernel.org
To: Jeff Layton <jlayton@redhat.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from rcsinet12.oracle.com ([148.87.113.124]:28249 "EHLO
	rcsinet12.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754434Ab0ARV24 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 18 Jan 2010 16:28:56 -0500
In-Reply-To: <20100118144746.1e05865e-9yPaYZwiELC+kQycOl6kW4xkIHaj4LzF@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


On Jan 18, 2010, at 2:47 PM, Jeff Layton wrote:

> With the commit of the statd patches over the weekend, we're now
> positioned to be able to ship IPv6-enabled nfs-utils in distros. There
> is a potential snag though...
>
> Consider this situation:
>
> Admin has a Linux server set up. Server has both IPv4 and IPv6 addrs.
> Both addresses are in DNS.
>
> Without an IPv6-enabled nfs-utils, he mounts via IPv4 and all works
> fine. Now with an IPv6 enabled nfs-utils, mount.nfs prefers the IPv6
> addr and the mount fails (or hangs for a long time and then fails, if
> it's using NFSv4)...

Why should it fail?

> While I don't really like it, I think we may need to consider making
> mount.nfs prefer IPv4 addrs when it can resolve a hostname to both v4
> and v6. Otherwise, we run the risk of breaking an awful lot of working
> setups...

Isn't that what "proto=udp" vs. "proto=udp6" is for?

-- 
Chuck Lever
chuck[dot]lever[at]oracle[dot]com





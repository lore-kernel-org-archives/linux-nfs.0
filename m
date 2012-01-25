Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:54609 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751399Ab2AYOeu (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 25 Jan 2012 09:34:50 -0500
Date: Wed, 25 Jan 2012 09:34:49 -0500
To: "J. von Balzac" <jhm.balzac@gmail.com>
Cc: linux-nfs@vger.kernel.org
Subject: Re: NFSv4 - Linux server, FreeBSD client
Message-ID: <20120125143449.GB17873@fieldses.org>
References: <CAG+vHK+OUSdEc5L=_oeq4Y9iwseusspPTG=jwUvoOQd5587O9Q@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <CAG+vHK+OUSdEc5L=_oeq4Y9iwseusspPTG=jwUvoOQd5587O9Q@mail.gmail.com>
From: "J. Bruce Fields" <bfields@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Sat, Jan 21, 2012 at 06:04:17PM +0100, J. von Balzac wrote:
> Hello,
> 
> Linux (kernel 3.2) /etc/exports contains the following:
> 
> /exp  -ro,fsid=0,async,subtree_check,all_squash,crossmnt 192.168.1.0/24
> /exp/freebsd  -ro,no_acl,async,subtree_check,all_squash 192.168.1.0/24
> /exp/freebsd/extra -rw,no_acl,async,subtree_check,no_root_squash 192.168.1.0/24
> /exp/freebsd/ports  -rw,no_acl,async,subtree_check,no_root_squash 192.168.1.0/24

Note no_acl is actually meaningless, and async and subtree_check are
generally not recommended.

Also, "fsid=0" tricks aren't necessary any more: if you just leave out
that line, then v4 clients will be able to mount /exp/freebsd/* just as
v2/v3 clients would.

> I have also tested it without no_acl, and with the alternative
> 192.168.1.0/24(options).
> 
> The used mount command on FreeBSD and the resulting error:
> 
> # mount_nfs -o nfsv4 192.168.1.3:/freebsd/ports /usr/ports
> mount_nfs: /usr/ports, : Operation not permitted
> 
> I am emailing this list and not FreeBSD, because of this next output
> from tcpdump. Note that 192.168.1.3 is the server and 192.168.1.10 is
> the client:
> 
> 17:00:21.761418 IP (tos 0x0, ttl 64, id 62972, offset 0, flags [DF],
> proto TCP (6), length 116)
>     192.168.1.3.2049 > 192.168.1.10.1382070341: reply ok 60 getattr
> ERROR: Operation not permitted

Huh--does tcpdump even know how to parse NFSv4, or is that actually an
NFSv3 call?

The tcpdump output isn't very informative--wireshark is usually more
helpful.

What version of nfs-utils are you using?

--b.

> 
> The entire output of the tcpdump can be found at the following url:
> http://sprunge.us/OVbQ
> 
> Looking forward to resolving this.
> Jan.
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:13456 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752131Ab0JMMzx (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 13 Oct 2010 08:55:53 -0400
Date: Wed, 13 Oct 2010 08:56:28 -0400
From: Jeff Layton <jlayton@redhat.com>
To: Valentijn Sessink <valentyn@blub.net>
Cc: linux-nfs@vger.kernel.org
Subject: Re: ipv6 + krb5, server status?
Message-ID: <20101013085628.58f568d7@corrin.poochiereds.net>
In-Reply-To: <4CB59086.9080108@blub.net>
References: <4CB59086.9080108@blub.net>
Content-Type: text/plain; charset=US-ASCII
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Wed, 13 Oct 2010 12:57:10 +0200
Valentijn Sessink <valentyn@blub.net> wrote:

> Hello list,
> 
> I found a lot of information on the subject NFS server, ipv6 + krb5, but
> not anything conclusive. So I tried it out; I got IPv6 +
> NFS4 to work, but only with sec=sys.
> 
> When using sec=krb5, there seemed to be errors in gssd communication.
> (Ubuntu 10.04 with rpcbind instead of portmap; with nfs-utils-1.2.3 from
> nfs.sf.net, and with a 2.6.35-020635rc1-generic kernel package).
> 
> Is this correct, i.e. svcgssd still needs to be adapted to IPv6? Or
> should NFS-server/IPv6/Kerberos on Linux just work, i.e. should I
> re-check my configuration?
> 
> Best regards,
> 
> Valentijn Sessink
> 

When I last tested it and reviewed it (which was quite some time ago),
it worked without any issues. rpc.svcgssd doesn't really do much with
addresses, so it didn't need anything to convert it to IPv6.

What sort of problems were you having?

-- 
Jeff Layton <jlayton@redhat.com>

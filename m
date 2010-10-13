Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:58616 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752255Ab0JMNvl (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 13 Oct 2010 09:51:41 -0400
Date: Wed, 13 Oct 2010 09:52:16 -0400
From: Jeff Layton <jlayton@redhat.com>
To: Jim Rees <rees@umich.edu>
Cc: Valentijn Sessink <valentyn@blub.net>, linux-nfs@vger.kernel.org
Subject: Re: ipv6 + krb5, server status?
Message-ID: <20101013095216.5b9b31a7@corrin.poochiereds.net>
In-Reply-To: <20101013125656.GA5197@merit.edu>
References: <4CB59086.9080108@blub.net>
	<20101013125656.GA5197@merit.edu>
Content-Type: text/plain; charset=US-ASCII
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Wed, 13 Oct 2010 08:56:56 -0400
Jim Rees <rees@umich.edu> wrote:

> Valentijn Sessink wrote:
> 
>   Hello list,
>   
>   I found a lot of information on the subject NFS server, ipv6 + krb5, but
>   not anything conclusive. So I tried it out; I got IPv6 +
>   NFS4 to work, but only with sec=sys.
>   
>   When using sec=krb5, there seemed to be errors in gssd communication.
>   (Ubuntu 10.04 with rpcbind instead of portmap; with nfs-utils-1.2.3 from
>   nfs.sf.net, and with a 2.6.35-020635rc1-generic kernel package).
>   
>   Is this correct, i.e. svcgssd still needs to be adapted to IPv6? Or
>   should NFS-server/IPv6/Kerberos on Linux just work, i.e. should I
>   re-check my configuration?
> 
> I don't know the specific answer to your question, but ipv6 support is still
> a work in progress, and I'm actually a bit surprised it works out of the box
> even with sec=sys.
> 
> You may want to try the very latest ipv6 version of nfs-utils, which may
> have some patches that have not yet been merged upstream.  You can get it
> from git://git.linux-nfs.org/projects/cel/nfs-utils.git .  The usual
> warnings apply, this is experimental code, you could lose data, it may not
> work with your 2.6.35 kernel, and if you find bugs you can't necessarily get
> anyone to help you.

As of nfs-utils-1.2.3, IPv6 server-side support should be
"complete" (modulo bugs, of course).

-- 
Jeff Layton <jlayton@redhat.com>

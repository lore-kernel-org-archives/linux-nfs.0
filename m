Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from filter.openoffice.nl ([217.170.2.175]:35068 "EHLO
	filter.openoffice.nl" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752535Ab0JTMLk (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 20 Oct 2010 08:11:40 -0400
Message-ID: <4CBEDC75.6020503@blub.net>
Date: Wed, 20 Oct 2010 14:11:33 +0200
From: Valentijn Sessink <valentyn@blub.net>
To: Jim Rees <rees@umich.edu>
CC: Jeff Layton <jlayton@redhat.com>, linux-nfs@vger.kernel.org
Subject: Re: ipv6 + krb5, server status?
References: <4CB59086.9080108@blub.net> <20101013125656.GA5197@merit.edu> <20101013095216.5b9b31a7@corrin.poochiereds.net> <4CB5BA8F.2090608@blub.net> <20101013104937.358fe122@corrin.poochiereds.net> <4CBECBFF.2050802@blub.net> <20101020120519.GA3848@merit.edu>
In-Reply-To: <20101020120519.GA3848@merit.edu>
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

Hi Jim, Jeff, list,

Jim Rees schreef:
>   another system, where "networkmanager" messes with the hosts-file, and
> You mean resolv.conf?

No, /etc/hosts

Today, I found a long standing Ubuntu bug about this:
https://bugs.launchpad.net/ubuntu/+source/network-manager/+bug/8980

>  This is one of my gripes with network manager.  I
> usually un-install it, or "chattr +i resolv.conf".

Yep, we usually uninstall it as well.

But now, we're thinking about changing nsswitch.conf to "hosts: dns
files" - might be a better way in this case.

> The usual fix for idmapd is to set the domain in /etc/idmapd.conf.

Yes, I know. In fact, during the install phase we commented the "Domain"
clause out, to have the system configure it's own FQDN (based on DHCP,
mostly). I'm not a big fan of spraying domain name and hostname on every
file in /etc if the system can find things out by itself.

But I guess I'm being corrected by reality.

V.


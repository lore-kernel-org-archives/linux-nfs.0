Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-qk0-f180.google.com ([209.85.220.180]:36642 "EHLO
	mail-qk0-f180.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751383AbbFGJGl (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sun, 7 Jun 2015 05:06:41 -0400
Received: by qkx62 with SMTP id 62so63426708qkx.3
        for <linux-nfs@vger.kernel.org>; Sun, 07 Jun 2015 02:06:40 -0700 (PDT)
Message-ID: <5574099C.9090205@gmail.com>
Date: Sun, 07 Jun 2015 17:06:36 +0800
From: Kinglong Mee <kinglongmee@gmail.com>
MIME-Version: 1.0
To: Sean Elble <elbles@sessys.com>, linux-nfs@vger.kernel.org,
        Steve Dickson <SteveD@redhat.com>
Subject: Re: rpc.nfsd Host Option & IPv6
References: <b66b20ec16b59568246f454bfbbfd5e9@mail.sessys.com>
In-Reply-To: <b66b20ec16b59568246f454bfbbfd5e9@mail.sessys.com>
Content-Type: text/plain; charset=utf-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Cc steve,

On 6/3/2015 9:39 PM, Sean Elble wrote:
> Hi all,
> 
> While it seems that most folks use iptables to restrict access to single interfaces when multihomed hosts are acting as NFS servers, I do see that there is a "--host" option that can be provided to rpc.nfsd when it starts so that it only binds to a specific IP/interface.
> 
> This does seem to work nicely, but when I try to use it, it throws an error/warning (where nfs-server is defined in /etc/hosts for the IPv4 address of the interface I wish for TCP port 2049 to be opened on):
> 
> rpc.nfsd: unable to resolve nfs-server:nfs to inet6 address: Name or service not known

It is caused by that rpc.nfsd try to bind IPv4 and IPv6 address default.
you don't support an IPv6 address, so rpc.nfsd print the message.

But, IPv4 is work correctly.

> 
> Commenting out the following lines in /etc/netconfig (as suggested by the Google) allows the daemon to start without error:
> 
> udp6       tpi_clts      v     inet6    udp     -       -
> tcp6       tpi_cots_ord  v     inet6    tcp     -       -

If you comment those lines, rpc.nfsd will check /etc/netconfig and find udp6/tcp6 is not allowed,
so, rpc.nfsd will not bind IPv6 address, the message is not printed.

> 
> But I'm wondering if that is the only means for this to work, particularly considering that I'd expect changes to /etc/netconfig to apply to more than just rpc.nfsd.

Agree with you.

> 
> It is worth noting that 1) this seems to apply equally to Debian-based and RHEL-based systems and 2) things seem to work even with the error, but I wouldn't have expected to see that message for something (seemingly) so simple.

I think we should not print the message as you want.

thanks,
Kinglong Mee

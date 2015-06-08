Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from userp1040.oracle.com ([156.151.31.81]:48218 "EHLO
	userp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752206AbbFHTpZ convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 8 Jun 2015 15:45:25 -0400
Content-Type: text/plain; charset=windows-1252
Mime-Version: 1.0 (Mac OS X Mail 7.3 \(1878.6\))
Subject: Re: rpc.nfsd Host Option & IPv6
From: Chuck Lever <chuck.lever@oracle.com>
In-Reply-To: <b66b20ec16b59568246f454bfbbfd5e9@mail.sessys.com>
Date: Mon, 8 Jun 2015 15:48:29 -0400
Cc: Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Message-Id: <8AB90F17-5DBB-460C-8418-399C50F87D4C@oracle.com>
References: <b66b20ec16b59568246f454bfbbfd5e9@mail.sessys.com>
To: Sean Elble <elbles@sessys.com>, Jeff Layton <jlayton@poochiereds.net>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


On Jun 3, 2015, at 9:39 AM, Sean Elble <elbles@sessys.com> wrote:

> Hi all,
> 
> While it seems that most folks use iptables to restrict access to single interfaces when multihomed hosts are acting as NFS servers, I do see that there is a "--host" option that can be provided to rpc.nfsd when it starts so that it only binds to a specific IP/interface.
> 
> This does seem to work nicely, but when I try to use it, it throws an error/warning (where nfs-server is defined in /etc/hosts for the IPv4 address of the interface I wish for TCP port 2049 to be opened on):
> 
> rpc.nfsd: unable to resolve nfs-server:nfs to inet6 address: Name or service not known

This is a DNS error. No IPv6 mapping is provided in /etc/hosts. I suppose
if you provided “-H ipv4-address” the getaddrinfo(AF_INET6) call would
also fail.

Normally an ANY address is used when setting up NFSD listeners, and
no DNS lookup is done. This appears to be an issue just with -H.

> Commenting out the following lines in /etc/netconfig (as suggested by the Google) allows the daemon to start without error:
> 
> udp6       tpi_clts      v     inet6    udp     -       -
> tcp6       tpi_cots_ord  v     inet6    tcp     -       -
> 
> But I'm wondering if that is the only means for this to work, particularly considering that I'd expect changes to /etc/netconfig to apply to more than just rpc.nfsd.

The kernel handles IPv4 and IPv6 traffic on separate listener sockets.

It appears that with support for /etc/netconfig, it is possible to
set up a UDP AF_INET NFSD socket and a TCP AF_INET6 NFSD socket?

Since these are not really TI-RPC sockets and libtirpc isn’t
involved after the sockets are passed to the kernel, I’m not sure
it’s appropriate to consult /etc/netconfig here?

Anyway, the creation of the IPv4 socket succeeded, but the creation
of the IPv6 socket did not. At least one socket was created, so the
rpc.nfsd command worked, even though it threw a spurious error.

My preference would be to change the way all this works so that a
single getaddrinfo(3) could be used for both sockets. That way the
DNS failure would occur only if there were _no_ valid addresses,
since that’s the only legitimate failure in this case.

Jeff, any thoughts? Am I contradicting myself from 6 years ago?

--
Chuck Lever
chuck[dot]lever[at]oracle[dot]com




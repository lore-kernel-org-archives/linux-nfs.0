Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-ig0-f182.google.com ([209.85.213.182]:34103 "EHLO
	mail-ig0-f182.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751475AbbFITFc convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 9 Jun 2015 15:05:32 -0400
Received: by igbhj9 with SMTP id hj9so19674234igb.1
        for <linux-nfs@vger.kernel.org>; Tue, 09 Jun 2015 12:05:31 -0700 (PDT)
Date: Tue, 9 Jun 2015 15:05:24 -0400
From: Jeff Layton <jlayton@poochiereds.net>
To: Chuck Lever <chuck.lever@oracle.com>
Cc: Sean Elble <elbles@sessys.com>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Subject: Re: rpc.nfsd Host Option & IPv6
Message-ID: <20150609150524.327489f6@tlielax.poochiereds.net>
In-Reply-To: <8AB90F17-5DBB-460C-8418-399C50F87D4C@oracle.com>
References: <b66b20ec16b59568246f454bfbbfd5e9@mail.sessys.com>
	<8AB90F17-5DBB-460C-8418-399C50F87D4C@oracle.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, 8 Jun 2015 15:48:29 -0400
Chuck Lever <chuck.lever@oracle.com> wrote:

> 
> On Jun 3, 2015, at 9:39 AM, Sean Elble <elbles@sessys.com> wrote:
> 
> > Hi all,
> > 
> > While it seems that most folks use iptables to restrict access to single interfaces when multihomed hosts are acting as NFS servers, I do see that there is a "--host" option that can be provided to rpc.nfsd when it starts so that it only binds to a specific IP/interface.
> > 
> > This does seem to work nicely, but when I try to use it, it throws an error/warning (where nfs-server is defined in /etc/hosts for the IPv4 address of the interface I wish for TCP port 2049 to be opened on):
> > 
> > rpc.nfsd: unable to resolve nfs-server:nfs to inet6 address: Name or service not known
> 
> This is a DNS error. No IPv6 mapping is provided in /etc/hosts. I suppose
> if you provided “-H ipv4-address” the getaddrinfo(AF_INET6) call would
> also fail.
> 
> Normally an ANY address is used when setting up NFSD listeners, and
> no DNS lookup is done. This appears to be an issue just with -H.
> 
> > Commenting out the following lines in /etc/netconfig (as suggested by the Google) allows the daemon to start without error:
> > 
> > udp6       tpi_clts      v     inet6    udp     -       -
> > tcp6       tpi_cots_ord  v     inet6    tcp     -       -
> > 
> > But I'm wondering if that is the only means for this to work, particularly considering that I'd expect changes to /etc/netconfig to apply to more than just rpc.nfsd.
> 
> The kernel handles IPv4 and IPv6 traffic on separate listener sockets.
> 
> It appears that with support for /etc/netconfig, it is possible to
> set up a UDP AF_INET NFSD socket and a TCP AF_INET6 NFSD socket?
> 
> Since these are not really TI-RPC sockets and libtirpc isn’t
> involved after the sockets are passed to the kernel, I’m not sure
> it’s appropriate to consult /etc/netconfig here?
> 
> Anyway, the creation of the IPv4 socket succeeded, but the creation
> of the IPv6 socket did not. At least one socket was created, so the
> rpc.nfsd command worked, even though it threw a spurious error.
> 
> My preference would be to change the way all this works so that a
> single getaddrinfo(3) could be used for both sockets. That way the
> DNS failure would occur only if there were _no_ valid addresses,
> since that’s the only legitimate failure in this case.
> 
> Jeff, any thoughts? Am I contradicting myself from 6 years ago?
> 

No, sounds reasonable to me. I suspect that the code is probably not
structured to handle that well at the moment, so that'll mean some
refactoring.

-- 
Jeff Layton <jlayton@poochiereds.net>

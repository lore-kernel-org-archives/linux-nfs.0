Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([173.255.197.46]:41055 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752214AbbFHVMQ (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 8 Jun 2015 17:12:16 -0400
Date: Mon, 8 Jun 2015 17:12:10 -0400
To: Sean Elble <elbles@sessys.com>
Cc: Chuck Lever <chucklever@gmail.com>, Kinglong Mee <kinglongmee@gmail.com>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>,
        linux-nfs-owner@vger.kernel.org
Subject: Re: [PATCH] rpc.nfsd: add no-ipv4 and no-ipv6 options
Message-ID: <20150608211210.GC27887@fieldses.org>
References: <55743EDE.7070707@gmail.com>
 <3CE6594A-508B-4BBD-9E52-CF9EDDA6274D@oracle.com>
 <557597D3.8090401@gmail.com>
 <312511264c19c5a98cbd1062531b306e@mail.sessys.com>
 <2F03891D-9240-4A8E-BEEB-7F5BBAD1B5FE@gmail.com>
 <76DB6DF0-8409-4D42-B2FD-6C7B08B148A5@gmail.com>
 <d4bfa4c82f2a8ef2dec4dce303c0c96b@mail.sessys.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
In-Reply-To: <d4bfa4c82f2a8ef2dec4dce303c0c96b@mail.sessys.com>
From: bfields@fieldses.org (J. Bruce Fields)
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, Jun 08, 2015 at 10:33:22AM -0400, Sean Elble wrote:
> On 08.06.2015 10:27, Chuck Lever wrote:
> >>I don’t understand the need to “turn off” an address family.
> >>That’s what
> >>/etc/netconfig is supposed to be for. What’s not happening here that
> >>should be?
> >
> >What I mean is: I’d rather not add more command line options if there
> >is a way for rpc.nfsd to automatically and quietly do what is needed.
> >But I don’t understand the use case here. Sean, can you explain it
> >for
> >bears of little brain?
> 
> Sure, and please correct me if any of my understanding is incorrect
> (as it may well be).  In my environment, I wanted to have NFS only
> listen on one interface of a multihomed host.  In using the "--host"
> parameter to do so, I saw the error message regarding IPv6 thrown.
> While disabling IPv6 globally in /etc/netconfig is an option (one I
> understand to be "global", in that it'd affect *all* applications on
> the host), it'd be nice to disable IPv6 for a single service/daemon
> instead.

But doesn't something like

	rpc.nfsd --host 10.0.0.1 --no-ipv6

seem a bit redundant?

I mean, you've already told it to listen to that one (ipv4) address.
That'd argue for just disabling the warning in this case, I think.  But
my understanding of IPv6 is still poor.

--b.

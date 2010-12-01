Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:42728 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754168Ab0LADKT convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 30 Nov 2010 22:10:19 -0500
Subject: Re: NFSv4 behaviour on unknown users
From: Trond Myklebust <Trond.Myklebust@netapp.com>
To: Neil Brown <neilb@suse.de>
Cc: "J. Bruce Fields" <bfields@fieldses.org>,
        Steve Dickson <SteveD@redhat.com>, Spelic <spelic@shiftmail.org>,
        linux-nfs@vger.kernel.org
In-Reply-To: <20101201135740.0d3b5948@notabene.brown>
References: <4CF3ED05.3070401@shiftmail.org>
	 <1291054975.12784.17.camel@heimdal.trondhjem.org>
	 <4CF3F326.4060608@shiftmail.org> <20101129190122.GA31843@fieldses.org>
	 <1291057747.12784.38.camel@heimdal.trondhjem.org>
	 <4CF519F2.8080900@RedHat.com>
	 <1291155578.2998.38.camel@heimdal.trondhjem.org>
	 <20101130222651.GB5054@fieldses.org>
	 <1291156414.4393.2.camel@heimdal.trondhjem.org>
	 <20101130223627.GC5054@fieldses.org>
	 <20101201135740.0d3b5948@notabene.brown>
Content-Type: text/plain; charset="UTF-8"
Date: Tue, 30 Nov 2010 22:10:02 -0500
Message-ID: <1291173002.7694.7.camel@heimdal.trondhjem.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Wed, 2010-12-01 at 13:57 +1100, Neil Brown wrote:
> I have a strong memory from about 7 years ago of Brian Pawlowski saying - or
> possibly being quoted as saying - that the user information in NFS requests
> (the stuff that idmapper handles) is totally independent of the RPC
> authentication mechanism being used (the AUTH_SYS / RPCSEC_GSS stuff).
> 
> I always thought that was nonsense, but I wasn't in a position to discuss it
> at the time for reasons that I really don't recall.
> 
> If users are being authorised using numbers (AUTH_SYS) then it only (to me)
> makes sense to communication all identies as numbers.
> And if users are being authenticated as name@domain strings, then it only
> make sense to communicate all identities as name@domain.
> 
> But this path is not the path for NFSv4 followed.
> 
> I've very glad to see Linux NFS allowing numeric IDs "on the wire" and hope
> to see this very sensible approach widely adopted (where AUTH_SYS is used).
> I think it would be great if nfsd did the same thing completely in-kernel
> without reference to idmapd.  Accepting either numeric or domain-based is
> trivial.  Choosing which to send on a per-client basis might be a challenge,
> but probably not a big one.
> 
> 
> I wonder if Brian remembers saying anything like that...

I think you need to take beepy's words in context here: as I believe I
mentioned previously, RFC3530 (and its predecessor RFC3010) assumed
everyone would be using principals for authenticating, either through
RPCSEC_GSS w/ krb5, or through the SPKM/Lipkey mechanism. So sure was
everyone of this, that AUTH_SYS isn't even mentioned as a valid
authentication mechanism, and so nobody had to worry about the
consequences of using it.

The fact we still use AUTH_SYS today is, BTW, very much a result of the
failure of SPKM/Lipkey to deliver on its promise of strong
authentication with no extra infrastructure requirements. If it had, we
wouldn't be needing this hack.

Cheers
  Trond

-- 
Trond Myklebust
Linux NFS client maintainer

NetApp
Trond.Myklebust@netapp.com
www.netapp.com


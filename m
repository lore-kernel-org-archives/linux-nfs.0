From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: Performance Diagnosis
Date: Tue, 15 Jul 2008 15:35:52 -0400
Message-ID: <1216150552.7981.48.camel@localhost>
References: <e80abd30807150834m47a1b86cle39885150f1d5bfd@mail.gmail.com>
	 <487CC928.8070908@redhat.com>
	 <76bd70e30807150923r31027edxb0394a220bbe879b@mail.gmail.com>
	 <487CE202.2000809@redhat.com>
	 <76bd70e30807151117g520f22cj1dfe26b971987d38@mail.gmail.com>
	 <1216147879.7981.44.camel@localhost>  <487CF8D6.2090908@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: chucklever@gmail.com, Andrew Bell <andrew.bell.ia@gmail.com>,
	linux-nfs@vger.kernel.org
To: Peter Staubach <staubach@redhat.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-out1.uio.no ([129.240.10.57]:48513 "EHLO mail-out1.uio.no"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753706AbYGOTf5 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 15 Jul 2008 15:35:57 -0400
In-Reply-To: <487CF8D6.2090908@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, 2008-07-15 at 15:21 -0400, Peter Staubach wrote:
> The connection manager would seem to be a RPC level thing, although
> I haven't thought through the ramifications of the NFSv4.1 stuff
> and how it might impact a connection manager sufficiently.

We already have the scheme that shuts down connections on inactive RPC
clients after a suitable timeout period, so the only gains I can see
would have to involve shutting down connections on active clients.

At that point, the danger isn't with NFSv4.1, it is rather with
NFSv2/3/4.0... Specifically, their lack of good replay cache semantics
mean that you have to be very careful about schemes that involve
shutting down connections on active RPC clients.

Cheers
  Trond


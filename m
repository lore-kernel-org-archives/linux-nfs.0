From: Benny Halevy <bhalevy@panasas.com>
Subject: Re: Performance Diagnosis
Date: Wed, 16 Jul 2008 10:35:15 +0300
Message-ID: <487DA4B3.1070805@panasas.com>
References: <e80abd30807150834m47a1b86cle39885150f1d5bfd@mail.gmail.com>	 <487CC928.8070908@redhat.com>	 <76bd70e30807150923r31027edxb0394a220bbe879b@mail.gmail.com>	 <487CE202.2000809@redhat.com>	 <76bd70e30807151117g520f22cj1dfe26b971987d38@mail.gmail.com>	 <1216147879.7981.44.camel@localhost>  <487CF8D6.2090908@redhat.com> <1216150552.7981.48.camel@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: Peter Staubach <staubach@redhat.com>, chucklever@gmail.com,
	Andrew Bell <andrew.bell.ia@gmail.com>,
	linux-nfs@vger.kernel.org
To: Trond Myklebust <trond.myklebust@fys.uio.no>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from gw-colo-pa.panasas.com ([66.238.117.130]:17416 "EHLO
	natasha.panasas.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1751939AbYGPHf7 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 16 Jul 2008 03:35:59 -0400
In-Reply-To: <1216150552.7981.48.camel@localhost>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Jul. 15, 2008, 22:35 +0300, Trond Myklebust <trond.myklebust@fys.uio.no> wrote:
> On Tue, 2008-07-15 at 15:21 -0400, Peter Staubach wrote:
>> The connection manager would seem to be a RPC level thing, although
>> I haven't thought through the ramifications of the NFSv4.1 stuff
>> and how it might impact a connection manager sufficiently.
> 
> We already have the scheme that shuts down connections on inactive RPC
> clients after a suitable timeout period, so the only gains I can see
> would have to involve shutting down connections on active clients.
> 
> At that point, the danger isn't with NFSv4.1, it is rather with
> NFSv2/3/4.0... Specifically, their lack of good replay cache semantics
> mean that you have to be very careful about schemes that involve
> shutting down connections on active RPC clients.

One more thing to consider about nfsv4.1 is the back channel which
uses one of the forward going connections.  You may need to keep it
alive while you hold state on the client (data/dir delegations, layouts,
etc.)

Benny

> 
> Cheers
>   Trond
> 
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html


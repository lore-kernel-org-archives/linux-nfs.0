From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: PATCH:  Support binding to a local IPv4 address when mounting
 a server.
Date: Sun, 22 Feb 2009 14:01:54 -0800
Message-ID: <1235340114.7331.92.camel@heimdal.trondhjem.org>
References: <4977C580.4040805@candelatech.com>
	 <633CA802-DD5A-4082-B771-C524D367241F@oracle.com>
	 <497805A7.4070205@candelatech.com>
	 <A1D6FF17-95D6-4775-AF60-5D6CD2078B3E@oracle.com>
	 <4978AD75.9090900@candelatech.com>
	 <65D69956-DB67-43A7-9101-9AFB7EC55A9F@oracle.com>
	 <499FB08B.1070200@candelatech.com>
	 <EF45429F-0B16-47C7-89ED-7C14C44E6E5E@oracle.com>
	 <49A0E802.9000209@candelatech.com>
	 <1235329791.7331.75.camel@heimdal.trondhjem.org>
	 <7DBDEC87-CB31-404E-8C4D-2762358387DE@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Linux NFS Mailing List <linux-nfs@vger.kernel.org>,
	Patrick McHardy <kaber@trash.net>,
	Ben Greear <greearb@candelatech.com>
To: Chuck Lever <chuck.lever@oracle.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-out1.uio.no ([129.240.10.57]:54858 "EHLO mail-out1.uio.no"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752523AbZBVWB7 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Sun, 22 Feb 2009 17:01:59 -0500
In-Reply-To: <7DBDEC87-CB31-404E-8C4D-2762358387DE@oracle.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Sun, 2009-02-22 at 15:29 -0500, Chuck Lever wrote:
> On Feb 22, 2009, at Feb 22, 2009, 2:09 PM, Trond Myklebust wrote:
> > I really dislike this idea of adding routing information at the sunrpc
> > level.
> 
> Well I think we have had problems in the past where RPC replies on  
> multi-homed systems go to the wrong interface and are dropped.  Isn't  
> that why we now have the source address field in rpc_create_args?

I fail to see the relevance to this case. We're not talking about RPC
callbacks here.

> I suspect we might have similar problems with NSM, for instance.

See Tom Talpey's talk at Connectathon a few years ago. This is why we
now have the 'nsm_use_hostnames' sysctl, and why the statd callback code
saves FQDNs rather than ip addresses.

Trond


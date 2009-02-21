From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: PATCH:  Support binding to a local IPv4 address when mounting
 a server.
Date: Sat, 21 Feb 2009 09:16:03 -0800
Message-ID: <1235236563.7312.5.camel@heimdal.trondhjem.org>
References: <4977C580.4040805@candelatech.com>
	 <633CA802-DD5A-4082-B771-C524D367241F@oracle.com>
	 <497805A7.4070205@candelatech.com>
	 <A1D6FF17-95D6-4775-AF60-5D6CD2078B3E@oracle.com>
	 <4978AD75.9090900@candelatech.com>
	 <65D69956-DB67-43A7-9101-9AFB7EC55A9F@oracle.com>
	 <499FB08B.1070200@candelatech.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Chuck Lever <chuck.lever@oracle.com>, linux-nfs@vger.kernel.org,
	Patrick McHardy <kaber@trash.net>
To: Ben Greear <greearb@candelatech.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-out2.uio.no ([129.240.10.58]:34384 "EHLO mail-out2.uio.no"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753064AbZBURQO (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Sat, 21 Feb 2009 12:16:14 -0500
In-Reply-To: <499FB08B.1070200@candelatech.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, 2009-02-20 at 23:43 -0800, Ben Greear wrote:
> I re-worked the kernel nfs local-address-binding logic against 
> 2.6.29-rc5.  In quick testing,
> this works with IPv4 and NFSv3 at least.  I changed the attribute to be 
> called 'bindaddr'
> as previously suggested.

Most of the changes are to NFSv4-specific code, and I definitely want
those code paths tested before considering this patch.

> I didn't actually make any further changes to the mount.nfs tool and it 
> took the bindaddr=a.b.c.d
> just fine, so maybe there are no changes at all needed in user-space.
> 
> Comments & suggestions welcome.

Remind me again what the application is?

Trond


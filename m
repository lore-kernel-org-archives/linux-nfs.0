From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: PATCH:  Support binding to a local IPv4 address when mounting
 a server.
Date: Sun, 22 Feb 2009 11:09:51 -0800
Message-ID: <1235329791.7331.75.camel@heimdal.trondhjem.org>
References: <4977C580.4040805@candelatech.com>
	 <633CA802-DD5A-4082-B771-C524D367241F@oracle.com>
	 <497805A7.4070205@candelatech.com>
	 <A1D6FF17-95D6-4775-AF60-5D6CD2078B3E@oracle.com>
	 <4978AD75.9090900@candelatech.com>
	 <65D69956-DB67-43A7-9101-9AFB7EC55A9F@oracle.com>
	 <499FB08B.1070200@candelatech.com>
	 <EF45429F-0B16-47C7-89ED-7C14C44E6E5E@oracle.com>
	 <49A0E802.9000209@candelatech.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Chuck Lever <chuck.lever@oracle.com>, linux-nfs@vger.kernel.org,
	Patrick McHardy <kaber@trash.net>
To: Ben Greear <greearb@candelatech.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-out2.uio.no ([129.240.10.58]:42029 "EHLO mail-out2.uio.no"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751948AbZBVTKB (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Sun, 22 Feb 2009 14:10:01 -0500
In-Reply-To: <49A0E802.9000209@candelatech.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Sat, 2009-02-21 at 21:52 -0800, Ben Greear wrote:
> Chuck Lever wrote:
> > Hi Ben-
> >
> > On Feb 21, 2009, at Feb 21, 2009, 2:43 AM, Ben Greear wrote:
> >> I re-worked the kernel nfs local-address-binding logic against 
> >> 2.6.29-rc5.  In quick testing,
> >> this works with IPv4 and NFSv3 at least.  I changed the attribute to 
> >> be called 'bindaddr'
> >> as previously suggested.
> >>
> >> I didn't actually make any further changes to the mount.nfs tool and 
> >> it took the bindaddr=a.b.c.d
> >> just fine, so maybe there are no changes at all needed in user-space.
> >
> > You probably want the code in support/nfs/getport.c to send requests 
> > from your bindaddr, if the mount command has to contact the server to 
> > renegotiate mount options.
> 
> Any clue as to which part of this code to modify and how to test if it 
> actually
> does anything useful?
> 
> >>
> >>     /* Don't talk to strangers */
> >> -    clp = nfs_find_client(svc_addr(rqstp), 4);
> >> +    clp = nfs_find_client(svc_daddr(rqstp), svc_addr(rqstp), 4);
> >
> > It's not clear to me why the callback server needs to be aware of the 
> > mount point's bind address.  Can you explain this a little more?  I 
> > would think the bind address would be pertinent for sending callback 
> > service replies, but I don't see code here to do that.
> I want to have a unique mount per local IP, so if I mount the same 
> server from 1.1.1.1 and from 1.1.1.2, I
> want two unique mounts.  I believe the way to do this is to 
> differentiate based on the IP addr,
> which is what this code is supposed to be doing.

You can already do that using the -onosharecache option.

I really dislike this idea of adding routing information at the sunrpc
level. So, I repeat: what is the application for all this? I've heard
mutterings about routing and multi-homed servers, but absolutely zero in
the way of specific applications and requirements.

Why can't you for instance do exactly the same thing, simply by setting
up two separate local networks; one for each NIC?

Trond


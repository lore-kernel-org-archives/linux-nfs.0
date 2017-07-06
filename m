Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([173.255.197.46]:50702 "EHLO fieldses.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751853AbdGFRQ1 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Thu, 6 Jul 2017 13:16:27 -0400
Date: Thu, 6 Jul 2017 13:16:26 -0400
To: Stefan Hajnoczi <stefanha@redhat.com>
Cc: Steve Dickson <SteveD@RedHat.com>, linux-nfs@vger.kernel.org,
        Jeff Layton <jlayton@redhat.com>,
        Abbas Naderi <abiusx@google.com>
Subject: Re: [PATCH nfs-utils v2 03/12] mount: present AF_VSOCK addresses
Message-ID: <20170706171626.GA30737@fieldses.org>
References: <20170630132120.31578-1-stefanha@redhat.com>
 <20170630132120.31578-4-stefanha@redhat.com>
 <dc1bd4ee-621f-d988-2914-61b1c144f146@RedHat.com>
 <20170703090048.GC22607@stefanha-x1.localdomain>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20170703090048.GC22607@stefanha-x1.localdomain>
From: bfields@fieldses.org (J. Bruce Fields)
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, Jul 03, 2017 at 10:00:48AM +0100, Stefan Hajnoczi wrote:
> On Fri, Jun 30, 2017 at 10:40:49AM -0400, Steve Dickson wrote:
> > On 06/30/2017 09:21 AM, Stefan Hajnoczi wrote:
> > > Format vsock hosts as "vsock:<cid>" so the addresses can be easily
> > > distinguished from IPv4 and IPv6 addresses.
> > > 
> > > Signed-off-by: Stefan Hajnoczi <stefanha@redhat.com>
> > > ---
> > >  utils/mount/network.c | 8 ++++++++
> > >  1 file changed, 8 insertions(+)
> > > 
> > > diff --git a/utils/mount/network.c b/utils/mount/network.c
> > > index 281e935..b5dcaa5 100644
> > > --- a/utils/mount/network.c
> > > +++ b/utils/mount/network.c
> > > @@ -45,6 +45,8 @@
> > >  #include <rpc/pmap_prot.h>
> > >  #include <rpc/pmap_clnt.h>
> > >  
> > > +#include <linux/vm_sockets.h>
> > In the previous patch you had this surrounded by #ifdef AF_VSOCK
> > I'm not keen on sprinkling a bunch ifdefs around since 
> > I think it makes the code harder to read. So my question 
> > is why is the ifdef need in the previous patch and
> > not needed in this patch and are they needed in the
> > previous patch?
> 
> The lack of #ifdef is my mistake.
> 
> My impression of nfs-utils is that the code is written to work in a
> variety of configurations and still support older kernels.  So I am
> wrapping AF_VSOCK logic with an #ifdef.

It needs to be able to support older kernels at run-time, and I don't
understand how #ifdefs would help with that.

--b.

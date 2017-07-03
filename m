Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mout02.posteo.de ([185.67.36.66]:33835 "EHLO mout02.posteo.de"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1753171AbdGCVFk (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Mon, 3 Jul 2017 17:05:40 -0400
Received: from submission (posteo.de [89.146.220.130])
        by mout02.posteo.de (Postfix) with ESMTPS id 2E9A120F74
        for <linux-nfs@vger.kernel.org>; Mon,  3 Jul 2017 23:05:38 +0200 (CEST)
Date: Mon, 3 Jul 2017 17:04:19 -0400
From: Felix Janda <felix.janda@posteo.de>
To: Steve Dickson <SteveD@RedHat.com>
Cc: Stefan Hajnoczi <stefanha@redhat.com>, linux-nfs@vger.kernel.org,
        Jeff Layton <jlayton@redhat.com>,
        Abbas Naderi <abiusx@google.com>
Subject: Re: [PATCH nfs-utils v2 03/12] mount: present AF_VSOCK addresses
Message-ID: <20170703210419.GA851@nyan>
References: <20170630132120.31578-1-stefanha@redhat.com>
 <20170630132120.31578-4-stefanha@redhat.com>
 <dc1bd4ee-621f-d988-2914-61b1c144f146@RedHat.com>
 <20170703090048.GC22607@stefanha-x1.localdomain>
 <2730896d-f9d6-352d-e829-d672d8735bd3@RedHat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <2730896d-f9d6-352d-e829-d672d8735bd3@RedHat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Steve Dickson wrote:
> 
> 
> On 07/03/2017 05:00 AM, Stefan Hajnoczi wrote:
> > On Fri, Jun 30, 2017 at 10:40:49AM -0400, Steve Dickson wrote:
> >> On 06/30/2017 09:21 AM, Stefan Hajnoczi wrote:
> >>> Format vsock hosts as "vsock:<cid>" so the addresses can be easily
> >>> distinguished from IPv4 and IPv6 addresses.
> >>>
> >>> Signed-off-by: Stefan Hajnoczi <stefanha@redhat.com>
> >>> ---
> >>>  utils/mount/network.c | 8 ++++++++
> >>>  1 file changed, 8 insertions(+)
> >>>
> >>> diff --git a/utils/mount/network.c b/utils/mount/network.c
> >>> index 281e935..b5dcaa5 100644
> >>> --- a/utils/mount/network.c
> >>> +++ b/utils/mount/network.c
> >>> @@ -45,6 +45,8 @@
> >>>  #include <rpc/pmap_prot.h>
> >>>  #include <rpc/pmap_clnt.h>
> >>>  
> >>> +#include <linux/vm_sockets.h>
> >> In the previous patch you had this surrounded by #ifdef AF_VSOCK
> >> I'm not keen on sprinkling a bunch ifdefs around since 
> >> I think it makes the code harder to read. So my question 
> >> is why is the ifdef need in the previous patch and
> >> not needed in this patch and are they needed in the
> >> previous patch?
> > 
> > The lack of #ifdef is my mistake.
> Fair enough.
> 
> > 
> > My impression of nfs-utils is that the code is written to work in a
> > variety of configurations and still support older kernels.  So I am
> > wrapping AF_VSOCK logic with an #ifdef.
> > 
> > AF_VSOCK has been in Linux since v3.9 in commit
> > d021c344051af91f42c5ba9fdedc176740cbd238 ("VSOCK: Introduce VM
> > Sockets").
> > 
> > I'd love to eliminate the #ifdefs, but would it be acceptable to simply
> > drop them?
> Very good question... 
> 
> CC-ing Felix... Would not ifdef-ing AF_VSOCK break compiling 
> with the musl libc? 

musl has AF_VSOCK since 2013 (v0.9.12):

http://git.musl-libc.org/cgit/musl/commit/?id=3d4583c3fba8989a596506619277ecd68768d9ab

I doubt that many people are using a version of musl older than that.

Felix

> Are there other implementations out there that would cause breakage?
> I'm pretty sure nfs-utils is only used in Linux environments, right?
> 
> steved.

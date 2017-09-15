Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-qt0-f169.google.com ([209.85.216.169]:46104 "EHLO
        mail-qt0-f169.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751229AbdIOLHK (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Fri, 15 Sep 2017 07:07:10 -0400
Received: by mail-qt0-f169.google.com with SMTP id s18so1788822qta.3
        for <linux-nfs@vger.kernel.org>; Fri, 15 Sep 2017 04:07:10 -0700 (PDT)
Message-ID: <1505473626.4781.9.camel@redhat.com>
Subject: Re: [PATCH nfs-utils v3 00/14] add NFS over AF_VSOCK support
From: Jeff Layton <jlayton@redhat.com>
To: Stefan Hajnoczi <stefanha@redhat.com>
Cc: linux-nfs@vger.kernel.org, NeilBrown <neilb@suse.com>,
        Matt Benjamin <mbenjami@redhat.com>,
        Chuck Lever <chuck.lever@oracle.com>,
        "J . Bruce Fields" <bfields@fieldses.org>,
        Steve Dickson <SteveD@RedHat.com>
Date: Fri, 15 Sep 2017 07:07:06 -0400
In-Reply-To: <20170914173730.GD4673@fieldses.org>
References: <20170913102650.10377-1-stefanha@redhat.com>
         <9adfce4d-dbd7-55a9-eb73-7389dbf900ac@RedHat.com>
         <0a5452ff-6cb9-4336-779b-ae65cfe156b8@RedHat.com>
         <20170914173730.GD4673@fieldses.org>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, 2017-09-14 at 13:37 -0400, J . Bruce Fields wrote:
> On Thu, Sep 14, 2017 at 11:55:51AM -0400, Steve Dickson wrote:
> > 
> > 
> > On 09/14/2017 11:39 AM, Steve Dickson wrote:
> > > Hello
> > > 
> > > On 09/13/2017 06:26 AM, Stefan Hajnoczi wrote:
> > > > v3:
> > > >  * Documented vsock syntax in exports.man, nfs.man, and nfsd.man
> > > >  * Added clientaddr autodetection in mount.nfs(8)
> > > >  * Replaced #ifdefs with a single vsock.h header file
> > > >  * Tested nfsd serving both IPv4 and vsock at the same time
> > > 
> > > Just curious as to the status of the kernel patches... Are
> > > they slated for any particular release?
> > 
> > Maybe I should have read the thread before replying ;-) 
> > 
> > I now see the status of the patches... not good!  8-)
> 
> To be specific, the code itself is probably fine, it's just that nobody
> on the NFS side seems convinced that NFS/VSOCK is necessary.
> 

...and to be even more clear, the problem you've outlined (having a zero
config network between an HV and guest) is a valid one. The issue here
is that the solution in these patches is horribly invasive and will
create an ongoing maintenance burden.

What would be much cleaner (IMNSHO) is a new type of virtual network
interface driver that has similar communication characteristics (only
allowing HV<->guest communication) and that autoconfigures itself when
plugged in (or only does so with minimal setup).

Then you could achieve the same result without having to completely
rework all of this code. That's also something potentially backportable
to earlier kernels, which is a nice bonus.
-- 
Jeff Layton <jlayton@redhat.com>

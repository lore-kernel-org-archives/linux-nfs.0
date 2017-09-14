Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([173.255.197.46]:41888 "EHLO fieldses.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751316AbdINRhb (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Thu, 14 Sep 2017 13:37:31 -0400
Date: Thu, 14 Sep 2017 13:37:30 -0400
From: "J . Bruce Fields" <bfields@fieldses.org>
To: Steve Dickson <SteveD@RedHat.com>
Cc: Stefan Hajnoczi <stefanha@redhat.com>, linux-nfs@vger.kernel.org,
        NeilBrown <neilb@suse.com>, Matt Benjamin <mbenjami@redhat.com>,
        Jeff Layton <jlayton@redhat.com>,
        Chuck Lever <chuck.lever@oracle.com>
Subject: Re: [PATCH nfs-utils v3 00/14] add NFS over AF_VSOCK support
Message-ID: <20170914173730.GD4673@fieldses.org>
References: <20170913102650.10377-1-stefanha@redhat.com>
 <9adfce4d-dbd7-55a9-eb73-7389dbf900ac@RedHat.com>
 <0a5452ff-6cb9-4336-779b-ae65cfe156b8@RedHat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <0a5452ff-6cb9-4336-779b-ae65cfe156b8@RedHat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, Sep 14, 2017 at 11:55:51AM -0400, Steve Dickson wrote:
> 
> 
> On 09/14/2017 11:39 AM, Steve Dickson wrote:
> > Hello
> > 
> > On 09/13/2017 06:26 AM, Stefan Hajnoczi wrote:
> >> v3:
> >>  * Documented vsock syntax in exports.man, nfs.man, and nfsd.man
> >>  * Added clientaddr autodetection in mount.nfs(8)
> >>  * Replaced #ifdefs with a single vsock.h header file
> >>  * Tested nfsd serving both IPv4 and vsock at the same time
> > Just curious as to the status of the kernel patches... Are
> > they slated for any particular release?
> Maybe I should have read the thread before replying ;-) 
> 
> I now see the status of the patches... not good!  8-)

To be specific, the code itself is probably fine, it's just that nobody
on the NFS side seems convinced that NFS/VSOCK is necessary.

--b.

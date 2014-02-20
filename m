Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:34211 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752540AbaBTUmt (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 20 Feb 2014 15:42:49 -0500
Date: Thu, 20 Feb 2014 15:42:47 -0500
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Steve Dickson <SteveD@redhat.com>
Cc: NeilBrown <neilb@suse.de>, Chuck Lever <chuck.lever@oracle.com>,
        NFS <linux-nfs@vger.kernel.org>, Carsten Ziepke <kieltux@gmail.com>
Subject: Re: [PATCH - nfs-utils] Fix fallback from tcp to udp
Message-ID: <20140220204247.GB13433@fieldses.org>
References: <20140218104307.34205fc8@notabene.brown>
 <53064057.70703@RedHat.com>
 <20140220203701.GA13433@fieldses.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20140220203701.GA13433@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, Feb 20, 2014 at 03:37:01PM -0500, bfields wrote:
> On Thu, Feb 20, 2014 at 12:50:15PM -0500, Steve Dickson wrote:
> > 
> > 
> > On 02/17/2014 06:43 PM, NeilBrown wrote:
> > > 
> > > Protocol negotiation in mount.nfs does not correctly negotiate with a
> > > server which only support NFSv3 and UDP.
> > > 
> > > When mount.nfs attempts an NFSv4 mount and fails with ECONNREFUSED
> > > it does not fall back to NFSv3, as this is not recognised as a
> > > "does not support NFSv4" error.
> > > However ECONNREFUSED is a clear indication that the server doesn't
> > > support TCP, and ipso facto does not support NFSv4.
> > > So ECONNREFUSED should trigger a fallback from v4 to v2/3.
> > I'm also pretty this is the error returned when the server is 
> > down or more pointy when server is rebooting...
> 
> Probably worth checking that.
> 
> > Do we really want to fallback at this point?
> 
> From a bz comment (#984901, not sure why it's private):
> 
> Any NFS server has to support either tcp or rpcbind.  But it's OK for a
> server to support only of those two.  So the only way to handle both
> cases while continuing to retry after ECONNREFUSED

(But I'm not actually convinced that's true.  In particular I don't see
ECONNREFUSED when rebooting a server.  But I'm not clear when it's
returned....)

--b.

> is to alternate
> between trying nfs4/tcp and rpcbind until you can connect to one or the
> other.
> 
> If it's the rpcbind call that succeeds first then I think we want to do
> one more try of nfs4/tcp just to make sure it didn't just come up,
> before falling back to v3.
> 
> The rpcbind call is done in userspace, if I understand right, so I think
> this is doable.  Looking at utils/mount/ I don't understand the mount
> process well enough to understand exactly how to do it.  Maybe
> everything but the final nfs_sys_mount needs to be moved out of
> nfs_do_mount_v3v2 into a new nfs_do_probe_v3v2 and nfs_autonegotiate
> should alternate between nfs_try_mount_v4 and nfs_do_probe_v3v2 as long
> as both return ECONNREFUSED, calling nfs_try_mount_v3v2 only if
> nfs_try_mount_v4 has failed after a succesful nfs_do_probe_v3v2?
> 
> Except the v3v2 mount logic seems to actually modify the mount_options,
> so probably that doesn't quite work.
> 
> ?
> 
> --b.

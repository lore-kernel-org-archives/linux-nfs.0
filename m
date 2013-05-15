Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx5.framestore.com ([193.203.83.15]:46676 "EHLO
	mx5.framestore.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755185Ab3EOOiZ (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 15 May 2013 10:38:25 -0400
Date: Wed, 15 May 2013 15:34:27 +0100 (BST)
From: James Vanns <james.vanns@framestore.com>
Reply-To: james.vanns@framestore.com
To: "J. Bruce Fields" <bfields@fieldses.org>
Cc: Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Message-ID: <1995711958.19982333.1368628467473.JavaMail.root@framestore.com>
In-Reply-To: <20130515141508.GH16811@fieldses.org>
Subject: Re: Where in the server code is fsinfo rtpref calculated?
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


> On Wed, May 15, 2013 at 02:42:42PM +0100, James Vanns wrote:
> > > fs/nfsd/nfssvc.c:nfsd_get_default_maxblksize() is probably a good
> > > starting point.  Its caller, nfsd_create_serv(), calls
> > > svc_create_pooled() with the result that's calculated.
> > 
> > Hmm. If I've read this section of code correctly, it seems to me
> > that on most modern NFS servers (using TCP as the transport) the
> > default
> > and preferred blocksize negotiated with clients will almost always
> > be
> > 1MB - the maximum RPC payload. The nfsd_get_default_maxblksize()
> > function
> > seems obsolete for modern 64-bit servers with at least 4G of RAM as
> > it'll
> > always prefer this upper bound instead of any value calculated
> > according to
> > available RAM.
> 
> Well, "obsolete" is an odd way to put it--the code is still expected
> to work on smaller machines.

Poor choice of words perhaps. I guess I'm just used to NFS servers being
pretty hefty pieces of kit and 'small' workstations having a couple of GB
of RAM too.

> Arguments welcome about the defaults, thoodd ugh I wonder whether it
> would be better to be doing this sort of calculation in user space.

See below.

> > For what it's worth (not sure if I specified this) I'm running
> > kernel 2.6.32.
> > 
> > Anyway, this file/function appears to set the default *max*
> > blocksize. I haven't
> > read all the related code yet, but does the preferred block size
> > derive
> > from this maximum too?
> 
> See
> > > For finfo see fs/nfsd/nfs3proc.c:nfsd3_proc_fsinfo, which uses
> > > svc_max_payload().

I've just returned from nfsd3_proc_fsinfo() and found what I would
consider an odd decision - perhaps nothing better was suggested at
the time. It seems to me that in response to an FSINFO call the reply
stuffs the max_block_size value in  both the maximum *and* preferred
block sizes for both read and write. A 1MB block size for a preferred
default is a little high! If a disk is reading at 33MB/s and we have just
a single server running 64 knfsd and each READ call is requesting 1MB of
data then all of a sudden we have an aggregate read speed of ~512k/s and 
that is without network latencies. And of course we will probably have 100s of
requests queued behind each knfsd waiting for these 512k reads to finish. All of a
sudden our user experience is rather poor :(

Perhaps a better suggestion would be to at least expose the maximum and preferred
block sizes (for both read and write) via a sysctl key so an administrator can set
it to the underlying block sizes of the file system or physical device?

Perhaps the defaults should at least be a smaller multiple of the page size or somewhere
between that and the PDU of the network layer the service is bound too.

Just my tuppence - and my maths might be flawed ;)

Jim

> I'm not sure what the history is behind that logic, though.
> 
> --b.
> 

-- 
Jim Vanns
Senior Software Developer
Framestore

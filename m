Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:59301 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1759940Ab3BMQVE (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 13 Feb 2013 11:21:04 -0500
Date: Wed, 13 Feb 2013 11:20:59 -0500
From: "J. Bruce Fields" <bfields@fieldses.org>
To: "Theodore Ts'o" <tytso@mit.edu>
Cc: linux-ext4@vger.kernel.org, sandeen@redhat.com,
        Bernd Schubert <bernd.schubert@itwm.fraunhofer.de>,
        gluster-devel@nongnu.org, linux-nfs@vger.kernel.org
Subject: Re: regressions due to 64-bit ext4 directory cookies
Message-ID: <20130213162059.GL14195@fieldses.org>
References: <20130212202841.GC10267@fieldses.org>
 <20130213040003.GB2614@thunk.org>
 <20130213133131.GE14195@fieldses.org>
 <20130213151455.GB17431@thunk.org>
 <20130213151953.GJ14195@fieldses.org>
 <20130213153654.GC17431@thunk.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20130213153654.GC17431@thunk.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Oops, probably should have cc'd linux-nfs.

On Wed, Feb 13, 2013 at 10:36:54AM -0500, Theodore Ts'o wrote:
> On Wed, Feb 13, 2013 at 10:19:53AM -0500, J. Bruce Fields wrote:
> > > > (In more detail: they're spreading a single directory across multiple
> > > > nodes, and encoding a node ID into the cookie they return, so they can
> > > > tell which node the cookie came from when they get it back.)
> > > > 
> > > > That works if you assume the cookie is an "offset" bounded above by some
> > > > measure of the directory size, hence unlikely to ever use the high
> > > > bits....
> > > 
> > > Right, but why wouldn't a nfs export option solave the problem for
> > > gluster?
> > 
> > No, gluster is running on ext4 directly.
> 
> OK, so let me see if I can get this straight.  Each local gluster node
> is running a userspace NFS server, right?

My understanding is that only one frontend server is running the server.
So in your picture below, "NFS v3" should be some internal gluster
protocol:


                                                   /------ GFS Storage
                                                  /        Server #1
   GFS Cluster     NFS V3      GFS Cluster      -- gluster protocol
   Client        <--------->   Frontend Server  ---------- GFS Storage
                                                --         Server #2
                                                  \
                                                   \------ GFS Storage
                                                           Server #3
 

That frontend server gets a readdir request for a directory which is
stored across several of the storage servers.  It has to return a
cookie.  It will get that cookie back from the client at some unknown
later time (possibly after the server has rebooted).  So their solution
is to return a cookie from one of the storage servers, plus some kind of
node id in the top bits so they can remember which server it came from.

(I don't know much about gluster, but I think that's the basic idea.)

I've assumed that users of directory cookies should treat them as
opaque, so I don't think what gluster is doing is correct.  But on the
other hand they are defined as integers and described as offsets here
and there.  And I can't actually think of anything else that would work,
short of gluster generating and storing its own cookies.

> Because if it were running
> a kernel-side NFS server, it would be sufficient to use an nfs export
> option.
> 
> A client which mounts a "gluster file system" is also doing this via
> NFSv3, right?  Or are they using their own protocol?  If they are
> using their own protocol, why can't they encode the node ID somewhere
> else?
> 
> So this a correct picture of what is going on:
> 
>                                                   /------ GFS Storage
>                                                  /        Server #1
>   GFS Cluster     NFS V3      GFS Cluster      -- NFS v3
>   Client        <--------->   Frontend Server  ---------- GFS Storage
>                                                --         Server #2
>                                                  \
>                                                   \------ GFS Storage
>                                                           Server #3
> 
> 
> And the reason why it needs to use the high bits is because when it
> needs to coalesce the results from each GFS Storage Server to the GFS
> Cluster client?
> 
> The other thing that I'd note is that the readdir cookie has been
> 64-bit since NFSv3, which was released in June ***1995***.  And the
> explicit, stated purpose of making it be a 64-bit value (as stated in
> RFC 1813) was to reduce interoperability problems.  If that were the
> case, are you telling me that Sun (who has traditionally been pretty
> good worrying about interoperability concerns, and in fact employed
> the editors of RFC 1813) didn't get this right?  This seems
> quite.... surprising to me.
> 
> I thought this was the whole point of the various NFS interoperability
> testing done at Connectathon, for which Sun was a major sponsor?!?  No
> one noticed?!?

Beats me.  But it's not necessarily easy to replace clients running
legacy applications, so we're stuck working with the clients we have....

The linux client does remap the server-provided cookies to small
integers, I believe exactly because older applications had trouble with
servers returning "large" cookies.  So presumably ext4-exporting-Linux
servers aren't the first to do this.

I don't know which client versions are affected--Connectathon's next
week and I'll talk to people and make sure there's an ext4 export with
this turned on to test against.

--b.

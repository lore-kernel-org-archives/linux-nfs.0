From: Ian Kent <raven@themaw.net>
Subject: Re: [NFS] Re: [RFC] Multiple server selection and replicated mount
	failover
Date: Wed, 24 May 2006 21:45:45 +0800
Message-ID: <1148478346.8182.22.camel@raven.themaw.net>
References: <Pine.LNX.4.64.0605021257500.3868@raven.themaw.net>
	 <Pine.LNX.4.64.0605241240200.3730@raven.themaw.net>
	 <44745972.2010305@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: nfs@lists.sourceforge.net,
	linux-fsdevel <linux-fsdevel@vger.kernel.org>,
	autofs mailing list <autofs@linux.kernel.org>
Return-path: <linux-fsdevel-owner@vger.kernel.org>
To: Peter Staubach <staubach@redhat.com>
In-Reply-To: <44745972.2010305@redhat.com>
Sender: linux-fsdevel-owner@vger.kernel.org
List-ID: <nfs.lists.sourceforge.net>

On Wed, 2006-05-24 at 09:02 -0400, Peter Staubach wrote:
> Ian Kent wrote:
> 
> >
> >I've re-written the server selection code now and I believe it works 
> >correctly.
> >
> >  
> >
> >>Apart from mount time server selection read-only replicated servers need 
> >>to be able to fail over to another server if the current one becomes 
> >>unavailable. 
> >>
> >>The questions I have are:
> >>
> >>1) What is the best place for each part of this process to be
> >>   carried out.
> >>   - mount time selection.
> >>   - read-only mount fail over.
> >>    
> >>
> >
> >I think mount time selection should be done in mount and I believe the 
> >failover needs to be done in the kernel against the list established with 
> >the user space selection. The list should only change when a umount 
> >and then a mount occurs (surely this is the only practical way to do it 
> >?).
> >
> >The code that I now have for the selection process can potentially improve 
> >the code used by patches to mount for probing NFS servers and doing this 
> >once in one place has to be better than doing it in automount and mount.
> >
> >The failover is another story.
> >
> >It seems to me that there are two similar ways to do this:
> >
> >1) Pass a list of address and path entries to NFS at mount time and 
> >intercept errors, identify if the host is down and if it is select and 
> >mount another server.
> >
> >2) Mount each member of the list with the best one on top and intercept 
> >errors, identify if the host is down and if it is select another from the 
> >list of mounts and put it atop the mounts. Maintaining the ordering with 
> >this approach could be difficult.
> >
> >With either of these approaches handling open files and held locks appears 
> >to be the the difficult part.
> >
> >Anyone have anything to contribute on how I could handle this or problems 
> >that I will encounter?
> >
> >  
> >
> 
> It seems to me that there is one other way which is similiar to #1 except
> that instead of passing path entries to NFS at mount time, pass in file
> handles.  This keeps all of the MOUNT protocol processing at the user
> level and does not require the kernel to learn anything about the MOUNT
> protocol.  It also allows a reasonable list to be constructed, with
> checking to ensure that all the servers support the same version of the
> NFS protocol, probably that all of the server support the same transport
> protocol, etc.

Of course, like #1 but with the benefits of #2 without the clutter. I
guess all I would have to do then is the vfs mount to make it happen.
Are we assuming a restriction like all the mounts have the same path
exported from the server? mtab could get a little confused.

> 
> >snip ..
> >
> >  
> >
> >>3) Is there any existing work available that anyone is aware
> >>   of that could be used as a reference.
> >>    
> >>
> >
> >Still wondering about this.
> >
> >  
> >
> 
> Well, there is the Solaris support.

But I'm not supposed to peek at that am I (cough, splutter, ...)?

> 
> >>4) How does NFS v4 fit into this picture as I believe that some
> >>   of this functionality is included within the protocol.
> >>    
> >>
> >
> >And this.
> >
> >NFS v4 appears quite different so should I be considering this for v2 and 
> >v3 only?
> >
> >  
> >
> >>Any comments or suggestions or reference code would be very much 
> >>appreciated.
> >>    
> >>
> 
> The Solaris support works by passing a list of structs containing server
> information down into the kernel at mount time.  This makes normal mounting
> just a subset of the replicated support because a normal mount would just
> contain a list of a single entry.

Cool. That's the way the selection code I have works, except for the
kernel bit of course.

> 
> When the Solaris client gets a timeout from an RPC, it checks to see whether
> this file and mount are failover'able.  This checks to see whether there are
> alternate servers in the list and could contain a check to see if there are
> locks existing on the file.  If there are locks, then don't failover.  The
> alternative to doing this is to attempt to move the lock, but this could
> be problematic because there would be no guarantee that the new lock could
> be acquired.

Yep. Failing over the locks looks like it could turn into a nightmare
really fast. Sounds like a good simplifying restriction for a first stab
at this.

> 
> Anyway, if the file is failover'able, then a new server is chosen from the
> list and the file handle associated with the file is remapped to the
> equivalent file on the new server.  This is done by repeating the lookups
> done to get the original file handle.  Once the new file handle is acquired,
> then some minimal checks are done to try to ensure that the files are the
> "same".  This is probably mostly checking to see whether the sizes of the
> two files are the same.
> 
> Please note that this approach contains the interesting aspect that
> files are only failed over when they need to be and are not failed over
> proactively.  This can lead to the situation where processes using the
> the file system can be talking to many of the different underlying
> servers, all at the sametime.  If a server goes down and then comes back
> up before a process, which was talking to that server, notices, then it
> will just continue to use that server, while another process, which
> noticed the failed server, may have failed over to a new server.

Interesting. This hadn't occurred to me yet.

I was still at the stage of wondering whether the "on demand" approach
would work but the simplifying restriction above should make it workable
(I think ....).

> 
> The key ingredient to this approach, I think, is a list of servers and
> information about them, and then information for each active NFS inode
> that keeps track of the pathname used to discover the file handle and
> also the server which is being currently used by the specific file.

Haven't quite got to the path issues yet.
But can't we just get the path from d_path?
It will return the path from a given dentry to the root of the mount, if
I remember correctly, and we have a file handle for the server.

But your talking about the difficulty of the housekeeping overall I
think.
 
>     Thanx...

Thanks for your comments.
Much appreciated and certainly very helpful.

Ian


From: Neil Brown <neilb@suse.de>
Subject: Re: how to cleanly shutdown NFS without risk of hanging.
Date: Fri, 11 Sep 2009 16:44:25 +1000
Message-ID: <19113.61897.442428.663247@notabene.brown>
References: <19108.34796.342633.805371@notabene.brown>
	<1252333108.5172.17.camel@heimdal.trondhjem.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-nfs@vger.kernel.org
To: Trond Myklebust <trond.myklebust@fys.uio.no>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from cantor.suse.de ([195.135.220.2]:41313 "EHLO mx1.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751654AbZIKGn1 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 11 Sep 2009 02:43:27 -0400
In-Reply-To: message from Trond Myklebust on Monday September 7
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Monday September 7, trond.myklebust@fys.uio.no wrote:
> On Mon, 2009-09-07 at 14:11 +1000, Neil Brown wrote:
> > Hi Trond et al
> > 
> > The problem is this:
> >  If I run 'shutdown' while there are mounted NFS filesystems
> >   from servers that are accessible and working, then I want
> >   any last minute changes to be flushed through to the server(s).
> >  If I run 'shutdown' while there are mounted NFS filesystems
> >   but the servers are not accessible, whether because they are dead,
> >   or because I pulled my network cable, or I've walked out of range
> >   of my Wifi access point, then I don't want 'shutdown' to hang
> >   indefinitely, but I want to it complete in a reasonable time.
> > 
> > I don't think meeting both of those goals is currently possible with
> > Linux NFS.
> > 
> > I've been trying to think how to solve it and the only solution that
> > seems at all robust is to somehow switch NFS mounts to 'soft' as part
> > of the shutdown process.  That way things will get flushed if
> > possible, but won't cause umount or sync to hang indefinitely -
> > exactly what I want.
> > 
> > I can see two ways to achieve this.
> > One is to allow "-o remount" to change the soft/hard flag.
> > I think it would be easy enough to change ->cl_softrtry, but
> > setting RPC_TASK_SOFT on each task would be awkward.
> > Maybe we could change RPC_IS_SOFT() to something like:
> >   (((t)->tk_flags & RPC_TASK_SOFT) || (t)->tk_client->cl_softrtry)
> > ??
> > 
> > The other approach with be to introduce some global flag (a sysctl
> > or module parameter??) which forces all tasks to be 'soft'.
> > 
> > The latter would be easier to plug in to the shutdown sequence and
> > would equally apply to filesystems that have already been
> > lazy-unmounted (you cannot remount those filesystems).
> > 
> > The former seems more in keeping with the way things are usually done,
> > but is a little more complex for the shutdown scripts and doesn't help
> > if someone lazy-unmounted a filesystem.
> > 
> > Of course we could do both.
> > 
> > Do you have any thoughts about this before I try implementing
> > something?
> 
> I think that the ability to remount to 'soft', and possibly also to
> change the timeout parameters could be very helpful even in a
> non-shutdown situation.
> 
> The former should be very easy: it wouldn't take much effort to set the
> RPC_TASK_SOFT flag by looping over the 'rpc_client->cl_tasks' list (see
> rpc_killall_tasks()).
> If you want to do this for all RPC clients, then we can do that too.
> That's just a question of looping over the 'all_clients' list and
> applying the above recipe to each rpc_client.
> 
> Changing the timeout parameters on existing tasks might not be possible,
> but we could at least allow the user to change the default timeout on
> the rpc_client...
> 
> Cheers
>   Trond

Thanks.
I had a go at adding support for changing soft, hard, timeo, and
retrans for which I will post patches shortly.

However it doesn't really solve my problem after all.
If the server isn't responding, then both 'mount' and 'mount.nfs' will
try to stat the mountpoint, and mount.nfs will try to talk to the
server to check protocol parameters.
These can be fixed, but then the kernel in do_remount_sb() calls
fsync_super() which will block if the server is down and there is any
dirty data.  I guess that might be fixable too, but it gets ugly.

It might be best to try using "umount -f" which is a lot more useful
now that TASK_KILLABLE exists (I think that is what has made the
difference).

If I:

   mkill -TERM /mount/point
   if umount /mount/point
   then : success
   else
        mkill -KILL /mount/point
        if umount /mount/point
        then : success
        else umount -f /mount/point
        fi
   fi

(mkill is a program is opensuse which kills all processes accessing
 the filesystem without touching the filesystem itself.  It just reads
 /proc/mounts and various symlinks from /proc/[0-9]*/ to find the
 right processes to kill).

Then I think I'll get what I want.  My only concern is that some dirty
data might be left in the page cache after a process is killed.
Is that possible?

I've tried the above and it mostly works, though once I had to
make one more umount attempt.

Maybe I need to put it all in a loop and check if umount
fails due to the filesystem being busy, or due to it not being
mounted...

I wonder if this would be something that should be included in
umount.nfs.  It might be appropriate for umount to kill processes
though. I wonder if it would be ok to add a '-k' flag????

 umount -f -k /mount/point

repeatedly kills processed and tries "umount -f" until it works,
or it has tried hard enough???

I might just do it in a script for now.

Thanks,
NeilBrown



for attempt in 1 2 3
do
   mkill -TERM $mountpoint
   if umount $mountpoint || test $? -ne 16
   then break
   else
        mkill -KILL $mountpoint
        if umount $mountpoint || test $? -ne 16
        then break
        else umount -f $mountpoint
        fi
   fi
done

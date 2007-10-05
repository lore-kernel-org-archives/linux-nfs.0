From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: What's slated for inclusion in 2.6.24-rc1 from the NFS
	client	git tree...
Date: Fri, 05 Oct 2007 13:31:26 -0400
Message-ID: <1191605486.6715.80.camel@heimdal.trondhjem.org>
References: <1191454876.6726.32.camel@heimdal.trondhjem.org>
	<B8C02D2E-BA41-44DB-BB43-2850223927E7@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net
To: Chuck Lever <chuck.lever@oracle.com>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1Idr25-0003zk-Nv
	for nfs@lists.sourceforge.net; Fri, 05 Oct 2007 10:32:13 -0700
Received: from pat.uio.no ([129.240.10.15])
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1Idr29-0008Oy-DK
	for nfs@lists.sourceforge.net; Fri, 05 Oct 2007 10:32:19 -0700
In-Reply-To: <B8C02D2E-BA41-44DB-BB43-2850223927E7@oracle.com>
List-Id: "Discussion of NFS under Linux development, interoperability,
	and testing." <nfs.lists.sourceforge.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=nfs>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
Sender: nfs-bounces@lists.sourceforge.net
Errors-To: nfs-bounces@lists.sourceforge.net

On Thu, 2007-10-04 at 16:16 -0400, Chuck Lever wrote:

> commit 37e582fe2194862ba1924e1c31b081f8c866df29
> Author: Trond Myklebust <Trond.Myklebust@netapp.com>
> Date:   Mon Oct 1 12:06:48 2007 -0400
> 
>      SUNRPC: Don't call xprt_release in call refresh
> 
>      Call it from call_verify() instead...
> 
>      Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
> 
> Can you explain what you are fixing?  Why is it better not to call
> xprt_release() in call_refresh() ?

call_refresh can be called before you ever hit call_transmit. It is
pointless to allocate an XID, then release it _before_ you have used it.


> commit 76d0ee01ff975eaa696d682138927dac40e90856
> Author: Trond Myklebust <Trond.Myklebust@netapp.com>
> Date:   Mon Oct 1 12:06:44 2007 -0400
> 
>      SUNRPC: Don't call xprt_release() if call_allocate fails
> 
>      It completely fouls up the RPC call statistics, and serves no  
> useful
>      purpose.
> 
>      Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
> 
> The xprt_release() is needed because we don't want to tie up a slot  
> in the
> transport's slot table during the rpc_delay() after the RPC buffer
> allocation failed.

Which causes:
      * XID leakage
      * Reordering of the RPC calls
      * breakage of the RPC scheduling priority code

...in addition to adding extra latencies to the particular RPC call that
failed. Most of the calls that require the allocation of large buffers
tend to be _synchronous_ calls, such as LOOKUP, OPEN, LINK, SYMLINK.
Whereas nobody really worries too much about the latency of SYMLINK
calls, an extra latency on LOOKUP can add up to a lot of wasted time.

> Would it make sense to add some conditional processing in
> rpc_count_iostats() that skipped some accounting if tk_status < 0 ?  
> Or by
> adding a boolean argument to xprt_release() that indicates if the RPC  
> should
> be counted or not?  Or by adding a new xprt_release_no_count function  
> that
> doesn't count the RPC request?

Why not instead call xprt_release() only when it is necessary?

> commit 56ad5672426879452eb2a70e9986e59f4d642243
> Author: Trond Myklebust <Trond.Myklebust@netapp.com>
> Date:   Tue Oct 2 23:13:32 2007 -0400
> 
>      NFS: Simplify filehandle revalidation
> 
>      Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
> 
> I think a little more explanation of what's going on here is needed.
> Maybe a sentence or two in the description about why this is not
> going to break CTO?  Are you just fixing a minor oversight?

The patch is clearly _not_ going to break close-to-open cache
consistency. It changes one line immediately after a test that
establishes that we're not doing a lookup for the file that is being
open()ed.

It basically gets rid of a revalidation that was supposed to check if
the filehandle is stale or not, but we've already determined that the
parent directory hasn't changed, so the file hasn't been deleted since
we last revalidated it.

> commit 36fbae45411bebd6876310009336de58e8ef4a9a
> Author: Trond Myklebust <Trond.Myklebust@netapp.com>
> Date:   Tue Oct 2 21:58:05 2007 -0400
> 
>      NFS: Ensure that nfs_link() returns a hashed dentry
> 
>      Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
> 
> Here, the d_drop() and d_add() are explicitly serialized inside  
> nfs_link()
> via the BKL.  I'm focusing on that serialization because it will have  
> some
> effect on my effort to eliminate the BKL from the NFS client.
> 
> For those of us who aren't fluent users of the dentry cache, can you
> elaborate on why the d_drop() is needed in these cases?

We don't know a priori if the dentry is hashed or not. nfs_lookup() may
have optimised away the actual lookup (the VFS will set the
LOOKUP_CREATE and O_EXCL flags), in which case an unhashed negative
dentry is created, and so we need a call to d_add() instead of
d_instantiate().
Alternatively, the user may have actually tried to open or stat the
dentry before creating a link, in which case we would have a hashed
negative dentry on our hands, and so we unhash it before calling
d_add().

> commit bf1dc509161086950c9563c98c62879260eda056
> Author: Trond Myklebust <Trond.Myklebust@netapp.com>
> Date:   Tue Oct 2 19:13:04 2007 -0400
> 
>      NFS: Be strict about dentry revalidation when doing exclusive  
> create
> 
>      Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
> 
> Can you explain why the extra checking is needed for exclusive create?

We shouldn't trust cached values in the case of exclusive create.
Someone may have unlinked the file on the server, in which case we want
the exclusive create to succeed.

> commit 389b68610d592e103936801cc449ef3052008fd6
> Author: Trond Myklebust <Trond.Myklebust@netapp.com>
> Date:   Tue Oct 2 17:11:54 2007 -0400
> 
>      NFS: Remove the redundant nfs_reval_fsid()
> 
>      Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
> 
> I'd like to understand why nfs_reval_fsid() is no longer necessary.  Is
> it because this check is already done by _nfs4_proc_lookup() ?

In NFSv3, the directory fsid has already been revalidated by the lookup
call: the post-op attributes return it.
If we need that kind of revalidation in NFSv4 too (I don't see why the
NFSv4 servers would change their fsid willy-nilly given that the NFSv4
spec says that means you are crossing a mountpoint), then we should add
directory post-op attributes to lookup there too.


> commit defee1455a19a43c4b857b55d46085e107337c17
> Author: Trond Myklebust <Trond.Myklebust@netapp.com>
> Date:   Sat Sep 29 17:34:46 2007 -0400
> 
>      NFS: Remove NFS_I(inode)->data_updates
> 
>      We have no more users...
> 
>      Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
> 
> You have removed nfs_begin_data_update() in this patch... but the  
> next patch
> in the series (commit b322d877bb6a58af6f24930bb5ff6122860d61e1)  
> removes a
> bunch of calls to it.  Are these two patches in reverse order?

Look again. This patch converts nfs_begin_data_update() into an empty
inlined function. The next patch removes it altogether.

> commit 40acc380df81ba07d4cd610107b5479b1edb6055
> Author: Trond Myklebust <Trond.Myklebust@netapp.com>
> Date:   Sat Sep 29 17:25:43 2007 -0400
> 
>      NFS: NFS_CACHEINV() should not test for nfs_caches_unstable()
> 
>      The fact that we're in the process of modifying the inode does  
> not mean
>      that we should not invalidate the attribute and data caches. The  
> defensive
>      thing is to always invalidate when we're confronted with inode
>      mtime/ctime or change_attribute updates that we do not immediately
>      recognise.
> 
>      Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
> 
> Ugh, a triple negative.  I'm having trouble understanding the  
> description
> and figuring out exactly what's going on this patch.

It is getting rid of an invalid assumption. The last sentence above says
it all: we always invalidate the attribute and data caches whenever we
see an mtime/ctime or change_attribute update that we don't recognise as
being ours (i.e. no pre-op attribute matches).

> commit f507133ab0f2369194037ae7842dc0895b979627
> Author: Trond Myklebust <Trond.Myklebust@netapp.com>
> Date:   Mon Oct 1 13:54:51 2007 -0400
> 
>      NFS: Remove bogus nfs_mark_for_revalidate() in nfs_lookup
> 
>      The parent of the newly materialised dentry has just been  
> revalidated...
> 
>      Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
> 
> Is there a way to document the revalidation of the parent?  Where  
> exactly
> does that occur in the nfs_lookup() path?

We just did a LOOKUP from that same parent.

> commit 176c84c19cb7cd7ea1a83a105649b41d18999812
> Author: Trond Myklebust <Trond.Myklebust@netapp.com>
> Date:   Mon Oct 1 10:00:23 2007 -0400
> 
>      NFS: nfs_mark_for_revalidate don't update cache_change_attribute
> 
>      Just let the subsequent inode revalidation do the update...
> 
>      Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
> 
> The short description is ungrammatical.

Don't care as long as it fits on one line and is descriptive.

> commit d2c7da6c1cb184ea79b765eae848b1a2a8910dbf
> Author: Trond Myklebust <Trond.Myklebust@netapp.com>
> Date:   Mon Oct 1 09:59:15 2007 -0400
> 
>      NFS: nfs_post_op_update_inode don't update cache_change_attribute
> 
>      If nfs_post_op_update_inode fails because the server didn't  
> return any
>      attributes, then we let the subsequent inode revalidation update
>      cache_change_attribute.
> 
>      Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
> 
> The short description is ungrammatical.

Don't care as long as it fits on one line and is descriptive.

> commit fb26bdc63b426cfed53e7f1fc89e5113ceb17a5b
> Author: Trond Myklebust <Trond.Myklebust@netapp.com>
> Date:   Mon Oct 1 09:56:59 2007 -0400
> 
>      NFS: Don't revalidate dentries on directory size or ctime changes
> 
>      We only need to look at the mtime changes...
> 
>      Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
> 
> It would be friendly to spell out what's going on here in the patch
> description.

What is missing?

> commit 9dd4607202e6c177cc53035338473db378b98c63
> Author: Trond Myklebust <Trond.Myklebust@netapp.com>
> Date:   Sat Sep 29 17:41:33 2007 -0400
> 
>      NFS: Ensure nfs_instantiate() invalidates the parent dir on error
> 
>      Also ensure that it drops the dentry in this case.
> 
>      Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
> 
> Perhaps a silly question, but since you've added a d_drop(dentry)  
> right at
> the top of nfs_instatiate(), does nfs_instantiate() now rely on some  
> kind of
> external serialization (say, the BKL)?

Nothing has changed. The only serialisation we rely on is the usual one
for operations that modify a directory: the callers _must_ be holding
the directory's i_mutex.

> commit c7a8d8a69d807dc026dc016df11f82380d841118
> Author: Trond Myklebust <Trond.Myklebust@netapp.com>
> Date:   Sat Sep 29 17:14:03 2007 -0400
> 
>      NFS: Fix the sign of the return value of  
> nfs_save_change_attribute()
> 
>      Also fix up the comments.
> 
>      Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
> 
> I would mention that the type of the return value of
> nfs_save_change_attribute() has to match the second parameter of
> nfs_set_verifier().  Otherwise it's not clear why you are changing this.

The return type of nfs_save_change_attribute() should match the type of
the cache_change_attribute that we're reading.

> commit 9cd8d8475b9ecdca1181eb8dc41a00b8cf84b7bd
> Author: Trond Myklebust <Trond.Myklebust@netapp.com>
> Date:   Sun Sep 30 15:21:24 2007 -0400
> 
>      NFS: Fake up 'wcc' attributes to prevent cache invalidation  
> after write
> 
>      NFSv2 and v4 don't offer weak cache consistency attributes on  
> WRITE calls.
>      In NFSv3, returning wcc data is optional. In all cases, we want  
> to prevent
>      the client from invalidating our cached data whenever - 
>  >write_done()
>      attempts to update the inode attributes.
> 
>      Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
> 
> See comment on commit 74994c59a5a1def233c2245c3f7ef23cb01c64ce.
> 
> commit 71d96564928ac2017c97a4555f818397c49c461c
> Author: Trond Myklebust <Trond.Myklebust@netapp.com>
> Date:   Fri Sep 28 19:11:33 2007 -0400
> 
>      NFS: Fix the ESTALE "revalidation" in _nfs_revalidate_inode()
> 
>      For one thing, the test NFS_ATTRTIMEO() == 0 makes no sense: we're
>      testing whether or not the cache timeout length is zero, which  
> is totally
>      unrelated to the issue of whether or not we trust the file  
> staleness.
> 
>      Secondly, we do not want to retry the GETATTR once a file has  
> been declared
>      stale by the server: we rather want to discard that inode as  
> soon as
>      possible, since there are broken servers still in use out there  
> that reuse
>      filehandles on new files.
> 
>      Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
> 
> The NFS_ATTRTIMEO check was made to see if the "noac" or "actimeo=0"  
> mount
> options are in effect.  Basically you are saying that cache revalidation
> should not be different in those cases.

Damned right!

> Do you have test cases for all the crazy things one might do with  
> rsync or
> file restoration that might result in a stale file handle?

Please go back, and read the code and the above comments. Once a _file_
is declared stale, there is no going back! It doesn't matter if you set
'noac' or if you brush your teeth for 2 minutes every morning and night,
we're not going to let you read or write to that inode again.

> commit a03b09537dd935a4efaedb9bdb56f180e71db6bb
> Author: Trond Myklebust <Trond.Myklebust@netapp.com>
> Date:   Fri Sep 28 17:20:07 2007 -0400
> 
>      NFS: Fix atime revalidation in read()
> 
>      NFSv3 will correctly update atime on a read() call, so there is  
> no need to
>      set the NFS_INO_INVALID_ATIME flag unless the call to  
> nfs_refresh_inode()
>      fails.
> 
>      Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
> 
> You say "unless the call to nfs_refresh_inode() fails" but it looks  
> to me
> like you're always setting NFS_INO_INVALID_ATIME for all three protocol
> versions.
> 
> There's also an additional undocumented change in nfs3_read_done:  
> apparently
> the server returns post-op attributes whether or not the READ request  
> failed.
> In a later patch against the NFS lookup path, this change is broken  
> out and
> documented separately.

...and the NFS_INO_INVALID_ATIME flag will therefore be cleared if the
call to nfs_refresh_inode results in an inode update.

> commit ac67b2f0c9bb90389ec925ca5ecc7fd930eaab3b
> Author: Trond Myklebust <Trond.Myklebust@netapp.com>
> Date:   Fri Sep 28 17:11:45 2007 -0400
> 
>      NFS: Fix atime revalidation in readdir()
> 
>      NFSv3 will correctly update atime on a readdir call, so there is  
> no need to
>      set the NFS_INO_INVALID_ATIME flag unless the call to  
> nfs_refresh_inode()
>      fails.
> 
>      Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
> 
> You say "unless the call to nfs_refresh_inode() fails" but it looks  
> to me
> like you're always setting NFS_INO_INVALID_ATIME for all three protocol
> versions.

...and the NFS_INO_INVALID_ATIME flag will therefore be cleared if the
call to nfs_refresh_inode results in an inode update.

> commit adbf11d6638fe8e1a8b3075216efa73b8294f17d
> Author: Trond Myklebust <Trond.Myklebust@netapp.com>
> Date:   Sun Sep 30 18:01:13 2007 -0400
> 
>      NFS: Don't use readdirplus data if the page cache is invalid
> 
>      Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
> 
> Ulp.  Nasty.
> 
> Minor quibble:  the page cache isn't being checked here; rather it's
> the validity of the NFS data cache for the directory in question.  In
> other words, you're checking an NFS attribute cache flag here, not a
> generic VFS data structure.
> 
> Why is the spin lock needed for checking NFS_INO_INVALID_DATA?  What do
> you anticipate is the race condition here?

It is there to ensure that there is a memory barrier between the read of
the verifier (in nfs_save_change_attribute()) and the check for whether
or not the directory's cache is valid.
That again should ensure that even if we later find out that the cache
was invalid, the dentry verifier is correctly labelled with the
directory verifier that was _prior_ to the cache being labelled as
invalid.

> commit a7096362f511f24a47788b332636a992a3518da8
> Author: Trond Myklebust <Trond.Myklebust@netapp.com>
> Date:   Thu Sep 27 15:57:24 2007 -0400
> 
>      NFSv4: Don't use ctime/mtime for determining when to invalidate  
> the caches
> 
>      In NFSv4 we should only be looking at the change attribute.
> 
>      Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
> 
> I know you don't prefer the idea, but I think fs/nfs/inode.c would be  
> made
> much cleaner in the face of these kind of version-related differences if
> there were version-specific copies of nfs_update_inode() and friends.

The behaviour of the code right now depends on the contents of the fattr
struct, rather than any assumptions about what kind of attributes each
NFS version returns. The NFSv4 protocol allows for a lot of choices for
what the fattr may contain.

> commit a6d2ddd5bf668adb1a700104f846ab664b64ea35
> Author: Trond Myklebust <Trond.Myklebust@netapp.com>
> Date:   Thu Sep 27 10:07:31 2007 -0400
> 
>      NFS: Don't force a dcache revalidation if nfs_wcc_update_inode  
> succeeds
> 
>      The reason is that if the weak cache consistency update was  
> successful,
>      then we know that our client must be the only one that changed the
>      directory, and we've already updated the dcache to reflect the  
> change.
> 
>      Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
> 
> It would help me if there was, say, an nfs_force_dcache_reval() function
> that just plugged the current jiffies value into nfsi- 
>  >cache_change_attribute.
> That would clearly document in which cases dcache revalidation was  
> needed,
> instead of just the raw code that shows us saving jiffies in the NFS  
> inode
> for some unknown reason.

That is a cleanup that might make sense.

> commit a289c003c1ec4d6bad69a9d0d0ad4f138f6ba096
> Author: Trond Myklebust <Trond.Myklebust@netapp.com>
> Date:   Sun Sep 30 17:03:25 2007 -0400
> 
>      NFS: nfs_wcc_update_inode: directory caches are always invalidated
> 
>      We must ensure that the readdir data is always invalidated  
> whether or not
>      the weak cache consistency data update succeeds.
> 
>      Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
> 
> What happens if the directory's data cache is not invalidated?  Can you
> explain what bug is being addresses here?  Are there performance
> implications to this change?

Any change in the directory means that our READDIR data needs to get
tossed out. We can't fake up directory entries ourselves.

> commit 93953f229fdf4e8f26c73c596bcca4b386a697f3
> Author: Trond Myklebust <Trond.Myklebust@netapp.com>
> Date:   Fri Sep 28 14:20:12 2007 -0400
> 
>      NFS: fix nfs_verify_change_attribute
> 
>      We always want to check that the verifier and directory
>      cache_change_attribute match. This also allows us to remove the  
> 'wraparound
>      hack' for the cache_change_attribute. If we're only checking for  
> equality,
>      then we don't care about wraparound issues.
> 
>      Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
> 
> Nice clean-up, but can you elucidate why "we always want to check  
> that the
> verifier and directory cache_change_attribute match?"

It is a requirement that we impose. By saving the parent directory's
cache_change_attribute in the dentry->d_time, we're labelling the dentry
as having been revalidated or checked. If ever we see the parent
directory changed in some way that we don't recognise as being due to
our activity, then we change its dir->cache_change_attribute. Every time
a dentry is presented to nfs_lookup_revalidate(), we can then compare
the dentry->d_time to the dir->cache_change_attribute for equality in
order to test whether or not it was revalidated since the last change.

> commit 74994c59a5a1def233c2245c3f7ef23cb01c64ce
> Author: Trond Myklebust <Trond.Myklebust@netapp.com>
> Date:   Wed Aug 15 12:59:12 2007 -0400
> 
>      NFS: nfs_post_op_update_inode() should call nfs_refresh_inode()
> 
>      Ensure that we don't clobber the results from a more recent  
> getattr call...
> 
>      Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
> 
> I notice that block comments in front of nfs_refresh_inode,
> nfs_post_op_update_inode, and nfs_post_op_update_inode_force_wcc all  
> claim
> that these functions "try to update the inode attribute cache".  IMO the
> block comments do not help the reader understand how each of these is
> different.  In other words they don't explain why we need three of  
> these.

They differ in the circumstances of use. nfs_refresh_inode simply says
that I should check and/or update the inode attributes assuming that my
fattr is not empty.

nfs_post_op_update_inode says that I should call nfs_refresh_inode, or
invalidate my inode's attribute cache if the fattr is empty. It will
normally be called if I know for certain that an RPC call I just made
has changed the inode.

nfs_post_op_update_inode_force_wcc is a variant on
nfs_post_op_update_inode that was specifically made for the case of
writes because they often involve multiple simultaneous updates of the
inode that break the weak cache consistency model because the replies
from the server may be handled in a different order to the update order
on the server.

> commit f0b280597f7967c68356c396673ea645228eb2c6
> Author: Trond Myklebust <Trond.Myklebust@netapp.com>
> Date:   Wed Aug 15 12:49:17 2007 -0400
> 
>      NFS: Fix over-conservative attribute invalidation in  
> nfs_update_inode()
> 
>      We should always be declaring the attribute cache as valid after  
> having
>      updated it.
> 
>      Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
> 
> Can you explain in your description why it is now considered safe to
> ignore outstanding updates while updating an inode's cached attributes?
> Does this change prevent an extra GETATTR request after a series of
> overlapping async writes?

It is not safe to 'ignore outstanding updates'. All this says is that if
I just updated the inode, then I'm reasonably sure that the attributes
are valid.

Trond


-------------------------------------------------------------------------
This SF.net email is sponsored by: Splunk Inc.
Still grepping through log files to find problems?  Stop.
Now Search log events and configuration files using AJAX and a browser.
Download your FREE copy of Splunk now >> http://get.splunk.com/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs

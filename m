From: Chuck Lever <chuck.lever@oracle.com>
Subject: Re: What's slated for inclusion in 2.6.24-rc1 from the NFS
	client git tree...
Date: Thu, 4 Oct 2007 16:16:22 -0400
Message-ID: <B8C02D2E-BA41-44DB-BB43-2850223927E7@oracle.com>
References: <1191454876.6726.32.camel@heimdal.trondhjem.org>
Mime-Version: 1.0 (Apple Message framework v752.2)
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net
To: Trond Myklebust <trond.myklebust@fys.uio.no>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1IdX9V-0000EP-Jo
	for nfs@lists.sourceforge.net; Thu, 04 Oct 2007 13:18:34 -0700
Received: from rgminet01.oracle.com ([148.87.113.118])
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1IdX9Y-0008Lm-Ug
	for nfs@lists.sourceforge.net; Thu, 04 Oct 2007 13:18:38 -0700
In-Reply-To: <1191454876.6726.32.camel@heimdal.trondhjem.org>
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

[ Trimming the cc: list... ]

On Oct 3, 2007, at 7:41 PM, Trond Myklebust wrote:
> Aside from the usual updates from Chuck for NFS-over-IPv6 (still
> incomplete) and a number of bugfixes for the text-based mount code,  
> the
> main news in the NFS tree is the merging of support for the NFS/RDMA
> client code from Tom Talpey and the NetApp New England (NANE) team.
>
> We also have the 64-bit inode support from RedHat/Peter Staubach.
>
> There is also the addition of a nfs_vm_page_mkwrite() method in  
> order to
> clean up the mmap() write code.
> Finally, I've been working on a number of updates for the attribute
> revalidation, having pulled apart most of the dentry and attribute
> revalidation into separate variables. A number of fixes that address
> existing bugs fell out of that review, which should hopefully  
> result in
> more efficient dcache behaviour...
>
> The NFS client git tree can be found at
>
>    git://git.linux-nfs.org/pub/linux/nfs-2.6.git
>
> or on gitweb at
>
>   http://linux-nfs.org/cgi-bin/gitweb.cgi?p=nfs-2.6.git;a=summary
>
> Finally, a full set of patches may be found on
>
>   http://client.linux-nfs.org/Linux-2.6.x/2.6.23-rc9/

This is a massive effort...  boo-yah!

I downloaded this latest set of patches and browsed through them  
today in order to get a sense of how my BKL and IPv6 patch sets will  
need to be adapted for 2.6.24.  I've already reviewed Mr. Talpey's  
patches, so I focused mainly on patches I hadn't seen already.

There are some patches I don't include here, either because I didn't  
find any issues with them, or because I'm not smart enough to  
understand exactly what they are changing.  Here are my comments in  
"git log" order (so you should start from the bottom of this email at  
the oldest change).


commit 37e582fe2194862ba1924e1c31b081f8c866df29
Author: Trond Myklebust <Trond.Myklebust@netapp.com>
Date:   Mon Oct 1 12:06:48 2007 -0400

     SUNRPC: Don't call xprt_release in call refresh

     Call it from call_verify() instead...

     Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

Can you explain what you are fixing?  Why is it better not to call
xprt_release() in call_refresh() ?

commit 76d0ee01ff975eaa696d682138927dac40e90856
Author: Trond Myklebust <Trond.Myklebust@netapp.com>
Date:   Mon Oct 1 12:06:44 2007 -0400

     SUNRPC: Don't call xprt_release() if call_allocate fails

     It completely fouls up the RPC call statistics, and serves no  
useful
     purpose.

     Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

The xprt_release() is needed because we don't want to tie up a slot  
in the
transport's slot table during the rpc_delay() after the RPC buffer
allocation failed.

Would it make sense to add some conditional processing in
rpc_count_iostats() that skipped some accounting if tk_status < 0 ?  
Or by
adding a boolean argument to xprt_release() that indicates if the RPC  
should
be counted or not?  Or by adding a new xprt_release_no_count function  
that
doesn't count the RPC request?

commit 373352e2c1de96e2db27201e191ce21fb459bbd7
Author: Trond Myklebust <Trond.Myklebust@netapp.com>
Date:   Mon Oct 1 11:43:37 2007 -0400

     SUNRPC: Fix buggy UDP transmission

     xs_sendpages() may return a negative result. We sure as hell  
don't want to
     add that to the 'tk_bytes_sent' tally...

     Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

Heh.  Oops.

commit 56ad5672426879452eb2a70e9986e59f4d642243
Author: Trond Myklebust <Trond.Myklebust@netapp.com>
Date:   Tue Oct 2 23:13:32 2007 -0400

     NFS: Simplify filehandle revalidation

     Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

I think a little more explanation of what's going on here is needed.
Maybe a sentence or two in the description about why this is not
going to break CTO?  Are you just fixing a minor oversight?

commit 36fbae45411bebd6876310009336de58e8ef4a9a
Author: Trond Myklebust <Trond.Myklebust@netapp.com>
Date:   Tue Oct 2 21:58:05 2007 -0400

     NFS: Ensure that nfs_link() returns a hashed dentry

     Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

Here, the d_drop() and d_add() are explicitly serialized inside  
nfs_link()
via the BKL.  I'm focusing on that serialization because it will have  
some
effect on my effort to eliminate the BKL from the NFS client.

For those of us who aren't fluent users of the dentry cache, can you
elaborate on why the d_drop() is needed in these cases?

commit bf1dc509161086950c9563c98c62879260eda056
Author: Trond Myklebust <Trond.Myklebust@netapp.com>
Date:   Tue Oct 2 19:13:04 2007 -0400

     NFS: Be strict about dentry revalidation when doing exclusive  
create

     Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

Can you explain why the extra checking is needed for exclusive create?

commit 92f82103b37c9a6e8a4246de85ff909d734b77c6
Author: Trond Myklebust <Trond.Myklebust@netapp.com>
Date:   Tue Oct 2 19:02:07 2007 -0400

     NFS: Don't zap the readdir caches upon error

     If necessary, the caches will get zapped under normal revalidation.

     Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

Again, to be clear, you're using the NFS attribute cache flags to detect
out-of-date page cache data, rather than using the generic VFS support,
for directories.  Seems reasonable.

commit 389b68610d592e103936801cc449ef3052008fd6
Author: Trond Myklebust <Trond.Myklebust@netapp.com>
Date:   Tue Oct 2 17:11:54 2007 -0400

     NFS: Remove the redundant nfs_reval_fsid()

     Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

I'd like to understand why nfs_reval_fsid() is no longer necessary.  Is
it because this check is already done by _nfs4_proc_lookup() ?

commit b322d877bb6a58af6f24930bb5ff6122860d61e1
Author: Trond Myklebust <Trond.Myklebust@netapp.com>
Date:   Sat Sep 29 17:48:19 2007 -0400

     NFS: Remove nfs_begin_data_update/nfs_end_data_update

     The lower level routines in fs/nfs/proc.c, fs/nfs/nfs3proc.c and
     fs/nfs/nfs4proc.c should already be dealing with the  
revalidation issues.

     Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit defee1455a19a43c4b857b55d46085e107337c17
Author: Trond Myklebust <Trond.Myklebust@netapp.com>
Date:   Sat Sep 29 17:34:46 2007 -0400

     NFS: Remove NFS_I(inode)->data_updates

     We have no more users...

     Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

You have removed nfs_begin_data_update() in this patch... but the  
next patch
in the series (commit b322d877bb6a58af6f24930bb5ff6122860d61e1)  
removes a
bunch of calls to it.  Are these two patches in reverse order?

commit 40acc380df81ba07d4cd610107b5479b1edb6055
Author: Trond Myklebust <Trond.Myklebust@netapp.com>
Date:   Sat Sep 29 17:25:43 2007 -0400

     NFS: NFS_CACHEINV() should not test for nfs_caches_unstable()

     The fact that we're in the process of modifying the inode does  
not mean
     that we should not invalidate the attribute and data caches. The  
defensive
     thing is to always invalidate when we're confronted with inode
     mtime/ctime or change_attribute updates that we do not immediately
     recognise.

     Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

Ugh, a triple negative.  I'm having trouble understanding the  
description
and figuring out exactly what's going on this patch.

commit f507133ab0f2369194037ae7842dc0895b979627
Author: Trond Myklebust <Trond.Myklebust@netapp.com>
Date:   Mon Oct 1 13:54:51 2007 -0400

     NFS: Remove bogus nfs_mark_for_revalidate() in nfs_lookup

     The parent of the newly materialised dentry has just been  
revalidated...

     Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

Is there a way to document the revalidation of the parent?  Where  
exactly
does that occur in the nfs_lookup() path?

commit 176c84c19cb7cd7ea1a83a105649b41d18999812
Author: Trond Myklebust <Trond.Myklebust@netapp.com>
Date:   Mon Oct 1 10:00:23 2007 -0400

     NFS: nfs_mark_for_revalidate don't update cache_change_attribute

     Just let the subsequent inode revalidation do the update...

     Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

The short description is ungrammatical.

commit d2c7da6c1cb184ea79b765eae848b1a2a8910dbf
Author: Trond Myklebust <Trond.Myklebust@netapp.com>
Date:   Mon Oct 1 09:59:15 2007 -0400

     NFS: nfs_post_op_update_inode don't update cache_change_attribute

     If nfs_post_op_update_inode fails because the server didn't  
return any
     attributes, then we let the subsequent inode revalidation update
     cache_change_attribute.

     Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

The short description is ungrammatical.

commit fb26bdc63b426cfed53e7f1fc89e5113ceb17a5b
Author: Trond Myklebust <Trond.Myklebust@netapp.com>
Date:   Mon Oct 1 09:56:59 2007 -0400

     NFS: Don't revalidate dentries on directory size or ctime changes

     We only need to look at the mtime changes...

     Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

It would be friendly to spell out what's going on here in the patch
description.

commit 9dd4607202e6c177cc53035338473db378b98c63
Author: Trond Myklebust <Trond.Myklebust@netapp.com>
Date:   Sat Sep 29 17:41:33 2007 -0400

     NFS: Ensure nfs_instantiate() invalidates the parent dir on error

     Also ensure that it drops the dentry in this case.

     Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

Perhaps a silly question, but since you've added a d_drop(dentry)  
right at
the top of nfs_instatiate(), does nfs_instantiate() now rely on some  
kind of
external serialization (say, the BKL)?

commit c7a8d8a69d807dc026dc016df11f82380d841118
Author: Trond Myklebust <Trond.Myklebust@netapp.com>
Date:   Sat Sep 29 17:14:03 2007 -0400

     NFS: Fix the sign of the return value of  
nfs_save_change_attribute()

     Also fix up the comments.

     Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

I would mention that the type of the return value of
nfs_save_change_attribute() has to match the second parameter of
nfs_set_verifier().  Otherwise it's not clear why you are changing this.

commit 9cd8d8475b9ecdca1181eb8dc41a00b8cf84b7bd
Author: Trond Myklebust <Trond.Myklebust@netapp.com>
Date:   Sun Sep 30 15:21:24 2007 -0400

     NFS: Fake up 'wcc' attributes to prevent cache invalidation  
after write

     NFSv2 and v4 don't offer weak cache consistency attributes on  
WRITE calls.
     In NFSv3, returning wcc data is optional. In all cases, we want  
to prevent
     the client from invalidating our cached data whenever - 
 >write_done()
     attempts to update the inode attributes.

     Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

See comment on commit 74994c59a5a1def233c2245c3f7ef23cb01c64ce.

commit 71d96564928ac2017c97a4555f818397c49c461c
Author: Trond Myklebust <Trond.Myklebust@netapp.com>
Date:   Fri Sep 28 19:11:33 2007 -0400

     NFS: Fix the ESTALE "revalidation" in _nfs_revalidate_inode()

     For one thing, the test NFS_ATTRTIMEO() == 0 makes no sense: we're
     testing whether or not the cache timeout length is zero, which  
is totally
     unrelated to the issue of whether or not we trust the file  
staleness.

     Secondly, we do not want to retry the GETATTR once a file has  
been declared
     stale by the server: we rather want to discard that inode as  
soon as
     possible, since there are broken servers still in use out there  
that reuse
     filehandles on new files.

     Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

The NFS_ATTRTIMEO check was made to see if the "noac" or "actimeo=0"  
mount
options are in effect.  Basically you are saying that cache revalidation
should not be different in those cases.

Do you have test cases for all the crazy things one might do with  
rsync or
file restoration that might result in a stale file handle?

commit a03b09537dd935a4efaedb9bdb56f180e71db6bb
Author: Trond Myklebust <Trond.Myklebust@netapp.com>
Date:   Fri Sep 28 17:20:07 2007 -0400

     NFS: Fix atime revalidation in read()

     NFSv3 will correctly update atime on a read() call, so there is  
no need to
     set the NFS_INO_INVALID_ATIME flag unless the call to  
nfs_refresh_inode()
     fails.

     Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

You say "unless the call to nfs_refresh_inode() fails" but it looks  
to me
like you're always setting NFS_INO_INVALID_ATIME for all three protocol
versions.

There's also an additional undocumented change in nfs3_read_done:  
apparently
the server returns post-op attributes whether or not the READ request  
failed.
In a later patch against the NFS lookup path, this change is broken  
out and
documented separately.

commit ac67b2f0c9bb90389ec925ca5ecc7fd930eaab3b
Author: Trond Myklebust <Trond.Myklebust@netapp.com>
Date:   Fri Sep 28 17:11:45 2007 -0400

     NFS: Fix atime revalidation in readdir()

     NFSv3 will correctly update atime on a readdir call, so there is  
no need to
     set the NFS_INO_INVALID_ATIME flag unless the call to  
nfs_refresh_inode()
     fails.

     Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

You say "unless the call to nfs_refresh_inode() fails" but it looks  
to me
like you're always setting NFS_INO_INVALID_ATIME for all three protocol
versions.

commit adbf11d6638fe8e1a8b3075216efa73b8294f17d
Author: Trond Myklebust <Trond.Myklebust@netapp.com>
Date:   Sun Sep 30 18:01:13 2007 -0400

     NFS: Don't use readdirplus data if the page cache is invalid

     Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

Ulp.  Nasty.

Minor quibble:  the page cache isn't being checked here; rather it's
the validity of the NFS data cache for the directory in question.  In
other words, you're checking an NFS attribute cache flag here, not a
generic VFS data structure.

Why is the spin lock needed for checking NFS_INO_INVALID_DATA?  What do
you anticipate is the race condition here?

commit a7096362f511f24a47788b332636a992a3518da8
Author: Trond Myklebust <Trond.Myklebust@netapp.com>
Date:   Thu Sep 27 15:57:24 2007 -0400

     NFSv4: Don't use ctime/mtime for determining when to invalidate  
the caches

     In NFSv4 we should only be looking at the change attribute.

     Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

I know you don't prefer the idea, but I think fs/nfs/inode.c would be  
made
much cleaner in the face of these kind of version-related differences if
there were version-specific copies of nfs_update_inode() and friends.

commit a6d2ddd5bf668adb1a700104f846ab664b64ea35
Author: Trond Myklebust <Trond.Myklebust@netapp.com>
Date:   Thu Sep 27 10:07:31 2007 -0400

     NFS: Don't force a dcache revalidation if nfs_wcc_update_inode  
succeeds

     The reason is that if the weak cache consistency update was  
successful,
     then we know that our client must be the only one that changed the
     directory, and we've already updated the dcache to reflect the  
change.

     Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

It would help me if there was, say, an nfs_force_dcache_reval() function
that just plugged the current jiffies value into nfsi- 
 >cache_change_attribute.
That would clearly document in which cases dcache revalidation was  
needed,
instead of just the raw code that shows us saving jiffies in the NFS  
inode
for some unknown reason.

commit a289c003c1ec4d6bad69a9d0d0ad4f138f6ba096
Author: Trond Myklebust <Trond.Myklebust@netapp.com>
Date:   Sun Sep 30 17:03:25 2007 -0400

     NFS: nfs_wcc_update_inode: directory caches are always invalidated

     We must ensure that the readdir data is always invalidated  
whether or not
     the weak cache consistency data update succeeds.

     Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

What happens if the directory's data cache is not invalidated?  Can you
explain what bug is being addresses here?  Are there performance
implications to this change?

commit 93953f229fdf4e8f26c73c596bcca4b386a697f3
Author: Trond Myklebust <Trond.Myklebust@netapp.com>
Date:   Fri Sep 28 14:20:12 2007 -0400

     NFS: fix nfs_verify_change_attribute

     We always want to check that the verifier and directory
     cache_change_attribute match. This also allows us to remove the  
'wraparound
     hack' for the cache_change_attribute. If we're only checking for  
equality,
     then we don't care about wraparound issues.

     Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

Nice clean-up, but can you elucidate why "we always want to check  
that the
verifier and directory cache_change_attribute match?"

commit 74994c59a5a1def233c2245c3f7ef23cb01c64ce
Author: Trond Myklebust <Trond.Myklebust@netapp.com>
Date:   Wed Aug 15 12:59:12 2007 -0400

     NFS: nfs_post_op_update_inode() should call nfs_refresh_inode()

     Ensure that we don't clobber the results from a more recent  
getattr call...

     Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

I notice that block comments in front of nfs_refresh_inode,
nfs_post_op_update_inode, and nfs_post_op_update_inode_force_wcc all  
claim
that these functions "try to update the inode attribute cache".  IMO the
block comments do not help the reader understand how each of these is
different.  In other words they don't explain why we need three of  
these.

commit f0b280597f7967c68356c396673ea645228eb2c6
Author: Trond Myklebust <Trond.Myklebust@netapp.com>
Date:   Wed Aug 15 12:49:17 2007 -0400

     NFS: Fix over-conservative attribute invalidation in  
nfs_update_inode()

     We should always be declaring the attribute cache as valid after  
having
     updated it.

     Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

Can you explain in your description why it is now considered safe to
ignore outstanding updates while updating an inode's cached attributes?
Does this change prevent an extra GETATTR request after a series of
overlapping async writes?

--
Chuck Lever
chuck[dot]lever[at]oracle[dot]com




-------------------------------------------------------------------------
This SF.net email is sponsored by: Splunk Inc.
Still grepping through log files to find problems?  Stop.
Now Search log events and configuration files using AJAX and a browser.
Download your FREE copy of Splunk now >> http://get.splunk.com/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs

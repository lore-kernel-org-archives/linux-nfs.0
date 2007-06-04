From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: Passing sec info to security modules when mounting an FS
Date: Mon, 04 Jun 2007 10:47:11 -0400
Message-ID: <1180968431.17737.26.camel@heimdal.trondhjem.org>
References: <1180739989.3931.47.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: hch@infradead.org, nfs@lists.sourceforge.net,
	viro@zeniv.linux.org.uk, selinux@tycho.nsa.gov, sds@tycho.nsa.gov
To: Eric Paris <eparis@redhat.com>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1HvDqK-00017Z-J4
	for nfs@lists.sourceforge.net; Mon, 04 Jun 2007 07:47:38 -0700
Received: from pat.uio.no ([129.240.10.15]
	ident=[U2FsdGVkX1+GL66NWotu0/TPKZBBqIsPQQKWO6OMlmo=])
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1HvDqL-0000lp-96
	for nfs@lists.sourceforge.net; Mon, 04 Jun 2007 07:47:39 -0700
In-Reply-To: <1180739989.3931.47.camel@localhost.localdomain>
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

On Fri, 2007-06-01 at 19:19 -0400, Eric Paris wrote:
> A while back I posted a (ugly) patch trying to address a quirk found
> dealing with NFS and it's use of binary mount data.
> 
> http://marc.info/?l=linux-nfs&m=117856053112297&w=2
> 
> The answer was LSM modules/SELinux 'stop trying to read NFS's binary
> mount data.'  So now I'm working on a real long term solution to the
> problem.
> 
> A two second overview of how this work now.  With binary mount data,
> SELinux checks if the FS is NFS and if so inside try_context_mount() it
> casts the data to a nfs_mount_data and then grabs the security context
> from the data->context field added in version 6 of the nfs_mount_data.
> Its being doing that for quite some time now.  For any FS which has
> binary mount data other than NFS it is impossible to pass security
> relevant information to the SELinux.  For text mount options selinux
> walks the string, copies all of the relevant options (context=,
> fscontext=, defcontext=, rootcontext=) to a new page and then inside
> try_context_mount() uses those options.
> 
> Since everyone seemed to agree that having selinux grab the context out
> of the binary data was the wrong way to do things it appears that
> filesystems like NFS, which have binary mount data, are going to need a
> way to pass the security information contained in that mount data
> through the VFS to get it to the LSM hooks.  I figure we can add a new
> vfs_kern_mount_secdata() which takes as a argument a string which
> contains all of the relevant security information.  This string can then
> be passed right on down into the security modules and we can eliminate
> the NFS specific handling of the mount data in the selinux code.
> 
> The first problem with this right now is that the SELinux parser is
> expecting to get full mount options like context=user_u:role_r:type_t
> but the NFS code (somewhere I haven't figure out where yet) is
> manipulating the security string and taking the context=blah and
> stripping the first part of the string and only storing the part after
> the =.  Which means that now something is going to have to change how
> the security options are being handled.  I can see this being done a
> couple of places
> 
> ?the nfs code - can just store the full text string it got in userspace
> and pass it along.  Other binary mount data FS's could do the same
> thing.  (I think this is the best option)
> 
> ?the nfs code - can just append context= onto the front of the string
> before it calls into the new vfs_kern_mount_secdata() function, seems
> like this is not the place to add some selinux specific text
> manipulation, but then again, nfs decided to pull that part of the
> string off, why can't it put it back?
> 
> ?the vfs to a new LSM hook - create some new hook which verifys the data
> and can manipulate it if needed before it is passed to the real LSM
> hook?  (ok this is a terrible idea)
> 
> ?extra flags being passed down to the original security_sb_kern_mount
> hook - if we pass extra flags down the security_sb_kern_mount to say
> this came from a binary mount then the selinux code could deal with all
> of the special casing itself.
> 
> ?no extra flags and selinux code can just assume what is meant when it
> gets a string without one of the tokens it recognizes.  Right now we
> catch those errors and bomb out, but I haven't ever seen the printk...
> 
> Personally I think the 'fix' should be to store the full string in the
> data->context field of the nfs data instead of making the NFS chain
> parse and manipulate the string.  If others in the NFS world agree to
> this solution can you give me pointers to where the context= part of the
> mount options got pulled off?   Is that in userspace?
> 
> It also is a bit of a change in meaning for the ->context field.  It no
> longer would be just a selinux context and would instead be a 'security
> string' which could contain all of the possible options someday and
> would get parsed correctly.
> 
> I also heard that NFS was going to go to a text mount option in the
> future and maybe for such a corner case of a problem (remember that link
> way back at the top) we could just ignore all of this until that
> happens.  If so I think all of the problem would go away since selinux
> can just find its options from the text string like every other FS
> already does.  In the meantime maybe people would be agreeable to a
> nasty hack inside the SELinux code (something like changing the nfs
> specific check in try_context_mount to (d->version <  NFS_MOUNT_VERSION)
> && (d->version < 0xc00000000) to get the same result as my previous hack
> in the other patch but realize that d->version might actually be a
> pointer to a kernel data structure rather than to a version field)

No. The change to a text based mount option changes _nothing_. Firstly,
we still have to keep a backward-compatibility layer in order to deal
with old copies of the "mount" utility. Secondly, I expect that we will
still be using binary interfaces when doing internal submounts such as
when we cross over a remote filesystem boundary and/or when we encounter
an NFSv4 referral.

The correct thing here is to allow NFS to parse its own mount options,
then have the parser call a security function with the context string
and the vfsmount (or superblock) as the only arguments.
If selinux requires the string to be stored then it should be
responsible for managing that memory (i.e. for calling kstrdup() and
kfree() at mount/umount).

Cheers
  Trond


-------------------------------------------------------------------------
This SF.net email is sponsored by DB2 Express
Download DB2 Express C - the FREE version of DB2 express and take
control of your XML. No limits. Just data. Click to get it now.
http://sourceforge.net/powerbar/db2/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs

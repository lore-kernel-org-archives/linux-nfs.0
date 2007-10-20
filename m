From: Erez Zadok <ezk@cs.sunysb.edu>
Subject: Re: nfsv2 ref leak in 2.6.24?
Date: Sat, 20 Oct 2007 15:04:39 -0400
Message-ID: <200710201904.l9KJ4d4Z019993@agora.fsl.cs.sunysb.edu>
References: <1192900351.7440.6.camel@heimdal.trondhjem.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: bfields@fieldses.org, neilb@suse.de,
	Erez Zadok <ezk@cs.sunysb.edu>, nfs@lists.sourceforge.net,
	linux-kernel@vger.kernel.org
To: Trond Myklebust <trond.myklebust@fys.uio.no>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1IjJcz-0000EH-V6
	for nfs@lists.sourceforge.net; Sat, 20 Oct 2007 12:04:54 -0700
Received: from filer.fsl.cs.sunysb.edu ([130.245.126.2])
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1IjJd5-0000wH-1F
	for nfs@lists.sourceforge.net; Sat, 20 Oct 2007 12:04:59 -0700
In-reply-to: Your message of "Sat, 20 Oct 2007 13:12:31 EDT."
	<1192900351.7440.6.camel@heimdal.trondhjem.org>
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

In message <1192900351.7440.6.camel@heimdal.trondhjem.org>, Trond Myklebust writes:
> 
> On Fri, 2007-10-19 at 22:33 -0400, Erez Zadok wrote:
> > Trond, good news.  I was able to narrow down the problem to purely the
> > client-side, probably dcache/readdir related, and I have a shell script that
> > deterministically triggers the problem each time for me (this is a FC6 image
> > under Vmware 6.0.1).  Here's a short shell script which reliably triggers
> > the "lost files" problem -- I create a file via nfs2 on the client side, and
> > sometimes it doesn't show up in readdir, but it is there if you stat it
> > directly.
> 
> Ah... I got confused as to what you were measuring and where.

Yeah, I wasn't sure myself until I narrowed it down to a small test case.

> Looking at
> nfs_proc_create(), there is indeed a missing call to
> nfs_mark_for_revalidate(). The reason why you need such a call being the
> usual one: NFSv2 doesn't provide post-op attributes for the directory.
> 
> The patch below ought to fix the problem.

It fixes some, but breaks others.  The test script I sent yesterday indeed
passes.  And more of my unionfs-on-nfs2 tests pass, but not all.  Three of
my unionfs tests (create w/ copyup, unlink open files, and unlink with a
whiteout) fail b/c they detect leftover silly-renamed files.  Worse, now the
same three tests also fail when I use unionfs on top of nfs3/nfs4: before
the one line fix below, unionfs-on-nfsv3/4 worked fine.

Was there any significant semantic change in the behaviour of silly-renamed
files in nfs in 2.6.24?  If so, then I may have to change how unionfs
handles refcounts and such.

I'll try to dig deeper and see if I can come up with a small test case that
doesn't involve unionfs.

Thanks,
Erez.

> Cheers
>   Trond
> ---------------------- CUT HERE -----------------------
> From: Trond Myklebust <Trond.Myklebust@netapp.com>
> Date: Sat, 20 Oct 2007 13:07:21 -0400
> NFSv2: Ensure that the directory metadata gets revalidated on file create
> 
> Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
> ---
> 
>  fs/nfs/proc.c |    1 +
>  1 files changed, 1 insertions(+), 0 deletions(-)
> 
> diff --git a/fs/nfs/proc.c b/fs/nfs/proc.c
> index 97669ed..4f80d88 100644
> --- a/fs/nfs/proc.c
> +++ b/fs/nfs/proc.c
> @@ -211,6 +211,7 @@ nfs_proc_create(struct inode *dir, struct dentry *dentry, struct iattr *sattr,
>  	nfs_fattr_init(&fattr);
>  	dprintk("NFS call  create %s\n", dentry->d_name.name);
>  	status = rpc_call_sync(NFS_CLIENT(dir), &msg, 0);
> +	nfs_mark_for_revalidate(dir);
>  	if (status == 0)
>  		status = nfs_instantiate(dentry, &fhandle, &fattr);
>  	dprintk("NFS reply create: %d\n", status);

Erez.

-------------------------------------------------------------------------
This SF.net email is sponsored by: Splunk Inc.
Still grepping through log files to find problems?  Stop.
Now Search log events and configuration files using AJAX and a browser.
Download your FREE copy of Splunk now >> http://get.splunk.com/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs

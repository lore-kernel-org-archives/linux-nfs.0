From: "Chuck Lever" <chucklever@gmail.com>
Subject: Re: [Fwd: Re: [Patch] Possible dereference in
	fs/nfsd/nfs4callback.c]
Date: Tue, 26 Sep 2006 15:37:35 -0400
Message-ID: <76bd70e30609261237v72fe65fbuab72b27eae0b24f9@mail.gmail.com>
References: <451962BD.6050909@oracle.com>
	<76bd70e30609261036l111274er219db13a336c1164@mail.gmail.com>
	<1159296937.5492.15.camel@lade.trondhjem.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: Eric Sesterhenn / Snakebyte <snakebyte@gmx.de>,
	Linux NFS Mailing List <nfs@lists.sourceforge.net>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1GSIkK-0001Td-Qi
	for nfs@lists.sourceforge.net; Tue, 26 Sep 2006 12:37:36 -0700
Received: from wx-out-0506.google.com ([66.249.82.227])
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1GSIkL-0005nr-CY
	for nfs@lists.sourceforge.net; Tue, 26 Sep 2006 12:37:37 -0700
Received: by wx-out-0506.google.com with SMTP id r21so2805159wxc
	for <nfs@lists.sourceforge.net>; Tue, 26 Sep 2006 12:37:36 -0700 (PDT)
To: "Trond Myklebust" <trond.myklebust@fys.uio.no>
In-Reply-To: <1159296937.5492.15.camel@lade.trondhjem.org>
List-Id: "Discussion of NFS under Linux development, interoperability,
	and testing." <nfs.lists.sourceforge.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=nfs>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
Sender: nfs-bounces@lists.sourceforge.net
Errors-To: nfs-bounces@lists.sourceforge.net

Some comments below.

On 9/26/06, Trond Myklebust <trond.myklebust@fys.uio.no> wrote:
> > #cid 1373  base/src/linux-2.6/fs/nfs/inode.c
> >
> > 568     __nfs_revalidate_inode(struct nfs_server *server, struct inode
> > *inode)
> > 569     {
> > 570             int              status = -ESTALE;
> > 571             struct nfs_fattr fattr;
> > 572             struct nfs_inode *nfsi = NFS_I(inode);
> > 573
> >
> > Event deref_ptr: Directly dereferenced pointer "inode"
> > Also see events: [check_after_deref]
> > At conditional (1): "0" taking false path
> >
> > 574             dfprintk(PAGECACHE, "NFS: revalidating (%s/%Ld)\n",
> > 575                     inode->i_sb->s_id, (long
> > long)NFS_FILEID(inode));
> > 576
> > 577             nfs_inc_stats(inode, NFSIOS_INODEREVALIDATE);
> > 578             lock_kernel();
> >
> > Event check_after_deref: Pointer "inode" dereferenced before NULL check
> > Also see events: [deref_ptr]
> >
> > 579             if (!inode || is_bad_inode(inode))
> > 580                     goto out_nowait
> >
>
> If _ever_ __nfs_revalidate_inode() is called with a null inode pointer
> value, then we definitely want to Oops. It should not be possible.

If you review this area of the code, you see that the "if (!inode ||"
is completely superfluous, in that case.  That's what coverity is
pointing out here.  (Actually I thought this check had already been
removed long ago).

Getting rid of the check makes the code slightly clearer, does not
change the characteristic that the code will oops if inode == NULL,
and has the side advantage of shutting up coverity checking.  That's
all my patch does.

> > #cid 847 base/src/linux-2.6/fs/nfs/nfs4proc.c
> >
> > 1296    nfs4_open_revalidate(struct inode *dir, struct dentry *dentry,
> > int openflags, struct nameidata *nd)
> > 1297    {
> > 1298            struct rpc_cred *cred;
> > 1299            struct nfs4_state *state;
> > 1300
> > 1301            cred = rpcauth_lookupcred(NFS_CLIENT(dir)->cl_auth, 0);
> > 1302            if (IS_ERR(cred))
> > 1303                    return PTR_ERR(cred);
> >
> > Event deref_ptr_in_call: Dereferences pointer "(dentry)->d_inode"
> > [model]
> > Also see events: [check_after_deref]
>
> Broken coverity. The caller _always_ tests for negative dentries and
> routes around this call.
>
> > 1304            state = nfs4_open_delegated(dentry->d_inode, openflags,
> > cred);
> >
> > At conditional (1): "IS_ERR != 0" taking true path
>
> What on earth does this "error" mean?

It's not an error.  This is describing the execution path coverity
used to find the problem.  The conditional is assumed to be true for
the sake of this error report.

> > 1305            if (IS_ERR(state))
> > 1306                    state = nfs4_do_open(dir, dentry, openflags,
> > NULL, cred);
> > 1307            put_rpccred(cred);
> >
> > At conditional (2): "IS_ERR != 0" taking true path
> Ditto?
> > 1308            if (IS_ERR(state)) {
> > 1309                    switch (PTR_ERR(state)) {
> > 1310                            case -EPERM:
> > 1311                            case -EACCES:
> > 1312                            case -EDQUOT:
> > 1313                            case -ENOSPC:
> > 1314                            case -EROFS:
> > 1315                                    lookup_instantiate_filp(nd,
> > (struct dentry *)state, NULL);
> > 1316                                    return 1;
> >
> > At conditional (3): "PTR_ERR == -2" taking true path
> Ditto?
> > 1317                            case -ENOENT:
> >
> > Event check_after_deref: Pointer "(dentry)->d_inode" dereferenced before
> > NULL check
> > Also see events: [deref_ptr_in_call]
>
> Junk. See above.
>
> > 1318                                    if (dentry->d_inode == NULL)
> > 1319                                            return 1;
> > 1320                    }
> > 1321                    goto out_drop

What coverity is pointing out here is that if it is true that
dentry->d_inode is always valid, then how is this check ever useful?
Either a comment or removal of the check is called for here.  I can't
see that the contents of dentry are changed by any routine called by
this function.  So why are we checking if d_inode is NULL here?

-- 
"We who cut mere stones must always be envisioning cathedrals"
   -- Quarry worker's creed

-------------------------------------------------------------------------
Take Surveys. Earn Cash. Influence the Future of IT
Join SourceForge.net's Techsay panel and you'll get the chance to share your
opinions on IT & business topics through brief surveys -- and earn cash
http://www.techsay.com/default.php?page=join.php&p=sourceforge&CID=DEVDEV
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs

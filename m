From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: [Fwd: Re: [Patch] Possible dereference
	in	fs/nfsd/nfs4callback.c]
Date: Tue, 26 Sep 2006 14:55:37 -0400
Message-ID: <1159296937.5492.15.camel@lade.trondhjem.org>
References: <451962BD.6050909@oracle.com>
	<76bd70e30609261036l111274er219db13a336c1164@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: Eric Sesterhenn / Snakebyte <snakebyte@gmx.de>,
	Linux NFS Mailing List <nfs@lists.sourceforge.net>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1GSI65-00051e-04
	for nfs@lists.sourceforge.net; Tue, 26 Sep 2006 11:56:01 -0700
Received: from pat.uio.no ([129.240.10.4] ident=7411)
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1GSI64-00036o-5Y
	for nfs@lists.sourceforge.net; Tue, 26 Sep 2006 11:56:01 -0700
To: Chuck Lever <chucklever@gmail.com>
In-Reply-To: <76bd70e30609261036l111274er219db13a336c1164@mail.gmail.com>
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

On Tue, 2006-09-26 at 13:36 -0400, Chuck Lever wrote:
> Hi Eric-
> 
> I've checked through these reports.
> 
> 733 and 1110 are likely the same problem.  You should report these
> two, 847, and 1034 as open bugs on the NFSv4 bugzilla site, which
> appears to be down at the moment (http://linux-nfs.org, where are
> you?)
> 
> I have a patch for 1372+1373, and a patch for the error handling bug
> you reported earlier today, both of which I will send to Trond.

1372 and 1373 don't need fixing. Fix coverity instead.

> ---------- Forwarded message ----------
> From: Eric Sesterhenn / Snakebyte <snakebyte@gmx.de>
> To: Chuck Lever <chuck.lever@oracle.com>
> Date: Tue, 26 Sep 2006 15:30:37 +0200
> Subject: Re: [Patch] Possible dereference in fs/nfsd/nfs4callback.c
> * Chuck Lever (chuck.lever@oracle.com) wrote:
> > While some complain that coverity finds only nits, I think coverity is
> > useful in providing a nudge to re-examine your code in a fresh light.
> >
> > I don't have a coverity id at the moment.  Can you forward the other
> > relevant issues?
> 
> Here we go, just noticed that the two issues in fs/nfsd also got
> listed with the fs/nfs stuff, so there are just 6 warnings.
> In case you need further output, just let me know,
> where [model] is included, the checker can output where
> it guesses that the called function dereferences something.
> 
> thanks for checking this,
> Eric
> 
> #cid 1373  base/src/linux-2.6/fs/nfs/inode.c
> 
> 568     __nfs_revalidate_inode(struct nfs_server *server, struct inode
> *inode)
> 569     {
> 570             int              status = -ESTALE;
> 571             struct nfs_fattr fattr;
> 572             struct nfs_inode *nfsi = NFS_I(inode);
> 573
> 
> Event deref_ptr: Directly dereferenced pointer "inode"
> Also see events: [check_after_deref]
> At conditional (1): "0" taking false path
> 
> 574             dfprintk(PAGECACHE, "NFS: revalidating (%s/%Ld)\n",
> 575                     inode->i_sb->s_id, (long
> long)NFS_FILEID(inode));
> 576
> 577             nfs_inc_stats(inode, NFSIOS_INODEREVALIDATE);
> 578             lock_kernel();
> 
> Event check_after_deref: Pointer "inode" dereferenced before NULL check
> Also see events: [deref_ptr]
> 
> 579             if (!inode || is_bad_inode(inode))
> 580                     goto out_nowait
> 

If _ever_ __nfs_revalidate_inode() is called with a null inode pointer
value, then we definitely want to Oops. It should not be possible.

> ----------------------snip------------------------------------
> #cid 1372 base/src/linux-2.6/fs/nfs/inode.c
> 
> 568     __nfs_revalidate_inode(struct nfs_server *server, struct inode
> *inode)
> 569     {
> 570             int              status = -ESTALE;
> 571             struct nfs_fattr fattr;
> 572             struct nfs_inode *nfsi = NFS_I(inode);
> 573
> 574             dfprintk(PAGECACHE, "NFS: revalidating (%s/%Ld)\n",
> 575                     inode->i_sb->s_id, (long
> long)NFS_FILEID(inode));
> 576
> 
> Event deref_ptr_in_call: Dereferences pointer "inode" [model]
> Also see events: [check_after_deref]

Ditto.

> 577             nfs_inc_stats(inode, NFSIOS_INODEREVALIDATE);
> 578             lock_kernel();
> 
> Event check_after_deref: Pointer "inode" dereferenced before NULL check
> Also see events: [deref_ptr_in_call]
> 
> 579             if (!inode || is_bad_inode(inode))
> 580                     goto out_nowait;

Ditto.

> ----------------------snip------------------------------------
> #cid 1034 base/src/linux-2.6/fs/nfs/callback_xdr.c
> 
> 356     static unsigned process_op(struct svc_rqst *rqstp,
> 357                     struct xdr_stream *xdr_in, void *argp,
> 358                     struct xdr_stream *xdr_out, void *resp)
> 359     {
> 360             struct callback_op *op = &callback_ops[0];
> 361             unsigned int op_nr = OP_CB_ILLEGAL;
> 362             unsigned int status = 0;
> 363             long maxlen;
> 364             unsigned res;
> 365
> 366             dprintk("%s: start\n", __FUNCTION__);
> 367             status = decode_op_hdr(xdr_in, &op_nr);
> 368             if (likely(status == 0)) {
> 369                     switch (op_nr) {
> 370                             case OP_CB_GETATTR:
> 371                             case OP_CB_RECALL:
> 
> Event ptr_assign: Pointer "op" assigned address of static buffer pointer
> "(&callback_ops + (op_nr * 16))" of size 80 and offset 160704
> Also see events: [overrun-local][overrun-local]

Broken Coverity. The code explicitly limits the values of op to
callback_ops[OP_CB_GETATTR] and callback_ops[OP_CB_RECALL]. Anything
else is mapped to callback_ops[0].

> 372                                     op = &callback_ops[op_nr];
> 373                                     break;
> 374                             default:
> 375                                     op_nr = OP_CB_ILLEGAL;
> 376                                     op = &callback_ops[0];
> 377                                     status =
> htonl(NFS4ERR_OP_ILLEGAL);
> 378                     }
> 379             }
> 380
> 381             maxlen = xdr_out->end - xdr_out->p;
> 
> At conditional (1): "maxlen > 0" taking true path
> At conditional (2): "maxlen < 4096" taking true path
> 
> 382             if (maxlen > 0 && maxlen < PAGE_SIZE) {
> 
> Event overrun-local: Overrun of static array of size 80 at position
> 160704 by accessing with pointer alias "op"
> Event overrun-local: NOTE: These bugs are often difficult to see at
> first glance. Coverity Prevent recommends a close inspection of the
> events leading to this overrun.
> Also see events: [ptr_assign][overrun-local]
> At conditional (3): "status == 0" taking true path

Junk. See comment above.

> 383                     if (likely(status == 0 && op->decode_args !=
> NULL))
> 384                             status = op->decode_args(rqstp, xdr_in,
> argp);
> 385                     if (likely(status == 0 && op->process_op !=
> NULL))
> 386                             status = op->process_op(argp, resp);
> 387             } else
> 388                     status = htonl(NFS4ERR_RESOURCE);
> 389
> 390             res = encode_op_hdr(xdr_out, op_nr, status);
> 391             if (status == 0)
> 392                     status = res;
> 393             if (op->encode_res != NULL && status == 0)
> 394                     status = op->encode_res(rqstp, xdr_out, resp);
> 395             dprintk("%s: done, status = %d\n", __FUNCTION__,
> status);
> 396             return status;
> 397     }
> 
> ----------------------snip------------------------------------
> #cid 847 base/src/linux-2.6/fs/nfs/nfs4proc.c
> 
> 1296    nfs4_open_revalidate(struct inode *dir, struct dentry *dentry,
> int openflags, struct nameidata *nd)
> 1297    {
> 1298            struct rpc_cred *cred;
> 1299            struct nfs4_state *state;
> 1300
> 1301            cred = rpcauth_lookupcred(NFS_CLIENT(dir)->cl_auth, 0);
> 1302            if (IS_ERR(cred))
> 1303                    return PTR_ERR(cred);
> 
> Event deref_ptr_in_call: Dereferences pointer "(dentry)->d_inode"
> [model]
> Also see events: [check_after_deref]

Broken coverity. The caller _always_ tests for negative dentries and
routes around this call.

> 1304            state = nfs4_open_delegated(dentry->d_inode, openflags,
> cred);
> 
> At conditional (1): "IS_ERR != 0" taking true path

What on earth does this "error" mean?

> 1305            if (IS_ERR(state))
> 1306                    state = nfs4_do_open(dir, dentry, openflags,
> NULL, cred);
> 1307            put_rpccred(cred);
> 
> At conditional (2): "IS_ERR != 0" taking true path
Ditto?
> 1308            if (IS_ERR(state)) {
> 1309                    switch (PTR_ERR(state)) {
> 1310                            case -EPERM:
> 1311                            case -EACCES:
> 1312                            case -EDQUOT:
> 1313                            case -ENOSPC:
> 1314                            case -EROFS:
> 1315                                    lookup_instantiate_filp(nd,
> (struct dentry *)state, NULL);
> 1316                                    return 1;
> 
> At conditional (3): "PTR_ERR == -2" taking true path
Ditto?
> 1317                            case -ENOENT:
> 
> Event check_after_deref: Pointer "(dentry)->d_inode" dereferenced before
> NULL check
> Also see events: [deref_ptr_in_call]

Junk. See above.

> 1318                                    if (dentry->d_inode == NULL)
> 1319                                            return 1;
> 1320                    }
> 1321                    goto out_drop
> 

Cheers,
  Trond


-------------------------------------------------------------------------
Take Surveys. Earn Cash. Influence the Future of IT
Join SourceForge.net's Techsay panel and you'll get the chance to share your
opinions on IT & business topics through brief surveys -- and earn cash
http://www.techsay.com/default.php?page=join.php&p=sourceforge&CID=DEVDEV
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs

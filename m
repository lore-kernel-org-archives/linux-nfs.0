From: "Chuck Lever" <chucklever@gmail.com>
Subject: [Fwd: Re: [Patch] Possible dereference in
	fs/nfsd/nfs4callback.c]
Date: Tue, 26 Sep 2006 13:36:02 -0400
Message-ID: <76bd70e30609261036l111274er219db13a336c1164@mail.gmail.com>
References: <451962BD.6050909@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: Linux NFS Mailing List <nfs@lists.sourceforge.net>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1GSGql-0006Nt-RF
	for nfs@lists.sourceforge.net; Tue, 26 Sep 2006 10:36:07 -0700
Received: from wx-out-0506.google.com ([66.249.82.228])
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1GSGqm-0005kd-3k
	for nfs@lists.sourceforge.net; Tue, 26 Sep 2006 10:36:08 -0700
Received: by wx-out-0506.google.com with SMTP id r21so2760168wxc
	for <nfs@lists.sourceforge.net>; Tue, 26 Sep 2006 10:36:02 -0700 (PDT)
To: "Eric Sesterhenn / Snakebyte" <snakebyte@gmx.de>
In-Reply-To: <451962BD.6050909@oracle.com>
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

Hi Eric-

I've checked through these reports.

733 and 1110 are likely the same problem.  You should report these
two, 847, and 1034 as open bugs on the NFSv4 bugzilla site, which
appears to be down at the moment (http://linux-nfs.org, where are
you?)

I have a patch for 1372+1373, and a patch for the error handling bug
you reported earlier today, both of which I will send to Trond.

---------- Forwarded message ----------
From: Eric Sesterhenn / Snakebyte <snakebyte@gmx.de>
To: Chuck Lever <chuck.lever@oracle.com>
Date: Tue, 26 Sep 2006 15:30:37 +0200
Subject: Re: [Patch] Possible dereference in fs/nfsd/nfs4callback.c
* Chuck Lever (chuck.lever@oracle.com) wrote:
> While some complain that coverity finds only nits, I think coverity is
> useful in providing a nudge to re-examine your code in a fresh light.
>
> I don't have a coverity id at the moment.  Can you forward the other
> relevant issues?

Here we go, just noticed that the two issues in fs/nfsd also got
listed with the fs/nfs stuff, so there are just 6 warnings.
In case you need further output, just let me know,
where [model] is included, the checker can output where
it guesses that the called function dereferences something.

thanks for checking this,
Eric

#cid 1373  base/src/linux-2.6/fs/nfs/inode.c

568     __nfs_revalidate_inode(struct nfs_server *server, struct inode
*inode)
569     {
570             int              status = -ESTALE;
571             struct nfs_fattr fattr;
572             struct nfs_inode *nfsi = NFS_I(inode);
573

Event deref_ptr: Directly dereferenced pointer "inode"
Also see events: [check_after_deref]
At conditional (1): "0" taking false path

574             dfprintk(PAGECACHE, "NFS: revalidating (%s/%Ld)\n",
575                     inode->i_sb->s_id, (long
long)NFS_FILEID(inode));
576
577             nfs_inc_stats(inode, NFSIOS_INODEREVALIDATE);
578             lock_kernel();

Event check_after_deref: Pointer "inode" dereferenced before NULL check
Also see events: [deref_ptr]

579             if (!inode || is_bad_inode(inode))
580                     goto out_nowait


----------------------snip------------------------------------
#cid 1372 base/src/linux-2.6/fs/nfs/inode.c

568     __nfs_revalidate_inode(struct nfs_server *server, struct inode
*inode)
569     {
570             int              status = -ESTALE;
571             struct nfs_fattr fattr;
572             struct nfs_inode *nfsi = NFS_I(inode);
573
574             dfprintk(PAGECACHE, "NFS: revalidating (%s/%Ld)\n",
575                     inode->i_sb->s_id, (long
long)NFS_FILEID(inode));
576

Event deref_ptr_in_call: Dereferences pointer "inode" [model]
Also see events: [check_after_deref]

577             nfs_inc_stats(inode, NFSIOS_INODEREVALIDATE);
578             lock_kernel();

Event check_after_deref: Pointer "inode" dereferenced before NULL check
Also see events: [deref_ptr_in_call]

579             if (!inode || is_bad_inode(inode))
580                     goto out_nowait;

----------------------snip------------------------------------
#cid 1110 base/src/linux-2.6/fs/nfsd/nfs4acl.c
374     nfs4_acl_nfsv4_to_posix(struct nfs4_acl *acl, struct posix_acl
**pacl,
375                     struct posix_acl **dpacl, unsigned int flags)
376     {
377             struct nfs4_acl *dacl;
378             int error = -ENOMEM;
379

Event deref_ptr: Directly dereferenced pointer "pacl"
Also see events: [check_after_deref][check_after_deref]

380             *pacl = NULL;
381             *dpacl = NULL;
382
383             dacl = nfs4_acl_new();

At conditional (1): "dacl == 0" taking false path

384             if (dacl == NULL)
385                     goto out;
386
387             error = nfs4_acl_split(acl, dacl);

At conditional (2): "error < 0" taking false path

388             if (error < 0)
389                     goto out_acl;
390

Event check_after_deref: Pointer "pacl" dereferenced before NULL check
Also see events: [deref_ptr][check_after_deref]

391             if (pacl != NULL) {
392                     if (acl->naces == 0) {
393                             error = -ENODATA;
394                             goto try_dpacl;
395                     }

----------------------snip------------------------------------
#cid 1034 base/src/linux-2.6/fs/nfs/callback_xdr.c

356     static unsigned process_op(struct svc_rqst *rqstp,
357                     struct xdr_stream *xdr_in, void *argp,
358                     struct xdr_stream *xdr_out, void *resp)
359     {
360             struct callback_op *op = &callback_ops[0];
361             unsigned int op_nr = OP_CB_ILLEGAL;
362             unsigned int status = 0;
363             long maxlen;
364             unsigned res;
365
366             dprintk("%s: start\n", __FUNCTION__);
367             status = decode_op_hdr(xdr_in, &op_nr);
368             if (likely(status == 0)) {
369                     switch (op_nr) {
370                             case OP_CB_GETATTR:
371                             case OP_CB_RECALL:

Event ptr_assign: Pointer "op" assigned address of static buffer pointer
"(&callback_ops + (op_nr * 16))" of size 80 and offset 160704
Also see events: [overrun-local][overrun-local]

372                                     op = &callback_ops[op_nr];
373                                     break;
374                             default:
375                                     op_nr = OP_CB_ILLEGAL;
376                                     op = &callback_ops[0];
377                                     status =
htonl(NFS4ERR_OP_ILLEGAL);
378                     }
379             }
380
381             maxlen = xdr_out->end - xdr_out->p;

At conditional (1): "maxlen > 0" taking true path
At conditional (2): "maxlen < 4096" taking true path

382             if (maxlen > 0 && maxlen < PAGE_SIZE) {

Event overrun-local: Overrun of static array of size 80 at position
160704 by accessing with pointer alias "op"
Event overrun-local: NOTE: These bugs are often difficult to see at
first glance. Coverity Prevent recommends a close inspection of the
events leading to this overrun.
Also see events: [ptr_assign][overrun-local]
At conditional (3): "status == 0" taking true path

383                     if (likely(status == 0 && op->decode_args !=
NULL))
384                             status = op->decode_args(rqstp, xdr_in,
argp);
385                     if (likely(status == 0 && op->process_op !=
NULL))
386                             status = op->process_op(argp, resp);
387             } else
388                     status = htonl(NFS4ERR_RESOURCE);
389
390             res = encode_op_hdr(xdr_out, op_nr, status);
391             if (status == 0)
392                     status = res;
393             if (op->encode_res != NULL && status == 0)
394                     status = op->encode_res(rqstp, xdr_out, resp);
395             dprintk("%s: done, status = %d\n", __FUNCTION__,
status);
396             return status;
397     }

----------------------snip------------------------------------
#cid 847 base/src/linux-2.6/fs/nfs/nfs4proc.c

1296    nfs4_open_revalidate(struct inode *dir, struct dentry *dentry,
int openflags, struct nameidata *nd)
1297    {
1298            struct rpc_cred *cred;
1299            struct nfs4_state *state;
1300
1301            cred = rpcauth_lookupcred(NFS_CLIENT(dir)->cl_auth, 0);
1302            if (IS_ERR(cred))
1303                    return PTR_ERR(cred);

Event deref_ptr_in_call: Dereferences pointer "(dentry)->d_inode"
[model]
Also see events: [check_after_deref]

1304            state = nfs4_open_delegated(dentry->d_inode, openflags,
cred);

At conditional (1): "IS_ERR != 0" taking true path

1305            if (IS_ERR(state))
1306                    state = nfs4_do_open(dir, dentry, openflags,
NULL, cred);
1307            put_rpccred(cred);

At conditional (2): "IS_ERR != 0" taking true path

1308            if (IS_ERR(state)) {
1309                    switch (PTR_ERR(state)) {
1310                            case -EPERM:
1311                            case -EACCES:
1312                            case -EDQUOT:
1313                            case -ENOSPC:
1314                            case -EROFS:
1315                                    lookup_instantiate_filp(nd,
(struct dentry *)state, NULL);
1316                                    return 1;

At conditional (3): "PTR_ERR == -2" taking true path

1317                            case -ENOENT:

Event check_after_deref: Pointer "(dentry)->d_inode" dereferenced before
NULL check
Also see events: [deref_ptr_in_call]

1318                                    if (dentry->d_inode == NULL)
1319                                            return 1;
1320                    }
1321                    goto out_drop


----------------------snip------------------------------------
#cid 733 base/src/linux-2.6/fs/nfsd/nfs4acl.c

374     nfs4_acl_nfsv4_to_posix(struct nfs4_acl *acl, struct posix_acl
**pacl,
375                     struct posix_acl **dpacl, unsigned int flags)
376     {
377             struct nfs4_acl *dacl;
378             int error = -ENOMEM;
379
380             *pacl = NULL;

Event deref_ptr: Directly dereferenced pointer "dpacl"
Also see events: [check_after_deref]

381             *dpacl = NULL;
382
383             dacl = nfs4_acl_new();

At conditional (1): "dacl == 0" taking false path

384             if (dacl == NULL)
385                     goto out;
386
387             error = nfs4_acl_split(acl, dacl);

At conditional (2): "error < 0" taking false path

388             if (error < 0)
389                     goto out_acl;
390

At conditional (3): "pacl != 0" taking true path

391             if (pacl != NULL) {

At conditional (4): "(acl)->naces == 0" taking true path

392                     if (acl->naces == 0) {
393                             error = -ENODATA;
394                             goto try_dpacl;
395                     }
396
397                     *pacl = _nfsv4_to_posix_one(acl, flags);
398                     if (IS_ERR(*pacl)) {
399                             error = PTR_ERR(*pacl);
400                             *pacl = NULL;
401                             goto out_acl;
402                     }
403             }
404
405     try_dpacl:

Event check_after_deref: Pointer "dpacl" dereferenced before NULL check
Also see events: [deref_ptr]

406             if (dpacl != NULL) {
407                     if (dacl->naces == 0) {
408                             if (pacl == NULL || *pacl == NULL)
409                                     error = -ENODATA;
410                             goto out_acl;
411                     }






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

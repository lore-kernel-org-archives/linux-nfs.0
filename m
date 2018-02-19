Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mga07.intel.com ([134.134.136.100]:22972 "EHLO mga07.intel.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752995AbeBSO7E (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Mon, 19 Feb 2018 09:59:04 -0500
Date: Mon, 19 Feb 2018 22:58:29 +0800
From: kbuild test robot <lkp@intel.com>
To: NeilBrown <neilb@suse.com>
Cc: kbuild-all@01.org,
        Trond Myklebust <trond.myklebust@primarydata.com>,
        Anna Schumaker <anna.schumaker@netapp.com>,
        linux-nfs@vger.kernel.org
Subject: Re: [PATCH 19/23] NFS/NFSD/SUNRPC: replace generic creds with
 'struct cred'.
Message-ID: <201802192252.Y6fdV4Fk%fengguang.wu@intel.com>
References: <151901654943.17421.16135174786512989263.stgit@noble>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <151901654943.17421.16135174786512989263.stgit@noble>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi NeilBrown,

Thank you for the patch! Perhaps something to improve:

[auto build test WARNING on nfs/linux-next]
[also build test WARNING on v4.16-rc2 next-20180219]
[if your patch is applied to the wrong git tree, please drop us a note to help improve the system]

url:    https://github.com/0day-ci/linux/commits/NeilBrown/Remove-generic-rpc-credentials-and-associated-changed-V3/20180219-190836
base:   git://git.linux-nfs.org/projects/trondmy/linux-nfs.git linux-next
reproduce:
        # apt-get install sparse
        make ARCH=x86_64 allmodconfig
        make C=1 CF=-D__CHECK_ENDIAN__


sparse warnings: (new ones prefixed by >>)

>> fs/nfs/flexfilelayout/flexfilelayout.c:517:40: sparse: incorrect type in initializer (different address spaces) @@ expected struct cred const @@ got cred const @@
   fs/nfs/flexfilelayout/flexfilelayout.c:517:40: expected struct cred const
   fs/nfs/flexfilelayout/flexfilelayout.c:517:40: got struct cred const Documentation Kbuild Kconfig Makefile certs drivers firmware fs include samples scripts sound tools cred
>> fs/nfs/flexfilelayout/flexfilelayout.c:517:38: sparse: incorrect type in assignment (different address spaces) @@ expected struct cred const Documentation Kbuild Kconfig Makefile certs drivers firmware fs include samples scripts sound tools cred @@ got struct cred conststruct cred const Documentation Kbuild Kconfig Makefile certs drivers firmware fs include samples scripts sound tools cred @@
   fs/nfs/flexfilelayout/flexfilelayout.c:517:38: expected struct cred const Documentation Kbuild Kconfig Makefile certs drivers firmware fs include samples scripts sound tools cred
   fs/nfs/flexfilelayout/flexfilelayout.c:517:38: got struct cred const __ret
   fs/nfs/flexfilelayout/flexfilelayout.c:520:40: sparse: incorrect type in initializer (different address spaces) @@ expected struct cred const @@ got cred const @@
   fs/nfs/flexfilelayout/flexfilelayout.c:520:40: expected struct cred const
   fs/nfs/flexfilelayout/flexfilelayout.c:520:40: got struct cred const Documentation Kbuild Kconfig Makefile certs drivers firmware fs include samples scripts sound tools cred
   fs/nfs/flexfilelayout/flexfilelayout.c:520:38: sparse: incorrect type in assignment (different address spaces) @@ expected struct cred const Documentation Kbuild Kconfig Makefile certs drivers firmware fs include samples scripts sound tools cred @@ got struct cred conststruct cred const Documentation Kbuild Kconfig Makefile certs drivers firmware fs include samples scripts sound tools cred @@
   fs/nfs/flexfilelayout/flexfilelayout.c:520:38: expected struct cred const Documentation Kbuild Kconfig Makefile certs drivers firmware fs include samples scripts sound tools cred
   fs/nfs/flexfilelayout/flexfilelayout.c:520:38: got struct cred const __ret

vim +517 fs/nfs/flexfilelayout/flexfilelayout.c

d67ae825 Tom Haynes      2014-12-11  360  
d67ae825 Tom Haynes      2014-12-11  361  static struct pnfs_layout_segment *
d67ae825 Tom Haynes      2014-12-11  362  ff_layout_alloc_lseg(struct pnfs_layout_hdr *lh,
d67ae825 Tom Haynes      2014-12-11  363  		     struct nfs4_layoutget_res *lgr,
d67ae825 Tom Haynes      2014-12-11  364  		     gfp_t gfp_flags)
d67ae825 Tom Haynes      2014-12-11  365  {
d67ae825 Tom Haynes      2014-12-11  366  	struct pnfs_layout_segment *ret;
d67ae825 Tom Haynes      2014-12-11  367  	struct nfs4_ff_layout_segment *fls = NULL;
d67ae825 Tom Haynes      2014-12-11  368  	struct xdr_stream stream;
d67ae825 Tom Haynes      2014-12-11  369  	struct xdr_buf buf;
d67ae825 Tom Haynes      2014-12-11  370  	struct page *scratch;
d67ae825 Tom Haynes      2014-12-11  371  	u64 stripe_unit;
d67ae825 Tom Haynes      2014-12-11  372  	u32 mirror_array_cnt;
d67ae825 Tom Haynes      2014-12-11  373  	__be32 *p;
d67ae825 Tom Haynes      2014-12-11  374  	int i, rc;
d67ae825 Tom Haynes      2014-12-11  375  
d67ae825 Tom Haynes      2014-12-11  376  	dprintk("--> %s\n", __func__);
d67ae825 Tom Haynes      2014-12-11  377  	scratch = alloc_page(gfp_flags);
d67ae825 Tom Haynes      2014-12-11  378  	if (!scratch)
d67ae825 Tom Haynes      2014-12-11  379  		return ERR_PTR(-ENOMEM);
d67ae825 Tom Haynes      2014-12-11  380  
d67ae825 Tom Haynes      2014-12-11  381  	xdr_init_decode_pages(&stream, &buf, lgr->layoutp->pages,
d67ae825 Tom Haynes      2014-12-11  382  			      lgr->layoutp->len);
d67ae825 Tom Haynes      2014-12-11  383  	xdr_set_scratch_buffer(&stream, page_address(scratch), PAGE_SIZE);
d67ae825 Tom Haynes      2014-12-11  384  
d67ae825 Tom Haynes      2014-12-11  385  	/* stripe unit and mirror_array_cnt */
d67ae825 Tom Haynes      2014-12-11  386  	rc = -EIO;
d67ae825 Tom Haynes      2014-12-11  387  	p = xdr_inline_decode(&stream, 8 + 4);
d67ae825 Tom Haynes      2014-12-11  388  	if (!p)
d67ae825 Tom Haynes      2014-12-11  389  		goto out_err_free;
d67ae825 Tom Haynes      2014-12-11  390  
d67ae825 Tom Haynes      2014-12-11  391  	p = xdr_decode_hyper(p, &stripe_unit);
d67ae825 Tom Haynes      2014-12-11  392  	mirror_array_cnt = be32_to_cpup(p++);
d67ae825 Tom Haynes      2014-12-11  393  	dprintk("%s: stripe_unit=%llu mirror_array_cnt=%u\n", __func__,
d67ae825 Tom Haynes      2014-12-11  394  		stripe_unit, mirror_array_cnt);
d67ae825 Tom Haynes      2014-12-11  395  
d67ae825 Tom Haynes      2014-12-11  396  	if (mirror_array_cnt > NFS4_FLEXFILE_LAYOUT_MAX_MIRROR_CNT ||
d67ae825 Tom Haynes      2014-12-11  397  	    mirror_array_cnt == 0)
d67ae825 Tom Haynes      2014-12-11  398  		goto out_err_free;
d67ae825 Tom Haynes      2014-12-11  399  
d67ae825 Tom Haynes      2014-12-11  400  	rc = -ENOMEM;
d67ae825 Tom Haynes      2014-12-11  401  	fls = kzalloc(sizeof(*fls), gfp_flags);
d67ae825 Tom Haynes      2014-12-11  402  	if (!fls)
d67ae825 Tom Haynes      2014-12-11  403  		goto out_err_free;
d67ae825 Tom Haynes      2014-12-11  404  
d67ae825 Tom Haynes      2014-12-11  405  	fls->mirror_array_cnt = mirror_array_cnt;
d67ae825 Tom Haynes      2014-12-11  406  	fls->stripe_unit = stripe_unit;
d67ae825 Tom Haynes      2014-12-11  407  	fls->mirror_array = kcalloc(fls->mirror_array_cnt,
d67ae825 Tom Haynes      2014-12-11  408  				    sizeof(fls->mirror_array[0]), gfp_flags);
d67ae825 Tom Haynes      2014-12-11  409  	if (fls->mirror_array == NULL)
d67ae825 Tom Haynes      2014-12-11  410  		goto out_err_free;
d67ae825 Tom Haynes      2014-12-11  411  
d67ae825 Tom Haynes      2014-12-11  412  	for (i = 0; i < fls->mirror_array_cnt; i++) {
266d12d4 Trond Myklebust 2015-08-24  413  		struct nfs4_ff_layout_mirror *mirror;
bbf32642 NeilBrown       2018-02-19  414  		struct cred *kcred;
3c189a1f NeilBrown       2018-02-19  415  		const struct cred *cred;
df462af3 NeilBrown       2018-02-19  416  		kuid_t uid;
df462af3 NeilBrown       2018-02-19  417  		kgid_t gid;
90a0be00 Jeff Layton     2016-04-21  418  		u32 ds_count, fh_count, id;
d67ae825 Tom Haynes      2014-12-11  419  		int j;
d67ae825 Tom Haynes      2014-12-11  420  
d67ae825 Tom Haynes      2014-12-11  421  		rc = -EIO;
d67ae825 Tom Haynes      2014-12-11  422  		p = xdr_inline_decode(&stream, 4);
d67ae825 Tom Haynes      2014-12-11  423  		if (!p)
d67ae825 Tom Haynes      2014-12-11  424  			goto out_err_free;
d67ae825 Tom Haynes      2014-12-11  425  		ds_count = be32_to_cpup(p);
d67ae825 Tom Haynes      2014-12-11  426  
d67ae825 Tom Haynes      2014-12-11  427  		/* FIXME: allow for striping? */
d67ae825 Tom Haynes      2014-12-11  428  		if (ds_count != 1)
d67ae825 Tom Haynes      2014-12-11  429  			goto out_err_free;
d67ae825 Tom Haynes      2014-12-11  430  
28a0d72c Trond Myklebust 2015-08-24  431  		fls->mirror_array[i] = ff_layout_alloc_mirror(gfp_flags);
d67ae825 Tom Haynes      2014-12-11  432  		if (fls->mirror_array[i] == NULL) {
d67ae825 Tom Haynes      2014-12-11  433  			rc = -ENOMEM;
d67ae825 Tom Haynes      2014-12-11  434  			goto out_err_free;
d67ae825 Tom Haynes      2014-12-11  435  		}
d67ae825 Tom Haynes      2014-12-11  436  
d67ae825 Tom Haynes      2014-12-11  437  		fls->mirror_array[i]->ds_count = ds_count;
d67ae825 Tom Haynes      2014-12-11  438  
d67ae825 Tom Haynes      2014-12-11  439  		/* deviceid */
65990d1a Fred Isaman     2016-09-30  440  		rc = decode_deviceid(&stream, &fls->mirror_array[i]->devid);
d67ae825 Tom Haynes      2014-12-11  441  		if (rc)
d67ae825 Tom Haynes      2014-12-11  442  			goto out_err_free;
d67ae825 Tom Haynes      2014-12-11  443  
d67ae825 Tom Haynes      2014-12-11  444  		/* efficiency */
d67ae825 Tom Haynes      2014-12-11  445  		rc = -EIO;
d67ae825 Tom Haynes      2014-12-11  446  		p = xdr_inline_decode(&stream, 4);
d67ae825 Tom Haynes      2014-12-11  447  		if (!p)
d67ae825 Tom Haynes      2014-12-11  448  			goto out_err_free;
d67ae825 Tom Haynes      2014-12-11  449  		fls->mirror_array[i]->efficiency = be32_to_cpup(p);
d67ae825 Tom Haynes      2014-12-11  450  
d67ae825 Tom Haynes      2014-12-11  451  		/* stateid */
93b717fd Trond Myklebust 2016-05-16  452  		rc = decode_pnfs_stateid(&stream, &fls->mirror_array[i]->stateid);
d67ae825 Tom Haynes      2014-12-11  453  		if (rc)
d67ae825 Tom Haynes      2014-12-11  454  			goto out_err_free;
d67ae825 Tom Haynes      2014-12-11  455  
d67ae825 Tom Haynes      2014-12-11  456  		/* fh */
662f9a10 Dan Carpenter   2017-05-20  457  		rc = -EIO;
d67ae825 Tom Haynes      2014-12-11  458  		p = xdr_inline_decode(&stream, 4);
d67ae825 Tom Haynes      2014-12-11  459  		if (!p)
d67ae825 Tom Haynes      2014-12-11  460  			goto out_err_free;
d67ae825 Tom Haynes      2014-12-11  461  		fh_count = be32_to_cpup(p);
d67ae825 Tom Haynes      2014-12-11  462  
d67ae825 Tom Haynes      2014-12-11  463  		fls->mirror_array[i]->fh_versions =
d67ae825 Tom Haynes      2014-12-11  464  			kzalloc(fh_count * sizeof(struct nfs_fh),
d67ae825 Tom Haynes      2014-12-11  465  				gfp_flags);
d67ae825 Tom Haynes      2014-12-11  466  		if (fls->mirror_array[i]->fh_versions == NULL) {
d67ae825 Tom Haynes      2014-12-11  467  			rc = -ENOMEM;
d67ae825 Tom Haynes      2014-12-11  468  			goto out_err_free;
d67ae825 Tom Haynes      2014-12-11  469  		}
d67ae825 Tom Haynes      2014-12-11  470  
d67ae825 Tom Haynes      2014-12-11  471  		for (j = 0; j < fh_count; j++) {
d67ae825 Tom Haynes      2014-12-11  472  			rc = decode_nfs_fh(&stream,
d67ae825 Tom Haynes      2014-12-11  473  					   &fls->mirror_array[i]->fh_versions[j]);
d67ae825 Tom Haynes      2014-12-11  474  			if (rc)
d67ae825 Tom Haynes      2014-12-11  475  				goto out_err_free;
d67ae825 Tom Haynes      2014-12-11  476  		}
d67ae825 Tom Haynes      2014-12-11  477  
d67ae825 Tom Haynes      2014-12-11  478  		fls->mirror_array[i]->fh_versions_cnt = fh_count;
d67ae825 Tom Haynes      2014-12-11  479  
d67ae825 Tom Haynes      2014-12-11  480  		/* user */
90a0be00 Jeff Layton     2016-04-21  481  		rc = decode_name(&stream, &id);
d67ae825 Tom Haynes      2014-12-11  482  		if (rc)
d67ae825 Tom Haynes      2014-12-11  483  			goto out_err_free;
d67ae825 Tom Haynes      2014-12-11  484  
df462af3 NeilBrown       2018-02-19  485  		uid = make_kuid(&init_user_ns, id);
90a0be00 Jeff Layton     2016-04-21  486  
d67ae825 Tom Haynes      2014-12-11  487  		/* group */
90a0be00 Jeff Layton     2016-04-21  488  		rc = decode_name(&stream, &id);
d67ae825 Tom Haynes      2014-12-11  489  		if (rc)
d67ae825 Tom Haynes      2014-12-11  490  			goto out_err_free;
d67ae825 Tom Haynes      2014-12-11  491  
df462af3 NeilBrown       2018-02-19  492  		gid = make_kgid(&init_user_ns, id);
90a0be00 Jeff Layton     2016-04-21  493  
bbf32642 NeilBrown       2018-02-19  494  		if (gfp_flags & __GFP_FS)
bbf32642 NeilBrown       2018-02-19  495  			kcred = prepare_kernel_cred(NULL);
bbf32642 NeilBrown       2018-02-19  496  		else {
bbf32642 NeilBrown       2018-02-19  497  			unsigned int nofs_flags = memalloc_nofs_save();
bbf32642 NeilBrown       2018-02-19  498  			kcred = prepare_kernel_cred(NULL);
bbf32642 NeilBrown       2018-02-19  499  			memalloc_nofs_restore(nofs_flags);
bbf32642 NeilBrown       2018-02-19  500  		}
bbf32642 NeilBrown       2018-02-19  501  		rc = -ENOMEM;
bbf32642 NeilBrown       2018-02-19  502  		if (!kcred)
bbf32642 NeilBrown       2018-02-19  503  			goto out_err_free;
df462af3 NeilBrown       2018-02-19  504  		kcred->fsuid = uid;
df462af3 NeilBrown       2018-02-19  505  		kcred->fsgid = gid;
3c189a1f NeilBrown       2018-02-19  506  		cred = kcred;
90a0be00 Jeff Layton     2016-04-21  507  
3064b686 Jeff Layton     2016-04-21  508  		if (lgr->range.iomode == IOMODE_READ)
3064b686 Jeff Layton     2016-04-21  509  			rcu_assign_pointer(fls->mirror_array[i]->ro_cred, cred);
3064b686 Jeff Layton     2016-04-21  510  		else
3064b686 Jeff Layton     2016-04-21  511  			rcu_assign_pointer(fls->mirror_array[i]->rw_cred, cred);
90a0be00 Jeff Layton     2016-04-21  512  
266d12d4 Trond Myklebust 2015-08-24  513  		mirror = ff_layout_add_mirror(lh, fls->mirror_array[i]);
266d12d4 Trond Myklebust 2015-08-24  514  		if (mirror != fls->mirror_array[i]) {
90a0be00 Jeff Layton     2016-04-21  515  			/* swap cred ptrs so free_mirror will clean up old */
3064b686 Jeff Layton     2016-04-21  516  			if (lgr->range.iomode == IOMODE_READ) {
3064b686 Jeff Layton     2016-04-21 @517  				cred = xchg(&mirror->ro_cred, cred);
3064b686 Jeff Layton     2016-04-21  518  				rcu_assign_pointer(fls->mirror_array[i]->ro_cred, cred);
3064b686 Jeff Layton     2016-04-21  519  			} else {
3064b686 Jeff Layton     2016-04-21  520  				cred = xchg(&mirror->rw_cred, cred);
3064b686 Jeff Layton     2016-04-21  521  				rcu_assign_pointer(fls->mirror_array[i]->rw_cred, cred);
3064b686 Jeff Layton     2016-04-21  522  			}
266d12d4 Trond Myklebust 2015-08-24  523  			ff_layout_free_mirror(fls->mirror_array[i]);
266d12d4 Trond Myklebust 2015-08-24  524  			fls->mirror_array[i] = mirror;
266d12d4 Trond Myklebust 2015-08-24  525  		}
266d12d4 Trond Myklebust 2015-08-24  526  
3064b686 Jeff Layton     2016-04-21  527  		dprintk("%s: iomode %s uid %u gid %u\n", __func__,
3064b686 Jeff Layton     2016-04-21  528  			lgr->range.iomode == IOMODE_READ ? "READ" : "RW",
df462af3 NeilBrown       2018-02-19  529  			from_kuid(&init_user_ns, uid),
df462af3 NeilBrown       2018-02-19  530  			from_kgid(&init_user_ns, gid));
d67ae825 Tom Haynes      2014-12-11  531  	}
d67ae825 Tom Haynes      2014-12-11  532  
c0f5f505 Trond Myklebust 2015-06-26  533  	p = xdr_inline_decode(&stream, 4);
d0379a5d Trond Myklebust 2015-11-16  534  	if (!p)
d0379a5d Trond Myklebust 2015-11-16  535  		goto out_sort_mirrors;
c0f5f505 Trond Myklebust 2015-06-26  536  	fls->flags = be32_to_cpup(p);
c0f5f505 Trond Myklebust 2015-06-26  537  
d0379a5d Trond Myklebust 2015-11-16  538  	p = xdr_inline_decode(&stream, 4);
d0379a5d Trond Myklebust 2015-11-16  539  	if (!p)
d0379a5d Trond Myklebust 2015-11-16  540  		goto out_sort_mirrors;
d0379a5d Trond Myklebust 2015-11-16  541  	for (i=0; i < fls->mirror_array_cnt; i++)
d0379a5d Trond Myklebust 2015-11-16  542  		fls->mirror_array[i]->report_interval = be32_to_cpup(p);
d0379a5d Trond Myklebust 2015-11-16  543  
d0379a5d Trond Myklebust 2015-11-16  544  out_sort_mirrors:
d67ae825 Tom Haynes      2014-12-11  545  	ff_layout_sort_mirrors(fls);
d67ae825 Tom Haynes      2014-12-11  546  	rc = ff_layout_check_layout(lgr);
d67ae825 Tom Haynes      2014-12-11  547  	if (rc)
d67ae825 Tom Haynes      2014-12-11  548  		goto out_err_free;
d67ae825 Tom Haynes      2014-12-11  549  	ret = &fls->generic_hdr;
d67ae825 Tom Haynes      2014-12-11  550  	dprintk("<-- %s (success)\n", __func__);
d67ae825 Tom Haynes      2014-12-11  551  out_free_page:
d67ae825 Tom Haynes      2014-12-11  552  	__free_page(scratch);
d67ae825 Tom Haynes      2014-12-11  553  	return ret;
d67ae825 Tom Haynes      2014-12-11  554  out_err_free:
d67ae825 Tom Haynes      2014-12-11  555  	_ff_layout_free_lseg(fls);
d67ae825 Tom Haynes      2014-12-11  556  	ret = ERR_PTR(rc);
d67ae825 Tom Haynes      2014-12-11  557  	dprintk("<-- %s (%d)\n", __func__, rc);
d67ae825 Tom Haynes      2014-12-11  558  	goto out_free_page;
d67ae825 Tom Haynes      2014-12-11  559  }
d67ae825 Tom Haynes      2014-12-11  560  

:::::: The code at line 517 was first introduced by commit
:::::: 3064b6861d00b7124558cdf79f9387f948361be3 nfs: have flexfiles mirror keep creds for both ro and rw layouts

:::::: TO: Jeff Layton <jlayton@poochiereds.net>
:::::: CC: Anna Schumaker <Anna.Schumaker@Netapp.com>

---
0-DAY kernel test infrastructure                Open Source Technology Center
https://lists.01.org/pipermail/kbuild-all                   Intel Corporation

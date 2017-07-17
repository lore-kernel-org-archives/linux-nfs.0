Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([173.255.197.46]:42684 "EHLO fieldses.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751314AbdGQSon (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Mon, 17 Jul 2017 14:44:43 -0400
Date: Mon, 17 Jul 2017 14:44:42 -0400
To: kbuild test robot <lkp@intel.com>
Cc: "J. Bruce Fields" <bfields@redhat.com>, kbuild-all@01.org,
        linux-nfs@vger.kernel.org
Subject: Re: [PATCH 3/5] nfsd4: define ->op_release for compound ops
Message-ID: <20170717184442.GA11947@fieldses.org>
References: <1500063895-29457-4-git-send-email-bfields@redhat.com>
 <201707151746.L72xqYjA%fengguang.wu@intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <201707151746.L72xqYjA%fengguang.wu@intel.com>
From: bfields@fieldses.org (J. Bruce Fields)
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Sat, Jul 15, 2017 at 05:27:48PM +0800, kbuild test robot wrote:
> Hi Bruce,
> 
> [auto build test ERROR on next-20170710]
> [cannot apply to nfsd/nfsd-next v4.12 v4.12-rc7 v4.12-rc6 v4.12]
> [if your patch is applied to the wrong git tree, please drop us a note to help improve the system]

These patches depend on patches that are in 13-rc1.

--b.

> 
> url:    https://github.com/0day-ci/linux/commits/J-Bruce-Fields/skip-op-encoders-in-error-cases/20170715-165807
> config: xtensa-allyesconfig (attached as .config)
> compiler: xtensa-linux-gcc (GCC) 4.9.0
> reproduce:
>         wget https://raw.githubusercontent.com/01org/lkp-tests/master/sbin/make.cross -O ~/bin/make.cross
>         chmod +x ~/bin/make.cross
>         # save the attached .config to linux build tree
>         make.cross ARCH=xtensa 
> 
> All error/warnings (new ones prefixed by >>):
> 
>    fs/nfsd/nfs4proc.c: In function 'nfsd4_getdeviceinfo_release':
> >> fs/nfsd/nfs4proc.c:1356:8: error: 'gdev' undeclared (first use in this function)
>      kfree(gdev->gd_device);
>            ^
>    fs/nfsd/nfs4proc.c:1356:8: note: each undeclared identifier is reported only once for each function it appears in
>    fs/nfsd/nfs4proc.c: At top level:
> >> fs/nfsd/nfs4proc.c:1439:1: warning: return type defaults to 'int' [-Wreturn-type]
>     nfsd4_layoutget_release(union nfsd4_op_u *u)
>     ^
>    fs/nfsd/nfs4proc.c: In function 'nfsd4_layoutget_release':
> >> fs/nfsd/nfs4proc.c:1441:8: error: 'lgp' undeclared (first use in this function)
>      kfree(lgp->lg_content);
>            ^
>    fs/nfsd/nfs4proc.c: At top level:
> >> fs/nfsd/nfs4proc.c:2401:3: warning: initialization from incompatible pointer type
>       .op_release = nfsd4_layoutget_release,
>       ^
>    fs/nfsd/nfs4proc.c:2401:3: warning: (near initialization for 'nfsd4_ops[50].op_release')
>    fs/nfsd/nfs4proc.c: In function 'nfsd4_layoutget_release':
> >> fs/nfsd/nfs4proc.c:1442:1: warning: control reaches end of non-void function [-Wreturn-type]
>     }
>     ^
> 
> vim +/gdev +1356 fs/nfsd/nfs4proc.c
> 
>   1352	
>   1353	static void
>   1354	nfsd4_getdeviceinfo_release(union nfsd4_op_u *u)
>   1355	{
> > 1356		kfree(gdev->gd_device);
>   1357	}
>   1358	
>   1359	static __be32
>   1360	nfsd4_layoutget(struct svc_rqst *rqstp,
>   1361			struct nfsd4_compound_state *cstate, union nfsd4_op_u *u)
>   1362	{
>   1363		struct nfsd4_layoutget *lgp = &u->layoutget;
>   1364		struct svc_fh *current_fh = &cstate->current_fh;
>   1365		const struct nfsd4_layout_ops *ops;
>   1366		struct nfs4_layout_stateid *ls;
>   1367		__be32 nfserr;
>   1368		int accmode;
>   1369	
>   1370		switch (lgp->lg_seg.iomode) {
>   1371		case IOMODE_READ:
>   1372			accmode = NFSD_MAY_READ;
>   1373			break;
>   1374		case IOMODE_RW:
>   1375			accmode = NFSD_MAY_READ | NFSD_MAY_WRITE;
>   1376			break;
>   1377		default:
>   1378			dprintk("%s: invalid iomode %d\n",
>   1379				__func__, lgp->lg_seg.iomode);
>   1380			nfserr = nfserr_badiomode;
>   1381			goto out;
>   1382		}
>   1383	
>   1384		nfserr = fh_verify(rqstp, current_fh, 0, accmode);
>   1385		if (nfserr)
>   1386			goto out;
>   1387	
>   1388		nfserr = nfserr_layoutunavailable;
>   1389		ops = nfsd4_layout_verify(current_fh->fh_export, lgp->lg_layout_type);
>   1390		if (!ops)
>   1391			goto out;
>   1392	
>   1393		/*
>   1394		 * Verify minlength and range as per RFC5661:
>   1395		 *  o  If loga_length is less than loga_minlength,
>   1396		 *     the metadata server MUST return NFS4ERR_INVAL.
>   1397		 *  o  If the sum of loga_offset and loga_minlength exceeds
>   1398		 *     NFS4_UINT64_MAX, and loga_minlength is not
>   1399		 *     NFS4_UINT64_MAX, the error NFS4ERR_INVAL MUST result.
>   1400		 *  o  If the sum of loga_offset and loga_length exceeds
>   1401		 *     NFS4_UINT64_MAX, and loga_length is not NFS4_UINT64_MAX,
>   1402		 *     the error NFS4ERR_INVAL MUST result.
>   1403		 */
>   1404		nfserr = nfserr_inval;
>   1405		if (lgp->lg_seg.length < lgp->lg_minlength ||
>   1406		    (lgp->lg_minlength != NFS4_MAX_UINT64 &&
>   1407		     lgp->lg_minlength > NFS4_MAX_UINT64 - lgp->lg_seg.offset) ||
>   1408		    (lgp->lg_seg.length != NFS4_MAX_UINT64 &&
>   1409		     lgp->lg_seg.length > NFS4_MAX_UINT64 - lgp->lg_seg.offset))
>   1410			goto out;
>   1411		if (lgp->lg_seg.length == 0)
>   1412			goto out;
>   1413	
>   1414		nfserr = nfsd4_preprocess_layout_stateid(rqstp, cstate, &lgp->lg_sid,
>   1415							true, lgp->lg_layout_type, &ls);
>   1416		if (nfserr) {
>   1417			trace_layout_get_lookup_fail(&lgp->lg_sid);
>   1418			goto out;
>   1419		}
>   1420	
>   1421		nfserr = nfserr_recallconflict;
>   1422		if (atomic_read(&ls->ls_stid.sc_file->fi_lo_recalls))
>   1423			goto out_put_stid;
>   1424	
>   1425		nfserr = ops->proc_layoutget(d_inode(current_fh->fh_dentry),
>   1426					     current_fh, lgp);
>   1427		if (nfserr)
>   1428			goto out_put_stid;
>   1429	
>   1430		nfserr = nfsd4_insert_layout(lgp, ls);
>   1431	
>   1432	out_put_stid:
>   1433		mutex_unlock(&ls->ls_mutex);
>   1434		nfs4_put_stid(&ls->ls_stid);
>   1435	out:
>   1436		return nfserr;
>   1437	}
>   1438	
> > 1439	nfsd4_layoutget_release(union nfsd4_op_u *u)
>   1440	{
> > 1441		kfree(lgp->lg_content);
> > 1442	}
>   1443	
> 
> ---
> 0-DAY kernel test infrastructure                Open Source Technology Center
> https://lists.01.org/pipermail/kbuild-all                   Intel Corporation



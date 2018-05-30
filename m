Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mga07.intel.com ([134.134.136.100]:40014 "EHLO mga07.intel.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S932113AbeE3WOy (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Wed, 30 May 2018 18:14:54 -0400
Date: Thu, 31 May 2018 06:14:40 +0800
From: kbuild test robot <lkp@intel.com>
To: Trond Myklebust <trond.myklebust@hammerspace.com>
Cc: kbuild-all@01.org, linux-nfs@vger.kernel.org
Subject: [nfs:testing 20/40] fs//nfs/nfs4proc.c:412:3: error: duplicate case
 value
Message-ID: <201805310638.cX0fB6LF%fengguang.wu@intel.com>
MIME-Version: 1.0
Content-Type: multipart/mixed; boundary="2oS5YaxWCcQjTEyO"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


--2oS5YaxWCcQjTEyO
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

tree:   git://git.linux-nfs.org/projects/trondmy/linux-nfs.git testing
head:   168d4f8633f3fc0fdd9f3f062dec089e387fed4e
commit: df1024df0c749ae3350f3dec4d6be8e2dc344e4c [20/40] NFSv4: Always clear the pNFS layout when handling ESTALE
config: parisc-712_defconfig (attached as .config)
compiler: hppa-linux-gnu-gcc (Debian 7.2.0-11) 7.2.0
reproduce:
        wget https://raw.githubusercontent.com/intel/lkp-tests/master/sbin/make.cross -O ~/bin/make.cross
        chmod +x ~/bin/make.cross
        git checkout df1024df0c749ae3350f3dec4d6be8e2dc344e4c
        # save the attached .config to linux build tree
        make.cross ARCH=parisc 

All errors (new ones prefixed by >>):

   fs//nfs/nfs4proc.c: In function 'nfs4_do_handle_exception':
>> fs//nfs/nfs4proc.c:412:3: error: duplicate case value
      case -ESTALE:
      ^~~~
   fs//nfs/nfs4proc.c:411:3: note: previously used here
      case -NFS4ERR_STALE:
      ^~~~

vim +412 fs//nfs/nfs4proc.c

   387	
   388	/* This is the error handling routine for processes that are allowed
   389	 * to sleep.
   390	 */
   391	static int nfs4_do_handle_exception(struct nfs_server *server,
   392			int errorcode, struct nfs4_exception *exception)
   393	{
   394		struct nfs_client *clp = server->nfs_client;
   395		struct nfs4_state *state = exception->state;
   396		const nfs4_stateid *stateid = exception->stateid;
   397		struct inode *inode = exception->inode;
   398		int ret = errorcode;
   399	
   400		exception->delay = 0;
   401		exception->recovering = 0;
   402		exception->retry = 0;
   403	
   404		if (stateid == NULL && state != NULL)
   405			stateid = &state->stateid;
   406	
   407		switch(errorcode) {
   408			case 0:
   409				return 0;
   410			case -NFS4ERR_BADHANDLE:
   411			case -NFS4ERR_STALE:
 > 412			case -ESTALE:
   413				if (inode != NULL && S_ISREG(inode->i_mode))
   414					pnfs_destroy_layout(NFS_I(inode));
   415				break;
   416			case -NFS4ERR_DELEG_REVOKED:
   417			case -NFS4ERR_ADMIN_REVOKED:
   418			case -NFS4ERR_EXPIRED:
   419			case -NFS4ERR_BAD_STATEID:
   420				if (inode != NULL && stateid != NULL) {
   421					nfs_inode_find_state_and_recover(inode,
   422							stateid);
   423					goto wait_on_recovery;
   424				}
   425			case -NFS4ERR_OPENMODE:
   426				if (inode) {
   427					int err;
   428	
   429					err = nfs_async_inode_return_delegation(inode,
   430							stateid);
   431					if (err == 0)
   432						goto wait_on_recovery;
   433					if (stateid != NULL && stateid->type == NFS4_DELEGATION_STATEID_TYPE) {
   434						exception->retry = 1;
   435						break;
   436					}
   437				}
   438				if (state == NULL)
   439					break;
   440				ret = nfs4_schedule_stateid_recovery(server, state);
   441				if (ret < 0)
   442					break;
   443				goto wait_on_recovery;
   444			case -NFS4ERR_STALE_STATEID:
   445			case -NFS4ERR_STALE_CLIENTID:
   446				nfs4_schedule_lease_recovery(clp);
   447				goto wait_on_recovery;
   448			case -NFS4ERR_MOVED:
   449				ret = nfs4_schedule_migration_recovery(server);
   450				if (ret < 0)
   451					break;
   452				goto wait_on_recovery;
   453			case -NFS4ERR_LEASE_MOVED:
   454				nfs4_schedule_lease_moved_recovery(clp);
   455				goto wait_on_recovery;
   456	#if defined(CONFIG_NFS_V4_1)
   457			case -NFS4ERR_BADSESSION:
   458			case -NFS4ERR_BADSLOT:
   459			case -NFS4ERR_BAD_HIGH_SLOT:
   460			case -NFS4ERR_CONN_NOT_BOUND_TO_SESSION:
   461			case -NFS4ERR_DEADSESSION:
   462			case -NFS4ERR_SEQ_FALSE_RETRY:
   463			case -NFS4ERR_SEQ_MISORDERED:
   464				dprintk("%s ERROR: %d Reset session\n", __func__,
   465					errorcode);
   466				nfs4_schedule_session_recovery(clp->cl_session, errorcode);
   467				goto wait_on_recovery;
   468	#endif /* defined(CONFIG_NFS_V4_1) */
   469			case -NFS4ERR_FILE_OPEN:
   470				if (exception->timeout > HZ) {
   471					/* We have retried a decent amount, time to
   472					 * fail
   473					 */
   474					ret = -EBUSY;
   475					break;
   476				}
   477			case -NFS4ERR_DELAY:
   478				nfs_inc_server_stats(server, NFSIOS_DELAY);
   479			case -NFS4ERR_GRACE:
   480			case -NFS4ERR_LAYOUTTRYLATER:
   481			case -NFS4ERR_RECALLCONFLICT:
   482				exception->delay = 1;
   483				return 0;
   484	
   485			case -NFS4ERR_RETRY_UNCACHED_REP:
   486			case -NFS4ERR_OLD_STATEID:
   487				exception->retry = 1;
   488				break;
   489			case -NFS4ERR_BADOWNER:
   490				/* The following works around a Linux server bug! */
   491			case -NFS4ERR_BADNAME:
   492				if (server->caps & NFS_CAP_UIDGID_NOMAP) {
   493					server->caps &= ~NFS_CAP_UIDGID_NOMAP;
   494					exception->retry = 1;
   495					printk(KERN_WARNING "NFS: v4 server %s "
   496							"does not accept raw "
   497							"uid/gids. "
   498							"Reenabling the idmapper.\n",
   499							server->nfs_client->cl_hostname);
   500				}
   501		}
   502		/* We failed to handle the error */
   503		return nfs4_map_errors(ret);
   504	wait_on_recovery:
   505		exception->recovering = 1;
   506		return 0;
   507	}
   508	

---
0-DAY kernel test infrastructure                Open Source Technology Center
https://lists.01.org/pipermail/kbuild-all                   Intel Corporation

--2oS5YaxWCcQjTEyO
Content-Type: application/gzip
Content-Disposition: attachment; filename=".config.gz"
Content-Transfer-Encoding: base64

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

--2oS5YaxWCcQjTEyO--

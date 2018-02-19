Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mga06.intel.com ([134.134.136.31]:33240 "EHLO mga06.intel.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751429AbeBSOlJ (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Mon, 19 Feb 2018 09:41:09 -0500
Date: Mon, 19 Feb 2018 22:41:04 +0800
From: kbuild test robot <lkp@intel.com>
To: NeilBrown <neilb@suse.com>
Cc: kbuild-all@01.org,
        Trond Myklebust <trond.myklebust@primarydata.com>,
        Anna Schumaker <anna.schumaker@netapp.com>,
        linux-nfs@vger.kernel.org
Subject: Re: [PATCH 12/23] NFS/SUNRPC: don't lookup machine credential until
 rpcauth_bindcred().
Message-ID: <201802192255.remnWsHA%fengguang.wu@intel.com>
References: <151901654917.17421.591694583443039725.stgit@noble>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <151901654917.17421.591694583443039725.stgit@noble>
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

>> net/sunrpc/auth.c:700:34: sparse: incorrect type in initializer (different address spaces) @@ expected struct cred const @@ got struct cred const [addrestruct cred const @@
   net/sunrpc/auth.c:700:34: expected struct cred const
   net/sunrpc/auth.c:700:34: got struct cred const cred

vim +700 net/sunrpc/auth.c

   693	
   694	static struct rpc_cred *
   695	rpcauth_bind_machine_cred(struct rpc_task *task, int lookupflags)
   696	{
   697		struct rpc_auth *auth = task->tk_client->cl_auth;
   698		struct auth_cred acred = {
   699			.principal = task->tk_client->cl_principal,
 > 700			.cred = init_task.cred,
   701		};
   702	
   703		if (!acred.principal)
   704			return NULL;
   705		dprintk("RPC: %5u looking up %s machine cred\n",
   706			task->tk_pid, task->tk_client->cl_auth->au_ops->au_name);
   707		return auth->au_ops->lookup_cred(auth, &acred, lookupflags);
   708	}
   709	

---
0-DAY kernel test infrastructure                Open Source Technology Center
https://lists.01.org/pipermail/kbuild-all                   Intel Corporation

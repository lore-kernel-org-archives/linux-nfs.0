Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mga11.intel.com ([192.55.52.93]:37881 "EHLO mga11.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751723Ab2GQAOQ (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 16 Jul 2012 20:14:16 -0400
Date: Tue, 17 Jul 2012 08:14:10 +0800
From: Fengguang Wu <fengguang.wu@intel.com>
To: Chuck Lever <chuck.lever@oracle.com>
Cc: kernel-janitors@vger.kernel.org, Linux-NFS <linux-nfs@vger.kernel.org>
Subject: [nfs:nfs-for-bryan 100/100]
 net/sunrpc/auth_gss/gss_mech_switch.c:252:5: sparse: context imbalance in
 'gss_mech_list_pseudoflavors' - wrong count at exit
Message-ID: <20120717001410.GD16944@localhost>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi Chuck,

There are new sparse warnings (likely a true locking bug) show up in

tree:   git://git.linux-nfs.org/projects/trondmy/linux-nfs.git nfs-for-bryan
head:   6a1a1e34dc55f17e7bd260809207442dbb7a0296
commit: 6a1a1e34dc55f17e7bd260809207442dbb7a0296 [100/100] SUNRPC: Add rpcauth_list_flavors()

All sparse warnings:

  net/sunrpc/auth_gss/gss_mech_switch.c:143:21: sparse: symbol '_gss_mech_get_by_name' was not declared. Should it be static?
  net/sunrpc/auth_gss/gss_mech_switch.c:208:21: sparse: symbol '_gss_mech_get_by_pseudoflavor' was not declared. Should it be static?
+ net/sunrpc/auth_gss/gss_mech_switch.c:252:5: sparse: context imbalance in 'gss_mech_list_pseudoflavors' - wrong count at exit

vim +252 net/sunrpc/auth_gss/gss_mech_switch.c
   249	 * The returned array is not sorted by any policy.  Callers should not
   250	 * rely on the order of the items in the returned array.
   251	 */
 > 252	int gss_mech_list_pseudoflavors(rpc_authflavor_t *array_ptr, int size)
   253	{
   254		struct gss_api_mech *pos = NULL;
   255		int j, i = 0;

---
0-DAY kernel build testing backend         Open Source Technology Centre
Fengguang Wu <wfg@linux.intel.com>                     Intel Corporation

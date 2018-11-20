Return-Path: <SRS0=9Ter=N7=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,MENTIONS_GIT_HOSTING,SPF_PASS autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 4158EC43441
	for <linux-nfs@archiver.kernel.org>; Tue, 20 Nov 2018 05:58:51 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id EAEBB2075B
	for <linux-nfs@archiver.kernel.org>; Tue, 20 Nov 2018 05:58:50 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org EAEBB2075B
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=lip6.fr
Authentication-Results: mail.kernel.org; spf=none smtp.mailfrom=linux-nfs-owner@vger.kernel.org
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1730710AbeKTQ0K (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Tue, 20 Nov 2018 11:26:10 -0500
Received: from mail2-relais-roc.national.inria.fr ([192.134.164.83]:37450 "EHLO
        mail2-relais-roc.national.inria.fr" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1726982AbeKTQ0K (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Tue, 20 Nov 2018 11:26:10 -0500
X-IronPort-AV: E=Sophos;i="5.56,255,1539640800"; 
   d="scan'208";a="356364122"
Received: from abo-186-120-68.mrs.modulonet.fr (HELO hadrien) ([85.68.120.186])
  by mail2-relais-roc.national.inria.fr with ESMTP/TLS/DHE-RSA-AES256-GCM-SHA384; 20 Nov 2018 06:58:43 +0100
Date:   Tue, 20 Nov 2018 06:58:43 +0100 (CET)
From:   Julia Lawall <julia.lawall@lip6.fr>
X-X-Sender: jll@hadrien
To:     Olga Kornievskaia <olga.kornievskaia@gmail.com>
cc:     trond.myklebust@hammerspace.com, anna.schumaker@netapp.com,
        linux-nfs@vger.kernel.org, linux-nfs@vger.kernel.org,
        kbuild-all@01.org
Subject: Re: [PATCH 1/1] NFSv4.2 do not allocate memory under the lock
 (fwd)
Message-ID: <alpine.DEB.2.21.1811200654450.2553@hadrien>
User-Agent: Alpine 2.21 (DEB 202 2017-01-01)
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

Hello,

At the end of the function, if found is false then the inner
list_for_each_entry has executed.  Once that happens, the copy allocated
at the beginning of the function is no longer visible.  In particular,
copy will be bound to the dummy element at the beginning/end of the list.

julia

---------- Forwarded message ----------
Date: Tue, 20 Nov 2018 13:26:31 +0800
From: kbuild test robot <lkp@intel.com>
To: kbuild@01.org
Cc: Julia Lawall <julia.lawall@lip6.fr>
Subject: Re: [PATCH 1/1] NFSv4.2 do not allocate memory under the lock

CC: kbuild-all@01.org
In-Reply-To: <20181116162623.50517-1-olga.kornievskaia@gmail.com>
References: <20181116162623.50517-1-olga.kornievskaia@gmail.com>
TO: Olga Kornievskaia <olga.kornievskaia@gmail.com>
CC: trond.myklebust@hammerspace.com, anna.schumaker@netapp.com, linux-nfs@vger.kernel.org
CC: linux-nfs@vger.kernel.org

Hi Olga,

Thank you for the patch! Perhaps something to improve:

[auto build test WARNING on nfs/linux-next]
[also build test WARNING on v4.20-rc3 next-20181119]
[if your patch is applied to the wrong git tree, please drop us a note to help improve the system]

url:    https://github.com/0day-ci/linux/commits/Olga-Kornievskaia/NFSv4-2-do-not-allocate-memory-under-the-lock/20181119-202157
base:   git://git.linux-nfs.org/projects/trondmy/linux-nfs.git linux-next
:::::: branch date: 17 hours ago
:::::: commit date: 17 hours ago

>> fs/nfs/callback_proc.c:714:10-14: ERROR: invalid reference to the index variable of the iterator on line 700
   fs/nfs/callback_proc.c:718:8-12: ERROR: invalid reference to the index variable of the iterator on line 700

# https://github.com/0day-ci/linux/commit/65d4b7555e18c7c43f4410c07503c9b5e06dd75e
git remote add linux-review https://github.com/0day-ci/linux
git remote update linux-review
git checkout 65d4b7555e18c7c43f4410c07503c9b5e06dd75e
vim +714 fs/nfs/callback_proc.c

62164f317 Olga Kornievskaia 2018-07-09  683
62164f317 Olga Kornievskaia 2018-07-09  684  __be32 nfs4_callback_offload(void *data, void *dummy,
5178a125f Olga Kornievskaia 2018-07-09  685  			     struct cb_process_state *cps)
5178a125f Olga Kornievskaia 2018-07-09  686  {
62164f317 Olga Kornievskaia 2018-07-09  687  	struct cb_offloadargs *args = data;
62164f317 Olga Kornievskaia 2018-07-09  688  	struct nfs_server *server;
62164f317 Olga Kornievskaia 2018-07-09  689  	struct nfs4_copy_state *copy;
bc0c9079b Olga Kornievskaia 2018-07-09  690  	bool found = false;
62164f317 Olga Kornievskaia 2018-07-09  691
65d4b7555 Olga Kornievskaia 2018-11-16  692  	copy = kzalloc(sizeof(struct nfs4_copy_state), GFP_NOFS);
65d4b7555 Olga Kornievskaia 2018-11-16  693  	if (!copy)
65d4b7555 Olga Kornievskaia 2018-11-16  694  		return htonl(NFS4ERR_SERVERFAULT);
65d4b7555 Olga Kornievskaia 2018-11-16  695
bc0c9079b Olga Kornievskaia 2018-07-09  696  	spin_lock(&cps->clp->cl_lock);
62164f317 Olga Kornievskaia 2018-07-09  697  	rcu_read_lock();
62164f317 Olga Kornievskaia 2018-07-09  698  	list_for_each_entry_rcu(server, &cps->clp->cl_superblocks,
62164f317 Olga Kornievskaia 2018-07-09  699  				client_link) {
62164f317 Olga Kornievskaia 2018-07-09 @700  		list_for_each_entry(copy, &server->ss_copies, copies) {
62164f317 Olga Kornievskaia 2018-07-09  701  			if (memcmp(args->coa_stateid.other,
62164f317 Olga Kornievskaia 2018-07-09  702  					copy->stateid.other,
62164f317 Olga Kornievskaia 2018-07-09  703  					sizeof(args->coa_stateid.other)))
62164f317 Olga Kornievskaia 2018-07-09  704  				continue;
62164f317 Olga Kornievskaia 2018-07-09  705  			nfs4_copy_cb_args(copy, args);
62164f317 Olga Kornievskaia 2018-07-09  706  			complete(&copy->completion);
bc0c9079b Olga Kornievskaia 2018-07-09  707  			found = true;
62164f317 Olga Kornievskaia 2018-07-09  708  			goto out;
62164f317 Olga Kornievskaia 2018-07-09  709  		}
62164f317 Olga Kornievskaia 2018-07-09  710  	}
62164f317 Olga Kornievskaia 2018-07-09  711  out:
62164f317 Olga Kornievskaia 2018-07-09  712  	rcu_read_unlock();
bc0c9079b Olga Kornievskaia 2018-07-09  713  	if (!found) {
bc0c9079b Olga Kornievskaia 2018-07-09 @714  		memcpy(&copy->stateid, &args->coa_stateid, NFS4_STATEID_SIZE);

:::::: The code at line 714 was first introduced by commit
:::::: bc0c9079b48ddcf1f8a6e1aaa277288b263c78d8 NFS handle COPY reply CB_OFFLOAD call race

:::::: TO: Olga Kornievskaia <kolga@netapp.com>
:::::: CC: Anna Schumaker <Anna.Schumaker@Netapp.com>

---
0-DAY kernel test infrastructure                Open Source Technology Center
https://lists.01.org/pipermail/kbuild-all                   Intel Corporation

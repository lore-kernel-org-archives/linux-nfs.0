Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from daytona.panasas.com ([67.152.220.89]:57970 "EHLO
	daytona.int.panasas.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1751635Ab0EKVJ7 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 11 May 2010 17:09:59 -0400
Message-ID: <4BE9C7A2.8030801@panasas.com>
Date: Wed, 12 May 2010 00:09:54 +0300
From: Benny Halevy <bhalevy@panasas.com>
To: "J. Bruce Fields" <bfields@citi.umich.edu>
CC: NFS list <linux-nfs@vger.kernel.org>
Subject: [PATCH v2 0/9] nfsd4: keep the client from expiring while in use
 by nfs41 compounds
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

Changes since first version:

- move clients to be expired by laundromat to temporary reaplist
  under the client lock.  Then release the lock and expire them
  without holding the client lock.

- mark clients as expired under the client lock, do not renew
  clients mark as expired

- fix an existing bug in nfsd4_destroy_session that must take the state lock
  for clearing the callback client.

[PATCH v2 1/9] nfsd4: rename sessionid_lock to client_lock
[PATCH v2 2/9] nfsd4: fold release_session into expire_client
[PATCH v2 3/9] nfsd4: use list_move in move_to_confirmed
[PATCH v2 4/9] nfsd4: extend the client_lock to cover cl_lru
[PATCH v2 5/9] nfsd4: refactor expire_client
[PATCH v2 6/9] nfsd4: introduce nfs4_client.cl_refcount
[PATCH v2 7/9] nfsd4: mark_client_expired
[PATCH v2 8/9] nfsd4: keep a reference count on client while in use
[PATCH v2 9/9] nfsd4: nfsd4_destroy_session must set callback client under the state lock

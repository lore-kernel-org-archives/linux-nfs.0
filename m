Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from daytona.panasas.com ([67.152.220.89]:2721 "EHLO
	daytona.int.panasas.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1762620AbZLPRj1 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 16 Dec 2009 12:39:27 -0500
Message-ID: <4B291B4C.3060603@panasas.com>
Date: Wed, 16 Dec 2009 19:39:24 +0200
From: Benny Halevy <bhalevy@panasas.com>
To: "J. Bruce Fields" <bfields@citi.umich.edu>
CC: pNFS Mailing List <pnfs@linux-nfs.org>,
        NFS list <linux-nfs@vger.kernel.org>
Subject: [RFC 0/11] state lock reduction prep
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

Bruce,

The following patches implement the first phase in preparation
for reducing the scope in we which we hold the state lock mutex.

[RFC 01/11] nfsd: introduce nfs4_client state
[RFC 02/11] nfsd: mark client state as expired in expire_client
[RFC 03/11] nfsd: introduce get_nfs4_client
[RFC 04/11] nfsd: mark client for renew
[RFC 05/11] nfsd: skip clients marked for renewal
[RFC 06/11] nfsd41: no need to hold the state lock around mark_client_for_renew

the patches above use an atomic cl_state field to manage the
nfs4_client expire vs. renew state so this can be done outside
the state lock.

[RFC 07/11] nfsd: rename recall_lock to deleg_lock
[RFC 08/11] nfsd: use deleg_lock to protect dl_perfile and dl_perclnt
[RFC 09/11] nfsd: get a reference count on the delgation while outside of the deleg_lock
[RFC 10/11] nfsd: close delegation only on last reference
[RFC 11/11] nfsd: refactor unhash_delegation

The patches above augment the use of the recall_lock spinlock
(and rename it to deleg_lock) and grab a reference count on
the delegation structure while not protected by the deleg_lock.
The delegation's respective file will be closed only on last
dereference, so the deleg structure could be used safely while
not holding the state_lock and potentially in parallel to
expire_client being called (and unhashing the delegation)

The next steps I see are:

1. use a spinlock for traversing the nfs4_client hash lists
2. use a spinlock for traversing the nfs4_stateowner lists

Eventually, reducing the state_lock scope for complex state changes
requiring the coordination of state across multiple lists
and involving blocking ops (e.g. allocation, manipulating clid_dir)
in particular there should be no need to hold the state lock
for expire_client.

Benny

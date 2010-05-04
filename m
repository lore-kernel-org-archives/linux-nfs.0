Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from daytona.panasas.com ([67.152.220.89]:23029 "EHLO
	daytona.int.panasas.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1754838Ab0EDWhg (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 4 May 2010 18:37:36 -0400
Message-ID: <4BE0A1AE.4040905@panasas.com>
Date: Wed, 05 May 2010 01:37:34 +0300
From: Benny Halevy <bhalevy@panasas.com>
To: "J. Bruce Fields" <bfields@citi.umich.edu>
CC: NFS list <linux-nfs@vger.kernel.org>
Subject: [PATCH 0/8] nfsd4: keep the client from expiring while in use by
 nfs41 compounds
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

Bruce,

The following patchset changes the scope of the sessionid spin lock
to cover both sessions and the client lru list and it introduces a
new reference count on the client that's manipulated under that new
client lock (not requiring the state mutex).

It's tested to pass connectathon tests as well as explicit session destroy
and implicit client expiry when the client is blown away.
However, I haven't tested the gist of this patchset which is to get
the client to perform a long enough compound during which it might time out...

[PATCH 1/8] nfsd4: rename sessionid_lock to client_lock
[PATCH 2/8] nfsd4: fold release_session into expire_client
[PATCH 3/8] nfsd4: use list_move in move_to_confirmed
[PATCH 4/8] nfsd4: extend the client_lock to cover cl_lru
[PATCH 5/8] nfsd4: refactor expire_client
[PATCH 6/8] nfsd4: introduce nfs4_client.cl_refcount
[PATCH 7/8] nfsd4: keep a reference count on client while in use

[PATCH 8/8] nfsd41: cstate->session can NULL in nfsd4_destroy_session
I think this was introduced in: 26c0c75 nfsd4: fix unlikely race in session replay case
though I'm not sure how it ever worked correctly...

Benny

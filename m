Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from citi.umich.edu ([141.211.133.111]:47698 "EHLO citi.umich.edu"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752451AbZD2V4K (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 29 Apr 2009 17:56:10 -0400
From: Kevin Coffman <kwc@citi.umich.edu>
Subject: [PATCH 0/7] nfs-utils: add support for authenticated callbacks
To: steved@redhat.com
Cc: linux-nfs@vger.kernel.org
Date: Wed, 29 Apr 2009 17:56:10 -0400
Message-ID: <20090429214300.25811.81332.stgit@jazz.citi.umich.edu>
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

This series adds support to gssd and svcgssd to support
authenticated callbacks.

1) adds the name the client used when authenticating to the
svcgssd downcall information.  This is used by nfsd to determine
the target name when initiating the callback.

2) splits out the processing of update_client_list() to accomodate
a new upcall pipe added in the next patch.

3) adds support in gssd to process the new nfsd4_cb pipe for callbacks

4) a debugging aid to distinquish "normal" upcalls and "callback" upcalls

5) adds support for the new text-based upcall format added in 2.6.29

6) adds support for handling the "target=" attribute in the new upcall

7) adds support for handling the "service=" attribute in the new upcall

NOTE:  For authenticated callbacks to work, an NFS client or an
NFS server must be running both rpcgssd _and_ rpcsvcgssd.
This will require a configuration change.

A future patch is planned to combine gssd and svcgssd into
a single daemon to make configuration easier.  However, there
are some architectural issues that must be resolved first.

---

Olga Kornievskaia (7):
      gssd: process service= attribute in new upcall
      gssd: process target= attribute in new upcall
      gssd: handle new client upcall
      gssd: print full client directory being handled
      gssd: add support for callback authentication
      gssd: refactor update_client_list()
      svcgssd: add client's principal name to downcall information


 utils/gssd/gssd.c           |    5 +
 utils/gssd/gssd.h           |    5 +
 utils/gssd/gssd_main_loop.c |   32 ++++
 utils/gssd/gssd_proc.c      |  351 ++++++++++++++++++++++++++++++++++++-------
 utils/gssd/krb5_util.c      |   21 ++-
 utils/gssd/krb5_util.h      |    3 
 utils/gssd/svcgssd_proc.c   |   94 +++++++++++-
 7 files changed, 436 insertions(+), 75 deletions(-)


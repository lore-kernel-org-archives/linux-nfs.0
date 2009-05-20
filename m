Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from citi.umich.edu ([141.211.133.111]:36488 "EHLO citi.umich.edu"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753825AbZETPUe (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 20 May 2009 11:20:34 -0400
From: Kevin Coffman <kwc@citi.umich.edu>
Subject: [round2 PATCH 0/7] nfs-utils: add support for authenticated callbacks
To: steved@redhat.com
Cc: linux-nfs@vger.kernel.org
Date: Wed, 20 May 2009 11:20:36 -0400
Message-ID: <20090520151651.2986.29621.stgit@jazz.citi.umich.edu>
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

Hi Steve,

This series adds support to gssd and svcgssd to support
authenticated callbacks.

1) adds the name the client used when authenticating to the
svcgssd downcall information.  This is used by nfsd to determine
the target name when initiating the callback.

2) splits out the processing of update_client_list() to accomodate
a new upcall pipe added in the next patch.

3) changes gssd to process all rpc_pipefs directories (this patch is
changed from the first round to process all directories rather than
special-casing directories)

4) a debugging aid to distinquish which upcall is being processed

6) adds support for handling the "target=" attribute in the new upcall

7) adds support for handling the "service=" attribute in the new upcall

NOTE:  For authenticated callbacks to work, an NFS client or an
NFS server must be running both rpcgssd _and_ rpcsvcgssd.
This will require a configuration change.

A future patch is planned to combine gssd and svcgssd into
a single daemon to make configuration easier.  However, there
are some architectural issues that must be resolved first.

---

Kevin Coffman (1):
      gssd: add upcall support for callback authentication

Olga Kornievskaia (6):
      gssd: process service= attribute in new upcall
      gssd: process target= attribute in new upcall
      gssd: handle new client upcall
      gssd: print full client directory being handled
      gssd: refactor update_client_list()
      svcgssd: add client's principal name to downcall information


 utils/gssd/gssd.c           |    6 -
 utils/gssd/gssd.h           |   12 +
 utils/gssd/gssd_main_loop.c |  102 +++++++++++-
 utils/gssd/gssd_proc.c      |  365 +++++++++++++++++++++++++++++++++++--------
 utils/gssd/krb5_util.c      |   21 ++
 utils/gssd/krb5_util.h      |    3 
 utils/gssd/svcgssd_proc.c   |   94 ++++++++++-
 7 files changed, 505 insertions(+), 98 deletions(-)


Return-Path: linux-nfs-owner@vger.kernel.org
Received: from userp1040.oracle.com ([156.151.31.81]:27975 "EHLO
	userp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752390Ab3GXWEX convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 24 Jul 2013 18:04:23 -0400
Content-Type: text/plain; charset=us-ascii
Mime-Version: 1.0 (Mac OS X Mail 6.5 \(1508\))
Subject: Re: [PATCH v1 09/19] NFS: Add a "struct nfs_server *" argument to nfs4_sequence_done()
From: Chuck Lever <chuck.lever@oracle.com>
In-Reply-To: <1374521276.7972.31.camel@leira.trondhjem.org>
Date: Wed, 24 Jul 2013 18:04:15 -0400
Cc: Linux NFS Mailing List <linux-nfs@vger.kernel.org>,
        Andy Adamson <William.Adamson@netapp.com>,
        David Noveck <david.noveck@emc.com>
Message-Id: <CA3DFD27-B77A-4314-A02A-856339C033E3@oracle.com>
References: <20130712155303.1444.62697.stgit@seurat.1015granger.net> <20130712163245.1444.48096.stgit@seurat.1015granger.net> <1374521276.7972.31.camel@leira.trondhjem.org>
To: "Myklebust, Trond" <Trond.Myklebust@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


On Jul 22, 2013, at 3:27 PM, "Myklebust, Trond" <Trond.Myklebust@netapp.com> wrote:

> On Fri, 2013-07-12 at 12:32 -0400, Chuck Lever wrote:
>> For NFSv4.1, a session slot table reference is passed to
>> nfs4_sequence_done().
>> 
>> For NFSv4.0, transport state is managed in the nfs_client that owns
>> this nfs_server.  The nfs_server struct must be passed to
>> nfs4_sequence_done() to make it available to the functions dealing
>> with transport blocking.
> 
> Why? Can't 4.0 just reuse the existing v4.1 session slot table for this?

Before commit 774d5f14 "NFSv4.1 Fix a pNFS session draining deadlock," Mon May 20 14:13:50 2013, the DRAINING bit was in nfs4_session, not in nfs4_slot_table.  Before that commit, I would have had to enable most of the NFSv4.1 sessions code to re-use it for NFSv4.0 transport blocking.

(And btw, thanks Andy!  774d5f14 is a very useful refactoring).

I spent the last couple of days re-implementing my NFSv4.0 transport blocking mechanism based on the slot table abstraction, rather than adding similar fields to the nfs_client.  At this point, it looks like a workable approach, but I won't get it finished and tested before I head to Berlin.  I may have some time to continue work while I'm there.

Since our town hall meeting is cancelled this week, let me report on progress with migration support.

I was hoping to publish my 3.11-rc port of the migration patches today for another round of review, but I'm not going to make it due to the complexity of rebasing the transport blocking mechanism directly on struct nfs4_slot_table.  It will be at the top of my list when I get back.

I was able to check off some of the test cases I mentioned in the cover letter for the v1 patch series:

Migration with no TSM:  identified and fixed a client bug, then was able to witness state recovery during a successful migration.  The server prototype currently reports NFS4ERR_EXPIRED, so state recovery in this case involves OPEN(CLAIM_NULL) - the server is not in a grace period, and it is possible for clients to lose their locks.

Migration during a lock-intensive workload:  the server prototype is still attempting to put off client requests without using NFS4ERR_DELAY, which causes the client workload to terminate; waiting for that to be addressed, then will try again.

Migration recovery failure:  identified the need for more infrastructure to communicate state manager failure back to forward NFS processes.  That infrastructure has been added, but not yet tested.

The idea is that all I/O on the mount should fail after a migration, but an admin should be able to unmount cleanly.  In other words, manual recovery by remounting the FSID on the destination server, which is what would happen in the pre-migration world.

Migration with Kerberos:  exploring KDC resources available for testing my client with the server prototypes that are located in our Austin lab.

-- 
Chuck Lever
chuck[dot]lever[at]oracle[dot]com





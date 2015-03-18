Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:41429 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756376AbbCRRLM (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 18 Mar 2015 13:11:12 -0400
Received: from int-mx10.intmail.prod.int.phx2.redhat.com (int-mx10.intmail.prod.int.phx2.redhat.com [10.5.11.23])
	by mx1.redhat.com (8.14.4/8.14.4) with ESMTP id t2IHBBfc027299
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-GCM-SHA384 bits=256 verify=FAIL)
	for <linux-nfs@vger.kernel.org>; Wed, 18 Mar 2015 13:11:12 -0400
Received: from [10.10.53.118] (vpn-53-118.rdu2.redhat.com [10.10.53.118])
	by int-mx10.intmail.prod.int.phx2.redhat.com (8.14.4/8.14.4) with ESMTP id t2IHBAaH031352
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-GCM-SHA384 bits=256 verify=NO)
	for <linux-nfs@vger.kernel.org>; Wed, 18 Mar 2015 13:11:11 -0400
Date: Wed, 18 Mar 2015 13:11:10 -0400 (EDT)
From: Benjamin Coddington <bcodding@redhat.com>
To: linux-nfs@vger.kernel.org
Subject: BAD_SEQID drops state_owner, but lock stateid can still be found
Message-ID: <alpine.OSX.2.19.9992.1503181243090.947@planck.local>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

I'm working on a RHEL6 bug where the client gets stuck in a
WRITE,BAD_STATEID loop forever, and it looks like what happens is the write
continually picks a delegated write lock stateid in nfs4_select_rw_stateid()
for the write which never gets cleaned up in the state machine because a
previous OPEN during recovery had a BAD_SEQID come in which dropped the
state_owner.

Does it make sense to try to find lock stateids and set NFS_LOCK_LOST if
we're going to drop the state_owner?

It may be entirely impossible to reproduce the problem upstream, but I
figured I'd ask while I try..

Ben

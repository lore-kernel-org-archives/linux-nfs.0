Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:44990 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750852AbbCSKss (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 19 Mar 2015 06:48:48 -0400
Received: from int-mx13.intmail.prod.int.phx2.redhat.com (int-mx13.intmail.prod.int.phx2.redhat.com [10.5.11.26])
	by mx1.redhat.com (8.14.4/8.14.4) with ESMTP id t2JAmmjj026104
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-GCM-SHA384 bits=256 verify=FAIL)
	for <linux-nfs@vger.kernel.org>; Thu, 19 Mar 2015 06:48:48 -0400
Received: from [10.10.54.212] (vpn-54-212.rdu2.redhat.com [10.10.54.212])
	by int-mx13.intmail.prod.int.phx2.redhat.com (8.14.4/8.14.4) with ESMTP id t2JAmldF028997
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-GCM-SHA384 bits=256 verify=NO)
	for <linux-nfs@vger.kernel.org>; Thu, 19 Mar 2015 06:48:48 -0400
Date: Thu, 19 Mar 2015 06:48:47 -0400 (EDT)
From: Benjamin Coddington <bcodding@redhat.com>
To: linux-nfs@vger.kernel.org
Subject: Recovery after BAD_SEQID
Message-ID: <alpine.OSX.2.19.9992.1503190633310.947@planck.local>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

I wrote yesterday about a RHEL6 bug, but I'd gotten some details wrong about
the problem, so I'm starting new thread.

It looks like getting BAD_SEQID back from an OPEN operation drops the state_owner
which means that the state machine can't find or recover any other objects
for that state_owner.  That can get the client into unrecoverable loops.  I
can produce one of them with:

1) OPEN file1, OPEN file2
2) break the network for longer than the lease period
3) during recovery, have the server return BAD_SEQID for one of the OPENS
4) break the network again for longer than the lease period
5) WRITE to the file that recovered properly in #3

This gets stuck in WRITE,NFS4ERR_EXPIRED.

It looks like some cleanup is needed if we have to drop the whole
state_owner.  Alternatively, does it make sense to just drop the objects in
that sequence?

Ben

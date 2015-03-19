Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:57379 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755091AbbCSKNG (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 19 Mar 2015 06:13:06 -0400
Received: from int-mx11.intmail.prod.int.phx2.redhat.com (int-mx11.intmail.prod.int.phx2.redhat.com [10.5.11.24])
	by mx1.redhat.com (8.14.4/8.14.4) with ESMTP id t2JAD5f6006667
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-GCM-SHA384 bits=256 verify=FAIL)
	for <linux-nfs@vger.kernel.org>; Thu, 19 Mar 2015 06:13:06 -0400
Received: from [10.10.54.212] (vpn-54-212.rdu2.redhat.com [10.10.54.212])
	by int-mx11.intmail.prod.int.phx2.redhat.com (8.14.4/8.14.4) with ESMTP id t2JAD493024349
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-GCM-SHA384 bits=256 verify=NO)
	for <linux-nfs@vger.kernel.org>; Thu, 19 Mar 2015 06:13:05 -0400
Date: Thu, 19 Mar 2015 06:13:04 -0400 (EDT)
From: Benjamin Coddington <bcodding@redhat.com>
To: linux-nfs@vger.kernel.org
Subject: Re: BAD_SEQID drops state_owner, but lock stateid can still be
 found
In-Reply-To: <alpine.OSX.2.19.9992.1503181243090.947@planck.local>
Message-ID: <alpine.OSX.2.19.9992.1503190559290.947@planck.local>
References: <alpine.OSX.2.19.9992.1503181243090.947@planck.local>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, 18 Mar 2015, Benjamin Coddington wrote:

> I'm working on a RHEL6 bug where the client gets stuck in a
> WRITE,BAD_STATEID loop forever, and it looks like what happens is the write
> continually picks a delegated write lock stateid in nfs4_select_rw_stateid()
> for the write which never gets cleaned up in the state machine because a
> previous OPEN during recovery had a BAD_SEQID come in which dropped the
> state_owner.
>
> Does it make sense to try to find lock stateids and set NFS_LOCK_LOST if
> we're going to drop the state_owner?
>
> It may be entirely impossible to reproduce the problem upstream, but I
> figured I'd ask while I try..

So, I'm wrong about what's actually happening here -- so please ignore me
for the time being.  I didn't see that a local lock on a write delegation
doesn't have a ls_stateid - which makes perfect sense.  I still think
there's a problem, but this description of it is inaccurate..

TL;DR - Ben bashes head against state machine, gets it wrong.

Ben

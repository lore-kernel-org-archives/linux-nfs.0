Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:8618 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755497Ab0DITkT (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 9 Apr 2010 15:40:19 -0400
Received: from int-mx02.intmail.prod.int.phx2.redhat.com (int-mx02.intmail.prod.int.phx2.redhat.com [10.5.11.12])
	by mx1.redhat.com (8.13.8/8.13.8) with ESMTP id o39JeJ8h009740
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=OK)
	for <linux-nfs@vger.kernel.org>; Fri, 9 Apr 2010 15:40:19 -0400
Received: from redhat.com (null.msp.redhat.com [10.15.80.136])
	by int-mx02.intmail.prod.int.phx2.redhat.com (8.13.8/8.13.8) with SMTP id o39JeJn5017202
	for <linux-nfs@vger.kernel.org>; Fri, 9 Apr 2010 15:40:19 -0400
Date: Fri, 9 Apr 2010 14:40:18 -0500
From: David Teigland <teigland@redhat.com>
To: linux-nfs@vger.kernel.org
Subject: lockd and lock cancellation
Message-ID: <20100409194018.GA11823@redhat.com>
Content-Type: text/plain; charset=us-ascii
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

Here's what I think was the first time we discussed cancelation and
Bruce's provisional locks: http://marc.info/?t=116538335700005&r=1&w=2
I'm still skeptical of trying to handle cancels, it seems too complex to
become reliable in the lifetime of nfs3.

What I would be interested to see fixed is this oops that's not difficult
to trigger by doing lock/unlock loops on a client:
https://bugzilla.redhat.com/show_bug.cgi?id=502977#c18

But, for all the kernel work on these nfs/gfs/dlm hooks, there's a larger
issue that no one is working on AFAIK:  the mechanisms for recovering
client locks on remaining gfs nodes when one gfs node fails.  That would
take a lot of work, and until it's done all the kernel apis will be a moot
point since clustered nfs locks on gfs will be unusable.

Dave


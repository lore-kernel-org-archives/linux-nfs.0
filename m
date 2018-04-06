Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx3-rdu2.redhat.com ([66.187.233.73]:45804 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1752586AbeDFOop (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Fri, 6 Apr 2018 10:44:45 -0400
From: David Howells <dhowells@redhat.com>
In-Reply-To: <152287959470.14760.10350886166577848180.stgit@warthog.procyon.org.uk>
References: <152287959470.14760.10350886166577848180.stgit@warthog.procyon.org.uk>
To: torvalds@linux-foundation.org
Cc: dhowells@redhat.com, linux-nfs@vger.kernel.org,
        linux-kernel@vger.kernel.org, linux-cachefs@redhat.com,
        linux-fsdevel@vger.kernel.org, linux-afs@lists.infradead.org
Subject: Re: [PATCH net-next 00/12] fscache: Fixes, traces and development
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Date: Fri, 06 Apr 2018 15:44:40 +0100
Message-ID: <4034.1523025880@warthog.procyon.org.uk>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi Linus,

I've fixed a bug in the final patch that was found by the kbuild test robot
and disabled a debugging statement in an earlier one.  This is now tagged as:

	git://git.kernel.org/pub/scm/linux/kernel/git/dhowells/linux-fs.git
	tags/fscache-next-20180406

Do you want me to repost the patchset?

David

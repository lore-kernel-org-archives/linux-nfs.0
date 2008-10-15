From: andros@netapp.com
Subject: [PATCH 0/3] NFSD EOS deferral
Date: Wed, 15 Oct 2008 17:00:23 -0400
Message-ID: <1224104426-12293-1-git-send-email-andros@netapp.com>
Cc: bfields@fieldses.org
To: linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:39118 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752844AbYJOVA2 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 15 Oct 2008 17:00:28 -0400
In-Reply-To: <>
References: <>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Here's a patch set for review - it compiles and seems to work, but I haven't
done stress testing, nor testing of all of the combinations of deferral cases.

A deferral occurs when NFSD needs information from an rpc cache, and an upcall
is required. Instead of NFSD waiting for the cache to be filled by the upcall,
the RPC request is inserted back into the receive stream for processing at a
later time.

Exactly once semantics require that NFSD compound RPC deferral processing
restart at the operation that caused the deferral, instead of reprocessing the
full compound RPC from the start possibly repeating operation processing.
These patches add three callbacks, a data pointer, and page pointer storage
to the sunrpc svc deferral architecture that NFSD uses to accomplish this goal.

Deferrals that do not define the callbacks act as before. Care has been taken
to ensure that combinations of deferrals - those from the NFSv4 server with
the callbacks defined, and those from the RPC layer without the callbacks
defined work together correctly.

Thoughts, comments and suggestions are really appreciated...

-->Andy Adamson <andros@netapp.com>



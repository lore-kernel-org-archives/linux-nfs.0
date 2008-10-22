From: andros@netapp.com
Subject: [PATCH 0/3] NFSD EOS deferral
Date: Wed, 22 Oct 2008 14:12:03 -0400
Message-ID: <1224699126-3762-1-git-send-email-andros@netapp.com>
Cc: androsadamson@gmail.com
To: linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:22722 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753057AbYJVSMJ (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 22 Oct 2008 14:12:09 -0400
In-Reply-To: <>
References: <>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Here's a resend of the deferral patch set for review , responding to comments
on the last patch set.

A deferral occurs when NFSD needs information from an rpc cache, and an upcall
is required. Instead of NFSD waiting for the cache to be filled by the upcall,
the RPC request is inserted back into the receive stream for processing at a
later time.

Exactly once semantics require that NFSD compound RPC deferral processing
restart at the operation that caused the deferral, instead of reprocessing the
full compound RPC from the start possibly repeating operation processing.
These patches add three callbacks, a data pointer, and dynamic page pointer
storage to the sunrpc svc deferral architecture that NFSD uses to accomplish
this goal.

Deferrals that do not define the callbacks act as before. Care has been taken
to ensure that combinations of deferrals - those from the NFSv4 server with
the callbacks defined, and those from the RPC layer without the callbacks
defined work together correctly.

NEW:

I've limited the number of pages held by all deferrals to the number of pages
in the rpc maximum payload - the same as adding another nfsd thread.
Most deferrals (most requests) fit in a page or two. We want to service
the rare deferral where a large readdir or read reply is followed by a
deferral, this limit allows the servicing of one such request at time.

I've changed the deferral page pointer storage from static to dynamic.
The new svc_rqst fields are initialized in the beginning of svc_process
along with the rest of the fields.

As always, thoughts, comments and suggestions welcome.

-->Andy


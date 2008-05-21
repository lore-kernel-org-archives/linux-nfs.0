From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 0/6] Initial set of 2.6.27 patches, take 3
Date: Wed, 21 May 2008 14:15:33 -0400
Message-ID: <20080521180231.3295.84997.stgit@ellison>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Cc: linux-nfs@vger.kernel.org
To: trond.myklebust@netapp.com
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from rgminet01.oracle.com ([148.87.113.118]:32722 "EHLO
	rgminet01.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S935252AbYEUSTw (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 21 May 2008 14:19:52 -0400
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi Trond-

Resending the first batch of 2.6.27 patches, with additional fixes.

Using the RPC procedure name in debugging messages should no longer add a
risk of a segmentation fault.

I've also done a third re-implementation of the tk_action function name
patch.  I finally managed to find an interface that will perform the symbol
table lookup, and can be called from a module or from built-in code.

Oddly this API has been around for a while; I'm not sure how I missed it
originally.  But it should implement the nice function-name-rather-than-
memory-address feature without a wonky table, and without requiring any
additional changes when adding a new FSM state function.  It will display
the function name if the lookup succeeds; otherwise it will display a hex
memory address.  It works for any arbitrary pointer stored in the
tk_action field.

I've thought of a couple of other ways rpc_show_tasks() could be improved.
First, it could display the IP address of the server handling each request;
and it should have a different column layout for systems with 64-bit
addresses.  All for another day, I suppose.

---

Chuck Lever (6):
      SUNRPC: Display some debugging information as text rather than numbers
      SUNRPC: Refactor rpc_show_tasks
      SUNRPC: Don't display the rpc_show_tasks header if there are no tasks
      SUNRPC: Rename "call_" functions that are no longer FSM states
      SUNRPC: Add a function to display the name of an RPC procedure
      NFS: Update help text for CONFIG_NFS_FS


 fs/Kconfig        |  115 ++++++++++++++++++++++++-------------------------
 net/sunrpc/clnt.c |  124 ++++++++++++++++++++++++++++++-----------------------
 2 files changed, 128 insertions(+), 111 deletions(-)

-- 
Signature

Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([173.255.197.46]:50410 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752594AbbJSVsE (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 19 Oct 2015 17:48:04 -0400
Date: Mon, 19 Oct 2015 17:48:01 -0400
From: Bruce Fields <bfields@fieldses.org>
To: Frank Filz <ffilzlnx@mindspring.com>
Cc: linux-nfs@vger.kernel.org
Subject: Re: Pull request for pynfs
Message-ID: <20151019214801.GA16551@fieldses.org>
References: <012101d10853$7cae4ac0$760ae040$@mindspring.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <012101d10853$7cae4ac0$760ae040$@mindspring.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, Oct 16, 2015 at 01:44:42PM -0700, Frank Filz wrote:
> Bruce,
> 
> Please pull the top patch from:
> 
> https://github.com/ffilz/pynfs/commits/master
> 
> It fixes CID2 to allow NFS4_OK when SETCLIENTID with a different principal
> replaces a clientid that has no state, and adds CID2a which expects
> NFS4ERR_CLID_INUSE since it does have state.

Thanks!

This leave us with two test functions both named "testInUse".

I applied the following to get both tests working.

--b.

diff --git a/nfs4.0/servertests/st_setclientid.py b/nfs4.0/servertests/st_setclientid.py
index 0fb59cd7f542..fbeab22e5026 100644
--- a/nfs4.0/servertests/st_setclientid.py
+++ b/nfs4.0/servertests/st_setclientid.py
@@ -50,7 +50,7 @@ def testClientUpdateCallback(t, env):
     res = c.close_file(t.code, fh, stateid)
     check(res, msg="Close after updating callback info")
     
-def testInUse(t, env):
+def testNotInUse(t, env):
     """SETCLIENTID with same nfs_client_id.id should return NFS4ERR_OK
        if there is no active state
 

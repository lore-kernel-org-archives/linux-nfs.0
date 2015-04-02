Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:37422 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752517AbbDBOms (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 2 Apr 2015 10:42:48 -0400
Message-ID: <1427985766.2973.11.camel@deneb.redhat.com>
Subject: userspace breakage in linux/nfsd/debug.h
From: Mark Salter <msalter@redhat.com>
To: Jeff Layton <jlayton@primarydata.com>
Cc: Trond Myklebust <trond.myklebust@primarydata.com>,
        linux-nfs@vger.kernel.org, linux-kernel@vger.kernel.org
Date: Thu, 02 Apr 2015 10:42:46 -0400
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

This patch:

  commit f895b252d4edf66b2895fb5a7b17a638665f3e1f
  Author: Jeff Layton <jlayton@primarydata.com>
  Date:   Mon Nov 17 16:58:04 2014 -0500

    sunrpc: eliminate RPC_DEBUG
    
    It's always set to whatever CONFIG_SUNRPC_DEBUG is, so just use that.
    
    Signed-off-by: Jeff Layton <jlayton@primarydata.com>
    Signed-off-by: Trond Myklebust <trond.myklebust@primarydata.com>

breaks userspace use of linux/nfsd/debug.h because of:

  diff --git a/include/uapi/linux/nfsd/debug.h b/include/uapi/linux/nfsd/debug.h
  index a6f453c..1fdc95b 100644
  --- a/include/uapi/linux/nfsd/debug.h
  +++ b/include/uapi/linux/nfsd/debug.h
  @@ -15,7 +15,7 @@
    * Enable debugging for nfsd.
    * Requires RPC_DEBUG.
    */
  -#ifdef RPC_DEBUG
  +#if IS_ENABLED(CONFIG_SUNRPC_DEBUG)
   # define NFSD_DEBUG		1
   #endif
 
IS_ENABLED() is not available outside the kernel and causes a compile
time failure:

  /usr/include/linux/nfsd/debug.h:18:15: error: missing binary operator before token "("
 #if IS_ENABLED(CONFIG_SUNRPC_DEBUG)




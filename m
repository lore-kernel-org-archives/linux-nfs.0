Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx2.netapp.com ([216.240.18.37]:63199 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751521Ab3KNAgE convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 13 Nov 2013 19:36:04 -0500
From: "Myklebust, Trond" <Trond.Myklebust@netapp.com>
To: Jeff Layton <jlayton@redhat.com>
CC: "chuck.lever@oracle.com" <chuck.lever@oracle.com>,
        "neilb@suse.de" <neilb@suse.de>,
        "steved@redhat.com" <steved@redhat.com>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH v3 2/3] sunrpc: replace sunrpc_net->gssd_running flag
 with a more reliable check
Date: Thu, 14 Nov 2013 00:36:01 +0000
Message-ID: <1384389360.4573.3.camel@leira.trondhjem.org>
References: <1384379575-8997-1-git-send-email-jlayton@redhat.com>
	 <1384379575-8997-3-git-send-email-jlayton@redhat.com>
In-Reply-To: <1384379575-8997-3-git-send-email-jlayton@redhat.com>
Content-Type: text/plain; charset="utf-7"
MIME-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, 2013-11-13 at 16:52 -0500, Jeff Layton wrote:
+AD4- Now that we have a more reliable method to tell if gssd is running, we
+AD4- can replace the sn-+AD4-gssd+AF8-running flag with a function that will query to
+AD4- see if it's up and running.
+AD4- 
+AD4- There's also no need to attempt an upcall that we know will fail, so
+AD4- just return -EACCES if gssd isn't running in that case.
+AD4- 
+AD4- Signed-off-by: Jeff Layton +ADw-jlayton+AEA-redhat.com+AD4-
+AD4- ---
+AD4-  include/linux/sunrpc/rpc+AF8-pipe+AF8-fs.h +AHw- 14 +-+-+-+-+-+-+-+-+-+-+-+-+-+-
+AD4-  net/sunrpc/auth+AF8-gss/auth+AF8-gss.c     +AHw- 10 +-+-+-+-+------
+AD4-  net/sunrpc/netns.h                 +AHw-  2 --
+AD4-  net/sunrpc/rpc+AF8-pipe.c              +AHw- 16 +-+-+-+-+-+-+-+-+-+-+-+-----
+AD4-  4 files changed, 31 insertions(+-), 11 deletions(-)
+AD4- 
+AD4- diff --git a/include/linux/sunrpc/rpc+AF8-pipe+AF8-fs.h b/include/linux/sunrpc/rpc+AF8-pipe+AF8-fs.h
+AD4- index 85f1342..438e606 100644
+AD4- --- a/include/linux/sunrpc/rpc+AF8-pipe+AF8-fs.h
+AD4- +-+-+- b/include/linux/sunrpc/rpc+AF8-pipe+AF8-fs.h
+AD4- +AEAAQA- -131,5 +-131,19 +AEAAQA- extern int rpc+AF8-unlink(struct dentry +ACo-)+ADs-
+AD4-  extern int register+AF8-rpc+AF8-pipefs(void)+ADs-
+AD4-  extern void unregister+AF8-rpc+AF8-pipefs(void)+ADs-
+AD4-  
+AD4- +-+ACM-if IS+AF8-ENABLED(CONFIG+AF8-SUNRPC+AF8-GSS)
+AD4- +-
+AD4- +-extern bool gssd+AF8-running(struct net +ACo-net)+ADs-
+AD4- +-
+AD4- +-+ACM-else /+ACo- +ACE-CONFIG+AF8-SUNRPC+AF8-GSS +ACo-/
+AD4- +-
+AD4- +-static inline bool
+AD4- +-gssd+AF8-running(struct net +ACo-net)
+AD4- +-+AHs-
+AD4- +-	return false+ADs-
+AD4- +-+AH0-
+AD4- +-
+AD4- +-+ACM-endif /+ACo- CONFIG+AF8-SUNRPC+AF8-GSS +ACo-/

Why the +ACM-if IS+AF8-ENABLED(CONFIG+AF8-SUNRPC+AF8-GSS)? Prior to this patch, there
was nothing stopping you from compiling the module later.

-- 
Trond Myklebust
Linux NFS client maintainer

NetApp
Trond.Myklebust+AEA-netapp.com
www.netapp.com

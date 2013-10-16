Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx12.netapp.com ([216.240.18.77]:49335 "EHLO mx12.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S935473Ab3JPSR4 convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 16 Oct 2013 14:17:56 -0400
From: "Myklebust, Trond" <Trond.Myklebust@netapp.com>
To: "J. Bruce Fields" <bfields@redhat.com>
CC: "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH 1/2] rpc: change BUG to WARN in gss_encode_v1_msg
Date: Wed, 16 Oct 2013 18:17:54 +0000
Message-ID: <1381947473.17178.2.camel@leira.trondhjem.org>
References: <1380721695-14755-1-git-send-email-bfields@redhat.com>
In-Reply-To: <1380721695-14755-1-git-send-email-bfields@redhat.com>
Content-Type: text/plain; charset="utf-7"
MIME-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, 2013-10-02 at 09:48 -0400, J. Bruce Fields wrote:
+AD4- From: +ACI-J. Bruce Fields+ACI- +ADw-bfields+AEA-redhat.com+AD4-
+AD4- 
+AD4- Failure of this assertion would indeed be serious, but as we've seen a
+AD4- BUG() in a worker thread (this can run from rpciod context) can screw up
+AD4- the system so badly that the oops doesn't even get to the logs+ADs- better
+AD4- to WARN() and soldier on.
+AD4- 
+AD4- Signed-off-by: J. Bruce Fields +ADw-bfields+AEA-redhat.com+AD4-
+AD4- ---
+AD4-  net/sunrpc/auth+AF8-gss/auth+AF8-gss.c +AHw-    2 +--
+AD4-  1 file changed, 1 insertion(+-), 1 deletion(-)
+AD4- 
+AD4- diff --git a/net/sunrpc/auth+AF8-gss/auth+AF8-gss.c b/net/sunrpc/auth+AF8-gss/auth+AF8-gss.c
+AD4- index 0846566..254a9f0 100644
+AD4- --- a/net/sunrpc/auth+AF8-gss/auth+AF8-gss.c
+AD4- +-+-+- b/net/sunrpc/auth+AF8-gss/auth+AF8-gss.c
+AD4- +AEAAQA- -454,7 +-454,7 +AEAAQA- static void gss+AF8-encode+AF8-v1+AF8-msg(struct gss+AF8-upcall+AF8-msg +ACo-gss+AF8-msg,
+AD4-  	gss+AF8-msg-+AD4-msg.len +-+AD0- len+ADs-
+AD4-  
+AD4-  	gss+AF8-msg-+AD4-msg.data +AD0- gss+AF8-msg-+AD4-databuf+ADs-
+AD4- -	BUG+AF8-ON(gss+AF8-msg-+AD4-msg.len +AD4- UPCALL+AF8-BUF+AF8-LEN)+ADs-
+AD4- +-	WARN+AF8-ON+AF8-ONCE(gss+AF8-msg-+AD4-msg.len +AD4- UPCALL+AF8-BUF+AF8-LEN)+ADs-
+AD4-  +AH0-
+AD4-  
+AD4-  static struct gss+AF8-upcall+AF8-msg +ACo-

Umm.... Why aren't we using scnprintf() in order to prevent string
buffer overflows before they happen?

-- 
Trond Myklebust
Linux NFS client maintainer

NetApp
Trond.Myklebust+AEA-netapp.com
www.netapp.com

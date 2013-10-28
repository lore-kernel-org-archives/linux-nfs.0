Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx12.netapp.com ([216.240.18.77]:4955 "EHLO mx12.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756448Ab3J1Skd convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 28 Oct 2013 14:40:33 -0400
From: "Myklebust, Trond" <Trond.Myklebust@netapp.com>
To: Jeff Layton <jlayton@redhat.com>
CC: "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH] nfs: return -EBUSY on remount when new options can't be
 applied
Date: Mon, 28 Oct 2013 18:40:32 +0000
Message-ID: <1382985630.3314.3.camel@leira.trondhjem.org>
References: <1382363554-6587-1-git-send-email-jlayton@redhat.com>
In-Reply-To: <1382363554-6587-1-git-send-email-jlayton@redhat.com>
Content-Type: text/plain; charset="utf-7"
MIME-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, 2013-10-21 at 09:52 -0400, Jeff Layton wrote:
+AD4- Currently the kernel returns -EINVAL, which makes it hard to
+AD4- distinguish this situation from the case where an invalid mount option
+AD4- was specified.
+AD4- 
+AD4- Signed-off-by: Jeff Layton +ADw-jlayton+AEA-redhat.com+AD4-
+AD4- ---
+AD4-  fs/nfs/super.c +AHw- 2 +--
+AD4-  1 file changed, 1 insertion(+-), 1 deletion(-)
+AD4- 
+AD4- diff --git a/fs/nfs/super.c b/fs/nfs/super.c
+AD4- index 3f5a7a8..cebdb26 100644
+AD4- --- a/fs/nfs/super.c
+AD4- +-+-+- b/fs/nfs/super.c
+AD4- +AEAAQA- -2156,7 +-2156,7 +AEAAQA- nfs+AF8-compare+AF8-remount+AF8-data(struct nfs+AF8-server +ACo-nfss,
+AD4-  	    data-+AD4-nfs+AF8-server.addrlen +ACEAPQ- nfss-+AD4-nfs+AF8-client-+AD4-cl+AF8-addrlen +AHwAfA-
+AD4-  	    +ACE-rpc+AF8-cmp+AF8-addr((struct sockaddr +ACo-)+ACY-data-+AD4-nfs+AF8-server.address,
+AD4-  			  (struct sockaddr +ACo-)+ACY-nfss-+AD4-nfs+AF8-client-+AD4-cl+AF8-addr))
+AD4- -		return -EINVAL+ADs-
+AD4- +-		return -EBUSY+ADs-
+AD4-  
+AD4-  	return 0+ADs-
+AD4-  +AH0-

The problem is that EBUSY also has a different meaning when it comes to
remount. According to the manpage it means the source +ACI-cannot be
remounted read-only, because it still holds files open for writing.+ACI-

So, as far as I can see, this is a case of pick your poison...

-- 
Trond Myklebust
Linux NFS client maintainer

NetApp
Trond.Myklebust+AEA-netapp.com
www.netapp.com

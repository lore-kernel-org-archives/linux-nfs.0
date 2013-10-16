Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx11.netapp.com ([216.240.18.76]:36831 "EHLO mx11.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1761486Ab3JPUgO convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 16 Oct 2013 16:36:14 -0400
From: "Myklebust, Trond" <Trond.Myklebust@netapp.com>
To: Weston Andros Adamson <dros@netapp.com>
CC: "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH] NFS: Add support for multiple sec= mount options
Date: Wed, 16 Oct 2013 20:36:13 +0000
Message-ID: <1381955772.17178.33.camel@leira.trondhjem.org>
References: <1381517062-11267-1-git-send-email-dros@netapp.com>
In-Reply-To: <1381517062-11267-1-git-send-email-dros@netapp.com>
Content-Type: text/plain; charset="utf-7"
MIME-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, 2013-10-11 at 14:44 -0400, Weston Andros Adamson wrote:
+AD4- This patch adds support for multiple security options which can be
+AD4- specified using a colon-delimited list of security flavors (the same
+AD4- syntax as nfsd's exports file).
+AD4- 
+AD4- This is useful, for instance, when NFSv4.x mounts cross SECINFO
+AD4- boundaries. With this patch a user can use +ACI-sec+AD0-krb5i,krb5p+ACI-
+AD4- to mount a remote filesystem using krb5i, but can still cross
+AD4- into krb5p-only exports.
+AD4- 
+AD4- New mounts will try all security options before failing.  NFSv4.x
+AD4- SECINFO results will be compared against the sec+AD0- flavors to
+AD4- find the first flavor in both lists or if no match is found will
+AD4- return EPERM.
+AD4- 
+AD4- This patch cleans up some of the auth flavor logic by separating
+AD4- the parsed mount options from the currently selected flavor and
+AD4- sharing more code between the 'no sec+AD0- specified' and 'sec+AD0- specified'
+AD4- code paths.
+AD4- 
+AD4- Along with this patch I'm posting a patch to nfs-util's nfs.man to
+AD4- reflect these changes.
+AD4- 
+AD4- I wrote a script to verify that I haven't broken anything, it tests
+AD4- all vers+AD0- and sec+AD0- combinations against a server with the exports:
+AD4- 
+AD4-  /export/sys       +ACo-(sec+AD0-sys,rw,no+AF8-root+AF8-squash)
+AD4-  /export/krb5a     +ACo-(sec+AD0-krb5,rw,no+AF8-root+AF8-squash)
+AD4-  /export/krb5i     +ACo-(sec+AD0-krb5i,rw,no+AF8-root+AF8-squash)
+AD4-  /export/krb5p     +ACo-(sec+AD0-krb5p,rw,no+AF8-root+AF8-squash)
+AD4-  /export/krb5ip    +ACo-(sec+AD0-krb5i:krb5p,rw,no+AF8-root+AF8-squash)
+AD4-  /export/krb5aip   +ACo-(sec+AD0-krb5:krb5i:krb5p,rw,no+AF8-root+AF8-squash)
+AD4- 
+AD4- The script runs these tests against all exports, and the versions NFSv3,
+AD4- v4.0, v4.1:
+AD4-  - no sec+AD0- options
+AD4-  - all single sec+AD0- options
+AD4-  - all combinations of multiple sec+AD0- options
+AD4-  - no sec+AD0- SECINFO (mount / then ls export dir, v4.x only)
+AD4-  - single sec+AD0- SECINFO (mount / then ls export dir, v4.x only)
+AD4-  - all combinations of multiple sec+AD0- SECINFO (mount / then ls export dir,
+AD4-     v4.x only)
+AD4- 
+AD4- Signed-off-by: Weston Andros Adamson +ADw-dros+AEA-netapp.com+AD4-

Can you please split this up? It seems to me that there are at least 3
patches here:

     1. Refactor code to introduce struct nfs+AF8-auth+AF8-info
     2. Cache struct nfs+AF8-auth+AF8-info in struct nfs+AF8-server
     3. Extend the mount code to allow multiple auth flavours in the
        'sec+AD0-' mount options

Thanks
  Trond

-- 
Trond Myklebust
Linux NFS client maintainer

NetApp
Trond.Myklebust+AEA-netapp.com
www.netapp.com

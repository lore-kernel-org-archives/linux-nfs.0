Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:36303 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754436Ab3EKVqI (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Sat, 11 May 2013 17:46:08 -0400
Message-ID: <518EBBD4.7010306@RedHat.com>
Date: Sat, 11 May 2013 17:44:52 -0400
From: Steve Dickson <SteveD@redhat.com>
MIME-Version: 1.0
To: "J. Bruce Fields" <bfields@fieldses.org>
CC: Trond Myklebust <Trond.Myklebust@netapp.com>,
        "J. Bruce Fields" <bfields@redhat.com>,
        "David P. Quigley" <dpquigl@tycho.nsa.gov>,
        Linux NFS list <linux-nfs@vger.kernel.org>,
        Linux FS devel list <linux-fsdevel@vger.kernel.org>,
        Linux Security List <linux-security-module@vger.kernel.org>,
        SELinux List <selinux@tycho.nsa.gov>
Subject: Re: [PATCH 16/17] NFSD: Server implementation of MAC Labeling
References: <1367515151-31015-1-git-send-email-SteveD@redhat.com> <1367515151-31015-17-git-send-email-SteveD@redhat.com> <20130509015033.GI23747@fieldses.org>
In-Reply-To: <20130509015033.GI23747@fieldses.org>
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>



On 08/05/13 21:50, J. Bruce Fields wrote:
> This also doesn't handle the unsupported case correctly.
> 
> Applying the following fix to my tree.
With in the following commit

commit ad8684190a6eb3913a54eda7838f31ead8a73168
Author: David Quigley <dpquigl@davequigley.com>
Date:   Thu May 2 13:19:10 2013 -0400

    NFSD: Server implementation of MAC Labeling

The following chunk of code was committed:

 @@ -380,6 +386,33 @@ nfsd4_decode_fattr(struct nfsd4_compoundargs *argp, u32 *bm
                        goto xdr_error;
                }
        }
+
+       label->len = 0;
+#ifdef CONFIG_NFSD_V4_SECURITY_LABEL
+       if (bmval[2] & FATTR4_WORD2_SECURITY_LABEL) {
+               READ_BUF(4);
+               len += 4;
+               READ32(dummy32); /* lfs: we don't use it */
+               READ_BUF(4);
+               len += 4;
+               READ32(dummy32); /* pi: we don't use it either */
+               READ_BUF(4);
+               len += 4;
+               READ32(dummy32);
+               READ_BUF(dummy32);
+               if (dummy32 > NFSD4_MAX_SEC_LABEL_LEN)
+                       return nfserr_badlabel;
+               len += (XDR_QUADLEN(dummy32) << 2);
+               READMEM(buf, dummy32);
+               label->data = kzalloc(dummy32 + 1, GFP_KERNEL);
+               if (!label->data)
+                       return nfserr_jukebox;
+               defer_free(argp, kfree, label->data);
+               memcpy(label->data, buf, dummy32);
+               label->data[len] = '\0';
+       }
+#endif
+
which is not quite right.... 

You really don't need to NULL out label->data since kzalloc(dummy32 + 1) was 
used and especially with 'len' since only 'dummy32' amount of space was allocated 
which is significantly less than the 'len' value. But you do want to set 
label->len to dummy32 otherwise nfsd4_setattr() will never call nfsd4_set_nfs4_label() 
to process the label. 

commit 965ac99ed149eba2f7d2e37abe07919decf8afa5
Author: Steve Dickson <steved@redhat.com>
Date:   Sat May 11 17:36:21 2013 -0400

    nfsd: Fixed memory corruption in the decoding of labels
    
    Commit ad86841 caused a memory corruption in
    how labels are allocated in nfsd4_decode_fattr()
    by using 'len' to set the NULL in label->data.
    
    Also label->len was not being set which cause
    labels not to be process in nfsd4_setattr()
    
    Signed-off-by: Steve Dickson <steved@redhat.com>

diff --git a/fs/nfsd/nfs4xdr.c b/fs/nfsd/nfs4xdr.c
index 96f07cb..a1a3669 100644
--- a/fs/nfsd/nfs4xdr.c
+++ b/fs/nfsd/nfs4xdr.c
@@ -409,7 +409,7 @@ nfsd4_decode_fattr(struct nfsd4_compoundargs *argp, u32 *bmval,
 			return nfserr_jukebox;
 		defer_free(argp, kfree, label->data);
 		memcpy(label->data, buf, dummy32);
-		label->data[len] = '\0';
+		label->len = dummy32;
 	}
 #endif

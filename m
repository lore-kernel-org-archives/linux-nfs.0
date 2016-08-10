Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx0b-00082601.pphosted.com ([67.231.153.30]:9507 "EHLO
	mx0a-00082601.pphosted.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1753724AbcHJSsc (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 10 Aug 2016 14:48:32 -0400
Subject: Re: [lkp] [nfsd] b44061d0b9: BUG: Dentry
 ffff880027d7c540{i=1846f,n=0a} still in use (1) [unmount of btrfs vda]
To: Linus Torvalds <torvalds@linux-foundation.org>
References: <20160810053947.GG21941@yexl-desktop>
 <CA+55aFxdcG4y4zWTFFT8SekEtxsvx12P+e=11kTCFc=zS__bXQ@mail.gmail.com>
 <dc406145-b465-b7e9-e370-91910abb8e6a@fb.com>
 <CA+55aFzdTMBc7f5=bQLRUtceu-Kg-MGmzWrAv1r96_ra8yutJA@mail.gmail.com>
CC: kernel test robot <xiaolong.ye@intel.com>,
        Al Viro <viro@zeniv.linux.org.uk>, Chris Mason <clm@fb.com>,
        David Sterba <dsterba@suse.com>,
        "J. Bruce Fields" <bfields@redhat.com>,
        LKML <linux-kernel@vger.kernel.org>, LKP <lkp@01.org>,
        linux-btrfs <linux-btrfs@vger.kernel.org>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>
From: Josef Bacik <jbacik@fb.com>
Message-ID: <e6fb50d4-2a27-13cd-02c8-5b8439a16b3f@fb.com>
Date: Wed, 10 Aug 2016 14:46:27 -0400
MIME-Version: 1.0
In-Reply-To: <CA+55aFzdTMBc7f5=bQLRUtceu-Kg-MGmzWrAv1r96_ra8yutJA@mail.gmail.com>
Content-Type: text/plain; charset="utf-8"; format=flowed
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 08/10/2016 02:25 PM, Linus Torvalds wrote:
> On Wed, Aug 10, 2016 at 11:22 AM, Josef Bacik <jbacik@fb.com> wrote:
>> On 08/10/2016 02:06 PM, Linus Torvalds wrote:
>>>
>>> More information in the original email on lkml.
>>
>> I'm not subscribed to lkml and for some reason I can't find the original
>> email in any of the lkml/linux-nfs archives.  Could you forward more of the
>> details?
>
> Done.
>

So my naive fix would be something like this


From: Josef Bacik <jbacik@fb.com>
Date: Wed, 10 Aug 2016 14:43:08 -0400
Subject: [PATCH] nfsd: fix dentry refcounting problem

b44061d0b9 introduced a dentry ref counting bug, previously we were grabbing one
ref to dchild in nfsd_create(), but with the creation of nfsd_create_locked() we
have a ref for dchild from the lookup in nfsd_create(), and then another ref in
nfsd_create_locked().  The ref from the lookup in nfsd_create() is never dropped
and results in dentries still in use at unmount.

Signed-off-by: Josef Bacik <jbacik@fb.com>
---
  fs/nfsd/vfs.c | 9 ++++++---
  1 file changed, 6 insertions(+), 3 deletions(-)

diff --git a/fs/nfsd/vfs.c b/fs/nfsd/vfs.c
index ba944123..ff476e6 100644
--- a/fs/nfsd/vfs.c
+++ b/fs/nfsd/vfs.c
@@ -1252,10 +1252,13 @@ nfsd_create(struct svc_rqst *rqstp, struct svc_fh *fhp,
  	if (IS_ERR(dchild))
  		return nfserrno(host_err);
  	err = fh_compose(resfhp, fhp->fh_export, dchild, fhp);
-	if (err) {
-		dput(dchild);
+	/*
+	 * We unconditionally drop our ref to dchild as fh_compose will have
+	 * already grabbed its own ref for it.
+	 */
+	dput(dchild);
+	if (err)
  		return err;
-	}
  	return nfsd_create_locked(rqstp, fhp, fname, flen, iap, type,
  					rdev, resfhp);
  }
-- 
2.5.5


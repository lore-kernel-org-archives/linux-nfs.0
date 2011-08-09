Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-ww0-f44.google.com ([74.125.82.44]:36257 "EHLO
	mail-ww0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750801Ab1HIIwU (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 9 Aug 2011 04:52:20 -0400
Received: by wwf5 with SMTP id 5so2413422wwf.1
        for <linux-nfs@vger.kernel.org>; Tue, 09 Aug 2011 01:52:18 -0700 (PDT)
Message-ID: <4E40F53A.2080303@tonian.com>
Date: Tue, 09 Aug 2011 04:52:10 -0400
From: Benny Halevy <bhalevy@tonian.com>
To: Olga Kornievskaia <aglo@citi.umich.edu>
CC: Billy Hass <billdh16@gmail.com>, linux-nfs@vger.kernel.org
Subject: Re: Unable to Compile Latest Kernel from Git
References: <CALPVbefsY4Ddw6QOZu9BckCx+Q0YJg8tgbjK6xN5sQxbpdD16w@mail.gmail.com> <CAN-5tyEmCx+1quj+545zDZ1ueQRVhHGgDzhdjZ1K1h6hCjOJvw@mail.gmail.com>
In-Reply-To: <CAN-5tyEmCx+1quj+545zDZ1ueQRVhHGgDzhdjZ1K1h6hCjOJvw@mail.gmail.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On 2011-08-08 15:01, Olga Kornievskaia wrote:
> I'd like to 2nd this.
> 
> Current pnfs server doesn't build if chosen to be build into the
> kernel. It does build, if built as a module.
> 
> when client and server code is build into the kernel it seems that
> both sides try to define pnfs_roc() function and stepping on each
> others toes..
> 
> On Fri, Aug 5, 2011 at 9:58 PM, Billy Hass <billdh16@gmail.com> wrote:
>> Hey all,
>>
>> I am unable to compile the latest kernel from the git tree.
>>
>> git clone git://git.linux-nfs.org/projects/bhalevy/linux-pnfs.git
>> cd linux-pnfs
>> make oldconfig
>> make -j5 -s
>>      [ ... ]
>>      [A lot of warnings, but no errors]
>>      [ ... ]
>> make install
>>      sh /usr/src/kernels/3.0.0/linux-
>>     pnfs/arch/x86/boot/install.sh 3.0.0-pnfs arch/x86/boot/bzImage \
>>          System.map "/boot"
>>       *** Missing file: arch/x86/boot/bzImage
>>       *** You need to run "make" before "make install".
>>      make[1]: *** [install] Error 1
>>      make: *** [install] Error 2
>>
>> When I try to do the make again, here is the output
>> make -j5 -s
>>      fs/nfsd/built-in.o: In function `pnfs_roc':
>>      (.text+0x226d1): multiple definition of `pnfs_roc'
>>      fs/nfs/built-in.o:(.text+0x304ee): first defined here
>>      make[1]: *** [fs/built-in.o] Error 1
>>      make: *** [fs] Error 2
>>      make: *** Waiting for unfinished jobs....
>>
>> Thanks for any help!
>>
>> Bill
>>
>> --
>> Bill D. Hass
>> Major | Electrical Engineering BSE
>> Minor | Mathematics
>> University of Michigan '13
>> College of Engineering
>> (715) 923-8382
>> --
>> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
>> the body of a message to majordomo@vger.kernel.org
>> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>>
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

Right.  The following patch simply renames the function for pnfsd.
I'm pushing it to pnfs-all-3.0 and I'll add it to the 3.1-rc tree
(pnfs-all-latest) once I finish rebasing and testing it.

Benny

>From d76f73eca38fd7b803d80e78cfa8f9468e83a9b3 Mon Sep 17 00:00:00 2001
From: Benny Halevy <benny@tonian.com>
Date: Tue, 9 Aug 2011 01:11:16 -0400
Subject: [PATCH] SQUASHME: pnfsd: rename pnfs_roc to pnfsd_roc

It clashes with a function called the same in the nfs module

Signed-off-by: Benny Halevy <benny@tonian.com>
---
 fs/nfsd/nfs4pnfsd.c |    2 +-
 fs/nfsd/nfs4state.c |    2 +-
 fs/nfsd/pnfsd.h     |    2 +-
 3 files changed, 3 insertions(+), 3 deletions(-)

diff --git a/fs/nfsd/nfs4pnfsd.c b/fs/nfsd/nfs4pnfsd.c
index b1f67eb..e0669ad 100644
--- a/fs/nfsd/nfs4pnfsd.c
+++ b/fs/nfsd/nfs4pnfsd.c
@@ -1336,7 +1336,7 @@ nomatching_layout(struct nfs4_layoutrecall *clr)
  *   the layout and simulate a layout_return. Surly the client has forgotten
  *   these layouts or it would return them before the close.
  */
-void pnfs_roc(struct nfs4_client *clp, struct nfs4_file *fp)
+void pnfsd_roc(struct nfs4_client *clp, struct nfs4_file *fp)
 {
 	struct nfs4_layout *lo, *nextlp;

diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
index 1941051..b95589e 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -3620,7 +3620,7 @@ nfsd4_close(struct svc_rqst *rqstp, struct nfsd4_compound_state *cstate,
 	update_stateid(&stp->st_stateid);
 	memcpy(&close->cl_stateid, &stp->st_stateid, sizeof(stateid_t));

-	pnfs_roc(stp->st_stateowner->so_client, stp->st_file);
+	pnfsd_roc(stp->st_stateowner->so_client, stp->st_file);

 	/* release_stateid() calls nfsd_close() if needed */
 	release_open_stateid(stp);
diff --git a/fs/nfsd/pnfsd.h b/fs/nfsd/pnfsd.h
index a4c8a9c..6e60d2c 100644
--- a/fs/nfsd/pnfsd.h
+++ b/fs/nfsd/pnfsd.h
@@ -125,7 +125,7 @@ int nfs4_pnfs_cb_change_state(struct pnfs_get_state *);
 void nfs4_ds_get_verifier(stateid_t *, struct super_block *, u32 *);
 int put_layoutrecall(struct nfs4_layoutrecall *);
 void nomatching_layout(struct nfs4_layoutrecall *);
-void pnfs_roc(struct nfs4_client *clp, struct nfs4_file *fp);
+void pnfsd_roc(struct nfs4_client *clp, struct nfs4_file *fp);
 void *layoutrecall_done(struct nfs4_layoutrecall *);
 void nfsd4_cb_layout(struct nfs4_layoutrecall *);
 int _nfsd_layout_recall_cb(struct super_block *, struct inode *,
-- 
1.7.6


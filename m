Return-Path: linux-nfs-owner@vger.kernel.org
Received: from co1ehsobe004.messaging.microsoft.com ([216.32.180.187]:5866
	"EHLO co1outboundpool.messaging.microsoft.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754464Ab2HPXpG convert rfc822-to-8bit
	(ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 16 Aug 2012 19:45:06 -0400
From: Shai Lazmi <shai.lazmi@qlogic.com>
To: Trond Myklebust <Trond.Myklebust@netapp.com>,
        William Dauchy <wdauchy@gmail.com>
CC: Bryan Schumaker <bjschuma@netapp.com>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Date: Thu, 16 Aug 2012 16:44:58 -0700
Subject: RE: [PATCH 1/2] NFS: Clear key construction data if the idmap
 upcall fails
Message-ID: <21641D3714F5AF449DC483E699E1124E86E640957F@AVEXMB2.qlogic.org>
References: <1345148622-10845-1-git-send-email-Trond.Myklebust@netapp.com>
In-Reply-To: <1345148622-10845-1-git-send-email-Trond.Myklebust@netapp.com>
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Patch fails with "
git apply --check
fatal: patch fragment without header at line 31: @@ -380,11 +387,13 @@ static const match_table_t nfs_idmap_tokens = {  static int nfs_idmap_legacy_upcall(struct key_construction *, const char *, void *);  static ssize_t idmap_pipe_downcall(struct file *, const char __user *,
"

-----Original Message-----
From: Trond Myklebust [mailto:Trond.Myklebust@netapp.com]
Sent: Thursday, August 16, 2012 1:24 PM
To: William Dauchy
Cc: Shai Lazmi; Bryan Schumaker; linux-nfs@vger.kernel.org
Subject: [PATCH 1/2] NFS: Clear key construction data if the idmap upcall fails

From: Bryan Schumaker <bjschuma@netapp.com>

idmap_pipe_downcall already clears this field if the upcall succeeds,
but if it fails (rpc.idmapd isn't running) the field will still be set
on the next call triggering a BUG_ON().  This patch tries to handle all
possible ways that the upcall could fail and clear the idmap key data
for each one.

Signed-off-by: Bryan Schumaker <bjschuma@netapp.com>
Cc: stable@vger.kernel.org [>= 3.4]
Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
---
 fs/nfs/idmap.c | 56 ++++++++++++++++++++++++++++++++++++++++++--------------
 1 file changed, 42 insertions(+), 14 deletions(-)

diff --git a/fs/nfs/idmap.c b/fs/nfs/idmap.c
index b701358..6703c73 100644
--- a/fs/nfs/idmap.c
+++ b/fs/nfs/idmap.c
@@ -61,6 +61,12 @@ struct idmap {
        struct mutex            idmap_mutex;
 };

+struct idmap_legacy_upcalldata {
+       struct rpc_pipe_msg pipe_msg;
+       struct idmap_msg idmap_msg;
+       struct idmap *idmap;
+};
+
 /**
  * nfs_fattr_init_names - initialise the nfs_fattr owner_name/group_name fields
  * @fattr: fully initialised struct nfs_fattr
@@ -324,6 +330,7 @@ static ssize_t nfs_idmap_get_key(const char *name, size_t namelen,
                ret = nfs_idmap_request_key(&key_type_id_resolver_legacy,
                                            name, namelen, type, data,
                                            data_size, idmap);
+               idmap->idmap_key_cons = NULL;
                mutex_unlock(&idmap->idmap_mutex);
        }
        return ret;
@@ -380,11 +387,13 @@ static const match_table_t nfs_idmap_tokens = {
 static int nfs_idmap_legacy_upcall(struct key_construction *, const char *, void *);
 static ssize_t idmap_pipe_downcall(struct file *, const char __user *,
                                   size_t);
+static void idmap_release_pipe(struct inode *);
 static void idmap_pipe_destroy_msg(struct rpc_pipe_msg *);

 static const struct rpc_pipe_ops idmap_upcall_ops = {
        .upcall         = rpc_pipe_generic_upcall,
        .downcall       = idmap_pipe_downcall,
+       .release_pipe   = idmap_release_pipe,
        .destroy_msg    = idmap_pipe_destroy_msg,
 };

@@ -616,7 +625,8 @@ void nfs_idmap_quit(void)
        nfs_idmap_quit_keyring();
 }

-static int nfs_idmap_prepare_message(char *desc, struct idmap_msg *im,
+static int nfs_idmap_prepare_message(char *desc, struct idmap *idmap,
+                                    struct idmap_msg *im,
                                     struct rpc_pipe_msg *msg)
 {
        substring_t substr;
@@ -659,6 +669,7 @@ static int nfs_idmap_legacy_upcall(struct key_construction *cons,
                                   const char *op,
                                   void *aux)
 {
+       struct idmap_legacy_upcalldata *data;
        struct rpc_pipe_msg *msg;
        struct idmap_msg *im;
        struct idmap *idmap = (struct idmap *)aux;
@@ -666,15 +677,15 @@ static int nfs_idmap_legacy_upcall(struct key_construction *cons,
        int ret = -ENOMEM;

        /* msg and im are freed in idmap_pipe_destroy_msg */
-       msg = kmalloc(sizeof(*msg), GFP_KERNEL);
-       if (!msg)
-               goto out0;
-
-       im = kmalloc(sizeof(*im), GFP_KERNEL);
-       if (!im)
+       data = kmalloc(sizeof(*data), GFP_KERNEL);
+       if (!data)
                goto out1;

-       ret = nfs_idmap_prepare_message(key->description, im, msg);
+       msg = &data->pipe_msg;
+       im = &data->idmap_msg;
+       data->idmap = idmap;
+
+       ret = nfs_idmap_prepare_message(key->description, idmap, im, msg);
        if (ret < 0)
                goto out2;

@@ -683,15 +694,15 @@ static int nfs_idmap_legacy_upcall(struct key_construction *cons,

        ret = rpc_queue_upcall(idmap->idmap_pipe, msg);
        if (ret < 0)
-               goto out2;
+               goto out3;

        return ret;

+out3:
+       idmap->idmap_key_cons = NULL;
 out2:
-       kfree(im);
+       kfree(data);
 out1:
-       kfree(msg);
-out0:
        complete_request_key(cons, ret);
        return ret;
 }
@@ -775,9 +786,26 @@ out_incomplete:
 static void
 idmap_pipe_destroy_msg(struct rpc_pipe_msg *msg)
 {
+       struct idmap_legacy_upcalldata *data = container_of(msg,
+                       struct idmap_legacy_upcalldata,
+                       pipe_msg);
+       struct idmap *idmap = data->idmap;
+       struct key_construction *cons;
+       if (msg->errno) {
+               cons = ACCESS_ONCE(idmap->idmap_key_cons);
+               idmap->idmap_key_cons = NULL;
+               complete_request_key(cons, msg->errno);
+       }
        /* Free memory allocated in nfs_idmap_legacy_upcall() */
-       kfree(msg->data);
-       kfree(msg);
+       kfree(data);
+}
+
+static void
+idmap_release_pipe(struct inode *inode)
+{
+       struct rpc_inode *rpci = RPC_I(inode);
+       struct idmap *idmap = (struct idmap *)rpci->private;
+       idmap->idmap_key_cons = NULL;
 }

 int nfs_map_name_to_uid(const struct nfs_server *server, const char *name, size_t namelen, __u32 *uid)
--
1.7.11.2



This message and any attached documents contain information from QLogic Corporation or its wholly-owned subsidiaries that may be confidential. If you are not the intended recipient, you may not read, copy, distribute, or use this information. If you have received this transmission in error, please notify the sender immediately by reply e-mail and then delete this message.


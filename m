Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mailout-de.gmx.net ([213.165.64.22]:44366 "HELO
	mailout-de.gmx.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with SMTP id S1753489Ab1E1PAe convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sat, 28 May 2011 11:00:34 -0400
From: =?iso-8859-1?q?R=FCdiger_Meier?= <sweet_f_a@gmx.de>
To: linux-nfs@vger.kernel.org
Subject: Re: infinite getdents64 loop
Date: Sat, 28 May 2011 17:00:29 +0200
References: <201105281502.32719.sweet_f_a@gmx.de>
In-Reply-To: <201105281502.32719.sweet_f_a@gmx.de>
Content-Type: text/plain;
  charset="iso-8859-1"
Message-Id: <201105281700.30726.sweet_f_a@gmx.de>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Saturday 28 May 2011, Rüdiger Meier wrote:
> I could track down the problem to:
>
> commit 0b26a0bf6ff398185546432420bb772bcfdf8d94
> Author: Trond Myklebust <Trond.Myklebust@netapp.com>
> Date:   Sat Nov 20 14:26:44 2010 -0500
>
>     NFS: Ensure we return the dirent->d_type when it is known
>
>
> After reverting the problem is gone.

Actually it's enough to remove d_type from struct nfs_cache_array_entry 
again. It's not enough to set it DT_UNKNOWN always. I had to remove it 
from struct to let it work.
Tested with kernels 2.6.37.6 and 2.6.39.


commit c9799af304af2a22acffaae25e7e9c3b733a5b68
Author: Ruediger Meier <ruediger.meier@ga-group.nl>
Date:   Sat May 28 15:26:15 2011 +0200

    hotfix, opensuse bug 678123
    this reverts the effect of 0b26a0bf

diff --git a/fs/nfs/dir.c b/fs/nfs/dir.c
index 7237672..48cfc27 100644
--- a/fs/nfs/dir.c
+++ b/fs/nfs/dir.c
@@ -202,7 +202,6 @@ struct nfs_cache_array_entry {
        u64 cookie;
        u64 ino;
        struct qstr string;
-       unsigned char d_type;
 };

 struct nfs_cache_array {
@@ -305,7 +304,6 @@ int nfs_readdir_add_to_array(struct nfs_entry 
*entry, struct page *page)

        cache_entry->cookie = entry->prev_cookie;
        cache_entry->ino = entry->ino;
-       cache_entry->d_type = entry->d_type;
        ret = nfs_readdir_make_qstr(&cache_entry->string, entry->name, 
entry->len);
        if (ret)
                goto out;
@@ -770,7 +768,7 @@ int nfs_do_filldir(nfs_readdir_descriptor_t *desc, 
void *dirent,
                ent = &array->array[i];
                if (filldir(dirent, ent->string.name, ent->string.len,
                    file->f_pos, nfs_compat_user_ino64(ent->ino),
-                   ent->d_type) < 0) {
+                   DT_UNKNOWN) < 0) {
                        desc->eof = 1;
                        break;
                }

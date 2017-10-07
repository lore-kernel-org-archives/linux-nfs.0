Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from bombadil.infradead.org ([65.50.211.133]:44182 "EHLO
        bombadil.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751869AbdJGAIL (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Fri, 6 Oct 2017 20:08:11 -0400
Subject: Re: [PATCH 03/14] VFS: Implement a filesystem superblock
 creation/configuration context [ver #6]
To: David Howells <dhowells@redhat.com>
Cc: viro@ZenIV.linux.org.uk, linux-fsdevel@vger.kernel.org,
        mszeredi@redhat.com, linux-nfs@vger.kernel.org,
        linux-kernel@vger.kernel.org, jlayton@redhat.com
References: <27530b6a-7290-2171-899e-6c16c14f402e@infradead.org>
 <150730494491.6182.5139368907374172391.stgit@warthog.procyon.org.uk>
 <150730496982.6182.10042997820796149075.stgit@warthog.procyon.org.uk>
 <25218.1507331581@warthog.procyon.org.uk>
From: Randy Dunlap <rdunlap@infradead.org>
Message-ID: <d4b3cb0e-72f7-ad62-c58f-93c22100cf74@infradead.org>
Date: Fri, 6 Oct 2017 17:08:10 -0700
MIME-Version: 1.0
In-Reply-To: <25218.1507331581@warthog.procyon.org.uk>
Content-Type: text/plain; charset=utf-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 10/06/17 16:13, David Howells wrote:
> Randy Dunlap <rdunlap@infradead.org> wrote:
> 
>> (in fs/namespace.c:)
> 
> Ummm?

in fs/namespace.c:

+/**
+ * vfs_create_mount - Create a mount for a configured superblock
+ * fc: The configuration context with the superblock attached
+ *
+ * Create a mount to an already configured superblock.  If necessary, the
+ * caller should invoke vfs_get_tree() before calling this.
+ *
+ * Note that this does not attach the mount to anything.
+ */
+struct vfsmount *vfs_create_mount(struct fs_context *fc)
+{


in the kernel-doc notation:
s/fc:/@fc:/


ta.
-- 
~Randy

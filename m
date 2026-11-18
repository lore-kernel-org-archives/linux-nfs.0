Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=100.103.45.18
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1795005362;
	b=MArhJEPGoyl1yEnb3veQ5PkEK4KOdZWz4Un5MQpAxQDwz244UdFjyZMWmdTtXHhlS4X+
	 DFa9gOouM5XWoC/8/rNzUkSKUXpbZHcxEW/3idHV6Ct0FQIsqqEn37X0hBy4yOii9Rrg2
	 8PmZW7fZsM70ltCUXUSzwFTQkS5QaDzhjHqKUD9UPK9DiwOZzSlADkaUbaKXImzIVhn3Q
	 Em3FJJJEhWZ0rMrl7vKiwlVM5GEpy1NBICHkCkDQXghVODctVE/f0aMRyqvQ34jJ4Tm48
	 oYFTZ7nNB0/a4U4SMCelynk+1XInLm5XPKVYSyQayO6/8swseGKg1f4wHufVsODLkNg==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1795005362;
	h=Received:DKIM-Signature:Date:From:To:Cc:Subject:Message-ID:
	 References:MIME-Version:Content-Type:Content-Disposition:In-Reply-To;
	bh=CVVMPE+j7KjW39jvyf6/oFfejt3hTMTeayg9+QfA8JM=;
	b=jmmW7vD2SjD7LlgDBpvfw0Fk3VUPpIDpHD9EHfEMKSEY/OzfDHLKxaAq4J8piL5+W95O
	 8ehzi9cZWCkOeiEBZ0J1bzDjMFXGfJLmbX4ChJAEFJGNSkO8+LZ02iRPbHVPQxnoQnRfE
	 qpNBAMRc2y5ZD/R8P830Pr9ObFvCUk0HAndY1gRgZoIs7YnaSAEX9Ny+KHHYBpuEPGwZj
	 LM+f3Ps1qHyik2VKuVa0yjUdSIa2+TkoRcFWXNu1KkVjKG1PQzeAE4QgEm+BE/SE0xN1L
	 4XWUSYf+ChKjcmO8X4NssgP9597GZQZr/zwdHm59UXS/6GHCsJfxxoEy6OT+/uUBFqQ==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dkim=pass header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=cmhFiyIL;
	arc=none smtp.remote-ip=100.103.45.18
Received: from smtp.kernel.org (quasi.space.kernel.org [100.103.45.18])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1) server-digest SHA256)
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 6ECC8606A31C;
	Wed, 18 Nov 2026 12:36:02 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=cmhFiyIL
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 9AE051F000C4;
	Wed, 18 Nov 2026 12:35:57 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1795005362;
	bh=CVVMPE+j7KjW39jvyf6/oFfejt3hTMTeayg9+QfA8JM=;
	h=Date:From:To:Cc:Subject:References:In-Reply-To;
	b=cmhFiyILoty0S/ImExh0a7qYIzr9QxLGbi3BPcVks5rTwq7n4h5eX1E+wtvxecs6I
	 MICCZIaiZxXPWwL+28p6tfmmoutV1DIq5J14Vkrf1CM5EZ2wqvwX3vLoZKgjMx5D75
	 KMkyjRhDRpoP/TDY0jxEdlESD4QZAi8dMz/qCheRb7NWLzGd9w71fQfwy519efZtSN
	 mF4xpdK3Zso7ZVFiTFq3gufRyriGirqmZwg+cd/5bzbaCqo52hnGwXaMIdxdJMQq4M
	 +nBFYYeTqQSFzMzDB+cmQ77NGLzRNP8L9Bn1nPmZIhdN1rsfL6Fl/FjYvdqjJ2q/QZ
	 OctztNUtUxvNw==
Date: Wed, 18 Nov 2026 13:35:54 +0100
From: Christian Brauner <brauner@kernel.org>
To: Paulo Alcantara <pc@manguebit.org>, 
	David Howells <dhowells@redhat.com>
Cc: Christian Brauner <christian@brauner.io>, 
	Matthew Wilcox <willy@infradead.org>, Namjae Jeon <linkinjeon@kernel.org>, 
	Marc Dionne <marc.dionne@auristor.com>, Stefan Metzmacher <metze@samba.org>, 
	Eric Van Hensbergen <ericvh@kernel.org>, Dominique Martinet <asmadeus@codewreck.org>, 
	Ilya Dryomov <idryomov@gmail.com>, netfs@lists.linux.dev, linux-afs@lists.infradead.org, 
	linux-cifs@vger.kernel.org, linux-nfs@vger.kernel.org, ceph-devel@vger.kernel.org, 
	v9fs@lists.linux.dev, linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org
Subject: Re: [PATCH v12 5/5] cachefiles: Preset the state xattr when creating
 a new file
Message-ID: <20261118-hebamme-virtuell-boten-055bf85097a3@brauner>
References: <20260910220242.2165023-1-dhowells@redhat.com>
 <20260910220242.2165023-6-dhowells@redhat.com>
 <920f0b50480231f1af8a9c8e7f118f5c@manguebit.org>
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Post: <mailto:linux-nfs@vger.kernel.org>
List-Help: <mailto:linux-nfs+help@vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
List-Owner: <mailto:linux-nfs+owner@vger.kernel.org>
Precedence: list
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
In-Reply-To: <920f0b50480231f1af8a9c8e7f118f5c@manguebit.org>

On Fri, Sep 11, 2026 at 05:21:38PM -0300, Paulo Alcantara wrote:
> David Howells <dhowells@redhat.com> writes:
> > +	buf = kzalloc(sizeof(struct cachefiles_xattr) + min(len, sizeof(__be64)), GFP_KERNEL);
>
> You should use max() here.

Meh, this is in mainline since v7.4-rc1:

KASAN catches it reading a file through an -o fsc mount with an ext4
cache gives:

  BUG: KASAN: slab-out-of-bounds in ext4_xattr_set_entry+0xf3d/0x1bd0
  Read of size 58 by task kworker/u32:1/63
  Workqueue: fscache fscache_cookie_worker
  Call Trace:
   __asan_memcpy+0x23/0x60
   ext4_xattr_set_entry+0xf3d/0x1bd0
   ext4_xattr_block_set+0x647/0x3080
   ext4_xattr_set_handle+0xd19/0x1420
   ext4_xattr_set+0x12a/0x380
   __vfs_setxattr+0x10a/0x160
   __vfs_setxattr_noperm+0xef/0x5d0
   vfs_setxattr+0x148/0x3d0
   cachefiles_preset_object_xattr+0x191/0x5e0
   cachefiles_create_tmpfile+0x2c1/0x7f0
   cachefiles_create_file+0x6a/0x2f0
   cachefiles_look_up_object+0x715/0x8a0

With max() it's gone. David, unless you want to send it yourself I'll
put this into vfs.fixes:

diff --git a/fs/cachefiles/xattr.c b/fs/cachefiles/xattr.c
--- a/fs/cachefiles/xattr.c
+++ b/fs/cachefiles/xattr.c
@@ -44,7 +44,7 @@ int cachefiles_preset_object_xattr(struct cachefiles_object *object, struct file *file)
 	unsigned int len = object->cookie->aux_len;
 	int ret;
 
-	buf = kzalloc(sizeof(struct cachefiles_xattr) + min(len, sizeof(__be64)), GFP_KERNEL);
+	buf = kzalloc(sizeof(struct cachefiles_xattr) + max(len, sizeof(__be64)), GFP_KERNEL);
 	if (!buf)
 		return -ENOMEM;
 

-- 

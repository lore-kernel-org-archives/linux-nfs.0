Received: from smtp.kernel.org (aws-us-west-2-korg-mail-alma10-1.taild15c8.ts.net [100.103.45.18])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 05ADA3C2775;
	Mon, 10 Aug 2026 13:12:33 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=100.103.45.18
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1786367555; cv=none; b=TBCiwlaWkdiE5NDckuag8ZSXj/84oPiOUTZ2jnwI6u0SYjf1ZWvdbQDiwqs2lsKAnkIJsuXm5/fdf8pXZcdpTPd6ijaZya5vkz5kk22BCnKtBcS3JRr3L4qucFeB+/WcSHKu8Yqdo7g4i3fyLgwRfPKwsGNxmwtWNIiSZfFzDMI=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1786367555; c=relaxed/simple;
	bh=H4bkzjyn5PYFF1fjCINLDBhQNmdAHkuGSmghaii28ks=;
	h=From:To:Cc:Subject:Date:Message-ID:In-Reply-To:References:
	 MIME-Version:Content-Type; b=GHHTYLnCjo3LXs2p6f3xXaDdmCjgY1/cTkPZjPm7YW69lhd6STRnEga5eGkXE21cCkTtHNm64VPohS1X70g/Esi6pu9IHF1yoZZvrCGgxBnpYmezW83VU0uXoeQicVaq/GZYYH8PLJdsJKooCwWgRo152BEurVUXDUu1ktuCJiE=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=gD7tKxwY; arc=none smtp.client-ip=100.103.45.18
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="gD7tKxwY"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id C4B801F000E9;
	Mon, 10 Aug 2026 13:12:28 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1786367553;
	bh=gzwFhtE0Ek2LlVIsTwETJaTv5SvMI/8Bx08qLe2Vxtc=;
	h=From:To:Cc:Subject:Date:In-Reply-To:References;
	b=gD7tKxwYhcI7DHlrAioW2qhKgIAABui+x7xOWM4yNge/+pxISG8Prmuy7Nw1PWEo8
	 h0IXKke3j8f3JhEchHd2VYAiFknegfIvqbj3fZvne9Z4HdzC/03nUZtBJ3AOBDzi81
	 hmRrKeUHFkWBTJtgJ0EWBy5jiJS6xIgAOu56flgrDCUqxAJJ5fc0PbJZSysDPVWS2s
	 kMoQfcWZGyQuL/xvmYbiBn3teBRTbCUUa9+nLUu3qTZQke/zsjObGWHu7PyyAjg6TY
	 XPEotAtFQm884B2uRvPVe+xj3Qo8xDW3CUdlrdupZzS2yqdcUNZodAqzXiW3qvf52C
	 AbGgrCKjIgvcw==
From: Christian Brauner <brauner@kernel.org>
To: Matthew Wilcox <willy@infradead.org>,
	Christoph Hellwig <hch@infradead.org>,
	Christian Brauner <brauner@kernel.org>,
	David Howells <dhowells@redhat.com>
Cc: Paulo Alcantara <pc@manguebit.org>,
	Jens Axboe <axboe@kernel.dk>,
	Leon Romanovsky <leon@kernel.org>,
	Steve French <sfrench@samba.org>,
	ChenXiaoSong <chenxiaosong@chenxiaosong.com>,
	Marc Dionne <marc.dionne@auristor.com>,
	Stefan Metzmacher <metze@samba.org>,
	Eric Van Hensbergen <ericvh@kernel.org>,
	Dominique Martinet <asmadeus@codewreck.org>,
	Ilya Dryomov <idryomov@gmail.com>,
	netfs@lists.linux.dev,
	linux-afs@lists.infradead.org,
	linux-cifs@vger.kernel.org,
	linux-nfs@vger.kernel.org,
	ceph-devel@vger.kernel.org,
	v9fs@lists.linux.dev,
	linux-erofs@lists.ozlabs.org,
	linux-fsdevel@vger.kernel.org,
	linux-kernel@vger.kernel.org
Subject: Re: [PATCH v8 00/25] netfs: Keep track of folios in a segmented bio_vec[] chain
Date: Mon, 10 Aug 2026 15:12:23 +0200
Message-ID: <20260810-luftdicht-popmusik-hypen-61dd8d9e3c06@brauner>
X-Mailer: git-send-email 2.53.0
In-Reply-To: <20260804100224.2748935-1-dhowells@redhat.com>
References: <20260804100224.2748935-1-dhowells@redhat.com>
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
X-Developer-Signature: v=1; a=openpgp-sha256; l=3993; i=brauner@kernel.org; h=from:subject:message-id; bh=H4bkzjyn5PYFF1fjCINLDBhQNmdAHkuGSmghaii28ks=; b=owGbwMvMwCU28Zj0gdSKO4sYT6slMWRVnrN4Erc35H3fhn/clms7GJ4uEZWeJhcuUrNrW+arA JGQ3SaJHaUsDGJcDLJiiiwO7Sbhcst5KjYbZWrAzGFlAhnCwMUpABfhYPinGptzyGzilt/72nwE E3ab2vZrKqdG7hRYYeuScWP2gbQTjAwHlysWdRuZxNts5j2tfWFGkW/arCzbN+KvBaYoVvILruU DAA==
X-Developer-Key: i=brauner@kernel.org; a=openpgp; fpr=4880B8C9BD0E5106FC070F4F7B3C391EFEA93624
Content-Transfer-Encoding: 8bit

On Tue, 04 Aug 2026 11:01:55 +0100, David Howells wrote:
> Could you add these patches to the VFS tree for next?
> 
> The patches get rid of folio_queue, rolling_buffer and ITER_FOLIOQ,
> replacing the folio queue construct used to manage buffers in netfslib with
> one based around a segmented chain of bio_vec arrays instead.  There are
> three main aims here:
> 
> [...]

Applied to the vfs-7.3.netfs branch of the vfs/vfs.git tree.
Patches in the vfs-7.3.netfs branch should appear in linux-next soon.

Please report any outstanding bugs that were missed during review in a
new review to the original patch series allowing us to drop it.

It's encouraged to provide Acked-bys and Reviewed-bys even though the
patch has now been applied. If possible patch trailers will be updated.

Note that commit hashes shown below are subject to change due to rebase,
trailer updates or similar. If in doubt, please check the listed branch.

tree:   https://git.kernel.org/pub/scm/linux/kernel/git/vfs/vfs.git
branch: vfs-7.3.netfs

[01/25] mm: Make readahead store folio count in readahead_control
        https://git.kernel.org/vfs/vfs/c/bb16bd52f872
[02/25] netfs: Bulk load the readahead-provided folios up front
        https://git.kernel.org/vfs/vfs/c/49fe2955409b
[03/25] Add a function to kmap one page of a multipage bio_vec
        https://git.kernel.org/vfs/vfs/c/71947db0b6b2
[04/25] iov_iter: Make iov_iter_get_pages*() wrap iov_iter_extract_pages()
        https://git.kernel.org/vfs/vfs/c/fc0f8aa28cb0
[05/25] iov_iter: Add a segmented queue of bio_vec[]
        https://git.kernel.org/vfs/vfs/c/b7eab1a852c3
[06/25] netfs: Add some tools for managing bvecq chains
        https://git.kernel.org/vfs/vfs/c/a8e973126d3f
[07/25] netfs: Make mempool available for bvecq
        https://git.kernel.org/vfs/vfs/c/c95787e047bf
[08/25] netfs: Add a function to extract from an iter into a bvecq
        https://git.kernel.org/vfs/vfs/c/8854b625d977
[09/25] afs: Use a bvecq to hold dir content rather than folioq
        https://git.kernel.org/vfs/vfs/c/acb8eed74013
[10/25] cifs: Use a bvecq for buffering instead of a folioq
        https://git.kernel.org/vfs/vfs/c/b0d72aea6001
[11/25] smbdirect: Support ITER_BVECQ in smbdirect_map_sges_from_iter()
        https://git.kernel.org/vfs/vfs/c/27a6832d7b93
[12/25] netfs: Remove the writethrough code
        https://git.kernel.org/vfs/vfs/c/de4a0d855ae3
[13/25] cachefiles,netfs: sunset ondemand mode
        https://git.kernel.org/vfs/vfs/c/3b09163b7bed
[14/25] cachefiles: Don't rely on backing fs storage map for most use cases
        https://git.kernel.org/vfs/vfs/c/f3ac229c89a0
[15/25] netfs: Add the cache object ID to netfs_read/write tracepoints
        https://git.kernel.org/vfs/vfs/c/592472ff5a77
[16/25] netfs: Switch to using bvecq rather than folio_queue and rolling_buffer
        https://git.kernel.org/vfs/vfs/c/4c9ea0ae64f9
[17/25] smbdirect: Remove support for ITER_FOLIOQ from smbdirect_map_sges_from_iter()
        https://git.kernel.org/vfs/vfs/c/c9529300bd22
[18/25] netfs: Remove netfs_alloc/free_folioq_buffer()
        https://git.kernel.org/vfs/vfs/c/bc89b7f32adb
[19/25] netfs: Remove netfs_extract_user_iter()
        https://git.kernel.org/vfs/vfs/c/e533d0d598c4
[20/25] iov_iter: Remove ITER_FOLIOQ
        https://git.kernel.org/vfs/vfs/c/ca929d6a6044
[21/25] netfs: Remove folio_queue and rolling_buffer
        https://git.kernel.org/vfs/vfs/c/6440cb5fd08b
[22/25] netfs: Check for too much data being read
        https://git.kernel.org/vfs/vfs/c/353f336ead13
[23/25] netfs: Limit the minimum trigger for progress reporting
        https://git.kernel.org/vfs/vfs/c/0150b23b0a63
[24/25] netfs: Combine prepare and issue ops and grab the buffers on request
        https://git.kernel.org/vfs/vfs/c/473527604b71
[25/25] cachefiles: Preset the state xattr when creating a new file
        https://git.kernel.org/vfs/vfs/c/9476c221814c

Received: from smtp.kernel.org (aws-us-west-2-korg-mail-alma10-1.taild15c8.ts.net [100.103.45.18])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 1089E374A12;
	Fri,  2 Oct 2026 10:07:41 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=100.103.45.18
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1790935663; cv=none; b=lRSGM8bT1G3gnk+YdWFafFkD8vif8IMDn64B2yJSqTeg96rD21H1cc7hhuQyT2QSdGqpR8EBBdfsTLe86NCL9INwm1Wt7W+ODpwznU24/0atChT5hJCBvybiRd9v7N7lmlgpVCvevlS11kBKZ0Mo4TM8y6ZaBDLDHKCXIJmmFpM=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1790935663; c=relaxed/simple;
	bh=0mTU4GXrzawN6cP4nmnSp0HVBlilX5z+tSvo0yS7r1g=;
	h=From:To:Cc:Subject:Date:Message-ID:In-Reply-To:References:
	 MIME-Version:Content-Type; b=HhdrhDeXQv/N9c5Bu8mT+0v17vtMT9jpD9roHULZOSCP1C8Jt9it/5tqCEUorsU+ayvaS0LX/CzwPARg4I7ajUDP4s3r6ZlWYnytIOk09CpVE+8qow1wlx+1ouknFzxvjCEgFjkK4ihi37j1s7bwYLWGuntVXatAJ47flBR1MvQ=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=llK4AeWe; arc=none smtp.client-ip=100.103.45.18
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="llK4AeWe"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id D88951F000FF;
	Fri,  2 Oct 2026 10:07:37 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1790935661;
	bh=u1r9CsebzekmHkUWNJ3ne/263jxtn1b01RsvPf0B/JQ=;
	h=From:To:Cc:Subject:Date:In-Reply-To:References;
	b=llK4AeWe82evvjfhPvoLp2Z0aiSjCR/QWdh6SsroPBJMnxYma70OWt7dlFdvXn+f0
	 +s4qQ7aPwiNjRr5bRrZQ2zRjlsZsrgMIlyuA9aY1BZiCrCidngSwEf4EkmW0REQag5
	 xn+tZCOdl/C96oCXNKe2MLyRQvUgvU8vZQGjUTtr4wLcJtOMlAwXsPcvkfJ8n9Yjj4
	 l7nwRBk13YQG1Kb27SpsBO76f4VpkCwE1lVqTmEViMmxV7MgCTEdnj9TBvcAh2Ow6w
	 VUSqTzZleN/6E8YNP9dOm+bVlaHCjP4Dk6lBS1uQhqSfV+EjQ9f2/vLKqQyitWZn+U
	 1MACGMpAkqzPQ==
From: Christian Brauner <brauner@kernel.org>
To: Christian Brauner <brauner@kernel.org>,
	David Howells <dhowells@redhat.com>
Cc: Paulo Alcantara <pc@manguebit.org>,
	Matthew Wilcox <willy@infradead.org>,
	Namjae Jeon <linkinjeon@kernel.org>,
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
	linux-fsdevel@vger.kernel.org,
	linux-kernel@vger.kernel.org
Subject: Re: [PATCH v15 00/10] netfs, iov_iter: Use a chain of bio_vec arrays instead of folio_queue
Date: Fri,  2 Oct 2026 12:07:29 +0200
Message-ID: <20261002-fachsimpeln-hasten-situation-84f466b5d3cb@brauner>
X-Mailer: git-send-email 2.53.0
In-Reply-To: <20261001091239.3343034-1-dhowells@redhat.com>
References: <20261001091239.3343034-1-dhowells@redhat.com>
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
X-Developer-Signature: v=1; a=openpgp-sha256; l=2644; i=brauner@kernel.org; h=from:subject:message-id; bh=0mTU4GXrzawN6cP4nmnSp0HVBlilX5z+tSvo0yS7r1g=; b=owGbwMvMwCU28Zj0gdSKO4sYT6slMWTtb0oz8mVJ/rZu5oWEsKQzaYzdQo3mBlNteabbf8wSe pZi3721o5SFQYyLQVZMkcWh3SRcbjlPxWajTA2YOaxMIEMYuDgFYCLq+owMF22b3r8V2TvvxOu/ nPJ3fY8xODx0vT4lVHhS7Nw56x6/rWL4K7ZH4p7wAudjvx6z3BPa3GMnc+3J66Ka8ilPghfYLgo 4xgIA
X-Developer-Key: i=brauner@kernel.org; a=openpgp; fpr=4880B8C9BD0E5106FC070F4F7B3C391EFEA93624
Content-Transfer-Encoding: 8bit

On Thu, 01 Oct 2026 10:12:28 +0100, David Howells wrote:
> Could you pull these patches please into your vfs-7.4.netfs branch?  This
> is the third of four (maybe five) batches, in this case replacing the
> folio_queue struct with a bvecq struct, and is based upon the
> aforementioned branch.  This was split from v11 of a larger netfslib
> series[1].  I've fixed some issues spotted by sashiko[5-7].
> 
> This series adds a new type, struct bvecq.  This points to a bounded array
> of bio_vecs with information about how to clean up the memory they point
> to.  A number of bvecq structs can be linked together to form a chain and
> an iterator type, ITER_BVECQ, is provided that can be pointed at the chain
> and can walk it.  Netfslib is then switched to use the new type and
> folio_queue is removed along with ITER_FOLIOQ.
> 
> [...]

Applied to the vfs-7.4.netfs branch of the vfs/vfs.git tree.
Patches in the vfs-7.4.netfs branch should appear in linux-next soon.

Please report any outstanding bugs that were missed during review in a
new review to the original patch series allowing us to drop it.

It's encouraged to provide Acked-bys and Reviewed-bys even though the
patch has now been applied. If possible patch trailers will be updated.

Note that commit hashes shown below are subject to change due to rebase,
trailer updates or similar. If in doubt, please check the listed branch.

tree:   https://git.kernel.org/pub/scm/linux/kernel/git/vfs/vfs.git
branch: vfs-7.4.netfs

[01/10] Add a function to kmap one page of a multipage bio_vec
        https://git.kernel.org/vfs/vfs/c/a6a7576e126e
[02/10] iov_iter: Add a segmented queue of bio_vec[]
        https://git.kernel.org/vfs/vfs/c/05f94143ca30
[03/10] netfs: Add some tools for managing bvecq chains
        https://git.kernel.org/vfs/vfs/c/29d66a06098a
[04/10] afs: Use a bvecq to hold dir content rather than folioq
        https://git.kernel.org/vfs/vfs/c/cac55bc34a56
[05/10] cifs: Use a bvecq for buffering instead of a folioq
        https://git.kernel.org/vfs/vfs/c/b84e753bb326
[06/10] smbdirect: Support ITER_BVECQ in smbdirect_map_sges_from_iter()
        https://git.kernel.org/vfs/vfs/c/787366e144a5
[07/10] netfs: Switch folioq to bvecq
        https://git.kernel.org/vfs/vfs/c/f6da2ecbfbce
[08/10] smbdirect: Remove support for ITER_FOLIOQ from smbdirect_map_sges_from_iter()
        https://git.kernel.org/vfs/vfs/c/e85d0262d3c1
[09/10] iov_iter: Remove ITER_FOLIOQ
        https://git.kernel.org/vfs/vfs/c/e488bc1d0deb
[10/10] netfs: Remove folio_queue
        https://git.kernel.org/vfs/vfs/c/f71507811163

Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=100.103.45.18
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1795167522;
	b=OpkBCQa+hyguvi92icHIP8TNeqUYSEyPd9qN5b0vicJ410LO1LWtvzmfwfb3Ms2JfrAZ
	 lkwIKRUOYhyDdo/6xvA59eTpurKsOrhIY0dAYgtfWl2UqL453N8sxv9wcOUCYT6hBco5J
	 TRQr0PCs5WevktPQ52n0TY5TbfESwI0XL1+zzZc+GlyJm0HuyG8+NDFQLFdDQ/B8i4wEH
	 8OvvKPZMjGrGR/Gy729oyo2Ckqp1XrTi5Z00mnaDPx3PI5f/cd49vcemoJOTKWo6Mj8iH
	 vZ48N+54b+V24LkV7yWE6kb9oKSlXt0uy3sVZdMBmfMPiCGjFUYb79vf10yDRx1w4RA==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1795167522;
	h=Received:DKIM-Signature:From:To:Cc:In-Reply-To:References:Subject:
	 Message-Id:Date:MIME-Version:Content-Type:Content-Transfer-Encoding:
	 X-Mailer;
	bh=Afd1H3HLHSzEfHiPoIegI1/ZAbqBna+yrjuMxmwAVis=;
	b=jm6BIZKBbRd72vwuc+dOpELu7YHRywoTj3Y08SkcighrlOVVW7QS2Y7tjuE+CT/AZPvJ
	 dAcQv/1sjcPXgtaFsFLI6Q5naMScxS3BNRQ8UoWiBLWsBNnV5VDNTLR8yXzkSBQW1Ujse
	 TsGUuFDPRr1vRXWdYAOkDO3GgNedGwrY3Y7b/6yQRToTMTnHQbcrlnvLxaaIG2Uc/dNB7
	 i+xBxEcJy1RqW9iRRpmIL17ldY8T8x5YG3otHAi25ddfCD0MdjPro2Ug9fJFqkUgo+Jx3
	 yPImE8XKgeTxuuoFpDZKsp9fv5EVOjzTPuQaaEts1zbZ3HXk/F1Nl3zXAyDp7/Sh0qw==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dkim=pass header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=P9BgjAry;
	arc=none smtp.remote-ip=100.103.45.18
Received: from smtp.kernel.org (quasi.space.kernel.org [100.103.45.18])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 3A995606A33B;
	Fri, 20 Nov 2026 09:38:42 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=P9BgjAry
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 243BC1F000D1;
	Fri, 20 Nov 2026 09:38:37 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1795167522;
	bh=Afd1H3HLHSzEfHiPoIegI1/ZAbqBna+yrjuMxmwAVis=;
	h=From:To:Cc:In-Reply-To:References:Subject:Date;
	b=P9BgjAryBt+3bY5m/SLXSxDvgSE1J5cTrN85T5FlspUqiGiRY+TDcTEQ2pB+Nk2WU
	 s/l3tIaGXPJB9IOZTFkyiZ/fF365eqlMfnnqd9D0DGZLkjU75jkjP13P+Vod8jrI39
	 jZfj5MkeQITq6V0NHMDic6D3NOk7jBAj1QlAmaX/Nn3pDgRjqlJSpkvDN475/j2XI/
	 MOBD20m1QYazNVzMBEAmFRDMGtM5LG2aKs6GgBN0tPDHSP9WcIbF3Hq6WccgG0xPE+
	 T544xi1ba+5i3xtr7VaobdBha5xS9kHMn/K70pDpAY83IRBB3VM8IhXEWr08NU0OBe
	 Uln8HSiREyYaA==
From: Christian Brauner <brauner@kernel.org>
To: Christian Brauner <brauner@kernel.org>, 
 David Howells <dhowells@redhat.com>
Cc: Paulo Alcantara <pc@manguebit.org>, 
 Matthew Wilcox <willy@infradead.org>, Namjae Jeon <linkinjeon@kernel.org>, 
 Marc Dionne <marc.dionne@auristor.com>, Stefan Metzmacher <metze@samba.org>, 
 Eric Van Hensbergen <ericvh@kernel.org>, 
 Dominique Martinet <asmadeus@codewreck.org>, 
 Ilya Dryomov <idryomov@gmail.com>, netfs@lists.linux.dev, 
 linux-afs@lists.infradead.org, linux-cifs@vger.kernel.org, 
 linux-nfs@vger.kernel.org, ceph-devel@vger.kernel.org, v9fs@lists.linux.dev, 
 linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org
In-Reply-To: <20261119083851.3306418-1-dhowells@redhat.com>
References: <20261119083851.3306418-1-dhowells@redhat.com>
Subject: Re: [PATCH v19 00/17] netfs, iov_iter: Use a chain of bio_vec
 arrays instead of folio_queue
Message-Id: <20261120-koriander-wohnform-parolen-1f10ac9dbc4e@brauner>
Date: Fri, 20 Nov 2026 10:38:35 +0100
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Post: <mailto:linux-nfs@vger.kernel.org>
List-Help: <mailto:linux-nfs+help@vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
List-Owner: <mailto:linux-nfs+owner@vger.kernel.org>
Precedence: list
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
X-Mailer: b4 0.17-dev-04696

On Thu, 19 Nov 2026 08:38:31 +0000, David Howells wrote:
> Could you pull these patches please into your vfs-7.5.netfs branch?  This
> is the third of five batches (two already having gone upstream), in this
> case replacing the folio_queue struct with a bvecq struct.  It has been
> rebased on v7.4-rc3.  This was split from v11 of a larger netfslib
> series[1].
> 
> This series adds a new type, struct bvecq.  This points to a bounded array
> of bio_vecs with information about how to clean up the memory they point
> to.  A number of bvecq structs can be linked together to form a chain and
> an iterator type, ITER_BVECQ, is provided that can be pointed at the chain
> and can walk it.  Netfslib is then switched to use the new type and
> folio_queue is removed along with ITER_FOLIOQ.
> 
> [...]

Applied to the vfs-7.5.netfs branch of the vfs/vfs.git tree.
Patches in the vfs-7.5.netfs branch should appear in linux-next soon.

Please report any outstanding bugs that were missed during review in a
new review to the original patch series allowing us to drop it.

It's encouraged to provide Acked-bys and Reviewed-bys even though the
patch has now been applied. If possible patch trailers will be updated.

Note that commit hashes shown below are subject to change due to rebase,
trailer updates or similar. If in doubt, please check the listed branch.

tree:   https://git.kernel.org/pub/scm/linux/kernel/git/vfs/vfs.git
branch: vfs-7.5.netfs

[01/17] iov_iter: Fix kunit test to remove __init and __refdata marks
        https://git.kernel.org/vfs/vfs/c/1bce9def76dd
[02/17] block: Add a function to kmap one page of a multipage bio_vec
        https://git.kernel.org/vfs/vfs/c/14e2292a9706
[03/17] iov_iter: Add a segmented queue of bio_vec[]
        https://git.kernel.org/vfs/vfs/c/5f1dd24265f0
[04/17] netfs: Add some tools for managing bvecq chains
        https://git.kernel.org/vfs/vfs/c/b4e0ea3853e5
[05/17] iov_iter: Add an API document for the bvecq structure
        https://git.kernel.org/vfs/vfs/c/ca90a27f2d94
[06/17] iov_iter: Add a bvecq kunit test
        https://git.kernel.org/vfs/vfs/c/0a2f9551262e
[07/17] afs: Fix an inconsistency in the symlink code
        https://git.kernel.org/vfs/vfs/c/44921a81054c
[08/17] netfs: Explicitly pass tail padding to netfs_writeback_single()
        https://git.kernel.org/vfs/vfs/c/7a3a80623cca
[09/17] netfs: Change netfs_writeback_single() to not look inside the iterator
        https://git.kernel.org/vfs/vfs/c/6703bfa120ef
[10/17] netfs: Pass the write length to request creation where appropriate
        https://git.kernel.org/vfs/vfs/c/c7496c6ed431
[11/17] afs: Use a bvecq to hold dir content rather than folioq
        https://git.kernel.org/vfs/vfs/c/65752f84cf61
[12/17] cifs: Use a bvecq for buffering instead of a folioq
        https://git.kernel.org/vfs/vfs/c/145d329f12ee
[13/17] smbdirect: Support ITER_BVECQ in smbdirect_map_sges_from_iter()
        https://git.kernel.org/vfs/vfs/c/adf3cafd9933
[14/17] netfs: Switch folioq to bvecq
        https://git.kernel.org/vfs/vfs/c/5b95afa0aeaf
[15/17] smbdirect: Remove support for ITER_FOLIOQ from smbdirect_map_sges_from_iter()
        https://git.kernel.org/vfs/vfs/c/c7879d1a4e06
[16/17] iov_iter: Remove ITER_FOLIOQ
        https://git.kernel.org/vfs/vfs/c/3d9d0bbb7fcd
[17/17] netfs: Remove folio_queue
        https://git.kernel.org/vfs/vfs/c/d6d5b8979e5d


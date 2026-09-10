Received: from smtp.kernel.org (aws-us-west-2-korg-mail-alma10-1.taild15c8.ts.net [100.103.45.18])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id B84C341D659;
	Thu, 10 Sep 2026 08:11:38 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=100.103.45.18
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1789027900; cv=none; b=Ra8gYRe6ss+lBA32ycWdJVbb/i1cOY97R1n14RReNMXJQnfO3OzSid0Oj9NN10CGiyM453xw1RICHoSAhufwliPLDESJkbDsetW7vooHBOfL1N6qwBZ7llUEvS+Ykf1dvV3fJD2B2Xt94hYImfLdR/s00UT4SMzVapV0dzRwGcM=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1789027900; c=relaxed/simple;
	bh=PSYLbShhpWiv3aVB2nJrOHdeh7Z3k4zELmiY4CjG9uE=;
	h=From:To:Cc:In-Reply-To:References:Subject:Message-Id:Date:
	 MIME-Version:Content-Type; b=APz4CCiH+scFj5VaY5yCvC3vSP3RkakrrQqCN0KZJxQqOQRl9O8N8PvOv3WJ5sDVO3a3lyzW4l3fMMYMy/azwITyD5I/W4ZJ1O9lioVpnGUkkI94lQKNvaZwiMHjn5vg600ILmXr7WfEKx56KAqU3h0QGGIZKe3Lqkdm3He+LXM=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=DAqb16Lh; arc=none smtp.client-ip=100.103.45.18
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="DAqb16Lh"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 06D241F000FF;
	Thu, 10 Sep 2026 08:11:33 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1789027898;
	bh=Bl2jWTajUKdkFTVEmaIsZckt4uMF6UIWmGeyLi3kFQg=;
	h=From:To:Cc:In-Reply-To:References:Subject:Date;
	b=DAqb16LhXA4V3x2MEBgyebklpieMD75ealCT6F60CkFf+1FpmPAJyTfsmtGyVFhzC
	 Eekvf46yp132dC4zoRl85r5FXyUpUdsWXVUh08Xcz1+9bOVObP5c6h1fXfZmlaxrzM
	 P2tKsaJycMsQjasylX2DwThvMnSOubkKYXSyhG5k+ZOmCTZPVPkzq9xY4H9AAtgM2+
	 bv/gFqBICa+dxei6mzc0FdAoQcLhta8R015Ur710MTEVpZDuYI8huu5pliRpIvykY1
	 PM3ORUCluTaMjr1OPi/LRpzglnTOCs6cwf/AQvzv4pOZJCfOVOQQWJkrVBZxdVs+Io
	 bpZbmlO4+cExw==
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
 linux-erofs@lists.ozlabs.org, linux-fsdevel@vger.kernel.org, 
 linux-kernel@vger.kernel.org
In-Reply-To: <20260909072105.1663687-1-dhowells@redhat.com>
References: <20260909072105.1663687-1-dhowells@redhat.com>
Subject: Re: [PATCH v13 0/8] netfs: Miscellaneous preparatory changes
Message-Id: <20260910-rohrkrepierer-clinchen-affront-100171384452@brauner>
Date: Thu, 10 Sep 2026 10:11:29 +0200
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
X-Mailer: b4 0.17-dev-db0b7
X-Developer-Signature: v=1; a=openpgp-sha256; l=1938; i=brauner@kernel.org;
 h=from:subject:message-id; bh=PSYLbShhpWiv3aVB2nJrOHdeh7Z3k4zELmiY4CjG9uE=;
 b=owGbwMvMwCU28Zj0gdSKO4sYT6slMWQtSjPOTU++uvzGNKGtX+59+bbANNaqinHmG+kZFS+fz
 imr/6Fl01HKwiDGxSArpsji0G4SLrecp2KzUaYGzBxWJpAhDFycAjCRiX6MDLNL9Jr6i6ZfcHJI
 5Zibue9R84UHvjxep8JUI2eX/pB/28/IcMBbawZXzeYHH6JTJjpNWJb77J//i10b/F5X3sh6F7u
 ilg0A
X-Developer-Key: i=brauner@kernel.org; a=openpgp;
 fpr=4880B8C9BD0E5106FC070F4F7B3C391EFEA93624

On Wed, 09 Sep 2026 08:20:54 +0100, David Howells wrote:
> netfs: Miscellaneous preparatory changes
> 
> Hi Christian,
> 
> Could you pull these patches please for -next?  This is the first of four
> batches.  This is based on your vfs.fixes as there are some prerequisite
> patches there.  This was split from v11 of a larger series[1].
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

[1/8] netfs: Use uoff_t instead of unsigned long long and loff_t
      https://git.kernel.org/vfs/vfs/c/0447d3e7ca81
[2/8] netfs: Remove the writethrough code
      https://git.kernel.org/vfs/vfs/c/1c167be3e3f3
[3/8] netfs: trace: Change the "clear" folio traces to "endwb"
      https://git.kernel.org/vfs/vfs/c/b4c9fce24e25
[4/8] netfs: trace: Rejig a couple of the tracepoints
      https://git.kernel.org/vfs/vfs/c/80fe2005dc3c
[5/8] netfs: Add the cache object ID to netfs_read/write tracepoints
      https://git.kernel.org/vfs/vfs/c/b1abd92147b1
[6/8] netfs: Make deprecated PG_private_2 support opt-in
      https://git.kernel.org/vfs/vfs/c/e5c67dd3bbf7
[7/8] netfs: Add some functions to wrap the all-queued handling
      https://git.kernel.org/vfs/vfs/c/a38f37509940
[8/8] netfs: Set subrequest->source at alloc before trace emission
      https://git.kernel.org/vfs/vfs/c/3df7501ad939


Received: from smtp.kernel.org (aws-us-west-2-korg-mail-alma10-1.taild15c8.ts.net [100.103.45.18])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id E002437268A;
	Fri, 16 Oct 2026 15:07:54 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=100.103.45.18
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1792163275; cv=none; b=qJp0cGW+KOj9nXrwT7gKVFr+6XrjESpK6qpY+rP7urVwsQ3pXqen8W+h/Eu0wGxtc2YJIqZhwx3w8KoopM0nopR8qt0Nlykpuv0x24f68/Y9ABKeVqbbFh+O3Z4wES1dZsWjzz/ze7K+8WEmsk1cLTfAoDswm9zWJf/tdGP97dE=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1792163275; c=relaxed/simple;
	bh=2SgDK5SsCZkw3vwg5e4zmLrYzqYgnUyvSCT2ZzDT44g=;
	h=From:To:Cc:Subject:Date:Message-ID:In-Reply-To:References:
	 MIME-Version:Content-Type; b=k9DngA10jJ+XVPTDwobHaLUInSlp5nMXOw3uBTb1g+iQGM9K5kAJyj5RFiJgyvkesjVZ9SsndnT2Qx42juXknUXuG6C5+8NBpw3IXSJmzc88zfY6mF794EswX9fc/1qhx6UISxbEOOwITFBR/5RX520Vrh9t9wHyD1DW320dwv8=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=O5VsNf46; arc=none smtp.client-ip=100.103.45.18
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="O5VsNf46"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 9B1161F000C4;
	Fri, 16 Oct 2026 15:07:53 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1792163274;
	bh=t81fDmDERrOEPxXdiPfTcNBp/WX5Dx4aZa3z7Ylvso4=;
	h=From:To:Cc:Subject:Date:In-Reply-To:References;
	b=O5VsNf46jlclQBIuDiDyJQF1R+QtZ3NR1qiwMRijih6Sy1GMEiDCQNal2kbeVxVZH
	 Kbxnc13w+D4G2lP4vMl9a5u/pxj6U9Q9oz8dgjQML03jaecxOWolTiu8KfSZOcbRPp
	 qXixzdyBoKJOZpkTObKQ94L1TNdERoxn3aYL3xU7KTNwh9tlf/Th1/EZPNLab6/Y7b
	 2DJHXaPFdiNAYwZUtgm58deEyHNyfckhL/T1h4c+PAbNnsrGg4dNNmplVKxFOxwOon
	 wzvbshYuBAZ9AemMRkMMZ5QDVaD0Xhfi7CG6GdNByUhHDtJDFcqZhPxwMZlROxfcHt
	 b7K9dYexS6X6A==
From: Chuck Lever <cel@kernel.org>
To: Jeff Layton <jlayton@kernel.org>,
	NeilBrown <neil@brown.name>,
	Olga Kornievskaia <okorniev@redhat.com>,
	Dai Ngo <Dai.Ngo@oracle.com>,
	Tom Talpey <tom@talpey.com>,
	Daejun Park <daejun7.park@samsung.com>
Cc: Christoph Hellwig <hch@lst.de>,
	Benjamin Coddington <bcodding@redhat.com>,
	Trond Myklebust <trondmy@kernel.org>,
	Anna Schumaker <anna@kernel.org>,
	linux-nfs@vger.kernel.org,
	linux-kernel@vger.kernel.org
Subject: Re: [PATCH v3 0/7] nfsd: layout recall and lease break fixes
Date: Fri, 16 Oct 2026 11:07:48 -0400
Message-ID: <179216321999.3259068.1930105017871798851.b4-ty@b4>
X-Mailer: git-send-email 2.54.0
In-Reply-To: <20261015-nfsd-layout-recall-v3-0-ba3269f8ca22@samsung.com>
References: <20261015-nfsd-layout-recall-v3-0-ba3269f8ca22@samsung.com>
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 8bit

On Thu, 15 Oct 2026 13:15:41 +0900, Daejun Park wrote:
> nfsd polls a client that has accepted a CB_LAYOUTRECALL by sending the
> callback again every 10 ms, with the stateid of the first callback. A
> Linux client from v6.8 on answers the repeat with NFS4ERR_OLD_STATEID,
> and nfsd takes that as a failed recall. So a client that needs more than
> 10 ms to return a layout has the layout revoked and the fence path run.
> With the block layout that client loses data it has written and synced,
> with the SCSI layout it is cut off from the device. Patch 6 lets nfsd
> keep polling instead.
> 
> [...]

Applied to nfsd-testing, thanks!

[1/7] nfsd: fail a LAYOUTGET in progress when the layout lease is broken
      commit: d515165272ab36d84d3de3ef47e515f8b4a89d9a
[2/7] nfsd: answer NFS4ERR_DELAY instead of waiting for a layout recall
      commit: 9d05d7591a48bc4a0a3090d08ba0df11d14882c4
[3/7] nfsd: make the time limit of a layout recall work
      commit: 3d7313ec82ddf16ea9079c2c972cacafaff28aa8
[4/7] nfsd: run the fence script when a block layout lease break times out
      commit: 7c59b6dd394c3e88962c7a8d38f58f4de429d94e
[5/7] nfsd: end a layout recall once a lease break has fenced the client
      commit: f4236d9aea0e97062d9a33ad64679d5b0e0ff5de
[6/7] nfsd: keep polling a layout recall answered with NFS4ERR_OLD_STATEID
      commit: 466ed0b27822450edb52e3332d60bd5d8975b917
[7/7] nfsd: do not fence a client for a layout recall with no layouts left
      commit: f8ee816e1c8b4de47ebd8f7ca8e8b4a488de53b7

--
Chuck Lever


Received: from smtp.kernel.org (aws-us-west-2-korg-mail-alma10-1.taild15c8.ts.net [100.103.45.18])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 0A0B43D5C05;
	Fri, 25 Sep 2026 14:15:09 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=100.103.45.18
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1790345711; cv=none; b=rvRii15Ay70crZaPYXdKbpBxRqxurAgjwIB76fsHnybJ/ynTSW+kSlitbizTLlug+Asyuq2p/cNPShQXw3dm1dL+0lQSFJcc58VXUs3KgrGfmucGo4vZ8OVO/N2ihuWquKEAbUIK7Y5IMrpW0t2b/HsQ8CGKYjzzwWAQ/N8enOk=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1790345711; c=relaxed/simple;
	bh=Nhzcuaa19S/4QH0u1yNemZrARjjDFHHWAbX7Sg/uii0=;
	h=From:To:Cc:In-Reply-To:References:Subject:Message-Id:Date:
	 MIME-Version:Content-Type; b=D/2KrouqD0jD9bEsQZpTQgcewr/kb+sTk3bRkCntoFP/oi8pmJW7auCxBW02mv6x8lKAQb1UZI7DQbxtZz3IWLj0Yd8C4F4n3F17aumpKk6XkcAtCtsHbCwIqK+q0AbW7MFY9fEbFZEsz4ckRCEcQeuQZRuztVKn7PgRZXjdiFs=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=VcaC0h6T; arc=none smtp.client-ip=100.103.45.18
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="VcaC0h6T"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 9C3141F000FF;
	Fri, 25 Sep 2026 14:15:05 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1790345709;
	bh=MIe23nsde5XC5yVj3zneg2fItu+VCNKw2E2wq5yQiZ8=;
	h=From:To:Cc:In-Reply-To:References:Subject:Date;
	b=VcaC0h6ThfWLU0dY3RnDbS/2UX9Srn1tRcz0irJM91BitNgejZb5rkFkfp6LAr4hs
	 JVNORK4Uq6TEQeFcmJBrtMVsP5Dnq+c3EE7hJG5bf7EdI1X4tJMGxa+Wf0SoqcQE4s
	 tsJRuCEs8LpR0opajlU/v5Dhx5dnIEm2OqWeN5pZeOX0/gE7CPDuhq79HGUgKhRRoi
	 IDuzzmBbJgwLU2AV4BhhsMG1Y0/tcG50oqt0+1G4b13TzeeMMnh5bh1ZdP6RRYlu2t
	 xFuYpHSzMMjM8TXj5d1GJiYONvv3crgvc2HFcmlF1HQkvA03AU9W1GHh5YedZZkIGI
	 /OVlmA/pHjshA==
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
In-Reply-To: <20260910220242.2165023-1-dhowells@redhat.com>
References: <20260910220242.2165023-1-dhowells@redhat.com>
Subject: Re: [PATCH v12 0/5] netfs, cachefiles: Changes for next, primarily
 occupancy tracking-related
Message-Id: <20260925-entbehren-dasein-toben-4bb08888fa6a@brauner>
Date: Fri, 25 Sep 2026 16:15:01 +0200
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
X-Mailer: b4 0.17-dev-db0b7
X-Developer-Signature: v=1; a=openpgp-sha256; l=1696; i=brauner@kernel.org;
 h=from:subject:message-id; bh=Nhzcuaa19S/4QH0u1yNemZrARjjDFHHWAbX7Sg/uii0=;
 b=owGbwMvMwCU28Zj0gdSKO4sYT6slMWRta3zu9ejPksnvHCdsrAyaqDf31UaOw0H+30O8DY96/
 c24ZLnoX0cpC4MYF4OsmCKLQ7tJuNxynorNRpkaMHNYmUCGMHBxCsBE8kMZ/nBZ1n0LnC6Tz/DA
 fK/MoRtt33Q9ZDWLPptVOP9nN/1gY8rI8IPFWylD066JLyLn4Cq3vRP//WANW3Dc8U2Dm6ry2rB
 NvAA=
X-Developer-Key: i=brauner@kernel.org; a=openpgp;
 fpr=4880B8C9BD0E5106FC070F4F7B3C391EFEA93624

On Thu, 10 Sep 2026 23:02:35 +0100, David Howells wrote:
> netfs, cachefiles: Changes for next, primarily occupancy tracking-related
> 
> Hi Christian,
> 
> Could you pull these patches please into your vfs-7.4.netfs branch?  This
> is the second of four batches, in this case dealing with cachefiles, and is
> based upon the aforementioned branch.  This was split from v11 of a larger
> netfslib series[1].
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

[1/5] cachefiles: Clean up cachefiles_do_prepare_read()
      https://git.kernel.org/vfs/vfs/c/c9e86618da69
[2/5] netfs, cachefiles: Add a couple of traces for write failure
      https://git.kernel.org/vfs/vfs/c/4f973d314d59
[3/5] cachefiles: Add a tracepoint to log insufficient space errors
      https://git.kernel.org/vfs/vfs/c/dd79f8c90ea8
[4/5] cachefiles: Don't rely on backing fs storage map for most use cases
      https://git.kernel.org/vfs/vfs/c/c8d890e089a1
[5/5] cachefiles: Preset the state xattr when creating a new file
      https://git.kernel.org/vfs/vfs/c/f96cbb18159f


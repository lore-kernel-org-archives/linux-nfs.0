Received: from smtp.kernel.org (aws-us-west-2-korg-mail-alma10-1.taild15c8.ts.net [100.103.45.18])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id CDA753F6C2F;
	Wed, 17 Jun 2026 13:59:10 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=100.103.45.18
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1781704751; cv=none; b=mg93dz13CwVyfS3/PFSheYaY4ywA0L9hf0zlOQT1VA3WUW6B772l5ns2WmZkxdgRfNrjyfK0cKEqwrhoqUPiPKybVpTh5oJAane+8inzGqBcPNwtuIhZ+tmeJjqLuCATWk0JqqRt7SXb1igbRY1FQvqM3FqlXYIuB0naxQZ/TU8=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1781704751; c=relaxed/simple;
	bh=qmjXhExzMbCkpNuMGsDzJsr6r2rhXpxK9SxkO/cXaOU=;
	h=From:To:Cc:Subject:Date:Message-ID:In-Reply-To:References:
	 MIME-Version:Content-Type; b=p4d20boGrhOqbZ3LHtL1ttn0P0Vgy1vW6wlBO9tkXD1sVj7vg2fN1iYua6w5gfoOjmmE7BrbJkLUSm/ydoAdcYyw4VSj/xfV6QlkXL6T+5XKlWz16TZjD7d6pFYQlbExVbKKiubrz/H0XfeBbMKKttc5YuL5xXtH/8d3JnQV4oY=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=Cwp4SwHR; arc=none smtp.client-ip=100.103.45.18
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="Cwp4SwHR"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 55B9C1F000E9;
	Wed, 17 Jun 2026 13:59:09 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1781704750;
	bh=Nw1hFI6TGxp+LvW86By36bUZ2cPR1AXCKv5z9/ll768=;
	h=From:To:Cc:Subject:Date:In-Reply-To:References;
	b=Cwp4SwHRbXG4hfKFMLwOfN5aUSgofqCN3Eaf7BKn5yyTDSGzCnmSFStDO3UF/WGWo
	 4kYaRFSjvixMc5W84KfwpgRtx8D9d/UvzeKL0c9+AIgY/cV/hNRU5in8qwHaPPiLFj
	 25Tc1x2sFQSRR1rpdOS6m8VYFDqEqAUIrFH0/DWZ00XkehojlWU/SQBEugWYtxvFcm
	 PbZMXZDHhjw4Ks+jldUCGjMWwnM0quqn9jm5fF+wms8Hhg6tWzCJkv1UW1BhuTxwG0
	 Nncun/FZUHk7MGKoyaGktFjPCfu+tNfOlbudhzsmQZsT8110i5QgwiCZhXG1EDcVyg
	 WzhJQK2FZJ2Iw==
From: Chuck Lever <cel@kernel.org>
To: NeilBrown <neil@brown.name>,
	Olga Kornievskaia <okorniev@redhat.com>,
	Dai Ngo <Dai.Ngo@oracle.com>,
	Tom Talpey <tom@talpey.com>,
	Trond Myklebust <trondmy@kernel.org>,
	Anna Schumaker <anna@kernel.org>,
	Jonathan Corbet <corbet@lwn.net>,
	Shuah Khan <skhan@linuxfoundation.org>,
	Jeff Layton <jlayton@kernel.org>
Cc: Steven Rostedt <rostedt@goodmis.org>,
	Alexander Aring <alex.aring@gmail.com>,
	Amir Goldstein <amir73il@gmail.com>,
	Jan Kara <jack@suse.cz>,
	Alexander Viro <viro@zeniv.linux.org.uk>,
	Christian Brauner <brauner@kernel.org>,
	Calum Mackay <calum.mackay@oracle.com>,
	linux-kernel@vger.kernel.org,
	linux-doc@vger.kernel.org,
	linux-nfs@vger.kernel.org
Subject: Re: [PATCH v7 00/20] nfsd: add support for CB_NOTIFY callbacks in directory delegations
Date: Wed, 17 Jun 2026 09:59:06 -0400
Message-ID: <178170474157.1605926.7351578842122181978.b4-ty@b4>
X-Mailer: git-send-email 2.54.0
In-Reply-To: <20260616-dir-deleg-v7-0-6cbc7eac0ade@kernel.org>
References: <20260616-dir-deleg-v7-0-6cbc7eac0ade@kernel.org>
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 8bit

On Tue, 16 Jun 2026 07:58:43 -0400, Jeff Layton wrote:
> This patchset builds on the directory delegation work we did a few
> months ago to add support for CB_NOTIFY callbacks for some events. In
> particular, creates, unlinks and renames. The server also sends updated
> directory attributes in the notifications. With this support, the client
> can register interest in a directory and get notifications about changes
> within it without losing its lease.
> 
> [...]

Applied to nfsd-testing, thanks!

[01/20] nfsd: check fl_lmops in nfsd_breaker_owns_lease()
        commit: 5829ecd7e99a7ed8da577f30a3818e219e0f939a
[02/20] nfsd: add protocol support for CB_NOTIFY
        commit: 02a63ce55455420340d9d90721ba6f0914301399
[03/20] nfs_common: add new NOTIFY4_* flags proposed in RFC8881bis
        commit: b08cfbdd37224bd6963735da9532744d11d52020
[04/20] nfsd: allow nfsd to get a dir lease with an ignore mask
        commit: 124ee5f1be54c060e0a23a0ac62ecd3802094a59
[05/20] nfsd: update the fsnotify mark when setting or removing a dir delegation
        commit: 08c7feaff63d6a14ff0b868b44a5d03e2ced99e4
[06/20] nfsd: make nfsd4_callback_ops->prepare operation bool return
        commit: da30d09e299cd9a8e3928ab555eca7f4dc332f61
[07/20] nfsd: add callback encoding and decoding linkages for CB_NOTIFY
        commit: 046b4a0e1817482e2017db5262734ca35c691fce
[08/20] nfsd: use RCU to protect fi_deleg_file
        commit: 7d47d06e04e03d05be4ae7febdf81a7365054995
[09/20] nfsd: add data structures for handling CB_NOTIFY
        commit: 0db43bdffdc39bbc076c09630c87710f6c2ce3eb
[10/20] nfsd: add notification handlers for dir events
        commit: b557e3bcc740d87b1fb0b5d0fd9743ae2d9e6ece
[11/20] nfsd: apply the notify mask to the delegation when requested
        commit: 718bee77fdb46cb4074b113aa40a3c82e49bf13b
[12/20] nfsd: add helper to marshal a fattr4 from completed args
        commit: 2c495d8ec198888447018689ad33c2d52e52cb48
[13/20] nfsd: allow nfsd4_encode_fattr4_change() to work with no export
        commit: 498a0c7ad8710daaf9e92040b325055cebc31747
[14/20] nfsd: send basic file attributes in CB_NOTIFY
        commit: b78e9993ec52676ccebb161fd65996e18372f6c4
[15/20] nfsd: allow encoding a filehandle into fattr4 without a svc_fh
        commit: c2959ab33014d9aaefd2782f414cf0b78b991efa
[16/20] nfsd: add the filehandle to returned attributes in CB_NOTIFY
        commit: b4d7483c6e50fb9382f2f4977ed7eae86e4264b9
[17/20] nfsd: fix reply size estimate for GET_DIR_DELEGATION
        commit: 7c8674f3963bc3f4d2472c70884d350164fff25b
[18/20] nfsd: properly track requested child attributes
        commit: 744500529a2d378084909bfd277af18e62ce34ac
[19/20] nfsd: track requested dir attributes
        commit: df3ecee7ae57f6e1042556fa5f7b5dcae3b7b26d
[20/20] nfsd: add support to CB_NOTIFY for dir attribute changes
        commit: 0c072553ca525d62c7e8e63a6ecb7e88f84d07e0

--
Chuck Lever


Received: from smtp.kernel.org (aws-us-west-2-korg-mail-alma10-1.taild15c8.ts.net [100.103.45.18])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 4011549B21A;
	Fri,  4 Sep 2026 11:02:26 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=100.103.45.18
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1788519747; cv=none; b=Y9lmg1MwISqfURqZy1CWVVpWvFbKh7DqVnSq1O7B/xtcxIlxN/DLb73kuaErvTgltK9A/MCybSVo6Dk9pf/rTm3uSO9BeoMLPOyP3hZkegpz6YN+Uz3bl8TzB3pMl3aLUOsCY4co3x/3CPvo2rESpL4LOvk3ssBpEjIBg9XALvk=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1788519747; c=relaxed/simple;
	bh=RK6NO+ffgL5RZHOgzUImNyTEdl1/bkJVmSxpR+TcKR4=;
	h=From:To:Cc:In-Reply-To:References:Subject:Message-Id:Date:
	 MIME-Version:Content-Type; b=apIhRCeoMfQMgQ7FpmjYUslge87Tz43EjXJD7fS2q81TdN81pfBMVJub3bMkT87mcmA1OIiEvyQhr2uScqsgBSsC22W8opCA61ve8AyKyf9GwCAEwmfAb/pZQ74nv1DFMPDsgXQOyhFcIkXMu4/C+6WxUes26Umh2hT++9n4j3s=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=VaQntKqk; arc=none smtp.client-ip=100.103.45.18
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="VaQntKqk"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 859E31F00A3D;
	Fri,  4 Sep 2026 11:02:24 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1788519746;
	bh=bEy8h/nZgDMUnkc90lyT7Ywxlz3gFxZb72N4dGO+EQ8=;
	h=From:To:Cc:In-Reply-To:References:Subject:Date;
	b=VaQntKqkh4rt6SStOjRhuarV3J/lDVAWd3u+0RWIczXQYhW4hE18ud5e4rSQE3oj2
	 vZD29VEyw9pQlMYiPBP3zU2o0mZem8kjqrshxUkVUnaUqeWhXR2K2h1ZlRjtgVIp/U
	 kL4sX9WB6zaFuTyGeG+97+l1G/RJzbpy5yMav4p/H9K2Q4bJqrDYa5k16zA7JCHyHF
	 mI27stTwsnRkNu5O/WUC7bLCstgyJqqTYgefmSO8SkDBjvLcIbzHwDpDPmPO8Lz4lD
	 Oaea+eQ1chJ6KPYo4q8aZmvw0wr8o9aFHuWPgfsJfU2qsUs0RECFaodJf8r3NlZm3M
	 U2oWIsX6c+pDA==
From: Christian Brauner <brauner@kernel.org>
To: Al Viro <viro@zeniv.linux.org.uk>, Jan Kara <jack@suse.cz>, 
 Chuck Lever <cel@kernel.org>
Cc: linux-fsdevel@vger.kernel.org, linux-nfs@vger.kernel.org, 
 Ameer Hamza <ameer.hamza@truenas.com>, Amir Goldstein <amir73il@gmail.com>
In-Reply-To: <20260901135329.487666-1-cel@kernel.org>
References: <20260901135329.487666-1-cel@kernel.org>
Subject: Re: [PATCH v2] splice: emit a single fsnotify access event per
 NFSD READ
Message-Id: <20260904-strategisch-zuvor-ethisch-206357ecc5ee@brauner>
Date: Fri, 04 Sep 2026 13:02:16 +0200
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
X-Mailer: b4 0.17-dev-db0b7
X-Developer-Signature: v=1; a=openpgp-sha256; l=898; i=brauner@kernel.org;
 h=from:subject:message-id; bh=RK6NO+ffgL5RZHOgzUImNyTEdl1/bkJVmSxpR+TcKR4=;
 b=owGbwMvMwCU28Zj0gdSKO4sYT6slMWTNWmpnPqvmTN31cBYLazPepTyvL9+aL/D4z8sHa5UWW
 bidj1Lc2VHKwiDGxSArpsji0G4SLrecp2KzUaYGzBxWJpAhDFycAjARtfcM/0w+6CSbrJrKeNwt
 5LAdX1LEj9R7jR8LZBZmK8mZiU1d+pHhf8YGjpX9HAejW3gs/NvrKx6cOH9rE7toVHHijpkKCgd
 5eAE=
X-Developer-Key: i=brauner@kernel.org; a=openpgp;
 fpr=4880B8C9BD0E5106FC070F4F7B3C391EFEA93624

On Tue, 01 Sep 2026 09:53:29 -0400, Chuck Lever wrote:
> splice: emit a single fsnotify access event per NFSD READ

Applied to the vfs-7.4.misc branch of the vfs/vfs.git tree.
Patches in the vfs-7.4.misc branch should appear in linux-next soon.

Please report any outstanding bugs that were missed during review in a
new review to the original patch series allowing us to drop it.

It's encouraged to provide Acked-bys and Reviewed-bys even though the
patch has now been applied. If possible patch trailers will be updated.

Note that commit hashes shown below are subject to change due to rebase,
trailer updates or similar. If in doubt, please check the listed branch.

tree:   https://git.kernel.org/pub/scm/linux/kernel/git/vfs/vfs.git
branch: vfs-7.4.misc

[1/1] splice: emit a single fsnotify access event per NFSD READ
      https://git.kernel.org/vfs/vfs/c/24973c36a6ea


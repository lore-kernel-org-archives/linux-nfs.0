Received: from smtp.kernel.org (aws-us-west-2-korg-mail-alma10-1.taild15c8.ts.net [100.103.45.18])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 89B183749FA;
	Mon, 24 Aug 2026 17:49:25 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=100.103.45.18
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1787593766; cv=none; b=JW/+fJshRAxE3VrOG4qJmFw0uMStoiz5d3Rc78friyjeyxxJsXzEWXnHhRi+sK7u118kFtrE6kgBfJcoqHbFsmxvZwtjrhdP3dQklYNmYEM+pQKc2GsE9RhBq0b23W6K2yMesOOLk8BaTTeH7F7MIX8ykmLxmH7W4zU2XVWAcQQ=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1787593766; c=relaxed/simple;
	bh=90suKUiXI7PlSRgK1Ox8F7w+EyQdnbS1Le8ieXJSXio=;
	h=MIME-Version:Date:From:To:Cc:Message-Id:In-Reply-To:References:
	 Subject:Content-Type; b=hyMne8zjTd1JXuguZkHeeeXxLXZ1+VLZSFDlWYtRoAOJxetWoqBhdCA+Z4PjBprPBfwCvvY0IOPPJ5y/ZktxOy7EjQ7+liXf4Q3ZtIKTNd0lbD/u27UJa0RkNta0GPznT/s7bMywuooeMpc8PcvFFgByH62I8iat8yHkuW65/f4=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=U0v/SvDj; arc=none smtp.client-ip=100.103.45.18
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="U0v/SvDj"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id A74871F00A3D;
	Mon, 24 Aug 2026 17:49:24 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1787593765;
	bh=PXcM5X3uBKvKFdABV+dXq4fIKyqlgx4ANk3fPDAXJGY=;
	h=Date:From:To:Cc:In-Reply-To:References:Subject;
	b=U0v/SvDjWTxpVVRAXEaFwXgetWu8mbgLqIy9RlYwGxFSFBnMciUU3Pa3W9drfPF25
	 2P5Y+TNzAJrFk3Lcjj+1e+4+1C7V0su9p3ITVPi6VaoexaDJeFgFpb0hqgptJVx928
	 wyjUsLid2AhCmc0A5qZa9Oomn+CZjcIIJb4B+uFskJxtCJibzDaHTu/S7HU/8fzfaB
	 82uVG3XkMoWoKPQIzBBHyf7cQtjt1nU8Q56k/cwTXDmK1qxkuoODPUKbKFxsW0TyLv
	 bcFExql9IaoqLlH5bU9FlvivvQyWSx2WYvm0mXsVPA10FErjBWOt6DQTC4DnMLLx46
	 fHHPfXOl4niDg==
Received: from phl-compute-10.internal (phl-compute-10.internal [10.202.2.50])
	by mailfauth.phl.internal (Postfix) with ESMTP id 7B2DCF4006A;
	Mon, 24 Aug 2026 13:49:23 -0400 (EDT)
Received: from phl-imap-15 ([10.202.2.104])
  by phl-compute-10.internal (MEProxy); Mon, 24 Aug 2026 13:49:23 -0400
X-ME-Sender: <xms:I4SMaqOMmOG-UPHTwUCzOMoOwBKxCCj4rKSCCbowWTrCq6jOFXb4pw>
    <xme:I4SMajwnIfgYk_1eqDTR_Ennsikt3CIt3u6Z-VZ53Aia9mf6T6S_rYnegrgqeNcNB
    8XPSCerfNVF8zPR1soC-HHlONyPqPtHTyDQnl88KXqPPadx2pio2cwS>
X-ME-Proxy-Cause: dmFkZTEhxdDtUpllTHrqstN18oDAkCQb3QAt856ufTOaFLeUg8o+LMg/a4UZ3D4hP9DtZY
    F3Ryksg3VzUj9CzcUm3C9lk5xqxp3VHAxJbuzKYrfJEOXQF7166wHgRGQ1ssx7cte54Rum
    3GktrAmFv6hlvG0EXZITf7bjBrr4JSjILoDLyWjxoscMWd3UzlJ3qmofuiQtCYrbtqNw3T
    a1vuRV5j2VaIj70DuMAK/H8m715VK8tEx1GB6+yQuWqz0BuXCLTmQYehSiDUmYJ0xeqiUz
    9W3CmMCNA1G+smMDtcw3ONbTEkeE5j6MY8pylI82lOUvM1b+9W+MtHfzk/ApujlQeFzZm8
    zn7eWrmzTmHm+r5U9JxBxUTFQQXuR7mtMTZCjQ88R648L1fL5K2uRVRWX2D2DrDYhH/6KM
    2YR+TFvy0iYYhD4MxdIZytboaGV4+1JRaYOfeNdVR9wJVUItZZviUlme9jeCIdd8dO9fXR
    Q9cn/p0oEgcnU5fAED7LmcS3QUPGoRQWYmV0fQq0ndWlsd2L6yqMa7kuyA2ayNMNUyDzLK
    3xS3VpjeHubqFxEmJDQiItVsEsWrPr1zJ8tgHWWUnN/4RE81JpOMGeJRWKLfR3pxJWB1mm
    fnSuyX38J6J8NdyUYbaX3tA6HdioZmYAQQcs6YlCA5gy1Ep3Dkdy2zi8t7Vg
X-ME-Proxy: <xmx:I4SMakUwlrPuNVe1NFA6MCqWtQYUbFTTqtaRsjMDmbJc7Wu7EIXZ8g>
    <xmx:I4SMakCdNbugk5JqJrrWKZKRM62FDGVRxZjbP_YkJUrb_e-q7450FQ>
    <xmx:I4SManGaDKgvXRDRsf7EVJVHND1c4yumwZ8_bt6wjkpfyS5II7jevQ>
    <xmx:I4SMagd37ZaRg4ExO--M1E7TCXJOJnBr3laUrSY3w35T-0g6ReXubw>
    <xmx:I4SMak9EypA4RZJSgzAPfSfkOCjT_5JJDVqQcL0rwqUfgsoSpscQYFNn>
Feedback-ID: ifa6e4810:Fastmail
Received: by mailuser.phl.internal (Postfix, from userid 501)
	id 54BA57811F0; Mon, 24 Aug 2026 13:49:23 -0400 (EDT)
X-Mailer: MessagingEngine.com Webmail Interface
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
X-ThreadId: A-zzBGauvJA-
Date: Mon, 24 Aug 2026 13:49:05 -0400
From: "Chuck Lever" <cel@kernel.org>
To: NeilBrown <neil@brown.name>, "Ian Kent" <raven@themaw.net>,
 "Jake Edge" <jake@lwn.net>, "Ilya Dryomov" <idryomov@gmail.com>,
 "Alex Markuze" <amarkuze@redhat.com>,
 "Viacheslav Dubeyko" <slava@dubeyko.com>, "Jan Harkes" <jaharkes@cs.cmu.edu>,
 coda@cs.cmu.edu, "Alexander Viro" <viro@zeniv.linux.org.uk>,
 "Christian Brauner" <brauner@kernel.org>, "Jan Kara" <jack@suse.cz>,
 "Trond Myklebust" <trondmy@kernel.org>, "Anna Schumaker" <anna@kernel.org>,
 "Amir Goldstein" <amir73il@gmail.com>,
 "Andrew Morton" <akpm@linux-foundation.org>,
 "Miklos Szeredi" <mszeredi@redhat.com>
Cc: autofs@vger.kernel.org, linux-kernel@vger.kernel.org,
 ceph-devel@vger.kernel.org, codalist@coda.cs.cmu.edu,
 linux-fsdevel@vger.kernel.org, linux-nfs@vger.kernel.org
Message-Id: <f9d16f36-10e6-4bec-aa8e-b9b3cb3ad872@app.fastmail.com>
In-Reply-To: <20260815042707.2535717-5-neilb@ownmail.net>
References: <20260815042707.2535717-1-neilb@ownmail.net>
 <20260815042707.2535717-5-neilb@ownmail.net>
Subject: Re: [PATCH v2 04/18] nfs: separate locked regions in
 nfs_clear_verifier_directory()
Content-Type: text/plain
Content-Transfer-Encoding: 7bit


On Sat, Aug 15, 2026, at 2:21 PM, NeilBrown wrote:
> nfs_clear_verifier_directory() locks the dir to call
>   nfs_unset_verifier_delegated()
> and also to walk the d_children list.
> These are two separate needs and they don't need to both
> be in the same locked region.
>
> Subsequent patches will use a helper for walking the d_children list and
> that helper may drop the lock temporarily.  To simplify this transition,
> split the locked range by dropping and retaking the lock between to make
> two separate locked regions.

I hit this running xfstests against tmpfs with the series applied.  The
trigger was incidental (an unrelated process chmod'ed a file on an
NFSv4 mount while xfstests was running) so it is not deterministic, but
the path looks reachable by any SETATTR that returns a delegation on a
directory:

  BUG: sleeping function called from invalid context at fs/nfs/dir.c:1497
  in_atomic(): 1, irqs_disabled(): 0, non_block: 0, pid: 2385380
  preempt_count: 1, expected: 0
  Call Trace:
   __might_resched+0x165/0x180
   nfs_clear_verifier_delegated+0x112/0x250 [nfs]
   nfs_start_delegation_return+0xa1/0x130 [nfsv4]
   nfs4_inode_return_delegation+0x1b/0xf0 [nfsv4]
   nfs4_inode_make_writeable+0xa9/0x130 [nfsv4]
   nfs4_proc_setattr+0xa2/0xf0 [nfsv4]
   nfs_setattr+0x1f2/0x480 [nfs]
   notify_change+0x321/0x380
   chmod_common+0x10d/0x1c0
   do_fchmodat+0x8a/0x110
   __x64_sys_chmod+0x1d/0x30

Line 1497 is the d_for_each_positive_child() call.


-- 
Chuck Lever

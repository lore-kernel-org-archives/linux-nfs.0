Received: from flow-a7-smtp.messagingengine.com (flow-a7-smtp.messagingengine.com [103.168.172.142])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id CE50E2D9792;
	Tue, 25 Aug 2026 04:09:59 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=103.168.172.142
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1787631002; cv=none; b=luAgRr60uFsylVAHUbdQVNr+IemAa20Fn70ioSbFSwryI7uirD8bj621KJt8h9+iUpPqCUDhFV5ggJ1uVFrqudBTxpNjaG4LTn+bECAlvTG3O6FH7xaUFdtb3nicC6YDUY3VdvJIvxgYtHDtv/mVAMozSK1eh+LyjDUs7SOrPz8=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1787631002; c=relaxed/simple;
	bh=GCKOeqvQQ4h3sLsNo4562hEc6cyczIzgczQh3GCPpv8=;
	h=Content-Type:MIME-Version:From:To:Cc:Subject:In-reply-to:
	 References:Date:Message-id; b=fhix13fpzYgnPmYKeAxe0DvC+JRVZPgu05v2VSniVMKdQCLbWd0sla8JNCT5wc+yCfviO7r0srkrBillDOzu7vnEUTj0Npg+nk4UYP5ILA0cVxjvbouyHKKdZrvml//kUgtzYNp4rTxpjOR7AXbH6jyOnF+DF6ib2xzUlo2oRuo=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=ownmail.net; spf=pass smtp.mailfrom=ownmail.net; dkim=pass (2048-bit key) header.d=ownmail.net header.i=@ownmail.net header.b=VmOJZsvu; dkim=pass (2048-bit key) header.d=messagingengine.com header.i=@messagingengine.com header.b=EEYEIXQU; arc=none smtp.client-ip=103.168.172.142
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=ownmail.net
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=ownmail.net
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=ownmail.net header.i=@ownmail.net header.b="VmOJZsvu";
	dkim=pass (2048-bit key) header.d=messagingengine.com header.i=@messagingengine.com header.b="EEYEIXQU"
Received: from phl-compute-02.internal (phl-compute-02.internal [10.202.2.42])
	by mailflow.phl.internal (Postfix) with ESMTP id CB70A1380104;
	Tue, 25 Aug 2026 00:09:58 -0400 (EDT)
Received: from phl-frontend-04 ([10.202.2.163])
  by phl-compute-02.internal (MEProxy); Tue, 25 Aug 2026 00:09:58 -0400
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=ownmail.net; h=
	cc:cc:content-transfer-encoding:content-type:content-type:date
	:date:from:from:in-reply-to:in-reply-to:message-id:mime-version
	:references:reply-to:reply-to:subject:subject:to:to; s=fm3; t=
	1787630998; x=1787638198; bh=gfzmhiIcB0bekT0CYQojOTQWt5VjQ1DlVCR
	0Y2kGVR8=; b=VmOJZsvuLMPuT4/XbFzo+7qH8JmIsulFBHvMYvEEAdqZamZAJe0
	pkSs2rOgyyZsJx/ggcxsQ+m+M8aZ1sloSs8QoLmn1UFg786DgXbv13TpqamsBkDo
	B29/XjMlqPloGpnIW31haAbfzfcl1/IpAH+joT0c/votgdQPMEfyl0bTOnD1rOLB
	slUvWgjpCcOQ1dqVlO0cbpoZ2cN8UUfR9iMKNY1M/RU0OkjpAa9fdieoJpBWsugJ
	cDbs1HJaX6P9PbxL+XG0P6mQ9cqpYC+m9MhkELIl86/9KnkbH2y/JXxKJygmrYs8
	GSIdVhjxGdiUMnZSZqYiPg2htZAkN2OKMvQ==
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=
	messagingengine.com; h=cc:cc:content-transfer-encoding
	:content-type:content-type:date:date:feedback-id:feedback-id
	:from:from:in-reply-to:in-reply-to:message-id:mime-version
	:references:reply-to:reply-to:subject:subject:to:to:x-me-proxy
	:x-me-sender:x-me-sender:x-sasl-enc; s=fm3; t=1787630998; x=
	1787638198; bh=gfzmhiIcB0bekT0CYQojOTQWt5VjQ1DlVCR0Y2kGVR8=; b=E
	EYEIXQUW2w+IvyjYge8X3DaNB6r0vHv607haJuOez0M4icKrjYT/amTGoqj99PtF
	n+uK0UCXU50HbHy5oHtqzlJ3TEZCheLxT/aeeVpMW3roYIEku7K6Kznd0vamrz1a
	ctfjWJC9446Wste/Drgr47i289kvHEMiVa/sFUT9F3MeZwBpXiH0Iq7qIptmbKOa
	UhVWEV5PLJSbSrpaMUPcZe1/j3+RcsWBKaXlkRnpBtyFQjiRSvtHAqHd9fLTUGxB
	yxqc8miu+dSasSTCjiqyQ1DT4cgJcs4c0VFeyY8F9b7oyFqRWBIkM4dWl8ZhgnfN
	gcfoeQUrIQ8bfVrK0VlpQ==
X-ME-Sender: <xms:lhWNamVF71uR9GJ31G4ZO444p7EgsO1dj34ek-tF-WJF6J79P7kHSw>
    <xme:lhWNaqycHXt0IAot3O1HBfnlTNd1khShIudtVSEU_c0DeUnS19_VWd6HVRJaGjvo-
    A2YjabCXuE0B6uFeWi7EFfxP70fG_zSrE2cmydkHtPzl-HyjA>
X-ME-Received: <xmr:lhWNahtPN5xHk7o7l7R9sLNp-myD4YRQdS_zVXIe4AiabzHsxUVaYVa86HXnfzmiDrBvQvwQVIoKSUBReCAhwgc4Mjm9Ix4>
X-ME-Proxy-Cause: dmFkZTFb1V9n/Rau2wZjVEeTtHtAjpRLi3Fx7aQyWsyGbHDDpCn5SpctxOLQF1z4Pp6DFa
    9u5RfEtGY5ExorOrZ2p6AhLPnE7vhM6Wukm+9E/99g9uWhllVzhra78LAV00rcmHXm9CtX
    sxRThI/CZ7x+k68gPOCgj85/kxGrOXdHKYxGvExhQ+HqpYpim4/DKKQ1VSLuVUGjv+gfFo
    rcS5ckepksDSIEfOeE2ooDJs4ZksKbVdt0C1d+A5VNZ9Sf0Y9+lAjSsMgyvT1Zhn8vfSTG
    CrJ7vggwcZjX/4RRVpVYry9/jh3xS9sWT4haWu3+KA2caFajuAOdVITGx0rQWEGbJyIvt6
    lUmpuZ7Mjjacvy/4gBvxOgsGlI/U5TA778viJUJljUFLcsPJbkTyaBN306CJ1Nut17fdek
    yoJuvCcWls1Cq9rHbCBQwXKDMxX2R9fUM1jFqWhMjSnTDtTFp6aeqY+lPdLddoh/g5VlpO
    Tdi72QDIJXlHlpMnc4gzw/MyvbSCFfiC06wLu/qOl8VVA63AGetsUjfPIJRXR5xkwCXaB5
    8P9ZKEe9ZC5jOcTrlBa4UIXfzS6Dm/W7EGh/UglMBU/3B/KbcHgwl7DILluhJYmiXxXvUW
    UQ41DKOiUMmF10GuO5ZVQNFgjbHlxjVdIctb3PJx4+ukParWxM+J+OOBLDTg
X-ME-Proxy: <xmx:lhWNarAWdNtupeRSPBtBuRi1dyk1lF-oTizL-iOjgaQJFtQOnJvT5g>
    <xmx:lhWNatr3sZ9SNydp2YV53_-YiA3GsLC8mS62XQgHT1Poyaxzz_cNzA>
    <xmx:lhWNaiawtpRyFqo2DkEmYFoc0IO2MuEFMrV0gJEjTxqbjPhGqL6lVw>
    <xmx:lhWNanG_b16RRRA4l-9dbuhINdCwX8ze2MCPJ_0ayf1X6Kku5bX0gA>
    <xmx:lhWNasNK21d0YsdN7RsTP5tPEqFHidkbfkKWJ9DUzicAw2-Cy_4CAMcx>
Feedback-ID: i9d664b8f:Fastmail
Received: by mail.messagingengine.com (Postfix) with ESMTPA; Tue,
 25 Aug 2026 00:09:52 -0400 (EDT)
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
From: NeilBrown <neilb@ownmail.net>
To: "Chuck Lever" <cel@kernel.org>
Cc: "Ian Kent" <raven@themaw.net>, "Jake Edge" <jake@lwn.net>,
 "Ilya Dryomov" <idryomov@gmail.com>, "Alex Markuze" <amarkuze@redhat.com>,
 "Viacheslav Dubeyko" <slava@dubeyko.com>, "Jan Harkes" <jaharkes@cs.cmu.edu>,
 coda@cs.cmu.edu, "Alexander Viro" <viro@zeniv.linux.org.uk>,
 "Christian Brauner" <brauner@kernel.org>, "Jan Kara" <jack@suse.cz>,
 "Trond Myklebust" <trondmy@kernel.org>, "Anna Schumaker" <anna@kernel.org>,
 "Amir Goldstein" <amir73il@gmail.com>,
 "Andrew Morton" <akpm@linux-foundation.org>,
 "Miklos Szeredi" <mszeredi@redhat.com>, autofs@vger.kernel.org,
 linux-kernel@vger.kernel.org, ceph-devel@vger.kernel.org,
 codalist@coda.cs.cmu.edu, linux-fsdevel@vger.kernel.org,
 linux-nfs@vger.kernel.org
Subject: Re: [PATCH v2 04/18] nfs: separate locked regions in
 nfs_clear_verifier_directory()
In-reply-to: <f9d16f36-10e6-4bec-aa8e-b9b3cb3ad872@app.fastmail.com>
References: <20260815042707.2535717-1-neilb@ownmail.net>
  <20260815042707.2535717-5-neilb@ownmail.net>
  <f9d16f36-10e6-4bec-aa8e-b9b3cb3ad872@app.fastmail.com>
Date: Tue, 25 Aug 2026 14:09:48 +1000
Message-id: <178763098869.3510150.7453977572617670907@noble.neil.brown.name>
Reply-To: NeilBrown <neil@brown.name>

On Tue, 25 Aug 2026, Chuck Lever wrote:
> On Sat, Aug 15, 2026, at 2:21 PM, NeilBrown wrote:
> > nfs_clear_verifier_directory() locks the dir to call
> >   nfs_unset_verifier_delegated()
> > and also to walk the d_children list.
> > These are two separate needs and they don't need to both
> > be in the same locked region.
> >
> > Subsequent patches will use a helper for walking the d_children list and
> > that helper may drop the lock temporarily.  To simplify this transition,
> > split the locked range by dropping and retaking the lock between to make
> > two separate locked regions.
> 
> I hit this running xfstests against tmpfs with the series applied.  The
> trigger was incidental (an unrelated process chmod'ed a file on an
> NFSv4 mount while xfstests was running) so it is not deterministic, but
> the path looks reachable by any SETATTR that returns a delegation on a
> directory:
> 
>   BUG: sleeping function called from invalid context at fs/nfs/dir.c:1497
>   in_atomic(): 1, irqs_disabled(): 0, non_block: 0, pid: 2385380
>   preempt_count: 1, expected: 0
>   Call Trace:
>    __might_resched+0x165/0x180
>    nfs_clear_verifier_delegated+0x112/0x250 [nfs]
>    nfs_start_delegation_return+0xa1/0x130 [nfsv4]
>    nfs4_inode_return_delegation+0x1b/0xf0 [nfsv4]
>    nfs4_inode_make_writeable+0xa9/0x130 [nfsv4]
>    nfs4_proc_setattr+0xa2/0xf0 [nfsv4]
>    nfs_setattr+0x1f2/0x480 [nfs]
>    notify_change+0x321/0x380
>    chmod_common+0x10d/0x1c0
>    do_fchmodat+0x8a/0x110
>    __x64_sys_chmod+0x1d/0x30
> 
> Line 1497 is the d_for_each_positive_child() call.

Thanks for testing!

nfs_clear_verifier_deleted() holds the inode i_lock across
nfs_clear_verifier_directory() which walks the the d_children list.
I'll need to use d_find_alias() to get the dentry like I did in the
notify code.
Hopefully I'll send another RFC tomorrow.

Thanks,
NeilBrown

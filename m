Received: from smtp.kernel.org (aws-us-west-2-korg-mail-alma10-1.taild15c8.ts.net [100.103.45.18])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 11CF746E00C
	for <linux-nfs@vger.kernel.org>; Fri,  2 Oct 2026 17:24:14 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=100.103.45.18
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1790961861; cv=none; b=uDlu9h6cg1R5uPWXVry+ZAnbxvE3eqnfw+N5DFjYh/NOZ6icBZCi0rP7vUAl3BOVt1reYjBzcG7u9kP+p2DY1ju3OotDoE4uyW5G80CPTBTlPLhePlEifGQshWLqKlXHvFc0EcOsW2Gw1d0a408Bz7udqaTdfyPe/QnOxPXoUwM=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1790961861; c=relaxed/simple;
	bh=EVXGrwDHpoljTj/p1PUZZL1/ggE1sWSuZYgK+9zUrrE=;
	h=MIME-Version:Date:From:To:Cc:Message-Id:In-Reply-To:References:
	 Subject:Content-Type; b=LJtByYMkaK0mfdhUAVrEZFW9agRFlBkki5ZQPgUc0BFEka8u78YNwu7QtWG3zHSPT+/7mhf3UKaTO3WY+SYCPe/B/HXY8UQF5w1r0q4vIAJJUS1zkaU10eebF33jtQurpCViHP45ZEjnOy+CUfhtmmf3RXYC12SbsHu7I+UCKZU=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=IlYKHebZ; arc=none smtp.client-ip=100.103.45.18
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="IlYKHebZ"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id BAC381F00893;
	Fri,  2 Oct 2026 17:24:11 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1790961852;
	bh=foLqwN3KSzDF8hfyBK54+nX2CHEJI8PtQ7/b/K+FHXI=;
	h=Date:From:To:Cc:In-Reply-To:References:Subject;
	b=IlYKHebZfkojxKa5x9Bv3QrsK4NrKFuwLyP7dw/pfXdIdSqSOBXwrrqraxi/fFzY8
	 HibS01ImeWwRlqrdwdi+lJ+zpflcQUc/aK/q5q/OeJNuehYTY1qM/MzNGWTfEzP0Hj
	 DfQQYTbBK6UA8qmIFjTYTmNhR1OQ6zTxZBCig8BWI0fShnGWgEqhi1rsyi0hxk+gw8
	 8JwQZS/Fh111ALd66fd+UZut3Va41i5Mt48iKNwvslLe5Zgi/MdaAhDCb/wvBXIXx8
	 pu4LCPiMl9mjueNiVKTJyCDexfcK5ifvDSO1Vc0z9Qla1CCuES1UJhonp+5ipvDjw9
	 YILunIf0qzgtg==
Received: from phl-compute-10.internal (phl-compute-10.internal [10.202.2.50])
	by mailfauth.phl.internal (Postfix) with ESMTP id D6E83F40066;
	Fri,  2 Oct 2026 13:24:10 -0400 (EDT)
Received: from phl-imap-15 ([10.202.2.104])
  by phl-compute-10.internal (MEProxy); Fri, 02 Oct 2026 13:24:10 -0400
X-ME-Sender: <xms:uui_ahWvQHb8d0UaMNs8zaD8ZjLZFDbi-NoecmFMyQsrQSo8ClCCiA>
    <xme:uui_asY9wu-19J2x7Ye5umeMrvecpYn2L8t1XkdJb02hQzQPrqo67m1JTTF_v3wUF
    lQj59yZMamwFXB3MCjx2nJuZwAv5FCNwvtDvxdHvS6nIPiWWNWHYGaq>
X-ME-Proxy-Cause: dmFkZTEYCemXcGg6IXHFzz9t5SUR+dCIh1/GnuXbP57Cduk6JveKAxSdweHJflB8pYnNJ6
    4Pb4seaICcm6yfilOz9nty58ioaf8+sWK93MSluY9I5IICftWNl4mLOO9QP9KTc9FVmUb3
    s6a6GEAGRPxpRooJxfqQ7BccA1MUsHnCc9KIvBbNjC34iAkh8QcQ0itjUAaM3XZCRDIyLT
    Y4IXZMFnErSyT3L5sbj0FPuyOmaYJegKqm0VWkrMNbhjkARHo6/fcklJuKkzr7bHEvz2+t
    N3GOTqFSZhYC813YH/28wzJR/ECCPI2XeYW1OGTu/delTIIeiB9BC9QBUthTF1doLtBPmL
    gEdca9C7qG1zlcUCqOl2UG3DclV/pyW2KT29B8SxKnSF9UwTx3Llrh29aMfCEJIYviEHEg
    Phm6rNyXSM0oJ7q6phrkOtjF/BEGLQ7rRWSO+bKV3ESN+OHC0LAQj6RyxpL3MwgY8oVe+l
    Xons7ojqMLOO82DVI8tM7t0rxlTaOq7xY91yy7K5BY4/JXC7gNUvdUlCs5aZgjY2nalTrb
    6m+G7mrKIVmz0OL+mOH3nCkm5vY476sOIoGAMuNQLe2NffzjcN+LwmIRzin0ek3v9Q+9Zn
    DAVdi4cFxnShtVlqiYT/cIlMgGQTsmKEuImL6HmPPpKMoTtbFWfWYpVMRDMQ
X-ME-Proxy: <xmx:uui_avC_1jgWbpUcfXujCrRY86QwfEJGNzCQx00mXJR13i4Kj7D71w>
    <xmx:uui_au3IDhlVkzLOZifWk5pNsZMForj6L1f6TTP4LQPwxbdHc7GwkQ>
    <xmx:uui_ah1KwhqLDhaB5WFBU4MQzgZ5YCKzB2gdecWmWVQDme1Al-Lb9g>
    <xmx:uui_ajC7O_sHcBYU-SC_AwAtkH29W-hc_eeow1MxaY8ihhqY-m0Ugg>
    <xmx:uui_ag5K5OD7Yu5khePvMGWUOUqZbjw0gKGJzlfIlIhaP_NmOJFsANuE>
Feedback-ID: ifa6e4810:Fastmail
Received: by mailuser.phl.internal (Postfix, from userid 501)
	id B77BD780070; Fri,  2 Oct 2026 13:24:10 -0400 (EDT)
X-Mailer: MessagingEngine.com Webmail Interface
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
X-ThreadId: ArA5_ikg4jso
Date: Fri, 02 Oct 2026 10:23:50 -0700
From: "Chuck Lever" <cel@kernel.org>
To: "Benjamin Coddington" <ben.coddington@hammerspace.com>,
 "Trond Myklebust" <trondmy@kernel.org>, "Anna Schumaker" <anna@kernel.org>,
 "Jeff Layton" <jlayton@kernel.org>, NeilBrown <neil@brown.name>
Cc: linux-nfs@vger.kernel.org
Message-Id: <509cfcc3-c413-403e-a4b4-59ad8ddbd774@app.fastmail.com>
In-Reply-To: 
 <6469ea852a2ad9d650a0bcdc8e2609bbaaec9f98.1790948497.git.bcodding@hammerspace.com>
References: 
 <6469ea852a2ad9d650a0bcdc8e2609bbaaec9f98.1790948497.git.bcodding@hammerspace.com>
Subject: Re: [PATCH] lockd: make the nlm_file reference count atomic
Content-Type: text/plain
Content-Transfer-Encoding: 7bit



On Fri, Oct 2, 2026, at 7:16 AM, Benjamin Coddington wrote:
> nlmsvc_create_block() takes its reference on the nlm_file with
> file->f_count++ while holding only that file's f_mutex.  Every other
> update of f_count is made under nlm_file_mutex, and can come from
> another task: nlm_traverse_files() pins each file it visits and runs
> from lockd_down() in any network namespace and from nfsd's unlock_ip and
> unlock_filesystem, and nlm_release_file() runs from the release of a
> GRANTED callback.  An update can be lost, and the count then reaches
> zero while a reference is still held:
>
>   BUG: KASAN: slab-use-after-free in nlm_release_file+0x504/0x7e8 [lockd]
>   Read of size 4 at addr ffff0000a738f6c4 by task lockd/11494
>
>   Call trace:
>    nlm_release_file+0x504/0x7e8 [lockd]
>    nlm4svc_do_lock+0x2bc/0x468 [lockd]
>    nlm4svc_proc_lock+0x1c/0x30 [lockd]
>    nlmsvc_dispatch+0xa8/0x200 [lockd]
>    svc_process_common+0xb08/0x1b80 [sunrpc]
>    svc_process+0x424/0xb70 [sunrpc]
>    svc_recv+0x1680/0x2408 [sunrpc]
>    lockd+0x148/0x288 [lockd]
>
>   Allocated by task 10651:
>    nlm_lookup_file+0x2a4/0x5c0 [lockd]
>    nlm4svc_lookup_file.constprop.0+0x4dc/0x848 [lockd]
>    nlm4svc_do_lock+0x284/0x468 [lockd]
>    nlm4svc_proc_lock+0x1c/0x30 [lockd]
>
>   Freed by task 11494:
>    nlm_release_file+0x46c/0x7e8 [lockd]
>    nlmsvc_free_block+0x1a4/0x298 [lockd]
>    nlmsvc_lock+0x2cc/0x1a80 [lockd]
>    nlm4svc_do_lock+0x324/0x468 [lockd]
>    nlm4svc_proc_lock+0x1c/0x30 [lockd]
>
> That is v7.2 with commit 526c49cff3f7 ("lockd: pin next file across
> nlm_inspect_file lock-drop") applied, with NLM lock and unlock traffic
> in one network namespace while a second namespace mounts and unmounts
> NFSv3, which shuts lockd down in that namespace each time.
>
> Make f_count an atomic_t.  Files are still only freed under
> nlm_file_mutex, and nlmsvc_create_block() increments a count that its
> caller already holds.  It is an atomic_t rather than a refcount_t
> because the count rests at zero while only locks hold the file in the
> table.
>
> Fixes: d9f6eb75d490 ("lockd: blocks should hold a reference to the 
> nlm_file")
> Cc: <stable@vger.kernel.org> # 526c49cff3f7: lockd: pin next file across nlm_inspect_file lock-drop
> Signed-off-by: Benjamin Coddington <bcodding@hammerspace.com>

checkpatch reports:

WARNING: From:/Signed-off-by: email address mismatch: 'From: Benjamin Coddington <ben.coddington@hammerspace.com>' != 'Signed-off-by: Benjamin Coddington <bcodding@hammerspace.com>'


-- 
Chuck Lever (Come to NFS bake-a-thon! https://nfsv4bat.org)

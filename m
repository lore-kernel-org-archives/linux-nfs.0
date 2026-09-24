Received: from smtp.kernel.org (aws-us-west-2-korg-mail-alma10-1.taild15c8.ts.net [100.103.45.18])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id BE6B74CE680
	for <linux-nfs@vger.kernel.org>; Thu, 24 Sep 2026 21:31:23 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=100.103.45.18
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1790285486; cv=none; b=G5PnjkUN+8+2syps+QMfgseioRPXdZ8jQ5vPgJvU5zqDyecmiA8t+Km19I+XtgCx5IFSvhS7QM8vOYikKjleDsFp0CIC+9152lZ1Mtnf1xshbGByl+PoA/uq8wRvk+rUlZOQmpTTLfiNGSCvTUWusjj4faxw3iyasDkeZ24ssQ0=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1790285486; c=relaxed/simple;
	bh=/JFxaCUheibH2RUIKcV0YOdb6NsjcyP4SL1uIr4aoW4=;
	h=MIME-Version:Date:From:To:Cc:Message-Id:In-Reply-To:References:
	 Subject:Content-Type; b=miB19j61zcOl3iIL/jo4gZ+Nzf09S0EjWnx78oR/TghHEk20f8IoEZfYBSdl/hlwpfFgUNFS1MLEFSTuRUsq3ibU8Ah4ni41yuvmTHeBttxteJS3tHIRvsR9Uf75AjW8mv5Z2MXd/FmGq7VzG8IdF29fz5limkds7ZkdZkPj3zY=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=P0Wu8G+7; arc=none smtp.client-ip=100.103.45.18
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="P0Wu8G+7"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 4951B1F00899;
	Thu, 24 Sep 2026 21:31:21 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1790285481;
	bh=d28M2eqxQ4aEVog2f39dyY5RPfWjRG55uoMWp40vBrk=;
	h=Date:From:To:Cc:In-Reply-To:References:Subject;
	b=P0Wu8G+7sSU5tOmfAMHGa15sKKnPKSWurYInyKILHCm/J8MYfyDoyyHDO8LKM6iMM
	 hUXxBA7+wVgDdMPxVpCPqcLUv43EXQUrZBaFOu14sua/CuGWqLG0RKJqsXTTn19cKb
	 UBGRnenmON0uJo+GiG6hOE6cQyjyBQfS1RBNqx78RX784rIxh+PODneeEoh8fLFQrn
	 5XZYGjRjEhzmyFptubwh80q0U2H2hSqsSuObyukvoDFC8BMeJW0vxyThK5dFCLh+k8
	 ZT4i0P9d8Gg0eDGz0rNoW3ePn9EMTd0jTWlFn5Rp0xIyAgGHpGsJz25vtm+T5jbJ26
	 8EUXVQ5v5myzQ==
Received: from phl-compute-10.internal (phl-compute-10.internal [10.202.2.50])
	by mailfauth.phl.internal (Postfix) with ESMTP id 69902F40066;
	Thu, 24 Sep 2026 17:31:20 -0400 (EDT)
Received: from phl-imap-15 ([10.202.2.104])
  by phl-compute-10.internal (MEProxy); Thu, 24 Sep 2026 17:31:20 -0400
X-ME-Sender: <xms:qJa1ar1QL7M7Uu879YEIGj1w3d9kOP-Hmcr-m4m8YBUZdArHGpj8Eg>
    <xme:qJa1ak4Cev2cr89GsZdb36DMKWvuiD940TEtEQ3dHggEqYDiPOUc7uqd8DzufdT8X
    j58BNVsVwO4LdoKgxYIBxHkbyo-iBj5Rxxr4HzcbFAjsObLUoy5Zz7X>
X-ME-Proxy-Cause: dmFkZTECmX3JND/oDKJBmwzIUpuWZyKLuDw+EogiMNSrY/1hIq3yEutNLIsjCy/IgQZSmt
    JvX312lctYId6m0nlnG4tBDU5mWA8B1SvA0nqdyIl51npLEtPXLrWREwzE21s3jqK5COQy
    cCOap4BdqzG/2MaM6rII98UquJWtRXRIe6iIKGs7C9/q0k2x5BJNfCvdR3/jr6D+sJxgzG
    t3RdyXTTU0KZMY2uNZVGJS2wUzBFeaVCuT5ObJgJkJmNJPupzsIKsdcJFawBZxELNvAAV4
    9onGThx6mSW1r5U20BwMDjvcjjbY82ZrOslsSFPaSarER5OsYdjA1PXF/Tu5KnGDldwrPV
    VCDgpwkfYQo4+idTBJnDYK4oIoxSUfsXBNmKaj09a4ZwumgRmJOwW+QItP5Ugz8I7WAOTn
    tXsmtTSwVVijHOrAiyANAnch0hJ2hGwqFnQtcdP8U0WT2PrI7L6wGY20Ox0ZiU0depL0YN
    Y6xYWvQDNU8WPiWJNk30Xg01+ohktW/NKBcFHenK1JjvJZU4tKk0z56Fn9+XvdVuvOJgET
    2iNtTlQ0C0mK7IMzZTK/KzML4OxompCnl0cXY4m10nyiFt5xyDlIIUHVV3BvMhZddyN0bz
    kBL0R6BRc6z8WC4Mzqrdcz7B3HVpwqMRhcpjDDfPGPtULDZyqxPsaHRHohaQ
X-ME-Proxy: <xmx:qJa1agELJ3aLWABhi7q8UBY50pXcqgIbwBO3gGVP_aOYSyFUg0oMAQ>
    <xmx:qJa1apxLEHeSzSIGXty4QyyCTs5uDVYpeurY3oLz9qh5L5iFq9bCdw>
    <xmx:qJa1aq1VtRrCvuKZqektYjAaKq0GGUeLq2PyD_APRN3gR_Y3OOUwZg>
    <xmx:qJa1aprPdsN5DEbzyCAyYqkHAC9q3QS6EA07Gv7YHcx3BqyDBogcbg>
    <xmx:qJa1anX5uFnhnIMZJqZTLwl89vxq4rqm-aNebWSaG15UDVBGJ3SdQIJX>
Feedback-ID: ifa6e4810:Fastmail
Received: by mailuser.phl.internal (Postfix, from userid 501)
	id 49919780070; Thu, 24 Sep 2026 17:31:20 -0400 (EDT)
X-Mailer: MessagingEngine.com Webmail Interface
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
X-ThreadId: ASoP3UDnCVzw
Date: Thu, 24 Sep 2026 17:31:00 -0400
From: "Chuck Lever" <cel@kernel.org>
To: "Tim Menninger" <tmenninger@everpuredata.com>,
 "Trond Myklebust" <trondmy@kernel.org>, "Anna Schumaker" <anna@kernel.org>,
 "Jeff Layton" <jlayton@kernel.org>
Cc: linux-nfs@vger.kernel.org, "Eric Badger" <ebadger@everpuredata.com>,
 "Jon Curley" <jcurley@everpuredata.com>,
 "Shiva Lingappa" <slingappa@everpuredata.com>, stable@vger.kernel.org
Message-Id: <a4080918-9200-4ab6-accb-ed748af07ab9@app.fastmail.com>
In-Reply-To: <20260924203440.3374889-1-tmenninger@everpuredata.com>
References: <20260924203440.3374889-1-tmenninger@everpuredata.com>
Subject: Re: [PATCH] xprtrdma: prevent disconnect feedback during endpoint teardown
Content-Type: text/plain
Content-Transfer-Encoding: 7bit



On Thu, Sep 24, 2026, at 4:34 PM, Tim Menninger wrote:
> xprt_autoclose() clears XPRT_CLOSE_WAIT before invoking the transport's
> ->close() operation. For RPC/RDMA, ->close() calls
> rpcrdma_xprt_disconnect(), which disconnects the RDMA CM endpoint and
> drains its QP.
>
> Since commit 31e62d25b5b8 ("xprtrdma: Simplify RPC wake-ups on
> connect"), RDMA_CM_EVENT_DISCONNECTED requests a SUNRPC transport
> disconnect. Today that path, along with failed completion handling,
> reaches xprt_force_disconnect() through rpcrdma_force_disconnect().
>
> Commit c487eb7d8e41 ("xprtrdma: Clean up disconnect") later added
> re_force_disconnect to ensure that multiple failure indications request
> only one SUNRPC disconnect. However, the gate remains open when SUNRPC
> itself begins endpoint teardown.
>
> If re_force_disconnect is still clear, either a CM disconnect event or a
> completion error can set XPRT_CLOSE_WAIT again while the current close
> is in progress. When the transport send lock is subsequently released,
> xprt_clear_locked() observes XPRT_CLOSE_WAIT and queues another
> autoclose.
>
> Requesting a disconnect this way is necessary when a connection is lost
> unexpectedly, but not when the event was generated by
> rpcrdma_xprt_disconnect() itself. In that case SUNRPC is already
> committed to closing the transport.
>
> Mark re_force_disconnect before initiating local endpoint teardown so
> that CM events and completion errors caused by that teardown cannot
> request another close. An unexpected error that wins the race before
> local endpoint teardown begins can still request a disconnect normally.
>
> Use a fully ordered exchange so that the gate is globally closed before
> rdma_disconnect() can transition the QP to error and generate the
> callbacks that the gate suppresses.

Reviewed-by: Chuck Lever <cel@kernel.org>


-- 
Chuck Lever (Come to NFS bake-a-thon! https://nfsv4bat.org)

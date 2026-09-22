Received: from smtp.kernel.org (aws-us-west-2-korg-mail-alma10-1.taild15c8.ts.net [100.103.45.18])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 6EB4C563FB7
	for <linux-nfs@vger.kernel.org>; Tue, 22 Sep 2026 16:13:20 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=100.103.45.18
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1790093601; cv=none; b=BNrXFojg6N3qloWJOQDdXQU2gy4cCTtefuI1wVayVwZlQWHQvmR5fwPDosMyFZXC49TpYEAmZUK4iCulzJ9pfS4HUKhaCPVJTjBcTC9JMqsP1CP1qa6Cx2uXqgCTjSrUkevrwGsftOs62Zqj8KETDqcSVaWK4tR5N3M7A+2AcUE=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1790093601; c=relaxed/simple;
	bh=QRVPCsjyS/d17FDqBpEGQrhcMy7/xFo9Lk/zh0QDdew=;
	h=From:To:Cc:Subject:Date:Message-ID:In-Reply-To:References:
	 MIME-Version:Content-Type; b=V7CuJoo44d2L15ytmi5Y01u+3kqoHBY8a5HsTPCGHU+auLNu10ILacvKYNmV51P53SCcDyHHRALhRNv9zA/3Q7HxJ19lnqslGuNHGm8cFmgKx0Yc0ugEpJlxCyvygwX/WiRvMxxhnTKr6HrUwpwUgGF0UpeiRgdwkwtcg8wj/M8=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=WLpnQLIZ; arc=none smtp.client-ip=100.103.45.18
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="WLpnQLIZ"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 83ADB1F000FF;
	Tue, 22 Sep 2026 16:13:19 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1790093600;
	bh=bi3moq/IAoOC6RR9KPDXAhkYQ2BMbBEyW5ujmZIoHqA=;
	h=From:To:Cc:Subject:Date:In-Reply-To:References;
	b=WLpnQLIZF7Msxy6DWx1PFOMUwkBoDcrQQHnofzFc183PTJ1tvL1Wm5XaFacAC5wPl
	 FFm6hOW61QJmsVYoCEndpDOcOg7ABbTuKSrAb6iimakk+oGtYp41F5+9Ao7P9J0hI4
	 6ylSQYuRGOm8hUg/1owwk+9zil29LT5ELvh0nveJt9GHA/toO3SGr0tO9kpB5POx2u
	 k6T/1Ynmheh9W/1BM70NauDADdt0kPHb/jbCe3Q3yjdBMS1WhAkeL6PEHWzd8Id71a
	 mRHq3X8hLVoqGICSXQcaSdFaa3WcBWjDjzpzpRN9qJKRXFUTm9zbt9meXldGuuT1Me
	 PPKlSIaK6vclw==
From: Chuck Lever <cel@kernel.org>
To: jlayton@kernel.org,
	Abhinandan Ekande <aekande@redhat.com>
Cc: neilb@brown.name,
	okorniev@redhat.com,
	Dai.Ngo@oracle.com,
	tom@talpey.com,
	linux-nfs@vger.kernel.org
Subject: Re: [PATCH] SUNRPC: in svcauth_gss_wrap_integ() resync rq_next_page after the GSS wrap
Date: Tue, 22 Sep 2026 12:13:16 -0400
Message-ID: <179009358798.3889096.3405918687560360743.b4-ty@b4>
X-Mailer: git-send-email 2.54.0
In-Reply-To: <20260922134858.2219136-1-aekande@redhat.com>
References: <20260922134858.2219136-1-aekande@redhat.com>
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 8bit

On Tue, 22 Sep 2026 09:48:58 -0400, Abhinandan Ekande wrote:
> For a page-aligned READ payload, xdr_reserve_space_vec() leaves the
> encode cursor with p == end and page_ptr still on the last payload page.
> nfsd4_encode_operation() then resyncs rqstp->rq_next_page = xdr->page_ptr + 1,
> so rq_next_page points at the first page past the payload.
> 
> The GSS MIC is encoded later, after the last operation, and nothing resyncs
> rq_next_page after that. Because p == end, the MIC's xdr_reserve_space()
> falls into xdr_get_next_encode_buffer(), which increments page_ptr into
> the next page — the page rq_next_page points at. After the send,
> svc_rqst_release_pages() releases only 'rq_next_page - rq_respages' pages,
> so that page sits one past the release range and is never released. The
> next reply from the same nfsd thread writes its MIC into the same physical
> page while TCP still holds a MSG_SPLICE_PAGES reference to the previous
> reply, so that reply is transmitted carrying the wrong MIC.
> 
> [...]

Applied to nfsd-testing, thanks!

[1/1] SUNRPC: in svcauth_gss_wrap_integ() resync rq_next_page after the GSS wrap
      commit: 1f04f4ab88bd62ea98bdf6490b385b6d046aafab

--
Chuck Lever


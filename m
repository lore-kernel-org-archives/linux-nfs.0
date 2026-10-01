Received: from smtp.kernel.org (aws-us-west-2-korg-mail-alma10-1.taild15c8.ts.net [100.103.45.18])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 7F8E035E1A4
	for <linux-nfs@vger.kernel.org>; Thu,  1 Oct 2026 00:43:33 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=100.103.45.18
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1790815417; cv=none; b=Nyj6MeK1njfcCFVWrYfoN5Q7s0LWh8GQIQYqm+6eqbky6YiE46OZyQ6iLM9i48FQeUKhHQ6NNanjMaV530HUecvmAyXyAr3vaq47a0UdfuYM/F1fm2lo0rBLpkuZTJ/8fNXvRd8q88DQa8YAjaE1pydTDvDlxdOPrLthFAbixIE=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1790815417; c=relaxed/simple;
	bh=KSHu5a2mJ1xfNyaJECWoE/21miVpc1tY893M0grLibE=;
	h=MIME-Version:Date:From:To:Cc:Message-Id:In-Reply-To:References:
	 Subject:Content-Type; b=GxhIvceSYCby0QzVZ38Tam1Gat5IYbw7QHJBOjDs4vfUXkaouOYlCTTbLi1GXaQrtcMcah+OlvPcscD34L5n4NPnuF56mtPsGFu0aJu5+lTDHIN6cHZk9J5CB8f+xQq4DiTzn5QrTh1MDr+CeCPRLj6sc/giaUI+7ND9BvfAbro=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=H7UTmxGh; arc=none smtp.client-ip=100.103.45.18
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="H7UTmxGh"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 595E31F00899;
	Thu,  1 Oct 2026 00:43:31 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1790815411;
	bh=ovnpSUKE8TetNT/2EM4/AmmK3MMTLsMWa1SMiRHMF0Y=;
	h=Date:From:To:Cc:In-Reply-To:References:Subject;
	b=H7UTmxGhFmYj8l8vbFqvO1h/jpTEX3RuaFnZGbAk7RuqPLf0DC8fsj48X4EcPnh1K
	 8F88q/gtXcSdyyfNIeQRw3zhN4s8+T3hNt6TE9F+QDNPXTRtIEAW5WjqmV1k19xcZk
	 44ZCUM38KT3KLHf5G/RBWrsazO9wD/GULCwNmPQLzpWU/KTfjP1+fxZgjcxgWl9Y6i
	 4K2UGQ9erAwCZLeRKExbJdk4jWFp3QTaMxyZrIIA3r2bh0U2s/XIqD2hzipvhlH1ub
	 EjrX6LDz+0LofL5G7jPSAljj0FnC7G7WIp07Ur7U/nLR9fy9hGysNVGVQ6b72d7RSo
	 rYRCck/r3ifkQ==
Received: from phl-compute-10.internal (phl-compute-10.internal [10.202.2.50])
	by mailfauth.phl.internal (Postfix) with ESMTP id 5ECD0F40066;
	Wed, 30 Sep 2026 20:43:30 -0400 (EDT)
Received: from phl-imap-15 ([10.202.2.104])
  by phl-compute-10.internal (MEProxy); Wed, 30 Sep 2026 20:43:30 -0400
X-ME-Sender: <xms:sqy9alGenPyRr-cK67sw5lzfAp1skrHzLwDBCe3bOY4JhbvgkCBdHw>
    <xme:sqy9alICJ1EVgYReiQg7GmpyxB1SZQJajWXjWzdaxXuwbHmOGuDZldl1-SyRSd_VB
    2QUB45BruCHL9AGovnCWYc6tMk-5zA6IFGETC-5unhsnhx208haBkQ>
X-ME-Proxy-Cause: dmFkZTFPsPLjRKQ1KfOK9Wy4TAKAfGz3PpBZFtlmdV0SPWnhd59cV9BLzEtbSpBUKbM7eL
    RpYFf1OsIkDgLdD6cOy+0f4DV2YATffAZfbiCI57B6NDB1J+j/3kwRAbgVdB3Afbuuoj1Z
    F/8T1jR5nJiyD5Zu8hTxE6bSKDhbHsh4UmLktrFRRH//4Eht4yFLx4Y5I2kJss1OiLKkQD
    iZdqjlKZlXTgIfTD6sxK3qJ24i75O76ogDT0oNaawi9uTfLPEa7/0p+YQzaFy4VZK7aNqT
    XT1phKjs0iec3B42/gQokZWV7kMRZ6Nj5ijGwJcsD2iQNL38PaYOolQbjzyIVVp3ZZfSkn
    Sfvw2waxjCoP9suZQRPpgn+Xd8wLUIRG+5yP3WmGUUP4GWl7CQKPaOjsmBEISH2gyvfGoP
    CPLDqUz6NZdGW7lW07pC5qx3TTgc2QebnAcpLuqei3ca1To3hmwGUjCVAOyM/9iY5PRYPh
    45no4yhSYp61QWUrvceLeqjRw0E9cb60wFkNSDfTlD+Z5iGI9B245HvlRcIXtpWI6Dy5S5
    lEjdKWhpYjaesd+BTKZFn4xnPtmRZ3i2ycD0glvhO0WUT3vPjbtAogx7pKrWBSlCYf1OOk
    o9ikINXQIjTKg37ESJUUR6CloCrNcjHIx3W6DYsvi7cWwsL6CESIvPUUpm9A
X-ME-Proxy: <xmx:sqy9akbDU5yMOi2ppUNSOkc9irWS7uPw_t3ib3RzPqEaZ4ee-bMWoQ>
    <xmx:sqy9apYmjP7q28xdJDGZNR5oMkVL2yRN0XLGa4Mz6IE2gfcTZS_A7g>
    <xmx:sqy9alnA3Roc-ZTMrNRqTWgIWMavl5VXA6auKwf7MO-hy-nqIUNnOw>
    <xmx:sqy9as3Z_gtWp_fWPAQA9Cj-eSnKuUr8y5VjZ3vuIJu0VIxKsAhIjA>
    <xmx:sqy9at068CS2cGhNLAZPGdIwxncoU0lkRwIa2X6esyjVkS9n4BGqhzoT>
Feedback-ID: ifa6e4810:Fastmail
Received: by mailuser.phl.internal (Postfix, from userid 501)
	id 38270780070; Wed, 30 Sep 2026 20:43:30 -0400 (EDT)
X-Mailer: MessagingEngine.com Webmail Interface
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
X-ThreadId: ALdGVoYYsPlN
Date: Wed, 30 Sep 2026 17:43:10 -0700
From: "Chuck Lever" <cel@kernel.org>
To: "Hyunsol Mun" <muumthf@gmail.com>
Cc: linux-nfs@vger.kernel.org, "Jeff Layton" <jlayton@kernel.org>,
 NeilBrown <neil@brown.name>, "Olga Kornievskaia" <okorniev@redhat.com>,
 "Dai Ngo" <Dai.Ngo@oracle.com>, "Tom Talpey" <tom@talpey.com>,
 bobtobabz@gmail.com
Message-Id: <31deab90-3f1b-4238-9890-982f7e9ab66b@slotpi15m67>
In-Reply-To: <20260930054032.299499-1-muumthf@gmail.com>
References: <20260930054032.299499-1-muumthf@gmail.com>
Subject: Re: [PATCH v2] nfsd: update reclaim client pointer under hash lock
Content-Type: text/plain
Content-Transfer-Encoding: 7bit

Hello Hyunsol -

On Wed, Sep 30, 2026 at 02:40:32PM +0900, Hyunsol Mun wrote:
> __nfsd4_create_reclaim_record_grace() assigns cr_clp after
> nfs4_client_to_reclaim() has released reclaim_str_hashtbl_lock.
> Concurrent reclaim-record removal can free the returned record before
> that assignment.
>
> Pass the client into nfs4_client_to_reclaim() and install cr_clp while
> its write lock is held, both for an existing record and for a newly
> allocated record.

This patch does not apply to nfsd-testing. The first hunk in
fs/nfsd/nfs4recover.c fails because nfsd-testing carries these two
commits:

  nfsd: remove the nfsdcltrack usermodehelper tracking backend
  nfsd: remove CONFIG_NFSD_LEGACY_CLIENT_TRACKING

The second one deletes __nfsd4_create_reclaim_record_grace() and
load_recdir(), along with the rest of the legacy recovery directory
backend. The function with the post-unlock assignment no longer
exists.

So I can't take this patch for nfsd-next: there is nothing left for it
to fix there.

-- 
Chuck Lever (Come to NFS bake-a-thon! https://nfsv4bat.org)

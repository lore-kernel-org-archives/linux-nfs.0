Received: from smtp.kernel.org (aws-us-west-2-korg-mail-alma10-1.taild15c8.ts.net [100.103.45.18])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 745733C3F7B
	for <linux-nfs@vger.kernel.org>; Wed, 30 Sep 2026 21:46:32 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=100.103.45.18
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1790804794; cv=none; b=FAMH9q8y6LTBNUibRbBm+STnAqKRJIIUwNySyEtcOLwOFXp9hktTJnZbJbuqKtBPQJjmMsPWbvE4KeftG4ggjJEzeorKuHX5b0sRAfSkz20WVpyCjmZhGVIzsUOV5aDFe6RGVJyA4iLZED7zP2ckEwXePZxmfYJfJ+8UW7ZyIJ4=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1790804794; c=relaxed/simple;
	bh=TNA0IBdBB6KsRV8w2gcT7EJGHWEW1cVHFIVLc20xrao=;
	h=MIME-Version:Date:From:To:Cc:Message-Id:In-Reply-To:References:
	 Subject:Content-Type; b=UYRQvzwWm0nBRJ1VxkqNkG6fV8l01OKAzH8PvXrSZeSkSPlLai+WKimd6o6CF2ZLzAGooEysKgSm9Vu4OSjPc9vvc0w/3KFxCYvS6kN8lIgZc2G4hSylTrj+ily/Vl/XETzhpKZ+zbHZ+iZkrVkRRl8cQMvyRWU+w0Gz+i51niE=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=jPvUrJDS; arc=none smtp.client-ip=100.103.45.18
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="jPvUrJDS"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 13C0C1F000FF;
	Wed, 30 Sep 2026 21:46:31 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1790804792;
	bh=JnhUUGXAziXW8Hwb73Q3nu7+EUVdIzqCluinUbKWA8A=;
	h=Date:From:To:Cc:In-Reply-To:References:Subject;
	b=jPvUrJDSLxV+V55BYupCLTc0GzYXKLG0Z2F2loamcQjLLd9m16TBcAo0oTYJe1zgp
	 8nkHGVBcV9OsIO1r5Qxnk3ht7XHMaQU0cy4w3LXxVWu3h8HhvaGA1tBRBo0plvk5tL
	 X00xVSLY04xJW3rRPWjLIBXh1v+rQX5mM9fqpX/KLqt1zG+OfYvwf4LYaNEYPikPzd
	 ZA2z0jSofiikRcLOuiR0HweBnA6TldIw+P4SMu6GmlKJBmKsfVDhj/t4ZuSmTFz2Hj
	 PgiNFB3YUCoRQbz486u9ERjme+wV3ICyY0GvT3WeiENGc8pKMIRidDXKWRIZeVY5GL
	 bSzgyMs9yWyCw==
Received: from phl-compute-10.internal (phl-compute-10.internal [10.202.2.50])
	by mailfauth.phl.internal (Postfix) with ESMTP id 3ED2CF40066;
	Wed, 30 Sep 2026 17:46:31 -0400 (EDT)
Received: from phl-imap-15 ([10.202.2.104])
  by phl-compute-10.internal (MEProxy); Wed, 30 Sep 2026 17:46:31 -0400
X-ME-Sender: <xms:N4O9aoJrwdc2Ygj2QTbnpGOaeaSIMqliC6uNt24x8gpT5_c8ye-VKQ>
    <xme:N4O9ai9mWFdKgA1qGa-aw0JIFeIkPkiYQ513kiiIT9J7u1cWWey9fYLXUDtFh2eC7
    Yp-1VfJAeknatLGYJKVVESCfMC0FO7IvR8UPJD6ckUCQ8zywXL1yEns>
X-ME-Proxy-Cause: dmFkZTEJ+TncayYneT3QkSMGGMBsLAiAQvFM9tzMmSnplT3XLoqVXo/EPkN6MJgBp/W1pp
    VfoOXVPzuv9mo8TDYGp1TUcGOccqWAFnlH/Zlju3ZANpAAjTS1ZqkOsDrarxuMsoGCzhsE
    RFnCrqYGBslagWExhHq1ev4OxHPAZRvSZDH99aJHyoIOZX6MfR7+t1WobBjeCujysW01Ii
    s1Ssbpsp0EvLCbJYhozvGOBL4J6vVtB0roMUVn/LstlMo4mTiA6IPxfBWYaRV13l6HuCZc
    RjrZA4mAiA+0UJHkdudNC1xhR6Bvu+1T7vonHRWOlTv1YH/A1sdzCR0Za+9dqNZvg4j7Kx
    H+iExrHPb3fPnu+J7WIIvZPDYI8AItTz0EMjTDAsGSds1YlJU+cs+07NJuismg4oAKJTP4
    XuEVGnJqgrc2coLJz3GKSqvrFJwScYomFLzl/5lRxwAYt37fHTLqPkCrai9eeTb7YxGMYe
    UFN18Pc8s7r43w4y23LxpBO4dPk7iKRtGPRM6qrofu+leGoWyipG6YtHAgfnIwwrYyD8Lk
    98K1KV1zkIq3XWNq8EoFQQVvKhoa5XtCTAcaBy7jVZ4fOnr3VoFLjwvnPOaW5LMkzsPLoo
    7o0mAVObxHbHUaWRozQ+0CQE1lnb0d5pe4tvKM4f4c7R0qx9IErYnpdqw0mg
X-ME-Proxy: <xmx:N4O9aqM5H3dS-qyOrUB0hNJMYNM8JBwUsnclkYy5-1d5BxVhnzXgTQ>
    <xmx:N4O9aqcm-cc2BDy4srfZ0jB2bvLthCuzKzeJ64S1n_J1WqrnEOFy4A>
    <xmx:N4O9ahU82abZmFJnBQmHv-4KN1OqMHA_SahIYbtUko0Tjn7Es4-QHA>
    <xmx:N4O9aqjM0dNhvKhsQ3SeoKX1RxGHlFUc8XEQ2o3fTPfj16WiB1w2Cw>
    <xmx:N4O9ao9bTF8WbhhQ3tTrgELIhYdR8enP34Y-arY4v-ZN41i22ORmvCDn>
Feedback-ID: ifa6e4810:Fastmail
Received: by mailuser.phl.internal (Postfix, from userid 501)
	id 25CEB780070; Wed, 30 Sep 2026 17:46:31 -0400 (EDT)
X-Mailer: MessagingEngine.com Webmail Interface
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
X-ThreadId: AKcoqTPZAJRZ
Date: Wed, 30 Sep 2026 14:46:10 -0700
From: "Chuck Lever" <cel@kernel.org>
To: "Mike Snitzer" <snitzer@kernel.org>
Cc: "Jeff Layton" <jlayton@kernel.org>, linux-nfs@vger.kernel.org,
 "Trond Myklebust" <trondmy@kernel.org>, "Anna Schumaker" <anna@kernel.org>
Message-Id: <03d36af4-79b6-4bb3-8890-c6f6f44fe70f@slotpi15m67>
In-Reply-To: <20260929231329.22018-6-snitzer@kernel.org>
References: <20260929231329.22018-1-snitzer@kernel.org>
 <20260929231329.22018-6-snitzer@kernel.org>
Subject: Re: [PATCH v2 5/9] NFSD: let a direct-mode WRITE raise stable_how and elide
 the client's COMMIT
Content-Type: text/plain
Content-Transfer-Encoding: 7bit

On 9/29/26 7:13 PM, Mike Snitzer wrote:
> A WRITE serviced in a direct mode is already persistent when NFSD
> replies: the aligned middle is O_DIRECT, and a synchronous WRITE fsyncs
> whatever was buffered before the reply is sent.  The reply still says
> UNSTABLE, so the client dutifully sends a COMMIT for data that is
> already on stable storage, and NFSD answers it with an fsync that has
> nothing left to write.

I'm stopping my review here. The premise of this patch is wrong, and
the remaining patches in the series depend on whether we keep this
patch and the previous patch to return a different stable_how to the
client, or drop them.

An O_DIRECT write issued for an UNSTABLE WRITE carries no IOCB_DSYNC.
It bypasses the page cache, but it does not flush the device's write
cache and it does not commit metadata: block allocation, unwritten
extent conversion, and the i_size update all sit in the journal or
in memory until something calls fsync. Under NFSD_IO_DIRECT the data
is not on stable storage when the reply goes out, and the COMMIT's
fsync is the operation that makes it so.

The diff does the right thing to make the raised stable_how truthful:
the floor reaches every segment, and for the direct middle iomap sets
IOMAP_DIO_NEED_SYNC and runs generic_write_sync at completion. But
that means modes 3 and 4 add a flush and journal commit to every
UNSTABLE WRITE, for every client and every export, whether or not a
COMMIT would have followed. A client streaming a large sequential
write to an ordinary export goes from one flush per COMMIT to one
flush per wsize. A per-WRITE O_DSYNC direct write was measured to
cost more than a direct WRITE followed by a COMMIT, and that is why
NFSD's direct UNSTABLE path deliberately leaves IOCB_DSYNC clear.

That is a rule we established when designing the DIRECT WRITE I/O
mode: an UNSTABLE WRITE is never synced by the server on its own
initiative, and a COMMIT is always needed afterwards.

The redundant COMMIT in your flexfiles setup is a client problem, not
a server one. The client starts each flush with FLUSH_COND_STABLE,
meaning "send FILE_SYNC if this flush is a single WRITE", and clears
it whenever pg_moreio is set. In nfs_pageio_add_request, pg_moreio is
set as soon as nfs_pageio_do_add_request declines to coalesce the
next page, and on a pNFS mount the layout's pg_test declines at a
data server boundary. So a write that straddles two DSs sends both
halves UNSTABLE and follows each with a COMMIT, even though each DS
receives exactly one WRITE. The heuristic conflates "more WRITEs in
this flush" with "more WRITEs to this server". If the piece bound for
a given DS fits a single RPC, the client already knows a COMMIT will
follow and should mark that piece FILE_SYNC. Each DS then does the
write and fsync in one round trip under the existing NFSD_IO_DIRECT
mode, and no server knob is needed.

Trond, Anna: does a change in the pg_moreio / FLUSH_COND_STABLE
logic along those lines look reasonable to you?

-- 
Chuck Lever (Come to NFS bake-a-thon! https://nfsv4bat.org)

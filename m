Received: from mail-ot1-f54.google.com (mail-ot1-f54.google.com [209.85.210.54])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 0A1BB3FF1AD
	for <linux-nfs@vger.kernel.org>; Mon, 29 Jun 2026 12:19:30 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=209.85.210.54
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1782735572; cv=none; b=q/Y1iwxjXYXvzL23PVZBhYyy+LFYDHxyqlV2gyIehiMu6m43YvgCIdd2Ahbl6tMZTNaAwKOSG7hn6A27KJg+Z7Cx7eSrX5xfoJ5zALesPoZiFQjbAfNXdBSYBOyaP3zl1lK+DqSfshy4sjZFylLiHq/aPupQl+lsKKIjNf+muOE=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1782735572; c=relaxed/simple;
	bh=XXOXrVaYnzKWAxfCo0js55Z5XQp1GuwZJRgIBQ/jlWY=;
	h=From:To:Cc:Subject:Date:Message-ID:In-Reply-To:References:
	 MIME-Version:Content-Type; b=gIXr9D2ehvGfIfmNME/Hd/jj5uMzZehfH9j5oggTYRxZxdrTXv0XbBiI7AOUj47bdYLBm1nE8kIpBekbzUquRwN7cQDluiHk9THKn1/zaApz/roY/iba9rFZUXZqfU/ONDPynZoxR0RrYmGAmrYKMu2Vp/Oawr645p6FVdop+Tg=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=hammerspace.com; spf=pass smtp.mailfrom=hammerspace.com; dkim=pass (2048-bit key) header.d=hammerspace.com header.i=@hammerspace.com header.b=Pm2RUG6b; arc=none smtp.client-ip=209.85.210.54
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=hammerspace.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=hammerspace.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=hammerspace.com header.i=@hammerspace.com header.b="Pm2RUG6b"
Received: by mail-ot1-f54.google.com with SMTP id 46e09a7af769-7e9d7464b71so291116a34.0
        for <linux-nfs@vger.kernel.org>; Mon, 29 Jun 2026 05:19:30 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=hammerspace.com; s=google; t=1782735570; x=1783340370; darn=vger.kernel.org;
        h=mime-version:references:in-reply-to:message-id:date:subject:cc:to
         :from:from:to:cc:subject:date:message-id:reply-to;
        bh=68asA+LKRyyKZBVYpU4cyjrMQxmezZkkAS9hhyYQ5Mk=;
        b=Pm2RUG6bKjqvRoA8ES43to8YvAyrJLqlBceTRAAHMEL67Ix1OyfcuLAvRu88rchppe
         lTrI4ZVL0Ru0BrpCwHrlffGX6195kiM6yUFmHAThEcECTLoliGOamNNNTZvVNcs5/Hhm
         SwNIAzi8Zf0JoVvdUHkRJV0w4hKqMXqIXmTQXH+1eScAjuCpRBdRBzjxJoTsiChiA+bf
         Q8nLpAuz4X7yepeMQ0HX7JkNDrzc/jzGtm0qMZpsOp2FGn3/oPSKxzS/uABgJ8MHxSN3
         PfbEYHu3S+F9zFR+Jivh6K0B298F1IcA9ok4pC4kzwcl/7GS5e5ns31XKCTn1Px3QjT1
         ja4A==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20251104; t=1782735570; x=1783340370;
        h=mime-version:references:in-reply-to:message-id:date:subject:cc:to
         :from:x-gm-gg:x-gm-message-state:from:to:cc:subject:date:message-id
         :reply-to;
        bh=68asA+LKRyyKZBVYpU4cyjrMQxmezZkkAS9hhyYQ5Mk=;
        b=ZMNG5PsFYEXvDaSuEGDtYEOuZU5OCg2HQFuX6prPamkwPzI1n/ISpPTpfvZhaw+clc
         JqSHEM9fBEW7ShLLk5ZNvek7MR8NBGLggml2+vbrUBPUACtAwvbXaUuRFWEKqo0taBSa
         q0VqZ24lE7xPxlE5P12/JhbddDX/3rj9h4NY5hJqOqoEZi6eU6fFZyDsCcD7BrTf2Wz2
         rDdWpk7yAcaAnEQFY/sfkgjwiuTFYn2OsDzylzRplM4aZTSZichpx3fFBymcF7jNJfC/
         bB7Wyu0SUcZBUzxCmkhhgu246dfOfvgxdg5HMnJTSCVJdQJyeQiO4l6ToK+AOm6yG5uy
         AvOg==
X-Forwarded-Encrypted: i=1; AFNElJ/FOfpduiJqHtMZ+tTQSdt/E1+AhhFBXHPgO2RTf4wRT56JA/XnottiDmUGuDQcWUVAfqM9wtKJ4/Y=@vger.kernel.org
X-Gm-Message-State: AOJu0YwboVN8zz35oCf7LlU2BqtU8VcH+HbqQGm6KqLnAUiwtgYRr49R
	5E2SiHCisGqQA9HLE7z5EABVfAGZaYx105pUmIUnG4NpRIE2zGuJ9M3IqZCpypocTOQ=
X-Gm-Gg: AfdE7cl8zAquGgFfquqlgdm+LSby/BiS5oqoCdGanvQNYvjXuUfV9ycJ37qYAHpUIUx
	IC8/wnWxPcBM/fni019xcJIs4k6Atf1BqrVGYjHb523KVi+iqrsULJ/7C+QyTPCrV8XsZ+08xo4
	3iLOV2FL3TyvmQluT67a+76f1AeC9weAw2Vp+v8nHBr2vFExUL3fhG9TqBhemzNUtOuzUZDutHL
	xyeV8KHc/FooL7lrK8vXuRUcQfLzX+er0ej5epXyFknYNya6bwwaQZjInL0UdPMrSCtM+qe/AbA
	ciPTBduQHL7Lpc+/gLumLLRIMcDUzYJxbEe6iOarjdVQBUyd9BXGeuoaxooCFbKN9Pj/8oddRJ8
	PmX4O4IzD62+rMdhnyTW0g2l7JTs/cZ1RgT0ZPq7VzolR6sTTQG1TKQcxX0Mj46+Oje+kl6SUJx
	yFYzC4S+iTRje+ujt4UdCgYNO7OFA8Go3H
X-Received: by 2002:a05:6830:3c89:b0:7e9:e88f:972 with SMTP id 46e09a7af769-7e9e922bd62mr255676a34.11.1782735569695;
        Mon, 29 Jun 2026 05:19:29 -0700 (PDT)
Received: from [192.168.254.51] ([66.97.168.37])
        by smtp.gmail.com with ESMTPSA id 46e09a7af769-7e9aa787468sm8325551a34.17.2026.06.29.05.19.28
        (version=TLS1_3 cipher=TLS_AES_256_GCM_SHA384 bits=256/256);
        Mon, 29 Jun 2026 05:19:29 -0700 (PDT)
From: Benjamin Coddington <ben.coddington@hammerspace.com>
X-Google-Original-From: Benjamin Coddington <bcodding@hammerspace.com>
To: NeilBrown <neil@brown.name>
Cc: Benjamin Coddington <ben.coddington@hammerspace.com>,
 Chuck Lever <cel@kernel.org>, Jeff Layton <jlayton@kernel.org>,
 Olga Kornievskaia <okorniev@redhat.com>, Dai Ngo <Dai.Ngo@oracle.com>,
 Tom Talpey <tom@talpey.com>, Trond Myklebust <trondmy@kernel.org>,
 Anna Schumaker <anna@kernel.org>, Daire Byrne <daire@dneg.com>,
 linux-nfs@vger.kernel.org
Subject: Re: [PATCH RFC 0/3] SUNRPC: a latency floor for interactive clients
 via sparse-flow dispatch
Date: Mon, 29 Jun 2026 08:19:27 -0400
X-Mailer: MailMate (2.0r6272)
Message-ID: <666496E4-D0EB-44A1-88CD-CD9C5BE0FBB1@hammerspace.com>
In-Reply-To: <178244194881.27465.15942469476886027226@noble.neil.brown.name>
References: <cover.1782314746.git.bcodding@hammerspace.com>
 <178244194881.27465.15942469476886027226@noble.neil.brown.name>
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain

On 25 Jun 2026, at 22:45, NeilBrown wrote:
> I wonder if we should make "batch" the special case, rather than
> "interactive".
> I don't think this makes a big difference to the code (there are still
> two queues and everyone starts out interactive) but it might change how
> we think about it.
>
> I would wait a lot longer than 64 requests before considering an
> xprt to be "batch", and I would probably want to measure it in
> seconds rather than requests.  Maybe 10-15 seconds.
> I might also only consider an xprt batch if xpt_nr_rqsts remains above
> some small number - maybe 5.
>
> Maybe we could keep track of the number of "batch" xprts and compare it
> to the thread limit.  Batch xprts might only be allowed some share of
> the thread limit...
>
> If there are a bunch of READ requests on the same file, the first could
> trigger a read-ahead, and the next several might wait for that
> read-ahead, so they would all be blocked on the same thing, which can be
> pointless.  nfsd doesn;'t have any direct visibility into this, but
> limiting requests-per-xprt differently for batch and interactive might
> be useful.  non-sync WRITE requests probably behave differently...
>
> While this approach does seem pleasingly simple, I wonder how easy it
> would be for a client to accidentally start appearing to be "batch".
> Multiple interactive sessions on the one client could incorrectly
> trigger the batch detection.
>
> Maybe it would be useful to collect some statistics of what a "batch"
> stream typically looks like (OP mix, concurrency,...) as there may be a
> better signal to look for than xpt_nr_rqsts.

I like your thinking here - but while I've been putting some numbers
together for the re-arm problem Chuck was pointing out, I've found the
behavior of the server (even with this simple mechanism) to be surprisingly
complex.  The re-arm floor/ceiling is highly dependent on timing from
multiple actors.

I'm not sure I can appropriately characterize what batch looks like.  I'm
afraid I'll end up creating a heuristic monster that will hunt us down in
the future.

I'm starting to think that per-client round-robin is suddenly looking
simpler to understand and will do the right thing in most cases, but I
haven't really given up on this dual-queue setup yet.

Here's another crazy idea: instead of letting me break this for everyone,
let's leave the current behavior untouched and create a bpf interface so
folks like me can inject their desired scheduler from userspace.

Ben

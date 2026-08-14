Received: from mail-wm1-f43.google.com (mail-wm1-f43.google.com [209.85.128.43])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 4D355377A8E
	for <linux-nfs@vger.kernel.org>; Fri, 14 Aug 2026 20:35:03 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=209.85.128.43
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1786739705; cv=none; b=HsA3AIHjFOnYcyeKEdMu0iSZFBUgyNrss8UZpsavHRlC2wKUem0F0oJNi7Z2s67+fqeYE7NaA19JxDPXQVKCE1Z8zfv7aGEqMlUAeAifkQaWv1uP7cwcJWyJUtpdXM402lzjDOdQydZEvhRt1Sesbc30XQfRcp5fyMVb7tWDjxA=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1786739705; c=relaxed/simple;
	bh=Y0DnnLCKrn4UR+viD2LnHKNQzSrMQ4oyX6cKdGqCwBk=;
	h=Date:From:To:Cc:Subject:Message-ID:References:MIME-Version:
	 Content-Type:Content-Disposition:In-Reply-To; b=X2yqMmLm6N7x9rlXfqIx0jigf1BbMLE1RT3bz9wN4NRwsFkFV/gtgelIwv4fxTBRTV5zUd26/3Fol6Zt8u+JbgIeXvfEm/C6Mwskin/bu/FxrCUfIP1S3qctchxpyTKPGBaBe5pWAl/Kjkm1+oNkboQZYIoL9BUIKdth6HPCinA=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=truenas.com; spf=pass smtp.mailfrom=truenas.com; dkim=pass (2048-bit key) header.d=truenas.com header.i=@truenas.com header.b=Xr5OP1UJ; arc=none smtp.client-ip=209.85.128.43
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=truenas.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=truenas.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=truenas.com header.i=@truenas.com header.b="Xr5OP1UJ"
Received: by mail-wm1-f43.google.com with SMTP id 5b1f17b1804b1-49800c6a846so15663255e9.3
        for <linux-nfs@vger.kernel.org>; Fri, 14 Aug 2026 13:35:03 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=truenas.com; s=google; t=1786739701; x=1787344501; darn=vger.kernel.org;
        h=in-reply-to:content-disposition:content-type:mime-version
         :references:message-id:subject:cc:to:from:date:from:to:cc:subject
         :date:message-id:reply-to:content-type;
        bh=Uakh9dheobahKr2bQxAdnTzBionUCo0AbbTF93Cw6r0=;
        b=Xr5OP1UJzA/Qg4sPxYWRqc61DA+MPQclWcU0DzI180sS8Z9jjcUOyrtZjOXPIR+/5w
         ZmGXl5yfh15o71PohxKv1l4dtOYDD2VaxjSBUCUgkLa/PhHv4QJkqbyULvmoyZR8Xhbh
         oKPADuu7FKF7lCEdU+Cap0H13Jt694XKQYRFutEOMhh4jsrQfZpInUWGhP6L2hIf8RGi
         +CiOgi6ZA6bUPnOHe+ZBQzoncnpzL1KdpsSqNR3rcm8U5VxJJAdsi8VWe4LvNHxxBvk6
         OwW6DqPLdDG1EPr+A41/Pa20kMWWfd90bLiOZHzK9SShNhLRO4i+V8amTHifh7SQ8FUS
         cC8g==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20251104; t=1786739701; x=1787344501;
        h=in-reply-to:content-disposition:content-type:mime-version
         :references:message-id:subject:cc:to:from:date:x-gm-gg
         :x-gm-message-state:from:to:cc:subject:date:message-id:reply-to
         :content-type;
        bh=Uakh9dheobahKr2bQxAdnTzBionUCo0AbbTF93Cw6r0=;
        b=bcyro4sfsd4cZAcFEqPLi0QoRPHtOCrpmhr/awAwoUiH+O6iOocp8qbU5tFa+oQsqz
         avdIUBK313rH5KLLt4/FrajsK2JKnqO/Ve0jLmTtXCH8E6FxIcaUY7yFF6c8qpE8tr0P
         0ZTkRNXO7pQFkDN5oGX/NRtXnDzL/bU5VqDpfZuXjb04etvJILDiZC6V89CSE5dkzTpx
         BNxXN4vTNeWivbdeY5NEFt75mlH9QXcA6FK9/vyS1shbz5xykrJxWaj00Ok+igihE3iT
         JlgFB76THHRj5Z+sn1JaAWy5UhHgiJGoq4En+k6yXoGh4Y1HytaDpfRPUBrhWrOR29uT
         wL9Q==
X-Forwarded-Encrypted: i=1; AHgh+RoFctEKllO4uAolGDs64KCIFmTC6GNI3Qtsua6ZjqVGuXE2UvbtblpeKKwHcWAaazYuhEymFKRk7pg=@vger.kernel.org
X-Gm-Message-State: AOJu0Yx74afXWBmpPG66pWp9iU0FKVKoIx77QkEx98bihjsaChCPqeTE
	+W2Jpz3SaeajJLqx2cFPMHA8M4VA2JuVba35v9gdsQBec19d1i3IaCG3ROBZwMJW0Q==
X-Gm-Gg: AR+sD12/pXnUXDMZx93YNFDAv8yIO9llW32tpOGts7OYfv84XFYeGkY64QTEODZmrjL
	zjaNAOshUaVPZfri6zaCQZ8VF0Iim33n18sOVNiPTlNICjBMFhruCJxGRnd48GVJB/neriSX5hA
	eWAbo5M9GxOXOuBGNiWNUU9UGtG4h+Bl6PCrmX0I9FbTFKDrIEo5CcsGKkQFRjRRJKbFp6HfEq1
	ZIyQoj1yx/EPkEbp8XtekfcaYkQSrhpIY0vqsQTH6ubOlwCWmKBdqp2rEVGLaMHcMBkUY9XReH4
	e1hiacoh/Daw0jdbAsb3FVFELNOUgpHJuZ0BwK+Qlu4blpuN2gPPzcEv42uiUu5QQFIw7o3E5vf
	YayTw/dVbezPhIiaTQO2cNdDnXxqJGmvO4wo2xW7cd1n0XcuCBcLrWE5Xbgwxf3xHNOwMxAjxMM
	g9Ki8Ao7r9j0FF8czj2WGybLjHe2kLujR+KXfKswixHBCVftxa/Jw=
X-Received: by 2002:a05:600d:8489:20b0:499:8b13:3a98 with SMTP id 5b1f17b1804b1-4998b133b3dmr44499635e9.4.1786739701433;
        Fri, 14 Aug 2026 13:35:01 -0700 (PDT)
Received: from hamza-PC ([2400:adc1:158:c700::1])
        by smtp.gmail.com with ESMTPSA id 5b1f17b1804b1-4998777d428sm51134315e9.0.2026.08.14.13.34.59
        (version=TLS1_3 cipher=TLS_AES_256_GCM_SHA384 bits=256/256);
        Fri, 14 Aug 2026 13:35:00 -0700 (PDT)
Date: Sat, 15 Aug 2026 01:34:56 +0500
From: Ameer Hamza <ameer.hamza@truenas.com>
To: Chuck Lever <cel@kernel.org>
Cc: Jeff Layton <jlayton@kernel.org>, NeilBrown <neil@brown.name>, 
	Olga Kornievskaia <okorniev@redhat.com>, Dai Ngo <Dai.Ngo@oracle.com>, Tom Talpey <tom@talpey.com>, 
	linux-nfs@vger.kernel.org, linux-kernel@vger.kernel.org, alexander.motin@truenas.com, 
	caleb.stjohn@truenas.com
Subject: Re: [PATCH] sunrpc: treat empty auth.unix.gid replies as negative
 entries
Message-ID: <an966NrsO26fe8tm@hamza-PC>
References: <20260814172507.1474519-1-ameer.hamza@truenas.com>
 <032eae35-e958-4c87-9185-3896250eb7e1@app.fastmail.com>
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <032eae35-e958-4c87-9185-3896250eb7e1@app.fastmail.com>

On Fri, Aug 14, 2026 at 04:02:23PM -0400, Chuck Lever wrote:
> 
> 
> On Fri, Aug 14, 2026, at 1:25 PM, Ameer Hamza wrote:
> > When rpc.mountd cannot resolve a uid (getpwuid() or getgrouplist()
> > failure, e.g. while winbind or sssd is briefly unreachable), it
> > answers the auth.unix.gid upcall with zero groups. unix_gid_parse()
> > installs that as a valid positive entry, and svcauth_unix_set_client()
> > then replaces the credential's group list with the empty one on
> > every request, RPCSEC_GSS included via svcauth_gss_set_client().
> > One failed lookup strips that uid of all supplementary groups on
> > every export for up to mountd's configured TTL (30 minutes by
> > default), long after the NSS backend has recovered.
> >
> > mountd cannot send an empty list for a successful lookup, since
> > getgrouplist(3) always includes at least the user's primary group,
> > so a zero-group reply can only mean the lookup failed. Record it as
> > a negative entry: unix_gid_find() then returns -ENOENT and
> > svcauth_unix_set_client() keeps the groups the RPC credential
> > already carries. This is the fallback that
> > commit 3fc605a2aa38 ("[PATCH] knfsd: allow the server to provide a
> > gid list when using AUTH_UNIX authentication") promised when no
> > answer is available, and the same state try_to_negate_entry()
> > already creates when no listener holds the channel open.
> >
> > Fixes: 3fc605a2aa38 ("[PATCH] knfsd: allow the server to provide a gid 
> > list when using AUTH_UNIX authentication")
> > Assisted-by: Claude:claude-fable-5
> > Signed-off-by: Ameer Hamza <ameer.hamza@truenas.com>
> 
> Looks like the same bug exists for the new mountd netlink
> mechanism. Since that instance of the bug arrived in a
> different commit, that fix needs to be a separate patch
> with its own Fixes: tag.
> 
> Can you make this a two-patch series?
> 
> 
> -- 
> Chuck Lever

Sure, will send v2 with the netlink fix as a separate patch. Thanks for taking a look.

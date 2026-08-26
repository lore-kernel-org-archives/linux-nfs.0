Received: from mail-ed1-f53.google.com (mail-ed1-f53.google.com [209.85.208.53])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id CC63549481F
	for <linux-nfs@vger.kernel.org>; Wed, 26 Aug 2026 22:48:37 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=209.85.208.53
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1787784521; cv=none; b=ARq4zZ3+B3k/oGUk48wVJgaDAUSs5BQyXlQpt7RPcXwk95h5BX8Hm52b6iTVhhhRtkjsLXHlA9yTBFGqdNoi7ubgDW6IpEhMmkh6iQRagqMqVGg1jlEy7AAXLy2gTg+NL9LK0s4xpPgvx2F2dORpo82KEqvd1Mz1Fo2U2J4qFbU=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1787784521; c=relaxed/simple;
	bh=xzmAEInDz857u2Jr0pvQVTHNeTTi4QZmA77e1G1h9tY=;
	h=MIME-Version:References:In-Reply-To:From:Date:Message-ID:Subject:
	 To:Cc:Content-Type; b=ZqAo7fmq4W2/o/8iS6c9c8JHlnJIpmSjy8lCyzmXo4pofPnPQOF5YpRTYVayVKd+GdzXayYxNrKI+DmQw1QO3tL/MlIC4AEg2t2FaPmLf01wkdl0fRMNhGZNknA1rWxrJmy/k6s7SPsytCj6/yd8P19Z25yK3wHSPNri6m8nDlU=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=none (p=none dis=none) header.from=linux-foundation.org; spf=pass smtp.mailfrom=linuxfoundation.org; dkim=pass (1024-bit key) header.d=linux-foundation.org header.i=@linux-foundation.org header.b=SjfgPyl9; arc=none smtp.client-ip=209.85.208.53
Authentication-Results: smtp.subspace.kernel.org; dmarc=none (p=none dis=none) header.from=linux-foundation.org
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=linuxfoundation.org
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (1024-bit key) header.d=linux-foundation.org header.i=@linux-foundation.org header.b="SjfgPyl9"
Received: by mail-ed1-f53.google.com with SMTP id 4fb4d7f45d1cf-6a5e866bca0so2054850a12.0
        for <linux-nfs@vger.kernel.org>; Wed, 26 Aug 2026 15:48:37 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=linux-foundation.org; s=google; t=1787784516; x=1788389316; darn=vger.kernel.org;
        h=content-type:cc:to:subject:message-id:date:from:in-reply-to
         :references:mime-version:from:to:cc:subject:date:message-id:reply-to
         :content-type;
        bh=BabTwaHX7D5uldURRvLu8fbrYXwykwbu4VtBW/tOxko=;
        b=SjfgPyl9lnH1W7A3FW9V2AL1TSX0fB8A2yYx2OPQ5KgKNevzfEDvJPmyl/mZWeU21G
         4g/HARx1lB3ORIu8QmoZSa3s16fK6xTYizSlpxyWgUxtqCYGoEF7Hx4uxsA3eBsyOS2/
         eaE1I8+w5RQhMp7jzwmVUhBYfNP3hxSy/w31s=
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20251104; t=1787784516; x=1788389316;
        h=content-type:cc:to:subject:message-id:date:from:in-reply-to
         :references:mime-version:x-gm-gg:x-gm-message-state:from:to:cc
         :subject:date:message-id:reply-to:content-type;
        bh=BabTwaHX7D5uldURRvLu8fbrYXwykwbu4VtBW/tOxko=;
        b=JP2SDgELwxHBJwZ1SzfjF07D2g1YzcYNw+WqgIt3AqgB3w7Nhv4GRsoMDk9uDG8HF4
         NXNDmm8LU1Zvr0MSF43rzHfFz9omuRIrw1z64SmILGirPA1j5pQvhyXMXOj9WIdsWhoy
         upGs/UCuI93byDyYxG8k6r81Net+vPjhNzR4E6guqZykn34wJ9CCuxoD5CLWwQkVUZNv
         ttPZLE4DBPZwtlB/6lkj9glWC2BkBYCkasTfBNxt8P+6vfj3UZvJ5jGNGDoJQ1CfGjr2
         TlTrsq0h3jjopAjATz9BaBhDNAQv2GAplbwN8IZuzN3Cu6cos9jafRo4UErAnC4SuuMf
         FbRg==
X-Gm-Message-State: AFuF++lzUkRopS4+d1mXJyG3GFatR20lKSSGnS1T3gtwPle0HnMaB7FC
	E7l4tJpV1QxqxZJs37FBbtjJG+OLDKYUYMxlcM8Pa7HJukYzgL53WStN8n9Z5zFoDduIJjKyMLz
	kf7NckwM=
X-Gm-Gg: AR+sD10mYjCQXAHBQqrKDeQxctyBFvpb6RnU0KcddV5BqCqEtN+dgEFdcqQ+pK8hAjL
	dUrOfRa+tssAeE6SAjYJDjx/Aj5et6Iw+nABEaBKwXren9ZBoPOkXJ5z4ff+sKwMy48pJn5V6GZ
	fr12Hg3bFcM23t4keKpeqZlV1bDFWKUg8y5jxvdB40DuBoU10JRI+tDLjyxmd4uSuXGMjvLGFW/
	n6dGYMUT+gT3mdLRDd7KYc8TGNXtNaZK716TWlz+CsZ/YJrenbDl4+xCCfwGfvVJUWWBHpVixx3
	NzljYRl5DxP/c8UwSfMYZnJEgF5SdeyzIC6CHFDkeBkiHc9ci93l288+aGTY6nDO3iY9+goyORU
	1WjMoptiWgd4JITZQSHeyYMGuvhxMygSr3Rqq/zqeskBNgVvjr06yf0iK+C2uyik+ASmsWbuLlX
	7bRFOHX2m88u/XS6arYVI+cQHS3Pv6S48YTHp4OAk8/Xxzm/5EqDmxk283KMqDji1aQPkaY9fLD
	OI1q5Rxa9pBD23KbCauG2NEHmHSxyOao93IcuI=
X-Received: by 2002:a05:6402:2810:b0:6a5:f528:ff48 with SMTP id 4fb4d7f45d1cf-6a5f5290123mr1738972a12.5.1787784515680;
        Wed, 26 Aug 2026 15:48:35 -0700 (PDT)
Received: from mail-ej1-f41.google.com (mail-ej1-f41.google.com. [209.85.218.41])
        by smtp.gmail.com with ESMTPSA id 4fb4d7f45d1cf-6a5deae9a75sm4800531a12.28.2026.08.26.15.48.34
        for <linux-nfs@vger.kernel.org>
        (version=TLS1_3 cipher=TLS_AES_128_GCM_SHA256 bits=128/128);
        Wed, 26 Aug 2026 15:48:34 -0700 (PDT)
Received: by mail-ej1-f41.google.com with SMTP id a640c23a62f3a-c15cd3fd760so179663766b.2
        for <linux-nfs@vger.kernel.org>; Wed, 26 Aug 2026 15:48:34 -0700 (PDT)
X-Received: by 2002:a17:906:9fce:b0:c1f:1520:4de5 with SMTP id
 a640c23a62f3a-c250bb50762mr1155820666b.1.1787784514514; Wed, 26 Aug 2026
 15:48:34 -0700 (PDT)
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
References: <ebcd172da92ef6a8aafb5f0c6f84d0c6a735cb01.camel@kernel.org>
In-Reply-To: <ebcd172da92ef6a8aafb5f0c6f84d0c6a735cb01.camel@kernel.org>
From: Linus Torvalds <torvalds@linux-foundation.org>
Date: Wed, 26 Aug 2026 15:48:18 -0700
X-Gmail-Original-Message-ID: <CAHk-=wgBDRG2X_p2=DA+sftD+4ZWfistBnxMAZL+vmjvetLJhQ@mail.gmail.com>
X-Gm-Features: AcwNN1UH3VpmiB1YTnghqZPx00sofqQvPCEo3vmv_OnECRtfTKpzanZE3MeNbGE
Message-ID: <CAHk-=wgBDRG2X_p2=DA+sftD+4ZWfistBnxMAZL+vmjvetLJhQ@mail.gmail.com>
Subject: Re: [GIT PULL] Please pull NFS client fixes for Linux 7.3
To: Trond Myklebust <trondmy@kernel.org>
Cc: Linux NFS mailing list <linux-nfs@vger.kernel.org>, 
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>
Content-Type: text/plain; charset="UTF-8"

On Wed, 26 Aug 2026 at 13:57, Trond Myklebust <trondmy@kernel.org> wrote:
>
>
> Highlights include:
>
> Stable fixes:
> - SunRPC: Use-after-free fixes for the sunrpc client code
> - NFSv4: Delegation hash table leak
> - lockd: NULL dereference on lockowner allocation failure
[..]

Please give a real summary of what has happened, not just a lightly
edited git shortlog list sorted by "is stable cc'd or not".

And even if the end result is that "lightly edited shortlog", then at
least make it more useful and legible to users.

For example, just to look at that first bullet point: why have that
"SunRPC:" thing at all? It adds no value. This is a NFS client merge
message, and the line goes on to say "fixes for the sunrpc client
code".

Same foes for pretty much every single bullet entry - that first one
was not the one that stood out - they all stood out as "

The merge message shouldn't be about some minor details - that's what
the individual commits messages are for.

I did some more light editing to at least make it slightly more
readable, but it's still not exactly great.  Please don't make me do
that. Give me that overview of what happened and what matters. And
it's ok to say "And misc fixes" for things that really doesn't matter
and people who care should just look at the individual commits.

                  Linus

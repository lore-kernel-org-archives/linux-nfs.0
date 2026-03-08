Received: from sphereful.davidgow.net (sphereful.davidgow.net [203.29.242.92])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 0A1D92D8771;
	Sun,  8 Mar 2026 08:41:46 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=203.29.242.92
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1772959309; cv=none; b=EzGMBqBwNGXn8Jb8x6yfjiuiLE6jKTG7DWUZJXYrt+1QDEdcugVbMd5XAxsKbadbzL0O/1R/Eb9wnT+/Jwy1W+8Whstuq7BYpaBPJ3pX6d/XAV4pb6pCPg8dqc/oAtgaSjxS4q4GVaSMf6lNHViogO+7LAGhks3TCi4aAphCBQ0=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1772959309; c=relaxed/simple;
	bh=Knb4Xoodhrmve8INDkUo+7HYC1WNtVl3+yivDKX50KE=;
	h=Message-ID:Date:MIME-Version:Subject:To:Cc:References:From:
	 In-Reply-To:Content-Type; b=G2Bw508krTAs8x+fh2axkTH7k5W3fwI4N7/g3KhWxwXHNZXtizfLCZayRDGRmO1kGF35ENFEnrV7doyeaactPOJUAEOVE916R3wvpD+zcVgadZWm9Q7P5Ba6voPiKOtiUQLmkCahTx+xvH8w80UHaPXPqNwU9PAOoN10dY6M8KI=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=davidgow.net; spf=pass smtp.mailfrom=davidgow.net; dkim=pass (4096-bit key) header.d=davidgow.net header.i=@davidgow.net header.b=E1VMigsn; dkim=pass (4096-bit key) header.d=davidgow.net header.i=@davidgow.net header.b=hMW0T7HX; arc=none smtp.client-ip=203.29.242.92
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=davidgow.net
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=davidgow.net
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (4096-bit key) header.d=davidgow.net header.i=@davidgow.net header.b="E1VMigsn";
	dkim=pass (4096-bit key) header.d=davidgow.net header.i=@davidgow.net header.b="hMW0T7HX"
DKIM-Signature: v=1; a=rsa-sha256; c=simple/simple; d=davidgow.net;
	s=201606; t=1772959299;
	bh=Knb4Xoodhrmve8INDkUo+7HYC1WNtVl3+yivDKX50KE=;
	h=Date:Subject:To:Cc:References:From:In-Reply-To:From;
	b=E1VMigsnA7wPsJ61Mb/AOBlmay9BItR3tg1sDmRazk+qZfsHTAPG3F+p7QwDxq9w7
	 7ft/S/F/+sVu+XG2TEqALifwEQ5UhJ+E04mGUU+w6bJ3TRqPWiI2dHHfZ92QlNaWQo
	 phgzOO8D7W/osdKd9WJ0iHe7pETRPK1CAoaCjF3Y/hxyz0Iv22h6iH+yPZHTiJQItI
	 YBlcOAqH+JNI1RyIQJvLumGqXZWqDqeD/xyPgZCx3bD8QCTl+YP4+Z3QfK+A3hs3fW
	 MTiIR1mxY9VKnYRcTxRZUL61yQBNA4Ii3ImV0s1wUAhccdfbUPtLSRR3u1C+KIyfMF
	 FGEQFDU8Y+SRz+kfgHqjLkh1FPI04oy3a+A2vAlzgzV+ytE4nHgqcRieDyeocCR2iU
	 pv0aZgh0KRB8GBthc75zN6yK9py1i0xIWBZ4m5yAfE+qrcuHipRg468oX+NYDswNW+
	 zVRHpwhbHB2evT2Lzo2ItygDVSDFrT5FzIBOYAvtK8YIEme6MySQBldo/cMRT1nBn8
	 5Yt71y3NF7nd4sQ2rz65x4fgW68aVxDVZ+30xmd/wTSBAPYdZHMACi9rJmAPgK/Gr6
	 I6ybO198utsBGK0TdO33lY6HpssIldpRwYn2z88dJzDDVIqkd5BV/VhQbh0eI8IdVd
	 KC+tjo21qPOxGUv4PN67VerA=
Received: by sphereful.davidgow.net (Postfix, from userid 119)
	id 05A141E7D0D; Sun,  8 Mar 2026 16:41:39 +0800 (AWST)
X-Spam-Level: 
DKIM-Signature: v=1; a=rsa-sha256; c=simple/simple; d=davidgow.net;
	s=201606; t=1772959295;
	bh=Knb4Xoodhrmve8INDkUo+7HYC1WNtVl3+yivDKX50KE=;
	h=Date:Subject:To:Cc:References:From:In-Reply-To:From;
	b=hMW0T7HX5XyRPd33+hfTJo9vma2kEYtb3C6wnPNkoou7NRD30oNk+3diCa6r3w15q
	 CgbNF3XYf+5w1HaluQ/dom0QmQSiE5Z463bYoXluVk4xwC7+po5YjcbaiDlrjVnf5x
	 4so5r4bl4X9EPgqKqGY4sFeps7N8CREH9w87MwrRqGUq8UjhKYH0HUOAnxZ5WiyH/2
	 A3jKS3tYVrDgchSJX4+S1OX2wqfKYEwsVhEqQRYWQVK1xTWvM9sZp2k5Pxw2O3ZKrH
	 sKLU0JGeQTxHm5sncYAMCDhzJWhbmga4o9iLZUfwwpdsOPVAk5UhaMfwK4Lw2rdhQz
	 9W9lmW/wurh/oLtqPG2h82eb8jBqBHpbOJwqOX462TJe1lrykS1Uh2lM0zsDI6oHu5
	 nyAtVenjmBjopCPgNSEC6qdUVXNlgggJz1g74eKDC+6dIuhXuQ4La6aQhAFRJewd2t
	 Vb59gC4fJF2llMd8ciAlcOX0slPqio0CF/9wCHzIKrZdY5L/KZuVtUg0ih40RurLDA
	 fnAfVmfG//PxBcjmJuWnDl5vQXwQrkOsaE5JILop6IOf8+snLXaV85bqU3obDtU6J3
	 WqKqVjT6vTFfIZ+gnlGbHlHZX45j9CPT4oTTSXbU0fxWHTK6udAJL0nebSB44yJbFb
	 cYTt+93mCGXaADDf7UTCAUZU=
Received: from [IPV6:2001:8003:8824:9e00:6d16:7ef9:c827:387c] (unknown [IPv6:2001:8003:8824:9e00:6d16:7ef9:c827:387c])
	by sphereful.davidgow.net (Postfix) with ESMTPSA id B3D0E1E7CFB;
	Sun,  8 Mar 2026 16:41:35 +0800 (AWST)
Message-ID: <61367c90-a2c0-4525-975a-fecbc9cb2bdf@davidgow.net>
Date: Sun, 8 Mar 2026 16:41:32 +0800
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
User-Agent: Mozilla Thunderbird
Subject: Re: [PATCH] kthread: remove kthread_exit()
To: Christian Brauner <brauner@kernel.org>, linux-kernel@vger.kernel.org,
 linux-modules@vger.kernel.org, linux-nfs@vger.kernel.org,
 bpf@vger.kernel.org, linux-kselftest@vger.kernel.org,
 kunit-dev@googlegroups.com
Cc: Luis Chamberlain <mcgrof@kernel.org>, Petr Pavlu <petr.pavlu@suse.com>,
 Daniel Gomez <da.gomez@kernel.org>, Sami Tolvanen <samitolvanen@google.com>,
 Aaron Tomlin <atomlin@atomlin.com>, Chuck Lever <chuck.lever@oracle.com>,
 Jeff Layton <jlayton@kernel.org>, NeilBrown <neil@brown.name>,
 Olga Kornievskaia <okorniev@redhat.com>, Dai Ngo <Dai.Ngo@oracle.com>,
 Tom Talpey <tom@talpey.com>, Trond Myklebust <trondmy@kernel.org>,
 Anna Schumaker <anna@kernel.org>, Alexei Starovoitov <ast@kernel.org>,
 Daniel Borkmann <daniel@iogearbox.net>,
 John Fastabend <john.fastabend@gmail.com>,
 Andrii Nakryiko <andrii@kernel.org>, Martin KaFai Lau
 <martin.lau@linux.dev>, Eduard Zingerman <eddyz87@gmail.com>,
 Song Liu <song@kernel.org>, Yonghong Song <yonghong.song@linux.dev>,
 KP Singh <kpsingh@kernel.org>, Stanislav Fomichev <sdf@fomichev.me>,
 Hao Luo <haoluo@google.com>, Jiri Olsa <jolsa@kernel.org>,
 Brendan Higgins <brendan.higgins@linux.dev>, David Gow <david@davidgow.net>,
 Rae Moar <raemoar63@gmail.com>, Christian Loehle <christian.loehle@arm.com>,
 Linus Torvalds <torvalds@linux-foundation.org>
References: <1ff1bce2-8bb4-463c-a631-16e14f4ea7e2@arm.com>
 <20260306-work-kernel-exit-v1-1-8f871f6281cb@kernel.org>
Content-Language: fr
From: David Gow <david@davidgow.net>
In-Reply-To: <20260306-work-kernel-exit-v1-1-8f871f6281cb@kernel.org>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 8bit

Le 06/03/2026 à 10:07 PM, 'Christian Brauner' via KUnit Development a 
écrit :
> In 28aaa9c39945 ("kthread: consolidate kthread exit paths to prevent use-after-free")
> we folded kthread_exit() into do_exit() when we fixed a nasty UAF bug.
> We left kthread_exit() around as an alias to do_exit(). Remove it
> completely.
> 
> Reported-by: Christian Loehle <christian.loehle@arm.com>
> Link: https://lore.kernel.org/1ff1bce2-8bb4-463c-a631-16e14f4ea7e2@arm.com
> Signed-off-by: Christian Brauner <brauner@kernel.org>
> ---

The KUnit bits of this look fine, and it all works for me.

(That being said, I agree that do_exit() isn't as nice a name.)

Acked-by: David Gow <david@davidgow.net>
Tested-by: David Gow <david@davidgow.net>

Cheers,
-- David

Received: from smtp.kernel.org (aws-us-west-2-korg-mail-alma10-1.taild15c8.ts.net [100.103.45.18])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 54B33355F22;
	Wed, 12 Aug 2026 14:07:37 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=100.103.45.18
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1786543658; cv=none; b=m30vqAhQcDqJc5HOfaiJMRbzKLM79vade7NTvYsTg7yCGPVPVLqHgUx7I/YXrRSMG1B5SoZ/ibOsPnbqXH5LSYaMVBpV0uEWUyopXU28TKMGDiVIWyZd7mQUvlaENo1nEZjQZYWxeZgN8Ril4h98bxpMTngeXaiEeV0XCm85dzM=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1786543658; c=relaxed/simple;
	bh=rFesAZN8Qg9HYQcqwGFYTggXinYFaTFpaZR+81d1gY0=;
	h=MIME-Version:Date:From:To:Cc:Message-Id:In-Reply-To:References:
	 Subject:Content-Type; b=uTcmRXCIfJPi1i1QcHM+CbBjw/wh+p2LMUB4ybLG7BiDNgzC6FSmRBlGtqaGiPA8pykSyIjMlOYhU1qa3zqLi5lK6aYxrRZLIjnKyWSwbMZNc9npCCnL9QiWVIvABLYhHCSy1PnN1Hb/PGVkNP48y7RmNdHNU1e26lG13RODuIA=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=Y4EMz38j; arc=none smtp.client-ip=100.103.45.18
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="Y4EMz38j"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id AED7A1F000E9;
	Wed, 12 Aug 2026 14:07:36 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1786543657;
	bh=enO4XMSWCe0GjND/TiJxwQGqkoFUFFZDKvoF7bt4lqU=;
	h=Date:From:To:Cc:In-Reply-To:References:Subject;
	b=Y4EMz38jU/6zN2jBYNaGncUwO1CsXM34BYUvBkRvqBy3nkATsgEcmRUc5cUDgysHO
	 AdKmMURd5UcXrGeKQzzcAp2P0aNEbl3Ffjv+oRppQDjjJiMfBIqVKMbqrr0Sbjeg21
	 b8RfsvKVs4TlTO9n3BABJQbSAN1JBmV6w43IXOFNYgseXFwoqSkYAqwAH49OGSKgRO
	 ARPoMF0+mjCttVuHxfyE7xy7EbT4Zncdh59P7TYA2Ww0B+A/Pgr04x2CQIhf2fOmjy
	 0TeRcQzz+6V7lrmSR1Fdwh3PCgYY+Yh/rRTvFwonh6/yP5QzyccF9cIb0XcrqO4dAu
	 Li4uqxO8mDpfw==
Received: from phl-compute-10.internal (phl-compute-10.internal [10.202.2.50])
	by mailfauth.phl.internal (Postfix) with ESMTP id EAD9AF40066;
	Wed, 12 Aug 2026 10:07:35 -0400 (EDT)
Received: from phl-imap-15 ([10.202.2.104])
  by phl-compute-10.internal (MEProxy); Wed, 12 Aug 2026 10:07:35 -0400
X-ME-Sender: <xms:J358atZP_hSGhiF065tP_cA9pEsKDR1JUGCb0rqvqWpAuWjqeSSdKg>
    <xme:J358avMV2XTZgIq8-iMKJ4QmIX0BZwuFZx_UUHOHTFxtIrH_wv0gTF_lP5EuQ1wCp
    RsjHvqJDWZRAFfR6cvbnb5lqAVmU-la_IF1l4Kl03mXlH9alKSvZw4>
X-ME-Proxy-Cause: dmFkZTGq3wFRQbBqRhbe+msFvX7jNHN0jAw2/maiqaDKsF3utbIKgG5qbO+5Jt9A0iH8ZY
    B3/HLKOHEnyGkXxoPC+37uAGwEc1jNJYN9BwDCz30eOp/GB8qQLKcgQbKLjuZWJNsOnnX9
    DWS2sCAoIPH31gqy9BXQCu0DsCszgGTg8hT3uW1X7rQ7SJPpidZZ5UzCwxTNEDajCpu0Ht
    hlVUDu5jJ6v/El7M82B6p+2E+1EoI2JlQeRE7UjQaflNGw3O9idmabyES7I7vQjf+ZInDy
    Hb7FQLesBcO2QUfqN3wp7rLLVZRxY+93PsZsOR9ncbOxiCTGwYE28zX9wJ0qteyOPtYISg
    4MuQwFQKIgJbmkXaVewZuAK/A2g/7ty08b6fXu+oO+FyNyXfjqh+MMxJC7uv9k9rNjvbsp
    2YrWrY6AtvljMVokBTwQOFeCfT8moUEdPcvuq5M/qFBksZO+r93TkEUoAT0Zudx6FfoOds
    6z9wiWG7WvFgM8Kouv+08RjAyP/PwGenwS2Y5VHTrbxj/R0XsdTWwEZVk0dsZN2dsPV3vS
    7L0JND33adkHw4Rm6MQJfgXBIuNLZjFgPHwJhm3v7QriK0aRXNxGCOV7boKbcQpMQ1QiY4
    dqCIko2jGHeR2sWaaNh2B7d/FduMd1S2UZLXg5S1NXwgxILyMMkMDHqkvAkQ
X-ME-Proxy: <xmx:J358anbRNDbpOzlVhhKmOzfnauOUevGiSwd57rd2F3dXfDYBaDy9Tw>
    <xmx:J358aiYxLdY2BtY46KBfU-EejlFtcFDagwEEFvrkz7kNZJn5FylZ3w>
    <xmx:J358asJhMZEJopQgdLiYGzX9VQwEKPM17VF4Vw6IaNt946U9u80__A>
    <xmx:J358auvLZr3VyE08paWeJkSkhl07VZMkROhBZwfojYZPxMk48IPF5w>
    <xmx:J358agXKu01uUZjqhYEprgaZrJgbul0pf_PUZApm7VCs2b89-NTi8Q8c>
Feedback-ID: ifa6e4810:Fastmail
Received: by mailuser.phl.internal (Postfix, from userid 501)
	id CCA2D780B77; Wed, 12 Aug 2026 10:07:35 -0400 (EDT)
X-Mailer: MessagingEngine.com Webmail Interface
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
X-ThreadId: A7zFWkTO2YKR
Date: Wed, 12 Aug 2026 10:07:19 -0400
From: "Chuck Lever" <cel@kernel.org>
To: "Cedric Blancher" <cedric.blancher@gmail.com>,
 "Chuck Lever" <chuck.lever@oracle.com>
Cc: "Trond Myklebust" <trondmy@kernel.org>,
 "Anna Schumaker" <anna@kernel.org>, "Peng Tao" <tao.peng@primarydata.com>,
 "Felix Hoffmann" <f3lix.dev@gmx.de>, linux-nfs@vger.kernel.org,
 linux-kernel@vger.kernel.org
Message-Id: <e6321479-dedf-4219-99cd-ad27aa6fa18c@app.fastmail.com>
In-Reply-To: 
 <CALXu0UehYh4Kdjj3ioTy+c_9C5504ke18RufKZ0r79VfyPAEqw@mail.gmail.com>
References: <20260802195328.175328-1-f3lix.dev@gmx.de>
 <CALXu0UehYh4Kdjj3ioTy+c_9C5504ke18RufKZ0r79VfyPAEqw@mail.gmail.com>
Subject: Re: [PATCH] NFSv4.2: request mode after CLONE
Content-Type: text/plain
Content-Transfer-Encoding: 7bit



On Wed, Aug 12, 2026, at 2:25 AM, Cedric Blancher wrote:
> On Sun, 2 Aug 2026 at 21:58, Felix Hoffmann <f3lix.dev@gmx.de> wrote:
>>
>> The NFS server can clear setuid and setgid bits when CLONE modifies the
>> destination.  The client currently omits mode from the post-operation
>> attributes, so the cached mode can retain setid bits after the server has
>> removed them.  A local process can then execute the file using those stale
>> privilege bits.
>>
>> Request mode in the CLONE compound's GETATTR.  This lets the ordered
>> post-operation update install the server's mode before CLONE returns.
>>
>> Fixes: e5341f3a5762 ("nfs42: add CLONE proc functions")
>> Cc: stable@vger.kernel.org
>> Assisted-by: Codex:gpt-5
>> Signed-off-by: Felix Hoffmann <f3lix.dev@gmx.de>
>> ---
>> Tested on x86-64 using an NFSv4.2 loopback mount with Linux NFSD and a
>> Btrfs export:
>>
>>   - before this change, the client retained mode 04775 while the server
>>     stored mode 0775, and the privilege transition reproduced in 10/10
>>     non-debug runs
>>   - with this change, both client and server reported mode 0775 and no
>>     privilege transition occurred in 10/10 non-debug runs or 3/3 KASAN
>>     runs
>>
>> The reproducer requires write authorization to the destination; NFSD
>> rejected the same operation against a non-writable 04755 file with EACCES.
>> A working reproducer is available privately on request.
>>
>>  fs/nfs/nfs42proc.c | 3 ++-
>>  1 file changed, 2 insertions(+), 1 deletion(-)
>>
>> diff --git a/fs/nfs/nfs42proc.c b/fs/nfs/nfs42proc.c
>> index ab86246fc364..35a4909d51b7 100644
>> --- a/fs/nfs/nfs42proc.c
>> +++ b/fs/nfs/nfs42proc.c
>> @@ -1302,7 +1302,8 @@ static int _nfs42_proc_clone(struct rpc_message *msg, struct file *src_f,
>>                 return -ENOMEM;
>>
>>         nfs4_bitmask_set(dst_bitmask, server->cache_consistency_bitmask,
>> -                        dst_inode, NFS_INO_INVALID_BLOCKS);
>> +                        dst_inode,
>> +                        NFS_INO_INVALID_BLOCKS | NFS_INO_INVALID_MODE);
>>
>>         status = nfs4_call_sync(server->client, server, msg,
>>                                 &args.seq_args, &res.seq_res, 0);
>
> Chuck, what do you think? Does this apply only to NFS CLONE, or to NFS COPY too?

Responding since you asked me directly, but I don't have a
considered opinion about this. Just some advice: the OP
provided a reproducer, you could try that and see. Naively
I would expect it might apply to COPY.

-- 
Chuck Lever

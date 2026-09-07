Received: from jasonwiebedairy.com (jasonwiebedairy.com [45.79.9.129])
	by smtp.subspace.kernel.org (Postfix) with ESMTP id 732FB3A254C;
	Mon,  7 Sep 2026 18:57:50 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=45.79.9.129
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1788807471; cv=none; b=PnzW/pnHbbqYlj8u40T2iliaCwLzuY2RW5+UV2UEOho2RxJuJ0xRxQUmB2G2A3THOAQNioJo8D6M5ZI9L0cXA013/gQ3ulV+fnrZEx/+Jm6nlb8+lvStcxEp0QlIf245HVcmOHtqFuLecjCrwBBjWeVBuREK+mZINK1j8Ch4Sdc=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1788807471; c=relaxed/simple;
	bh=A1BEhn4OuvvbXx9z9acOPhoqdJmT0xQz1QCSBNLAdFY=;
	h=Message-ID:Date:Subject:To:Cc:References:From:In-Reply-To:
	 Content-Type; b=KwyxBpEutGYcxIaWjGco/VujRv1phS4hKhgWWEWcPwT8/0T3kbTaLtnrsEuo5veibS2AGXtq0gH1m9ppLWxwczaH92lAJOvE6TTNaPRvpU2mmgOlt/7+tD+Na+mv8Ps7iaU3nyroGhSqBImHGeHUMPG/UBqujbIYRUkYnwwGrl0=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=reject dis=none) header.from=benjiwiebe.com; spf=pass smtp.mailfrom=benjiwiebe.com; dkim=pass (1024-bit key) header.d=benjiwiebe.com header.i=@benjiwiebe.com header.b=JpmDYyIB; arc=none smtp.client-ip=45.79.9.129
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=reject dis=none) header.from=benjiwiebe.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=benjiwiebe.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (1024-bit key) header.d=benjiwiebe.com header.i=@benjiwiebe.com header.b="JpmDYyIB"
Message-ID: <b5134cbf-f73e-4326-8969-5d8ac070b3eb@benjiwiebe.com>
DKIM-Filter: OpenDKIM Filter v2.11.0 jasonwiebedairy.com 752BBC05DD
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=benjiwiebe.com;
	s=default; t=1788807464;
	bh=X47q27yWTGaHqcyll6KHKra5gQ+HkE6+FI/4j9i5MpA=;
	h=Date:Subject:To:Cc:References:From:In-Reply-To:From;
	b=JpmDYyIBSxmfiv+E96fJfu5qF6oL2qAUsyuQ3GlImEhXdfwxeW9QTulNTFEQ80qOu
	 Dfs9I3XoWGT1bDT5O9Lz0gHo2N1fZHGusIeDbnVHvThucBA6RQwkywScV+BqDRV9ZQ
	 NVwP08DL4IMJ6tZc5jKGVIdMbVazdhzBz0QZgDZs=
Date: Mon, 7 Sep 2026 13:57:43 -0500
User-Agent: Mozilla Thunderbird
Subject: Re: [REGRESSION] reads and writes hang if NFS server has v3 disabled
To: Jeff Layton <jlayton@kernel.org>, Chuck Lever <cel@kernel.org>
Cc: Linux kernel regressions list <regressions@lists.linux.dev>,
 linux-nfs@vger.kernel.org, stable@vger.kernel.org
References: <c26ff09f-48d6-4ef3-9feb-8a8e6d6f37ba@benjiwiebe.com>
 <c3d06b9f-7da5-479f-be4f-9c0136631ce9@oracle.com>
 <c734eeb8-8486-4491-bb4d-b9656cbaffbe@app.fastmail.com>
 <52ddb3307fcc0893cc20ed63c4dc924f6bcaa8fd.camel@kernel.org>
Content-Language: en-US
From: Benji Wiebe <itsme@benjiwiebe.com>
In-Reply-To: <52ddb3307fcc0893cc20ed63c4dc924f6bcaa8fd.camel@kernel.org>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 8bit
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>

On 9/4/26 8:45 AM, Jeff Layton wrote:
> On Fri, 2026-09-04 at 09:09 -0400, Chuck Lever wrote:
>> [ Adding correct addresses from MAINTAINERS ]
>>
>> On Fri, Sep 4, 2026, at 9:05 AM, Chuck Lever wrote:
>>> I'm using a minimal Fedora 45 VM (kvm) for testing.   I export a
>>> directory with rw and mount it from my personal computer running Fedora
>>> 45 as well. If /etc/nfs. conf has vers3=n, then reads and writes hang in
>>> D+ state, and there's a continuous
>>>
>>>
>>> I'm using a minimal Fedora 45 VM (kvm) for testing.  I export a
>>> directory with rw and mount it from my personal computer running Fedora
>>> 45 as well.
>>> If /etc/nfs.conf has vers3=n, then reads and writes hang in D+ state,
>>> and there's a continuous loop of V3 NULL calls, with the server replying
>>> that it only supports v4.
>>> If nfs.conf has vers3=y, then the reads and writes succeed.
>>> Introduced in 70b7e3526c53d9dd, still present in the latest
>>> mainline/master (841e384b841a).
>>>
>>> The hung state can be rescued by changing the setting and restarting
>>> nfs-server, at which point the read/write will complete.
>>>
>>> I can do more testing / get more information as needed.
>>>
>>> Here's links to pcap files with it working/bugged:
>>> http://grepper.net/lkml-files/nfs-working.pcap
>>> http://grepper.net/lkml-files/nfs-bugged.pcap
>>> http://grepper.net/lkml-files/nfs-bug-kernel.config
>>>
>>> #regzbot introduced:  70b7e3526c53d9dd7caccdbeff5b0485640d8cf1
>>
>> It's not immediately obvious to me why 70b7e3526c53d9dd should
>> cause this kind of behavior regression.
>>
>> Jeff, it's a netlink change. Can you triage?
>>
> 
> Sure.
> 
> Looking at the captures, it looks like the server is handing out a
> flexfiles v3 pNFS layout for the trivial server, and that's (of course)
> failing in this situation.
> 
> So we have at least one server bug there -- it shouldn't advertise a
> flexfiles v3 layout when it's not serving v3! I'll plan to fix that
> soon.
> 
> That doesn't seem to have anything to do with commit 70b7e3526c53d9dd
> though. I'm not sure why a bisect would have landed there.
I checked and rechecked several times (and again now!) and 
70b7e3526c53d9dd always had the bug present and 565ee23ea2374 did not 
have the bug present.>
> What does the /etc/exports entry for this export look like? Disabling
> pnfs should work around this for now too if you have it explicitly
> enabled here.

The /etc/exports entry I'm using:
/home/export *(rw,no_root_squash)

I'm new to the kernel development process; is there a patch I can apply 
now to see if it fixes the bug?

Return-Path: linux-nfs-owner@vger.kernel.org
Received: from science.horizon.com ([71.41.210.146]:19547 "HELO
	science.horizon.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with SMTP id S935029Ab2JaJKU (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 31 Oct 2012 05:10:20 -0400
Date: 31 Oct 2012 05:10:18 -0400
Message-ID: <20121031091018.24875.qmail@science.horizon.com>
From: "George Spelvin" <linux@horizon.com>
To: tj@kernel.org
Subject: Re: [dm-devel] [PATCH v8 01/16] hashtable: introduce a small and naive hashtable
Cc: dm-devel@redhat.com, levinsasha928@gmail.com, linux-kernel@vger.kernel.org,
        linux-mm@kvack.org, linux-nfs@vger.kernel.org, netdev@vger.kernel.org
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Tejun Heo wrote:
>> +#define hash_min(val, bits)						\
>> +({									\
>> +	sizeof(val) <= 4 ?						\
>> +	hash_32(val, bits) :						\
>> +	hash_long(val, bits);						\
>> +})

> Also, you probably want () around at least @val.  In general,
> it's a good idea to add () around any macro argument to avoid nasty
> surprises.

Er... not in this case, you don't.  If a macro argument is passed verbatim
as an argument to a function, it doesn't need additional parens.

That's because the one guarantee you have about a macro argument is
that it can't contain any (unquoted) commas, and there's nothing lower
precedence than the comma.  So it's safe to delimit a macro argument
with *either* parens *or* a comma.

So you can go ahead and write:

#define hash_min(val, bits) \
	(sizeof(val) <= 4 ? hash_32(val, bits) : hash_long(val, bits))

... which is easier to read, anyway.

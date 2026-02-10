Received: from smtp.kernel.org (aws-us-west-2-korg-mail-1.web.codeaurora.org [10.30.226.201])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id F09EE32860E
	for <linux-nfs@vger.kernel.org>; Tue, 10 Feb 2026 17:11:00 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=10.30.226.201
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1770743461; cv=none; b=VdAQEFQjVnKbQnd+wV0vlWkHngpzMYcT6uFjgRE9MY6YJunfZ2NA8psT9/h0sM51FMOXWedJCEsZ03VXCD3jyJcIV03wTzcj1Af83oigPTt/PHlXkU3qk8HZVGEicJDa3TQLP/N3LVj46eFtz084NVXf/UgUXOkK2ZTg1wvjZLI=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1770743461; c=relaxed/simple;
	bh=h4alh0TOoFesUup6cToi2ztnt9rjScw6936k7k0+UEU=;
	h=MIME-Version:Date:From:To:Cc:Message-Id:In-Reply-To:References:
	 Subject:Content-Type; b=NHgWz80rXhyIxuqFxS8tzRbW/YU4t3yLA4Ezxo+9/IwsdV0kRcSLLQHzZ0uG/pftIX7oKT2393MRDtr7vCqAUgpIZbmqPP61qg+KClVcEq4fYyJLN9FN2wiKj+yvmuRkTGXWG9d0kJrmS0PtMAs8E4faVEFYUB+VwnZI7bAkvDo=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=hEyMWBp6; arc=none smtp.client-ip=10.30.226.201
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="hEyMWBp6"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 75F6EC4AF0B;
	Tue, 10 Feb 2026 17:11:00 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
	s=k20201202; t=1770743460;
	bh=h4alh0TOoFesUup6cToi2ztnt9rjScw6936k7k0+UEU=;
	h=Date:From:To:Cc:In-Reply-To:References:Subject:From;
	b=hEyMWBp6+NwlP6rAjhbN9/MbNJcNcSlo9KQYxnJN9O8QNHjgluA9OnEAaoFZKPZe7
	 y1UaWMlgmmv/AmQP6nXqvb9pLNAGHrKoTd129QA2toXgs5QfQA/UwkEOpJT1vkufdh
	 PXaMsk5O1utZWzll/nMiT88ENC6q8d2U2rd+R5Twp+lGimUXND4UFgU9GFlwvRUlJG
	 +dg60kMPnd8XhUyQQBi11njKyaiDu1+AuOrT97ooIWOCFDublKc4zpuXWX1RQFZzn2
	 CgqkblLYZNNv4ev9648sO9tTrWeyDTbYAovYn4nHfOxjEsfs3+dd7ybMDb01IFb/D6
	 sv08jXb/aIINQ==
Received: from phl-compute-10.internal (phl-compute-10.internal [10.202.2.50])
	by mailfauth.phl.internal (Postfix) with ESMTP id 7502DF4006B;
	Tue, 10 Feb 2026 12:10:59 -0500 (EST)
Received: from phl-imap-15 ([10.202.2.104])
  by phl-compute-10.internal (MEProxy); Tue, 10 Feb 2026 12:10:59 -0500
X-ME-Sender: <xms:o2aLaXuepjrkYPtsIvBRkZ8bKNR3HePXsv_S12k6VVO_hsoVnE4ANg>
    <xme:o2aLaTTQRkqG8dU8frzxU_VT5vw-63YVwyd6w2jSWQ4_qX_jLlay_4Y6yYj74_Vxe
    VcHa4562frpLRsyOsAys5TqnlZOyq342d8MVkBl-R31CfdRtplQ2h-J>
X-ME-Proxy-Cause: gggruggvucftvghtrhhoucdtuddrgeefgedrtddtgddvtddtvdehucetufdoteggodetrf
    dotffvucfrrhhofhhilhgvmecuhfgrshhtofgrihhlpdfurfetoffkrfgpnffqhgenuceu
    rghilhhouhhtmecufedttdenucesvcftvggtihhpihgvnhhtshculddquddttddmnecujf
    gurhepofggfffhvfevkfgjfhfutgfgsehtjeertdertddtnecuhfhrohhmpedfvehhuhgt
    khcunfgvvhgvrhdfuceotggvlheskhgvrhhnvghlrdhorhhgqeenucggtffrrghtthgvrh
    hnpefhffekffeftdfgheeiveekudeuhfdvjedvfedvueduvdegleekgeetgfduhfefleen
    ucevlhhushhtvghrufhiiigvpedtnecurfgrrhgrmhepmhgrihhlfhhrohhmpegthhhutg
    hklhgvvhgvrhdomhgvshhmthhprghuthhhphgvrhhsohhnrghlihhthidqudeifeegleel
    leehledqfedvleekgeegvdefqdgtvghlpeepkhgvrhhnvghlrdhorhhgsehfrghsthhmrg
    hilhdrtghomhdpnhgspghrtghpthhtohepuddupdhmohguvgepshhmthhpohhuthdprhgt
    phhtthhopehnvghilhessghrohifnhdrnhgrmhgvpdhrtghpthhtoheprhhitghkrdhmrg
    gtkhhlvghmsehgmhgrihhlrdgtohhmpdhrtghpthhtohepsggtohguughinhhgsehhrghm
    mhgvrhhsphgrtggvrdgtohhmpdhrtghpthhtoheprghnnhgrsehkvghrnhgvlhdrohhrgh
    dprhgtphhtthhopegvsghighhgvghrsheskhgvrhhnvghlrdhorhhgpdhrtghpthhtohep
    jhhlrgihthhonheskhgvrhhnvghlrdhorhhgpdhrtghpthhtohepthhrohhnughmhieskh
    gvrhhnvghlrdhorhhgpdhrtghpthhtoheptghhuhgtkhdrlhgvvhgvrhesohhrrggtlhgv
    rdgtohhmpdhrtghpthhtoheplhhinhhugidqtghrhihpthhosehvghgvrhdrkhgvrhhnvg
    hlrdhorhhg
X-ME-Proxy: <xmx:o2aLad0OwkVkgdc4NsNmOry-wr1f6kbMnPb87HFXHI8D6yKZPfjDgQ>
    <xmx:o2aLaf5M6CPfi3xL-lMzwI2uhKmWCxvLQ4ga8AEjPXKuGH_KsEAJpA>
    <xmx:o2aLaZQ1jgWhdSN4RIIhEw-lixK0NrmUZ_oevgx9kvT9KeDgOYSTjA>
    <xmx:o2aLaUUFzhAACBcnZ1rteSOiGb7q195ucr-d30LHT_X_Y3XurK5O2Q>
    <xmx:o2aLaeHSmjiOXQqujfSFekKLAMnsVG9xRCa9bIExn171bObcVroXKXl_>
Feedback-ID: ifa6e4810:Fastmail
Received: by mailuser.phl.internal (Postfix, from userid 501)
	id 4EEFD780075; Tue, 10 Feb 2026 12:10:59 -0500 (EST)
X-Mailer: MessagingEngine.com Webmail Interface
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
X-ThreadId: A8ayRBgwPfJg
Date: Tue, 10 Feb 2026 12:10:37 -0500
From: "Chuck Lever" <cel@kernel.org>
To: "Benjamin Coddington" <bcodding@hammerspace.com>,
 "Chuck Lever" <chuck.lever@oracle.com>
Cc: "Jeff Layton" <jlayton@kernel.org>, NeilBrown <neil@brown.name>,
 "Trond Myklebust" <trondmy@kernel.org>, "Anna Schumaker" <anna@kernel.org>,
 "Eric Biggers" <ebiggers@kernel.org>,
 "Rick Macklem" <rick.macklem@gmail.com>, linux-nfs@vger.kernel.org,
 linux-fsdevel@vger.kernel.org, linux-crypto@vger.kernel.org
Message-Id: <286dc184-336e-471e-85b4-9326dd3bdcaf@app.fastmail.com>
In-Reply-To: <8CDB950C-7FAD-493A-A69D-9F7AB0D3775F@hammerspace.com>
References: <cover.1770660136.git.bcodding@hammerspace.com>
 <c24f0ce95c5d2ec5b7855d6ab4e3f673b4f29321.1770660136.git.bcodding@hammerspace.com>
 <8574c412-31fb-4810-a675-edf72240ae29@oracle.com>
 <8CDB950C-7FAD-493A-A69D-9F7AB0D3775F@hammerspace.com>
Subject: Re: [PATCH v5 3/3] NFSD: Sign filehandles
Content-Type: text/plain
Content-Transfer-Encoding: 7bit



On Tue, Feb 10, 2026, at 11:56 AM, Benjamin Coddington wrote:
> On 9 Feb 2026, at 15:29, Chuck Lever wrote:
>> On 2/9/26 1:09 PM, Benjamin Coddington wrote:

>>> diff --git a/fs/nfsd/nfsfh.c b/fs/nfsd/nfsfh.c
>>> index 68b629fbaaeb..3bab2ad0b21f 100644
>>> --- a/fs/nfsd/nfsfh.c
>>> +++ b/fs/nfsd/nfsfh.c
>>> @@ -11,6 +11,7 @@
>>>  #include <linux/exportfs.h>
>>>
>>>  #include <linux/sunrpc/svcauth_gss.h>
>>> +#include <crypto/utils.h>
>>>  #include "nfsd.h"
>>>  #include "vfs.h"
>>>  #include "auth.h"
>>> @@ -140,6 +141,57 @@ static inline __be32 check_pseudo_root(struct dentry *dentry,
>>>  	return nfs_ok;
>>>  }
>>>
>>> +/*
>>> + * Append an 8-byte MAC to the filehandle hashed from the server's fh_key:
>>> + */
>>> +static int fh_append_mac(struct svc_fh *fhp, struct net *net)
>>> +{
>>> +	struct nfsd_net *nn = net_generic(net, nfsd_net_id);
>>> +	struct knfsd_fh *fh = &fhp->fh_handle;
>>> +	siphash_key_t *fh_key = nn->fh_key;
>>> +	__le64 hash;
>>> +
>>> +	if (!(fhp->fh_export->ex_flags & NFSEXP_SIGN_FH))
>>> +		return 0;
>>> +
>>> +	if (!fh_key) {
>>> +		pr_warn_ratelimited("NFSD: unable to sign filehandles, fh_key not set.\n");
>>> +		return -EINVAL;
>>> +	}
>>> +
>>> +	if (fh->fh_size + sizeof(hash) > fhp->fh_maxsize) {
>>> +		pr_warn_ratelimited("NFSD: unable to sign filehandles, fh_size %d would be greater"
>>> +			" than fh_maxsize %d.\n", (int)(fh->fh_size + sizeof(hash)), fhp->fh_maxsize);
>>> +		return -EINVAL;
>>> +	}
>>> +
>>> +	hash = cpu_to_le64(siphash(&fh->fh_raw, fh->fh_size, fh_key));
>>> +	memcpy(&fh->fh_raw[fh->fh_size], &hash, sizeof(hash));
>>> +	fh->fh_size += sizeof(hash);
>>> +
>>> +	return 0;
>>> +}
>>> +
>>> +/*
>>> + * Verify that the filehandle's MAC was hashed from this filehandle
>>> + * given the server's fh_key:
>>> + */
>>> +static int fh_verify_mac(struct svc_fh *fhp, struct net *net)
>>> +{
>>> +	struct nfsd_net *nn = net_generic(net, nfsd_net_id);
>>> +	struct knfsd_fh *fh = &fhp->fh_handle;
>>> +	siphash_key_t *fh_key = nn->fh_key;
>>> +	__le64 hash;
>>> +
>>> +	if (!fh_key) {
>>> +		pr_warn_ratelimited("NFSD: unable to verify signed filehandles, fh_key not set.\n");
>>> +		return -EINVAL;
>>> +	}
>>> +
>>> +	hash = cpu_to_le64(siphash(&fh->fh_raw, fh->fh_size - sizeof(hash),  fh_key));
>>> +	return crypto_memneq(&fh->fh_raw[fh->fh_size - sizeof(hash)], &hash, sizeof(hash));
>>
>> Nit: fh_verify_mac() here returns positive-on-error (crypto_memneq
>> convention) while fh_append_mac() returns negative-on-error (errno
>> convention). Would it be better if both returned bool?
>
> I'd be inclined to change the function names if they both want to return a
> bool thing, so that the functions assert a fact that can be true or false,
> rather than explain the operation.
>
> If you want them to both return a bool, then maybe prefix them with
> did_{fh_..}?
>
> For me, the semantics make sense as they are..

The requested change is more about consistency with the surrounding
source code so that maintainers have a better chance of not screwing
this up when fixing a bug.

The current function names are consistent with existing code and the
"positive return code" return value is not.


-- 
Chuck Lever

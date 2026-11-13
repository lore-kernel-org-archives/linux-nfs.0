Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=100.103.45.18
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1794580199;
	b=2aI6irMwFsCRGiXHu5eOLS4pbxlvhVso8KPmU/52qMhF3inEti9dPig2ACkFyfEGzy7w
	 n14MANYAWXdlBWapQkgfDjDctf0mo9MfTPCH8YmTsYB5ykbHtb9i0UkyqRTu+YUOQKkg3
	 dBFPqKCpsMaJDmnIaourutk1mUkF4djyVhieXcdqw5V97ZRdKHMGQSL9gymi5II2Et186
	 EogzQUiSESu5HXNtT/nUxMKam7xk8BRKJ8ygORdQqPwXLCV7Pyf1KhN+wQEBPelROl5Vi
	 92XEeeWyHzNw4QDyXnbEoRYS4r1q/J0XfBHdC+do/gMmxBoLsND4Oa7C+uad6mJPN1w==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1794580199;
	h=Received:DKIM-Signature:Received:Received:X-ME-Sender:
	 X-ME-Proxy-Cause:X-ME-Proxy:Feedback-ID:Received:X-Mailer:
	 MIME-Version:X-ThreadId:Date:From:To:Cc:Message-Id:In-Reply-To:
	 References:Subject:Content-Type:Content-Transfer-Encoding;
	bh=r44VGVXjpBZvSPH3AAkVDqbr/+AiQktps6NDmxi0hik=;
	b=0swbSZ64lKJqlmopSW4hnjBwZ16VxOSOfvKRDO6pI0U1B/Q+sl21ticlzyYbOD0ys9in
	 fe84yIW1t6yXIH6ZiazpgrBz0EWsGPx32D1SVuMUJ0qUFusYHWXz3w5Mb4TWXplnK6fcc
	 hwWZw6nswP6hHs54L23Oa+YKiKD0CB4JUn5KpoEEDuTJ9JRbr5kElKcVA8ryZj7QYgrxv
	 P3xGtljZm3j0Y9G+/tqiR5wg5G74Utv0LWJDZP42fcXzQQ68ENq8RtWD8l8bBCdKPQFHx
	 uJx7TuMTna3U74jOufoepBNd4FqyMHd54r3MXjtKFXc+CGmhJJTBc1t9i9K8jwYm8gw==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dkim=pass header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b="bW41KZL/";
	arc=none smtp.remote-ip=100.103.45.18
Received: from smtp.kernel.org (quasi.space.kernel.org [100.103.45.18])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id DDC97606A32E;
	Fri, 13 Nov 2026 14:29:59 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=bW41KZL/
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 06E681F000C5;
	Fri, 13 Nov 2026 14:29:58 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1794580199;
	bh=r44VGVXjpBZvSPH3AAkVDqbr/+AiQktps6NDmxi0hik=;
	h=Date:From:To:Cc:In-Reply-To:References:Subject;
	b=bW41KZL/XLBd60oESBbZ9PfXa//xgnu7BroEPbDMWPUA7H6dPcxf7Y5k7tUmNhGCg
	 QMP44HzSAyBRLoL/5wQw0J4WNo0IETSebAHXFxMcVJAEs1Czwfwam3yuGLonmzWBwh
	 7y18BJQJJKJtJPFNh/vkfOICCBX+5yluHpnF9/K1x/vfj5mnCXyslXtnC8+Quh0sQm
	 yc6nKVm+4V0DPluQ1CyDLoQKQ9ZR/FMlY4X1Konfk4yZ+B2f2OgDbWc3c4vZMtfixt
	 UeIUz6YDRCLSQ+6CbFn6oEAfdMqaTGOLwSbsy0vILwceuoq8+G88wGqxuu1V8rJInY
	 +PhOx4eNTYlng==
Received: from phl-compute-10.internal (phl-compute-10.internal [10.202.2.50])
	by mailfauth.phl.internal (Postfix) with ESMTP id 4ED74F40069;
	Fri, 13 Nov 2026 09:29:58 -0500 (EST)
Received: from phl-imap-15 ([10.202.2.104])
  by phl-compute-10.internal (MEProxy); Fri, 13 Nov 2026 09:29:58 -0500
X-ME-Sender: <xms:5h73ajHbLgXGptB-dLn7JolU98xqZzvOYw5qiuUWzN2H88vb2mSYCA>
    <xme:5h73arItnLhI9Lm7rBE_uEwXyrLRPez3-oCsJnuPte095JZZJGJX7SNvcpr2FPe5j
    VCKhzJvUfwORn2e4PKQZLgr6bBGF7dbq3t8atIUb5yw-OBySTQp>
X-ME-Proxy-Cause: dmFkZTE/tOQp30OUl6utnn/w64DIjqD/RRWwsaN4vYA/Um7X8Hi0+38VBMJkOTI7il1dTj
    9GDGmQ/tntw9pB4r639GENnQSS374aTm40SaYFhBJb3/rc4NqayYCYuv1cKjeuZg5ozGVy
    9jm7SGRy4mjVCAtZDk0OdyfrgbxcxBpVg14dRsf0FSl7GYPyf0jxpJ1PaglA/Ahgitf50G
    tYf1fz57lsz+ArTGdypZQerbtMPD5NCxF8t0eYyQzLLvMxL2aVj/hfqm5mTSRMEgkI7f8M
    ja5juPSxNHeEwWmT3TeN7Pc0PhZPmsRgLvOF8/1AqpMQl194E1ME6BcwdlmnUUYYVf1pOl
    f4ISQDtRi/ca9iO5bylZkJ5n1ii862vn5VxiQYK2st5/K9VvhXIWxsRjxNDQyrrzSQaIIX
    qYNHGwJdBf2n0IED9fucthumcfPCnuIFgE5bW7gcKB9i2tv1KP8j3wAivqD+M0Jb3EUUfz
    5UPyiEYvfAcy0Iq0oB8yJFdexYPJ6OHATFxTYEKvNs3dyHhXcN4cH1S15eCJSu9yQh9Pvo
    Aw2PRO9mukA+Ppx9rHF9R6ZvFgc2COflEqJVrAbgJs9LwQh2tiR7063LZB7buOUx6/inml
    cbuYc7B9acJtwWkXY4E+AwHyPl/Xc1Q4rb75SkDGZYUHQIizezNpW/19N+OQ
X-ME-Proxy: <xmx:5h73alzwDHiX-GqJeiEDrfQ4osAGX0cKV9iJhjL_T68AiBQRTwMi_w>
    <xmx:5h73ahWwQxeiluvyUOtPmRU0tBvZKrM12OZ6CAfurTRXRDl05eO8_g>
    <xmx:5h73aqrMz5qopQ5fw7RU9o095_0BPg80zPUHkwETH8klJEEm4PruSQ>
    <xmx:5h73amc9f7nbs-9G9HBwNcRIuxYjQ-0rEV4palYsrSyfjiX9oltsSQ>
    <xmx:5h73agEuLlqwQZTcPwpye9FI79QIQundgG14hhc6Npf2nRtwNxjRHBbv>
Feedback-ID: ifa6e4810:Fastmail
Received: by mailuser.phl.internal (Postfix, from userid 501)
	id 23F69780075; Fri, 13 Nov 2026 09:29:58 -0500 (EST)
X-Mailer: MessagingEngine.com Webmail Interface
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Post: <mailto:linux-nfs@vger.kernel.org>
List-Help: <mailto:linux-nfs+help@vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
List-Owner: <mailto:linux-nfs+owner@vger.kernel.org>
Precedence: list
MIME-Version: 1.0
X-ThreadId: AhoMoQ4eTUpJ
Date: Fri, 13 Nov 2026 09:29:38 -0500
From: "Chuck Lever" <cel@kernel.org>
To: "Jeff Layton" <jlayton@kernel.org>, "Jan Kara" <jack@suse.cz>,
 "Christian Brauner" <brauner@kernel.org>
Cc: linux-fsdevel@vger.kernel.org,
 "Andreas Gruenbacher" <agruenba@redhat.com>, gfs2@lists.linux.dev,
 "Mike Marshall" <hubcap@omnibond.com>,
 "Martin Brandenburg" <martin@omnibond.com>, devel@lists.orangefs.org,
 "Dave Kleikamp" <shaggy@kernel.org>, jfs-discussion@lists.sourceforge.net,
 "Carlos Maiolino" <cem@kernel.org>, linux-xfs@vger.kernel.org,
 "David Howells" <dhowells@redhat.com>,
 "Marc Dionne" <marc.dionne@auristor.com>, linux-afs@lists.infradead.org,
 "Miklos Szeredi" <miklos@szeredi.hu>, fuse-devel@lists.linux.dev,
 "linux-block@vger.kernel.org" <linux-block@vger.kernel.org>,
 linux-nfs@vger.kernel.org, "Eric Biggers" <ebiggers@kernel.org>,
 "Jaegeuk Kim" <jaegeuk@kernel.org>, linux-fscrypt@vger.kernel.org
Message-Id: <8f7083c7-2a37-4a41-8cdf-5504dd889f44@app.fastmail.com>
In-Reply-To: <bda5f50707205ff7fa55120247fec46300d420ad.camel@kernel.org>
References: <20261113083336.15152-1-jack@suse.cz>
 <20261113084700.739002-24-jack@suse.cz>
 <bda5f50707205ff7fa55120247fec46300d420ad.camel@kernel.org>
Subject: Re: [PATCH 11/13] nfsd: Use inode_or_folios_dirty() for dirtiness check in
 wait_for_concurrent_writes()
Content-Type: text/plain
Content-Transfer-Encoding: 7bit



On Fri, Nov 13, 2026, at 8:08 AM, Jeff Layton wrote:
> On Fri, 2026-11-13 at 09:47 +0100, Jan Kara wrote:
>> The check for dirtiness in wait_for_concurrent_writes() is racy because
>> I_DIRTY_PAGES flag can be temporarily cleared by
>> __writeback_single_inode(). Use inode_or_folios_dirty() helper to avoid
>> that. This also makes sure inode timestamps properly persisted when
>> lazytime is enabled.
>> 
>> Signed-off-by: Jan Kara <jack@suse.cz>
>> ---
>>  fs/nfsd/vfs.c | 2 +-
>>  1 file changed, 1 insertion(+), 1 deletion(-)
>> 
>> diff --git a/fs/nfsd/vfs.c b/fs/nfsd/vfs.c
>> index 56c49b5bc5bb..a314ca39272f 100644
>> --- a/fs/nfsd/vfs.c
>> +++ b/fs/nfsd/vfs.c
>> @@ -1249,7 +1249,7 @@ static int wait_for_concurrent_writes(struct file *file)
>>  		dprintk("nfsd: write resume %d\n", task_pid_nr(current));
>>  	}
>>  
>> -	if (inode_state_read_once(inode) & I_DIRTY) {
>> +	if (inode_or_folios_dirty(inode)) {
>>  		dprintk("nfsd: write sync %d\n", task_pid_nr(current));
>>  		err = vfs_fsync(file, 0);
>>  	}
>
> Reviewed-by: Jeff Layton <jlayton@kernel.org>

Acked-by: Chuck Lever <cel@kernel.org>

-- 
Chuck Lever (Come to NFS bake-a-thon! https://nfsv4bat.org)

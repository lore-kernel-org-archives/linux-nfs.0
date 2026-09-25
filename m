Received: from smtp.kernel.org (aws-us-west-2-korg-mail-alma10-1.taild15c8.ts.net [100.103.45.18])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 4F8983B8409;
	Fri, 25 Sep 2026 16:56:40 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=100.103.45.18
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1790355410; cv=none; b=kRluWytSxzMwjGphxkZSD9mZ1+pS/MWdYxEshMbLFKasLQziM7XipsJiGrgFfuGNbnzP+NA+NE44Zt2s+knUKhV7BqHj9EOwRyPAxPHgjqfm59lYoqGx0pJHbAsnFl9140w6oQP0EniesEwnzxJJv5F0wvriM+IGC5eXB5gPbPg=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1790355410; c=relaxed/simple;
	bh=7qiLBvkL5f31UPJ2GYjFxJoybPTdrvHnUyAGg0joyoM=;
	h=MIME-Version:Date:From:To:Cc:Message-Id:In-Reply-To:References:
	 Subject:Content-Type; b=UdWBYbHpmEIDljuUMQRh2hv1oi3Ypc/qwET2OLTaAefiuEcG+64C5SN/dwdlEhdKjItjfPRDAtWcJyNVtF9c0JUerKqm4x/ZITGJ4+xgmfSMKNDWO5Ym3LWrOHAQEqNTsALPhiamzhHUYsdXy4AWOpLyV3hRI/Of7Mlkv7IPOPY=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=V8pA+M6k; arc=none smtp.client-ip=100.103.45.18
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="V8pA+M6k"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id BDFE81F000FF;
	Fri, 25 Sep 2026 16:56:37 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1790355398;
	bh=mtySRZfOGfyzWLw3A6sR7H3wATLXpdRhprJ1nem+O74=;
	h=Date:From:To:Cc:In-Reply-To:References:Subject;
	b=V8pA+M6k1zxkZfQB1M+nOoUv3HYgZjbVNr2fbYCv7aXvqHO0WB5acEPlTMwHmbtIZ
	 OimiWtGMdAm5SUt3y+IX0sB3AAuPrrsg/0r46ajF2wg0gq1I0/C37cfeTv0fz/mTGU
	 GXljzjVn3B3lvCxRbsdnhbQEj8iGko4hCWCxIxIMNHg+8qfvzC1Yvu9l3aYc8agAev
	 lViXOPMt6DQIVf8WK5lCj+8k4pwZd4JjD8zBOiwFvHcLH6DQ9JyRv0AlMEW4FwhPAC
	 1LPh7RxQX/GxHTc4v4VIIAWSxzQuvbVZoSbzCHwO5OH4u/91U/S1QpK5/g3doiaGit
	 LZwEtb2G0YsKg==
Received: from phl-compute-10.internal (phl-compute-10.internal [10.202.2.50])
	by mailfauth.phl.internal (Postfix) with ESMTP id A42A0F40068;
	Fri, 25 Sep 2026 12:56:36 -0400 (EDT)
Received: from phl-imap-15 ([10.202.2.104])
  by phl-compute-10.internal (MEProxy); Fri, 25 Sep 2026 12:56:36 -0400
X-ME-Sender: <xms:xKe2apJq4vvrUbOoXR3IQkzHyDKbRQ8uznavo-KYiNL8UE1owhYaUg>
    <xme:xKe2av9fTWFU2q8r4aZzjbClaHJEHdJXg8TknyYREd3c9xO4GevSrnitwGSJ0mryR
    EC5RG7aPjVbGpx3VWSCuj3enJR3vaHUO-Awc-e0Bm9mMNDaIzzR0K63>
X-ME-Proxy-Cause: dmFkZTE199OACx/5ZGmQOcqgj7GgW/wDsNF2qXaQx7rypS1ySEohTniwvIoRnu5gER2JKj
    jHei6a2m+alk6AgHs9qI/Eq8KwIT3v5UEiAy68IBmy4jHPGruy8dsVjitWYF+kufX5JzFq
    m74gM6jQiYubi3n2ZgAtqt4xEHg1Yy4C43X3u5kNMhKgBPb/mUyI1qH8YjxEOJsTYqn1je
    pAbxBwWujsi++cGSB0r0HDiN6lBig4rNZ2FcnVQ9Cc10tv1HwreJysL/jxVb3XuQ7xdRkx
    82bd1agSu1Dz6G2dwAwxeP77iGevNkeQ0d7ug9SHrwJQt7RsZsYbsXaxSf7m+mVdNQhYYH
    +jyZmbkaNB67O5LquY0+PjPX3d9yxv/xVRCMtuH/V59IrJJvpgU/3QF7w8D47H78u6Le62
    qlbJjgKLrU6DFiqe0fj1kLa9XnBADaEFXsv0B/96zocPFmlGIGU5WY9A92MPUeYqt31KkF
    +jYBgO0+Bi+b/N4bXPD38LLFAgTbUMXRz1fYNmh1Z6txsRDvIesLRHO3Ct4bGo2Jy9AWup
    zPUyTPuHrrvmQfdS51tf03gvkPZ4j7idqKxXZpkGvlTquR5cZZkJRYcCayZbSKYM/CmTCm
    wX0uSqQT+IHQNSxVm18uUYHhrX1efZNtOaZevxzT0tz8Bq1GNAfjxDdE7fdA
X-ME-Proxy: <xmx:xKe2avu8gZF8WFmuy9J-LVGnIWzZaVG_i9KGEa2SNyr2Dm-V45pHxw>
    <xmx:xKe2ahyqPAOF-RbkB-Xmns0hFbRkkAh-I-yWEJ8spZ-qzEhUqmpYeg>
    <xmx:xKe2anaaqJZqbMHNQrEcnTE_WMY7QJQcM2AWnz3K5HMXttX4g_urAQ>
    <xmx:xKe2ag5wEwRUHRMy1tTQzZQg5V0p0p6k2laVPIlyxoS-QAf69UVXJA>
    <xmx:xKe2am7nAOr3eqfmtAPH7_zRNhFJX0o_0syFG1-4IuldGMvw0wbQSmoC>
Feedback-ID: ifa6e4810:Fastmail
Received: by mailuser.phl.internal (Postfix, from userid 501)
	id 6EB83780070; Fri, 25 Sep 2026 12:56:36 -0400 (EDT)
X-Mailer: MessagingEngine.com Webmail Interface
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
X-ThreadId: AeJzmHWrDZMJ
Date: Fri, 25 Sep 2026 12:56:15 -0400
From: "Chuck Lever" <cel@kernel.org>
To: "Christian Brauner" <brauner@kernel.org>, NeilBrown <neil@brown.name>
Cc: "Alexander Viro" <viro@zeniv.linux.org.uk>,
 "Jeff Layton" <jlayton@kernel.org>, "Jori Koolstra" <jkoolstra@xs4all.nl>,
 "Mateusz Guzik" <mjguzik@gmail.com>,
 "Dorjoy Chowdhury" <dorjoychy111@gmail.com>,
 "Trond Myklebust" <trondmy@kernel.org>, "Anna Schumaker" <anna@kernel.org>,
 "Andreas Gruenbacher" <agruenba@redhat.com>, gfs2@lists.linux.dev,
 "Ilya Dryomov" <idryomov@gmail.com>, "Alex Markuze" <amarkuze@redhat.com>,
 "Viacheslav Dubeyko" <slava@dubeyko.com>, ceph-devel@vger.kernel.org,
 "Paulo Alcantara" <pc@manguebit.org>, "Namjae Jeon" <linkinjeon@kernel.org>,
 linux-cifs@vger.kernel.org, linux-fsdevel@vger.kernel.org,
 linux-nfs@vger.kernel.org
Message-Id: <a59cfd65-0491-4fe8-99d4-f48576185d5a@app.fastmail.com>
In-Reply-To: <20260925-diavortrag-zueinander-komitee-6bb18933f480@brauner>
References: <20260919022441.3305170-1-neilb@ownmail.net>
 <20260925-diavortrag-zueinander-komitee-6bb18933f480@brauner>
Subject: Re: [PATCH v2 01/14] fixes for vfs_lookup_open, and integration with nfsd
Content-Type: text/plain
Content-Transfer-Encoding: 7bit



On Fri, Sep 25, 2026, at 12:04 PM, Christian Brauner wrote:
> On Sat, Sep 19, 2026 at 12:06:04PM +1000, NeilBrown wrote:
>> Greetings.
>> 
>>  NFSv4 has an "OPEN" request which combines lookup and create and
>>  truncate and permission checks etc much like the open() syscall.  When
>>  nfsd implements this, I want it to share a much code as (reasonably)
>>  possible with the open() paths - in particular I want it to use lookup_open() 
>>  and so that it uses ->atomic_open() the same way that other code does.
>>  (Longer term I want to make some locking changes and having all the code
>>  central makes that easier.)
>>  vfs_lookup_open() is a step towards that  but it isn't quite ready yet.
>>  This series aims to make it ready, then use it.
>> 
>>  A particular issue is that using __O_REGULAR exactly meets the needs of
>>  nfsd (it doesn't want to open anything else) but the errors returned by
>>  __O_REGULAR aren't what nfsd needs.  nfsd needs to know if it was a
>>  directory, or a symlink, or something else.
>> 
>>  I don't think __O_REGULAR should cause symlinks to result in -EFTYPE.
>>  If a symlink is found, then it should be followed.  That is what
>>  happens with filesystems that don't support ->atomic_open, but some
>>  ->atomic_open handlers return -EFTYPE for symlinks when __O_REGULAR is
>>  present.  I think that O_NOFOLLOW can affect how symlink are handled,
>>  but where possible it is best to just return the symlink to the caller
>>  and let it figure out what to do.
>> 
>>  For directories, nfsd wants EISDIR rather than EFTYPE.  It may be that
>>  user-space could benefit from seeing EISDIR too, but that is a separate
>>  issue.  So I want ->atomic_open to return EISDIR (if it returns an
>>  error at all) rather than EFTYPE if a directory is found.  VFS code can
>>  then map that to EFTYPE if needed.
>> 
>>  So the first few patches in this series improve the documentation for
>>  atomic_open and then make changes to nfs, gfs2, ceph, cifs to better
>>  match this documentation.  I would appreciate an Ack-by (or whatever
>>  else might be appropriate) from fs maintainers for those.
>> 
>>  Subsequent patches make changes to vfs_lookup_open() and then to nfsd
>>  to use it.
>> 
>>  A significant change here is that opening a file with
>>  O_NONBLOCK|O_CREAT will result in -EWOULDBLOCK if a delegation
>>  exists on the parent directory - currently it blocks.
>>  Jeff - could you comment on that change (07/14)?
>> 
>>  There are quite a lot of changes here since my previous post,
>>  particularly the changes to various filesystems.
>>  I've stopped trying to return the dentry from vfs_lookup_open()
>>  in the error case - no-one liked that.
>> 
>>  Thanks for your time,
>
> Neil, I'll take the vfs specific fixes onto vfs-7.4.lookup and then nfs
> can pull that all in?

There are outstanding review comments on the NFSD patches in this
series, but once those are resolved I can merge vfs-7.4.lookup
into nfsd-next and apply Neil's work.

Let me know when I can merge your topic branch.


-- 
Chuck Lever (Come to NFS bake-a-thon! https://nfsv4bat.org)

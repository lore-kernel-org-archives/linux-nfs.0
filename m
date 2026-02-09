Received: from mail-qv1-f43.google.com (mail-qv1-f43.google.com [209.85.219.43])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id B5CDF2EA156
	for <linux-nfs@vger.kernel.org>; Mon,  9 Feb 2026 09:47:07 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=pass smtp.client-ip=209.85.219.43
ARC-Seal:i=2; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1770630428; cv=pass; b=CaDnUefxG4BV1IC5zLsscQOea2nqJGHJHTD2WfTgqFtU8RiBjLHFa3RyXj6aJGC1g9IVAG2rJxc8VwnmsqeVh4E53KDumbewquKU5h6u8bMTPDpjudNKOmVpGR3RuC6xIOSx+C3YLQBSwWwNJ9S1T8QTGj395Ax3Zav2xT+iLA8=
ARC-Message-Signature:i=2; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1770630428; c=relaxed/simple;
	bh=kslYdqR/Eeds+pnHFX4dOlw3YR4a+aL+uxqVvQbwvrY=;
	h=MIME-Version:From:Date:Message-ID:Subject:To:Cc:Content-Type; b=tPugniNqC7dF0orx3RL7jCCg9n9Rp7o9GHjvwnlB0s+C+h8y8826cYHkvsBVTIURKyNAQPH95SagAfViat3HjQWME4zT6ou7XMZOE1db8eWGwXEUhl+ZNU4q+aeVNAIC5AgyzA2NsVLRXEG9Vv5foYkj0605Ahz32c8xsgentGI=
ARC-Authentication-Results:i=2; smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=szeredi.hu; spf=pass smtp.mailfrom=szeredi.hu; dkim=pass (1024-bit key) header.d=szeredi.hu header.i=@szeredi.hu header.b=dLqrVPUl; arc=pass smtp.client-ip=209.85.219.43
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=szeredi.hu
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=szeredi.hu
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (1024-bit key) header.d=szeredi.hu header.i=@szeredi.hu header.b="dLqrVPUl"
Received: by mail-qv1-f43.google.com with SMTP id 6a1803df08f44-8966bd9da41so12962866d6.2
        for <linux-nfs@vger.kernel.org>; Mon, 09 Feb 2026 01:47:07 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1770630426; cv=none;
        d=google.com; s=arc-20240605;
        b=ToctPE2kQMvH6cgoBXlezLoY5ybyrJXqXFSk3FKkEij3YAkREEcDpY/D3D16JcP1dm
         BEVDun2nDJgEdvizGxypI7q0vx5X/0bJYPrzWadX6WeZi0iNNrA0gHkRtJU+MkKeWawr
         8QjSODjd//ia+LyX8cb4ztvyzlkxiUIb/gigLwRQXO098H6YIPkGQsxUHOeo0jftirwo
         0BrNUMExey+CxufDqjj4sBgxuTBFA/GySpuMx0DNW0nkQuwjA2Jp2jdIrIwz26eZa6j2
         N349LfxONnMkJMm+eBMlbPJIZLBm+JXkXRPe9pztRRW0GaZ4EX3QVgKA4HJxHK31okiY
         GUUQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20240605;
        h=cc:to:subject:message-id:date:from:mime-version:dkim-signature;
        bh=MhbUYQBRSHqJLFTCcNvNjXM5Nu9GEAvwhrEdsxUNUHw=;
        fh=myi6+dTaTzi35er4T2NoiWCgvovdSZFsxCxxzYX/KqY=;
        b=hbIe8wuFPkHvIoC3JxHEBzpF6OqKRBUIfPN/q08oe1xjXofy8w5RJw4L6XPLiaQDo3
         WJorQ5sqs3+qNOq7cp+EC18GZLo8CXg76AFaFKzfuCfxntNQr5JFCd26OLuHuvJUxptx
         U1galLBXproB50lZy6Yu6RAsPIYs1MgnsHr2SALZrCl/yAdMQMm0U2BQp/smYN2lhqrx
         afBp0aRdp1v9qkrhKVGIlVSVQq3Z7k7WUypfIcQ1BRlcJLFS3PPFmSBFJ4I0q+LCe4wC
         UPsRwC8kEs951iJAjFbPmJ5x7tLhG1QRptvacfIXuksqJjmAkC9sQGIYbZ7xjELygYq7
         CDbw==;
        darn=vger.kernel.org
ARC-Authentication-Results: i=1; mx.google.com; arc=none
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=szeredi.hu; s=google; t=1770630426; x=1771235226; darn=vger.kernel.org;
        h=cc:to:subject:message-id:date:from:mime-version:from:to:cc:subject
         :date:message-id:reply-to;
        bh=MhbUYQBRSHqJLFTCcNvNjXM5Nu9GEAvwhrEdsxUNUHw=;
        b=dLqrVPUlgWH8s70iuf87BTLXR0c3co+h9xD4nuv93T7Xk3UtPACbeTo+5mu2YD/tf2
         MLoysDWLD5MwAAtrg5WyxovXcu+Wm6kbGFNeoWszMaMdS9LbwB31VzyazUJOVZKQsUIy
         YVzsnY7Uc8RS4cevalkd7RvfQ35FV0mFGPSQk=
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20230601; t=1770630426; x=1771235226;
        h=cc:to:subject:message-id:date:from:mime-version:x-gm-gg
         :x-gm-message-state:from:to:cc:subject:date:message-id:reply-to;
        bh=MhbUYQBRSHqJLFTCcNvNjXM5Nu9GEAvwhrEdsxUNUHw=;
        b=WJ1aavZr2in4CzEmocpam/RpYV6pJyESLcTuw2+GdbmduTmTbBwy7X6GBbSNtyd3tP
         4SNnkwgPU/MhYj2tj+LEISXunLJ2YNK8zFubDi5c08NPf5ga6noT/wi3oUy7zOJ8Brt0
         dI4ECChSMhYGz5/IFXoE/buHo0A44OUSjERrxRySaKTcvv1wZMOiCajkW+PboXp6+vC+
         7kt+28egj7ebpy+eKgQ3BIjLDq6h/SOBJgAw8TVKQscKi4Z9kUCDqIvTtQDXRhybBwHD
         c4/JgMRDjUzLMHJpuFVg+VJeGUyEh6AG5bzjDK1GecZU8SgS8elEn296rqyD0yFqeBwA
         agfQ==
X-Gm-Message-State: AOJu0YzUW7mu5Y2fxylRQd9Jtb/otUJccaroX0dQCpwpI7EfirvxZmiz
	ZYfUtP38NfPnpl6Emobak0Nm6s/qvFn7Ha0W2gwOXRkb3yPY3LplHRdfdbkIk59h8Lof9vzEwng
	9V9/pTq6xJdH8JiriJ4/u/TVVoQUq06vSPh5D28+I4Q==
X-Gm-Gg: AZuq6aJ1on9+KErVYIXIA8GA3MmISGzP45yx6q0LZkKtfnuw4WcmgD/CbwAqGV8gy4/
	DeoUCZh+IoBSt56vsrWtAYqaAqjIHqsERQ34RlCAsdxYnUumXa2fHPnqOOMP7Fl3nMZ8+z/Uiqy
	OolK4sRHKE26plNknMGu33kNgZ0aUD8pwo9w7uBMcBB2654dnKf3EroTA1WiMl4ksfCGIJZgiwN
	4Tyh8bEsPZP5JVPvQTrYIKz8hnAjPQa8FMs/9YHuhD+LGal0IO9nntn4HeYWEGwz8ye+Q==
X-Received: by 2002:a05:6214:1313:b0:894:2cb3:d11f with SMTP id
 6a1803df08f44-8953c7e4bf2mr170464966d6.18.1770630426393; Mon, 09 Feb 2026
 01:47:06 -0800 (PST)
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
From: Miklos Szeredi <miklos@szeredi.hu>
Date: Mon, 9 Feb 2026 10:46:54 +0100
X-Gm-Features: AZwV_Qjy3xnJNEFhzfsyr6-tHP122kxtgH4LciILKjduIFPXSjrwE2RS0X3s71w
Message-ID: <CAJfpegu0PrfCemFdimcvDfw6BZ2R5=kaZ=Zrt6U5T37W=mfEAw@mail.gmail.com>
Subject: [LSF/MM/BPF TOPIC] xattr caching
To: lsf-pc <lsf-pc@lists.linux-foundation.org>, linux-fsdevel@vger.kernel.org
Cc: Linux NFS list <linux-nfs@vger.kernel.org>, Jan Kara <jack@suse.cz>
Content-Type: text/plain; charset="UTF-8"

I'm looking at implementing xattr caching for fuse and wondering how to do this.

Why is there no common infrastructure?

Should we create one?

What currently exists:

- mb_cache for ext2/4.  This seems to be used for deduplicating data,
so it's no good for fuse, afaics.

- simple_xattr for tmpfs/kernfs. This looks good, except it doesn't
have a shrinker, for obvious reasons.

- nfs4_xattr_cache for nfs. I don't really understand the design
choice of separate cache tables for each inode, which seems wasteful
for the common case of just a couple of xattrs per inode(*).

Without having looked deeply at each implementation, I'd think that
combining the features of all of the above into a common utility would
make sense.

Large, multi page xattrs (which I haven't seen in the wild, but I'm
sure they are out there) should be cached similarly to file data.
Small values could be stored "inline".

Deduplication of keys, values and lists is probably also useful.

Shrinking would not be used for tmpfs and kin, just like the other caches.

Any other considerations?

Thanks,
Miklos

(*) Either a global hash table or per-inode rb-trees would be saner choices.

Received: from mail-wr1-f50.google.com (mail-wr1-f50.google.com [209.85.221.50])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 756D03DFC70
	for <linux-nfs@vger.kernel.org>; Tue, 19 May 2026 08:15:49 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=209.85.221.50
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1779178551; cv=none; b=IN2LEuvUeekfKsqYtcTWqkPa+xKxhXRxHQZrE/addf+uFBu9ui4iHxehaUTCUyIos2NlOOC1rrdQEwhwf1/HRgXMrT4A9oiBHKt4HVF6QR7RwCldMTVTWjOci5CF3eIwYyQ7L07zVhf5hFCYMG/HOfYU5ta5+4w70u6D0fjxcNA=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1779178551; c=relaxed/simple;
	bh=ukNhp2SUe+V00i+CScbinEy01SmNCkigc3dUv72ANDo=;
	h=Date:From:To:Cc:Subject:Message-ID:In-Reply-To:References:
	 MIME-Version:Content-Type; b=JaAwi87kLsuh+HqgyskMqV/5a7pttRU4nP5yEZFB4BgWmOBwjEy22F5XRdrVJAP3xs7inH24uEE3JOwfTT1+3plPe4d+dkZCnplpK2YuagQaxCfKHj8750LwnHXxh1Y+jbAHjjBFlGE4RxtBQ7Sw2KU1BpTvQVN1GULiJ5YY74Y=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=gmail.com; spf=pass smtp.mailfrom=gmail.com; dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b=WaynMlMF; arc=none smtp.client-ip=209.85.221.50
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=gmail.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=gmail.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="WaynMlMF"
Received: by mail-wr1-f50.google.com with SMTP id ffacd0b85a97d-43d75312379so2792991f8f.1
        for <linux-nfs@vger.kernel.org>; Tue, 19 May 2026 01:15:49 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20251104; t=1779178548; x=1779783348; darn=vger.kernel.org;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:subject:cc:to:from:date:from:to:cc:subject:date
         :message-id:reply-to;
        bh=Gq7q4q44H1XtbreNnGBa/qXoQQzGGv2LByvvEOVI2FM=;
        b=WaynMlMFRuGTf8CvtKr5WJkga/2vuFLI4Z9hDGY2zHP4FUL/W1w8/z5fO03EraWi0k
         zekysh4ooH3cwk8tMdVKmYd5G8IP80btK8Yhk5SHzuSCv5HNBAerLX9MSP8LjS3gkgEA
         ivAtRVU/b4BDUVFd3zZS1V8zCW41ny0gc0s0lFjZrSV1HL7nYMJ64ke1uoPlaLmv/Su2
         BXawho+iOHQkDKHzJt9a4tSgXH4Nrbp+SJ/MGjog7pHL3YzdCjdfbf165Z2OOgucdGGX
         Abh/0uCTzxumg1RP3Mk44o90cDLwgXWGWzXlrMgSOjxMdTwS8GBuDixjlSejq9c+uBO4
         46wg==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20251104; t=1779178548; x=1779783348;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:subject:cc:to:from:date:x-gm-gg:x-gm-message-state:from
         :to:cc:subject:date:message-id:reply-to;
        bh=Gq7q4q44H1XtbreNnGBa/qXoQQzGGv2LByvvEOVI2FM=;
        b=IcRmVr6bqRSNCny5XSWAmjfGzTQejqBwuP6kiwCcs/wXvJ4w8J5DQcCSvivi80UtCU
         9O6r8gWho3k+9kWU0HqdWnEOAT6BJCkhVK2ME6Zfmox46sPGB0RWS7fiHxDjSNuZnO3h
         7MMOYLM65c1z8Wome75mPlVuZV4OFabjpkvXPXZoH8YNSZ5JN+9Wctzncxhgvz+Wfruq
         OxLt4mLBu9mYCYXNI1RqjE5BzqLZdQqPmcUxFqBk6RfLXYmrlEmippDxb/tZz47m/64B
         gLwh4T9ZUG5J08rU9O6Gh/Sr0HzHJSssBlIegaVYN2L2/pCFp5jelJLVpkwvh7TM//ZE
         DdOQ==
X-Forwarded-Encrypted: i=1; AFNElJ+1O/Ld5TnrquqCGFwRSLi3D7y5LbAmqF+MEAwwL1U/5iobsvGfbBxY7LIzvCEgzt6MsDnEmuDyapg=@vger.kernel.org
X-Gm-Message-State: AOJu0Yxu3Zp0q9BJdDB9NjCxGNdzMV1Lvdl8wNvTyA91k8qaollzGN8r
	LypBVC89xpWNKXg4i83RgO+GZE4o7mKNc7TA66U4M1uyMz+R0DLCsQv+
X-Gm-Gg: Acq92OF74RzEqhx8XvzmasBsF+ZhLx+0rRlA/DhsjzfBjXSThgrL+LFb8r2pKwrAPG/
	IqEvhSMT9zCnMGfNm+3n+qPNgqu7f7OJpB0XInoi7y/Ku0wp8jmTWBMQs8N/NNieu3G+xrXDKqB
	o+QK0wjeiclvJBeBz57Z+wibWamA3vrHN1Yh97TLCS5FqC3VuxZOSimnpKfFZCVb36fOaUy1uK1
	GIAH5uOGdo4Hlh6dgBrf5LckPzinu69eVwl9/fZWqiRgn8G/9N/6fdY/QlE1Lpfg4Bqhp6CRzGm
	N/YhUYXQcCvLb/sQWOACi22bNL1kTUU8uRMGdHCWOa3ZfoPIylnk3oBaEhjlwXUGiAmCzFuyRmB
	2/1iVlmURm8qwGaX1iDSdvqMxu/Z747jNrO/a1fwz3GcIRppk2CKvb7oaxkhLQLUHH502WbrxxF
	lFr6aH58aqrVKC5d4X3WXTSLLJDj+dPT37uq/4t1l7Iab9OnMaiyIzFlj3S46yo+fx
X-Received: by 2002:a5d:4577:0:b0:450:b883:dd3c with SMTP id ffacd0b85a97d-45d9352412cmr26263969f8f.20.1779178547828;
        Tue, 19 May 2026 01:15:47 -0700 (PDT)
Received: from pumpkin (82-69-66-36.dsl.in-addr.zen.co.uk. [82.69.66.36])
        by smtp.gmail.com with ESMTPSA id ffacd0b85a97d-45e7c22d8b7sm14602897f8f.6.2026.05.19.01.15.47
        (version=TLS1_3 cipher=TLS_AES_256_GCM_SHA384 bits=256/256);
        Tue, 19 May 2026 01:15:47 -0700 (PDT)
Date: Tue, 19 May 2026 09:15:45 +0100
From: David Laight <david.laight.linux@gmail.com>
To: David Howells <dhowells@redhat.com>
Cc: Christian Brauner <christian@brauner.io>, Matthew Wilcox
 <willy@infradead.org>, Christoph Hellwig <hch@infradead.org>, Paulo
 Alcantara <pc@manguebit.org>, Jens Axboe <axboe@kernel.dk>, Leon Romanovsky
 <leon@kernel.org>, Steve French <sfrench@samba.org>, ChenXiaoSong
 <chenxiaosong@chenxiaosong.com>, Marc Dionne <marc.dionne@auristor.com>,
 Eric Van Hensbergen <ericvh@kernel.org>, Dominique Martinet
 <asmadeus@codewreck.org>, Ilya Dryomov <idryomov@gmail.com>, Trond
 Myklebust <trondmy@kernel.org>, netfs@lists.linux.dev,
 linux-afs@lists.infradead.org, linux-cifs@vger.kernel.org,
 linux-nfs@vger.kernel.org, ceph-devel@vger.kernel.org,
 v9fs@lists.linux.dev, linux-erofs@lists.ozlabs.org,
 linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org
Subject: Re: [PATCH v2 00/21] netfs: Keep track of folios in a segmented
 bio_vec[] chain
Message-ID: <20260519091545.171c4b85@pumpkin>
In-Reply-To: <20260518222959.488126-1-dhowells@redhat.com>
References: <20260518222959.488126-1-dhowells@redhat.com>
X-Mailer: Claws Mail 4.1.1 (GTK 3.24.38; arm-unknown-linux-gnueabihf)
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit

On Mon, 18 May 2026 23:29:32 +0100
David Howells <dhowells@redhat.com> wrote:

> Hi Christian,
> 
> Could you add these patches to the VFS tree for next?
> 
> The patches get rid of folio_queue, rolling_buffer and ITER_FOLIOQ,
> replacing the folio queue construct used to manage buffers in netfslib with
> one based around a segmented chain of bio_vec arrays instead.  There are
> three main aims here:
> 
>  (1) The kernel file I/O subsystem seems to be moving towards consolidating
>      on the use of bio_vec arrays, so embrace this by moving netfslib to
>      keep track of its buffers for buffered I/O in bio_vec[] form.
> 
>  (2) Netfslib already uses a bio_vec[] to handle unbuffered/DIO, so the
>      number of different buffering schemes used can be reduced to just a
>      single one.
> 
>  (3) Always send an entire filesystem RPC request message to a TCP socket
>      with single kernel_sendmsg() call as this is faster, more efficient
>      and doesn't require the use of corking as it puts the entire
>      transmission loop inside of a single tcp_sendmsg().
> 
> For the replacement of folio_queue, a segmented chain of bio_vec arrays
> rather than a single monolithic array is provided:
> 
> 	struct bvecq {
> 		struct bvecq		*next;
> 		struct bvecq		*prev;
> 		unsigned long long	fpos;
> 		refcount_t		ref;
> 		u32			priv;
> 		u16			nr_segs;
> 		u16			max_segs;
> 		enum bvecq_mem		mem_type:2;
> 		bool			inline_bv:1;
> 		bool			discontig:1;

There doesn't seem to be any point using bitfields.
There is a massive hole here anyway.

> 		struct bio_vec		*bv;
> 		struct bio_vec		__bv[];
> 	};
> 
> The fields are:
> 
>  (1) next, prev - Link segments together in a list.  I want this to be
>      NULL-terminated linear rather than circular to make it possible to
>      arbitrarily glue bits on the front.

Do you ever need to follow the list backwards?
If not making prev point to the pointer to the entry (probably a tailq?)
makes the logic simpler (and safer) because you can remove an item without
knowing whether it is the head or which list it is on.

> 
>  (2) fpos, discontig - Note the current file position of the first byte of
>      the segment; all the bio_vecs in ->bv[] must be contiguous in the file
>      space.  The fpos can be used to find the folio by file position rather
>      then from the info in the bio_vec.

Should fpos be off_t (or u64) rather than 'long long' (they are all the
same underlying type).

>      If there's a discontiguity, this should break over into a new bvecq
>      segment with the discontig flag set (though this is redundant if you
>      keep track of the file position).  Note that the beginning and end
>      file positions in a segment need not be aligned to any filesystem
>      block size.

At this point you lose me :-)

-- David

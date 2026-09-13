Received: from us-smtp-delivery-124.mimecast.com (us-smtp-delivery-124.mimecast.com [170.10.129.124])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id A844B3016F5
	for <linux-nfs@vger.kernel.org>; Sun, 13 Sep 2026 03:47:37 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=170.10.129.124
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1789271259; cv=none; b=aJgm6w91CC1CjWipfRssm8uusUXFYgygOozy80D0kMuxspvxx2J9CUP970BC83iyb7Xms/uoRxDODlc7+eQUEMhYSWEm6MyWO1s3aeUkRgD8duJ4AZFaPkDoxChE9rennrzu+GlQceiPPHhyRfs2JDpl0vL62NwEpsJnWCSz1eE=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1789271259; c=relaxed/simple;
	bh=FZ5P57mheenGExd1yxhqqQdOsLpeBLxbWlOxjD7FAds=;
	h=Message-ID:Date:MIME-Version:Subject:To:Cc:References:From:
	 In-Reply-To:Content-Type; b=AW9WOD9CGT3PXvqrln/sM7vpLwKjA0wWATSjW7E7WCB/efBjTwYhYilMFFFz6Whozk88EPi14C3erl99Cc1rBKiwR+SMA4MbPuB8CqfxvrawJZDJRu21dAr+P92nMIDWn5qf39KIhD2FIKUIWvxjmNs7aJN+v+1xJR01WiMrx5k=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=redhat.com; spf=pass smtp.mailfrom=redhat.com; dkim=pass (1024-bit key) header.d=redhat.com header.i=@redhat.com header.b=DnRCFlrV; dkim=pass (2048-bit key) header.d=redhat.com header.i=@redhat.com header.b=UDSbg4XQ; arc=none smtp.client-ip=170.10.129.124
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=redhat.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=redhat.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (1024-bit key) header.d=redhat.com header.i=@redhat.com header.b="DnRCFlrV";
	dkim=pass (2048-bit key) header.d=redhat.com header.i=@redhat.com header.b="UDSbg4XQ"
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=redhat.com;
	s=mimecast20190719; t=1789271256;
	h=from:from:reply-to:subject:subject:date:date:message-id:message-id:
	 to:to:cc:cc:mime-version:mime-version:content-type:content-type:
	 content-transfer-encoding:content-transfer-encoding:
	 in-reply-to:in-reply-to:references:references;
	bh=C8F42YVVcKlU9z6QhRa60rhSkrM5LDKh8dQ8JhN+bO4=;
	b=DnRCFlrV882WvoCUIlSH/AKQJIdzWiQMbpyK0M6l7bYvlKF//ZjOXAUU0BCywV8eXuI9xB
	AsAJeNpQjlAcUjQy9JBBCLcnF2M45vVo4JCWZA9auqpcLG3hMxPPSXMjx+13f3B7jPn/vl
	zZ4stc2/0mR7aVn/0yXQd7srQols35Q=
Received: from mail-qt1-f200.google.com (mail-qt1-f200.google.com
 [209.85.160.200]) by relay.mimecast.com with ESMTP with STARTTLS
 (version=TLSv1.3, cipher=TLS_AES_256_GCM_SHA384) id
 us-mta-257-uy9vsS-yPrWQP3774XPBRA-1; Sat, 12 Sep 2026 23:47:34 -0400
X-MC-Unique: uy9vsS-yPrWQP3774XPBRA-1
X-Mimecast-MFC-AGG-ID: uy9vsS-yPrWQP3774XPBRA_1789271254
Received: by mail-qt1-f200.google.com with SMTP id d75a77b69052e-5304f2b5946so44763451cf.3
        for <linux-nfs@vger.kernel.org>; Sat, 12 Sep 2026 20:47:34 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=redhat.com; s=google; t=1789271254; x=1789876054; darn=vger.kernel.org;
        h=content-transfer-encoding:content-type:in-reply-to:from
         :content-language:references:cc:to:subject:user-agent:mime-version
         :date:message-id:from:to:cc:subject:date:message-id:reply-to
         :content-type;
        bh=C8F42YVVcKlU9z6QhRa60rhSkrM5LDKh8dQ8JhN+bO4=;
        b=UDSbg4XQzaD4UutFzw+53q9pmT3nWIMPKGGtezJlOwzCiEPNYwEYGlKKuxX2X+KPD0
         JrfU0CuWRHQ2e1CbHG/4bb+mltEzx+aLkGM3dJvjSg1b1/+VUvyEFF9oaFqPMfxM4cwW
         ARxffDBcN1qelY+4fPd3L+P9qCDdyOepRzUcEYz2BR3r/eU0uj9tD+GANxyk0bPGMqHp
         fKa6qwwq2f3BY6wpq57LY4vRXhxieJP/KqAKQz178G07yVsfrn1vwC9E6PkqsGOlxhYN
         Fokf2agmfdhxtsu/XUV9V685rNA7M5ITDHOQwHHIFm51H9o7/oWCHCS4ZZwfFZporsAA
         ha9A==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20251104; t=1789271254; x=1789876054;
        h=content-transfer-encoding:content-type:in-reply-to:from
         :content-language:references:cc:to:subject:user-agent:mime-version
         :date:message-id:x-gm-gg:x-gm-message-state:from:to:cc:subject:date
         :message-id:reply-to:content-type;
        bh=C8F42YVVcKlU9z6QhRa60rhSkrM5LDKh8dQ8JhN+bO4=;
        b=RcrNA6f39JR/y35AS211aQqO5txWLKprnbH6fpf/f51+xb2tIc5WpXe7zpUENvp8JS
         Go642xT4TQWB6hoROJWNePKXCjvDW0SS+K5soIRsgdfttD3PxxOlqLgmEOr0jyvwBRA1
         +KiUtLFy4q0Ww/bOd77+S4cTQFk7/ZVymeqjcOiVv0ETICaRlfnqVRTuYE5kqRXRjHIe
         7lkyjFcyQorQpC0BSYvQJYV+pmLNZmhVTfvQ6VYeGCmoEoNs7POnrJdziqPx+5Y9JxPL
         TPNhnZGG7xtIlhBw8Z8c/8lgg5I4YmzPPLnfyPX01AEs5Hri3/0XDoOQ+lyU0FOoaIcj
         uFvQ==
X-Gm-Message-State: AFuF++lNwYQXJ/FMVnZ6V+HIPfWpm1MI7ajBwPht3GPzAHmUIhtbTl6E
	f+6UyVuYQac7+pJE5WZUEot79vQy2N6WihCHcfhcB3pmJKsuAer5jauOng0b/1XEz4dOlMOFHiw
	4OvdC07OuhyoWrzgelfMtWrxBCOPuxeXO0+vM1eRPy6zvRzI0IqXOX9E4sRmuND6vHCR12g==
X-Gm-Gg: AYBFou1K04mWubBEPYxHOtvS/hpTxXAx/rOlFRi61ZogcpX1Yi8w2hrXkU/cFLJ19x5
	ZrZoDTK4gIMeCl0rc6zr8ogRBsNBg+kA/+mLePa5+bs2OtaEbmhs9+nM70Yccw/ILSZFsX5DuS5
	B1+Lcn3jzwj5l2IDg//jIMdnE54m3OX9k2Y5HZ/Li2TwtgX9mKrqdg6/gfZuwl+KxhYqU7/7WM6
	GweJ7P25B1ctaQSSSdOQpg5u9wE5bfhbIo/LDwFamhS51Ov4vk91FKmCzrCCntHnGtxiYUQbooL
	t4pjaGOzDaU0VuUpBwR9r6cqdIjHxNzvbLLQs27uNebuMMV4RQwJMkXkmPM0tVw+WmQu50kR2js
	=
X-Received: by 2002:a05:622a:1c0e:b0:530:f84c:efc7 with SMTP id d75a77b69052e-530f84cfebbmr32873281cf.25.1789271254307;
        Sat, 12 Sep 2026 20:47:34 -0700 (PDT)
X-Received: by 2002:a05:622a:1c0e:b0:530:f84c:efc7 with SMTP id d75a77b69052e-530f84cfebbmr32873081cf.25.1789271253860;
        Sat, 12 Sep 2026 20:47:33 -0700 (PDT)
Received: from [172.31.1.12] ([70.105.247.246])
        by smtp.gmail.com with ESMTPSA id 6a1803df08f44-9120f2032d4sm60952136d6.5.2026.09.12.20.47.32
        (version=TLS1_3 cipher=TLS_AES_128_GCM_SHA256 bits=128/128);
        Sat, 12 Sep 2026 20:47:33 -0700 (PDT)
Message-ID: <8fb9c70b-bb77-4dd5-8939-6116eb99ec25@redhat.com>
Date: Sat, 12 Sep 2026 23:47:24 -0400
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
User-Agent: Mozilla Thunderbird
Subject: Re: [PATCH 1/1] fsidd: require root credentials on abstract socket
To: Olga Kornievskaia <okorniev@redhat.com>
Cc: linux-nfs@vger.kernel.org
References: <20260907011328.21425-1-okorniev@redhat.com>
Content-Language: en-US
From: Steve Dickson <steved@redhat.com>
In-Reply-To: <20260907011328.21425-1-okorniev@redhat.com>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 8bit



On 9/6/26 9:13 PM, Olga Kornievskaia wrote:
> fsidd listens on an abstract UNIX domain socket which has no
> filesystem-level access control.  Any local unprivileged user can
> connect and issue mutating commands (get_or_create_fsidnum) that
> grow the reexport database without limit, degrading mountd
> performance.
> 
> Add a SO_PEERCRED check to reject connections from non-root
> clients.  The only legitimate client is mountd, which runs as root.
> 
> Fixes: 6fd2732d ("export: Add fsidd")
> Signed-off-by: Olga Kornievskaia <okorniev@redhat.com>
> ---
>   support/reexport/fsidd.c | 9 +++++++++
>   1 file changed, 9 insertions(+)
> 
> diff --git a/support/reexport/fsidd.c b/support/reexport/fsidd.c
> index 9b80b451..c714386e 100644
> --- a/support/reexport/fsidd.c
> +++ b/support/reexport/fsidd.c
> @@ -7,6 +7,7 @@
>   #include <dlfcn.h>
>   #endif
>   #include <event2/event.h>
> +#include <sys/socket.h>
>   #include <sys/un.h>
>   #include <unistd.h>
>   
> @@ -147,6 +148,8 @@ static void srv_cb(evutil_socket_t fd, short ev, void *d)
>   {
>   	int cl = accept4(fd, NULL, NULL, SOCK_NONBLOCK);
>   	struct event *client_ev;
> +	struct ucred cred;
> +	socklen_t clen = sizeof(cred);
>   
>   	if (cl == -1) {
>   		if (errno == EMFILE || errno == ENFILE || errno == ENOMEM ||
> @@ -162,6 +165,12 @@ static void srv_cb(evutil_socket_t fd, short ev, void *d)
>   	(void)ev;
>   	(void)d;
>   
> +	if (getsockopt(cl, SOL_SOCKET, SO_PEERCRED, &cred, &clen) < 0 ||
> +	    cred.uid != 0) {
> +		close(cl);
> +		return;
> +	}
> +
>   	client_ev = event_new(evbase, cl, EV_READ | EV_PERSIST | EV_CLOSED, client_cb, event_self_cbarg());
>   	if (!client_ev || event_add(client_ev, NULL) == -1) {
>   		if (client_ev)
This didn't apply cleanly... so I'll deal with it with some other
upcoming fsidd patches

steved.


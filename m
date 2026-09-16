Received: from us-smtp-delivery-124.mimecast.com (us-smtp-delivery-124.mimecast.com [170.10.133.124])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 08C6F3DB32B
	for <linux-nfs@vger.kernel.org>; Wed, 16 Sep 2026 14:12:57 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=170.10.133.124
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1789567979; cv=none; b=JNzMPSD5av1vGOUEBKhF+IdzGbBMQedy8r19rNFoQqvoVHLs2PoyNgB9qkqvwpqoHMXrhF+erk/g0ebzjsy3ubBnvrLJfWdn1DDFDys0RECLfx4KR21kQYxOSLsj2ACbU5nCKo9nBQvMIU5OKXyFIxzBE004bQFw1VkCd/TGfqY=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1789567979; c=relaxed/simple;
	bh=QLI3+/YXDTJSQHGYWBEVb+2A8B4k70AWsBdFM4e2+eM=;
	h=Message-ID:Date:MIME-Version:Subject:To:Cc:References:From:
	 In-Reply-To:Content-Type; b=oHRN4NTjgchkJOtfr1VSyOX08jY9ndmTXpdvDYyooxQRe4qumroSoi/u4rHTB+FNvphsrLoCtSrC5EOdE0kOUKe81i5hE0M/6Uw2TvFTtYQKRiCvwBtVnsvbnMxVfvNnq1ossfwrQP4KfhW7m+yscrQ3eO5NSaAU0UYqEVghiwc=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=redhat.com; spf=pass smtp.mailfrom=redhat.com; dkim=pass (1024-bit key) header.d=redhat.com header.i=@redhat.com header.b=eNL/rvex; dkim=pass (2048-bit key) header.d=redhat.com header.i=@redhat.com header.b=iCLOMdQG; arc=none smtp.client-ip=170.10.133.124
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=redhat.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=redhat.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (1024-bit key) header.d=redhat.com header.i=@redhat.com header.b="eNL/rvex";
	dkim=pass (2048-bit key) header.d=redhat.com header.i=@redhat.com header.b="iCLOMdQG"
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=redhat.com;
	s=mimecast20190719; t=1789567976;
	h=from:from:reply-to:subject:subject:date:date:message-id:message-id:
	 to:to:cc:cc:mime-version:mime-version:content-type:content-type:
	 content-transfer-encoding:content-transfer-encoding:
	 in-reply-to:in-reply-to:references:references;
	bh=HKMC9K9WchZnjKVCKkfZah9xzckI06/K1UacMsoA+f8=;
	b=eNL/rvexDkdSXxEE0snOqrO1B64rzWvWmKAJZdH3P4LDYEhBfZghCJZwbCWGA7kkcuK9iH
	kN1sJrnTKPAhmdV1NvZO8os3iipA1oNrJAoGYKUJDYtBSavNU0+N0bEa84X8twRxJdutL9
	uTxqMd6XNWpue7MkA2/2cg5A36zti5M=
Received: from mail-lf1-f69.google.com (mail-lf1-f69.google.com
 [209.85.167.69]) by relay.mimecast.com with ESMTP with STARTTLS
 (version=TLSv1.3, cipher=TLS_AES_256_GCM_SHA384) id
 us-mta-446-4gf82QxON0ajjRp3E_Vpuw-1; Wed, 16 Sep 2026 10:12:55 -0400
X-MC-Unique: 4gf82QxON0ajjRp3E_Vpuw-1
X-Mimecast-MFC-AGG-ID: 4gf82QxON0ajjRp3E_Vpuw_1789567974
Received: by mail-lf1-f69.google.com with SMTP id 2adb3069b0e04-5b14d51dae1so193600e87.3
        for <linux-nfs@vger.kernel.org>; Wed, 16 Sep 2026 07:12:55 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=redhat.com; s=google; t=1789567974; x=1790172774; darn=vger.kernel.org;
        h=content-transfer-encoding:content-type:in-reply-to:from
         :content-language:references:cc:to:subject:user-agent:mime-version
         :date:message-id:from:to:cc:subject:date:message-id:reply-to
         :content-type;
        bh=HKMC9K9WchZnjKVCKkfZah9xzckI06/K1UacMsoA+f8=;
        b=iCLOMdQG+GWJR1ibzSc23DJ2C5GzX3sILDHbW4Ak5HKgjaLZaXRp6t4BSkh3SUrnxV
         47EB8xtZGFD75Squ4EPecQ5K7onTGZX1WDEnfplUXIAh+d1F2d1gQ1JHoT+3jB7+dWVL
         mo++CpweIYUWeQLoPFg9TX4gSl50/RqBmZlRvbmJI5kbpEZqjww1uvL4FuII4PhNoKXn
         3SfqEJAmP62mgqMH16rqVAsA6VgJ7lpzJ61B33u3B3PyEkEzz1I/mxFEKszoE6rcMATO
         DxZYa27iV53it3gZKvXbeAvV6Y5qN1KmOAM3HNvphkWT6mJaOEgcYnUkvnTMVpe0KLAe
         pCoQ==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20260707; t=1789567974; x=1790172774;
        h=content-transfer-encoding:content-type:in-reply-to:from
         :content-language:references:cc:to:subject:user-agent:mime-version
         :date:message-id:x-gm-gg:x-gm-message-state:from:to:cc:subject:date
         :message-id:reply-to:content-type;
        bh=HKMC9K9WchZnjKVCKkfZah9xzckI06/K1UacMsoA+f8=;
        b=wg0lCfuwxOiQXbWV/l6OVPtWmicC+z8P/EEhDMEL1u56pQVASi7D3eI4Gx89qxz4+n
         G+wgY2j9klBtIIsk8g++jPszDJshk2xPRwEzGU5197OopYGCcrg6Luv5daYSR6GR3IMv
         jb6t0p9ljoZOg60ExyYytua8VPKDqPI9+TrV8sqQ4960iWiN4s76zZ00RHUYOke86LQe
         4iVgpX9rvQKhOHF1Mx7HYKcvL3OToACfm34axrYFQZWV0Lph/ng8R+lJesWCF6quvw6W
         4+vDdk+UaLMTCUNsJSGuIFJ0q4mHECddjnI0dwYi9WAZvPDp2EZVkHMEZTxDxcoiSP4x
         iwwg==
X-Gm-Message-State: AFuF++nch6wqFms/hP7uSv902yvfSRMgGJBeasTZyq9KZsj0/SY4Dn2x
	xUZzmoMkFVFa80asVbIw1i1I3lrZVE8k7ws0E2IsnMzpxekVyifvvPuiw8h0UOgGXYzEqCNOdMF
	cEBlqLYdL6E1D/Q84TajJ+etXgJiPFfUzdgcik8dCyOzaYYwWpHNoVPVRtbPSqTxBl/MVYg==
X-Gm-Gg: AYBFou0qmuv94iEiDyObB3l5pMVrQOgVQuHMqp2hPZgtPUJFupteq93V32LJszMGwC2
	bINmvaecwSut6u18C2d+IrNXBfGQRk1rpbi2mUOagc2TSLU5OPhFEDVVmhUk+q9VnEBSeFnsQWf
	9JdU62nkY2IKlvPBxcKmxw2KWPMVEB3Y0yw3vci+/YOBqx9QQHYxkrnlxNnhbu9w31h8zDFpsMJ
	gGpefUAHR/VwIZv/y84rk7XqhQd+TeYqKzT8I6s0QBC+2oxcU53wcMD3ZUR5RSPgdWQSBcm4Ugg
	iLUIQ+kr2Ymn1rvmF/Vhkm6DjvlQgJbehofNVHUrXy0hYW45J6BVLRwgYg+DjO25KbdLtBYLRXM
	=
X-Received: by 2002:a05:6512:31ca:b0:5ae:b260:cf47 with SMTP id 2adb3069b0e04-5b8b660acbamr940655e87.10.1789567973899;
        Wed, 16 Sep 2026 07:12:53 -0700 (PDT)
X-Received: by 2002:a05:6512:31ca:b0:5ae:b260:cf47 with SMTP id 2adb3069b0e04-5b8b660acbamr940638e87.10.1789567973376;
        Wed, 16 Sep 2026 07:12:53 -0700 (PDT)
Received: from [172.31.1.12] ([70.105.240.249])
        by smtp.gmail.com with ESMTPSA id 2adb3069b0e04-5b8b57cc66fsm940116e87.37.2026.09.16.07.12.51
        (version=TLS1_3 cipher=TLS_AES_128_GCM_SHA256 bits=128/128);
        Wed, 16 Sep 2026 07:12:51 -0700 (PDT)
Message-ID: <81042e14-5c1d-480f-ab5b-6af1ea1d0f90@redhat.com>
Date: Wed, 16 Sep 2026 10:12:50 -0400
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
User-Agent: Mozilla Thunderbird
Subject: Re: [nfs-utils PATCH] fsidd: handle accept4() failures before
 creating client event
To: Scott Mayhew <smayhew@redhat.com>
Cc: linux-nfs@vger.kernel.org
References: <20260903175027.1213868-1-smayhew@redhat.com>
Content-Language: en-US
From: Steve Dickson <steved@redhat.com>
In-Reply-To: <20260903175027.1213868-1-smayhew@redhat.com>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit



On 9/3/26 1:50 PM, Scott Mayhew wrote:
> Handle failures from accept4() before creating a client event,
> and add a short backoff on errors indicating resource exhaustion.
> 
> Signed-off-by: Scott Mayhew <smayhew@redhat.com>
Committed... (tag: nfs-utils-2-9-3-rc4)

steved.
> ---
>   support/reexport/fsidd.c | 28 ++++++++++++++++++++++++++--
>   1 file changed, 26 insertions(+), 2 deletions(-)
> 
> diff --git a/support/reexport/fsidd.c b/support/reexport/fsidd.c
> index 51750ea3..9b80b451 100644
> --- a/support/reexport/fsidd.c
> +++ b/support/reexport/fsidd.c
> @@ -17,6 +17,7 @@
>   #include "xlog.h"
>   
>   static struct event_base *evbase;
> +static struct event *srv_ev;
>   static struct reexpdb_backend_plugin *dbbackend = &sqlite_plug_ops;
>   
>   /* assert_safe() always evalutes it argument, as it might have
> @@ -133,21 +134,44 @@ static void client_cb(evutil_socket_t cl, short ev, void *d)
>   	}
>   }
>   
> +static void srv_reenable_cb(evutil_socket_t fd, short ev, void *d)
> +{
> +	(void)fd;
> +	(void)ev;
> +	(void)d;
> +	if (srv_ev)
> +		event_add(srv_ev, NULL);
> +}
> +
>   static void srv_cb(evutil_socket_t fd, short ev, void *d)
>   {
>   	int cl = accept4(fd, NULL, NULL, SOCK_NONBLOCK);
>   	struct event *client_ev;
> +
> +	if (cl == -1) {
> +		if (errno == EMFILE || errno == ENFILE || errno == ENOMEM ||
> +				errno == ENOBUFS) {
> +			struct timeval tv = {0, 200000};
> +			event_del(srv_ev);
> +			event_base_once(evbase, -1, EV_TIMEOUT, srv_reenable_cb,
> +					NULL, &tv);
> +		}
> +		return;
> +	}
>   	
>   	(void)ev;
>   	(void)d;
>   
>   	client_ev = event_new(evbase, cl, EV_READ | EV_PERSIST | EV_CLOSED, client_cb, event_self_cbarg());
> -	event_add(client_ev, NULL);
> +	if (!client_ev || event_add(client_ev, NULL) == -1) {
> +		if (client_ev)
> +			event_free(client_ev);
> +		close(cl);
> +	}
>   }
>   
>   int main(void)
>   {
> -	struct event *srv_ev;
>   	struct sockaddr_un addr;
>   	socklen_t addr_len;
>   	char *sock_file;


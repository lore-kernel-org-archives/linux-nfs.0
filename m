Received: from us-smtp-delivery-124.mimecast.com (us-smtp-delivery-124.mimecast.com [170.10.129.124])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 87A244908DD
	for <linux-nfs@vger.kernel.org>; Wed, 16 Sep 2026 21:57:07 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=170.10.129.124
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1789595835; cv=none; b=cu5uMh7JQBOxp8dK6ulFehuPF82rCA2vESQ2CSwzzeVcCXKiT2HeawVCS+GOMcaXBQXpwC0lWZoO1tD7ppYlUYfKzoK7JlG/SeLUCzRQ9UpIAMXdQuC9/5SXmdxJbxmHrIHf2WlZXr+eEwTWW4EOOp3LEMfRg3m3/kY0OxejWbg=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1789595835; c=relaxed/simple;
	bh=lF3fJnmhX5/lWGdKl41mUAYmZQJT+JDKcA9E7B9Yz4Q=;
	h=Message-ID:Date:MIME-Version:Subject:To:Cc:References:From:
	 In-Reply-To:Content-Type; b=X26UW6MKgp03qx+hTZl7cR+q7Z990YTcXezDYPuwmYehJS4fEbaH19FiPqmdPBVBk9eB3HzPx0OXa8We5+torjBlTwNVjrRrIe7ro6wWjFEDtgtpmXrbRJb61BIcF7we682oAF4gRTYccPPYGWcRHAj2WMDRsrNhRc1n/FGsFP4=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=redhat.com; spf=pass smtp.mailfrom=redhat.com; dkim=pass (1024-bit key) header.d=redhat.com header.i=@redhat.com header.b=gH0s9nUQ; dkim=pass (2048-bit key) header.d=redhat.com header.i=@redhat.com header.b=rYIZ53wJ; arc=none smtp.client-ip=170.10.129.124
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=redhat.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=redhat.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (1024-bit key) header.d=redhat.com header.i=@redhat.com header.b="gH0s9nUQ";
	dkim=pass (2048-bit key) header.d=redhat.com header.i=@redhat.com header.b="rYIZ53wJ"
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=redhat.com;
	s=mimecast20190719; t=1789595823;
	h=from:from:reply-to:subject:subject:date:date:message-id:message-id:
	 to:to:cc:cc:mime-version:mime-version:content-type:content-type:
	 content-transfer-encoding:content-transfer-encoding:
	 in-reply-to:in-reply-to:references:references;
	bh=ualMY5kU0x74npuEboXu7JQBk8XI1T+X5ASxMQ+oFvs=;
	b=gH0s9nUQw34zJ0gLTUR+C0BMs5ArAIa97bKYA0bN92ngouoVg8V5DaLjXDBeAyBB80WKFm
	4oReMf4/QnOFEDjyO1tLtyekvaooAPLDqJM0AGucs72LbXPcoPXxAg7Xhggir7YpeP1klR
	18G7U1UsqS4QT4f6j6Fn1ygv6PSrvX0=
Received: from mail-qk1-f197.google.com (mail-qk1-f197.google.com
 [209.85.222.197]) by relay.mimecast.com with ESMTP with STARTTLS
 (version=TLSv1.3, cipher=TLS_AES_256_GCM_SHA384) id
 us-mta-645-f9C_g7buNqCJcoPjs3hAHA-1; Wed, 16 Sep 2026 17:57:02 -0400
X-MC-Unique: f9C_g7buNqCJcoPjs3hAHA-1
X-Mimecast-MFC-AGG-ID: f9C_g7buNqCJcoPjs3hAHA_1789595822
Received: by mail-qk1-f197.google.com with SMTP id af79cd13be357-93a05d645acso30820885a.2
        for <linux-nfs@vger.kernel.org>; Wed, 16 Sep 2026 14:57:02 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=redhat.com; s=google; t=1789595822; x=1790200622; darn=vger.kernel.org;
        h=content-transfer-encoding:content-type:in-reply-to:from
         :content-language:references:cc:to:subject:user-agent:mime-version
         :date:message-id:from:to:cc:subject:date:message-id:reply-to
         :content-type;
        bh=ualMY5kU0x74npuEboXu7JQBk8XI1T+X5ASxMQ+oFvs=;
        b=rYIZ53wJshloV3tQDsASbT3j8hYEoCM+CoQrdeYysJWiDVhqeiGCLxkQPe3ajom14U
         saDswf65totpKZwjMVJkTVfmbUu437XIyijRfK0WhcZzZq2nxl4TVGumB4395i8uj6gu
         fi0rzCS+e7rK2QPqhGr/Btpa2T5rxGELDL6noh/biHgk+cw3DoKmrZkq9YZZ4V9jkj+Y
         zSvdJXYZVW/AviHAxLRTA8iA64z3yu9yKBR5aBmtKNJDcIhesEmn9S7Y7OR+oCvaJVT1
         0peU7QIopgYme36yI/v9JiETpvKEyBdcbxThdypD/g7Ic3kzkfoygKWIhIj7q22cgo+U
         8WYA==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20260707; t=1789595822; x=1790200622;
        h=content-transfer-encoding:content-type:in-reply-to:from
         :content-language:references:cc:to:subject:user-agent:mime-version
         :date:message-id:x-gm-gg:x-gm-message-state:from:to:cc:subject:date
         :message-id:reply-to:content-type;
        bh=ualMY5kU0x74npuEboXu7JQBk8XI1T+X5ASxMQ+oFvs=;
        b=oqVmCSLbF+OLNrScnvbw/SjNfu6L95x689w7OIF/0yZV8R298dvtD2EvzOltmfGq1O
         4jsxbG1nUsxxvHXmDWfufnfabSMeRW7uxYIcjudB515oBn6flmfRbSvEM/VwfU24B8E5
         SJ9yAUUlHbbSzNsVTkf/N9W34vq96ro/4e5zZhgqD91Mozrz5A9p1ca6Z3dkZJU0ZwaL
         5eWyNzclpT/xWqLWVuH5TdopJ7TatiQvV6JYfPPqPcYtxsfI813D22Mu0OpcuFqVLZ/Q
         SH74mTp00b69DRsggvaNjfZtoPF7F8JTt2pPko7txAoXBJeQXd74mQL97H6OSOEzZXEu
         S2HA==
X-Gm-Message-State: AFuF++mtyJ40NtFIgYtO2Ov5C0iVgEa4XQFY0Z4R4Dov0eELfU0cdoDo
	FO8TgsBuUxt817GBvkl+fR9/lDYgsQhPHv8L8L7jV8TrsdyLxvyrgPX7lV4xt0+cP2Ba7VhGY73
	dWCTIl6FwlE2GZyi//EOfnyXvTpRvbBFC1kbsBSYzCkeh3bWwCPNdRBokj8HB+w==
X-Gm-Gg: AYBFou2EEZX0Dp1dKB8/gBkztILN5CnquiVF61NItYxXZHAVpF8L+ynJ+26zq9951hm
	o/KMzd7EAVvQvE4Kj8Ick0Hkm2bYkh7vpkGvsL+rEPeWmr3hojw+pmN7qSdcRIMe6I19FCdXMS+
	99K6mf8MVuMhUECXFgRv50YqfggkgicIveUESuPBd01DoLXPZwK4qC+IfdLjpfc6FxnP3wTl0hL
	hnu31ZW6v+5QntMEfWGTtjhOVMGQ/5h+yHhUURtji3QAeU6pP0X8lEw3hn530epS5IHiZJcTxWO
	0orQh7G2cdRipTHNrZlusH7PerxGT+d+R3uis8zP+wb0ZrVM+h7GeqD8PALpnnvTMEJdgwav
X-Received: by 2002:a05:620a:4542:b0:93a:1540:a75d with SMTP id af79cd13be357-93bb78f1ddfmr803990685a.37.1789595821842;
        Wed, 16 Sep 2026 14:57:01 -0700 (PDT)
X-Received: by 2002:a05:620a:4542:b0:93a:1540:a75d with SMTP id af79cd13be357-93bb78f1ddfmr803986985a.37.1789595821356;
        Wed, 16 Sep 2026 14:57:01 -0700 (PDT)
Received: from [172.31.1.12] ([70.105.241.2])
        by smtp.gmail.com with ESMTPSA id af79cd13be357-93b81cf4ac6sm303772285a.37.2026.09.16.14.57.00
        (version=TLS1_3 cipher=TLS_AES_128_GCM_SHA256 bits=128/128);
        Wed, 16 Sep 2026 14:57:00 -0700 (PDT)
Message-ID: <ac59bd44-2fdf-4737-922a-5478749faaf7@redhat.com>
Date: Wed, 16 Sep 2026 17:57:00 -0400
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
User-Agent: Mozilla Thunderbird
Subject: Re: [nfs-utils PATCH] gssd: clean up threads on shutdown
To: Scott Mayhew <smayhew@redhat.com>
Cc: linux-nfs@vger.kernel.org
References: <20260831230247.814387-1-smayhew@redhat.com>
Content-Language: en-US
From: Steve Dickson <steved@redhat.com>
In-Reply-To: <20260831230247.814387-1-smayhew@redhat.com>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 8bit



On 8/31/26 7:02 PM, Scott Mayhew wrote:
> Valgrind reports leaks such as the following:
> 
> ==1781== 736 bytes in 2 blocks are possibly lost in loss record 831 of 926
> ==1781==    at 0x487F36B: calloc (vg_replace_malloc.c:1616)
> ==1781==    by 0x403A75F: calloc (rtld-malloc.h:44)
> ==1781==    by 0x403A75F: allocate_dtv (dl-tls.c:477)
> ==1781==    by 0x403B2E5: _dl_allocate_tls (dl-tls.c:734)
> ==1781==    by 0x4B6579E: pthread_create@@GLIBC_2.34 (in /usr/lib64/libc.so.6)
> ==1781==    by 0x400E531: start_upcall_thread.constprop.0 (gssd_proc.c:971)
> ==1781==    by 0x400EC34: handle_gssd_upcall (gssd_proc.c:1117)
> ==1781==    by 0x48B9D9B: event_persist_closure (event.c:1623)
> ==1781==    by 0x48B9D9B: event_process_active_single_queue (event.c:1682)
> ==1781==    by 0x48BA5BE: event_process_active (event.c:1783)
> ==1781==    by 0x48BA5BE: event_base_loop (event.c:2006)
> ==1781==    by 0x400A431: main (gssd.c:1292)
> ==1781==
> 
> This is due to the thread-local storage allocated by pthread_create() as
> well as the upcall_thread_info struct allocated by
> start_upcall_thread().  Those do eventually get freed by the watchdog
> thread in scan_active_thread_list().  The thread-local storage gets
> freed when pthread_tryjoin_np() succeeds and the upcall_thread_info gets
> freed via TAILQ_REMOVE() + free().  But since the watchdog thread sleeps
> between iterations (30 seconds by default), from the perspective of
> tools like valgrind there’s a leak.
> 
> Add logic to clean up the threads on shutdown to make tools like
> valgrind happy.
> 
> Signed-off-by: Scott Mayhew <smayhew@redhat.com>
Committed... (tag: nfs-utils-2-9-3-rc5)

steved.
> ---
>   utils/gssd/gssd.c | 60 +++++++++++++++++++++++++++++++++++++++++++++++
>   1 file changed, 60 insertions(+)
> 
> diff --git a/utils/gssd/gssd.c b/utils/gssd/gssd.c
> index 6a41fc5d..e381c0f2 100644
> --- a/utils/gssd/gssd.c
> +++ b/utils/gssd/gssd.c
> @@ -98,6 +98,7 @@ static struct event_base *evbase = NULL;
>   
>   int upcall_timeout = DEF_UPCALL_TIMEOUT;
>   static bool cancel_timed_out_upcalls = false;
> +pthread_t watchdog_tid;
>   
>   TAILQ_HEAD(topdir_list_head, topdir) topdir_list;
>   
> @@ -498,6 +499,61 @@ gssd_clnt_krb5_cb(int UNUSED(fd), short UNUSED(which), void *data)
>   	handle_krb5_upcall(clp);
>   }
>   
> +static void
> +cleanup_active_thread_list(void)
> +{
> +	struct upcall_thread_info *info;
> +	bool cancelled = false;
> +	void *tret, *saveprev;
> +	int err;
> +
> +	pthread_mutex_lock(&active_thread_list_lock);
> +	TAILQ_FOREACH(info, &active_thread_list, list) {
> +		err = pthread_tryjoin_np(info->tid, &tret);
> +		switch (err) {
> +		case 0:
> +			saveprev = info->list.tqe_prev;
> +			TAILQ_REMOVE(&active_thread_list, info, list);
> +			free(info);
> +			info = saveprev;
> +			break;
> +		case EBUSY:
> +			pthread_cancel(info->tid);
> +			do_error_downcall(info->fd, info->uid, -ETIMEDOUT);
> +			cancelled = true;
> +			break;
> +		default:
> +			/* EDEADLK, EINVAL, and ESRCH... none of which should happen! */
> +			printerr(0, "watchdog: attempt to join thread id 0x%lx returned %d (%s)!\n",
> +					info->tid, err, strerror(err));
> +			break;
> +		}
> +	}
> +	if (cancelled) {
> +		TAILQ_FOREACH(info, &active_thread_list, list) {
> +			err = pthread_tryjoin_np(info->tid, &tret);
> +			switch (err) {
> +			case EBUSY:
> +				printerr(0, "watchdog: thread id 0x%lx still busy on shutdown\n",
> +					 info->tid);
> +				/* fall through */
> +			default:
> +				/* EDEADLK, EINVAL, and ESRCH... none of which should happen! */
> +				printerr(0, "watchdog: attempt to join thread id 0x%lx returned %d (%s)!\n",
> +						info->tid, err, strerror(err));
> +				/* fall through */
> +			case 0:
> +				saveprev = info->list.tqe_prev;
> +				TAILQ_REMOVE(&active_thread_list, info, list);
> +				free(info);
> +				info = saveprev;
> +				break;
> +			}
> +		}
> +	}
> +	pthread_mutex_unlock(&active_thread_list_lock);
> +}
> +
>   /*
>    * scan_active_thread_list:
>    *
> @@ -628,6 +684,7 @@ start_watchdog_thread(void)
>   		printerr(0, "ERROR: pthread_create failed: ret %d: %s\n",
>   			 ret, strerror(errno));
>   	}
> +	watchdog_tid = th;
>   	return ret;
>   }
>   
> @@ -1290,6 +1347,9 @@ main(int argc, char *argv[])
>   
>   	printerr(0, "event_dispatch() returned %i!\n", rc);
>   
> +	pthread_cancel(watchdog_tid);
> +	cleanup_active_thread_list();
> +
>   	gssd_destroy_krb5_principals(root_uses_machine_creds);
>   
>   	while (!TAILQ_EMPTY(&topdir_list)) {


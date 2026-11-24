Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=74.125.82.171
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1795525772;
	b=hMJEyx+GyjjdOYiXyU9rQaxP0dGebbXcuKubAkv7MePZr1tn+nwdO7rJ6dr210hrrbgq
	 2Go2KZp6A8jc+l8Ktu517Ey2Rz7dCkQRJT0VputIvtUqzii6NbWuZy6LtqBCnt+rz1CPM
	 YhEJNCQMwaLNAYtwO2EGw2mKaT47P96GQiaojfvdivwNHISa4mT8brucXZzVblDZ9K+va
	 eQVYIPFXVZwXVadSzavcoV6BaK4WZqlDGtxN/yx9Mc3ggFLJRNmiNprGY1zHUO2x9mm44
	 pzb9gDlcsLvWRVff4iBibW/0mSdrWFeD3Xm5Wt7hkCQH/SQZeJhNG83epM/SH9kZjfQ==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1795525772;
	h=DMARC-Filter:Received:DKIM-Signature:X-Google-DKIM-Signature:
	 X-Forwarded-Encrypted:X-Gm-Message-State:X-Gm-Gg:X-Received:Received:
	 MIME-Version:Content-Type:Content-Transfer-Encoding:Subject:From:To:
	 Cc:In-Reply-To:References:Date:Message-Id:X-Mailer;
	bh=8yG0hkfIb2fB7h6z4Ui2DUaPUWV2P+Yav+jRqgNw3xY=;
	b=zsjfS9S79ILYoENMzXdvfUThq4Ou6P96bKT6AGBtbGT8RSL9biAreZMTaDTuSWSQPCSW
	 py/PGonU7dtkPGGo5IGwC//C/Slph89gEP/TFfElaXQSr/YuMp0ZKqz5Rm1hDtbF0GgL8
	 QMTydvKwVce9K3H/2qPZZiRJY6BLBE+P40HvGQdLQ+IbO4vk5tS2uBbG3dHjqEXVmzhtk
	 Ofxh70Aalk+Nr2+sqc04y/uggmVkSo+s950ia00KbQ21b0Sn8TqCMeq7AjaECJwlDjZ7d
	 Uw/KP/q0JTTRc/PRHZ6Z0lXaWqIYYro9XeOK9UpZaL3Zbq2xvJjJSy0YrK5sDDenFaQ==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dmarc=pass header.from=gmail.com;
	spf=pass smtp.mailfrom=gmail.com;
	dkim=pass header.d=gmail.com header.i=@gmail.com header.a=rsa-sha256 header.s=20260707 header.b=MqA5yQ3T;
	arc=none smtp.remote-ip=74.125.82.171
Received: from mail-dy1-f171.google.com (mail-dy1-f171.google.com [74.125.82.171])
	(using TLSv1.3 with cipher TLS_AES_128_GCM_SHA256 (128/128 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1) server-digest SHA256)
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 3EA4F606A327
	for <linux-nfs@vger.kernel.org>; Tue, 24 Nov 2026 13:09:32 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.4.2 smtp.subspace.kernel.org 3EA4F606A327
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=gmail.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=gmail.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.a=rsa-sha256 header.s=20260707 header.b=MqA5yQ3T
Received: by mail-dy1-f171.google.com with SMTP id 5a478bee46e88-38699cf08dfso4912839eec.1
        for <linux-nfs@vger.kernel.org>; Tue, 24 Nov 2026 05:09:32 -0800 (PST)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20260707; t=1795525771; x=1796130571; darn=vger.kernel.org;
        h=message-id:date:references:in-reply-to:cc:to:from:subject
         :content-transfer-encoding:content-type:mime-version:from:to:cc
         :subject:date:message-id:reply-to:content-type;
        bh=8yG0hkfIb2fB7h6z4Ui2DUaPUWV2P+Yav+jRqgNw3xY=;
        b=MqA5yQ3TI8mmHn2+b38HkEvtgqQzyHR0LW8DcJXTREDuHsnh+pcBCLS5qcgW9iqHV2
         412CSNfvFaovfq9i+tuCfj/aIt8L8dhNQEdrOr7k0LFjsU2tLUqdjRWnMhZDN3K0bI1r
         p3ZHytCZYvFZEmINQuTqy0a5Y7avToQ9MQN5o/QoJXXH0VXe5B23SQCz1TH21u0sQ9Hg
         luUfv8AFh9z9SpGarPSf97dpEHiPxoqqMfB6PHb+pSEpI3f3BC5X8G9UmN8mvOv3khf5
         Cfc4H336Fuyrp4h76AoH70AcMo6GMNVAa13ncgHSzoeYrbHc4kGPR3+GMO6RswgNB/cu
         iPFw==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20260707; t=1795525771; x=1796130571;
        h=message-id:date:references:in-reply-to:cc:to:from:subject
         :content-transfer-encoding:content-type:mime-version:x-gm-gg
         :x-gm-message-state:from:to:cc:subject:date:message-id:reply-to
         :content-type;
        bh=8yG0hkfIb2fB7h6z4Ui2DUaPUWV2P+Yav+jRqgNw3xY=;
        b=aqK6I9SCBdu26kgrZkPR159r4ngnneHIxSmHg00II2ASb0GaLbm4Tseqmw4guVtjdC
         7Yq6p7xvTQoNQbcprLh+jQr9WLEhIwke3uw9/4jqvs/dAKjICPts0xdO0Fl3WKrXPhnG
         dTtS9K6fgDDC4RiugWLiFq+dJAt+uN8Qy7VZYyAPHbA1BPsJI6JYfa1/d5hVkSw81Yl/
         CPzzaRgLEbj+YqL9Nv+rnpNHFMh1Dy38TrsLicIqnlRIZwZd0r+zaKPJPE4S7iQEFXAu
         TBVqTc8omkHlMGsRhRR0VxJptno+IVhSEZiP8xOEvJxNDgjvw7vPj97YBxYzY+kdvWqp
         hMmQ==
X-Forwarded-Encrypted: i=1; AL+hErEduemgrjKbrt7GDzvEdlA9DnZmqCYlU8Xhd8HIMy5LxIUAwO5IAsVKI14GpSMxJOsXEntM+iS9cac=@vger.kernel.org
X-Gm-Message-State: APuU4Z8X8Dgr1lyaAKpGh5jeKHly69oLOP25J8X1lGlhT6jjZFC3Zg1S
	rMJxsQSXO55LPOglFJFtazX4x3aLHWt1vFpm8W1t/JcIHf9Xnr1PI9FE
X-Gm-Gg: AZFdTZf+xdSLpR4k9IgLuYPqqs+giE9VaiFvr4p1PvNWxLme3+eWTeIzQYEtHV0wON7
	bRzLpww+ih8K18aUwXGDp3t5N9oVhZn3dWMqeJipIWUCrHzRdezbPs7WtZIep6D6qsSUiIrlYQA
	TWrc33BiXaq0lOap3iY70om+87+g5naqS1jDEd6uMkTXa+re7TIJAR/uGQeQSMe9m3NpOmmlGPP
	0mCIS5kOeA17k63/GJdOqtTYfQMRjPAYUay4p0vhdWmIqXB8Jyu4+YZNZCq6Ly3f54XTKx4BkyX
	6AEDAWdLZ5jwkjj9b1PM40kI7YSLLgkNOgVl+ufRJwTcV7+Luts9R5jshpK1iwLQQeIgeWHwG5I
	VYHA6AFqHDUFhwdwPuHjEow3JX11MZBSh2t88mG6ps1oS0+NRrYWp5L/q8AWG705wOSDWl2jNgW
	S89Pizyp05IRdG5ssea33o03s4RHEbgsBdG4R4d37EhpP6JOSUcC0EZLSWPI8JTWXr00jn51wqD
	oC8u/km5tMTYXy8xa4Gr8vUbtHAUO8Yllo+d0D71AtGYuI3dL5MKYXSSINGFM1dtEpUoJgZhtI8
	y7tr56r1Dn+nFNme1yRCiascvBIyxY6E3rEiWQ==
X-Received: by 2002:a05:7301:6083:b0:386:a01f:a36b with SMTP id 5a478bee46e88-386a01fa8d8mr15606324eec.35.1795525771011;
        Tue, 24 Nov 2026 05:09:31 -0800 (PST)
Received: from [192.168.29.85] ([2405:201:8026:213e:1412:77ad:61f2:79f2])
        by smtp.gmail.com with ESMTPSA id 5a478bee46e88-385d2b93dd9sm50659886eec.24.2026.11.24.05.09.27
        (version=TLS1_3 cipher=TLS_AES_256_GCM_SHA384 bits=256/256);
        Tue, 24 Nov 2026 05:09:30 -0800 (PST)
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Post: <mailto:linux-nfs@vger.kernel.org>
List-Help: <mailto:linux-nfs+help@vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
List-Owner: <mailto:linux-nfs+owner@vger.kernel.org>
Precedence: list
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Subject: Re: [PATCH v2] NFS: idmap: handle zero return from
 nfs_idmap_get_key()
From: mdshahid03@gmail.com
To: mdshahid03@gmail.com
Cc: trondmy@kernel.org, anna@kernel.org, linux-nfs@vger.kernel.org, 
 linux-kernel@vger.kernel.org
In-Reply-To: <20261112162938.14329-1-mdshahid03@gmail.com>
References: <20261112162938.14329-1-mdshahid03@gmail.com>
Date: Tue, 24 Nov 2026 18:39:12 +0530
Message-Id: <179552575292.187304.16298525842648413199.b4-reply@b4>
X-Mailer: b4 0.16.0

Hi ,

Could you please check and give your feedback ? when time permits.

Thanks
Shahid.

On 2026-11-12 21:59 +0530, mdshahid03@gmail.com wrote:
> From: Mohammad Shahid <mdshahid03@gmail.com>
> 
> nfs_idmap_get_key() can return zero, but nfs_idmap_lookup_name()
> treats only negative values as errors.
> 
> Treat zero as an error to avoid reporting an unsuccessful lookup
> as successful.
> 
> Signed-off-by: Mohammad Shahid <mdshahid03@gmail.com>
> ---
>  fs/nfs/nfs4idmap.c | 2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
> 
> diff --git a/fs/nfs/nfs4idmap.c b/fs/nfs/nfs4idmap.c
> index 06b193722660..8f5f0abf804d 100644
> --- a/fs/nfs/nfs4idmap.c
> +++ b/fs/nfs/nfs4idmap.c
> @@ -353,7 +353,7 @@ static ssize_t nfs_idmap_lookup_name(__u32 id, const char *type, char *buf,
>  
>  	id_len = nfs_map_numeric_to_string(id, id_str, sizeof(id_str));
>  	ret = nfs_idmap_get_key(id_str, id_len, type, buf, buflen, idmap);
> -	if (ret < 0)
> +	if (ret <= 0)
>  		return -EINVAL;
>  	return ret;
>  }
> -- 
> 2.43.0
> 
> 
> 



Received: from us-smtp-delivery-124.mimecast.com (us-smtp-delivery-124.mimecast.com [170.10.129.124])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id DAD7F3C3C08
	for <linux-nfs@vger.kernel.org>; Mon, 31 Aug 2026 22:58:48 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=170.10.129.124
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1788217130; cv=none; b=lcMxDObfrP1b8UMapQHP93QKZbNX8nQpnsewXAWaRw15botapqgpSUMcoA5xTgWjaUdQ2o+3AqZtBi2aDUqNxI7oi0n4csKlwwhl/2x958PeKWBGqDXY0fzADSpGSs+txdIyLk+F290FjfvHoTJhXPxXN6KmrVupAbvg8wKSgbE=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1788217130; c=relaxed/simple;
	bh=ejsLqYm2+CCJARERYwzgjk45W2YNsKYoIQQgpIoT5Sg=;
	h=Message-ID:Date:MIME-Version:Subject:To:Cc:References:From:
	 In-Reply-To:Content-Type; b=pbn9UQyGhqZMp7CHMz37+l5qLknNrOoSeOR5dz2ioVchZsX4JAFuRIqi+whiA7tdJQD6skVCFj26DuV3e5LAzrLesyhRTOjL63zKBicReiYgWpNHCeEKqI3wruu5fF0tnYvgelDM62FC1Fi/5O6FqcFbbBwyE7LOydBJZ25tD1Q=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=redhat.com; spf=pass smtp.mailfrom=redhat.com; dkim=pass (1024-bit key) header.d=redhat.com header.i=@redhat.com header.b=bhJ0L7Ja; dkim=pass (2048-bit key) header.d=redhat.com header.i=@redhat.com header.b=OV2xY1gR; arc=none smtp.client-ip=170.10.129.124
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=redhat.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=redhat.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (1024-bit key) header.d=redhat.com header.i=@redhat.com header.b="bhJ0L7Ja";
	dkim=pass (2048-bit key) header.d=redhat.com header.i=@redhat.com header.b="OV2xY1gR"
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=redhat.com;
	s=mimecast20190719; t=1788217127;
	h=from:from:reply-to:subject:subject:date:date:message-id:message-id:
	 to:to:cc:cc:mime-version:mime-version:content-type:content-type:
	 content-transfer-encoding:content-transfer-encoding:
	 in-reply-to:in-reply-to:references:references;
	bh=DMaZLxB3KEmVSeScfX+IxoTZm3dmSWq5BwnA4vSL9CI=;
	b=bhJ0L7JaLSIdQxyo/E6wYuIv9O58JKnMNVBRNuFZ59Sq4n1CGxNUGr2aHmybmx2NW+GMle
	uIuB6/FVaw+39v6v0i4QtMM65dj3jlrVxF9ZSMeJ9QSv4WITKDgSgRGa+ZyKCQlYX0oxyz
	OJYZVPvb+SQDI7RH1cFdU6fOTClFxWw=
Received: from mail-qv1-f72.google.com (mail-qv1-f72.google.com
 [209.85.219.72]) by relay.mimecast.com with ESMTP with STARTTLS
 (version=TLSv1.3, cipher=TLS_AES_256_GCM_SHA384) id
 us-mta-275-OTuSQ5XMM46RCvmD61O5Xw-1; Mon, 31 Aug 2026 18:58:46 -0400
X-MC-Unique: OTuSQ5XMM46RCvmD61O5Xw-1
X-Mimecast-MFC-AGG-ID: OTuSQ5XMM46RCvmD61O5Xw_1788217126
Received: by mail-qv1-f72.google.com with SMTP id 6a1803df08f44-90e869793d3so36864916d6.0
        for <linux-nfs@vger.kernel.org>; Mon, 31 Aug 2026 15:58:46 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=redhat.com; s=google; t=1788217125; x=1788821925; darn=vger.kernel.org;
        h=content-transfer-encoding:content-type:in-reply-to:from
         :content-language:references:cc:to:subject:user-agent:mime-version
         :date:message-id:from:to:cc:subject:date:message-id:reply-to
         :content-type;
        bh=DMaZLxB3KEmVSeScfX+IxoTZm3dmSWq5BwnA4vSL9CI=;
        b=OV2xY1gRrEB72NzcwYm1avtkZmtApe35KWogjawlksBMf4iGLuWPpUgKjBYsaQUasU
         plpCANU5b44phvp+FTCJ/g4OV86J6uW65ofVBI8PRVkCT/W2WK15GP6L19I+OICrrOO8
         k8ITLAwc62ptHRTS9c548OTiiBPMZbItVWMTrkT7kgOuuupk/0H9Z6oLb3VFhr5vzUeq
         TPtBzh6WArNzGNsaHPJnPQUR80BS4fJ5JwS06FUsT1yXw5bqtpXLiQdux91w7IgdNP7J
         iiBuUUDk+uucH6D9j2PSgiJFTxmPzJ8OmnvVmVvtUK0VnsF3Fxmc8J5Djbkis4vRQTwg
         YoMQ==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20251104; t=1788217125; x=1788821925;
        h=content-transfer-encoding:content-type:in-reply-to:from
         :content-language:references:cc:to:subject:user-agent:mime-version
         :date:message-id:x-gm-gg:x-gm-message-state:from:to:cc:subject:date
         :message-id:reply-to:content-type;
        bh=DMaZLxB3KEmVSeScfX+IxoTZm3dmSWq5BwnA4vSL9CI=;
        b=tPn9ZIAROyas5KjM4wqTtJejqGtJV4KETWeKR2DWKYtgH7eFnNunfKr1zW5O8tvgKO
         530LBbKdIWw8rk3YRRpveVZ/OKjuFt7fjaiKHLSIA0sF6/CfpkQUeTNhI7GVPVg04X/w
         fkHNAh+5bA9rNhCIlfhwG174yMp/tZWk/k/JAp/xN38T2TOEcjUW8VgESgSP3HTZ95Rd
         8hSrJiv68A6FXRavP/2Rx7aBDMg+QkkA+Ofk+j3IZc8jaGBYmzjOUiutABY+pRFYUXp+
         xTiWhYtp0EXkoVyc5+g+eTm/1XJhG22OY/36i9TYs1H0dwkd3fSH6D+/3s/2DQLrX7K0
         8arA==
X-Gm-Message-State: AFuF++mHxEyJkYPg+nzv94Ba1KXgrrYaQ+TFj6epbzGeh/cM8AKllS9G
	E/F5RYT9GZ0TgP24qI6IzGcEFI511eCunpEoLiP8Q/w+/KE9TaHUQhHahX42DrsIoFEJCHxySXw
	SHbIEQAmnVnlxS5jC5yiB497IgLE3pjny0VkfzYkUMLmUQ1sw2KY+xPkzBJVEdU4bFV6Dqw==
X-Gm-Gg: AYBFou3eG6ZSMooHrgWIdzToYRW7xJ4PqKSYb80OLT2WN7xcGqDqKHcLOKZxerCVEqr
	bYJnCMTn0ixbTh9K+bIXRl7pFb4DsxXOc3PC/rNEZ0nrhdVgMMy80m0Nic0nitQY15MRmo8nJJ7
	UWhLkgUJxt9I9z+e1SiDPH7SnLvyc/y7WQHUMGjTE2T/Zya8L78uJuTqeGEJ0bsxIYMDidgp+2R
	SgzmnDhhA0wR5wPZxpXSips5WHwpr3DL9RYVADOgGj/dJ0kJDQWMNa35Eq1h0FvYsPJ5hoUeKfT
	KMrd1vQiTzmHElCFMkrXiRzCE3RyaQZ2lUI9o7CnQl0SAfwogpbVLMXPMvI5A5qYTg9XaBMG/PK
	cyCZziML7BmhX9GbvpQegxk1C5Fgyjwu5EyBDQsrcIi4xBOqe
X-Received: by 2002:a05:6214:ac1:b0:90e:8cd4:30da with SMTP id 6a1803df08f44-90e929669camr59423966d6.18.1788217125560;
        Mon, 31 Aug 2026 15:58:45 -0700 (PDT)
X-Received: by 2002:a05:6214:ac1:b0:90e:8cd4:30da with SMTP id 6a1803df08f44-90e929669camr59423466d6.18.1788217125108;
        Mon, 31 Aug 2026 15:58:45 -0700 (PDT)
Received: from ?IPV6:2603:6000:1d40:9300:d6cc:b253:d867:f7d1? ([2603:6000:1d40:9300:d6cc:b253:d867:f7d1])
        by smtp.gmail.com with ESMTPSA id 6a1803df08f44-90ce415902dsm98770706d6.0.2026.08.31.15.58.44
        (version=TLS1_3 cipher=TLS_AES_128_GCM_SHA256 bits=128/128);
        Mon, 31 Aug 2026 15:58:44 -0700 (PDT)
Message-ID: <c0148d36-51b9-4f52-8886-15455e4b5272@redhat.com>
Date: Mon, 31 Aug 2026 17:58:43 -0500
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
User-Agent: Mozilla Thunderbird
Subject: Re: [PATCH] rpcctl: SyntaxWarning: 'return' in a 'finally' block
To: Salvatore Bonaccorso <carnil@debian.org>,
 Anna Schumaker <Anna.Schumaker@Netapp.com>
Cc: linux-nfs@vger.kernel.org, 1144982@bugs.debian.org,
 "Trent W. Buck" <trentbuck@gmail.com>
References: <20260822144142.682662-1-carnil@debian.org>
Content-Language: en-US
From: Steve Dickson <steved@redhat.com>
In-Reply-To: <20260822144142.682662-1-carnil@debian.org>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit



On 8/22/26 10:41 AM, Salvatore Bonaccorso wrote:
> Trent W. Buck reported that when using rpcctl with Python 3.14
> version, a SyntaxWarning warning is issued on the use of return in the
> finally block in the read_info_file function.
> 
> Replace the finally clause with an except BaseException, and dedent the
> return by one level up.
> 
> Reported-by: "Trent W. Buck" <trentbuck@gmail.com>
> Link: https://docs.python.org/3/whatsnew/3.14.html#pep-765-control-flow-in-finally-blocks
> Closes: https://bugs.debian.org/1144982
> Signed-off-by: Salvatore Bonaccorso <carnil@debian.org>
Committed... (tag: nfs-utils-2-9-3-rc2)

steved.
> ---
>   tools/rpcctl/rpcctl.py | 5 +++--
>   1 file changed, 3 insertions(+), 2 deletions(-)
> 
> diff --git a/tools/rpcctl/rpcctl.py b/tools/rpcctl/rpcctl.py
> index 29ae7d26f50e..42e238ca1c52 100755
> --- a/tools/rpcctl/rpcctl.py
> +++ b/tools/rpcctl/rpcctl.py
> @@ -43,8 +43,9 @@ def read_info_file(path):
>           with open(path) as info:
>               lines = [line.split("=", 1) for line in info if "=" in line]
>               res.update({key: int(val.strip()) for (key, val) in lines})
> -    finally:
> -        return res
> +    except BaseException:
> +        pass
> +    return res
>   
>   
>   class Xprt:


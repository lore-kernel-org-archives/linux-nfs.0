Received: from us-smtp-delivery-124.mimecast.com (us-smtp-delivery-124.mimecast.com [170.10.129.124])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 28DBA345729
	for <linux-nfs@vger.kernel.org>; Wed, 16 Sep 2026 14:54:05 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=170.10.129.124
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1789570447; cv=none; b=kvSARAlOHV3sNfAGuMU2NBusST7g+ITAKzbD2jYY+m45OpPmHXXUTyW0F+vD0rjvy+phxSMk5Axn/YC4BQOsDJH7XYsH03aiUV5cdT1kaSN8N/xzOy+MZ8obEwHCDLv+ehBZ0w3Ong/HBmkThRNBflVK8lGFwpMJUlTpxjOHg2U=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1789570447; c=relaxed/simple;
	bh=XNlQYiJ4TyTdTCRiU3j2hgo/6383B0nPLtn/t6uRU6g=;
	h=Message-ID:Date:MIME-Version:Subject:To:Cc:References:From:
	 In-Reply-To:Content-Type; b=Hqwb/gTPTzaMjlH8JQsrDs6aIRwVuD7iJWDybOJlkNlFGol+nCLhznYGIeKJWYtfI05wpGsOcSAPk/IobZ+QuXvrEQFUSn0XwDgqWVPaAVQjPf0hria6BDdS2UWKTaNUtwZzys3NCiqn+/5pgkqtgGsh4AN2hKKcbqZkkyhLjSM=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=redhat.com; spf=pass smtp.mailfrom=redhat.com; dkim=pass (1024-bit key) header.d=redhat.com header.i=@redhat.com header.b=f+fdPKQQ; dkim=pass (2048-bit key) header.d=redhat.com header.i=@redhat.com header.b=swun7AJI; arc=none smtp.client-ip=170.10.129.124
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=redhat.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=redhat.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (1024-bit key) header.d=redhat.com header.i=@redhat.com header.b="f+fdPKQQ";
	dkim=pass (2048-bit key) header.d=redhat.com header.i=@redhat.com header.b="swun7AJI"
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=redhat.com;
	s=mimecast20190719; t=1789570445;
	h=from:from:reply-to:subject:subject:date:date:message-id:message-id:
	 to:to:cc:cc:mime-version:mime-version:content-type:content-type:
	 content-transfer-encoding:content-transfer-encoding:
	 in-reply-to:in-reply-to:references:references;
	bh=juWo3ggAoS4EVjZjz/TvYhAi9uNUdeog12KJhWhJF7U=;
	b=f+fdPKQQYs805BN8biEqVTGhxIifmVtpl3AoK2opu80SQcPkLa2KBaj0EOhk3CobDLiS6v
	9ZjpVY3H5aJwsL67wg27Y0Ui8yVEUGNI8qL5k+bm5HZ+YIgsK3ycJ5PljMYEySl2UzWzS3
	A4QSj8AMR8C4Nqz8A3V3uzvXZgov+mQ=
Received: from mail-qt1-f198.google.com (mail-qt1-f198.google.com
 [209.85.160.198]) by relay.mimecast.com with ESMTP with STARTTLS
 (version=TLSv1.3, cipher=TLS_AES_256_GCM_SHA384) id
 us-mta-625-24PAHyJDN9qQX9ZI7ygyUw-1; Wed, 16 Sep 2026 10:54:03 -0400
X-MC-Unique: 24PAHyJDN9qQX9ZI7ygyUw-1
X-Mimecast-MFC-AGG-ID: 24PAHyJDN9qQX9ZI7ygyUw_1789570443
Received: by mail-qt1-f198.google.com with SMTP id d75a77b69052e-53286131b0dso9244511cf.2
        for <linux-nfs@vger.kernel.org>; Wed, 16 Sep 2026 07:54:03 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=redhat.com; s=google; t=1789570443; x=1790175243; darn=vger.kernel.org;
        h=content-transfer-encoding:content-type:in-reply-to:from
         :content-language:references:cc:to:subject:user-agent:mime-version
         :date:message-id:from:to:cc:subject:date:message-id:reply-to
         :content-type;
        bh=juWo3ggAoS4EVjZjz/TvYhAi9uNUdeog12KJhWhJF7U=;
        b=swun7AJITz+jzEtdJ/h6GSLjREmmLkDxiqKLu/hYINFhGxz6a9ceTr4w8QgpppKQpR
         z8R2UftRQwhsC03W4hQbIJEWS4ZzWCholNNVXpe8nitK5xP53TT80gsmuqTsq0DnFzDr
         xVwp1czgy6f+ak4s+NFPkDMTXViUBhugamyY4guoB/+uhfyK/y35jb85AaD52fZauHKx
         62u3tdUxZIKYgROsR69HK35JqvErTtGxb21TiJbweV3SsQnSYyK/1xwWElHWgoh6ZiR+
         N7/6BLkQ9WTPBbaq/d1XUb6Oe6DdS3O9l+oWQjlJ8Mj9JisNjxx0vj4vw4JnDmExJZb/
         9Y0g==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20260707; t=1789570443; x=1790175243;
        h=content-transfer-encoding:content-type:in-reply-to:from
         :content-language:references:cc:to:subject:user-agent:mime-version
         :date:message-id:x-gm-gg:x-gm-message-state:from:to:cc:subject:date
         :message-id:reply-to:content-type;
        bh=juWo3ggAoS4EVjZjz/TvYhAi9uNUdeog12KJhWhJF7U=;
        b=S6IRy/3zFoNnk/Fvykj158o9WTgy9NDyatztKtCfqTrVV2v1LuSLgcpQ8Stq7km3f5
         WCfHchNCSyO06zEjyblY/74goTyqhqtWcUOzn8/oFzRP8qmH0MwKcqj1Bb+e+EIiQg/d
         a4yDFzv1hA1nG1wjjiCO6elQERGxTDgIzB5XdlbVu0xNBZFW92LKFj4lYSEQIgDb9jg6
         xUrqJiTQxBahvHZOCJ2ofm32nixQt0EVAC0RZw7QV2qHaerCUQXaqfYx1GI4jnbZA0HT
         P606EO3htEJL90DDgci2cHBQMOzmqEH2OhoNZ76sZvB074/LQULc+f3gzZU1Y45i/VoB
         zZlA==
X-Gm-Message-State: AFuF++lKQRwpoqC2kZXhs5JKW4El3MmK+roqbARCaDgwU6wUkPBxoO7X
	4n3OPgF4NvixhqM1uCS3ol/6/DhRj/n3gDAoysKqtoZ9zf1n52nixANduLzla0R4LAVCxvPZPXW
	V8mcTi6UIfHaqUopxAD8Sg1UiZw+ZJ8qgtwDzEwoidLjrGLFh7M0AZ2nfRdULxXrlqF1YcQ==
X-Gm-Gg: AYBFou3yKzalHdusS+c37js8N6Dwg00uIIJPF3p20kJlxd47w994rbBtL4Rd0KJimEL
	P6G6e4Q4VKZ2jtaJn/AyoDVPW3vvSEiIvIgtuKWQKMpE2ydDvwZuUwMvP6LrJm+0PGqbvddhlLU
	JGhWiyM9o4dFC8hgxg5dhfwmIwmTwOMXrABdF5n957vWhcAYjbOX8Eeyfb4haWbAava9gn9uTTB
	oTV+ACPSwKAPvJX3fbwMyUXciifvrNTZoHWcRMcFndkXRZqgL71YN6zZOsmrZnhCGr26FFW6zum
	LXHXIVAzi6TxyTnL0ep9uoKoRA1GCMTxdWOZgaUW+9kYDlh0XeC8e7lM9mQIZmddpRQkhjMStXg
	=
X-Received: by 2002:ac8:5d90:0:b0:530:d429:c70a with SMTP id d75a77b69052e-5327ee4d5c7mr56133721cf.26.1789570442955;
        Wed, 16 Sep 2026 07:54:02 -0700 (PDT)
X-Received: by 2002:ac8:5d90:0:b0:530:d429:c70a with SMTP id d75a77b69052e-5327ee4d5c7mr56133011cf.26.1789570442487;
        Wed, 16 Sep 2026 07:54:02 -0700 (PDT)
Received: from [172.31.1.12] ([70.105.240.249])
        by smtp.gmail.com with ESMTPSA id d75a77b69052e-53261fd7e5bsm23712331cf.7.2026.09.16.07.54.01
        (version=TLS1_3 cipher=TLS_AES_128_GCM_SHA256 bits=128/128);
        Wed, 16 Sep 2026 07:54:01 -0700 (PDT)
Message-ID: <6320bbf5-4429-48d8-91f3-00e4f9c4da53@redhat.com>
Date: Wed, 16 Sep 2026 10:54:00 -0400
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
User-Agent: Mozilla Thunderbird
Subject: Re: [nfs4-acl-tools PATCH 0/3] nfs4-acl-tools hardening fixes
To: Roberto Bergantinos Corpas <rbergant@redhat.com>
Cc: linux-nfs@vger.kernel.org
References: <20260904093909.2881028-1-rbergant@redhat.com>
Content-Language: en-US
From: Steve Dickson <steved@redhat.com>
In-Reply-To: <20260904093909.2881028-1-rbergant@redhat.com>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit



On 9/4/26 5:39 AM, Roberto Bergantinos Corpas wrote:
> - Escape special characters in printed filenames to prevent injection
> - Fix bound checking around NFS4_MAX_PRINCIPALSIZE
> - Use lsetxattr to avoid following symlinks during recursive walks
> 
> Roberto Bergantinos Corpas (3):
>    nfs4_getfacl/nfs4_setfacl: escape newline+cr from filenames
>    libnfs4acl: fix various bound checkings against NFS4_MAX_PRINCIPALSIZE
>    nfs4_setacl: do not follow symlinks on
>      do_apply_action/nfs4_setacl_byname
> 
>   include/libacl_nfs4.h             |  1 +
>   libnfs4acl/acl_nfs4_set_who.c     |  2 +-
>   libnfs4acl/acl_nfs4_xattr_load.c  |  2 +-
>   libnfs4acl/nfs4_ace_from_string.c |  2 +-
>   libnfs4acl/nfs4_print_acl.c       | 13 +++++++++++++
>   libnfs4acl/nfs4_setacl.c          |  2 +-
>   nfs4_getfacl/nfs4_getfacl.c       |  7 +++++--
>   nfs4_setfacl/nfs4_setfacl.c       |  6 ++++--
>   8 files changed, 27 insertions(+), 8 deletions(-)
> 
Committed... (tag: nfs4-acl-tools-0.4.3-rc2)

steved.


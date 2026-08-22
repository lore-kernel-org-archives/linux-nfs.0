Received: from mail-ej1-f45.google.com (mail-ej1-f45.google.com [209.85.218.45])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 5A69A2E975E
	for <linux-nfs@vger.kernel.org>; Sat, 22 Aug 2026 15:11:43 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=209.85.218.45
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1787411504; cv=none; b=eI/MWr6LQBAzCDMps/ui9gXtE8uOQpyyaRS3I6tqzx7UTzEU0pVo7+z5lMFMjNGKhlrmLJExVTeW4WPzZiOoh9j0xSSmvu8JhRAbRLZQrT4sO1G017A8Z6Z8klowmZbcsj4bpNlf+WpbsIAbN6t/88xcUeU+y8XNv+Odte0BZqs=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1787411504; c=relaxed/simple;
	bh=IhrMcuJ0YZTW7IMYjNRvRuu4WX/Q7dTo9f3/9Pvw7hQ=;
	h=Date:From:To:Cc:Subject:Message-ID:References:MIME-Version:
	 Content-Type:Content-Disposition:In-Reply-To; b=g86AJaE52l7A00EgWhtVexWYpMsa0xSLco/Tvmu/vaS4BluHldfNC7PB2YPI/kFMTdiYzFZnTQvfGVXXuEO2DnnDWYOAtKK8tUFFNEqVPajklaOOmRQ2PG37PEGFLOJhkuOK77LHcSYdigYrzuWAU68M4RsfF6zAfWnSHoffJ9k=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=fail (p=none dis=none) header.from=debian.org; spf=pass smtp.mailfrom=gmail.com; dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b=NiTneCo1; arc=none smtp.client-ip=209.85.218.45
Authentication-Results: smtp.subspace.kernel.org; dmarc=fail (p=none dis=none) header.from=debian.org
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=gmail.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="NiTneCo1"
Received: by mail-ej1-f45.google.com with SMTP id a640c23a62f3a-c160420289bso301639966b.0
        for <linux-nfs@vger.kernel.org>; Sat, 22 Aug 2026 08:11:43 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20251104; t=1787411501; x=1788016301; darn=vger.kernel.org;
        h=in-reply-to:content-disposition:content-type:mime-version
         :references:message-id:subject:cc:to:from:date:sender:from:to:cc
         :subject:date:message-id:reply-to:content-type;
        bh=b0aP1NLs/a0OWcczfRYcy5Ra61BZqABKZ8pepyNzAQ4=;
        b=NiTneCo1pKN3TyR5FDim7BLj7uLVOuux8tOPZLqzGnFG/4br2FLhF8gAFEKg4jxFU5
         xRfHrWfyQ/CZC6aOukBRDC8ICqDHM2MGuVyIHOR0dTHTjLm427l0L49fk+PiUNWkkyWJ
         tSwUAT06y6KjiNjC9tNZQZLTIjVNFsugzux2kYkAYX4L2wp8zbBvDNMXVu+H5RGxAV7E
         0aFplWN/KlOOBbsnEUBiD7fFwekXARbCoVI1S+2CjKlnzBK/CodgALq3M002BQeW4Yxq
         ZJ6BdoHRuedVKVwzoKtNISdmAjkVY4KOYJWUz19YqDGfdBHZ9/JGFVNOH+UlofEzF4H9
         jVpA==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20251104; t=1787411501; x=1788016301;
        h=in-reply-to:content-disposition:content-type:mime-version
         :references:message-id:subject:cc:to:from:date:sender:x-gm-gg
         :x-gm-message-state:from:to:cc:subject:date:message-id:reply-to
         :content-type;
        bh=b0aP1NLs/a0OWcczfRYcy5Ra61BZqABKZ8pepyNzAQ4=;
        b=KHVEMRNVGGVlHNLetnSfYb6iFntc6ajX+5+76FypnAHSDES8XWErai1hKpy8FCyhwU
         6PAa0w+cPPtjHhHlLGoajunDCb4YcgmHU/j2xtg5GVGU2KWrjFEBqA7tew6WE9eqMADP
         n/70j2W9l06cELswH/cToRocB6aMN/sLXinTNteW0d6GUKDZilvKyfyOYlVbb1kEzENR
         nPC3YUXSCtgrdoeW6jv0gwsKL/KK6y+miV1/5bGhLYFZmiDntUu+mh5eyfr9FYWusT4x
         Vr37Q15gfrzRhi/JutQbW3URP09hxkg5ZQ7Qo5EaxzUE6cdvbkuRVwYzqJFoTQOA+hZl
         p7VQ==
X-Forwarded-Encrypted: i=1; AHgh+RrWV3Aaq/Hd7i13Lts7c2qyYb5mtPUKZ+L4Ku/n63WNMj38W0bP7FUberZnRanW8AGwjRonvGp0su4=@vger.kernel.org
X-Gm-Message-State: AFuF++nCEqbjn5hKfWsYUR9tP0Tg7Xmo8fJ3PCnCXobgwnzVDYg7PhXp
	uzpnV+QKBdCVqlSN7bSG0zlg8ayzzOwZtBSukDQinGHMKXMp9fkieOwd
X-Gm-Gg: AR+sD111BjLvqiyb08765ZwI2O+wkpBrI8hl8lT+46EoecZCrrDd8r4Y+OGIEevJDrn
	jWOGrHB6rvgZD6e0rNXICXmq/N8h6IVdgSAmJL5Eq90bk3X9Vq+00wCSdzP0kT2QyIeP5FJE13L
	WTXGdh608Vhd7XOtFtr099KeN8mWIWhZy2TzBDheZn77D4QLX/zV40MipuhYl+U7zmEte8L6c5f
	VRgpWZDx62aN3hQE+SSqjSrNgDC3EHQ7SC8y59c05WXoy5Yo0tZe4Wjsv0Z55Ss8GEH0YyU70hs
	O3yEZIfdt1kXfzeU2oWxddxs5vd+Y3rG53ZNbIyH3fWIZLvDMiqLAQUgIAbZu0CKUsR8KUa/ViF
	wrBilXPhC6o1KqcqVHuDm9x1P2wASVmsBpwbrUboDKX1pr+Hhle3qWV+1zhUIIpe/G6Ir79KTVo
	XXmVd1svLd/VLZHCUe/J7xyIYmC5LL/bPcjp64WjLm6gQNWrqGQKo3lFkNSkWvLkJnSMhy32oQj
	76CrV+lYI4w5Zm5vJpK9FU=
X-Received: by 2002:a17:906:d8d6:b0:c21:34a3:4d9c with SMTP id a640c23a62f3a-c246a72174bmr1212658266b.21.1787411501223;
        Sat, 22 Aug 2026 08:11:41 -0700 (PDT)
Received: from eldamar.lan (c-82-192-247-196.customer.ggaweb.ch. [82.192.247.196])
        by smtp.gmail.com with ESMTPSA id a640c23a62f3a-c249689fa1dsm330661966b.56.2026.08.22.08.11.39
        (version=TLS1_3 cipher=TLS_AES_256_GCM_SHA384 bits=256/256);
        Sat, 22 Aug 2026 08:11:40 -0700 (PDT)
Sender: Salvatore Bonaccorso <salvatore.bonaccorso@gmail.com>
Received: by eldamar.lan (Postfix, from userid 1000)
	id 1DD96BE2DE0; Sat, 22 Aug 2026 17:11:39 +0200 (CEST)
Date: Sat, 22 Aug 2026 17:11:39 +0200
From: Salvatore Bonaccorso <carnil@debian.org>
To: Anna Schumaker <anna.schumaker@oracle.com>
Cc: Steve Dickson <steved@redhat.com>, linux-nfs@vger.kernel.org,
	1144982@bugs.debian.org, "Trent W. Buck" <trentbuck@gmail.com>
Subject: Re: [PATCH] rpcctl: SyntaxWarning: 'return' in a 'finally' block
Message-ID: <aom8K-fFQq9BLZga@eldamar.lan>
References: <20260822144142.682662-1-carnil@debian.org>
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20260822144142.682662-1-carnil@debian.org>

Hi,

On Sat, Aug 22, 2026 at 04:41:42PM +0200, Salvatore Bonaccorso wrote:
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
> ---
>  tools/rpcctl/rpcctl.py | 5 +++--
>  1 file changed, 3 insertions(+), 2 deletions(-)
> 
> diff --git a/tools/rpcctl/rpcctl.py b/tools/rpcctl/rpcctl.py
> index 29ae7d26f50e..42e238ca1c52 100755
> --- a/tools/rpcctl/rpcctl.py
> +++ b/tools/rpcctl/rpcctl.py
> @@ -43,8 +43,9 @@ def read_info_file(path):
>          with open(path) as info:
>              lines = [line.split("=", 1) for line in info if "=" in line]
>              res.update({key: int(val.strip()) for (key, val) in lines})
> -    finally:
> -        return res
> +    except BaseException:
> +        pass
> +    return res
>  
>  
>  class Xprt:
> -- 
> 2.55.0

Including Anna's oracle.com address.

Regards,
Salvatore

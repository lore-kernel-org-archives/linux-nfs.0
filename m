Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=209.85.208.46
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1794657339;
	b=lyM1hpWP1TMm/XOwr2VkZe8d2VUe9rouL0vkXt1+mC/8G5kMjTTZygofx/psLnCPoYio
	 xMojknXbJ0Ai8gBNA/iQ75ssFf5RZ2bob5MJnZcJW4mqnP8yIey55aDXiJqeQ+duK4bTQ
	 dvWZhg+V6xobTb8FDQVgaTi2tiivWVEx6+65xx4JuxTlJEqc1v5u2scYnndnB9tGrOPsl
	 6e82y9JYwlbaKmIbKa/cge7Mp+vhidmRdzUlU3PSCo9cZTzP6i74EC+s3bYYj3FotEhAV
	 HpiSCsbVAHX9fngW03yFW/g1aNfCKbi5z9SPchsC/Zbmk5OokemmeFn+ONkSXrRWtGA==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1794657339;
	h=DMARC-Filter:Received:DKIM-Signature:X-Google-DKIM-Signature:
	 X-Forwarded-Encrypted:X-Gm-Message-State:X-Gm-Gg:X-Received:Received:
	 Date:From:To:Cc:Subject:Message-ID:References:MIME-Version:
	 Content-Type:Content-Disposition:Content-Transfer-Encoding:
	 In-Reply-To;
	bh=nJvs09p7QWIuuw8YOzj5TR133+2IJ5+yRajckn/hsO0=;
	b=Vb606juFbfBq4PPzI+1eeMoIlTlcO8Vzt0XOECuOIxqBVO3cHH2GDOUgu8Lb9VRZAuSs
	 s0xjSmrktHBzs6E6wXxFeWO9wjp9Zo06Qe8M+DmVUyoBoza0hT+vjU8KhNQ/OwYUKO/2e
	 ABItgh6eVFhSwiBQuZ/k3jsXnUfbM0jI0yaXmBnqJEIrf2UyhgvOVRp6GOlaAjOJDcR1e
	 cFrkdeKefE18fbgIFcXSh15jP//79sLS2Fs9w8FiHR39j1gg4ueDrBTIQgIzZjj1iw0Mq
	 fqNmFY++K8+7ICXxq4xm95FL7Z4wzxCQn8lAZrZsGonb54EOVYiYWijkDH3W3Th1mSw==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dmarc=pass header.from=gmail.com;
	spf=pass smtp.mailfrom=gmail.com;
	dkim=pass header.d=gmail.com header.i=@gmail.com header.a=rsa-sha256 header.s=20260707 header.b=MrTBjpIE;
	arc=none smtp.remote-ip=209.85.208.46
Received: from mail-ed1-f46.google.com (mail-ed1-f46.google.com [209.85.208.46])
	(using TLSv1.3 with cipher TLS_AES_128_GCM_SHA256 (128/128 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1) server-digest SHA256)
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 72D2C606A339
	for <linux-nfs@vger.kernel.org>; Sat, 14 Nov 2026 11:55:38 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.4.2 smtp.subspace.kernel.org 72D2C606A339
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=gmail.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=gmail.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.a=rsa-sha256 header.s=20260707 header.b=MrTBjpIE
Received: by mail-ed1-f46.google.com with SMTP id 4fb4d7f45d1cf-6b577addee9so3416710a12.1
        for <linux-nfs@vger.kernel.org>; Sat, 14 Nov 2026 03:55:38 -0800 (PST)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20260707; t=1794657337; x=1795262137; darn=vger.kernel.org;
        h=in-reply-to:content-transfer-encoding:content-disposition
         :content-type:mime-version:references:message-id:subject:cc:to:from
         :date:from:to:cc:subject:date:message-id:reply-to:content-type;
        bh=nJvs09p7QWIuuw8YOzj5TR133+2IJ5+yRajckn/hsO0=;
        b=MrTBjpIEXzsSZaANjc7oExJhwGnF+j3pBQoJGLV3AozjECewWnT/dOn8PoCfUIeYGI
         mRgldWBhVoyoY4kjpOu/TkcCPMpetn8bMN74Irqnk0JnK5MAQS777TE3iVfENO0qNvUE
         8qb82pxhdLikkA/6tATGUpByZMee1vHTbdl6A6vtosorr3+hE9wD/mpuH76lS1WAZqyn
         nUdTyabyG8UAyWqGnpYJGfY62DgpvBldD5kNADP5MARyaYxmHHJYDsQkr6qVKrnaldzF
         KHIyaxdpU8Pcl80WjVwUUXXw+yU81KD0D8RdN7wE6Dhf//BzElFXAKq/AgQBu3vGzFII
         7JmQ==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20260707; t=1794657337; x=1795262137;
        h=in-reply-to:content-transfer-encoding:content-disposition
         :content-type:mime-version:references:message-id:subject:cc:to:from
         :date:x-gm-gg:x-gm-message-state:from:to:cc:subject:date:message-id
         :reply-to:content-type;
        bh=nJvs09p7QWIuuw8YOzj5TR133+2IJ5+yRajckn/hsO0=;
        b=FTiOQJXO1ansyed6SYbku6tlzxh1XHyWZqzlpvFaNa7DPnyU6Ta9jrgmCEUhHW4NUZ
         EPpnhJzuMM/I+038H4dzDE/vLoFaM9jtfDbU1pR0dechVjpUZqlPwQxcjIxdbu1iD32X
         gBPxTMpK835e46qwaM6RkbxQ7D3UwH9kmhLnH0fZgTYxekOb/Mxness5fNOWJO4ltYNY
         /KeRTiIdCaMMyYZgPoYnkvWR5jX1XK39Xp8jwaNtfBD17sV8yTtN/uT1z+1E+ncjm0Ki
         PiMT1OgU0r1q1xt0UIuD8gmNhA0lzpOAZzeUy1a+O5a+droXCe/hfwxXw8CxJn3NlCuE
         EJrQ==
X-Forwarded-Encrypted: i=1; AL+hErFAiAUlairJRY554bySfEU7l80oTSgZD3breO+MhLkwsvI/L2JogkwXYemVRyGS5DInA0j9h4qCE7E=@vger.kernel.org
X-Gm-Message-State: APuU4Z+HmJgwuyvkJm0BCriz9GOB747fW7saaBKejtKsfq6M3timdmTo
	J7fuFxpcF1v1dJ4GRmhHjpKPIigIbaeuq7MwaWllDAFgfyewWMX0mrti
X-Gm-Gg: AYBFou2yfMu11b+MxDl3OUWJr80M1D66vHFh4g8uQgwWldn5oOgw5fF58nQ6Q/xQvQV
	ZdJuISorzgxQH+vAW816t7Ir2vXPTIxVng5703DAJsWG8RYd0c+LZbOZYvLpBPR0vo0Wm6uKvV6
	Fw/eztFU1c0OfElrFvu+gyjWMGObRLszhVbmeZ9JQy05XcVsfbpJ1wNpDUhPHMA1/f7NwFUJMVR
	yneegd2LOv5F1MBynNq4yXggse+EyVZ5t9SKin4kY0ABKwdKB+AtOFIY3nh6rh9ppOCezylgBFy
	Nu1bExmuCjm2Ri6U/zodOetuHKdbHCdk6UFaehJc6mXaeaobGHvKafGLy/M6LsvhwA6M+lUW2vM
	Kl1GOD171ohuUeef+Rn4PYxWJ4nRz2E/0vtDIRHSYmostQlmQvZ8tMopaW4fhH0cpQRnUIfMLr9
	Wisyl+ONJSF2mGwVRJPcBihKZ6UnOO2k7TjPlpUCCTNqUM1XEMTMoWmqQ/zQKPGA2x00l8k/yGJ
	QlFTmXRNeakLwkkY4pyCbchcqRiNdhJxeAOvl5PUweuuUOXxy0AnNtQl6o5E6WnnlW09WpCIrhU
	Sh6nwix9FFeE8mZzdeVvPUc0hG/wgzoWj+G/TSJb2tKtc9ky04Kt+HPFB0IS64bWGgVWt4mEs6P
	SvYyOx7xx6t0=
X-Received: by 2002:a17:907:3e10:b0:c40:231:6eab with SMTP id a640c23a62f3a-c5096370c31mr441592966b.16.1794657336589;
        Sat, 14 Nov 2026 03:55:36 -0800 (PST)
Received: from localhost (178-84-201-199.dynamic.upc.nl. [178.84.201.199])
        by smtp.gmail.com with ESMTPSA id a640c23a62f3a-c5095b41f44sm206223866b.31.2026.11.14.03.55.35
        (version=TLS1_3 cipher=TLS_AES_256_GCM_SHA384 bits=256/256);
        Sat, 14 Nov 2026 03:55:36 -0800 (PST)
Date: Sat, 14 Nov 2026 12:55:35 +0100
From: Amir Goldstein <amir73il@gmail.com>
To: Alexander Mikhalitsyn <alex@amutable.com>
Cc: Christoph Hellwig <hch@lst.de>, Christian Brauner <brauner@kernel.org>,
	linux-fsdevel@vger.kernel.org, Jann Horn <jannh@google.com>,
	Chris Mason <mason@kernel.org>, Josef Bacik <josef@toxicpanda.com>,
	linux-block@vger.kernel.org, linux-kernel@vger.kernel.org,
	linux-nvme@lists.infradead.org,
	Alexander Viro <viro@zeniv.linux.org.uk>, Jan Kara <jack@suse.cz>,
	linux-scsi@vger.kernel.org, target-devel@vger.kernel.org,
	driver-core@lists.linux.dev, linux-mm@kvack.org,
	bpf@vger.kernel.org, linux-security-module@vger.kernel.org,
	selinux@vger.kernel.org, apparmor@lists.ubuntu.com,
	linux-nfs@vger.kernel.org, netdev@vger.kernel.org,
	fuse-devel@lists.linux.dev, linux-efi@vger.kernel.org,
	xen-devel@lists.xenproject.org, ocfs2-devel@lists.linux.dev,
	linux-s390@vger.kernel.org, linuxppc-dev@lists.ozlabs.org,
	linux-usb@vger.kernel.org, linux-erofs@lists.ozlabs.org,
	linux-kselftest@vger.kernel.org
Subject: Re: [PATCH RFC 38/41] fuse: refuse files on pseudo filesystems as
 passthrough backing files
Message-ID: <avhMN39TECaur0sS@amir-ThinkPad-T480>
References: <20261110-work-loop-pseudo-v1-0-4c998976c6c7@kernel.org>
 <20261110-work-loop-pseudo-v1-38-4c998976c6c7@kernel.org>
 <20261111151202.GA11391@lst.de>
 <fb1d72cf25d10a960da627f6d93a3e041820ed3a.camel@amutable.com>
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Post: <mailto:linux-nfs@vger.kernel.org>
List-Help: <mailto:linux-nfs+help@vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
List-Owner: <mailto:linux-nfs+owner@vger.kernel.org>
Precedence: list
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <fb1d72cf25d10a960da627f6d93a3e041820ed3a.camel@amutable.com>

On Fri, Nov 13, 2026 at 11:25:57AM +0100, Alexander Mikhalitsyn wrote:
> Hi Christoph,
> 
> On Wed, 2026-11-11 at 16:12 +0100, Christoph Hellwig wrote:
> > I've seen setups where people use fuse to mediate access to sysfs
> > sysfs in odd ways.  No idea if that's still around, but if so, this
> > patch will break it.
> 
> 
> Oh, that's painful. Do they use backing files for that?
> It's a relatively new feature in FUSE...
> 

Very unlikely that they use FUSE passthrough and if they did
very unlikely that it would break their filesystem.

The API for fuse passthrough is that the server requests to setup a
backing file before open via ioctl and if ioctl fails (as this patch
does) then server falls back to non-passthrough open.

The ioctl can already fail for many reasons such as MAX_STACK_DEPTH on
procfs as the commit message says, so server needs to cope with the
fall back.

Thanks,
Amir.

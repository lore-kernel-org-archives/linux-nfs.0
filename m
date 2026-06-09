Received: from mail-wm1-f52.google.com (mail-wm1-f52.google.com [209.85.128.52])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id EBF8C3EB0E6
	for <linux-nfs@vger.kernel.org>; Tue,  9 Jun 2026 23:08:10 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=pass smtp.client-ip=209.85.128.52
ARC-Seal:i=2; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1781046492; cv=pass; b=Gnu3VxWdOyjG0fEK11sKvVdFSj6bFCAMS+8+8yIu7vUV32VqSrHp20/X0lKsqRmX4zV5gUEnBwCTUwNuMnwCEMZSXZaGuhbjv9fQwBqyNMluE7hegzjcvBLjBjX4gfLugrKmShMgaJ5t/voevfO/a1TdcLQW5tAsodsYzDbUXq4=
ARC-Message-Signature:i=2; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1781046492; c=relaxed/simple;
	bh=lUNML/CtRaOtfhfzL41BEZRHNRZPiV+5BPccaXoScnk=;
	h=MIME-Version:From:Date:Message-ID:Subject:To:Content-Type; b=bZpB8KGmM1dQmqlIZ+MSHE8RPxEwITSmSostynfry0RMVSa6yeODgvLTiSAagB+rB8sfzQVnqS6L1lQUhWwfCv6jqd88jB7/kV+Njnwd/KYIzA+S5PV76ZIgfGIWafiGt7NhpSGS7JK9BjLVOG8q7F7McsumlST6mWxtj6AMjno=
ARC-Authentication-Results:i=2; smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=gmail.com; spf=pass smtp.mailfrom=gmail.com; dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b=ovjP2ddf; arc=pass smtp.client-ip=209.85.128.52
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=gmail.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=gmail.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="ovjP2ddf"
Received: by mail-wm1-f52.google.com with SMTP id 5b1f17b1804b1-490b915ded5so52657865e9.3
        for <linux-nfs@vger.kernel.org>; Tue, 09 Jun 2026 16:08:10 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1781046489; cv=none;
        d=google.com; s=arc-20240605;
        b=YZK+eOKbKCnoLgeQO+8LM3cUrrtZzPDLNOgAbhm+hXFUJhnTBYP+lgmjUSKc8MonYQ
         P4thMePBoAXctE3asy/gcZ1eDLndAeYonxaCF0DXONRS6G7kq3hcSVEhGKM5nG6XH0J4
         UpOX5b38hzXoAcMWgnKdBqcPm6VRCHihXlK+URSyYNKil+7Gl2I78eDcrDD1fmoBOzHn
         Yn6cU1q44p8prVOBetL1BscX0QBbrc4UXJ43O3Zrc4B4PNdG0zzv2VJsa3e12rIx1EOG
         HFT8iPC/YNSYFVsScRQ7GoiZdrc/YEr7UiGuCpZV7JtWgsaz8LGwiyfOTLlFr+kfT5/b
         6LNA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20240605;
        h=content-transfer-encoding:to:subject:message-id:date:from
         :mime-version:dkim-signature;
        bh=TE7B9RQh0TU1kDQV4iAeS5kxsTjSujB4w0gqu1vGa7I=;
        fh=Mys3y4MwsHRytUQMpdfGBn3oGRYLcLloxNwkFYMYMmg=;
        b=HeMpbJ6fsM4eRHtH3kro90D6fBxmGcfDvgQj+7cMEA+2bNrrH4Lc7xJOCIbAro/Ydz
         B9QWC5RJrH9KxxlCuKCUvMOMPCUD0bWBipIxXNpXioJxJjppQSd0W+5/Q5QqszzpxuJ3
         rbbFG/Le+lKKFqDKLz7jRriBRlpzIUGRRU8rvoBtfmg7HE5KrdxX1qGG216zk3UM3uKP
         7EuAftzNvg/lo1TEEzS+zCMN8PNztBcZhHQJhf/HyNCI2CekNZwV5ECs5jyXFTaVM8Pi
         kYx6WijI7vxEWA3FoqNik3RAaEHVE3JQQrmfiBK92ujtNsWo43cDIZPIqMapyu50cXdP
         +cKQ==;
        darn=vger.kernel.org
ARC-Authentication-Results: i=1; mx.google.com; arc=none
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20251104; t=1781046489; x=1781651289; darn=vger.kernel.org;
        h=content-transfer-encoding:to:subject:message-id:date:from
         :mime-version:from:to:cc:subject:date:message-id:reply-to;
        bh=TE7B9RQh0TU1kDQV4iAeS5kxsTjSujB4w0gqu1vGa7I=;
        b=ovjP2ddf4i7J5Z5b4YGwJ2v+wOIG9iuzWE/IMavXcpf5Is63JkgAsrHS8lFJrxr/49
         mP6fzTPALJS7UZBOG8XmRuLKXizRQO/r5pMfCR9dOqa+6oUYltxb60iFhkrIUzeC07sL
         8gukgMuM9cRMfMIUl6wUTmNWT/JgRmXBwt1duAcdjdDdcKjCikkh0YuGrzJ4UqQ5krS7
         tm0Bol3A7zAMThu8GXPnNaAneFkDQYZULeC4LMhRKCPodI3dSktnhTFuaHXe/RAqIj7w
         uwKVK9NrNOtyTu3AGFBcdLtK+0TQslfYIuOlCEX9CxkpGdm9qKS44LRGx5CmOhvqo6eq
         9bUQ==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20251104; t=1781046489; x=1781651289;
        h=content-transfer-encoding:to:subject:message-id:date:from
         :mime-version:x-gm-gg:x-gm-message-state:from:to:cc:subject:date
         :message-id:reply-to;
        bh=TE7B9RQh0TU1kDQV4iAeS5kxsTjSujB4w0gqu1vGa7I=;
        b=W47T3tbZ/X3VXD1ZPM7CVaKE0rHh6c4H4J6MnBjIuKKYSuATfZArkqrqnuvgXmnNZW
         /m35GGA5BphtRUm3+Q2fQ4JjStM+RcxVF6FpyDfI59QG6+7mbLLMzgJtc8Vps5b2+JEy
         mGYhSWRMMbCEg7NKcBtnarsCMNwgeTg5z0M8+Z2qJwdTknh11mOjom00FRYvp9qm8/zk
         yunWDoxcX13+aLkx1rrfZTuh/F0Kklb3F1YvI2mK0gs+RhDSo9a9enJt4RQKQPV1Lryd
         W+yx9h58+oO2xrM4lS/h+TKPxH7G5t5YTEjdqWjufDyjuouF98prRjEVR4kPrxXy6y6y
         biwA==
X-Gm-Message-State: AOJu0YxXnp1ccjlDPf4M69ImyFDXh6qMl+zxX4Ed5WYjO0xZ6Rf1rHv6
	zNb7ktq8lqN1V1kxvUlcvkpU5+xjQFiJSGryCsQiCkIbYUQzuNj8raooyYOqyFV5UlLiKFytZtw
	287zcz/M26RmEIqHZ5+K5VwcDQ3Cf7VwzC00omRs=
X-Gm-Gg: Acq92OGqKz/wFI83g+C+RcEhvQ4ftjxLj7NLXklnsWNZixkLu0sV6302SAGg130sgpn
	6uKkv8Rz9woNStSniq1LeYENCN/rkefgHoUuFV/e0ClOWgGYL/vZndf7DUcsAALYtVpxdp7Hpen
	0H17OKsKZxEgoObxIRA6wu+xPn0oFLdqBuGxHhW8elzTAg93pybQsn6Br5eKIJTruU4w9vaRUm7
	BIAu+cNqUHh5S6GVXEByvYXZzWd2rxPlds3PkxZ6EczSnePAqtyHUAj0VGCqODfoGXmfMThxtF6
	nCeOReJfVheOapjMsyChSL+FwR8tRZslcEnvE5XM+eVJWgStYN4=
X-Received: by 2002:a05:600c:8a0c:10b0:490:c682:e37d with SMTP id
 5b1f17b1804b1-490c682e39dmr194150565e9.32.1781046489263; Tue, 09 Jun 2026
 16:08:09 -0700 (PDT)
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
From: Ubahakwe Emeka <ubahakweemeka@gmail.com>
Date: Wed, 10 Jun 2026 00:07:57 +0100
X-Gm-Features: AVVi8Ccy5t3g0EV0kBIADnkacGUQLFDSl2gW1k9zFjEVYdQGRInCmSkmPWvvyCg
Message-ID: <CAOBhB-TKRMtBPpXVhwu00h-vUJopZYzUnPkhAV6PWNoEDWz-mQ@mail.gmail.com>
Subject: nfsrahead SIGBUS crash on aarch64 for non-NFS block devices
To: linux-nfs@vger.kernel.org
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

nfsrahead crashes with SIGBUS on aarch64 when invoked by udev for
non-NFS block devices (virtio disks, loop devices, etc).

The udev rule 99-nfsrahead.rules fires for all block devices with no
filter for NFS-backed devices. nfsrahead is supposed to exit gracefully
for non-NFS devices but instead crashes in __libc_free() due to a
misaligned pointer =E2=80=94 a hard fault on aarch64, silent on x86_64.

Stack trace:
#0  __libc_free (libc.so.6)
#1  nfsrahead + 0x2074
#2  __libc_start_main (libc.so.6)
#3  nfsrahead + 0x22f0

Triggered for: 254:0 (virtio disk), 7:1, 7:2 (loop devices)

Fix needed:
1. nfsrahead should detect non-NFS devices and exit 0 gracefully
2. Fix the misaligned pointer in the cleanup/exit path on aarch64

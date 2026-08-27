Received: from mail-yw1-f181.google.com (mail-yw1-f181.google.com [209.85.128.181])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id DDBFE3F8893
	for <linux-nfs@vger.kernel.org>; Thu, 27 Aug 2026 08:45:54 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=pass smtp.client-ip=209.85.128.181
ARC-Seal:i=2; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1787820356; cv=pass; b=dVAAXGlMCB7uaJOui5Gsvk1jQVEMq3WJtv+AZXU4W3KhlIKXlGfkCeJ4JB5KwRrgRJulihD8A4IQHGkeVhJ1AuCoI8msvWbg2OiK3gskTtnT93/6590Qdrx82uiOogLm2/rVPXzhV1GoI4VKdB3+yhVO/+BVY4QbKdK3b84GC9I=
ARC-Message-Signature:i=2; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1787820356; c=relaxed/simple;
	bh=Z9WeisAG6TLxKmybrGHcFGk3e9/TcKEwwM6ZPWKRSNY=;
	h=MIME-Version:From:Date:Message-ID:Subject:To:Content-Type; b=aYtUqEc9yfx6K6sq8+UkBg2iqfqBZrxRt4IXg8t5PRoLoko7+U+HiaHU09hT87mN7ZHxfDBW5H5S3Y7+aRGQ+sULEM1qwUPZMXmGWSc2KETLO07UJycmHC4lMdMj8ptTNsb2T9rbWgOKvVKV8m24p5k2SjWYM0IaS/9peG2u+Ng=
ARC-Authentication-Results:i=2; smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=gmail.com; spf=pass smtp.mailfrom=gmail.com; dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b=Pn68qNfJ; arc=pass smtp.client-ip=209.85.128.181
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=gmail.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=gmail.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="Pn68qNfJ"
Received: by mail-yw1-f181.google.com with SMTP id 00721157ae682-81ed2a06b9eso19253827b3.3
        for <linux-nfs@vger.kernel.org>; Thu, 27 Aug 2026 01:45:54 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1787820353; cv=none;
        d=google.com; s=arc-20260327;
        b=ECwN0jVauVpM7ngjEE+Qq0Dn0rhMt49NZiND2HR1i0ozsIJ7SdeTSGTP4SpYc8jedv
         5VoGlYNK0mQ5w8OQaDUlbpgFIlq2SynFaKtvO+whn3PoVhytJ8zy48oqmjyASU3Ik3Cw
         x6999eCWNzfpYIISY/BB/JxgnSeHssN0IS9wdIKY8lZxr8LwFNquZ3S6cQc9k+FrhMZw
         l52r/iY5P0TzxtE3TtPuz2eeqTK5dyGLa2ltXqA8RS0zNiEgv7Q/wX1zu4+lfG/r/tmb
         zvFkM93BWGi3ofnI2lIacx4IF42K0F06G3OuXKhfTS465tKOaon9KQMyD5NWX04JVUrY
         4Jew==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20260327;
        h=to:subject:message-id:date:from:mime-version:dkim-signature;
        bh=Z9WeisAG6TLxKmybrGHcFGk3e9/TcKEwwM6ZPWKRSNY=;
        fh=Mys3y4MwsHRytUQMpdfGBn3oGRYLcLloxNwkFYMYMmg=;
        b=qfQiXUJBrQEMF+5K4btmfW6nCpbaesv4pncdxUoPqsd0ap7lKD6JOq20xJHWWaOYcF
         LMVXjInyL483pGdH6qcMutswShxdOma2Y3jk5++9K/EkZEdBYINQwzCXHqauWoKMk0vd
         6AySHfa9i740oqx6GZIMPGpqyq8fzUvT2PN2Wq90tPbrMwBgY5VWwGNazIXS7eAsc9sy
         O3aZBg/1pQdc76tJThcVdnfeGwowJsYDguHzAGItZOFuY+XymO8NpFZnt7X6Ce5X6qQW
         YgtsRMBgtNZuxZ0KKwEVmkaVRkHsd78FvtpnCRimklS4uq2LQIJjR2LCRYU63cYk1ys1
         1Amw==;
        darn=vger.kernel.org
ARC-Authentication-Results: i=1; mx.google.com; arc=none
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20251104; t=1787820353; x=1788425153; darn=vger.kernel.org;
        h=content-type:to:subject:message-id:date:from:mime-version:from:to
         :cc:subject:date:message-id:reply-to:content-type;
        bh=Z9WeisAG6TLxKmybrGHcFGk3e9/TcKEwwM6ZPWKRSNY=;
        b=Pn68qNfJWBnKP2XZYKWSai9ilvgbc05/wQjobICmptB8HC2cnChYj4USLV1uT6gU+d
         CIzmTbNZECm7NlFRjnfSty2CoPR+uM/HaeuACiya1ZDquLzYFHiIdj222YmrWVfgLQOH
         1tt6vvBa9Me6DFF2i2MMyv5RkbhDuMtTpeafw7xVvkIDEXoRVuGwDe7q8wk0FLx+iCIK
         niOiFoTcmuXQbtDYOTkIBiDOgX5eFLkQORn8aSR4I1qn8XUUnrTDhIPAqmaXsiBPVX5a
         sgrZA4ga1YemNqqkqqN1VuFrWQ2G9Fgqp5NpNBqLs1YDyczjg/OPccYvDOUUwKpdgPqp
         da3A==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20251104; t=1787820353; x=1788425153;
        h=content-type:to:subject:message-id:date:from:mime-version:x-gm-gg
         :x-gm-message-state:from:to:cc:subject:date:message-id:reply-to
         :content-type;
        bh=Z9WeisAG6TLxKmybrGHcFGk3e9/TcKEwwM6ZPWKRSNY=;
        b=Brmqb9AqyW3GFcoyADOXB6V4uYqAo4mBCjGObsLwZEYE78rmrjPfBMMK7UJYcPWBF8
         j/i69rCorOqa9Ndz+mf51Vp0YkrWx9Kcpp5DmqAiSJpDJZA9/fxKjrpxtdJygF5re+5Q
         Zch372gm2z1hlvCQKuHBCtsCxaCHHdCLVSXv+R5qWJU9o+5HrmxgqbIpCycZTYAHbmMa
         KsBdwd2xXNiLhlTfNuKm5x4kBdDGCvdPRTimi2ce/tfcPxe3q53BhGNA4XH0jz+Hgwu4
         +du5a2YdbQFMZzHHb2UuDXGe1EwmW1oNFiGHuCRJlqTgPwJUENoi0ERe3vx8sm5XrOdi
         rDfQ==
X-Gm-Message-State: AFuF++nY9IItu0r1VV+vkixPqKNHM7xgw3ByjrrGL3UEw9O2IzOyD97Q
	a3AxGrEsHE6m50aDwvoLiEBTypqbl1UQ3FYR0HQUIcJC40KoW5BN5ogsArGwd5YVGvDAlXmvW6B
	hzmdE6BVNCl4YT0QkXBB7xxELse3jwXj2CHRvdQU=
X-Gm-Gg: AR+sD11TSJizmv7alnxMoksdgjDOdaptcPNcY3YcZN7GYr6R/4+IznD71ulhVvAdatx
	vT2XtqdmM3H70VBA9PwhLKP8zxLbhCNgZayZND6RikwYRJDDgvcoBdunu8vccRNyUY5LrpYhF6P
	00UcyUocKaEu3JHhwq++4MwyivZEBjMPQTGkq975NsV+hBxrfbHMEgQSPRiWGSfdziVc22lJNfa
	eRQfcQ0kvZGwuj/9GKDsY8ZtcP0sqWqwaPA+wHmeMa8EvaN4ynrZMiyTIxn+MI6gPKbprmJNv9J
	m3C0F3OVeFs9BYexMPUsTzI2urIl+ZPDMPgk200FpOT8Pbq0qCcjY9UcKJiLvh/YsOLdefI8B52
	dFOfC6WyDeycz3v3YZ+d4FlJRIpI7goTEE261+e7/6WA=
X-Received: by 2002:a05:690c:7091:b0:820:b24:27c7 with SMTP id
 00721157ae682-8573d58cc99mr70404997b3.14.1787820353579; Thu, 27 Aug 2026
 01:45:53 -0700 (PDT)
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
From: Kris Globtrotter <kris.globtrotter@gmail.com>
Date: Thu, 27 Aug 2026 10:45:16 +0200
X-Gm-Features: AcwNN1XpaIW0eBHitazJmmLlqukTP3cBRSFwVE6n7YUZ1tUbfQkJktWC-9HelfY
Message-ID: <CAGD-p3J3nnDhghOMCOy6jk0UQzBysut1sbS7wn6bdF75KZJPbQ@mail.gmail.com>
Subject: NULL indirect call in xs_read_stream_request, leaked socket lock
 wedges all NFS traffic
To: linux-nfs@vger.kernel.org
Content-Type: text/plain; charset="UTF-8"

Hi,

I'm hitting a crash in the sunrpc receive path that leaves the machine
permanently unable to do any NFS I/O. Five occurrences since Aug 8, MTBF
now around two days.

Kernel: 7.0.14-12-pve (Proxmox VE, built 2026-08-11, based on
Ubuntu-7.0.0-31.31 plus later CVE cherry-picks)
Client: NFSv4.2, hard, nconnect currently off
Server: TrueNAS SCALE, in-kernel nfsd, same physical host (client is the
hypervisor, server is a VM on it, traffic over a virtio bridge)
Workload: ~1100 concurrent torrents plus media scanners, so a very high
rate of small RPCs

The crash:

BUG: kernel NULL pointer dereference, address: 0000000000000008
#PF: supervisor instruction fetch in kernel mode
#PF: error_code(0x0010) - not-present page
Oops: 0010 [#1] SMP NOPTI
Workqueue: xprtiod xs_stream_data_receive_workfn [sunrpc]
RIP: 0010:0x8
Call Trace:
 simple_copy_to_iter+0x3e/0x70
 __skb_datagram_iter+0x1b8/0x2f0
 skb_copy_datagram_iter+0x39/0xc0
 tcp_recvmsg_locked+0x836/0xb00
 tcp_recvmsg+0x83/0x1f0
 inet_recvmsg+0x51/0x130
 sock_recvmsg+0xb6/0xc0
 xs_sock_recvmsg.constprop.0+0x2c/0xa0 [sunrpc]
 xs_read_stream_request.constprop.0+0x255/0x4f0 [sunrpc]
 xs_read_stream.constprop.0+0x2b3/0x450 [sunrpc]
 xs_stream_data_receive_workfn+0x71/0x160 [sunrpc]
note: kworker/u80:6[316889] exited with irqs disabled

RIP is 0x8, i.e. an indirect call through a NULL struct at offset 8,
while copying a reply into the request's receive buffer. My reading is a
use-after-free on the rpc_rqst, but I have no reproducer.

The part that makes this fatal rather than merely noisy: tcp_recvmsg()
takes lock_sock() before calling tcp_recvmsg_locked(), so the worker died
holding the socket lock. Three hours later another rpciod worker was
still here:

[<0>] __lock_sock+0x7c/0xd0
[<0>] lock_sock_nested+0x54/0x60
[<0>] tcp_sock_set_cork+0x19/0x60
[<0>] xs_tcp_send_request+0xe3/0x360 [sunrpc]
[<0>] xprt_transmit+0x1be/0x4b0 [sunrpc]
[<0>] call_transmit+0x7f/0xa0 [sunrpc]
[<0>] __rpc_execute+0xbb/0x4e0 [sunrpc]
[<0>] rpc_async_schedule+0x33/0x50 [sunrpc]

Waiting on a lock whose owner no longer exists. Every subsequent RPC
queues behind it, load climbs past 65, and "nfs: server not responding"
appears even though the server is idle and responsive throughout
(verified independently on every occurrence). umount -f, remount and
service restarts are all futile since the state is in the socket. Only a
reboot recovers.

The same two functions (xs_read_stream / xs_stream_data_receive_workfn)
appear in both traces I've captured.

What I've excluded: hardware (6h stressapptest over 103GB, zero errors,
zero corrected ECC in EDAC); nconnect (the first occurrence predates my
enabling it, on a single transport, with the same __lock_sock
signature); the server side (idle and responsive every time).

On the taint flags: they are P O and come from ZFS, which this host uses
for local storage. There is no proprietary GPU driver. ZFS does not
appear anywhere in the call path, and the crash is entirely within
sunrpc and the TCP receive path, but I understand if that limits how
seriously this can be taken. I can't easily run a vanilla kernel here,
though I can test patches on this machine if that would help - it
reproduces on its own every couple of days.

I've disabled NFSv4 directory delegations as a first mitigation and will
report back.

Happy to provide anything else useful - full dmesg, mountstats, or
sysrq-t output at the next occurrence.

Thanks,
Kris

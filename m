Received: from mail-wr1-f46.google.com (mail-wr1-f46.google.com [209.85.221.46])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id A8878493644
	for <linux-nfs@vger.kernel.org>; Mon,  7 Sep 2026 11:33:54 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=209.85.221.46
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1788780836; cv=none; b=WoC8NKZHg4mWGtZzXeYkYTQN9BqBBsMRkWirJrhPkX8HIIUUNYZo/8euEIJ9GvXjHV6bT+DMzlsp+Gtfc8F0ipq4ARgL9swuopwiweJh62OwqhSlM8L+L6PwrVMy2XEVQ0fDzz6I+c/exmFkgTSrt4BtmexIgzsMsu7D2b57TIw=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1788780836; c=relaxed/simple;
	bh=VbAm5gQ4lOTh977mKX5Ftao7ID7EB5fAOAV24miNJoA=;
	h=Message-ID:Date:MIME-Version:To:From:Subject:Content-Type; b=uwhXhA4luhp6MIpnn8Hc1UQb4o+/pwdpG+F9qn9TkTObNwQErs+RGJ6+4yk9bw2A4ZsK+5AIix5TXPlf2Ud0P9uZJYTfmPjMbFx1SCbXAHT2j3lpFtw5V92UY5mkwL/cvdJx04U5gdOzneq0/RN13+aoL4K6OTGu7tdMNXsb3sE=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=gmail.com; spf=pass smtp.mailfrom=gmail.com; dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b=Rojqy3AJ; arc=none smtp.client-ip=209.85.221.46
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=gmail.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=gmail.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="Rojqy3AJ"
Received: by mail-wr1-f46.google.com with SMTP id ffacd0b85a97d-482f2ee53e7so2512483f8f.1
        for <linux-nfs@vger.kernel.org>; Mon, 07 Sep 2026 04:33:54 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20251104; t=1788780833; x=1789385633; darn=vger.kernel.org;
        h=content-transfer-encoding:content-type:autocrypt:subject:from:to
         :content-language:user-agent:mime-version:date:message-id:from:to:cc
         :subject:date:message-id:reply-to:content-type;
        bh=9xIXvKdhQcbnfEEWsOpdRrLXh0w89q9I/9DjqGfFqY8=;
        b=Rojqy3AJulGmCjdvpjoUUeCMKaL634ieIWFMrtY4TN4AThN7NuMbolEPMjz1/49+fy
         XiLSte2p+treFAWskJPWwdQWLaBW/sBcQz4wH1RKQU6SMBAaaAue8xjb4u95IuZ/Hd58
         6ReDHgVTZ8ohOAyfoh+2xmSj2/BRqwX7IJqTsIwO6F+ecwP09S2qHsMMz4Dn+AZuZne9
         WvdzBjhecO+AZft10bHVvG/R2N6Xhsv8XPqNzcRt43ejbnkFNfIIVJI8yfjsgIxVbTWH
         36vNFhgfemHMWcJm6ioS41/l+L/5jqJJcc6UiRpja6OyQhkR2m4Auk294Ek3rpgxjwTb
         g6Zg==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20251104; t=1788780833; x=1789385633;
        h=content-transfer-encoding:content-type:autocrypt:subject:from:to
         :content-language:user-agent:mime-version:date:message-id:x-gm-gg
         :x-gm-message-state:from:to:cc:subject:date:message-id:reply-to
         :content-type;
        bh=9xIXvKdhQcbnfEEWsOpdRrLXh0w89q9I/9DjqGfFqY8=;
        b=MvmiMRzMhnvTAPC6Lib9hWaXS0vcFX2pm2V0IfEt9Eztm5Xp1vIYwdt9fBqnL0Bf5X
         hqG9bG7nje0zFPx2LVwBcAnZiiZQHUGT4N49PnRpvm38/zRKgeaEx6dgUOWyE/f0NS0W
         n3FRAFq5ii1gCDnnc4zGYVpGR8zXSPbAH8BvDmY2LfyzPB2mw1t7D3Y3/DeSPHJRaOAM
         bQwmycxPPp6Sp5cWiUw0HWu0JOxgnP/iQVMDxi3kmCQA1VMHLpPicTV4HZ3pEsq2mE8J
         vOzd3khf6wklUvvp2YEroBgbc0MhqAF9MNyRtaOYXKphvlYtojG5C6+C0G9cHw7vnftN
         PLhQ==
X-Gm-Message-State: AFuF++m90eoYGDCL58B9BtcbxogTEvJHAkSNDBsiCf0uhUuAVZBkoRT7
	WkJX/Tnp836vC1EHqhVWBssaCnHKqGnP+NNShLxr7hXiqFN//xx+dgCbVz0RcXTs
X-Gm-Gg: AYBFou3AOWI3WJ/qIpgFtxzN1U9+3q56P/G4U3xMqZYNzerkIyVkc+BBqIZWHviD17Z
	FJeOpf06DxQY9Ax6dvqUf28cW6htIEW+5clWMn6TqydOl0gM6qaMza3Y4kC+UjH9vNcsgXug7kS
	B4L+QZd12RXFlzvmpvHCvxaxulflOB4D2tOuxvxquH/DGo5VHjfCGYRwoyB7rpxVstYlahCIHDp
	mfC6AN+ckUozj7OO+J0srzxHuHqW+VWAOZO86XA9HqGqSKRQdii44ZtzQSEbRVGb1n5czCrMIh/
	g/2HgCXRuaZIUtxEF4diVeWRoKer2MIstCveS6WCobqnJTQQKkcGXKp1D6c8yWdVazF70k7CUK3
	iuPuim7NKgZCib2o4JJOfuRM9obGby1ioB/4ohrsY+x7et2UJUChOV9M60XkZhmGzxLaLJQIaJp
	Xu2jMVTeKd8qJ8BRejkDyKFzEWNNWVShbsxBFJtUhyLDYOFCQ8C3HT/NIBojPcd6CvNzWPqfkqS
	l2kPnLiK8hWGUeNeFe/8AeO30bEQwiXxhnLIB0aIrUZ1w/c6FnYoaPDIw==
X-Received: by 2002:a5d:5f94:0:b0:485:8c17:975b with SMTP id ffacd0b85a97d-4858c1798cfmr20005076f8f.29.1788780832516;
        Mon, 07 Sep 2026 04:33:52 -0700 (PDT)
Received: from ?IPV6:2001:778:e27f:a23:36c4:e19f:3c1:8a8? ([2001:778:e27f:a23:36c4:e19f:3c1:8a8])
        by smtp.gmail.com with ESMTPSA id ffacd0b85a97d-485883a9b49sm23766494f8f.17.2026.09.07.04.33.51
        for <linux-nfs@vger.kernel.org>
        (version=TLS1_3 cipher=TLS_AES_128_GCM_SHA256 bits=128/128);
        Mon, 07 Sep 2026 04:33:51 -0700 (PDT)
Message-ID: <920a1a2f-ada8-4a9d-93a7-31922a0079af@gmail.com>
Date: Mon, 7 Sep 2026 14:33:49 +0300
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
User-Agent: Mozilla Thunderbird
Content-Language: en-US, lt-LT
To: Linux NFS Mailing List <linux-nfs@vger.kernel.org>
From: =?UTF-8?Q?Mantas_Mikul=C4=97nas?= <grawity@gmail.com>
Subject: crossmnt exports partially broken in 7.2?
Autocrypt: addr=grawity@gmail.com; keydata=
 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
 aETxZy4lQ+jpsbG/q9fvS/sAZA==
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 8bit

Hello,

After upgrading an NFS server to kernel 7.2.2 (from 7.1.11), it is no longer
possible to mount filesystems that should be handled by a "crossmnt" export.

For example, with /etc/exports being:

         /       *(rw,crossmnt,sec=krb5:krb5i:krb5p)

and all clients using NFSv4.2, it used to be possible to either mount 
foo:/hdd2
directly, or to descend into it through a "foo:/" mount.

With kernel 7.2 this no longer works -- after mounting foo:/hdd2 all 
attempts
to access it result in -ESTALE and the client's kernel complains about 
"fileid
changed":

         # mount horizon:/hdd1 /mnt

         # ls -l /mnt
         ls: cannot open directory '/mnt': Stale file handle

         # dmesg | tail -2
         [374226.359731] NFS: server horizon error: fileid changed
                         fsid 0:150: expected fileid 0x2, got 0x100

Mounting "foo:/" on /mnt and trying to stat /mnt/hdd1 likewise returns 
-ESTALE.
(Or hangs for a while if it's a autofs mount on the server side, but I 
switched
from systemd.automount to regular non-autofs mounts for now.)

In this case the server's root filesystem is Btrfs, additional disks are 
Ext4.
Another system with the same problem has Btrfs for both the rootfs and 
for the
secondary disks.

Bisect points to commit 70b7e3526c53d9dd7caccdbeff5b0485640d8cf1 which 
adds a
netlink interface for nfs-utils' rpc.mountd to use. Indeed if I disable 
netlink
support there (adding "[mountd] no-netlink=1" to the server's /etc/nfs.conf)
then crossmnt exports again start working as they should, even with 
kernel 7.2.
I've also tried kernel 7.3-rc1 with the same results.

Does this look like a kernel bug, or a nfs-utils (rpc.mountd) bug, or both?
The server has nfs-utils 2.9.2.


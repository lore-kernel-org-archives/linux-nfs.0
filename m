Received: from mail-oo1-f69.google.com (mail-oo1-f69.google.com [209.85.161.69])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id B5681352C3F
	for <linux-nfs@vger.kernel.org>; Mon,  7 Sep 2026 19:31:02 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=209.85.161.69
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1788809464; cv=none; b=bsxPTq7SRabzX6XKfqC2JGAw3fHpS1Bf3vmc56SRsRTHGVnjXWGc7R3anpScoJRy1hQMi39soiaNPENN5x9wPPcvgW3oHRnyCt/0LUG8WcTYu5KoaD68tOBwJGMEKncCdPFExPnhterFxxmZNzdfvys7A5QOhTBoW2Kp3JvYoq8=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1788809464; c=relaxed/simple;
	bh=Y/f7gKfTtD3caAROXXmlez0v7+lxdkmJJ2ksmNTB8Bs=;
	h=MIME-Version:Date:In-Reply-To:Message-ID:Subject:From:To:
	 Content-Type; b=KCrknc3geOlTuMBbZ93HXm0n05ytq0MzQ5oxAD4M3QLE95Xy2moONZhLZC56bjDiGEfmYGUXUkcf3bl6wzjMbllQ+6L7J7np9IHyPoAQS1B9Z4F14OoSXbFgsl2ieTXD5CMx+sDbjIzrOvl/O+IRy8ZDRhNKF0pUwzXvLReJjBg=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=fail (p=none dis=none) header.from=syzkaller.appspotmail.com; spf=pass smtp.mailfrom=M3KW2WVRGUFZ5GODRSRYTGD7.apphosting.bounces.google.com; arc=none smtp.client-ip=209.85.161.69
Authentication-Results: smtp.subspace.kernel.org; dmarc=fail (p=none dis=none) header.from=syzkaller.appspotmail.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=M3KW2WVRGUFZ5GODRSRYTGD7.apphosting.bounces.google.com
Received: by mail-oo1-f69.google.com with SMTP id 006d021491bc7-6b352d9062fso4592922eaf.3
        for <linux-nfs@vger.kernel.org>; Mon, 07 Sep 2026 12:31:02 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20251104; t=1788809461; x=1789414261;
        h=content-type:to:from:subject:message-id:in-reply-to:date
         :mime-version:x-gm-message-state:from:to:cc:subject:date:message-id
         :reply-to:content-type;
        bh=7xhFNaP6KQHnAXOKkPy8YZJSop4UrDgQg8b1cvrfSdQ=;
        b=jl43GF9phx3dyn03Amqw8atkYLLdpSd1/rfQiLvRpLBOMx/GhmCAMgwYCIrbSVPWx0
         K4fqSjSS1adfOG8hBy7/X04FvNS4QgnNsAF1CCjr7+Uic6Ka9gWQZ8Tc9fXx8C5HP9Z9
         LvUYodGK90WO5nbZWMD/erzmUN4W41r2AOc6zbj99UIYMyrq31yAnpc/LIPqFISrYoNU
         L/1QDzTtHUooZEq3pL/F1SKcHiZOsHWHgHZpHjPajipXRUwTGmU5NmqVrVP9w7Ap5Vow
         jLKCtxgJW/VYZ5QK1bMYJ2UrmTbqpKymCsbowPVYfhpsEovz88vSBbiBOyo/lXYXsmis
         DvTA==
X-Forwarded-Encrypted: i=1; AKwUvBxtvtZg3pXZsCJy+kLVKNFm7WexkSYZejjPw+0x4f/CbIXL5bufRNYq7fUJeZY8y3ENyCEFrZkuN/Q=@vger.kernel.org
X-Gm-Message-State: AFuF++kTycomXVaz78t34Iy/yMPn3d+5rZPvVGnpprsoWk5zjFPMg9Uq
	aBMHCGJYsmNNjlVBjQ7qRkeN1fgeqwR7plpp1ciIXbHiocYqLU/3URBCj3DvUETiwCGVsAdhAU2
	bPBm1084EdSdFqa41HrtYcGXhu/anUfErqhZHCSUj+7GYgmh6V9APwPJngaA=
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
X-Received: by 2002:a05:6820:c3d6:b0:6ba:3635:800b with SMTP id
 006d021491bc7-6ba36359f2amr3741068eaf.68.1788809461737; Mon, 07 Sep 2026
 12:31:01 -0700 (PDT)
Date: Mon, 07 Sep 2026 12:31:01 -0700
In-Reply-To: <4c018446-e4c0-457a-b2d1-a5bf856d0e2e@slotpi15m67>
X-Google-Appengine-App-Id: s~syzkaller
X-Google-Appengine-App-Id-Alias: syzkaller
Message-ID: <6a9f10f5.2bb5a69c.24b23c.000a.GAE@google.com>
Subject: Re: [syzbot] [nfs?] [net?] KASAN: vmalloc-out-of-bounds Read in rpc_queue_upcall
From: syzbot <syzbot+d5c77cabf7a3492aa650@syzkaller.appspotmail.com>
To: cel@kernel.org, linux-kernel@vger.kernel.org, linux-nfs@vger.kernel.org, 
	netdev@vger.kernel.org, syzkaller-bugs@googlegroups.com
Content-Type: text/plain; charset="UTF-8"

Hello,

syzbot has tested the proposed patch and the reproducer did not trigger any issue:

Reported-by: syzbot+d5c77cabf7a3492aa650@syzkaller.appspotmail.com
Tested-by: syzbot+d5c77cabf7a3492aa650@syzkaller.appspotmail.com

Tested on:

commit:         5965280c SUNRPC: fix netns use-after-free in write_gss..
git tree:       git://git.kernel.org/pub/scm/linux/kernel/git/cel/linux.git nfsd-testing
console output: https://syzkaller.appspot.com/x/log.txt?x=1374eaf9580000
kernel config:  https://syzkaller.appspot.com/x/.config?x=8c5c3949d762a91f
dashboard link: https://syzkaller.appspot.com/bug?extid=d5c77cabf7a3492aa650
compiler:       gcc (Debian 14.2.0-19) 14.2.0, GNU ld (GNU Binutils for Debian) 2.44

Note: no patches were applied.
Note: testing is done by a robot and is best-effort only.

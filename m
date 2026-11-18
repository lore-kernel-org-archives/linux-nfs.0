Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=170.10.133.124
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1795009617;
	b=36AnIwIRSEJeF7uOE4kYLMSZq6JCDFPWIpgSg1YolJEtrsMeYe0Y2/7GR6xn2qzTzZ9N
	 Xk2EpxJcFVWMibVI9gDiXLw+1IwWiZUbi707w7+5+wDItjAla/t6lZJLEv2DYHQm+BPXq
	 qAjD+/Uh+MQKqYuiw1LjXicBXOWWHXUTRKilijN7jpcVl6G6VUaKHwaiG8q/AH7VoGFUK
	 FTvb2W0+ovKUd3p/baOe5JBUE8bth7L8ifPUA0po/g+Tmu1nL4p2dqjKeKeO7Er77hNZF
	 tP5DJCmTbZ0A+zZyvNuDMo1GiZDGB+41W4ag8ZlBDvKV6klM59NP2wmRw+nf2kW7UOA==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1795009617;
	h=DMARC-Filter:DKIM-Signature:Received:X-MC-Unique:
	 X-Mimecast-MFC-AGG-ID:Received:DKIM-Signature:X-Google-DKIM-Signature:
	 X-Gm-Message-State:X-Gm-Gg:X-Received:X-Received:Received:Message-ID:
	 Date:MIME-Version:User-Agent:From:Subject:To:Cc:Content-Language:
	 Content-Type:Content-Transfer-Encoding;
	bh=Tle8slx6NRf4k2tH58uKxVCUa6+6GOP504/OgqZ9PWM=;
	b=jCKPCt/aF3Aa5WI41KSsmaPdPVe33UvpKrTfi3OknyEuaOJ6MVjTWlUndBlXxl+rY7sQ
	 eLVVwBP1mUVuhwBhSNoXpFWMT1Eox+8Z6CAPbjo0Uus0m9NZYa4kIESyiTVBajFe/hAa4
	 sqGKiQt2qlH7C2gFbSYX/h0BDWP+H8gVJtEaYrP1P2pn/t6ngvUhP8sGLgEpuLFQk1otD
	 X9975mkR4dXGUzKrkeI8k9akCnRjUPebdhPAiLJz8LNO8+Seafg3qjFScAi8/W5NCfEPK
	 Xb6QODmeNtKmrfXmQfS1evSf1cuUifVOLYjSlfb/Zfh22QHWQ1epo7yW1JE6p9semjQ==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dmarc=pass header.from=redhat.com;
	spf=pass smtp.mailfrom=redhat.com;
	dkim=pass header.d=redhat.com header.i=@redhat.com header.a=rsa-sha256 header.s=mimecast20190719 header.b="iJmJC4/6";
	dkim=pass header.d=redhat.com header.i=@redhat.com header.a=rsa-sha256 header.s=google header.b=R81Vhsre;
	arc=none smtp.remote-ip=170.10.133.124
Received: from us-smtp-delivery-124.mimecast.com (us-smtp-delivery-124.mimecast.com [170.10.133.124])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1) server-digest SHA256)
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id D949D606A32F
	for <linux-nfs@vger.kernel.org>; Wed, 18 Nov 2026 13:46:56 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.4.2 smtp.subspace.kernel.org D949D606A32F
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=redhat.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=redhat.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (1024-bit key) header.d=redhat.com header.i=@redhat.com header.a=rsa-sha256 header.s=mimecast20190719 header.b=iJmJC4/6;
	dkim=pass (2048-bit key) header.d=redhat.com header.i=@redhat.com header.a=rsa-sha256 header.s=google header.b=R81Vhsre
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=redhat.com;
	s=mimecast20190719; t=1795009615;
	h=from:from:reply-to:subject:subject:date:date:message-id:message-id:
	 to:to:cc:cc:mime-version:mime-version:content-type:content-type:
	 content-transfer-encoding:content-transfer-encoding;
	bh=Tle8slx6NRf4k2tH58uKxVCUa6+6GOP504/OgqZ9PWM=;
	b=iJmJC4/6T43o0wKSn/TVA62MZ54e3ophj7kG0x3YGd/bdupV2/ry/mtwA3QxFD93tQhh6D
	MYhxeq1etQN+DOFOgTpSB7lUHnvieWFi5xyqX6UPuqYhW246Rrv3uNDo+JGdp3CbZQUh0c
	H07KLIruqtJ0hCvOPoixwfZM12zleoE=
Received: from mail-ej1-f70.google.com (mail-ej1-f70.google.com
 [209.85.218.70]) by relay.mimecast.com with ESMTP with STARTTLS
 (version=TLSv1.3, cipher=TLS_AES_256_GCM_SHA384) id
 us-mta-474-3cZXkXoFPD2MOzC4Mg1Ggw-1; Wed, 18 Nov 2026 08:46:54 -0500
X-MC-Unique: 3cZXkXoFPD2MOzC4Mg1Ggw-1
X-Mimecast-MFC-AGG-ID: 3cZXkXoFPD2MOzC4Mg1Ggw_1795009613
Received: by mail-ej1-f70.google.com with SMTP id a640c23a62f3a-c504991a35eso101192866b.3
        for <linux-nfs@vger.kernel.org>; Wed, 18 Nov 2026 05:46:54 -0800 (PST)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=redhat.com; s=google; t=1795009613; x=1795614413; darn=vger.kernel.org;
        h=content-transfer-encoding:content-type:content-language:cc:to
         :subject:from:user-agent:mime-version:date:message-id:from:to:cc
         :subject:date:message-id:reply-to:content-type;
        bh=Tle8slx6NRf4k2tH58uKxVCUa6+6GOP504/OgqZ9PWM=;
        b=R81VhsreHTWlGNDkDLoCfwrtBiVudVSPjGVZyUlGV+6CieFE4VoJxOwwx59pYOjV/n
         0dLy8+PL8oduxX5PK3Yfiom3DRud0qUxpBUyHuQuizixpM92pD0q/u5kph4rCcOHuAAu
         6K4LPc9Ve6yZ7hRa+JWPLlPjaMHSvSdWZZ2yYtyqsS1TG3cfln+m6yXyTNqW7OTruVS7
         B9i4aDZoNdgFYy5B5jwojYXQohPP11TpqgVCT+Jn1JZTeAi85bSNZ95Wu6TcQLPn2CeY
         ilEuoyfV8H/yp/LjxYhc0qRHJ9wNglTUphybsvuBrWbCA97cY+4VfePnheCDA153WEj3
         vBNQ==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20260707; t=1795009613; x=1795614413;
        h=content-transfer-encoding:content-type:content-language:cc:to
         :subject:from:user-agent:mime-version:date:message-id:x-gm-gg
         :x-gm-message-state:from:to:cc:subject:date:message-id:reply-to
         :content-type;
        bh=Tle8slx6NRf4k2tH58uKxVCUa6+6GOP504/OgqZ9PWM=;
        b=umwVsj2QizjNYI0ebjHe3MA2ILzq9vUMrfD3BTuiH0xFBKTlZydPw1hpAwwalqxzXI
         8105/2dGR4eig3QiZx2193uAhELNdEeGoCphQuHvYZMYacPylN+PGdQYWRYiOlLQmws+
         FdXeC/NVAnONMvr2NN2MYhv/et5ZHNDaI75R/3p2S58i5uFTp8ALDvsp0cY6RoF03RQ6
         vZ3pfD9xdk5mYjTASq/DVwQmq48WykX5KHgFklWguwShrNpW8d6iwyHl3UR52kL31Qpw
         pR+kRrJDyA6ZjaE3yHNzKViWa2/JpFAWgFZbkqkW3xitUcNmDNqvPsKRiwqWsH+t0i4p
         NOmQ==
X-Gm-Message-State: APuU4Z9JSUISEhCEKBV9nxidC6Ec2NLPKWCHx7ifZkjskqdiXpu9vIor
	wqmxWrbjVOkjeL8urq4dJmhIG3ZkX74hMC1sAbSJe59DAhwl3A6DhQpyBcHEf7bGUAs4dNmxXoa
	Qo8g52DgRHSVrG3YaE6DFobujeFPjxkEyFj6HDdhssx0T+pImSljMJ79b/lYZgtr5RfClmvWK56
	wyDMVLKnZjnPwtG86Jle+MkEU13qzlEp2Nan37L4Ijv/A=
X-Gm-Gg: AYBFou3onmsbzaI0m0UTUV5z9qJUio8zDPDoN6pv4Gh4+DCnrUi4Sku1ILcAGWMc43E
	8RdGRbUModRSm1nI/mXhdEfQoOxUjfp+TrISINAioJxYayK6k+ALZSBPhfVbqoRpsnNhHl8Z0BR
	xfFFfJ5O/7i9zuEfqDA7qhoqTUH+VEIkTnUe9kDq7lvS/yHrVBSm2SppqsTiGGKbRgnf0tfN/4h
	wU3xaBZnztqFLjXhZdNxykQlihbVXyS+APAZurTvoEalTPXmJiC3OcgdEtOyS2oIIRldhUjEy7V
	Qaj8292Va0N0OXxJ5Yvopp1DqYgWdVbNZxBGvarbVpjsJs4vX2agk9+zOOK1iA3uaungPRlBwZF
	eE4g8d2N7IQoXCtS4EkGOrAGcmnWl7y9kLNYK7Bj8IfCc64hk
X-Received: by 2002:a17:907:3d10:b0:c46:2987:2169 with SMTP id a640c23a62f3a-c510e345f4emr257885566b.24.1795009613242;
        Wed, 18 Nov 2026 05:46:53 -0800 (PST)
X-Received: by 2002:a17:907:3d10:b0:c46:2987:2169 with SMTP id a640c23a62f3a-c510e345f4emr257881666b.24.1795009612822;
        Wed, 18 Nov 2026 05:46:52 -0800 (PST)
Received: from [172.31.1.12] ([70.105.240.105])
        by smtp.gmail.com with ESMTPSA id a640c23a62f3a-c510ca626f9sm96843066b.37.2026.11.18.05.46.51
        (version=TLS1_3 cipher=TLS_AES_128_GCM_SHA256 bits=128/128);
        Wed, 18 Nov 2026 05:46:51 -0800 (PST)
Message-ID: <f172891e-9e1a-4dac-8a31-17c13683dcdd@redhat.com>
Date: Wed, 18 Nov 2026 08:46:50 -0500
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Post: <mailto:linux-nfs@vger.kernel.org>
List-Help: <mailto:linux-nfs+help@vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
List-Owner: <mailto:linux-nfs+owner@vger.kernel.org>
Precedence: list
MIME-Version: 1.0
User-Agent: Mozilla Thunderbird
From: Steve Dickson <steved@redhat.com>
Subject: ANNOUNCE: nfs-utils-3.2.1 released.
To: Linux NFS Mailing list <linux-nfs@vger.kernel.org>
Cc: "linux-fsdevel@vger.kernel.org" <linux-fsdevel@vger.kernel.org>
Content-Language: en-US
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit

Hello,

This is yet another mostly AI generated release
fixing vulnerabilities,,, but with two new commands
     * nfs-fh-verify
     * nfsd-iomode-advisor
both have man pages so take a look.

A number of mountd and statd changes as well,

The tarballs can be found in
   https://www.kernel.org/pub/linux/utils/nfs-utils/3.2.1/
or
   http://sourceforge.net/projects/nfs/files/nfs-utils/3.2.1

The change log is in
https://www.kernel.org/pub/linux/utils/nfs-utils/3.2.1/3.2.1-Changelog
or
https://sourceforge.net/projects/nfs/files/nfs-utils/3.2.1/3.2.1-Changelog

The git tree is at:
    git://linux-nfs.org/~steved/nfs-utils

Please send comments/bugs to linux-nfs@vger.kernel.org

steved.


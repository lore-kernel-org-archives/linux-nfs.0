Received: from us-smtp-delivery-124.mimecast.com (us-smtp-delivery-124.mimecast.com [170.10.129.124])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 076B3379C2A
	for <linux-nfs@vger.kernel.org>; Sat, 19 Sep 2026 15:40:09 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=170.10.129.124
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1789832412; cv=none; b=f4qxnf58SWD7cD0cuGZwJiZBRxA1Da8j0sVIt7QgYRVRuEd3zOCtF5UZWDAQUzD0awkxL50BgQ+n5O0CWry3nHpLzVBUPLbLd5VCOZQHyB6eFAmusW9KaNPzLQPh7GSarax4dLLgeSjOhHVGoDVz0Q6HTvp6nJ1EKX1pYG7MNZQ=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1789832412; c=relaxed/simple;
	bh=Y4aLsO7E5K1rlKqvYJbr/U4BDZy6IH6PStNFk6QKzPw=;
	h=Message-ID:Date:MIME-Version:From:Subject:To:Cc:Content-Type; b=kHLQL2qSG2mtKBvGdT3tO9TkYHOe+XfKUbfEOQU9g3NK8yHJ+tMtwzRIOiMzR/lZVcKeQYyjsg46RkqWnjgP1oantQOVd02Q4hWHymC6npO6z8VWcVYVAXK+gFIcCJqkCMZ9Pyasb/4iMDBIGiU58Uvm5c6zZ1IBq8aqthIK/G0=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=redhat.com; spf=pass smtp.mailfrom=redhat.com; dkim=pass (1024-bit key) header.d=redhat.com header.i=@redhat.com header.b=N4+Z9AFr; dkim=pass (2048-bit key) header.d=redhat.com header.i=@redhat.com header.b=t0qZlavM; arc=none smtp.client-ip=170.10.129.124
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=redhat.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=redhat.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (1024-bit key) header.d=redhat.com header.i=@redhat.com header.b="N4+Z9AFr";
	dkim=pass (2048-bit key) header.d=redhat.com header.i=@redhat.com header.b="t0qZlavM"
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=redhat.com;
	s=mimecast20190719; t=1789832408;
	h=from:from:reply-to:subject:subject:date:date:message-id:message-id:
	 to:to:cc:cc:mime-version:mime-version:content-type:content-type:
	 content-transfer-encoding:content-transfer-encoding;
	bh=13X+p5BlHvU1jlJef4qxKfLhScGAMJVOYykK2pEOeDw=;
	b=N4+Z9AFrTD2xjFrcBdxVHalKE51g3TSdkVbr5W40CWFQYAsL8dm9WuOTxFRVuWt5sAWhVS
	xgaftODe+mw4LjC18fsE5j+ZMUm88dpL4Uj5+NfTyYxwLfBA3U6rZQE2UCTx9qLAzIGeV8
	VYQXdP2XFrXs2fzzKjH1Fs6kOUSxn7U=
Received: from mail-qk1-f198.google.com (mail-qk1-f198.google.com
 [209.85.222.198]) by relay.mimecast.com with ESMTP with STARTTLS
 (version=TLSv1.3, cipher=TLS_AES_256_GCM_SHA384) id
 us-mta-3-H4GMJhzAN4W62Ew3QjcSTA-1; Sat, 19 Sep 2026 11:40:06 -0400
X-MC-Unique: H4GMJhzAN4W62Ew3QjcSTA-1
X-Mimecast-MFC-AGG-ID: H4GMJhzAN4W62Ew3QjcSTA_1789832406
Received: by mail-qk1-f198.google.com with SMTP id af79cd13be357-939f3426a7cso345715985a.0
        for <linux-nfs@vger.kernel.org>; Sat, 19 Sep 2026 08:40:06 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=redhat.com; s=google; t=1789832406; x=1790437206; darn=vger.kernel.org;
        h=content-transfer-encoding:content-type:content-language:cc:to
         :subject:from:user-agent:mime-version:date:message-id:from:to:cc
         :subject:date:message-id:reply-to:content-type;
        bh=13X+p5BlHvU1jlJef4qxKfLhScGAMJVOYykK2pEOeDw=;
        b=t0qZlavM6jModQLtcyTRGNUAWzOmXrx9sTODu0BdJTVsqJ+Qagt7ObKKVH4m7y4nzt
         YroQTFtuiGT0rcBZsQR1sBccOY7vtLScsfPhY+Q3UE07g9rTcAJypF+Qa/oyiDlGGKcU
         DjobItQRQoNQIDXRous2qGIMGAL68rlomPmsyzM/abZ5namfZTva16c9dlnxJ5fndtkq
         1VrI+Q4Ff9+yz3cQrmu7BFRoImcWC0o2xuTuGT73nsesbrGUiAoh1cgv18zlRaKJp4GC
         V29LZdaF7W+VzegUXlwNsPgjB7ggpJDfcSWrNFEHtv/JTQ+i7m9VH212zan83CztXzHG
         AC/g==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20260707; t=1789832406; x=1790437206;
        h=content-transfer-encoding:content-type:content-language:cc:to
         :subject:from:user-agent:mime-version:date:message-id:x-gm-gg
         :x-gm-message-state:from:to:cc:subject:date:message-id:reply-to
         :content-type;
        bh=13X+p5BlHvU1jlJef4qxKfLhScGAMJVOYykK2pEOeDw=;
        b=1K0g+AF7Bs1esbzy9Ml9GCVZWi8PlvIx6sjh3GBWvCW8mNUyRlIA/VOhAxxItn0p49
         EqhljOQoTgbq/idleMs9sIcIjzlNqyfKotfCMtRzsigZar4Bu8teOjE3r4zgf+aTBzMx
         qUU8pUv+SHFk7mC/EVfy2VJPvI4QZeoPxFpMlQUiOva/HiKEfA4QDSW2YPURVuMIPSEf
         muLXfENCDwo4bp6c+3GTgTgt0ShI8GWeGUHpvq+ha08jRUpzn0mJm5cvEzQZYA+ML8vB
         BQP6xigBHSM2vn6jkrrZzdv7rn9t2dw4gBMeDgpHjATrZHVzHCp8Og/7jtMd5n4/h2iJ
         Wy1A==
X-Gm-Message-State: AFuF++mS5WOQoxHIKDYm3Umpr8JF24yT7z6YKOw+LlK2nlo+4hPGBrBW
	OYa0D3fIst3M1Ah8z6fB23TDmcriGHtJvjRVS/C+41W3LLT1wI3i2B5YMd2PH9qJwS6k+bHhgEi
	A6SX7qR68njry4yLSotDDbqAJK5dnf6fUmORzQLbL2Mt8uEp/jRiNFL0bvY6actUa/kvJXRhfgO
	evglI0Zy3IKfFz51BFPLDv+xdHaJ7gs4d7AUNygu6H2Ps=
X-Gm-Gg: AYBFou3VI86yMJ5APyZcuf5IvN+rrq80N3iydSh/ruF8Dmpfn2c/pWfyJfdeZy8Tz8w
	yqN1drwZfLR7u3z1eXxjxVKmwUROeNZ5TzYRzeAF3h3J5Eu6ur1jQb3KQguyeUVxbks/tRpyXAQ
	861YiswdTX4eXyllcIqlttMDIWMGpvRvGd6jwr7Vl75rTuVZgU3cVoje7G7uu8GcE2j7MICsUJH
	I1VXpaN7c8qF/I0sZ9F9rrvdoyQYKNul30kyDSErjY/aPJiJ1EJbvaYwMxhFbc2tuH+YtmbYAsX
	W5U63ykPVeCGPaTRtgFyL5hnYX93o7O6pN/IMOH53WpcHGlMYXiMOHfO7vpZpXSXdlf2FDimKzY
	=
X-Received: by 2002:a05:620a:2b96:b0:939:6d22:6fd with SMTP id af79cd13be357-93bf55950damr200312985a.18.1789832405994;
        Sat, 19 Sep 2026 08:40:05 -0700 (PDT)
X-Received: by 2002:a05:620a:2b96:b0:939:6d22:6fd with SMTP id af79cd13be357-93bf55950damr200307885a.18.1789832405432;
        Sat, 19 Sep 2026 08:40:05 -0700 (PDT)
Received: from [172.31.1.12] ([70.105.241.211])
        by smtp.gmail.com with ESMTPSA id af79cd13be357-93bedac892esm211835985a.25.2026.09.19.08.40.04
        (version=TLS1_3 cipher=TLS_AES_128_GCM_SHA256 bits=128/128);
        Sat, 19 Sep 2026 08:40:04 -0700 (PDT)
Message-ID: <5717a803-805c-409f-a9cc-d0c33a365570@redhat.com>
Date: Sat, 19 Sep 2026 11:40:03 -0400
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
User-Agent: Mozilla Thunderbird
From: Steve Dickson <steved@redhat.com>
Subject: ANNOUNCE: nfs-utils-3.1.1 released.
To: Linux NFS Mailing list <linux-nfs@vger.kernel.org>
Cc: "linux-fsdevel@vger.kernel.org" <linux-fsdevel@vger.kernel.org>
Content-Language: en-US
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit

Hello,

This is basically an AI generated release which
is way I bumped the version to 3.X. Most of the
patches were generated by vulnerabilities that
AI found.

The tarballs can be found in
   https://www.kernel.org/pub/linux/utils/nfs-utils/3.1.1/
or
   http://sourceforge.net/projects/nfs/files/nfs-utils/3.1.1

The change log is in
https://www.kernel.org/pub/linux/utils/nfs-utils/3.1.1/3.1.1-Changelog
or
https://sourceforge.net/projects/nfs/files/nfs-utils/3.1.1/3.1.1-Changelog

The git tree is at:
    git://linux-nfs.org/~steved/nfs-utils

Please send comments/bugs to linux-nfs@vger.kernel.org

steved.


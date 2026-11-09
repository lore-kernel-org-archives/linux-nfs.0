Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=115.124.28.81
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1794185753;
	b=EaSsyuPOwyclXNF58y7DNc4/XDj4mRCRvvjTA3jhMrGCaKF4zfPYPXA2ujhX4NME9LWN
	 Y/lEIWlSs4rC+KIL30z8aq7iujfevUbyS6YhGRYHJFTO5lW5iOG91h6upHd7JsxTzHz3G
	 lqCWvomWqlT4yHLGTLxylw8ctOijpGzF/hCnulREz6AXqZg4UIrkBdSndJYcmbO0jh+CS
	 mUHtxwzjC0JAGS/rY+T7UbGDxTlNm9WwoKALFdj/2PbReIMUgT3iFtNZRD2Cr1hKXO6Tr
	 BCDKXNFNSU4SFXq3Eg70QWwEeF2g/Bs6hXvzLf/Uk32DVVn8QLz6dffqz2AyDLVS/iA==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1794185753;
	h=DMARC-Filter:X-Alimail-AntiSpam:Received:Date:From:To:Subject:Cc:
	 Message-Id:MIME-Version:Content-Type:Content-Transfer-Encoding:
	 X-Mailer;
	bh=XtEyR0Fq50v/YiYwqNsdmsu/XM4SgIPqZiSf9Fsfcng=;
	b=3IaDflCpo4ZEzgloJXxpR0hgwcyzcGNUlAXqIU7GtVcrCMztvASpoLKqZcrwADYrR32P
	 KOdYpvp01WXVSAnFi+m7IVLiebFD1yGog1uB1JX7oEGJjE/xPfsbI51pr+bREKcoiofRv
	 MyeAkyvicM5J/0eNeLmtl0tVfmDMxGB1f0UFTAENWJHYfTUoMQttgAzZ6utImMHW8SRF2
	 z1M207rbFG5hX3igs7EJItswbtyCmr6/4Q1HCMCUPa2yzrk1CQHMzkndCxDZ/n2RSuB6d
	 UDOsARYcJmPqMl0cn28hloDrwzrdfG62pJ+VFMj2p9FAEWsUejVl457xXyRknSyVHbA==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dmarc=none header.from=e16-tech.com;
	spf=pass smtp.mailfrom=e16-tech.com;
	arc=none smtp.remote-ip=115.124.28.81
Received: from out28-81.mail.aliyun.com (out28-81.mail.aliyun.com [115.124.28.81])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1) server-digest SHA256)
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 28916606A321
	for <linux-nfs@vger.kernel.org>; Mon,  9 Nov 2026 00:55:49 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.4.2 smtp.subspace.kernel.org 28916606A321
Authentication-Results: smtp.subspace.kernel.org; dmarc=none (p=none dis=none) header.from=e16-tech.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=e16-tech.com
X-Alimail-AntiSpam:AC=CONTINUE;BC=0.2791298|-1;CH=green;DM=|CONTINUE|false|;DS=CONTINUE|ham_news_journal|0.055598-0.00806302-0.936339;FP=10134741544096743603|0|0|0|0|-1|-1|-1;HT=maildocker-contentspam011083032240;MF=wangyugui@e16-tech.com;NM=1;PH=DS;RN=2;RT=2;SR=0;TI=SMTPD_---.jzgxea-_1794185741;
Received: from 192.168.2.112(mailfrom:wangyugui@e16-tech.com fp:SMTPD_---.jzgxea-_1794185741 cluster:ay29)
          by smtp.aliyun-inc.com;
          Mon, 09 Nov 2026 08:55:42 +0800
Date: Mon, 09 Nov 2026 08:55:43 +0800
From: Wang Yugui <wangyugui@e16-tech.com>
To: linux-nfs@vger.kernel.org
Subject: Could nconnect apply to every trunk(path) when trunkdiscovery
Cc: wangyugui@e16-tech.com
Message-Id: <20261109085542.FAF7.409509F4@e16-tech.com>
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Post: <mailto:linux-nfs@vger.kernel.org>
List-Help: <mailto:linux-nfs+help@vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
List-Owner: <mailto:linux-nfs+owner@vger.kernel.org>
Precedence: list
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
X-Mailer: Becky! ver. 2.83.11 [en]

Hi,

The result of 'mount -o trunkdiscovery,nconnect=4,max_connect=16'
- 4 connections for 1st ip.
- 1 connection for 2nd ip.

so,  could nconnect apply to every trunk(path) when trunkdiscovery?

Best Regards
Wang Yugui (wangyugui@e16-tech.com)
2026/11/09



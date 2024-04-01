Received: from out28-55.mail.aliyun.com (out28-55.mail.aliyun.com [115.124.28.55])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 43F171CA80
	for <linux-nfs@vger.kernel.org>; Mon,  1 Apr 2024 11:05:31 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=115.124.28.55
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1711969537; cv=none; b=gcBpn9/6G1WaSdLeeRUF7Dxyz9J6HYgyz78XySai3aIaq7tSy1lwxgdVIIuZCPNKEUEgFYQE+jBh9NFSwNOBwCwpEfi8bmGGF2q+5HEi99NmMkYwErwOORE3iGmHu0sdNO1ck8mMs9XFx9D5Pie3+d4Kjp/8OOxlPFj1sookElg=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1711969537; c=relaxed/simple;
	bh=TF4dAEBRtpNoOMnUUAviQI6D2FNS6yRTAT1DeSYx1Bo=;
	h=Date:From:To:Subject:Message-Id:MIME-Version:Content-Type; b=e3eYyvQ+TgAlBludldpz1iYvZLrnReoTK+dheuSFa/4zOprr0ayVmWKEJMPc1gHYuVG5eyRrpM2nrAMdY52ecYhiJCYCiv8q0W+EoAlWvug/Ok/ybegvbjaQ3rIuhhQTDurIcIHAPjYVd2GjEuVcQYpa0Fp7RR04Ds2zWy0gj1M=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=none (p=none dis=none) header.from=e16-tech.com; spf=pass smtp.mailfrom=e16-tech.com; arc=none smtp.client-ip=115.124.28.55
Authentication-Results: smtp.subspace.kernel.org; dmarc=none (p=none dis=none) header.from=e16-tech.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=e16-tech.com
X-Alimail-AntiSpam:AC=CONTINUE;BC=0.352413|-1;CH=green;DM=|CONTINUE|false|;DS=CONTINUE|ham_news_journal|0.0615119-0.00026352-0.938225;FP=12495180928749297485|1|1|1|0|-1|-1|-1;HT=ay29a033018047203;MF=wangyugui@e16-tech.com;NM=1;PH=DS;RN=1;RT=1;SR=0;TI=SMTPD_---.X.J3kKJ_1711969526;
Received: from 192.168.2.112(mailfrom:wangyugui@e16-tech.com fp:SMTPD_---.X.J3kKJ_1711969526)
          by smtp.aliyun-inc.com;
          Mon, 01 Apr 2024 19:05:27 +0800
Date: Mon, 01 Apr 2024 19:05:28 +0800
From: Wang Yugui <wangyugui@e16-tech.com>
To: linux-nfs@vger.kernel.org
Subject: one more patch(nfsd: fix potential race in nfs4_find_file) for 6.1.83+ ?
Message-Id: <20240401190527.7D1D.409509F4@e16-tech.com>
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
X-Mailer: Becky! ver. 2.81.06 [en]

Hi,

We had 13 nfsd patches in 6.1.83, do we need one more patch(*1)?

*1:
bd6aaf781dae :Jeff Layton: nfsd: fix potential race in nfs4_find_file

Best Regards
Wang Yugui (wangyugui@e16-tech.com)
2024/04/01



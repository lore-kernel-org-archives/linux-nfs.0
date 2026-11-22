Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=116.130.217.65
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1795329091;
	b=kydw6E7xdESOeFK0Ga4fUMHjZnhFPsrx5+G/8n+7BPD5f3K/YSEp5K/fxL+S8WhHj5Qe
	 SaTEuguXHJCh89EkIvZiHvVSBIkJrMSJS5lbF1cevtrwQElEfZOiAua3tXUyA8kx3LmXs
	 RgvhY7uc/Ip9BaOFVUFyJ//8y/NL5H2C6wdWcEe0hygRF/FUXjNMG97m/hCS1D8DbmVbh
	 5dxL5+Z8SN6VDwswPTovZnUw3BOwYEU97uN30mhTnMpQSCJRyy5NzbVwJ3P+BPoF4/bJ5
	 cAMTMxVPs28YhElT0HUP3Ty0rEuvGXPbE4+IEAaEGBNR8Z0FIRZMLPYbeN6Qw2dELXA==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1795329091;
	h=DMARC-Filter:Received:DKIM-Signature:Content-Type:MIME-Version:
	 Content-Transfer-Encoding:Subject:From:To:Date:Message-ID:
	 List-Unsubscribe:List-Unsubscribe-Post:Reply-To:X-Sohu-Gateway:
	 X-Sohu-Antispam-Language:X-Sohu-Antispam-Score;
	bh=GY6Y8XpjS6LL2SJVfzaU3rdGUGK4ocd7hmzkZmVmcIQ=;
	b=D1cVJFp5tPn6WHzYkEkYe3gbMHS/7DJ9ISeQAwJFF49oIo8tcfmZ7Bj9uBcG7ZwoKRAD
	 GObNZRf9coseM7+WKM1Q5xOqewK7oYs479xUUlujBH/D0i3ceyfTegBjTjexOuJebakIH
	 2WMSFQvKDyk5aE/RYIcbHV9h/PJROmUeg4qszkFKYnQlgjLVz3j5owh0Wxu0EUIR9XFAu
	 6M7NfJFzN0BS3suPgzlVjHbiKoOVunP9VPjy+psbnYdNEENT4Vpq8efv2imlHuJAgJM/x
	 RxgSa49l/AJIstqmB8Sl4BcmvtfmdH71ZjezedbcGWKonC84dq5Wgh7tvHIVNovbeOg==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dmarc=pass header.from=sohu.com;
	spf=pass smtp.mailfrom=sohu.com;
	dkim=pass header.d=sohu.com header.i=@sohu.com header.a=rsa-sha256 header.s=mail header.b=a4kALmXK;
	arc=none smtp.remote-ip=116.130.217.65
Received: from smtp217-65.mail.sohu.com (smtp217-65.mail.sohu.com [116.130.217.65])
	by smtp.subspace.kernel.org (Postfix) with ESMTP id C38B7606A320
	for <linux-nfs@vger.kernel.org>; Sun, 22 Nov 2026 06:31:29 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.4.2 smtp.subspace.kernel.org C38B7606A320
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=reject dis=none) header.from=sohu.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=sohu.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (1024-bit key) header.d=sohu.com header.i=@sohu.com header.a=rsa-sha256 header.s=mail header.b=a4kALmXK
Received: from [172.25.140.59] (unknown [43.106.14.92])
	by smtp217-65.mail.sohu.com (Postfix) with ESMTPA id 4jXK3L66HBz6v4F
	for <linux-nfs@vger.kernel.org>; Sun, 22 Nov 2026 14:31:25 +0800 (CST)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=sohu.com; s=mail;
	t=1795329087; bh=GY6Y8XpjS6LL2SJVfzaU3rdGUGK4ocd7hmzkZmVmcIQ=;
	h=Subject:From:To:Date:List-Unsubscribe:Reply-To:From;
	b=a4kALmXKgVHgfV2h4JuQExGROezhxPGngYCEV1lx5NtO6sxosKfFqBsROOQUAeQLZ
	 YRt9/xJIKtxNbRc88C7d52/li8YMm8Z8YmWTdTvNZReQE1wj2BQgQA0tci/NhxRnB/
	 JjSvmqEsX95FFf7/g0UpE7GBDSjyNkL34IvlPWM0=
Content-Type: text/plain; charset="utf-8"
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Post: <mailto:linux-nfs@vger.kernel.org>
List-Help: <mailto:linux-nfs+help@vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
List-Owner: <mailto:linux-nfs+owner@vger.kernel.org>
Precedence: list
MIME-Version: 1.0
Content-Transfer-Encoding: base64
Subject: =?utf-8?q?token8341_=E2=80=94_an_API_partner_for_your_project?=
From: =?utf-8?b?ODM0MVRva2Vu5bel5Y6C?= <wusohu_177_0979@sohu.com>
To: linux-nfs@vger.kernel.org
Date: Sun, 22 Nov 2026 14:31:25 +0800
Message-ID: <179532908547.2759411.12092261385229402226@sohu.com>
List-Unsubscribe-Post: List-Unsubscribe=One-Click
Reply-To: wuqiong@token8341.com
X-Sohu-Gateway: 1
X-Sohu-Antispam-Language: 0
X-Sohu-Antispam-Score: 0.01

5L2g5aW977yMCgrmiJHku6zlubPlj7AgdG9rZW44MzQx77yIdG9rZW44MzQxLmNvbe+8ieaPkOS+
myBBSSDlpKfmqKHlnosgQVBJIOiBmuWQiOacjeWKoe+8jArkuIDkuKoga2V5IOiwg+eUqCBEZWVw
U2Vla+OAgUtpbWnjgIHmmbrosLEgR0xN44CB6YCa5LmJ5Y2D6Zeu44CBTWluaU1heCDnrYnmqKHl
novvvIwK5a6M5YWo5YW85a65IE9wZW5BSSBTREvjgIIKCuaDs+i3n+S9oOiBiuiBiuaYr+WQpuac
ieWQiOS9nOWPr+iDveOAguWbnui/meWwgemCruS7tuWwseiDveaJvuWIsOaIkeOAguiwouiwou+8
gQoKLS0tCuWQtOeQvAp0b2tlbjgzNDEKaHR0cHM6Ly93d3cudG9rZW44MzQxLmNvbQoKLS0K5LiN
5oOz5YaN5pS25Yiw5oiR5Lus55qE6YKu5Lu277yf54K55LiL6Z2i6L+Z5Liq6ZO+5o6l5LiA6ZSu
6YCA6K6i77yM56uL5Y2z55Sf5pWI77yaCmh0dHBzOi8vdG9rZW44MzQxLmNvbS9nby91L2JHbHVk
WGd0Ym1aelFIWm5aWEl1YTJWeWJtVnNMbTl5WjN3UUFqUjNVWjQK77yI5Lmf5Y+v5Lul55u05o6l
5Zue5aSN5pys6YKu5Lu244CB5q2j5paH5YaZ44CM6YCA6K6i44CN5Lik5Liq5a2X77yM5oiR5Lus
5ZCM5qC35Lya5aSE55CG44CC77yJ

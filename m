Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=113.46.200.226
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1794999956;
	b=ESq4rkETqvv7Cx7LScGrBYaLfbENSJLckIc/1cB0s62+px/ncEa0Nm5teXdXnjmZBXH3
	 SVydnyONL09sN7+jVz4cVHvtA0Rb2K51VGhXc7fKiE4gQ7ukcV0j0Kz4sxQjgYA+9HbXC
	 epMe7UxxyNVTgxVgBGdZ6nGPlC/fRec61FpUNIUmvei9p7IyVab/SARiXG2BMNGNY/4cC
	 kkb5EMCM0+BLlg0sfenhMuKymFK7xXctZm6kYl6l8yF93BXU5x/EN0HfjJ0IV8VeRrfeh
	 LGpNtEHob9Y4UMWVhjbjLaEZOKskld/Gsd98vcMzDobaV0xAY5vau73+Zbyl1vV3j/A==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1794999956;
	h=DMARC-Filter:dkim-signature:Received:Received:Received:Message-ID:
	 Date:MIME-Version:User-Agent:Subject:To:CC:References:In-Reply-To:
	 From:Content-Type:Content-Transfer-Encoding:X-Originating-IP:
	 X-ClientProxiedBy;
	bh=N2WBV91cmkAUdcnNf48jE+IYB0wjHX2MQTzeLVdlj/U=;
	b=BkUpM4f+9YIlQhRysxwfB03WPFjCh9vbC545JeBLVQML1e2jQsOIqYiMERXd6o2OMMjS
	 uGqYufSKNLu63BpaLVX4LgH9utSs727+JcFSKcpbyvyK8ZDEfbTm/699t01JLh76EuS7g
	 imSEeux16xAupDfexcB06V/thZhLaClA6cPWmZRG3ZD/DiGXjueM3vI0yekeQQIwDgC50
	 ao1zGuuW3ocJt+VtjU8l6JFbRAhFiLouSvPBMm4XkJV4dN6+FFdkJeoBbI94Aoup8zp84
	 loaL8FvP7PxCOu7+rM00UYPUU5xAi3jaFUmEhNFWABL2tVCdaGZTo7dAkgl3M3mXQoQ==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dmarc=pass header.from=huawei.com;
	spf=pass smtp.mailfrom=huawei.com;
	dkim=pass header.d=huawei.com header.i=@huawei.com header.a=rsa-sha256 header.s=dkim header.b=xhi0kL4V;
	arc=none smtp.remote-ip=113.46.200.226
Received: from canpmsgout11.his.huawei.com (canpmsgout11.his.huawei.com [113.46.200.226])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1) server-digest SHA256)
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id F175B606A320;
	Wed, 18 Nov 2026 11:05:53 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.4.2 smtp.subspace.kernel.org F175B606A320
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=huawei.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=huawei.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (1024-bit key, unprotected) header.d=huawei.com header.i=@huawei.com header.a=rsa-sha256 header.s=dkim header.b=xhi0kL4V
dkim-signature: v=1; a=rsa-sha256; d=huawei.com; s=dkim;
	c=relaxed/relaxed; q=dns/txt;
	h=From;
	bh=N2WBV91cmkAUdcnNf48jE+IYB0wjHX2MQTzeLVdlj/U=;
	b=xhi0kL4VDySviSZf0jN2Mj4lry4+vI4t2FYKDuPVA0kAOaiwsX7wbTUQ1lv5DOa4IHyhhpFGh
	kM804jmgUXvgvp5B18CMSrP3qNRWVjEzdfX6gmJqOj6jFnnqy98OPSgjxZE1c1lWOMZuRLPMFV6
	siuqwshGoPYJ5gIdiCJf414=
Received: from mail.maildlp.com (unknown [172.19.163.200])
	by canpmsgout11.his.huawei.com (SkyGuard) with ESMTPS id 4jTzKW14TGzKm64;
	Wed, 18 Nov 2026 19:05:35 +0800 (CST)
Received: from whupemk300014.china.huawei.com (unknown [7.152.185.8])
	by mail.maildlp.com (Postfix) with ESMTPS id 875A840563;
	Wed, 18 Nov 2026 19:05:49 +0800 (CST)
Received: from [10.174.177.221] (10.174.177.221) by
 whupemk300014.china.huawei.com (7.152.185.8) with Microsoft SMTP Server
 (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384) id
 15.2.2562.45; Wed, 18 Nov 2026 19:05:47 +0800
Message-ID: <074af9c6-b852-4990-a3e7-ed40a5dc6780@huawei.com>
Date: Wed, 18 Nov 2026 19:05:46 +0800
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
Subject: Re: [PATCH v2 3/3] xprtrdma: Wake connect worker on device removal
To: Tim Menninger <tmenninger@everpuredata.com>
CC: "Dai.Ngo@oracle.com" <Dai.Ngo@oracle.com>, "anna@kernel.org"
	<anna@kernel.org>, "cel@kernel.org" <cel@kernel.org>, "jlayton@kernel.org"
	<jlayton@kernel.org>, "linux-nfs@vger.kernel.org"
	<linux-nfs@vger.kernel.org>, "linux-rdma@vger.kernel.org"
	<linux-rdma@vger.kernel.org>, "neil@brown.name" <neil@brown.name>,
	"okorniev@redhat.com" <okorniev@redhat.com>, "stable@vger.kernel.org"
	<stable@vger.kernel.org>, "tom@talpey.com" <tom@talpey.com>,
	"trondmy@kernel.org" <trondmy@kernel.org>, "weiyongjun (A)"
	<weiyongjun1@huawei.com>, yuehaibing <yuehaibing@huawei.com>, zhangchangzhong
	<zhangchangzhong@huawei.com>
References: <20261103032758.1302493-4-lixiasong1@huawei.com>
 <20261117182727.104697-1-tmenninger@everpuredata.com>
In-Reply-To: 20261117182727.104697-1-tmenninger@everpuredata.com
From: Li Xiasong <lixiasong1@huawei.com>
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
X-ClientProxiedBy: kwepems200001.china.huawei.com (7.221.188.67) To
 whupemk300014.china.huawei.com (7.152.185.8)

Hi Tim,

On 11/18/2026 2:27 AM, Tim Menninger wrote:
> I encountered a refcount_t underflow warning in rpcrdma_ep_put() on
> 7.4.0-rc3 during a pNFS flexfiles read workload with one MDS and one DS.
> The trigger was restarting the NFS engine on the DS while reads were
> in flight. The warning came from xprt_rdma_connect_worker via
> rpcrdma_xprt_disconnect() -> rpcrdma_ep_put().
> 
> With all three patches from this v2 series applied to 7.4-rc3, the
> warning no longer occurred under the same test. This test did not
> involve removing the RDMA device.
> 
> Tested-by: Tim Menninger <tmenninger@everpuredata.com>

Thanks for testing the v2 series and sharing the results.

The v2 series is still being refined based on Chuck's and Sashiko's
feedback, including further improvements to the endpoint cleanup path.
I will include them in the next version.

Thanks,
Li Xiasong

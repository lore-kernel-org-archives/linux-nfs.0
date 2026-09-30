Received: from mx0b-003fbd02.pphosted.com (mx0b-003fbd02.pphosted.com [67.231.157.221])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id D9FD835DA53
	for <linux-nfs@vger.kernel.org>; Wed, 30 Sep 2026 01:51:51 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=fail smtp.client-ip=67.231.157.221
ARC-Seal:i=3; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1790733115; cv=fail; b=tMhSvlLAMzydsjoNFXHQV1aemgldTXQ2DvWaZoTVj6pVOe0yPe8KgrXl2XQiy6KMGhJKn4enjtYQfhB6UxduuEDA4m1Ycry/d4xkJX6W7/qZ2MlCO3piP2i40cAW+zTJyVsdEEoHx6ct4e47D4jE3d89xlFgqtFEgbY58qDdQ3Y=
ARC-Message-Signature:i=3; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1790733115; c=relaxed/simple;
	bh=Lh/XKBNKPxoGxKnNexnlfq0Fr3LStsGXnq/BrvlKqK4=;
	h=From:To:CC:Subject:Date:Message-ID:Content-Type:MIME-Version; b=IB9F9PgyQ+9Yit/VtFK8Ev21/oo4Vk6z7xN0x2thlM8EIo1LDuh602eSvOR1RQ6zA7RrLzLclDSvovhoXxsZblBKR4qoOHbKukViaFHUFvBws3/iMb7O5A0yt9BDoCSfY67diXM0M8NWQrzXHX35YyQJ9bFZogvmgaN5hwBzUDA=
ARC-Authentication-Results:i=3; smtp.subspace.kernel.org; dmarc=pass (p=reject dis=none) header.from=netapp.com; spf=pass smtp.mailfrom=netapp.com; dkim=pass (2048-bit key) header.d=netapp.com header.i=@netapp.com header.b=McesFB+t; dkim=pass (2048-bit key) header.d=netapp.com header.i=@netapp.com header.b=Z4FmX9mN; dkim=pass (2048-bit key) header.d=netapp.com header.i=@netapp.com header.b=Z4FmX9mN; arc=fail smtp.client-ip=67.231.157.221
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=reject dis=none) header.from=netapp.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=netapp.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=netapp.com header.i=@netapp.com header.b="McesFB+t";
	dkim=pass (2048-bit key) header.d=netapp.com header.i=@netapp.com header.b="Z4FmX9mN";
	dkim=pass (2048-bit key) header.d=netapp.com header.i=@netapp.com header.b="Z4FmX9mN"
Received: from pps.filterd (m0412383.ppops.net [127.0.0.1])
	by mx0b-003fbd02.pphosted.com (8.18.1.11/8.18.1.11) with ESMTP id 68TNngOl1651305;
	Wed, 30 Sep 2026 01:18:57 GMT
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=netapp.com; h=cc
	:content-transfer-encoding:content-type:date:from:message-id
	:mime-version:subject:to; s=pps1; bh=Q54K9jdJRObQ8VMFTpx//slYaUJ
	HUyRSY8lwJPo1vfY=; b=McesFB+tkAzmJqvm/tbgfVUcjTlJQt0cMK2wH2Czevz
	e+S9l9oB9wRx6hThWWM2SbCip52w3cFOzrhMPFqfRkj6bsYHCAKBz8UptOokB0xR
	1uYwe77KPO1O2qOK4A0s0XRKq7JbQuQqzGdcMZcesqsaWB0abYhX0kYdpftg4YzL
	GY0DwsxKAJq4J1CxObppHwm7Cn/TzRg+7fXIqa5yxaQOleIAiYyog7K1C73j6zj6
	S7NjyeaIRwAjlILv8xu2FUQ3T+pDcQ/oLcAyt425TN3XhP/NdRtBPIe8a/rGsJ+o
	d3wb3WowJiIXllhIn19mHJMNiTjELVvzv+aQTwZpcMQ==
Received: from ph8pr06cu001.outbound.protection.outlook.com (mail-westus3azon11012047.outbound.protection.outlook.com [40.107.209.47])
	by mx0b-003fbd02.pphosted.com (PPS) with ESMTPS id 4h0qbn876g-1
	(version=TLSv1.3 cipher=TLS_AES_256_GCM_SHA384 bits=256 verify=NOT);
	Wed, 30 Sep 2026 01:18:56 +0000 (GMT)
ARC-Seal: i=2; a=rsa-sha256; s=arcselector10001; d=microsoft.com; cv=pass;
 b=SE1U7HaB2LcfWuMzo9a/kGNDARnGaoZRcRFU8Cb9xKJB1SR/d1wM22cMsIhGSChBdbcPzEhxrp9zvsB3uhAZ9DzNcrq4WsEdzeiowzboXbpGv0Y89O/wJrGz6dtUVN0cGzoUVfvPuU2hg/swRrWXZxVZ40PBqC5+5gYRTR9RjcygxXjg/8FNVlGqvhguwNPyzSBsEQFPgBzvHOWplzWCQzklaYJbmNIXqOoomhDaS6FN6ZwYGRmNV729tEJQUsYkcDxs1B2i3zz3qg5xX11w17OWPTg5zJfU4CkWS+vlrZO2nnY/SpuFKCP0aO5bYbOMnhFNpjfSXEkYZ933jrD8tw==
ARC-Message-Signature: i=2; a=rsa-sha256; c=relaxed/relaxed; d=microsoft.com;
 s=arcselector10001;
 h=From:Date:Subject:Message-ID:Content-Type:MIME-Version:X-MS-Exchange-AntiSpam-MessageData-ChunkCount:X-MS-Exchange-AntiSpam-MessageData-0:X-MS-Exchange-AntiSpam-MessageData-1;
 bh=Q54K9jdJRObQ8VMFTpx//slYaUJHUyRSY8lwJPo1vfY=;
 b=Kh/+pUjmd6wUmvVUa0mdMC5md5B1a0dBrukukHozAQ1GdJ7o9fsJ6PCB7pdqNqIG0oEtalP8147EsA8JGVYa0+tSfcCES22QdAvgFjQ70R7vXblJXlLuq7KUVhe51mxP7kQjCF8tCVYLvEfBvTvfUxZTLJwU3KYGt7GdjSZ6vG5FQfHfcT0hFQeX0ff7uGC/w7bmWT48HmKhDK0nveZwC7kbXpWqi9Y5PsE2A3YgKal21y/ZWhtC+ZzIndSr5BHaWfDaPiEiAxfpAoMLb3DXHXCHnf3MLn9Gxcjnn3jwc/Z7gTpBpF4ga0NZINGpAzukZbysMMyDj/yiIe0ejkhpUA==
ARC-Authentication-Results: i=2; mx.microsoft.com 1; spf=fail (sender ip is
 136.226.152.54) smtp.rcpttodomain=redhat.com smtp.mailfrom=netapp.com;
 dmarc=pass (p=reject sp=reject pct=100) action=none header.from=netapp.com;
 dkim=pass (signature was verified) header.d=netapp.com; arc=pass (0 oda=1
 ltdi=1 spf=[1,1,smtp.mailfrom=netapp.com] dkim=[1,1,header.d=netapp.com]
 dmarc=[1,1,header.from=netapp.com])
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=netapp.com;
 s=selector1;
 h=From:Date:Subject:Message-ID:Content-Type:MIME-Version:X-MS-Exchange-SenderADCheck;
 bh=Q54K9jdJRObQ8VMFTpx//slYaUJHUyRSY8lwJPo1vfY=;
 b=Z4FmX9mNMNuADly98Fv2/8vjwxbwtmkVPUatMhqDrXc9GnOoNLQLC8pfxgQ2/fKkSrnbsRa6s3ZqEy/SN3SeRoY+2dIfxRunY6r9ZW1RPnmobGpMzNRC5h2Itfgrb88vxVWiCT3o3ER1M8kVPEi2aK0zoLA+CQaf3Ki6/hI7spc0MtpUSfeN7PDcZaMke7J5DHMeOBQ1uRTisJyv0Wd41iqu88MKgELo/+hQT3srY9nhTpsq5lzgX1UjuufkAGTjNKqee7AOOIdpuWieOj30aSyveqKwtAozCQtmkOVNWeMdSeiuKmbp6jfDa3YcDEUZtbvSeJDktR+8IHVlKSzdcw==
Received: from BY1P220CA0039.NAMP220.PROD.OUTLOOK.COM (2603:10b6:a03:59e::7)
 by DM6PR06MB6747.namprd06.prod.outlook.com (2603:10b6:5:259::16) with
 Microsoft SMTP Server (version=TLS1_2,
 cipher=TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384) id 15.21.451.26; Wed, 30 Sep
 2026 01:18:53 +0000
Received: from SJ1PEPF000037BB.namprd05.prod.outlook.com
 (2603:10b6:a03:59e:cafe::54) by BY1P220CA0039.outlook.office365.com
 (2603:10b6:a03:59e::7) with Microsoft SMTP Server (version=TLS1_3,
 cipher=TLS_AES_256_GCM_SHA384) id 15.21.472.15 via Frontend Transport; Wed,
 30 Sep 2026 01:18:53 +0000
X-MS-Exchange-Authentication-Results: spf=fail (sender IP is 136.226.152.54)
 smtp.mailfrom=netapp.com; dkim=pass (signature was verified)
 header.d=netapp.com;dmarc=pass action=none header.from=netapp.com;
Received-SPF: Fail (protection.outlook.com: domain of netapp.com does not
 designate 136.226.152.54 as permitted sender)
 receiver=protection.outlook.com; client-ip=136.226.152.54;
 helo=was11a2.mail.zscalertwo.net;
Received: from was11a2.mail.zscalertwo.net (136.226.152.54) by
 SJ1PEPF000037BB.mail.protection.outlook.com (10.167.244.202) with Microsoft
 SMTP Server (version=TLS1_3, cipher=TLS_AES_256_GCM_SHA384) id 15.21.472.14
 via Frontend Transport; Wed, 30 Sep 2026 01:18:52 +0000
Received: from co1pr08cu001.outbound.protection.outlook.com ([40.93.10.96])
	by was11a2.mail.zscalertwo.net ([136.226.152.43])
	with ESMTPS id 6ABC637C08F40000;
	Tue, 29 Sep 2026 21:18:52 -0400
ARC-Seal: i=1; a=rsa-sha256; s=arcselector10001; d=microsoft.com; cv=none;
 b=CDdfYt97QaQsG5MyAwxvhT+o8xDwGEkZzz0fF98BjPPtMck1mVtYRm9jdjERBsiDYSmHRZ5ae7fIugujUuDOJz8AjystOsW3ToIjJoQ9HxIQyUw7+6gY/wdpI9uwbp5jJLU/JwbkPtl/cziHh/iccgjVJAwD4hkXBErrUdSDDR9e/UwZnGQ9BALKYNooXZiiIh4DN6fnFxlMlpgF8JNvujVfLdWJBSt6niFYc7X9UuIa7/J9SO3+Qna85Y31diVFWDc8cwWXKDAOBjI1eut0IrStxuewneujn1U5CWraHNMhif9PIl7ap5qP14TU5u9yRMrKBZ7H2MrbNnVRgrjL7g==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=microsoft.com;
 s=arcselector10001;
 h=From:Date:Subject:Message-ID:Content-Type:MIME-Version:X-MS-Exchange-AntiSpam-MessageData-ChunkCount:X-MS-Exchange-AntiSpam-MessageData-0:X-MS-Exchange-AntiSpam-MessageData-1;
 bh=Q54K9jdJRObQ8VMFTpx//slYaUJHUyRSY8lwJPo1vfY=;
 b=UowF2iCJOqadiN+zKOE+ndZXQt+TBaUTsFifkleY/uN60BGhcmwaCOUTVYS4UFIZfzqF+m4gkqEicCbkbb5bgAzdioRREIo8viCVxCNj0h8FQRvrz8cdbTuH+g5bWcvEUJFqPE5/Ng/+LEI3AU9yZLApd3SyMi/pn3i9bMLxGpn+F4w6E5omOgQlD4hUryGxHHfg8l7qa2Y4/PC6E8QDeLFR+rKuPHIyvOWZgwGms4v9vtpWnH97J+hjq+IPxqlVcUlIMIZKvn3Yd9BdCKo4KN4RUtkjukuT6aPrtkgVnJxv3F1Szq/GwJld08XgVnzvlLjcvwBIwKQT2X78LTbS7w==
ARC-Authentication-Results: i=1; mx.microsoft.com 1; spf=pass
 smtp.mailfrom=netapp.com; dmarc=pass action=none header.from=netapp.com;
 dkim=pass header.d=netapp.com; arc=none
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=netapp.com;
 s=selector1;
 h=From:Date:Subject:Message-ID:Content-Type:MIME-Version:X-MS-Exchange-SenderADCheck;
 bh=Q54K9jdJRObQ8VMFTpx//slYaUJHUyRSY8lwJPo1vfY=;
 b=Z4FmX9mNMNuADly98Fv2/8vjwxbwtmkVPUatMhqDrXc9GnOoNLQLC8pfxgQ2/fKkSrnbsRa6s3ZqEy/SN3SeRoY+2dIfxRunY6r9ZW1RPnmobGpMzNRC5h2Itfgrb88vxVWiCT3o3ER1M8kVPEi2aK0zoLA+CQaf3Ki6/hI7spc0MtpUSfeN7PDcZaMke7J5DHMeOBQ1uRTisJyv0Wd41iqu88MKgELo/+hQT3srY9nhTpsq5lzgX1UjuufkAGTjNKqee7AOOIdpuWieOj30aSyveqKwtAozCQtmkOVNWeMdSeiuKmbp6jfDa3YcDEUZtbvSeJDktR+8IHVlKSzdcw==
Received: from LV2PR06MB11343.namprd06.prod.outlook.com
 (2603:10b6:408:351::20) by SA6PR06MB10716.namprd06.prod.outlook.com
 (2603:10b6:806:437::6) with Microsoft SMTP Server (version=TLS1_2,
 cipher=TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384) id 15.21.451.26; Wed, 30 Sep
 2026 01:18:47 +0000
Received: from LV2PR06MB11343.namprd06.prod.outlook.com
 ([fe80::748e:98e5:b837:639b]) by LV2PR06MB11343.namprd06.prod.outlook.com
 ([fe80::748e:98e5:b837:639b%6]) with mapi id 15.21.0451.024; Wed, 30 Sep 2026
 01:18:44 +0000
From: "Mora, Jorge" <Jorge.Mora@netapp.com>
To: "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
CC: Olga Kornievskaia <okorniev@redhat.com>,
        Scott Mayhew
	<smayhew@redhat.com>,
        Trond Myklebust <trondmy@kernel.org>,
        Anna Schumaker
	<anna@kernel.org>
Subject: BUG: unable to handle kernel paging request at 0000000000034620
Thread-Topic: BUG: unable to handle kernel paging request at 0000000000034620
Thread-Index: AQHdUHf+ACe4+kMaOEySCL/knrNvFw==
Date: Wed, 30 Sep 2026 01:18:44 +0000
Message-ID:
 <LV2PR06MB1134339C9F33C9857B9B2FD90E18B2@LV2PR06MB11343.namprd06.prod.outlook.com>
Accept-Language: en-US
Content-Language: en-US
X-MS-Has-Attach:
X-MS-TNEF-Correlator:
msip_labels:
Authentication-Results-Original: mx.microsoft.com 1; dkim=none (message not
 signed) header.d=none;dmarc=none action=none header.from=netapp.com;
x-ms-traffictypediagnostic:
	LV2PR06MB11343:EE_|SA6PR06MB10716:EE_|SJ1PEPF000037BB:EE_|DM6PR06MB6747:EE_
X-MS-Office365-Filtering-Correlation-Id: e22ad77b-b914-4bab-3cdb-08df1e90ca9b
X-MS-Exchange-SenderADCheck: 1
X-MS-Exchange-AntiSpam-Relay: 0
X-Microsoft-Antispam-Untrusted:
 BCL:0;ARA:13230040|1800799024|376014|366016|23010399003|38070700021|11063799006|56012099006|10067099003|18002099003|6133799003;
X-Microsoft-Antispam-Message-Info-Original:
 H7MQWa616XbwL8Ab2XWH7ceE7G7t3/1rG/uw3pw6s0mlLvJZN2SxfgHSYmDxHi4s4gAceiKIkPJ1VxVbSKncPkVBVDefL4fDPnmb4tn1G1UvT5P/LkEQjcWMUA7BuylWJ6oYpxuW3IE3tpWAg8mlMaHDzR3cD1KJvy9hcgBoQ903e0KOdhYvMlZY2kHjLQ1tZZBdvx99PMDsmp5vQk+ReXJP3p6N4mjD13E7Z9dgP8AAbJ+8o7Ypqo/eHosILPGqVIooBnQHQCAd+yzziVhjZtKnfRqtYDIQtLVZJ5emOV6hPHnz6OTSlgPLavgJZUxXdaDXXqui9beHvELb2FpFXVpA1a2V0a9UG90bXCzztneZJmzys3GLkg0kn+yNxtg9hVa7dcSwSGGWGwk2kNgabTqZPyg6TgM+Iisw3DDSNvdteRhjXqJcPmS5blSGPBNDP5A1mAJh0iqRvx4FzRwiHfcKxxhXcTaIGrK7mXuxT3qptyWjWyegPeU675vv1XDLQrRzM/Z7z5ZyaXZcn66D+GToYHV3ZWxklyc0tlLUVtnKk+t2krAX7SM1z9m3DAVTFkSzZd+p0uShi2xWohRyqFEj/BEBGv3OqtdRMuHIHaq//fPJIl9tP1nmrEm0DZOr8EueKrvUjAHZWriFeToMM/znnT9PBw7P1oNjF/XuUkIU8Jfq0s/WQA1tr7kKKmNQSh5tAJphb/gMiMx8lenQXgxpEbLNanK0GQbQrIIcx/w=
X-Forefront-Antispam-Report-Untrusted:
 CIP:255.255.255.255;CTRY:;LANG:en;SCL:1;SRV:;IPV:NLI;SFV:NSPM;H:LV2PR06MB11343.namprd06.prod.outlook.com;PTR:;CAT:NONE;SFS:(13230040)(1800799024)(376014)(366016)(23010399003)(38070700021)(11063799006)(56012099006)(10067099003)(18002099003)(6133799003);DIR:OUT;SFP:1101;
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
X-Exchange-RoutingPolicyChecked:
 290cN4+7WrxnT0v01yOzIop/TdQt1JL8JMjlJB3RUFyJrrBZ4yvb4BdMQ7JRU0bPUM9/XbTG1Q4AZ08BcHsA01cTf9lwshbgNwtrw1VfHCRDRcvik4jbg/1Kq96wOjdFytpphc+BMrPatcfIfMhDUM1wy3XhWlynGVSmtnaPtL+IJSmDk9FYBJ6ITHFRw0rFv1fBufgQiMI+ijJSnfJXMvF8+DIhviYW7VHrpS5TdDAeAmPqWDw5akJ2pWnNeR//GSsQ1SRAIpzg2jav8sSZU5RswtaLCOC8KkX9GknKRjU4CTI+rEDl2EpOs/Iz3kkWJ5NYiQgmAQd1vg68YwWsCw==
X-MS-Exchange-Transport-CrossTenantHeadersStamped: SA6PR06MB10716
X-Zscaler-Block: 0
X-EOPAttributedMessage: 0
X-MS-Exchange-Transport-CrossTenantHeadersStripped:
 SJ1PEPF000037BB.namprd05.prod.outlook.com
X-MS-PublicTrafficType: Email
X-MS-Office365-Filtering-Correlation-Id-Prvs:
	f4a70875-251e-45ed-4dd8-08df1e90c559
X-Microsoft-Antispam:
	BCL:0;ARA:13230040|376014|35042699022|14060799003|36860700016|82310400026|1800799024|23010399003|10067099003|11063799006|56012099006|6133799003|18002099003;
X-Microsoft-Antispam-Message-Info:
	ZhxipBI20kM1Z2sQeHIBomymKzXX+AXwSUrsGZRp5Uiw/R+25Uq6CUYBO0DTkEHWohXOUOn8nUsBiBovY38VE+Em7PtZS7mui9u8DfCazQa6CPyTTlJ2o+6U30unTEPM2K4nd89BW3MjHJQZsJYeJZJPCjHEgP7okanSBs6JCaLbAiOGYyckp1Yf1FUXcJfaDz8wjdLxkRxowxX5rfVFxlR0Avbs7vnDoIZ3rk83chcuMJqr/5jWClrfjDxnSNtqLYZaoNkxaIlYtw9Rt+oekDjj71WLO+rs0J7e0PCfrpS/R0Is7F20uEGTGdazNEfDqao8Zn8H0zIlZ+rbQMKjpVNEU8DZVrNu44v562JW0Qka5LYBPWTd86+ZCibTvGpOwNBiyIkx3Qq7G3uk6LMm7LDGx7bUvjSadV0RekBsj0VY4nebg92QMUYiEg4iIWki4ZR6tT/btSOw1GwRuCruxE0M38tAArMVvHTXaGmgyfBHL9LAzWcfr0RFAbyFMHhZ8YbCZ3Nlb0ngyQXdNW2tV8pAI0i3zXoV9174rCYthd7g+SxM/vC3ZWDwALz9Lh6fbXG3Kqst8f79VtvF+idNWeJY+jSMg1UpL7MevU6FBxgAWweSn3aAnIjHhjEohd7+rpRoOp+qzVEu9IMiXE5FMTz5+ZkfvatYhN3obCU2yUsZvFUNKSd9t5yuD7CGeKlQkdibU1cD0DjDgc4P87I9kQ==
X-Forefront-Antispam-Report:
	CIP:136.226.152.54;CTRY:US;LANG:en;SCL:1;SRV:;IPV:NLI;SFV:NSPM;H:was11a2.mail.zscalertwo.net;PTR:was11a2.mail.zscalertwo.net;CAT:NONE;SFS:(13230040)(376014)(35042699022)(14060799003)(36860700016)(82310400026)(1800799024)(23010399003)(10067099003)(11063799006)(56012099006)(6133799003)(18002099003);DIR:OUT;SFP:1101;
X-MS-Exchange-AntiSpam-MessageData-ChunkCount: 1
X-MS-Exchange-AntiSpam-MessageData-0:
	kkF53Z2kDAVlhpJPbGZ34lqkkkFwClx12Bw3rIMzTT3TMRO0ndWABm8Yf156b8FT28KVhL/KmuSnpajQ4T0i8c1XVMiX4XauBo/+M9HI0TN79oleR4mJNjlZzqjqD9Yvccg+q9jBqlchVDHkYqG5mKNHpmlmE5Pb2J4tQXVDbBEOem+oL0fQWOOqiVFisOi9Nu2YA033fprM4gTnNuqKwxglzIxTkiTbssaNrIZvk+bTZHN1JNroTR5wgWe02DUEbCVu7Jy8SGAZIIVBGrxcfLLiWQtIUHT0oqxuq0h54gF0+dO7LOcDFJtRJ6xTs37x3wVlNXNfCUpFYWImtDBBt2y74b3MtDwvWUcfI5mBgpfNWL7cXz/9IkD5hFPJWb9t0Jp4naKMlKwu1xXtKnsCchB9WUpxQsnOL4WNXIdB9iiZtU+mgtVL0lV4MR46LSIO
X-Exchange-RoutingPolicyChecked:
	0tlI2lKXZWHMg+4ATKTmhTVBnBDDu4wbvmRJu2ZjBIc79YKuEQ2hDU89a/5MVSvosv5abx73z0zIRVwPW2FdiAQLMPD55PMFr29HU97QhlNjyDmEu6QjfO9jGZU8OcgqpeftliHcbclmaIo6Ojq2MdGXh8vs8qol2tU1BkmpOcC1vEzDpSFw3FO24HIpCeILC0tWpOekZli7tdPPSh/JLWSiMpmKiN+gGWBUmkGa8a999asV+hJrEQJwZOx0HQ4c8FKosGnf44I37eknx5RzTCEQG6I9BKKx/tj2jwesnS03HfrlMxQoAnqnWM91vBVShWVwzkbs9CXniUgcokozuA==
X-MS-Exchange-AntiSpam-ExternalHop-MessageData-ChunkCount: 1
X-MS-Exchange-AntiSpam-ExternalHop-MessageData-0:
	F8uHyWBAeeZhnIuhXdcYNo07yOoo1mCxmhSoCvrEn/8+oTkiWj7XAKWumxYBsWQPaLBLIyOVYT2PvSPfFpcmaHH9hw/wI9ia6EPvd6HSmNgyBFTdca7Rrd4LlH0n4/0gaKu2NeOtKYpOD7N5USHVD72VLx/6FW5zFagw9fpH01rRKCx5pZA4ZsYK01XB4Wmkxu96Nj7IZtOrVAnAqUnACIOx18w3jGGEwn12H8lMvayjIu9zI9MZhf6SHU/PRln4/YdZkK+2l+cyAPRrsxSI56EHSnGnAtBNVYObpu4wsnykZJL/w3sHRAd2MBYF5FwHiMFMJZ1DJXAT3izvTnUoHMnZfakRSDMoSN2z4eHgegeDpkvw+U4vaaJNmFbx7w3u8lrsfaE/zjNngM1AO4EpzejtL2swbheF0bsVDZVv81XTfZWBFgMVlyrmuBfr4SQ5ii446anJdExEOudCNgBNqsSstIsSbKXwUHHkJ8uAnDltIHUI5y3Uu64QHNHoP3BCnqY3iVNUtbVYb5hPGbAESvlyaqUGlQeiv7Sdt1ztz0o8/VBa4lOlsGItV5iN9xWwK2VRzLJS6VvYvS5EByLjYPN4mxFF5JbQM6oymXrIiabYCwIcdPpCWt5ZYZdemYm0
X-OriginatorOrg: netapp.com
X-MS-Exchange-CrossTenant-OriginalArrivalTime: 30 Sep 2026 01:18:52.9709
 (UTC)
X-MS-Exchange-CrossTenant-Network-Message-Id: e22ad77b-b914-4bab-3cdb-08df1e90ca9b
X-MS-Exchange-CrossTenant-Id: 4b0911a0-929b-4715-944b-c03745165b3a
X-MS-Exchange-CrossTenant-OriginalAttributedTenantConnectingIp: TenantId=4b0911a0-929b-4715-944b-c03745165b3a;Ip=[136.226.152.54];Helo=[was11a2.mail.zscalertwo.net]
X-MS-Exchange-CrossTenant-AuthSource:
	SJ1PEPF000037BB.namprd05.prod.outlook.com
X-MS-Exchange-CrossTenant-AuthAs: Anonymous
X-MS-Exchange-CrossTenant-FromEntityHeader: HybridOnPrem
X-MS-Exchange-Transport-CrossTenantHeadersStamped: DM6PR06MB6747
X-Proofpoint-Spam-Info: AW1haW4tMjYwOTMwMDAwNCBTYWx0ZWRfXxbYypuhrJMUF
 /BNxXOG0MAuxzc4BK3qkaTu/1ervN82IK1t8kAA6ZCFkU1pmitmo3Bqfj2NcietzvIgrJ7mhDEK
 j3B7htDzLZpjTKqMJtkZBmJz05xgaOA=
X-Authority-Analysis: v=2.4 cv=b6AncdGx c=1 sm=1 tr=0 ts=6abc6380 cx=c_pps
 a=AG4d6nCg1awo7HAtkzPOig==:117 a=/R7wsi6P8MDabg3Hr5WfTA==:17
 a=6eWqkTHjU83fiwn7nKZWdM+Sl24=:19 a=lCpzRmAYbLLaTzLvsPZ7Mbvzbb8=:19
 a=xqWC_Br6kY4A:10 a=8nJEP1OIZ-IA:10 a=VdqzKS8jKosA:10 a=GWG4Yq0kndkA:10
 a=VkNPw1HP01LnGYTKEx00:22 a=1lWG0UuNQvn8UhQ8Wh4S:22 a=X7e-fZ-CKB32rjcIpVUG:22
 a=BEa9-PVfITzyacPP7l0A:9 a=wPNLvfGTeEIA:10
X-Proofpoint-Spam-Details-Enc: AW1haW4tMjYwOTMwMDAwNCBTYWx0ZWRfX4vR/hSTPDMBV
 Z8GJvOPvObyjMfeDIUCOFDKLbCtaAdR5V1Alwxm/SsE3VGP9FJqDWOrIG0ryatytkVlKfc91Kv5
 cD7YnPQJGNNruC8Iod/FYTW8rB64WCX7BjUf7Raha06XS2rWvDz535whtQEMuH3c1zdc+kXXNmc
 y4IK/sjzCx0+aBHmmXSHhCoSYCL6cLljxOM39KVnvZg7HzC0ZYkNr5qAQKrIZUU749o+Cfo6VUv
 aEq8fV+flxXebG4gjzBPmifMadcnyCt2ixex/YXSnFLQOLnW3Au9Uhbv/VlIEYZ2aVSsmPi+NBX
 2nTpP1k54W7i0cyhQaSyz/+Zz0nEneLpks78jiT6zHR+WFg3lwam9jk/BkoInWdZMOXkC0qGas8
 DZU/5Cxs/KzJH2bbM58G/5nDXFStXSJaZmhKZd4XaslbKvHHRbjbumvf7+pMT9cd4kRyKwtr6RM
 lRlMULTr0qQEKRXRI9g==
X-Proofpoint-ORIG-GUID: IwjGMM4szAxAk6bJH0aih7UQ-dO3t3xt
X-Proofpoint-GUID: IwjGMM4szAxAk6bJH0aih7UQ-dO3t3xt
X-Proofpoint-Virus-Version: vendor=baseguard
 engine=ICAP:2.0.293,Aquarius:18.0.1176,Hydra:6.1.134,FMLib:17.12.100.49
 definitions=2026-09-29_05,2026-09-21_02,2025-10-01_01
X-Proofpoint-Spam-Details: rule=outbound_notspam policy=outbound score=0
 bulkscore=0 clxscore=1011 impostorscore=0 phishscore=0 spamscore=0
 adultscore=0 lowpriorityscore=0 suspectscore=0 malwarescore=0
 priorityscore=1501 classifier=typeunknown authscore=0 authtc= authcc=
 route=outbound adjust=0 reason=mlx scancount=1 engine=8.22.0-2609040000
 definitions=main-2609300004

Greetings,=0A=
=0A=
Hitting the following on RHEL 8.10, is this a know issue?=0A=
=0A=
[ 2621.743900] BUG: unable to handle kernel paging request at 0000000000034=
620=0A=
[ 2621.750981] PGD 17629f067 P4D 0=0A=
[ 2621.754307] Oops: 0002 [#1] SMP NOPTI=0A=
[ 2621.758075] CPU: 3 PID: 7560 Comm: mount.nfs Kdump: loaded Tainted: G   =
            X  -------- -  - 4.18.0-553.166.1.el8_10.x86_64 #1=0A=
[ 2621.770252] Hardware name: Google Google Compute Engine/Google Compute E=
ngine, BIOS Google 07/08/2026=0A=
[ 2621.779565] RIP: 0010:__pv_queued_spin_lock_slowpath+0x19e/0x2a0=0A=
[ 2621.785671] Code: c4 c1 ea 12 41 be 01 00 00 00 4c 8d 6d 14 41 83 e4 03 =
8d 42 ff 49 c1 e4 05 48 98 49 81 c4 c0 45 03 00 4c 03 24 c5 80 68 bc 8e <49=
> 89 2c 24 b8 00 80 00 00 eb 15 84 c0 75 0a 41 0f b6 54 24 14 84=0A=
[ 2621.804534] RSP: 0018:ff54fdc2819f7c40 EFLAGS: 00010202=0A=
[ 2621.809856] RAX: 0000000000003ffe RBX: ff12559d4610e440 RCX: 00000000000=
00001=0A=
[ 2621.817085] RDX: 0000000000003fff RSI: 0000000000000000 RDI: 00000000000=
00000=0A=
[ 2621.824315] RBP: ff1255a06fbb45c0 R08: 0000000000000000 R09: ff12559d442=
35f20=0A=
[ 2621.831544] R10: 0000000000000004 R11: 0000000000000000 R12: 00000000000=
34620=0A=
[ 2621.838773] R13: ff1255a06fbb45d4 R14: 0000000000000001 R15: 00000000001=
00000=0A=
[ 2621.846001] FS:  00007ff93f0b6880(0000) GS:ff1255a06fb80000(0000) knlGS:=
0000000000000000=0A=
[ 2621.854186] CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033=0A=
[ 2621.860222] CR2: 0000000000034620 CR3: 00000001161f6003 CR4: 00000000003=
71ee0=0A=
[ 2621.867454] DR0: 0000000000000000 DR1: 0000000000000000 DR2: 00000000000=
00000=0A=
[ 2621.874684] DR3: 0000000000000000 DR6: 00000000fffe07f0 DR7: 00000000000=
00400=0A=
[ 2621.881914] Call Trace:=0A=
[ 2621.884460]  ? __die_body+0x1a/0x60=0A=
[ 2621.888047]  ? no_context+0x1ba/0x3f0=0A=
[ 2621.891806]  ? __bad_area_nosemaphore+0x157/0x180=0A=
[ 2621.896608]  ? do_page_fault+0x37/0x12d=0A=
[ 2621.900539]  ? page_fault+0x1e/0x30=0A=
[ 2621.904125]  ? __pv_queued_spin_lock_slowpath+0x19e/0x2a0=0A=
[ 2621.909619]  _raw_spin_lock+0x1e/0x30=0A=
[ 2621.913379]  list_lru_add+0x60/0x140=0A=
[ 2621.917052]  d_lru_add+0x51/0xd0=0A=
[ 2621.920376]  dput.part.36+0x133/0x150=0A=
[ 2621.924135]  drop_mountpoint+0x12/0x50=0A=
[ 2621.927981]  pin_kill+0x87/0x190=0A=
[ 2621.931305]  ? finish_wait+0x80/0x80=0A=
[ 2621.934990]  group_pin_kill+0x1a/0x30=0A=
[ 2621.938747]  namespace_unlock+0x73/0x80=0A=
[ 2621.942678]  put_mnt_ns+0x21/0x30=0A=
[ 2621.946091]  mount_subtree+0xec/0x160=0A=
[ 2621.949850]  do_nfs4_mount+0x24e/0x390 [nfsv4]=0A=
[ 2621.954412]  nfs4_try_get_tree+0x44/0xb0 [nfsv4]=0A=
[ 2621.959137]  vfs_get_tree+0x25/0xc0=0A=
[ 2621.962722]  do_mount+0x2e9/0x980=0A=
[ 2621.966136]  ksys_mount+0xbe/0xe0=0A=
[ 2621.969547]  __x64_sys_mount+0x21/0x30=0A=
[ 2621.973390]  do_syscall_64+0x5b/0x1d0=0A=
[ 2621.977157]  entry_SYSCALL_64_after_hwframe+0x66/0xcb=0A=
[ 2621.982306] RIP: 0033:0x7ff93e458e3e=0A=
[ 2621.985980] Code: 48 8b 0d 4d 60 39 00 f7 d8 64 89 01 48 83 c8 ff c3 66 =
2e 0f 1f 84 00 00 00 00 00 90 f3 0f 1e fa 49 89 ca b8 a5 00 00 00 0f 05 <48=
> 3d 01 f0 ff ff 73 01 c3 48 8b 0d 1a 60 39 00 f7 d8 64 89 01 48=0A=
[ 2622.004927] RSP: 002b:00007ffead0d9758 EFLAGS: 00000246 ORIG_RAX: 000000=
00000000a5=0A=
[ 2622.012592] RAX: ffffffffffffffda RBX: 0000000000000000 RCX: 00007ff93e4=
58e3e=0A=
[ 2622.019820] RDX: 000055e338ed54e0 RSI: 000055e338ed56c0 RDI: 000055e338e=
d5650=0A=
[ 2622.027050] RBP: 00007ffead0d98e0 R08: 000055e338edae30 R09: 003733322e3=
03432=0A=
[ 2622.034280] R10: 0000000000000000 R11: 0000000000000246 R12: 00007ffead0=
d98e0=0A=
[ 2622.041509] R13: 000055e338edaa00 R14: 0000000000000010 R15: 000055e3376=
66ed9=0A=
[ 2622.048738] Modules linked in: xt_conntrack ipt_MASQUERADE bridge stp ll=
c xt_set nft_counter xt_addrtype nft_compat rpcsec_gss_krb5 auth_rpcgss nfs=
v4 dns_resolver nfsv3 nfs_acl nfs lockd grace fscache scsi_transport_iscsi =
nft_fib_inet nft_fib_ipv4 nft_fib_ipv6 nft_fib nft_reject_inet nf_reject_ip=
v4 nf_reject_ipv6 nft_reject nft_ct nf_tables_set nft_chain_nat nf_nat nf_c=
onntrack nf_defrag_ipv6 nf_defrag_ipv4 ip_set overlay nf_tables nfnetlink e=
xt4 mbcache jbd2 loop sunrpc vfat fat dm_service_time dm_multipath dm_mod i=
ntel_rapl_msr intel_rapl_common intel_uncore_frequency_common nfit libnvdim=
m crc32_pclmul rapl i2c_piix4 pcspkr xfs libcrc32c crct10dif_pclmul crc32c_=
intel ghash_clmulni_intel gve serio_raw virtio_scsi nvme nvme_tcp(X) nvme_f=
abrics nvme_core t10_pi fuse=0A=
=0A=
=0A=
Thanks,=0A=
=0A=
--Jorge=

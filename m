Received: from mx0b-003fbd02.pphosted.com (mx0b-003fbd02.pphosted.com [67.231.157.221])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 939E9367F2F
	for <linux-nfs@vger.kernel.org>; Mon, 24 Aug 2026 16:30:27 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=fail smtp.client-ip=67.231.157.221
ARC-Seal:i=3; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1787589030; cv=fail; b=ScEAxefYdk42Uq4//JfTdYxeMeGFO2E/BjZu0zcYo05PMrotPeDO3IMjwUhAgRZkdTu2TtebFGSV+VNM7612DsZPerPZVzbF0WF7mYA73g2j2f10+NmBmIuhRoWj0FTGElBJ2oE16DAfdURI4KAQOQAWjAEemr6EwFY5vpWdwW4=
ARC-Message-Signature:i=3; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1787589030; c=relaxed/simple;
	bh=hgwYibwX1OTFWpvXZoCe/FZRnFi7sdJLupqiz6x0E5I=;
	h=From:To:CC:Subject:Date:Message-ID:Content-Type:MIME-Version; b=Asn7akzVXN4ExC2XnJ9NAIMgxwKviiv3WAaA1rCJbdzea4rQ/CH76uBATTuMQ8W9mIdGNvk/RqoVqO4EOF/krOejupdSCE5brNHH5xtJAjMdrNgeMooWJF3acI1nwJdaiAx7smYm+uuma1WUYqrEGWFXDWgqH35/yF1W7ZZB6NE=
ARC-Authentication-Results:i=3; smtp.subspace.kernel.org; dmarc=pass (p=reject dis=none) header.from=netapp.com; spf=pass smtp.mailfrom=netapp.com; dkim=pass (2048-bit key) header.d=netapp.com header.i=@netapp.com header.b=BmS8pgcp; dkim=pass (2048-bit key) header.d=netapp.com header.i=@netapp.com header.b=JLgoFXz6; dkim=pass (2048-bit key) header.d=netapp.com header.i=@netapp.com header.b=JLgoFXz6; arc=fail smtp.client-ip=67.231.157.221
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=reject dis=none) header.from=netapp.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=netapp.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=netapp.com header.i=@netapp.com header.b="BmS8pgcp";
	dkim=pass (2048-bit key) header.d=netapp.com header.i=@netapp.com header.b="JLgoFXz6";
	dkim=pass (2048-bit key) header.d=netapp.com header.i=@netapp.com header.b="JLgoFXz6"
Received: from pps.filterd (m0412384.ppops.net [127.0.0.1])
	by mx0b-003fbd02.pphosted.com (8.18.1.11/8.18.1.11) with ESMTP id 67OFrAA11013892;
	Mon, 24 Aug 2026 16:07:48 GMT
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=netapp.com; h=cc
	:content-transfer-encoding:content-type:date:from:message-id
	:mime-version:subject:to; s=pps1; bh=hgwYibwX1OTFWpvXZoCe/FZRnFi
	7sdJLupqiz6x0E5I=; b=BmS8pgcpLhHSvS8vzzOpDIlKEZWQZUhN7Lbi3kf7Mn8
	+zlB6SDdmTcirBHqNhel43fhxKFOjYyKxJOF1xtBioD2C4Ya4/9aJjnagprM80HM
	vjsghMtU2nNkWZBjW8Hyv2rBuhAvxImFLAeWQ+TPWoiZ1FGh6klzJZGN0VjM24iR
	jWk875J2UAZidiiHHW+jvPyWDnn99tcpv87cT1TI60iNyN4libH8sF0Xt8XJP4iA
	bVWGEJfP49NI2mubjZACxqNWbxEEnguP1s3lYSWGrsrKf3tGjhB38xu+bownMb8q
	KYAbNWI7DP26jyqtJTpCDfA97oVqdaINY0W6a3T6LKg==
Received: from ph0pr06cu001.outbound.protection.outlook.com (mail-westus3azon11011039.outbound.protection.outlook.com [40.107.208.39])
	by mx0b-003fbd02.pphosted.com (PPS) with ESMTPS id 4g7s3jcwke-1
	(version=TLSv1.3 cipher=TLS_AES_256_GCM_SHA384 bits=256 verify=NOT);
	Mon, 24 Aug 2026 16:07:48 +0000 (GMT)
ARC-Seal: i=2; a=rsa-sha256; s=arcselector10001; d=microsoft.com; cv=pass;
 b=yiPCMYWDHaTxJe0eYy2C2CA43GZd2lS6uoeLs1C2267vU5MW2ZHp06GlDBCuy+qQb9SLa42nJpd5rzOFGwd4bsUJMi+9XLMmL8otyeDcEqE6pYIM4KDPvo+r8a8CqDHIRhZQSPtG3ibI54AG1WvHT3bbQJ4bgA/FKaGxi2FDw5GtvKuTt0LjKEAr2i1WUK3xZQiUi/IzoYd2rZjuHqN6scfRgFqosFRNw/49i+1v2UC9WuMUdLd/Imwk5mrM4XN/X5TJMz1a6G9PyiEKt19+05dGCZx3du2xAaHSKe+NMnA1bh+0PZbWzxBiNQC0CL5TrztkpLLUcY+ZCEGzMiPUvg==
ARC-Message-Signature: i=2; a=rsa-sha256; c=relaxed/relaxed; d=microsoft.com;
 s=arcselector10001;
 h=From:Date:Subject:Message-ID:Content-Type:MIME-Version:X-MS-Exchange-AntiSpam-MessageData-ChunkCount:X-MS-Exchange-AntiSpam-MessageData-0:X-MS-Exchange-AntiSpam-MessageData-1;
 bh=hgwYibwX1OTFWpvXZoCe/FZRnFi7sdJLupqiz6x0E5I=;
 b=zUJse7T+7i5Kn97xpBJKEnQKgZfhfIcopoT+7eG3lenAi40pW5NC6qbjBFlvDm8QOihz0HC+cgsTj7I6umZYYjbS/xth+HwHywS8Jal8TZFXY4J6EPFUgFKdu4SrGkTGSZ6Bfkg/r2FsBAGxVfjYXy1ROchCtItfUzFCW4o2klX5r3OHP0KmMevfEILbqYpu+GfeUAo5Ju6iTU7a8W0BtlbtndTmzIs2ED2Y+jCMkQHsy4MRGKm3kdWwJ5tdSyB4Lb8+gRzT8oknS5QxOBltM/7YsXuSmYLr98g1giT0yLLJloGoZoElPFY/d6g0EtpeksnIGrU/d71rmewgoGKIVg==
ARC-Authentication-Results: i=2; mx.microsoft.com 1; spf=fail (sender ip is
 136.226.152.55) smtp.rcpttodomain=redhat.com smtp.mailfrom=netapp.com;
 dmarc=pass (p=reject sp=reject pct=100) action=none header.from=netapp.com;
 dkim=pass (signature was verified) header.d=netapp.com; arc=pass (0 oda=1
 ltdi=1 spf=[1,1,smtp.mailfrom=netapp.com] dkim=[1,1,header.d=netapp.com]
 dmarc=[1,1,header.from=netapp.com])
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=netapp.com;
 s=selector1;
 h=From:Date:Subject:Message-ID:Content-Type:MIME-Version:X-MS-Exchange-SenderADCheck;
 bh=hgwYibwX1OTFWpvXZoCe/FZRnFi7sdJLupqiz6x0E5I=;
 b=JLgoFXz6kHEvEFLXbkdPgjumdR72/Ubv3I61K7t2nX7D/mPQnz+QCLGk+lX4W1fSEBdT555RoVYNW2nonLYaCe1JpJjXbFFo4uGTMzPy9gmtD7bGi2WVhuRXnGdiC2oZEgfNKifsmoKTY5hL8RDAP+z477Vj7oR4Ml66emiVBlUHuF/iVQP6uKfQxv3ZMUJfRjZWpYJIFum97fzGZYBTG1+TeD0oASx3JTjSEC0mRUun8440/ZZ63m27A2UYwVPPbt83YmBK3YRiBO1lPd3nkZG/2xlfMC29PdAZy4dw+pyrKFwpjYyQMBK97cHghM5MYDJnRRVd82vs1GEq6pHodg==
Received: from MN2PR20CA0053.namprd20.prod.outlook.com (2603:10b6:208:235::22)
 by PH0PR06MB7397.namprd06.prod.outlook.com (2603:10b6:510:4e::14) with
 Microsoft SMTP Server (version=TLS1_2,
 cipher=TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384) id 15.21.360.6; Mon, 24 Aug
 2026 16:07:44 +0000
Received: from BL6PEPF00020E5F.namprd04.prod.outlook.com
 (2603:10b6:208:235:cafe::3d) by MN2PR20CA0053.outlook.office365.com
 (2603:10b6:208:235::22) with Microsoft SMTP Server (version=TLS1_3,
 cipher=TLS_AES_256_GCM_SHA384) id 15.21.339.12 via Frontend Transport; Mon,
 24 Aug 2026 16:07:43 +0000
X-MS-Exchange-Authentication-Results: spf=fail (sender IP is 136.226.152.55)
 smtp.mailfrom=netapp.com; dkim=pass (signature was verified)
 header.d=netapp.com;dmarc=pass action=none header.from=netapp.com;
Received-SPF: Fail (protection.outlook.com: domain of netapp.com does not
 designate 136.226.152.55 as permitted sender)
 receiver=protection.outlook.com; client-ip=136.226.152.55;
 helo=was11a3.mail.zscalertwo.net;
Received: from was11a3.mail.zscalertwo.net (136.226.152.55) by
 BL6PEPF00020E5F.mail.protection.outlook.com (10.167.249.20) with Microsoft
 SMTP Server (version=TLS1_3, cipher=TLS_AES_256_GCM_SHA384) id 15.21.360.3
 via Frontend Transport; Mon, 24 Aug 2026 16:07:43 +0000
Received: from co1pr07cu001.outbound.protection.outlook.com ([40.93.10.91])
	by was11a3.mail.zscalertwo.net ([136.226.152.43])
	with ESMTPS id 6A8C6C4F08F50001;
	Mon, 24 Aug 2026 12:07:43 -0400
ARC-Seal: i=1; a=rsa-sha256; s=arcselector10001; d=microsoft.com; cv=none;
 b=ZxLWoV7aGfp67Rh5Kas2V9JVLewUXcwZPAa4X1wMEa73Md4jXDucMubylbg3JlzD6kGqFSvEDQxCcpZBraaxwdL5oyuCb25lbTWayjqLXixbLNsFTG5KJrAAK5Ki8Bw/96sKgOrV4TvToCGtbdy/F1e3JRwcE8by3s/1q/SwElyMBNnSh96IRnAcWsr9oOm1XV23k/u//nZwwYHoBH8u6QqMtlJDUB44WLx9RNHejXSA5ocl2L0iwk36OtmRCjIqr5ZKSjbefrDv/RnTVEskI2tHO043xsbCnkX1OXj/bDTnNrF0487U4f3DX36QWalOlRsIJJopKd83kXsbqWCjzg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=microsoft.com;
 s=arcselector10001;
 h=From:Date:Subject:Message-ID:Content-Type:MIME-Version:X-MS-Exchange-AntiSpam-MessageData-ChunkCount:X-MS-Exchange-AntiSpam-MessageData-0:X-MS-Exchange-AntiSpam-MessageData-1;
 bh=hgwYibwX1OTFWpvXZoCe/FZRnFi7sdJLupqiz6x0E5I=;
 b=ruciFiKboqTk2zBAzEcYckAvCD4jnRtE95R8qe7sr8kdYxGTCe8DnQ7840rUfZQRavx5zOMTZx78EnpimVdxjpt52wBHgghZ7edsyTFtAEpnCL2NGfnDKt9dR1rR8xbO5Hc32NUvB57B+v7YZZ3ehNmVeuri5j7PDZ8fMpyH/uNY+oLsRmlMEajuovdYYQXwqx8cl30Pom9j3bQIy4stzRlReaScmw0e1sr4/yLnZhPaAn2NsDisk4/wLbR6MW1WUAhbsj45jQRZZXCgTGNeTcb+kMZtUERA375T0bqpYu4zZMQbag+XMvV6ogquydZgeFppj7FsWUETwOcmInBTNg==
ARC-Authentication-Results: i=1; mx.microsoft.com 1; spf=pass
 smtp.mailfrom=netapp.com; dmarc=pass action=none header.from=netapp.com;
 dkim=pass header.d=netapp.com; arc=none
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=netapp.com;
 s=selector1;
 h=From:Date:Subject:Message-ID:Content-Type:MIME-Version:X-MS-Exchange-SenderADCheck;
 bh=hgwYibwX1OTFWpvXZoCe/FZRnFi7sdJLupqiz6x0E5I=;
 b=JLgoFXz6kHEvEFLXbkdPgjumdR72/Ubv3I61K7t2nX7D/mPQnz+QCLGk+lX4W1fSEBdT555RoVYNW2nonLYaCe1JpJjXbFFo4uGTMzPy9gmtD7bGi2WVhuRXnGdiC2oZEgfNKifsmoKTY5hL8RDAP+z477Vj7oR4Ml66emiVBlUHuF/iVQP6uKfQxv3ZMUJfRjZWpYJIFum97fzGZYBTG1+TeD0oASx3JTjSEC0mRUun8440/ZZ63m27A2UYwVPPbt83YmBK3YRiBO1lPd3nkZG/2xlfMC29PdAZy4dw+pyrKFwpjYyQMBK97cHghM5MYDJnRRVd82vs1GEq6pHodg==
Received: from SA6PR06MB10469.namprd06.prod.outlook.com
 (2603:10b6:806:43f::18) by BLAPR06MB6945.namprd06.prod.outlook.com
 (2603:10b6:208:297::19) with Microsoft SMTP Server (version=TLS1_2,
 cipher=TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384) id 15.21.360.6; Mon, 24 Aug
 2026 16:07:40 +0000
Received: from SA6PR06MB10469.namprd06.prod.outlook.com
 ([fe80::927c:aeaa:a0b9:a113]) by SA6PR06MB10469.namprd06.prod.outlook.com
 ([fe80::927c:aeaa:a0b9:a113%4]) with mapi id 15.21.0360.005; Mon, 24 Aug 2026
 16:07:38 +0000
From: "Bhargava, Rakesh" <Rakesh.Bhargava@netapp.com>
To: "trondmy@kernel.org" <trondmy@kernel.org>,
        "anna@kernel.org"
	<anna@kernel.org>
CC: "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>,
        "smayhew@redhat.com" <smayhew@redhat.com>,
        "okorniev@redhat.com"
	<okorniev@redhat.com>,
        "Mora, Jorge" <Jorge.Mora@netapp.com>
Subject: [BUG] NFSv3 RDMA :  READ corrupts payload when READ3res omits
 post_op_attr
Thread-Topic: [BUG] NFSv3 RDMA :  READ corrupts payload when READ3res omits
 post_op_attr
Thread-Index: AQHdM+KK4goiASSGVkyTcP6+M8P3aQ==
Date: Mon, 24 Aug 2026 16:07:38 +0000
Message-ID:
 <SA6PR06MB104695205126871E29444567A8BA02@SA6PR06MB10469.namprd06.prod.outlook.com>
Accept-Language: en-US
Content-Language: en-US
X-MS-Has-Attach:
X-MS-TNEF-Correlator:
msip_labels:
Authentication-Results-Original: dkim=none (message not signed)
 header.d=none;dmarc=none action=none header.from=netapp.com;
x-ms-traffictypediagnostic:
	SA6PR06MB10469:EE_|BLAPR06MB6945:EE_|BL6PEPF00020E5F:EE_|PH0PR06MB7397:EE_
X-MS-Office365-Filtering-Correlation-Id: 77d6335e-6873-4273-7ddb-08df01f9d495
X-MS-Exchange-SenderADCheck: 1
X-MS-Exchange-AntiSpam-Relay: 0
X-Microsoft-Antispam-Untrusted:
 BCL:0;ARA:13230040|376014|23010399003|1800799024|366016|38070700021|3023799007|10067099003|56012099006|11063799006|18002099003;
X-Microsoft-Antispam-Message-Info-Original:
 viX+ebWe+bune4r19WtZ33CJZRwI1tRdpXbiNaWlWvIaUiOqVSR8hkZPmsbjrSXL7CSEWI59AuvHn1sxZt6BVcqGDNBNcloCjxbg/GafzhpEizo8wQb217JQ9RSwgraVnLzs2xb8fg6lLlnJb0xD+6ay17qg5PRgRPmei4FQ0l+yGJHBcD1m68j6NGnbK8jELmAHZ7vHKqA8IqixulTayr0Xj/Rv5x8/A2K/5wMFpjwtC5p0UJ5R8jBKKBXJXjnPdDsxWb7Cv3XWY0GmqpOEmtTmwRnUtx7gehsy+gEgOSvRPoe+gPemeYh/Exg22LLb7PtdCweN4ak5QbngJe0H/fOqCRJuMjY7/FPkQdqVi/6dOuYrRB2oFJ/HtxukX2yB1aeNov78k4E2XJwm1k+A7gcIAmQrG2UHvv37ZdOYj/8gnNP80A3YMmWcXZBtZe/IZwy0UZvsfq1yqOyQRtoCHw/+OJQiuSGhc1DHolqlbEfkgYyykOEuAS62teHORIurHrLk5bTLPw+pMYcNc71//QRruDB+6k6l9kvEzztrqM/Hy8VHkOl3Z/OFV6ba+apaU8X/Krkn61oElJ/O4Lb70odqeMuix8QADg2OfmaQ1gaWbyEWiM4FhYpRjDcHiyiUBDcFPK+7MvF7EZB4TOF+kkjznvNxM2rUw2jgUy0Ziz90CvFkIIoDYUmeS61KA8SgYo88gNi9SreRoHGx1zTFEXhTu/ex0a3/8EuomkxqnXA=
X-Forefront-Antispam-Report-Untrusted:
 CIP:255.255.255.255;CTRY:;LANG:en;SCL:1;SRV:;IPV:NLI;SFV:NSPM;H:SA6PR06MB10469.namprd06.prod.outlook.com;PTR:;CAT:NONE;SFS:(13230040)(376014)(23010399003)(1800799024)(366016)(38070700021)(3023799007)(10067099003)(56012099006)(11063799006)(18002099003);DIR:OUT;SFP:1101;
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
X-Exchange-RoutingPolicyChecked:
 ux4irvwKKkND9L7/0ASCkVQhjDgPPzr+D272l4RpEJWEEqDkDmQRyVtz8aUkIWSr6FA09V2AHvJLCINX5p9aD8pfzSXOTi0C8lKMsEF4z3K4HvdMYPgpmZMyfqrkBCStfCIWijJlNCiD6Y9mKz/tziUzTuXyzXiiclmc93vdOS7hlPlexcrO777cCg+jqxxI/LJevNJZzKsde58QK6Hn9HH0hn90S2V4Fs5P6BMPQgRRooxLvadHALQSdiPI2jlLcYPdu3LM9KFw08rdeY/eGyN3aTWyW6EwV674zg2fv1Ox8eBmwJqgFsELDv0BSohxp7AiiB39jXn9RONti0D+sw==
X-MS-Exchange-Transport-CrossTenantHeadersStamped: BLAPR06MB6945
X-Zscaler-Block: 0
X-EOPAttributedMessage: 0
X-MS-Exchange-Transport-CrossTenantHeadersStripped:
 BL6PEPF00020E5F.namprd04.prod.outlook.com
X-MS-PublicTrafficType: Email
X-MS-Office365-Filtering-Correlation-Id-Prvs:
	44e6cae8-5d19-4f20-47fc-08df01f9d1cf
X-Microsoft-Antispam:
	BCL:0;ARA:13230040|82310400026|23010399003|36860700016|35042699022|376014|1800799024|14060799003|56012099006|11063799006|10067099003|3023799007|18002099003;
X-Microsoft-Antispam-Message-Info:
	d4gumYOM8scabYJ73cPLr76eSZZZ/efj3WRFTfUY7yNy2bXeT4CYOW8Im7NgmtN/u5pJwAHE8y5c671Nrphcuk2nPSBKUhAbOHDuoS6fwCKWIbmWZ60hGN/nPDZ72usO6BDK8xwv736v4fSOcbaTz7euzjA6X4q+2z3us6A/jsPLl2KdHe/MZFyNvM6GM7GDh5dgGUjnls2sv0vPEc755jjiXl2HY+HvRdrjC0rwUxbdl8dICl1iEpQwqtpOrV8y4N8C2YF3AffucBh06+GGvYqt2csk8NveeW9WvArzn94SoEUztysHrg6h7tGgnQMspEfpf2xE/tTb03nQ5hVIW+OzPKBWAksLUHDtdgbvDZoara/IqCALezn1foWMW2tuPTk1FLzHuZDPou9rkA8lwtsVWCMrpzkkDWg28Nsb+mQdMJ09L1jHwwPTBaqKJB8u5kFaJdI0y8acGS8ozo8s0vKYaVHm5oiTv5YB2MvEts6OZDMomIcpRy08OQ0Cy2RQJgDMCsR6nI/1Y/qbCRHZ9rCLW2jfKWdq9n4/xoZqnduwlBt+TL47k2zfzmKQFy+CYPL+oLw3zyWIBJKDOFkVslCdIEThkhvg9vDdrnJZkvWh5+21PyZhfNXXnhCBEKQxiqU1A3NBe/moN6uyUzYkZpOgqpIX/YCNvjMzi6U8scGoE430SNWssS1lj39ewJYIVYzIWrM3FuWChwI5/Prz2g==
X-Forefront-Antispam-Report:
	CIP:136.226.152.55;CTRY:US;LANG:en;SCL:1;SRV:;IPV:NLI;SFV:NSPM;H:was11a3.mail.zscalertwo.net;PTR:was11a3.mail.zscalertwo.net;CAT:NONE;SFS:(13230040)(82310400026)(23010399003)(36860700016)(35042699022)(376014)(1800799024)(14060799003)(56012099006)(11063799006)(10067099003)(3023799007)(18002099003);DIR:OUT;SFP:1101;
X-MS-Exchange-AntiSpam-MessageData-ChunkCount: 1
X-MS-Exchange-AntiSpam-MessageData-0:
	eG4ReI2n6DtuMuCcjjr9KFbeXklZqdP0994Y7siQbVXZJvh/YdffCSo52joz/LbL4aAE+m15sM00ymdRzO6m3IHPtucg/2ztoisFSKCsC9rFwGX39OT5ZSHUQ+QoYmIvlf4cw6HPwNB85XbvHXkLAG4L0LTteG5e+0fOYlQPEQI0Oe/2B3ynHrvdwg6eyyBBmSY6CZrI38JQlxl1GzV2PJh+W8jpkvIc2m4bxtXAPOAmmNiyOG3lplsMtEZtI5fNGvapJqO1a92wMqMjseSeH2q7Da+6TjT6Q3ig/jqAGB1+hZgnBgROpFYGF2NZkiYrdo6IEaPSTbkYVpwbBtQiKqZaI2MX6PgWAoaBSKWJeFnr3EM6PxCYqpSYjhFlARrngc2Ba6CEF7/9cydiuuChk8qDeMYtQX7AvzbWia+P+TV9gQJwGtKMCbzjTGAwhVzr
X-MS-Exchange-AntiSpam-ExternalHop-MessageData-ChunkCount: 1
X-MS-Exchange-AntiSpam-ExternalHop-MessageData-0:
	GlrhVZJuTCZy2x26CGHYpz4qDYARSyoUI3XonpjjV02FjhwOAPluD4S1ySJ/0Pu0y/qo469xwnZqkQN7lQSppN6PGOHDcD3f6tVWglvpbyMLoyUFImHsHmyJ7XKv8Z+8h5YcD/a9aECIh6KW1NInAWgwuX7Pb7RQKsCHLnDK9+ZC0hustDQaklblisimEnKn9PQuz1GWeZH/7zmcrkh4PJZ9it6VJ9F6OUBvgjtVUxSDk5KiQd0lrn2xdb3NtjueKPzDoS9ujPFLOSJxP7mvWNAQsO6VfOdnQ5NRrOWTdH5qbPWGV6knp2fuBi3Jkjiv3aVEc/V4MLL5V3ZPDQYoQ6WLDM2BwmGtSD3DBIw8Wk32wKy3GVzHrGwtQd1AQOJRojiXY929wKPMFDfOF+eFzBdGcaAulhJg/AM3UG+4FA8J0fsXGNSjJNQjlTa/S+EtCpZOmfOwCO4Vl2NQsO1RA8tjRa9Eho/5RmM4BN3l3rz5tOMrFM4Oa0gNMJnol498aob7rxIZkJDNASjkVwc0LFUnxF26MpJMqHXruoxfVUfSdtLuIqV7MxO5hoOqBrEVztDipXbA5fIMDT00LSqgT9lEaFqYaVWaGEjS5Vuc2drL+iM8F2xIHJR612KX9c2L
X-OriginatorOrg: netapp.com
X-MS-Exchange-CrossTenant-OriginalArrivalTime: 24 Aug 2026 16:07:43.4407
 (UTC)
X-MS-Exchange-CrossTenant-Network-Message-Id: 77d6335e-6873-4273-7ddb-08df01f9d495
X-MS-Exchange-CrossTenant-Id: 4b0911a0-929b-4715-944b-c03745165b3a
X-MS-Exchange-CrossTenant-OriginalAttributedTenantConnectingIp: TenantId=4b0911a0-929b-4715-944b-c03745165b3a;Ip=[136.226.152.55];Helo=[was11a3.mail.zscalertwo.net]
X-MS-Exchange-CrossTenant-AuthSource:
	BL6PEPF00020E5F.namprd04.prod.outlook.com
X-MS-Exchange-CrossTenant-AuthAs: Anonymous
X-MS-Exchange-CrossTenant-FromEntityHeader: HybridOnPrem
X-MS-Exchange-Transport-CrossTenantHeadersStamped: PH0PR06MB7397
X-Proofpoint-GUID: XcYLYSLjC3RuVrLLOdj6RZg9GYK-NMhf
X-Proofpoint-Spam-Info: AW1haW4tMjYwODI0MDEzNSBTYWx0ZWRfXyO5BgdiOzq6t
 kweh/XTAybzifyeTV26nAqwcLBnwWyvRE+4c+hv39RvZ37S02WBn06hqjhWLjZp8Lsh+tdMrTJ4
 YZWD3r5a1B644ffP4JCxGXL1BSyKdj4=
X-Proofpoint-ORIG-GUID: XcYLYSLjC3RuVrLLOdj6RZg9GYK-NMhf
X-Authority-Analysis: v=2.4 cv=QJ9YgALL c=1 sm=1 tr=0 ts=6a8c6c54 cx=c_pps
 a=ILySzFF5iTKX7yzk26Ee5Q==:117 a=mXINPvuA9v3YlNpONGpdOA==:17
 a=6eWqkTHjU83fiwn7nKZWdM+Sl24=:19 a=lCpzRmAYbLLaTzLvsPZ7Mbvzbb8=:19
 a=xqWC_Br6kY4A:10 a=8nJEP1OIZ-IA:10 a=Sv0fKeRqtYgA:10 a=GWG4Yq0kndkA:10
 a=VkNPw1HP01LnGYTKEx00:22 a=1lWG0UuNQvn8UhQ8Wh4S:22 a=aI3CQ4rmUk7SosRCZclN:22
 a=eQ06qM7Koufcy8VxZZ8A:9 a=wPNLvfGTeEIA:10
X-Proofpoint-Spam-Details-Enc: AW1haW4tMjYwODI0MDEzNSBTYWx0ZWRfXxk66sXbpC8Rk
 Hi8fi8oWKgJYnyaEssuk77NBIEUfBOiPGb/Bnu3fUIkAxgLC/ozqjdh7rd11dFx/Pbg23NB4s4H
 MJiDTWMfaDttOcYWEyXug78cJqDWVXb5aidx4rIAQ1K7Cw9Abgp3A9jDL7z6P4nIUS0feVNzRTb
 /Vh+cPI5qKcG2vJ0ZPCoX7EoB0lBIfN10e0KYYSoQ8IUvaAA6otmrqSXGGv+iHevi5sk6eys/va
 ZyqGMkN2hSsnQXOQ86LT4b825bp3Q8HN+i2KGFhtLSvX1DSgRrYcEL9eRSvwpmT82eLG9LWmUgB
 GTFH6YMARK3OOp9YDRkTYlAF1+BgoQHaHdgE2f+6kli+9YlRC3MhE2qqNm6GQejOYPb8cjxITNw
 641YnM38jyPqXCHQ9hErPBdARXgdiQTPUnxMTe8+IrcbHKy06ONyflZCM4O/xyhgk9B6VXuTxcm
 QkHwoC0YicpBpDd4xdQ==
X-Proofpoint-Virus-Version: vendor=baseguard
 engine=ICAP:2.0.293,Aquarius:18.0.1176,Hydra:6.1.134,FMLib:17.12.100.49
 definitions=2026-08-24_05,2026-08-24_01,2025-10-01_01
X-Proofpoint-Spam-Details: rule=outbound_notspam policy=outbound score=0
 suspectscore=0 malwarescore=0 priorityscore=1501 impostorscore=0
 lowpriorityscore=0 clxscore=1015 phishscore=0 adultscore=0 spamscore=0
 bulkscore=0 classifier=typeunknown authscore=0 authtc= authcc= route=outbound
 adjust=0 reason=mlx scancount=1 engine=8.22.0-2606150000
 definitions=main-2608240135

A legal NFSv3 READ3resok response with attributes_follow =3D FALSE causes t=
he Linux RPC-over-RDMA client to prepend 84 bytes of stale receive-buffer d=
ata to an otherwise correct RDMA-written file payload. The server performs =
an RDMA Write containing the correct 4096-byte payload, but corruption occu=
rs later on the client when xdr_read_pages() realigns an oversized XDR head=
 and copies 84 bytes beyond the valid inline reply into the beginning of th=
e payload pages. The 84-byte corruption corresponds exactly to sizeof(fattr=
3), which is 21 XDR words. For a normal NFSv3 mount, only the first READ ty=
pically fails because the client subsequently learns the correct read_hdrsi=
ze. With a FlexFiles NFSv3 DS, the shorter DS header size is not learned, a=
llowing the issue to occur repeatedly.=0A=
=0A=
Client environment:=0A=
Linux 5.14.0-503.22.1.el9_5.x86_64, NFS mount vers=3D3, proto=3Drdma, port=
=3D20049, performing 4096-byte direct reads.=0A=
=0A=
The reason the corruption is exactly 84 bytes is that the client reserves s=
pace for the maximum possible NFSv3 READ reply header. In fs/nfs/nfs3xdr.c,=
 NFS3_fattr_sz is defined as 21 XDR words, and the maximum READ reply size =
includes status, post-operation attributes, count, eof, opaque length, and =
page padding. Before the first READ, args->replen is zero, so nfs3_xdr_enc_=
read3args() reserves the maximum reply header size. This results in 104 byt=
es of NFS header space. rpc_prepare_reply_pages() then adds the RPC reply a=
nd authentication header space. For the observed AUTH_SYS connection, the t=
otal reserved head size becomes 128 bytes.=0A=
=0A=
Because the server omits fattr3 when attributes_follow is FALSE, the actual=
 inline RPC payload consists only of the RPC reply/authentication header, N=
FS status, attributes_follow boolean, count, eof, and opaque length fields.=
 This totals only 44 bytes. The difference between the reserved 128-byte he=
ad and the actual 44-byte inline payload is 84 bytes, exactly the size of f=
attr3.=0A=
=0A=
The fault occurs as follows. First, the receive buffer is prepared with a 1=
28-byte head followed by the page list and tail buffers. Next, the DS perfo=
rms an RDMA Write directly into the pages, and the resulting 4096-byte file=
 payload is correct at that point. RPC-over-RDMA then receives only 44 byte=
s of inline RPC data. rpcrdma_decode_msg() determines the actual inline len=
gth and calls rpcrdma_inline_fixup().=0A=
=0A=
rpcrdma_inline_fixup() redirects the head iovec to point directly at the re=
ceived RPC reply message to avoid an extra memory copy. Although the amount=
 of valid data is recognized as only 44 bytes, the head iovec length remain=
s 128 bytes. As a result, bytes 44 through 127 do not contain valid RPC dat=
a and instead reference stale data remaining in a recycled RPC-over-RDMA re=
ceive buffer.=0A=
=0A=
NFS then correctly decodes attributes_follow =3D FALSE and does not attempt=
 to decode an fattr3 structure. The decoder advances only over the four-byt=
e boolean field. When decode_read3resok() later calls xdr_read_pages(), the=
 decoder position is 44 bytes while the head iovec length still reports 128=
 bytes, leaving an 84-byte difference.=0A=
=0A=
The generic XDR layer, specifically xdr_realign_pages() and xdr_shrink_bufh=
ead(), treats bytes 44 through 127 as valid inline payload. Because the hea=
d length exceeds the current decode position, xdr_shrink_bufhead() shifts t=
he extra 84 bytes into the page list. This overwrites the beginning of the =
already correct RDMA payload and produces the observed corruption.=0A=
=0A=
Please let me know your thoughts on this.=0A=
=0A=
Regards,=0A=
Rakesh=

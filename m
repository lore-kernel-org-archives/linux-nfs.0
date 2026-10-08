Received: from mx0b-003fbd02.pphosted.com (mx0b-003fbd02.pphosted.com [67.231.157.221])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 64E4E2EEE8C
	for <linux-nfs@vger.kernel.org>; Thu,  8 Oct 2026 16:43:47 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=fail smtp.client-ip=67.231.157.221
ARC-Seal:i=3; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1791477829; cv=fail; b=FY+wBoOqGaU3qd3DEX+nDVb9eo9gZNbwAiHzLS0peHLZbsivwFUFI1MZygICHfMUMPQBJANdFgTehVlJp/7YpqO7uanUH88l4ME5SQawBiTAAFka6sYjkexnE21QE4y3cPFyvjpTsaHyEzfioh2RRjEILcx+kKU3xa2QhOLS5kc=
ARC-Message-Signature:i=3; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1791477829; c=relaxed/simple;
	bh=7O0gnmMbqo0xpTAy0+TkJTA8NeAyC/Fw9iQv3W9VNhc=;
	h=From:To:CC:Subject:Date:Message-ID:References:In-Reply-To:
	 Content-Type:MIME-Version; b=EqBojtrAs0dc9E3A/j4t5iAzcdgy/wRrFi2ZkSUheQNJF9fycSkXvhoF6QRUJJqdu/dkVoJq6ukfMn/jxrs7zYx2dWsevVmuoJM/KCYwWJtg12bY41wS8Y+h5oOI0HqTrxEIQRrD/PM3PdLKQdCJCJ3aJA8WyDWaNemP6IoUI+8=
ARC-Authentication-Results:i=3; smtp.subspace.kernel.org; dmarc=pass (p=reject dis=none) header.from=netapp.com; spf=pass smtp.mailfrom=netapp.com; dkim=pass (2048-bit key) header.d=netapp.com header.i=@netapp.com header.b=ZvIGwSOb; dkim=pass (2048-bit key) header.d=netapp.com header.i=@netapp.com header.b=grDZ2TtC; dkim=pass (2048-bit key) header.d=netapp.com header.i=@netapp.com header.b=grDZ2TtC; arc=fail smtp.client-ip=67.231.157.221
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=reject dis=none) header.from=netapp.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=netapp.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=netapp.com header.i=@netapp.com header.b="ZvIGwSOb";
	dkim=pass (2048-bit key) header.d=netapp.com header.i=@netapp.com header.b="grDZ2TtC";
	dkim=pass (2048-bit key) header.d=netapp.com header.i=@netapp.com header.b="grDZ2TtC"
Received: from pps.filterd (m0412383.ppops.net [127.0.0.1])
	by mx0b-003fbd02.pphosted.com (8.18.1.11/8.18.1.11) with ESMTP id 698EWABS106288;
	Thu, 8 Oct 2026 16:43:40 GMT
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=netapp.com; h=cc
	:content-transfer-encoding:content-type:date:from:in-reply-to
	:message-id:mime-version:references:subject:to; s=pps1; bh=aOXHs
	KzfhM32+BNsgeVN5DZHTlAXcu/JV1fr9Z0EJQg=; b=ZvIGwSObXBVgsEAOgc0+5
	fDQIntkalAHgGLYIgEL+NzLOyFW1tBAqXb+aAcM9jsO2NRFOqYLpZ/9SvZowaH7J
	ggN9iCmh4zNQ0ou3mt5ZtMZloWIYZBBSSjx2XXEO8tWvgGJWszYvau56HfScXxyt
	saCMe7h52g38ibt+mHo4zonkx+M8IxPDCWfXdZAqK4FK9rueUcrlVCZx45ADkexk
	7plcBVIzkawQDgDIh90qODk9tVTorf73ImiGMBQROGx4quXS6dKoIAK52tlM+8Vg
	/zl966bIzPQ3Qfyw2PbTCNrXWcyVR9D+wUa6z6N+A5RpsnuOCTC15moajPoyvzDX
	A==
Received: from bl0pr03cu003.outbound.protection.outlook.com (mail-eastusazon11012068.outbound.protection.outlook.com [52.101.53.68])
	by mx0b-003fbd02.pphosted.com (PPS) with ESMTPS id 4h6ca40wj2-1
	(version=TLSv1.3 cipher=TLS_AES_256_GCM_SHA384 bits=256 verify=NOT);
	Thu, 08 Oct 2026 16:43:40 +0000 (GMT)
ARC-Seal: i=2; a=rsa-sha256; s=arcselector10001; d=microsoft.com; cv=pass;
 b=zS2MXcQMUcfqFPgFW/Q98vMsMIyWX0pNTLEiYXnCKH8ZVaL1z1Wm2nxkqroUJDeYSIy1I+pfGgMAlOBRWNxxe3fpOCl8+QB/s5WsJlLXtt7Z2i52HL75r1dDpvfasvl2SkG/wdkqUSfqCGbtaGw47kT+yHE4VmFDY25Sad7xE0RRLTzdmWvzAaK81swPPXxvoBvnH5QeKc9vjYvVAqykcdTJE8QHeJeZtIESomcpwIrzVHcbUfi+vMOTWmOV0X4P+Oz9XmLp97KQfwRJpLum41lp0WH0/HW0S9jv22Un+WAlPlFN/LuR3idpFJw9tQ518JleiESlrW/07M664Nif+w==
ARC-Message-Signature: i=2; a=rsa-sha256; c=relaxed/relaxed; d=microsoft.com;
 s=arcselector10001;
 h=From:Date:Subject:Message-ID:Content-Type:MIME-Version:X-MS-Exchange-AntiSpam-MessageData-ChunkCount:X-MS-Exchange-AntiSpam-MessageData-0:X-MS-Exchange-AntiSpam-MessageData-1;
 bh=aOXHsKzfhM32+BNsgeVN5DZHTlAXcu/JV1fr9Z0EJQg=;
 b=gI1DUhC1oMiFdL8l4kud/w4bmKRkt8eFtqwLFWYnyWt7GTpF+cZAaLvgX9U4dUi1OjmG/zgz36oW4OJozAi2gtyFesZ8ablmFYBqIPZlFmNShTjM9tQU2q5TsanKAoIHiPwHQskAXpd+NS7s6f/pQ//Htvam/Ezjfh+Y9TSdXkf3QTFeR3NotRCr9Lf3yjoHcYI1S6d+kkX4XmbWOv8Jn370aLzu/kIdMBi2TkfbN753y+4aP9eH+Z0sw/iV9SRnJC6E9YIkDKlpadUeWdY+7SAzEkfKx5cuBSzvGi5j3J7HbT8/clBZtnc6HWkMTniMS9h65zBKGjScEeCGcPlPxA==
ARC-Authentication-Results: i=2; mx.microsoft.com 1; spf=fail (sender ip is
 147.161.205.62) smtp.rcpttodomain=gsacapital.com smtp.mailfrom=netapp.com;
 dmarc=pass (p=reject sp=reject pct=100) action=none header.from=netapp.com;
 dkim=pass (signature was verified) header.d=netapp.com; arc=pass (0 oda=1
 ltdi=1 spf=[1,1,smtp.mailfrom=netapp.com] dkim=[1,1,header.d=netapp.com]
 dmarc=[1,1,header.from=netapp.com])
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=netapp.com;
 s=selector1;
 h=From:Date:Subject:Message-ID:Content-Type:MIME-Version:X-MS-Exchange-SenderADCheck;
 bh=aOXHsKzfhM32+BNsgeVN5DZHTlAXcu/JV1fr9Z0EJQg=;
 b=grDZ2TtChqrq0DU9LNVvN1VCqWEMroUdYJnY2S6nTw63Y+0mLKAA/N4Q3U6zpHflyct8W3lMVrimcCwn5hNHZEPq2nveAholApiiAmGELmCTGu0Ln32CepsaY6WhkgIrdkASJuAQZDDR6yWslei8SEZMRjcSMfBup1h9M+gRzZXKPOuaDJDDLEesHST68uD38N9sUY4/KNTAxbeJ897UdmW7L3ndCYNEvTXIpZYYWnnn2JLVIRIF6rXAIcVTKwY019N1jQaw5pyobrgm015gTMOlKq/zh6pfUrZz/uIzkRaq1e5t+8vqi7EP6ye0vAjqD53psTwWi/nkBpNtcYvXeQ==
Received: from DS1PR03CA0021.namprd03.prod.outlook.com (2603:10b6:8:233::8) by
 CH7PR06MB10620.namprd06.prod.outlook.com (2603:10b6:610:250::19) with
 Microsoft SMTP Server (version=TLS1_2,
 cipher=TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384) id 15.21.496.17; Thu, 8 Oct
 2026 16:43:34 +0000
Received: from SN1PEPF000397B0.namprd05.prod.outlook.com
 (2603:10b6:8:233:cafe::95) by DS1PR03CA0021.outlook.office365.com
 (2603:10b6:8:233::8) with Microsoft SMTP Server (version=TLS1_3,
 cipher=TLS_AES_256_GCM_SHA384) id 15.21.496.5 via Frontend Transport; Thu, 8
 Oct 2026 16:43:34 +0000
X-MS-Exchange-Authentication-Results: spf=fail (sender IP is 147.161.205.62)
 smtp.mailfrom=netapp.com; dkim=pass (signature was verified)
 header.d=netapp.com;dmarc=pass action=none header.from=netapp.com;
Received-SPF: Fail (protection.outlook.com: domain of netapp.com does not
 designate 147.161.205.62 as permitted sender)
 receiver=protection.outlook.com; client-ip=147.161.205.62;
 helo=sin41a5.mail.zscalertwo.net;
Received: from sin41a5.mail.zscalertwo.net (147.161.205.62) by
 SN1PEPF000397B0.mail.protection.outlook.com (10.167.248.54) with Microsoft
 SMTP Server (version=TLS1_3, cipher=TLS_AES_256_GCM_SHA384) id 15.21.522.6
 via Frontend Transport; Thu, 8 Oct 2026 16:43:32 +0000
Received: from dm2pr04cu003.outbound.protection.outlook.com ([40.93.13.56])
	by sin41a5.mail.zscalertwo.net ([147.161.205.46])
	with ESMTPS id 6AC7C83108470002;
	Fri, 09 Oct 2026 00:43:29 +0800
ARC-Seal: i=1; a=rsa-sha256; s=arcselector10001; d=microsoft.com; cv=none;
 b=chpWBzUqgrSwCh2hktBk+JFCVy1aaARazFu6bbBTNDKBICZcR6Wtv0+hmKYtR0RP622AwfwALm3efzIVm2dB+TPQGH9ayHrS8SosCQOuqkCcD4bkAhAXS1I09nh9fN3A6sKSfMyndtK5B+7aRQGI2P1fZt+46s+mr9DpeRHUp/WPZ+wA/uj8XH2sesm78Im3hgKcGmO2X5c1dCTcuZKSimNdKCvHTPi9tjmzPAZPbu+olqke5TIsyDdgISZ5KkpzTSRN0L3uZnEWUJtBjgwvlMpRJEXoHYXTTrrvZ1DWfsJIw0wAmDOI8tZC1pa4BnZoyBtf3ulw6O9F6N3jy9DK7w==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=microsoft.com;
 s=arcselector10001;
 h=From:Date:Subject:Message-ID:Content-Type:MIME-Version:X-MS-Exchange-AntiSpam-MessageData-ChunkCount:X-MS-Exchange-AntiSpam-MessageData-0:X-MS-Exchange-AntiSpam-MessageData-1;
 bh=aOXHsKzfhM32+BNsgeVN5DZHTlAXcu/JV1fr9Z0EJQg=;
 b=QjSl0Fywg7p2sXmHrstqYbE4kiedbnyevBB3zoalISUTf15T43QZi8RP9U1rpMdD76gsBiwgBx19ViEP18oaOoYppa56P10j7w8MQm7zZdcnMq6IldZ2My1ai/zjUCttD4H5tlCQYh2SWlx2z8v5o5NlQaXu26y7uYa0PT/ahC/6zx74ZRD3MdskHuXBZcHTh0kp2clIte5kR88YmSndUxfydymcuZ7eg7LSOBANlKQaOuAUoFbS7HJGZePjCHx5K3agOx8GRxgTqccDJXa2EcwzJtKG2qGBZnwTZ9f7aoIdhZFRo/aPuhFcRkmFULangzsarFJsR+IKByMxGh+QuQ==
ARC-Authentication-Results: i=1; mx.microsoft.com 1; spf=pass
 smtp.mailfrom=netapp.com; dmarc=pass action=none header.from=netapp.com;
 dkim=pass header.d=netapp.com; arc=none
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=netapp.com;
 s=selector1;
 h=From:Date:Subject:Message-ID:Content-Type:MIME-Version:X-MS-Exchange-SenderADCheck;
 bh=aOXHsKzfhM32+BNsgeVN5DZHTlAXcu/JV1fr9Z0EJQg=;
 b=grDZ2TtChqrq0DU9LNVvN1VCqWEMroUdYJnY2S6nTw63Y+0mLKAA/N4Q3U6zpHflyct8W3lMVrimcCwn5hNHZEPq2nveAholApiiAmGELmCTGu0Ln32CepsaY6WhkgIrdkASJuAQZDDR6yWslei8SEZMRjcSMfBup1h9M+gRzZXKPOuaDJDDLEesHST68uD38N9sUY4/KNTAxbeJ897UdmW7L3ndCYNEvTXIpZYYWnnn2JLVIRIF6rXAIcVTKwY019N1jQaw5pyobrgm015gTMOlKq/zh6pfUrZz/uIzkRaq1e5t+8vqi7EP6ye0vAjqD53psTwWi/nkBpNtcYvXeQ==
Received: from SA1PR06MB11353.namprd06.prod.outlook.com
 (2603:10b6:806:4a2::17) by EAYPR06MB313782.namprd06.prod.outlook.com
 (2603:10b6:303:2fa::15) with Microsoft SMTP Server (version=TLS1_2,
 cipher=TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384) id 15.21.496.17; Thu, 8 Oct
 2026 16:43:23 +0000
Received: from SA1PR06MB11353.namprd06.prod.outlook.com
 ([fe80::ff:880:c010:68bf]) by SA1PR06MB11353.namprd06.prod.outlook.com
 ([fe80::ff:880:c010:68bf%6]) with mapi id 15.21.0496.015; Thu, 8 Oct 2026
 16:43:22 +0000
From: "Mora, Jorge" <Jorge.Mora@netapp.com>
To: Anna Schumaker <anna@kernel.org>,
        "linux-nfs@vger.kernel.org"
	<linux-nfs@vger.kernel.org>,
        Trond Myklebust <trondmy@kernel.org>,
        Olga
 Kornievskaia <okorniev@redhat.com>,
        Scott Mayhew <smayhew@redhat.com>,
        Benjamin Coddington <ben.coddington@hammerspace.com>
CC: "rushil.patel@gsacapital.com" <rushil.patel@gsacapital.com>,
        "tim.saunders@gsacapital.com" <tim.saunders@gsacapital.com>,
        "mark.brading@gsacapital.com" <mark.brading@gsacapital.com>,
        "ben.roberts@gsacapital.com" <ben.roberts@gsacapital.com>,
        "Springall, Matt"
	<Matt.Springall@netapp.com>
Subject: Re: Close-to-open consistency on SIGKILL
Thread-Topic: Close-to-open consistency on SIGKILL
Thread-Index: AQHdVSBlpS+KtLjd9ki6JO7yF3rKErbxAeUAgALDDm6AABhNYg==
Date: Thu, 8 Oct 2026 16:43:22 +0000
Message-ID:
 <SA1PR06MB11353247F7788B2ED20D6A7B5E1932@SA1PR06MB11353.namprd06.prod.outlook.com>
References:
 <SA1PR06MB113533BFC97DA85AE6D37D99DE1962@SA1PR06MB11353.namprd06.prod.outlook.com>
 <d39afd89-0543-410c-8c3a-c8869ba643bb@app.fastmail.com>
 <SA1PR06MB11353080992DEADE0E7E9FA67E1932@SA1PR06MB11353.namprd06.prod.outlook.com>
In-Reply-To:
 <SA1PR06MB11353080992DEADE0E7E9FA67E1932@SA1PR06MB11353.namprd06.prod.outlook.com>
Accept-Language: en-US
Content-Language: en-US
X-MS-Has-Attach:
X-MS-TNEF-Correlator:
msip_labels:
Authentication-Results-Original: mx.microsoft.com 1; dkim=none (message not
 signed) header.d=none;dmarc=none action=none header.from=netapp.com;
x-ms-traffictypediagnostic:
	SA1PR06MB11353:EE_|EAYPR06MB313782:EE_|SN1PEPF000397B0:EE_|CH7PR06MB10620:EE_
X-MS-Office365-Filtering-Correlation-Id: a83c9bc2-2757-441f-e576-08df255b4aff
X-MS-Exchange-SenderADCheck: 1
X-MS-Exchange-AntiSpam-Relay: 0
X-Microsoft-Antispam-Untrusted:
 BCL:0;ARA:13230040|7416014|23010399003|376014|366016|1800799024|56012099006|38070700021|4143699003|11063799006|10067099003|22082099003|18002099003|3023799007;
X-Microsoft-Antispam-Message-Info-Original:
 W6vP8edw7S4QJui0mhtcjOOnq50JUte5aApK78yLduppigfDarRgelCo4nQ52Wh2LtIAedJNlsmZr4EugH1g5F/yYZL2Ba6e/jVhAcij+rt5ZffGnQby5NPnzE+e760CPqYKZVjoMUOgPIfUBKCilLWrkiJrRTKrId9J4S+q5uaIz9NlWLe0L74W/IoE34ZT7OG0tE12+5+m1lbbPE6yLQ0mPwfAUGG0iZDtNR7aHjphRdJpdyZCi9rBUNu90vISQclOyXmC/Ky0B+1my4mhk2Wc1+/960jzVl3XOwOlzK0ix945cjOKokiWxF6Bkzwc2lU8yYjfnONQJvT9/6S2E6jTxJLv1uVHyNEMM34p0pcPkCU2qBZQK0oBJQ5WT7dnUtfJrRN9W8KrNMMr3B1KQbpdk2zUJtFeQxVvfB4Rl7+H8PplZq5Stu4qBlCaqEB6yheS0QBuXAXnbbepfDv/AnOsR7xiV2eYFXoJn+v/DxLggkq6IjoJFWtpRywqWH0/E2K5D3w+9iyjlD4V334Gq2h2IsB4UbpC2UfP9fUlRkx6POYOkDq30uXFr+Y+fN+ydBEwhLwzo7874tAEMsFoOrEh98xrVaLxNyakDMqICX6l+E/RBM3PONwrt23CmSnAQ6mgOucXBb1V1kwMDo6iv1aVLYehHVx+lwU6rHKSBGc=
X-Forefront-Antispam-Report-Untrusted:
 CIP:255.255.255.255;CTRY:;LANG:en;SCL:1;SRV:;IPV:NLI;SFV:NSPM;H:SA1PR06MB11353.namprd06.prod.outlook.com;PTR:;CAT:NONE;SFS:(13230040)(7416014)(23010399003)(376014)(366016)(1800799024)(56012099006)(38070700021)(4143699003)(11063799006)(10067099003)(22082099003)(18002099003)(3023799007);DIR:OUT;SFP:1101;
Content-Type: text/plain; charset="Windows-1252"
Content-Transfer-Encoding: quoted-printable
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
X-Exchange-RoutingPolicyChecked:
 B/6vyCAPEPIMsTNdDTd3dVrWikBDBJxjt3ApXEki9D4mGyreC4WrYACjx/VGDSxKuSM42V0yVjKc6lU08dkx3AWD5jAME4ENC0a9PzFsFZPx2bMuDLAxy0OW5uVAIDrwTm1qbloDrL+XkQz7SfxEuByOBm9KD1U//gVL0eJjz4VBeoJ3+Cbonbmq5jOivM6WnIDVl0Gbm5Tc9yx/6E6fvq5GEu0ZVkJVBxCYRhoJaa/y55pKvF4/KpXyMiTOtUbhrcjByP7rJ2te8en7c3NkRfYj64TrgZ0WcOeS7Qw6ouzGFT2mspRc7Vqs7650AcArc+5sJRxPjJxzQDiZeESLhw==
X-MS-Exchange-Transport-CrossTenantHeadersStamped: EAYPR06MB313782
X-Zscaler-Block: 0
X-EOPAttributedMessage: 0
X-MS-Exchange-Transport-CrossTenantHeadersStripped:
 SN1PEPF000397B0.namprd05.prod.outlook.com
X-MS-PublicTrafficType: Email
X-MS-Office365-Filtering-Correlation-Id-Prvs:
	edeca414-4fe4-456c-2641-08df255b4424
X-Microsoft-Antispam:
	BCL:0;ARA:13230040|14060799003|1800799024|82310400026|36860700016|35042699022|376014|23010399003|22082099003|18002099003|10067099003|3023799007|4143699003|11063799006|56012099006;
X-Microsoft-Antispam-Message-Info:
	BX2CNdpIEQqtHPvYkVyFAhd881p7kh2xy7xjKeN/3JYGoIPRKVa7kNVe9p4o6zAcK/j0nki8DlQoGtNSV3KPG8mfwjNOqkKB1/odaD2S0DFAzSxxsBMGuBAYgpkdPC/rRGD/WPhlQDI2dPA9Yd7MbVxmThYiiT4kgWL5LY+iO88xUjaLme7K5niFgp+J68pyRGLQxucNuAma835AFitJa53lwytLalmHhLh5OGjgjSG1QnFPQpFA593r1+2LqukIDB+Jebsdtx9BB77YmqkmSRJjY+bAf6FJ6HTTAJNIiGV2Bg9G6uxE93I6jK1BrLFIkwp/kugK3hrJVwjRfRO/TIGDX/XSpLeMY/CUmzNtBgWNWahYPjT/B2oRD+FTZJim1fsdEyhVVqrPbcTuY+L8LRcttIo/Vdwz9mlBxwW6DcnB+dAxOS6G7RaDAvbgeWcdK6dOmEitpjjrrO6K1IzNr2I1BlBnVoegufGJa3T7MQLvT/oGccl2KsSaToNCnrCkqYZGrO1eUW4szi/X0zhH2WlV7GBNXc4yb7ArNgiFSGPnOFrDrq2uNNL/v8Xsx6bljWw8wYmV/YNnUQj/lXBvvXXo7T7hKtNqgOX8AS9tFeO/D4YVCfXDkxKb/B86BrfPA5I3L/21FhA3oa1FZxw09A==
X-Forefront-Antispam-Report:
	CIP:147.161.205.62;CTRY:SG;LANG:en;SCL:1;SRV:;IPV:NLI;SFV:NSPM;H:sin41a5.mail.zscalertwo.net;PTR:sin41a5.mail.zscalertwo.net;CAT:NONE;SFS:(13230040)(14060799003)(1800799024)(82310400026)(36860700016)(35042699022)(376014)(23010399003)(22082099003)(18002099003)(10067099003)(3023799007)(4143699003)(11063799006)(56012099006);DIR:OUT;SFP:1101;
X-MS-Exchange-AntiSpam-MessageData-ChunkCount: 1
X-MS-Exchange-AntiSpam-MessageData-0:
	VUABkPGtIkh5qQIgrDWwwEbE1efWwJ31ElwR1JFmFVW+IC5iVyj85kG1IfJuN9O9EwHgabrOvM2oYTadjgOy9L1fqLmi/QVGz7CBEDigQc+rhxpAIhYuXLUJ5lPG7NeUwmlkiV86ywecuhm+CAjkLIy9td8UZD5DrHuehNZ5/6cLCcc3wJjx5WW9e7L8ZWK28Vq1a57Khxzycpdiq+4OSjlnzZQe5lH0aCKzLeZi7QB/m4FlliLGS9Fd1UuW/04f1bLfXiArnLSJMz7Y8HX1VliXmrTAnsU5AApiXkE47jFYC31zlklA2u8LZGJVzbCgbWQPaEbVV8GbkpuLUg0NoGIUi4neuCaJFiwmJUlMDtuchfs5Ta/3yCULhHlgKLgNkPm7dkzWiSKTztsbnqrrqr80/yvaRsEo/qQGNfqXnvWucvQgNPiiBR41HmEaKFGI
X-Exchange-RoutingPolicyChecked:
	YD5pQGionyCRXz8ngAYck+WiZX8EzhzTSQNvz3ei5K8kmkLseyJXQKO2sMJzYSOMvU8En+OcpW4njeAMrxt75Aechqk/a8qyNLqvPKrTdmGiT2TiJ7UHOiA3s2NI7BMaznR3Q7Vobwk1T9K+tKzGuXp/QWDkyj45k5ZLo6O9anNK2FYWqUehj6BwtfLffCBbqVJN++HgSpZaAv27hAUhIBZC9BnnnijO9H5E4QTC9XyLAD7EhFILqBNF0HvGxtMRE43uE40O9bXwD3wDNBQOkDbqirbKux5h7yUtk5BrfrRtAEC5JDBUkwm/zpXUeLeslEWatJsfC6g5CyhsCu0yxA==
X-MS-Exchange-AntiSpam-ExternalHop-MessageData-ChunkCount: 1
X-MS-Exchange-AntiSpam-ExternalHop-MessageData-0:
	au2nkMW0Bmy+CSnsPrzLiv0SdYCMbWYhyPqSegF093bn+0BN8Izukqz8YutP4S0vlef1Psdz3Y2QfLGbo7CTsIrfw8oLDbisCrDcRs4aRLWztBGoviGcJvnJkAJG1q2vYSVeHnUIzxCJmMACWGb19mTMa6bq1gN1WpDN25oknppoSsfSwuQKJKvQ9EX3QD4AkVptG/KXqclBYS1Y7wauzvcSIsxshuvQXhLn2LNZXyAmMJJ/bqzV+zN1FqgkW84Bkh9i183zd0CEmwo4HjEugRYqSm0/qUYL7CDr93d1pV6dgAD9xsnyz8Lf9wwFhd+xu1celQ+rT7gSgNBV/CpsmNAvXF93waR8ISCDPxsMyeex5K7Ery22V6NZrpnVl4ZKZsTKRn1Z/g7V79EZOh8AJjcJbgXKD5v1AkZw8YF7KZaHKuHrfbKvrbItG5E6x2aOl6Er9Mn69VZvkOpgu3LnWRBLFtawp9IJ4TBSco1BF6cVNTt2Cm0Qrw17KqiCpb4GGI44FksqC3k4svDwE0VdZA7Z8/5oCQGyBO1eyzGNafOn4O2YdY/Xk0F7jZ5bMa53e5PuDn34vmb5gk3JF4+1aNEqHuETHp6ngdzIw7uJT7qm+AJiyt9xZ46zLmpT9RSG
X-OriginatorOrg: netapp.com
X-MS-Exchange-CrossTenant-OriginalArrivalTime: 08 Oct 2026 16:43:32.1556
 (UTC)
X-MS-Exchange-CrossTenant-Network-Message-Id: a83c9bc2-2757-441f-e576-08df255b4aff
X-MS-Exchange-CrossTenant-Id: 4b0911a0-929b-4715-944b-c03745165b3a
X-MS-Exchange-CrossTenant-OriginalAttributedTenantConnectingIp: TenantId=4b0911a0-929b-4715-944b-c03745165b3a;Ip=[147.161.205.62];Helo=[sin41a5.mail.zscalertwo.net]
X-MS-Exchange-CrossTenant-AuthSource:
	SN1PEPF000397B0.namprd05.prod.outlook.com
X-MS-Exchange-CrossTenant-AuthAs: Anonymous
X-MS-Exchange-CrossTenant-FromEntityHeader: HybridOnPrem
X-MS-Exchange-Transport-CrossTenantHeadersStamped: CH7PR06MB10620
X-Proofpoint-GUID: kEfm_9ne0QtxdVG1mxydUgnNriV7sQPN
X-Proofpoint-Spam-Info: AW1haW4tMjYxMDA4MDA2NiBTYWx0ZWRfXzH7glrb+OUwS
 tzPlie4FF5W6NjbSlzhj9tVikXqVbEVuIncI52B005iKPmFf7p2KZvFK+L3J3sFNHHPPtt3Mqzj
 njl2CcNiXGRu0TQoyypjv50GZyJdhYA=
X-Authority-Analysis: v=2.4 cv=BYRNQbt2 c=1 sm=1 tr=0 ts=6ac7c83c cx=c_pps
 a=EOla4jo+ZS3aUDydQNalYw==:117 a=yMizlIzLMa+8uQlivG87+A==:17
 a=6eWqkTHjU83fiwn7nKZWdM+Sl24=:19 a=lCpzRmAYbLLaTzLvsPZ7Mbvzbb8=:19
 a=xqWC_Br6kY4A:10 a=N659UExz7-8A:10 a=660iZSQnnn4A:10 a=GWG4Yq0kndkA:10
 a=VkNPw1HP01LnGYTKEx00:22 a=1lWG0UuNQvn8UhQ8Wh4S:22 a=X7e-fZ-CKB32rjcIpVUG:22
 a=VwQbUJbxAAAA:8 a=aU7qV5IrAAAA:8 a=JfrnYn6hAAAA:8 a=JDjsHSkAAAAA:8
 a=9aqLuabeEad2m3gMCTUA:9 a=pILNOxqGKmIA:10 a=XeeNnEZWyIaKVUq9vuPT:22
 a=1CNFftbPRP8L7MoqJWF3:22 a=dseMxAR1CDlncBZeV_se:22
X-Proofpoint-ORIG-GUID: kEfm_9ne0QtxdVG1mxydUgnNriV7sQPN
X-Proofpoint-Spam-Details-Enc: AW1haW4tMjYxMDA4MDA2NiBTYWx0ZWRfX1BW9uFQCDQde
 ousa+4lkcGHqxkyPZcKaqbiuY8iReU8ZuB9BfE7RYo84gqL7zC+DAvI1N5D4xFnfclNyrD2HYbU
 HMyCzpVjX98aHYI0h+e5+c/mu6aCk6QzsAsoz2EzNG1bn1rSEMDlUPmqK+hx3QhKarPw+I/5iAh
 b8WOOfDDQU6IkgTBVGMFkC7zf4/5JXBcZrN5l5lqbdf4d3bi8jhGl989vfMox/hF710GexX1X3n
 HjwQrXKpePZUHejWXnEFnd6p5GnwN/cjyLvXk0N+pdKFe5GguOqAYKe1yAfpDhsrqxxXYwdwZs1
 ELl48x+N5Cm7b5yXpQ22UV/MgxgkOVv7NrNa1ZOxuNtwbevBY7d0xd4ApnP2tAR1GKvlcDUeE6x
 v8f/FAW5/c5309EJuJCdutkd3ywng/knbuiQb1iVKNjc+VvEHRoVr8Kw2bQrEWsIFkFR678E2e/
 tdzP8aVP+X0MeriDLwQ==
X-Proofpoint-Virus-Version: vendor=baseguard
 engine=ICAP:2.0.293,Aquarius:18.0.1176,Hydra:6.1.134,FMLib:17.12.100.49
 definitions=2026-10-08_05,2026-10-08_01,2025-10-01_01
X-Proofpoint-Spam-Details: rule=outbound_notspam policy=outbound score=0
 spamscore=0 lowpriorityscore=0 bulkscore=0 clxscore=1015 impostorscore=0
 malwarescore=0 priorityscore=1501 adultscore=0 phishscore=0 suspectscore=0
 classifier=typeunknown authscore=0 authtc= authcc= route=outbound adjust=0
 reason=mlx scancount=1 engine=8.22.0-2610020000 definitions=main-2610080066

Adding Matt Springall to the conversation.=0A=
=0A=
--Jorge=0A=
________________________________________=0A=
From: Mora, Jorge <Jorge.Mora@netapp.com>=0A=
Sent: Thursday, October 8, 2026 9:14 AM=0A=
To: Anna Schumaker; linux-nfs@vger.kernel.org; Trond Myklebust; Olga Kornie=
vskaia; Scott Mayhew; Benjamin Coddington=0A=
Cc: rushil.patel@gsacapital.com; tim.saunders@gsacapital.com; mark.brading@=
gsacapital.com; ben.roberts@gsacapital.com=0A=
Subject: Re: Close-to-open consistency on SIGKILL=0A=
=0A=
EXTERNAL EMAIL - USE CAUTION when clicking links or attachments=0A=
=0A=
=0A=
=0A=
=0A=
Thank you Anna.=0A=
=0A=
=0A=
________________________________________=0A=
From: Anna Schumaker <anna@kernel.org>=0A=
Sent: Tuesday, October 6, 2026 3:03 PM=0A=
To: Mora, Jorge; linux-nfs@vger.kernel.org; Trond Myklebust; Olga Kornievsk=
aia; Scott Mayhew; Benjamin Coddington=0A=
Cc: rushil.patel@gsacapital.com; tim.saunders@gsacapital.com; mark.brading@=
gsacapital.com; ben.roberts@gsacapital.com=0A=
Subject: Re: Close-to-open consistency on SIGKILL=0A=
=0A=
EXTERNAL EMAIL - USE CAUTION when clicking links or attachments=0A=
=0A=
=0A=
=0A=
=0A=
Hi Jorge,=0A=
=0A=
On Mon, Oct 5, 2026, at 7:38 PM, Mora, Jorge wrote:=0A=
> Hello,=0A=
>=0A=
> I'd like to get the NFS client's view on a patch that showed up on=0A=
> linux-mm, and in particular on how the proposed behaviour interacts=0A=
> with NFS close-to-open (CTO) consistency.=0A=
>=0A=
> Background=0A=
> ----------=0A=
> Rushil Patel reported that on NFSv4.1 (Slurm jobs, NetApp filer),=0A=
> cancelling a job can leave processes stuck in D-state in=0A=
> folio_wait_bit_common() while __filemap_fdatawait_range() waits=0A=
> uninterruptibly for writeback. If the server is slow or unreachable,=0A=
> the only practical recovery is rebooting the client.=0A=
>=0A=
> The linux-mm patch:=0A=
>=0A=
> https://urldefense.com/v3/__https://lore.kernel.org/linux-mm/202603251136=
16.785496-1-rushil.patel@gsacapital.com/__;!!Nhn8V6BzJA!Xl2GlCQUQklUBCYzpDn=
CMPGWagSPwub-YMfWvj2K03aSZH8M4oenhGrd74g-nS74uKf5Mz9g1eiDQg$=0A=
>=0A=
> The patch makes the wait killable, and also skips the wait entirely when=
=0A=
> PF_EXITING is set. The PF_EXITING part is needed because after SIGKILL=0A=
> wakes the first wait, do_exit() -> exit_files() -> nfs4_file_flush()=0A=
> -> nfs_wb_all() re-enters filemap_write_and_wait(), and at that point=0A=
> wants_signal() will not deliver SIGKILL to a PF_EXITING task, so a=0A=
> second killable wait can hang forever.=0A=
>=0A=
> Matthew Wilcox's reply (CC'd linux-nfs):=0A=
>   https://urldefense.com/v3/__https://lore.kernel.org/linux-mm/acQ0YRLM_S=
xYfjfI@casper.infradead.org/__;!!Nhn8V6BzJA!Xl2GlCQUQklUBCYzpDnCMPGWagSPwub=
-YMfWvj2K03aSZH8M4oenhGrd74g-nS74uKf5Mz_S6HeTrg$=0A=
>=0A=
> suggests that the PF_EXITING special case may belong in NFS rather=0A=
> than in __filemap_fdatawait_range(), e.g. in nfs_wb_all():=0A=
>=0A=
>     if (current->flags & PF_EXITING)=0A=
>         ret =3D filemap_fdatawrite(inode->i_mapping);=0A=
>     else=0A=
>         ret =3D filemap_write_and_wait(inode->i_mapping);=0A=
>=0A=
> He also flagged the subsequent:=0A=
>     ret =3D nfs_commit_inode(inode, FLUSH_SYNC);=0A=
>=0A=
> as another possible synchronous wait that could trap an exiting task=0A=
> even if the filemap wait is skipped.=0A=
>=0A=
> Matthew's take on CTO was that other filesystems do not flush-on-close=0A=
> the way NFS does, and that it is probably acceptable to weaken the=0A=
> guarantee for an involuntary termination (SIGKILL / exit) rather than=0A=
> an orderly close. I'd like confirmation (or pushback) from the NFS=0A=
> side before we settle on an approach.=0A=
>=0A=
> Questions for the NFS client community=0A=
> --------------------------------------=0A=
> 1. CTO on involuntary close=0A=
>    NFS flush-on-close exists largely to uphold close-to-open: after=0A=
>    close, a subsequent open on another client should see the writer's=0A=
>    data.=0A=
>    If we skip waiting for writeback (and possibly COMMIT) because the=0A=
>    process is exiting after SIGKILL:=0A=
>    - Is it acceptable that CTO may not hold for that file until=0A=
>      writeback/COMMIT later complete (or fail) asynchronously?=0A=
=0A=
I think that if the user is explicitly killing the application, then they=
=0A=
are already aware of the risk of losing any unwritten data. This does=0A=
sound like you want 'softerr' semantics for killed tasks, however.=0A=
=0A=
>    - Are there known applications or protocols that assume even a=0A=
>      killed writer has pushed data to stable storage by the time the=0A=
>      file descriptor is gone?=0A=
=0A=
Not that I'm aware of off the top of my head (but of course, that doesn't=
=0A=
mean they don't exist!).=0A=
=0A=
>    - Should we still initiate writeback (filemap_fdatawrite) and an=0A=
>      async COMMIT, and only avoid the wait =97 or is skipping more of=0A=
>      the flush path preferred when PF_EXITING?=0A=
=0A=
I would prefer still making a best-effort attempt to writing back stale=0A=
data since a slow server will eventually process it.=0A=
=0A=
>=0A=
> 2. Where should the special case live?=0A=
>    - Generic: PF_EXITING / killable wait in __filemap_fdatawait_range()=
=0A=
>      (as in the linux-mm patch), affecting all callers.=0A=
>    - NFS-specific: change nfs_wb_all() / nfs4_file_flush() (and any=0A=
>      other flush-on-close paths) as Matthew sketched, leaving the mm=0A=
>      helper alone except perhaps for making the wait killable.=0A=
>    Preference? Any other NFS entry points that need the same treatment?=
=0A=
=0A=
We should probably handle this in the NFS client since it sounds like other=
=0A=
filesystems don't have the same issue.=0A=
=0A=
I hope this helps!=0A=
Anna=0A=
=0A=
>=0A=
> 3. nfs_commit_inode(..., FLUSH_SYNC) during exit=0A=
>    If we only replace filemap_write_and_wait() with filemap_fdatawrite()=
=0A=
>    on PF_EXITING, does FLUSH_SYNC COMMIT still block uninterruptibly=0A=
>    on a wedged server? If so, should exit-time flush use a non-waiting=0A=
>    commit mode, and what are the CTO / stability implications of that?=0A=
>=0A=
> 4. Error reporting / other openers=0A=
>    If the dying task stops waiting, writeback may still fail later.=0A=
>    Mapping wb_err / errseq_t should still surface errors to other=0A=
>    users of the inode =97 is that sufficient for NFS, or do we need=0A=
>    explicit handling so that a later open/revalidate does not=0A=
>    incorrectly assume a successful close flush?=0A=
>=0A=
> Ask=0A=
> ---=0A=
> Could people familiar with the client's CTO and flush-on-close paths=0A=
> weigh in on:=0A=
>   (a) whether weakening wait-for-stable-storage on SIGKILL/exit is OK=0A=
>       for CTO,=0A=
>   (b) NFS-side vs mm-side placement of the PF_EXITING bypass, and=0A=
>   (c) what to do about FLUSH_SYNC commit in that same exit path?=0A=
>=0A=
> Thanks,=0A=
>=0A=
> --Jorge=0A=
=0A=

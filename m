Received: from mx0a-003fbd02.pphosted.com (mx0a-003fbd02.pphosted.com [67.231.149.249])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 903C5C8CE
	for <linux-nfs@vger.kernel.org>; Tue,  6 Oct 2026 00:11:53 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=fail smtp.client-ip=67.231.149.249
ARC-Seal:i=3; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1791245515; cv=fail; b=gxuvSNCmxRxXE/wYt4zGXpX2ha55u4up1OEYSeCI+qlpCK5a9UU8+XDe+keFVUegNtdRHIFItAkuilYtBhsfu9bK6GFLB1Z0/j8zat3yvDlI9Z2tS9GwBo711O+ZvdA0981c6hG9wlXzR+CNirv8N7HEWTJ8vGd4L6tEM/cuWYE=
ARC-Message-Signature:i=3; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1791245515; c=relaxed/simple;
	bh=Mk5XrW69JzfpEILWeAU38EcV7zF/nynTuwSNuJHf7OY=;
	h=From:To:CC:Subject:Date:Message-ID:Content-Type:MIME-Version; b=eYbTYDZ9FAFoRT8eOGFm54wnQuRvRJmRx8udbAPrMXhME+0oDNk/J93xwN8G0GRUFUXqWenlAzfuUUZRzQeT0+h6NsQbEK+VoHLpUsKdEJ3sQkRAScnsj3+4L8U9o1RQL10G1nVoZ6CV89GZSROBWXL8cUEtmkf/+JmXuBjmrIg=
ARC-Authentication-Results:i=3; smtp.subspace.kernel.org; dmarc=pass (p=reject dis=none) header.from=netapp.com; spf=pass smtp.mailfrom=netapp.com; dkim=pass (2048-bit key) header.d=netapp.com header.i=@netapp.com header.b=lAzD4DV5; dkim=pass (2048-bit key) header.d=netapp.com header.i=@netapp.com header.b=q0KRVCyB; dkim=pass (2048-bit key) header.d=netapp.com header.i=@netapp.com header.b=q0KRVCyB; arc=fail smtp.client-ip=67.231.149.249
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=reject dis=none) header.from=netapp.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=netapp.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=netapp.com header.i=@netapp.com header.b="lAzD4DV5";
	dkim=pass (2048-bit key) header.d=netapp.com header.i=@netapp.com header.b="q0KRVCyB";
	dkim=pass (2048-bit key) header.d=netapp.com header.i=@netapp.com header.b="q0KRVCyB"
Received: from pps.filterd (m0412380.ppops.net [127.0.0.1])
	by mx0a-003fbd02.pphosted.com (8.18.1.11/8.18.1.11) with ESMTP id 695HLQJs1597263;
	Mon, 5 Oct 2026 23:39:06 GMT
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=netapp.com; h=cc
	:content-transfer-encoding:content-type:date:from:message-id
	:mime-version:subject:to; s=pps1; bh=aRzCm8zHZzQVY/a2Og8n9afrG8y
	El9tMKJtrrtUnrBI=; b=lAzD4DV5P7OA0u01a4UjvKPh097mwilo/x7aJuix4ss
	F73tyWhECyOswvAAUiXat5GOe0TeWDa5lDZJeu6oYbfdnqxiZvIkI7dFCzWdeA7R
	eEbICp6qJUomSTtE1yrahyWXSkoDc/mstv1+CCHIgzihjjBJrI4NTGPkOYO0/3tL
	jgaYZ8lt8Qcb5sk3jjRJ3+epfXDH/ep3iVc51jC4hsSc1JA9EycOjfv5UM1vEOd2
	T/qKDi9I418SPe/xATxNuE45J8sNGvgmV/IetCO//mrHnB9BjQw0wXaqf3kaa5rz
	jRbKJ+jbQrTMtUmQl8qwPutyPYpSrTEV4YyyUd5Svcg==
Received: from ph0pr06cu001.outbound.protection.outlook.com (mail-westus3azon11011058.outbound.protection.outlook.com [40.107.208.58])
	by mx0a-003fbd02.pphosted.com (PPS) with ESMTPS id 4h3chue224-1
	(version=TLSv1.3 cipher=TLS_AES_256_GCM_SHA384 bits=256 verify=NOT);
	Mon, 05 Oct 2026 23:39:05 +0000 (GMT)
ARC-Seal: i=2; a=rsa-sha256; s=arcselector10001; d=microsoft.com; cv=pass;
 b=y3sD5ytc9XXv8/CgFtgCrNopHX+mQM/MCpCKjWqOLPDWZT/j6/oVp/Uo4Qp/yR7JBUpBn8btph4VWhqY9lgD2ZZ71sLv9OY75K0NmYcfeuUZANuPoOfAsPMIq3b3sMwoYyrLVqBLGKzSR3JW6KBJvU2zcGjfRiKe27Ek7Xaf+Dfg6aYIV2/FxU6QR5WOhGAx2fmQmNYCiqc9/q5Z3hoz2RZ63ypc5OBcPXJp6NQ+kiUmbVy3ceUNJ9E9egY+zVQZhlaMkIEcb588tNjcAUovkTB9+ONKXTWEFdDIOoLio5do9AL4aN0p1R9bzxban2nCSjk1FfJ7tmrg2uIQtKmm9Q==
ARC-Message-Signature: i=2; a=rsa-sha256; c=relaxed/relaxed; d=microsoft.com;
 s=arcselector10001;
 h=From:Date:Subject:Message-ID:Content-Type:MIME-Version:X-MS-Exchange-AntiSpam-MessageData-ChunkCount:X-MS-Exchange-AntiSpam-MessageData-0:X-MS-Exchange-AntiSpam-MessageData-1;
 bh=aRzCm8zHZzQVY/a2Og8n9afrG8yEl9tMKJtrrtUnrBI=;
 b=KDRyX1qTi8IV+CfE0HcV/Fo1R045vyOzeRE6rpbUuh78MtPK+esobU/pCN+K/wIgEVocwkT4T742b46TAN5ssirj/wtKuBpud4pdtFw8oKuf9NEqglD4Goc0sjmx3G+sQvDKCHcAmMTeIp22/rATEwLAI7ARveWPKmCRA/raoduNabvqWKdQ6kHx8ET1gx/gH/CM7XAde9S4x3SET4QDVB9V1TLPRvdHHvn1jMbUAyQM2691IK6Aju1wv3MBclmyn3vPXYg2rY3Rc/x7EKx6h11zlR6oktAVr0nX03yijHRKyecMaqKMCmCKqXjhAbjlVhXYcfYwZkyN1z2XRTwTYg==
ARC-Authentication-Results: i=2; mx.microsoft.com 1; spf=fail (sender ip is
 136.226.142.111) smtp.rcpttodomain=gsacapital.com smtp.mailfrom=netapp.com;
 dmarc=pass (p=reject sp=reject pct=100) action=none header.from=netapp.com;
 dkim=pass (signature was verified) header.d=netapp.com; arc=pass (0 oda=1
 ltdi=1 spf=[1,1,smtp.mailfrom=netapp.com] dkim=[1,1,header.d=netapp.com]
 dmarc=[1,1,header.from=netapp.com])
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=netapp.com;
 s=selector1;
 h=From:Date:Subject:Message-ID:Content-Type:MIME-Version:X-MS-Exchange-SenderADCheck;
 bh=aRzCm8zHZzQVY/a2Og8n9afrG8yEl9tMKJtrrtUnrBI=;
 b=q0KRVCyB247yAUM6/bwTy/vAmxYp/J0bi26hBZMoDMv/XsqT257VWcR/iDELj85itns68tiK24zwFBKHxEq4cVYVC/bJCQGw8J/3lNj3jD9DZApUTdW5otFg4ndqnewDHizv1oY/3XvnR+fqJOMGu8aE6faVRJ6kC6qH0wL88D7G9gAtFVqzAFrstDB/3CZVmQ/Jgiz2LBM0OrRIp678BqO2ATheANAbLSQi8v7lw2j27Gp06pvnLqXT8Tpn6ZlG/NEc9wOGHnPaz+9Jaez2jcHHwXOu2cxxD8fHdZZ7qmHxPPmI2CpYdqo3ddQXMtZMGPbp2M4w9EER+XgAQeD5nQ==
Received: from PH0PR07CA0119.namprd07.prod.outlook.com (2603:10b6:510:4::34)
 by CY0PR06MB843264.namprd06.prod.outlook.com (2603:10b6:930:133::6) with
 Microsoft SMTP Server (version=TLS1_2,
 cipher=TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384) id 15.21.472.20; Mon, 5 Oct
 2026 23:39:00 +0000
Received: from SN1PEPF00036F3E.namprd05.prod.outlook.com
 (2603:10b6:510:4:cafe::3f) by PH0PR07CA0119.outlook.office365.com
 (2603:10b6:510:4::34) with Microsoft SMTP Server (version=TLS1_3,
 cipher=TLS_AES_256_GCM_SHA384) id 15.21.472.20 via Frontend Transport; Mon, 5
 Oct 2026 23:39:00 +0000
X-MS-Exchange-Authentication-Results: spf=fail (sender IP is 136.226.142.111)
 smtp.mailfrom=netapp.com; dkim=pass (signature was verified)
 header.d=netapp.com;dmarc=pass action=none header.from=netapp.com;
Received-SPF: Fail (protection.outlook.com: domain of netapp.com does not
 designate 136.226.142.111 as permitted sender)
 receiver=protection.outlook.com; client-ip=136.226.142.111;
 helo=sjc41b2.mail.zscalertwo.net;
Received: from sjc41b2.mail.zscalertwo.net (136.226.142.111) by
 SN1PEPF00036F3E.mail.protection.outlook.com (10.167.248.22) with Microsoft
 SMTP Server (version=TLS1_3, cipher=TLS_AES_256_GCM_SHA384) id 15.21.496.14
 via Frontend Transport; Mon, 5 Oct 2026 23:38:59 +0000
Received: from bn1pr07cu003.outbound.protection.outlook.com ([40.93.12.6])
	by sjc41b2.mail.zscalertwo.net ([136.226.142.95])
	with ESMTPS id 6AC4351308C10000;
	Mon, 05 Oct 2026 16:38:59 -0700
ARC-Seal: i=1; a=rsa-sha256; s=arcselector10001; d=microsoft.com; cv=none;
 b=yA9oWmcYdRqL2HSNm8N5Y9mKdIrvcWbjZtRc/MmqhG6GYSLF0OMrznZXL6Od8feXzTcJLmn9t/HaBEZmRVp2UiwGeRcplzrdxqV2GkNiEQyRo49k6rLqWjJjSZireUJQVXCxWF75YiW7qcfmm6KablV6FiPMvGGgw2fuxDg0nmKKEww4df2+74rIzk3DkE4IOVXbHB2IA8c+11tJbOoFx8ZSlruCgZn95C38yUf7kmugji+heghSyySa3ce1wSgoMZ7z3VSFwdgHsC2dK5BUpD0xcQCXLIZMPJTWg9M13tLlpXXR/7UZ7CPSC8O0cPEfYC4+W1+Bxvk0ryROYc0qdQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=microsoft.com;
 s=arcselector10001;
 h=From:Date:Subject:Message-ID:Content-Type:MIME-Version:X-MS-Exchange-AntiSpam-MessageData-ChunkCount:X-MS-Exchange-AntiSpam-MessageData-0:X-MS-Exchange-AntiSpam-MessageData-1;
 bh=aRzCm8zHZzQVY/a2Og8n9afrG8yEl9tMKJtrrtUnrBI=;
 b=RKywIKyRHF09Ic5yXHQoK0viNFJ4MLfx/KKNbctQpCWpbiZTeqoo1Sh9n5yJ7zuJK37GrGaK0FXWMqumsgQHvi/Ld4dKUD3r8js63CHG4+eg7hO0KfdefJ6jWVgkvuZ3lHseaTrQJqoCtJrb+ds3xG4jl0gFGERBXBDxvODFDO5cO7fWsmeDkeTBObgtf3/Brf2U+jSFjx33u3zx+ISO0hFvdL7CIIWR51IIG3SiwoKtHCbtuhCbU35FNntQdmtHzDLuH+aC1xmrwMunMrIMAJsVJRqHq17iiL1ZzIl0xE7Z8UYHTk28AX9oDMOwUE2OkSN+5Rc8/gFzibK+q1YOEQ==
ARC-Authentication-Results: i=1; mx.microsoft.com 1; spf=pass
 smtp.mailfrom=netapp.com; dmarc=pass action=none header.from=netapp.com;
 dkim=pass header.d=netapp.com; arc=none
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=netapp.com;
 s=selector1;
 h=From:Date:Subject:Message-ID:Content-Type:MIME-Version:X-MS-Exchange-SenderADCheck;
 bh=aRzCm8zHZzQVY/a2Og8n9afrG8yEl9tMKJtrrtUnrBI=;
 b=q0KRVCyB247yAUM6/bwTy/vAmxYp/J0bi26hBZMoDMv/XsqT257VWcR/iDELj85itns68tiK24zwFBKHxEq4cVYVC/bJCQGw8J/3lNj3jD9DZApUTdW5otFg4ndqnewDHizv1oY/3XvnR+fqJOMGu8aE6faVRJ6kC6qH0wL88D7G9gAtFVqzAFrstDB/3CZVmQ/Jgiz2LBM0OrRIp678BqO2ATheANAbLSQi8v7lw2j27Gp06pvnLqXT8Tpn6ZlG/NEc9wOGHnPaz+9Jaez2jcHHwXOu2cxxD8fHdZZ7qmHxPPmI2CpYdqo3ddQXMtZMGPbp2M4w9EER+XgAQeD5nQ==
Received: from SA1PR06MB11353.namprd06.prod.outlook.com
 (2603:10b6:806:4a2::17) by BY1PR06MB10161.namprd06.prod.outlook.com
 (2603:10b6:a03:5c1::13) with Microsoft SMTP Server (version=TLS1_2,
 cipher=TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384) id 15.21.472.20; Mon, 5 Oct
 2026 23:38:55 +0000
Received: from SA1PR06MB11353.namprd06.prod.outlook.com
 ([fe80::ff:880:c010:68bf]) by SA1PR06MB11353.namprd06.prod.outlook.com
 ([fe80::ff:880:c010:68bf%6]) with mapi id 15.21.0472.016; Mon, 5 Oct 2026
 23:38:55 +0000
From: "Mora, Jorge" <Jorge.Mora@netapp.com>
To: "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>,
        Trond Myklebust
	<trondmy@kernel.org>,
        "anna@kernel.org" <anna@kernel.org>,
        Olga Kornievskaia
	<okorniev@redhat.com>,
        Scott Mayhew <smayhew@redhat.com>,
        "ben.coddington@hammerspace.com" <ben.coddington@hammerspace.com>
CC: "rushil.patel@gsacapital.com" <rushil.patel@gsacapital.com>,
        "tim.saunders@gsacapital.com" <tim.saunders@gsacapital.com>,
        "mark.brading@gsacapital.com" <mark.brading@gsacapital.com>,
        "ben.roberts@gsacapital.com" <ben.roberts@gsacapital.com>
Subject: Close-to-open consistency on SIGKILL
Thread-Topic: Close-to-open consistency on SIGKILL
Thread-Index: AQHdVSBlpS+KtLjd9ki6JO7yF3rKEg==
Date: Mon, 5 Oct 2026 23:38:55 +0000
Message-ID:
 <SA1PR06MB113533BFC97DA85AE6D37D99DE1962@SA1PR06MB11353.namprd06.prod.outlook.com>
Accept-Language: en-US
Content-Language: en-US
X-MS-Has-Attach:
X-MS-TNEF-Correlator:
msip_labels:
Authentication-Results-Original: mx.microsoft.com 1; dkim=none (message not
 signed) header.d=none;dmarc=none action=none header.from=netapp.com;
x-ms-traffictypediagnostic:
	SA1PR06MB11353:EE_|BY1PR06MB10161:EE_|SN1PEPF00036F3E:EE_|CY0PR06MB843264:EE_
X-MS-Office365-Filtering-Correlation-Id: 886c228f-7416-443d-fc68-08df2339d4de
X-MS-Exchange-SenderADCheck: 1
X-MS-Exchange-AntiSpam-Relay: 0
X-Microsoft-Antispam-Untrusted:
 BCL:0;ARA:13230040|366016|1800799024|7416014|376014|23010399003|38070700021|11063799006|56012099006|10067099003|18002099003|3023799007;
X-Microsoft-Antispam-Message-Info-Original:
 xPd6OJgkjHH5D1e2W1D3STxdvhu9o3GSB608gZS4vQBZ5jWYMD2oJ44enYBBCN41bP3WrIOsfHZe0jT/JA8q+ZvEYUoE/Kngt/A5om7eRTF+dWjc6CytjAzrGlUhxflFjrBMst+8yQQVeqIyffGu/jNVr8j1DhP3dhxgg1L9HsH3pNbPvwFGUc/cwGCWY/9ACkUqFfpN7LP2MxxQBMa+kdM1PalPXyjbpmCbsDVDkwH+iZ8zScNkaeN8A+fJxp/8r2HrBJg+NCZtn8hHp2NELORecEMYdPsRz6NT49XYYRiALg7/826RhjRhXaSuL/diy2aoIgoY2mQBsDNTkPCry/n7LYgHY/OK2HRI8sr5h6PkrNYeNGQKdJp9Eacdr/x8z92K9l1xJOQqHnpqwyEhm/cxM6MltGmIfER6iS2cjUbPSJyJjzCPj/dUYvEUOjTMxcDK5RHGi7j0RJaxIneV9kcjIPiAeawxCnEJr5LkiLliu1/wI954pZNrTqQT12O+kcaicNAKqNdOimIf9j2hMi4lwLXEypK/gUfJExC8fgUnwwwkKRNW/GF4oP+az8cNuJ3xD4EiBj7rLhZ7pLU6a749436xDN+8P5pS6oFao2rYJOqn1UwHOtKf9iP1WxH+FBRVeIXGNJEYYP6L2LHW+4aI+SwT+fR/1RX0AiarRzg=
X-Forefront-Antispam-Report-Untrusted:
 CIP:255.255.255.255;CTRY:;LANG:en;SCL:1;SRV:;IPV:NLI;SFV:NSPM;H:SA1PR06MB11353.namprd06.prod.outlook.com;PTR:;CAT:NONE;SFS:(13230040)(366016)(1800799024)(7416014)(376014)(23010399003)(38070700021)(11063799006)(56012099006)(10067099003)(18002099003)(3023799007);DIR:OUT;SFP:1101;
Content-Type: text/plain; charset="Windows-1252"
Content-Transfer-Encoding: quoted-printable
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
X-Exchange-RoutingPolicyChecked:
 bish7Gv69BqE5DK+qljYzmjkoXjXkPNxuyT9QF0251l+Zo9yvCAi1Wn5IcmC8ErbOtOiLbvf+nMrhyoAH+UhkB2jtbuuTIJF5rN4sByY2O4g80UEeXFPpmb5Gi2EBkB6fsoUnzyOeE76IgOoFyG64laCmrTjsnbLnZ9X3HHIL6sfA87BuTac38hEwyLS7xj3VKa2Bv3zID+cfFdWNBJHZFTtgadJvEY/Mwtu+zEloltm12RxM0Han5KmwSFlUTv8wsTkwJTItaXBHWxqOXllqnAqODYFK2stT/PxvetXElQe6pOCqGc37sKcD+zokSDYsyBPB3+IEqdxydS6tYxTxg==
X-MS-Exchange-Transport-CrossTenantHeadersStamped: BY1PR06MB10161
X-Zscaler-Block: 0
X-EOPAttributedMessage: 0
X-MS-Exchange-Transport-CrossTenantHeadersStripped:
 SN1PEPF00036F3E.namprd05.prod.outlook.com
X-MS-PublicTrafficType: Email
X-MS-Office365-Filtering-Correlation-Id-Prvs:
	9601a478-d6ce-413b-738a-08df2339d247
X-Microsoft-Antispam:
	BCL:0;ARA:13230040|14060799003|1800799024|36860700016|376014|35042699022|23010399003|82310400026|13003099007|18002099003|10067099003|3023799007|11063799006|56012099006;
X-Microsoft-Antispam-Message-Info:
	PtCmn4+zRVU2BjjavYPU20Fdyq4553iW+Zgyp+F7eCKBFE4Y5LxFQkHrLNtfLLsbhHsS44p82ubItwUR+dcS1CBbH3xdBS4gaO55h65JiWJHhO9CjTldrYF5Sw+3PlaXJQwFkGYWXJFghtvEpR0Zo9lUYzR0z8sJ2eBdtO5rxYRA4YJdBBHN6hEImPUGhftRVHiG7t+0FJRZi47BdkCO7jB+UWIjKgmPDNmNL6BStqRJOYr/RCHf9O6GMqiKQlPvwHaPRMAH1JbNlpe2SC3/YYhbhHZ4FV2JoKldALWHQHH8ipvseqVHD3HVRiKRueuD/GAljEhz9dv9v1eZHDPNtpZeA44qo+adktelg/sBVW7FHlqrUeyyLEOTG2KKZZ2EGfIcjZARm/NLcU9VMMzQFocL31rlFD84zDz+77n3DfyAeHx4Y2INRDWH8y71vquRcrK/N3k4K42OoGq7niM1jbRKZ8Ztme1A2JivyZyI5i6LRTK9xU4nvGir+ettCnIbPvl/Ik/yL54adIQZ9K/tKNi6AAPYnaEUmxKjVB3HmHrPxFvQh1r4IQ6YhI+/o0q8InUjGsfEyVwtS0ncvUITCLqj6QvLDLbOQ6UfbxoNVR3siILeS4Ym8ArQZa0gQlF36HRyvY4Y4w9yXlOpR9dmGQ==
X-Forefront-Antispam-Report:
	CIP:136.226.142.111;CTRY:US;LANG:en;SCL:1;SRV:;IPV:NLI;SFV:NSPM;H:sjc41b2.mail.zscalertwo.net;PTR:sjc41b2.mail.zscalertwo.net;CAT:NONE;SFS:(13230040)(14060799003)(1800799024)(36860700016)(376014)(35042699022)(23010399003)(82310400026)(13003099007)(18002099003)(10067099003)(3023799007)(11063799006)(56012099006);DIR:OUT;SFP:1101;
X-MS-Exchange-AntiSpam-MessageData-ChunkCount: 1
X-MS-Exchange-AntiSpam-MessageData-0:
	hQUSL6R/iUWwYn/Av9AgSNVHcUbWQUPY5C0W8ti7B+lkKQjWJXhqmxIOa96DC/gjCFwltTV6FdzkGc5iTyt8DPC1zBJREKrlcUXVybjDICTZBgGFJfx/ctwveZI+PUKn5L7gKLg8266JZ/rsKwwrcwb0HA/lWb869Y1E/njDfPv6LqGmLAg1f59WB+y8iua8zHGaExmTyAO8xvFWtSI6+4apC8/2F3f3yBZgesD7/JSATc6dWyLNAc+a1H3KFcOaxJpWNCO3h1gbdSPtP3ZgBFCsLpv54vEyNsMXXLwITmSfPZWalr9KXQktjVnXwnOr7riLdX2SVasEXOXtGDmv7VJA8ez/M9lqvMoayEjOc3FTKCqUPjq1bRFUMmn1X3g5G5eoBI9sxqlshKAOb/Z5IUCSZ/22npKlflJKJtoHAfE7nfnr3nwsE8wd0TYdEBKT
X-Exchange-RoutingPolicyChecked:
	d/ml10w3MbkuAzVi0rAXpE+U/0nZgG3m/cuUwvzXpco3x/qK87hsb7v6H6zuK0cTiEGbySJ7vkgS0+UXyeWrNbll0j1oS3HlV/4R+Otw53DmlC40EwjcvK1i21eBS0LqDGRsiP/lyh3RmEk8mE/EsXxsDhThqOMikGG1xmMhLjc1njtvZXXI9ru0F54W+/M5KhJHuKHhisgaKa7+n/tG5XW5lLREZr95U6OAGwdgjOGs1jkYAEGhRxaRzBD1qD6GjJXdL17uPu38R+aVsV8Wpp/bAxrk5DVToUSOpXEr346syEfaIdUIoh3jxHFNRpwrOFgWLVm54efUis4EgwWG+w==
X-MS-Exchange-AntiSpam-ExternalHop-MessageData-ChunkCount: 1
X-MS-Exchange-AntiSpam-ExternalHop-MessageData-0:
	pmS9XJZ84BKUzEnhrrHyrhwuRxtz0GWY56tTzy3VbrHIIgriaRgEEl+xQ11VayIPixtwZ5tnF51cdzSndEjxYQ/ZBdEB6a2aLS9U3vW2d+l+ugmqsABmaZT4SZPl89KPwsVrao4lRlDZE4SwOg2Y29GlZQMDH+Ydd1mNsjDK88VSiepiPC5dBCOurAgKvBzgZD4crQGWriz+vncuVxjwmcBoJMd3AByJVeE8lmH8CIIKLquY7dWiLT63xt5NTiH1TOrEG4N0vcXhMOyXjJO2/60Kz97nCbw4zVHW0l7YnoXPgIPhGMHvGaLHdCwgDJ1RixAeIzca4526HPq2cO5oyVFMnlx1/Pu0m4Cd7dzUXTo1ByaBNfTTAuYD1RCnHEpaoROr5WHHC6GWTvVfDy00MDZerSmLgcwB5g99M14RLAqcCBf/0lHK+w8jILd40WmgGwKRqftmVtYg0pm6miIDkJ0jS9jF+70sAFrFvDVRBskP8ZYu2pAxL+NxEGHcD+jrI+eMjODKKHzeKJzuZ6PPb22ptTG9STw98uKtpe/4bKDz3/L+dB97cM/z8I+6Yx614m+KZQeC2SPWU2CWmTuQXUnEwarxr/WpKq/n/e0jefbAurGWSr5oLpPJImm/r2He
X-OriginatorOrg: netapp.com
X-MS-Exchange-CrossTenant-OriginalArrivalTime: 05 Oct 2026 23:38:59.7839
 (UTC)
X-MS-Exchange-CrossTenant-Network-Message-Id: 886c228f-7416-443d-fc68-08df2339d4de
X-MS-Exchange-CrossTenant-Id: 4b0911a0-929b-4715-944b-c03745165b3a
X-MS-Exchange-CrossTenant-OriginalAttributedTenantConnectingIp: TenantId=4b0911a0-929b-4715-944b-c03745165b3a;Ip=[136.226.142.111];Helo=[sjc41b2.mail.zscalertwo.net]
X-MS-Exchange-CrossTenant-AuthSource:
	SN1PEPF00036F3E.namprd05.prod.outlook.com
X-MS-Exchange-CrossTenant-AuthAs: Anonymous
X-MS-Exchange-CrossTenant-FromEntityHeader: HybridOnPrem
X-MS-Exchange-Transport-CrossTenantHeadersStamped: CY0PR06MB843264
X-Proofpoint-GUID: dXRq_2sayTPF-NRsKzRWOpKTulOeAXg8
X-Proofpoint-Spam-Details-Enc: AW1haW4tMjYxMDA1MDA5MyBTYWx0ZWRfX39NDeywzNoYQ
 3fCGlUZ8Zunm/h20UzXotnPk3QQuzXCppji7HUHAW7o9GXZF7dj+6Apw/hXMrGEo2sh41opIyzA
 ZRSMSaw4rHwh/mpMntdQBP/e+BPgDZGEy0YBj0xgZX+uAMzhLVF5/OAE5HpBIMxSe6sgDpB/hHe
 VtOBaZ8qyVYC1THtvMdRtFiCTDtClH/us9QYBXYzdii1b1K1eoDOUvSD8bou50yAarUTVkkI77O
 PNHkzulUdg3SOMyMdCK1Wsz+p+wGmb2ecHtsXLHajSIuIrkHoQxY5SGGukygnxXdCF1LzxHmB8W
 ppnIdNJdTZ57Khr6UpUJrgQ4kzWi/Bdfc7pufZtZIs9Y+sxVazZoIoKsf0DI247aRopyVhUHLMv
 Ha3w/JMVbcmODiOza2ByDmZ107nd3+xodD/oz2aGiek/l9xtXDP1I1uhbBewC9QvmdGCKqRCE+I
 0zaGMwIIgtlph5gyoGA==
X-Authority-Analysis: v=2.4 cv=WaWZ+EhX c=1 sm=1 tr=0 ts=6ac43519 cx=c_pps
 a=EoP4yJziA5n+MzrLuL7W4g==:117 a=1cKNBmr56ioqABmsJRZnaw==:17
 a=6eWqkTHjU83fiwn7nKZWdM+Sl24=:19 a=lCpzRmAYbLLaTzLvsPZ7Mbvzbb8=:19
 a=xqWC_Br6kY4A:10 a=N659UExz7-8A:10 a=660iZSQnnn4A:10 a=GWG4Yq0kndkA:10
 a=VkNPw1HP01LnGYTKEx00:22 a=1lWG0UuNQvn8UhQ8Wh4S:22 a=4vgg-l6Rpv8Bo-T7s-Q-:22
 a=VwQbUJbxAAAA:8 a=aU7qV5IrAAAA:8 a=JfrnYn6hAAAA:8 a=o56ra6yN8hH1rOG4z-gA:9
 a=pILNOxqGKmIA:10 a=XeeNnEZWyIaKVUq9vuPT:22 a=1CNFftbPRP8L7MoqJWF3:22
X-Proofpoint-Spam-Info: AW1haW4tMjYxMDA1MDA5MyBTYWx0ZWRfX+eXwNXmKZaPm
 9pSX9h/VrOjKvdyZKjEnmR9+/UtQPFRt9Q8PUysDdRYR2D81PB4XOuNSMb7pHx/yXm8F4CP1lRZ
 sK3U9EpTAlsEirySrI2ZLIEpCCucc6U=
X-Proofpoint-ORIG-GUID: dXRq_2sayTPF-NRsKzRWOpKTulOeAXg8
X-Proofpoint-Virus-Version: vendor=baseguard
 engine=ICAP:2.0.293,Aquarius:18.0.1176,Hydra:6.1.134,FMLib:17.12.100.49
 definitions=2026-10-05_05,2026-10-05_01,2025-10-01_01
X-Proofpoint-Spam-Details: rule=outbound_notspam policy=outbound score=0
 clxscore=1011 spamscore=0 malwarescore=0 phishscore=0 priorityscore=1501
 lowpriorityscore=0 bulkscore=0 suspectscore=0 impostorscore=0 adultscore=0
 classifier=typeunknown authscore=0 authtc= authcc= route=outbound adjust=0
 reason=mlx scancount=1 engine=8.22.0-2609040000 definitions=main-2610050093

Hello,=0A=
=0A=
I'd like to get the NFS client's view on a patch that showed up on=0A=
linux-mm, and in particular on how the proposed behaviour interacts=0A=
with NFS close-to-open (CTO) consistency.=0A=
=0A=
Background=0A=
----------=0A=
Rushil Patel reported that on NFSv4.1 (Slurm jobs, NetApp filer),=0A=
cancelling a job can leave processes stuck in D-state in=0A=
folio_wait_bit_common() while __filemap_fdatawait_range() waits=0A=
uninterruptibly for writeback. If the server is slow or unreachable,=0A=
the only practical recovery is rebooting the client.=0A=
=0A=
The linux-mm patch:=0A=
  https://lore.kernel.org/linux-mm/20260325113616.785496-1-rushil.patel@gsa=
capital.com/=0A=
=0A=
The patch makes the wait killable, and also skips the wait entirely when=0A=
PF_EXITING is set. The PF_EXITING part is needed because after SIGKILL=0A=
wakes the first wait, do_exit() -> exit_files() -> nfs4_file_flush()=0A=
-> nfs_wb_all() re-enters filemap_write_and_wait(), and at that point=0A=
wants_signal() will not deliver SIGKILL to a PF_EXITING task, so a=0A=
second killable wait can hang forever.=0A=
=0A=
Matthew Wilcox's reply (CC'd linux-nfs):=0A=
  https://lore.kernel.org/linux-mm/acQ0YRLM_SxYfjfI@casper.infradead.org/=
=0A=
=0A=
suggests that the PF_EXITING special case may belong in NFS rather=0A=
than in __filemap_fdatawait_range(), e.g. in nfs_wb_all():=0A=
=0A=
    if (current->flags & PF_EXITING)=0A=
        ret =3D filemap_fdatawrite(inode->i_mapping);=0A=
    else=0A=
        ret =3D filemap_write_and_wait(inode->i_mapping);=0A=
=0A=
He also flagged the subsequent:=0A=
    ret =3D nfs_commit_inode(inode, FLUSH_SYNC);=0A=
=0A=
as another possible synchronous wait that could trap an exiting task=0A=
even if the filemap wait is skipped.=0A=
=0A=
Matthew's take on CTO was that other filesystems do not flush-on-close=0A=
the way NFS does, and that it is probably acceptable to weaken the=0A=
guarantee for an involuntary termination (SIGKILL / exit) rather than=0A=
an orderly close. I'd like confirmation (or pushback) from the NFS=0A=
side before we settle on an approach.=0A=
=0A=
Questions for the NFS client community=0A=
--------------------------------------=0A=
1. CTO on involuntary close=0A=
   NFS flush-on-close exists largely to uphold close-to-open: after=0A=
   close, a subsequent open on another client should see the writer's=0A=
   data.=0A=
   If we skip waiting for writeback (and possibly COMMIT) because the=0A=
   process is exiting after SIGKILL:=0A=
   - Is it acceptable that CTO may not hold for that file until=0A=
     writeback/COMMIT later complete (or fail) asynchronously?=0A=
   - Are there known applications or protocols that assume even a=0A=
     killed writer has pushed data to stable storage by the time the=0A=
     file descriptor is gone?=0A=
   - Should we still initiate writeback (filemap_fdatawrite) and an=0A=
     async COMMIT, and only avoid the wait =97 or is skipping more of=0A=
     the flush path preferred when PF_EXITING?=0A=
=0A=
2. Where should the special case live?=0A=
   - Generic: PF_EXITING / killable wait in __filemap_fdatawait_range()=0A=
     (as in the linux-mm patch), affecting all callers.=0A=
   - NFS-specific: change nfs_wb_all() / nfs4_file_flush() (and any=0A=
     other flush-on-close paths) as Matthew sketched, leaving the mm=0A=
     helper alone except perhaps for making the wait killable.=0A=
   Preference? Any other NFS entry points that need the same treatment?=0A=
=0A=
3. nfs_commit_inode(..., FLUSH_SYNC) during exit=0A=
   If we only replace filemap_write_and_wait() with filemap_fdatawrite()=0A=
   on PF_EXITING, does FLUSH_SYNC COMMIT still block uninterruptibly=0A=
   on a wedged server? If so, should exit-time flush use a non-waiting=0A=
   commit mode, and what are the CTO / stability implications of that?=0A=
=0A=
4. Error reporting / other openers=0A=
   If the dying task stops waiting, writeback may still fail later.=0A=
   Mapping wb_err / errseq_t should still surface errors to other=0A=
   users of the inode =97 is that sufficient for NFS, or do we need=0A=
   explicit handling so that a later open/revalidate does not=0A=
   incorrectly assume a successful close flush?=0A=
=0A=
Ask=0A=
---=0A=
Could people familiar with the client's CTO and flush-on-close paths=0A=
weigh in on:=0A=
  (a) whether weakening wait-for-stable-storage on SIGKILL/exit is OK=0A=
      for CTO,=0A=
  (b) NFS-side vs mm-side placement of the PF_EXITING bypass, and=0A=
  (c) what to do about FLUSH_SYNC commit in that same exit path?=0A=
=0A=
Thanks,=0A=
=0A=
--Jorge=

Received: from mx0b-003fbd02.pphosted.com (mx0b-003fbd02.pphosted.com [67.231.157.221])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 52CA4368D79
	for <linux-nfs@vger.kernel.org>; Wed,  2 Sep 2026 17:59:08 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=fail smtp.client-ip=67.231.157.221
ARC-Seal:i=3; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1788371951; cv=fail; b=PQgDhrFcIXg+g64QWvN9aTASJWL6YYoatFXAXNoL+C5mEKT0RD3L+YZIUkoxJlf0FG42lJFku6J169KGgVZUDq7W+6V4w9mkIvHD+BLX7IK/j0wL1MTJWLp4koKm4Eqcs64CZ2So8XCaY/xkt9VmmSG2zujSkV0hgBSBpHs2Pb8=
ARC-Message-Signature:i=3; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1788371951; c=relaxed/simple;
	bh=daalI1u6DwW6JgBejpVvdAajGSD3TJQSUAPKUoCI5ds=;
	h=From:To:CC:Subject:Date:Message-ID:References:In-Reply-To:
	 Content-Type:MIME-Version; b=qYlOgPB4DVceEeJxn6mXfTpy95qYchIOmcLlIHgQsB18pB8zPnC9ZgyH7QlvyXmObncKQ6qDW/hyVYxp5R+zfXxIMUsMWrAtnaREPKLTRCMg2VcKogVNsS+QTa3b07otg8re/iQTIgMuaP4EAEK98ansztGjsYqsVk5gN59T54U=
ARC-Authentication-Results:i=3; smtp.subspace.kernel.org; dmarc=pass (p=reject dis=none) header.from=netapp.com; spf=pass smtp.mailfrom=netapp.com; dkim=pass (2048-bit key) header.d=netapp.com header.i=@netapp.com header.b=CPIPLpca; dkim=pass (2048-bit key) header.d=netapp.com header.i=@netapp.com header.b=eHlkifeh; dkim=pass (2048-bit key) header.d=netapp.com header.i=@netapp.com header.b=eHlkifeh; arc=fail smtp.client-ip=67.231.157.221
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=reject dis=none) header.from=netapp.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=netapp.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=netapp.com header.i=@netapp.com header.b="CPIPLpca";
	dkim=pass (2048-bit key) header.d=netapp.com header.i=@netapp.com header.b="eHlkifeh";
	dkim=pass (2048-bit key) header.d=netapp.com header.i=@netapp.com header.b="eHlkifeh"
Received: from pps.filterd (m0412383.ppops.net [127.0.0.1])
	by mx0b-003fbd02.pphosted.com (8.18.1.11/8.18.1.11) with ESMTP id 682HuXUm3726698;
	Wed, 2 Sep 2026 17:58:54 GMT
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=netapp.com; h=cc
	:content-transfer-encoding:content-type:date:from:in-reply-to
	:message-id:mime-version:references:subject:to; s=pps1; bh=Fnqq5
	fGPI/1ayAzK4SLvIgjmX6anBXdirKkYYduIz0k=; b=CPIPLpca4WLtNBRyRuDfO
	PSAMIf3OMqBzNQ29eB+Z6G3QTvA8PI5nqRpeAfcQwarBJNHA7C6iQ7gcZNvu7Z0A
	PEVL7FSpHB68idfoc2IDUhsc8ZpWB0y9j1O+5AILTPIR/JcyRScQKGb8u1kUHgcS
	y57usFLLxZK2JPuT5vVOH55O8rAg+97yPcpUsGn8dd1cZIiOGP/U+iNt2vfwgOSk
	GSYKbI0b1ooujCuFpSXfQ3Gzig5J9OK98z9e9FfQElU2xFovWVNyVptjWb22Zb1p
	3ovQ3wrlrwT4RZu3f0EHb908KfT4r7EALmPNaa86ZmBrJkiuJrkRptI3zwmdAnxs
	Q==
Received: from sn4pr2101cu001.outbound.protection.outlook.com (mail-southcentralusazon11012040.outbound.protection.outlook.com [40.93.195.40])
	by mx0b-003fbd02.pphosted.com (PPS) with ESMTPS id 4gdwucxrx0-1
	(version=TLSv1.3 cipher=TLS_AES_256_GCM_SHA384 bits=256 verify=NOT);
	Wed, 02 Sep 2026 17:58:53 +0000 (GMT)
ARC-Seal: i=2; a=rsa-sha256; s=arcselector10001; d=microsoft.com; cv=pass;
 b=GT2w8xUgyjfyQH+KmvqdasWSQSsOeJer9ICnBV8hPpuCDONgo97ATQM0QHg0qw9zzr1HBM6pGY7isCdVtliF8vAPnjgCqII+5P7o0gkYI0UW8RtauzAFumbiMCoOm+LRfQlerIdHyxmnEC1Z6NK2J/kB05mvByYCAt5yMn3XeIni/bSCzx5zLnytT/fCKfdU7RAb7EkCTD/gMzTHRaaYq4PD2VtrfUQptTZqukOIVy1hC4Q1UAgTD1bb1Z+bHG0LimshzK8EG0xZQizvziY9MnLVwMFIjggrAmxf1AuWlLp0eC0z3VaLbOOJCPo9/hIK0Xq0iPpa7pb0Ys3ugI2UuQ==
ARC-Message-Signature: i=2; a=rsa-sha256; c=relaxed/relaxed; d=microsoft.com;
 s=arcselector10001;
 h=From:Date:Subject:Message-ID:Content-Type:MIME-Version:X-MS-Exchange-AntiSpam-MessageData-ChunkCount:X-MS-Exchange-AntiSpam-MessageData-0:X-MS-Exchange-AntiSpam-MessageData-1;
 bh=Fnqq5fGPI/1ayAzK4SLvIgjmX6anBXdirKkYYduIz0k=;
 b=nT5rvlGPUwkF1RYfQG08sA73H89yIREwduhMFkuaBe6VyDm0XhkuWbFP7WTrafJ4WhNzPFvJniz6dy4wWirffuoG7XqZrJ5P3yxVVjKVBi1gnUa/SvHMGqfouejZ/sTvfFGYBpAhY46HODm1l4aNPzvWoPBrlrjYoUFhXSqvGcZrtJwAc1+0SOTDnWuoJ0XXmwfC20tPh/ZZD6R58lrexdUhxvuQCwtkE8fmGM40Rm8H7ZEO7ky9kw2Xaq0fEg+8RpEzYR31Krnb2/kI4PlXpB7Op37pLRizzU9GcW2AiK9sQ8H84j9Sy22CmdKp9tAi6xxUnhFeIu8YIm5bqO8hww==
ARC-Authentication-Results: i=2; mx.microsoft.com 1; spf=fail (sender ip is
 136.226.152.57) smtp.rcpttodomain=vger.kernel.org smtp.mailfrom=netapp.com;
 dmarc=pass (p=reject sp=reject pct=100) action=none header.from=netapp.com;
 dkim=pass (signature was verified) header.d=netapp.com; arc=pass (0 oda=1
 ltdi=1 spf=[1,1,smtp.mailfrom=netapp.com] dkim=[1,1,header.d=netapp.com]
 dmarc=[1,1,header.from=netapp.com])
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=netapp.com;
 s=selector1;
 h=From:Date:Subject:Message-ID:Content-Type:MIME-Version:X-MS-Exchange-SenderADCheck;
 bh=Fnqq5fGPI/1ayAzK4SLvIgjmX6anBXdirKkYYduIz0k=;
 b=eHlkifehifGEwKShotfQx7AG9mWdEHcc/mUnUMAD4O/anb+vCAE0ip2/TNLhVN+BZMlbcafXiWOFiwd3+ZNppFQrmQHkdxCRULpb+w1fV1nGW9NczQfvBI2H9uE5waiJCgg2qN7jjxEiRSK1hRSLb1SzwXoNDS+heBVGte5k//iz2TpsDt90MFYDPgSRjogo+TwuOK4PSHeX0RKr9V6X7ruF3ya0JKkTVZLFDZgkkhNcq7U14u69BqOiaRns0/VffPvepZT3bR6wIVNfkpI6m5h741lmL3/KNgYJwXVhhMWj+SogfLDYg26rJqq4edv1/wawYnuix+aMEivIb0CnIA==
Received: from SJ0PR05CA0177.namprd05.prod.outlook.com (2603:10b6:a03:339::32)
 by CO6PR06MB7602.namprd06.prod.outlook.com (2603:10b6:303:a5::16) with
 Microsoft SMTP Server (version=TLS1_2,
 cipher=TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384) id 15.21.382.10; Wed, 2 Sep
 2026 17:58:50 +0000
Received: from SJ1PEPF00001CDF.namprd05.prod.outlook.com
 (2603:10b6:a03:339:cafe::ad) by SJ0PR05CA0177.outlook.office365.com
 (2603:10b6:a03:339::32) with Microsoft SMTP Server (version=TLS1_3,
 cipher=TLS_AES_256_GCM_SHA384) id 15.21.382.7 via Frontend Transport; Wed, 2
 Sep 2026 17:58:50 +0000
X-MS-Exchange-Authentication-Results: spf=fail (sender IP is 136.226.152.57)
 smtp.mailfrom=netapp.com; dkim=pass (signature was verified)
 header.d=netapp.com;dmarc=pass action=none header.from=netapp.com;
Received-SPF: Fail (protection.outlook.com: domain of netapp.com does not
 designate 136.226.152.57 as permitted sender)
 receiver=protection.outlook.com; client-ip=136.226.152.57;
 helo=was11a5.mail.zscalertwo.net;
Received: from was11a5.mail.zscalertwo.net (136.226.152.57) by
 SJ1PEPF00001CDF.mail.protection.outlook.com (10.167.242.7) with Microsoft
 SMTP Server (version=TLS1_3, cipher=TLS_AES_256_GCM_SHA384) id 15.21.382.8
 via Frontend Transport; Wed, 2 Sep 2026 17:58:49 +0000
Received: from co1pr07cu001.outbound.protection.outlook.com ([40.93.10.91])
	by was11a5.mail.zscalertwo.net ([136.226.152.43])
	with ESMTPS id 6A9863D908F70001;
	Wed, 02 Sep 2026 13:58:49 -0400
ARC-Seal: i=1; a=rsa-sha256; s=arcselector10001; d=microsoft.com; cv=none;
 b=eJbyMDi3qMupheg4t+o06GazHTwGmBPfp1On+2JsLJoZRyHQ3L3PfGwA8Y3Lm5uiJJ69crWqpY2TSRILGedDLHKtRH79WUY0n87BmIAaDLK+u6ycz5zZRs44G7ZXk2vSwurrAd+R5/epzCgwKpPXAmrD5cygZeMb7S49cn3wzBcK6Uwdh+vTn7EqH/D13OMv7yV68vfZtMPTeauFJT3ZJHj1Pfse7nYIAjUI/yNagxdDfabLlO0L23MiDkTcK3/Wav5sAboJ0bdCH+pLHeW09luqmBeuZXVEd16ftde9mE6BPfTeJ4b0A+XYQFgirdGaZaqVCWKtXJpR1i6SFiGHdg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=microsoft.com;
 s=arcselector10001;
 h=From:Date:Subject:Message-ID:Content-Type:MIME-Version:X-MS-Exchange-AntiSpam-MessageData-ChunkCount:X-MS-Exchange-AntiSpam-MessageData-0:X-MS-Exchange-AntiSpam-MessageData-1;
 bh=Fnqq5fGPI/1ayAzK4SLvIgjmX6anBXdirKkYYduIz0k=;
 b=f/Is3B/X7zNlZ4Qviii25z8ZiC6VcQDkZEZJRoUhNmKSYayQCqShOSBp0hafZ4iDgKo0wSdTVIw8RKRjvKUFJL5Nol85r8MjXpxvB+ld+S2CGxK2Ttb3b0+jOzt0Px2pYs9LoC7NjYnsS8Vq1J/YEB26r+pVXKWQnQ3KLLg5E4VGwWCsrEUb2J9vkbrr+Vt9lE6PAQzBVIqQ17XwdHuw/SBseUAO0bOXQApR+6eshtRHz5w5/CndoO38F+w+GObugxzxU8irttZAqWpoYfzWH79i+jfa2CpxOKLehgZntlu9lujCHWd6xgvHrKMez2vNSEkCZ9lCD94KayqxOUWl2Q==
ARC-Authentication-Results: i=1; mx.microsoft.com 1; spf=pass
 smtp.mailfrom=netapp.com; dmarc=pass action=none header.from=netapp.com;
 dkim=pass header.d=netapp.com; arc=none
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=netapp.com;
 s=selector1;
 h=From:Date:Subject:Message-ID:Content-Type:MIME-Version:X-MS-Exchange-SenderADCheck;
 bh=Fnqq5fGPI/1ayAzK4SLvIgjmX6anBXdirKkYYduIz0k=;
 b=eHlkifehifGEwKShotfQx7AG9mWdEHcc/mUnUMAD4O/anb+vCAE0ip2/TNLhVN+BZMlbcafXiWOFiwd3+ZNppFQrmQHkdxCRULpb+w1fV1nGW9NczQfvBI2H9uE5waiJCgg2qN7jjxEiRSK1hRSLb1SzwXoNDS+heBVGte5k//iz2TpsDt90MFYDPgSRjogo+TwuOK4PSHeX0RKr9V6X7ruF3ya0JKkTVZLFDZgkkhNcq7U14u69BqOiaRns0/VffPvepZT3bR6wIVNfkpI6m5h741lmL3/KNgYJwXVhhMWj+SogfLDYg26rJqq4edv1/wawYnuix+aMEivIb0CnIA==
Received: from SA6PR06MB10469.namprd06.prod.outlook.com
 (2603:10b6:806:43f::18) by SJ0PR06MB7082.namprd06.prod.outlook.com
 (2603:10b6:a03:2eb::7) with Microsoft SMTP Server (version=TLS1_2,
 cipher=TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384) id 15.21.360.13; Wed, 2 Sep
 2026 17:58:25 +0000
Received: from SA6PR06MB10469.namprd06.prod.outlook.com
 ([fe80::927c:aeaa:a0b9:a113]) by SA6PR06MB10469.namprd06.prod.outlook.com
 ([fe80::927c:aeaa:a0b9:a113%4]) with mapi id 15.21.0360.008; Wed, 2 Sep 2026
 17:58:25 +0000
From: "Bhargava, Rakesh" <Rakesh.Bhargava@netapp.com>
To: "trondmy@kernel.org" <trondmy@kernel.org>,
        "anna@kernel.org"
	<anna@kernel.org>
CC: "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>,
        "smayhew@redhat.com" <smayhew@redhat.com>,
        "okorniev@redhat.com"
	<okorniev@redhat.com>,
        "Mora, Jorge" <Jorge.Mora@netapp.com>
Subject: Re: [BUG] NFSv3 RDMA :  READ corrupts payload when READ3res omits
 post_op_attr
Thread-Topic: [BUG] NFSv3 RDMA :  READ corrupts payload when READ3res omits
 post_op_attr
Thread-Index: AQHdM+KK4goiASSGVkyTcP6+M8P3aba59z1ogAGp6tE=
Date: Wed, 2 Sep 2026 17:58:25 +0000
Message-ID:
 <SA6PR06MB10469E226BAF748A721101D698BB72@SA6PR06MB10469.namprd06.prod.outlook.com>
References:
 <SA6PR06MB104695205126871E29444567A8BA02@SA6PR06MB10469.namprd06.prod.outlook.com>
 <SA6PR06MB1046983D79F0EAEBDE949C2678BA82@SA6PR06MB10469.namprd06.prod.outlook.com>
In-Reply-To:
 <SA6PR06MB1046983D79F0EAEBDE949C2678BA82@SA6PR06MB10469.namprd06.prod.outlook.com>
Accept-Language: en-US
Content-Language: en-US
X-MS-Has-Attach:
X-MS-TNEF-Correlator:
msip_labels:
Authentication-Results-Original: dkim=none (message not signed)
 header.d=none;dmarc=none action=none header.from=netapp.com;
x-ms-traffictypediagnostic:
	SA6PR06MB10469:EE_|SJ0PR06MB7082:EE_|SJ1PEPF00001CDF:EE_|CO6PR06MB7602:EE_
X-MS-Office365-Filtering-Correlation-Id: 29850bda-6f2f-4e2a-77f3-08df091bd7de
X-MS-Exchange-SenderADCheck: 1
X-MS-Exchange-AntiSpam-Relay: 0
X-Microsoft-Antispam-Untrusted:
 BCL:0;ARA:13230040|366016|1800799024|23010399003|376014|10067099003|3023799007|18002099003|56012099006|4143699003|11063799006|22082099003|38070700021;
X-Microsoft-Antispam-Message-Info-Original:
 c08P0papyRrpDSUpVu3ZA23fin07NCwHRGRtUf9Yympndu196TbyuvJqCqM8+m3sLtwbDxTeUqLbedryy5xZ7SdQFt/TsS1A4/YrWYDlPBG1Mct6cLBdQssJO3urZ+Ti3S62BP2yXBmhqpfQC4VtumxG9SnMKwsHXaNnxeJk98j5tZFxUBiIoVDHxrxEDnuuK4Jzl2HoI+1joTuoKsgNv78V/Ng+d/SULMUR4DNV2iV7RXISUM2aOilt0fAatUcVStzk2WaRACori1VQLylZb4OwmrklC9wOp714P/gfXoTTvcNWyH+gSbizcPzGep6MLKb5+U5As7UOkPKQ8lwDB/Amw8X8C3Lp6J/EpClZrSpsCfnEgXQeZ4b7BNgXV9FSTFeddK0gr9aEuxrEMqq4Ji0ia1VKYyyr17mQSwldCoXELS+ECovO49ocNTnLmlHVpmymb755CJKvePXI7azldx3L+eMcXUBg6K8Ui7h8GNjZBZnPyfk+QCrBizfMyMtl2ENZZt1LeDvlwjbOL5SSux60Gb37LzPtlsblVNmL4RaZBuAG11iJYIFlFR4oggSLh9AnNiIiOo+DWi6FK8i1y7JeElb1YqM1bG3l54++rl4yDPPm6IkDj8H787Xso3waemR/8bDvwkYWfWv1s5HOaF41YMoQB54CncSM5M+VsqkK8GojHm0VLXx6OSJz2tlHnxdCeKv1kkkztE6BOBKVCE/L+lW+OUZ77nIrVi26Oss=
X-Forefront-Antispam-Report-Untrusted:
 CIP:255.255.255.255;CTRY:;LANG:en;SCL:1;SRV:;IPV:NLI;SFV:NSPM;H:SA6PR06MB10469.namprd06.prod.outlook.com;PTR:;CAT:NONE;SFS:(13230040)(366016)(1800799024)(23010399003)(376014)(10067099003)(3023799007)(18002099003)(56012099006)(4143699003)(11063799006)(22082099003)(38070700021);DIR:OUT;SFP:1101;
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
X-Exchange-RoutingPolicyChecked:
 JcUNljv3xfid2dgy/NBxcg2gjjMiHOfEXMRFeK9bWeO2ph5+xdM2UiKuwQPu+Xkcbb27b/H+/OV9pCBhS14TnqKcm+HvMqs75xxfGahPQKW27ClXfWJvoT9zxfOIRRQJZJ7NI2mndGLYGffKE7uXup22REhBfBqC8s7F9HeiYOMs2QVORe2VhJOq7GBh0XFDKqwpu/P0raWaafALi95sk7vLJeZo4vcouZjClWniOOYFcC/6/jsSb2hDmTW0BUBZrcV4r8A5jLT+bhqUHgKwn4yCqUcsU396tAPlTupzNdK7ewl/I2felCf/Cc0ma+BxqF6JcRpS+yRoqcXqUWgO9w==
X-MS-Exchange-Transport-CrossTenantHeadersStamped: SJ0PR06MB7082
X-Zscaler-Block: 0
X-EOPAttributedMessage: 0
X-MS-Exchange-Transport-CrossTenantHeadersStripped:
 SJ1PEPF00001CDF.namprd05.prod.outlook.com
X-MS-PublicTrafficType: Email
X-MS-Office365-Filtering-Correlation-Id-Prvs:
	5034631f-6e09-4cbe-d13b-08df091bc92c
X-Microsoft-Antispam:
	BCL:0;ARA:13230040|35042699022|376014|23010399003|36860700016|1800799024|82310400026|14060799003|11063799006|4143699003|10067099003|56012099006|22082099003|18002099003|3023799007;
X-Microsoft-Antispam-Message-Info:
	odnvGzyv/qqGUFeFYCdpjBOt3PfealTbcNgvJS+buiIxeIu5O+dIagzg0kCEEA7kEXS87KRN5H64o3qrvk0Jt6TN8yRsW7lxxHR8+ejU1Tk4Om9H6E+zEEMe66P4h4fQSX39c56mBmbkdgzvQbG2dnMXNVOE/2WHRlxi5ihgqkE39PXxGYGTUpjG09hZoxv2FAfFXn297lXxohRSzHqonY4lI5SyeE9f5+6o99pPTIXVOPACyuTJy2Pyblzup42HmYlICr8q3BKdAoZljZ3BdQB+JDeRf+T7g3IS3rTT1ytGxT29mVU/EIQapSRq+PBajR90TSSfq/XKMpeMPc/kUN4tCccdBZmOLxalXPdPb5S3ATNvM7U4mNtwArGe3EZXQ8zRKr+fZlQ4tJMYbdqWEqf5nCrWcjusN9eQ9e1yFAgVq5lXMnNZ3AgCuunlDY9qMDccVI49abMI/+khx6GDWfcnPMQXqsVz1cPTgNfacKRSeAXDc0uZQWrU4osAP8DcBm9En0TZiiANu6Tyj9vUMb/d0fcv6kOEY99CtqETrDkXKay8Aml4l6xwFuzTwsR/pCjeya298ZbS0pvy5oUiFWtGpcbNCCFWcJ2UYr7EcUeMTjZj0IiLcus5vhX2fExlJe0W+QJpi9kRVFWsUIfRuTzKw74G7BBpP1uZMeXgvhMsp4/uOUzGi3HQKynXu2+deunRYfHNverBRfyLVPiqzg==
X-Forefront-Antispam-Report:
	CIP:136.226.152.57;CTRY:US;LANG:en;SCL:1;SRV:;IPV:NLI;SFV:NSPM;H:was11a5.mail.zscalertwo.net;PTR:was11a5.mail.zscalertwo.net;CAT:NONE;SFS:(13230040)(35042699022)(376014)(23010399003)(36860700016)(1800799024)(82310400026)(14060799003)(11063799006)(4143699003)(10067099003)(56012099006)(22082099003)(18002099003)(3023799007);DIR:OUT;SFP:1101;
X-MS-Exchange-AntiSpam-MessageData-ChunkCount: 1
X-MS-Exchange-AntiSpam-MessageData-0:
	ns2kvGDF4mydVx5dbdj9DBYqtIsqfuTgO6t6pYdyUuUIn9wrDH+ZVKrv4VIzyDECSB+nx7NIC5TxPNZqB21D6luOoHVLXvvD6otLrsVdSOi5MIW3V1+A4nCV7q0EybnMJUyxwZ+DIhWyFeT7pHDLIQDRZ7rkDADb6UPBXHnEAxR+mGVhqg0ZpjWdKqzDBVYXavoVHyGr34iJGbAb6y28wJmLeweCAVnCGkMM+mi2Uu+1utTp0AR4z9c33iMIMUpzrI38lekSBPAQFhjZVTAHxvYuZKQvYs4Aj2XEsVuIMVbs7NSEn0XXplTBsPYtxpfhtS+YKYExMxOf8SXxxwItprB0Jeosma1UCCPpnFMrfpKjR62K1qb13zeDzgqQiNsoEZz/SphFMDJwrXkcmFKzzaXjND0RMjW0MB1Ub9wxsbhv5fTHPQoM/gD5MGBiP7ZA
X-Exchange-RoutingPolicyChecked:
	PxubBzi96Hdd096nhPxaU6XAY/UuLPfdQChnJhpSlE9V3b8mL/pxbRe0j1kgWINoEnf8vZ8N9FStLmCPm0RAp+3jTqLTQMtFVdcOf7Dbltjjee4RiM087teAxrk6tNLR/+AycgYo40IoSExopAKvtdgZynjgVX9drYQYb6IpNrm4izWIOsph/ZpEA+lXJiAdSEe0PUxxcCqbB06RUgSP+qf4Udtv6+As3B5K3MTy1+buRJV60wlbidxBlSEcKEdv8c8ts1OEzJmYEuGhbIW9auG4thkmBO3ulVm5LN/bc1oq5ufpVcuB+q4L4He+BVvjw0ERy6mAP/04LO/xi1HgkQ==
X-MS-Exchange-AntiSpam-ExternalHop-MessageData-ChunkCount: 1
X-MS-Exchange-AntiSpam-ExternalHop-MessageData-0:
	qKRNHuRY2MI9VkSDFOSCf5IshHgXE0DefYDsJveLR7eepGa1DwGchRqRGo/B7HHw+qriyZ6vdobzklo2etAb4tdRfPAEwQYXJDPG7ycsBYjb48AT6/TFqLzIA19lsGEPHzpp3IdFiRoWA9D2Spo18K686xG1k52MuSj22YrvhUvnf/BD//55aXDVRFDqPYQ1gC+Lxy8yDavSVvl3lGtJKIX2J7ihuEGVU4zqZGT13x00g9fFhIpTh8IiWonOiKAbAA1V0FhRD9MhylwR/rkJxIdNzLMeL8liJi3y0gwxffGXX/Y/HhO++sxSgf0XA/Vb95DD6GGXggC9CNRk6WRD2XY8LtLmSF1hWmauKMpnI7hawWDwdtNWH8H1zt8/pghJgFpP1qMKNcCXfMLN0wg0qPvkomm6fN3P7xeEj/Z1mS4JXgIhfoiQ3ihNbaVvQ4+e5rDx435fQpAdUO7sVTDZIhtmLzhNCEoWfpNUwpC5+QxIcbZGFjQI0ly1c7HKVHotflaOZ2J2SDJCuxSNKS/8KiFyX2j7BmLrY5WAyyFzoF4rF6QTT2AieftcrNrCgAGd9b+DqPPU2lAwcP03Yaqwf5LI7K/vzif4STPrMjLaopib1rcMhmNhjPWPUt6/Nv9y
X-OriginatorOrg: netapp.com
X-MS-Exchange-CrossTenant-OriginalArrivalTime: 02 Sep 2026 17:58:49.6625
 (UTC)
X-MS-Exchange-CrossTenant-Network-Message-Id: 29850bda-6f2f-4e2a-77f3-08df091bd7de
X-MS-Exchange-CrossTenant-Id: 4b0911a0-929b-4715-944b-c03745165b3a
X-MS-Exchange-CrossTenant-OriginalAttributedTenantConnectingIp: TenantId=4b0911a0-929b-4715-944b-c03745165b3a;Ip=[136.226.152.57];Helo=[was11a5.mail.zscalertwo.net]
X-MS-Exchange-CrossTenant-AuthSource:
	SJ1PEPF00001CDF.namprd05.prod.outlook.com
X-MS-Exchange-CrossTenant-AuthAs: Anonymous
X-MS-Exchange-CrossTenant-FromEntityHeader: HybridOnPrem
X-MS-Exchange-Transport-CrossTenantHeadersStamped: CO6PR06MB7602
X-Proofpoint-Spam-Info: AW1haW4tMjYwOTAyMDE1OCBTYWx0ZWRfX3Xaf2m6ACJmM
 ZkJUjlVRN1cGH0ctPcXhHkOZJiBGc8c9r9C9nMcvsuvQ76CbS/rUyzY9UwTJfTqP2MQtp8lwAd5
 z5tmh078uyys5EG0o+8mj1kXiHo3p+0=
X-Proofpoint-Spam-Details-Enc: AW1haW4tMjYwOTAyMDE1OCBTYWx0ZWRfX2RnedSpxdK9U
 oaiawk2Pi9emgHcrkirWRH00Kyiudnq0N6xO1RISnYtXhb5vwKO6bIsdloB0KQDGe0lRcrCPjEQ
 kpuqvga9CFYZFeHMgDN29cwj8NPzSpLoLpE5UZOGGhBKtMl2BCPGhwAvUz+rgHIEq1LX19AR5GR
 68CiRQsPhPt9Vzg9auUNriWXfvxHwwjxUyEwJvYv1lQ7A+f311ydfceBzr/ht7eyioiS4cXV7R0
 gH6b0GPmZ0ZZN8kCnC6nLTtktxGVI2+YmjUJmRt/iE3FcpU/RKSvcAhlx2qvdHPpY/hc7SPypU+
 zzGvMv/jeA21N+IENVZbYfbU59Y5cdtl7/AGS2Vj0IwRH8xl4Qr1O4/gl/Jp74iz5fBRdjAzeiA
 uQ7VzHTqCTkEG4hrM2crA0SvdBwAko9t9AGRPgI2mB5gjbjzltJOum9CVLdDEpKxvJg4wMpOJPe
 /qGt8tKak1NIfWWSuNw==
X-Proofpoint-ORIG-GUID: kyBdhoouHXLQ4xfzcUGK1EcjoDyAcvSi
X-Proofpoint-GUID: kyBdhoouHXLQ4xfzcUGK1EcjoDyAcvSi
X-Authority-Analysis: v=2.4 cv=NY3WEWD4 c=1 sm=1 tr=0 ts=6a9863de cx=c_pps
 a=zWRuVz0++A3eh/KBGeICZg==:117 a=y2qyX5seKirFBAuOJ2n+PQ==:17
 a=6eWqkTHjU83fiwn7nKZWdM+Sl24=:19 a=lCpzRmAYbLLaTzLvsPZ7Mbvzbb8=:19
 a=xqWC_Br6kY4A:10 a=8nJEP1OIZ-IA:10 a=VdqzKS8jKosA:10 a=GWG4Yq0kndkA:10
 a=VkNPw1HP01LnGYTKEx00:22 a=1lWG0UuNQvn8UhQ8Wh4S:22 a=X7e-fZ-CKB32rjcIpVUG:22
 a=JDjsHSkAAAAA:8 a=VwQbUJbxAAAA:8 a=20KFwNOVAAAA:8 a=kYXF6sJWGlpfHcJRSCYA:9
 a=wPNLvfGTeEIA:10 a=dseMxAR1CDlncBZeV_se:22
X-Proofpoint-Virus-Version: vendor=baseguard
 engine=ICAP:2.0.293,Aquarius:18.0.1176,Hydra:6.1.134,FMLib:17.12.100.49
 definitions=2026-09-02_04,2026-09-02_04,2025-10-01_01
X-Proofpoint-Spam-Details: rule=outbound_notspam policy=outbound score=0
 adultscore=0 clxscore=1015 bulkscore=0 suspectscore=0 priorityscore=1501
 phishscore=0 lowpriorityscore=0 impostorscore=0 malwarescore=0 spamscore=0
 classifier=typeunknown authscore=0 authtc= authcc= route=outbound adjust=0
 reason=mlx scancount=1 engine=8.22.0-2606150000 definitions=main-2609020158

Please ignore the mail.=0A=
I missed the patch mail which fixed the issue.=0A=
=0A=
Regards,=0A=
Rakesh=0A=
=0A=
________________________________________=0A=
From: Bhargava, Rakesh <Rakesh.Bhargava@netapp.com>=0A=
Sent: Tuesday, September 1, 2026 22:03=0A=
To: trondmy@kernel.org; anna@kernel.org=0A=
Cc: linux-nfs@vger.kernel.org; smayhew@redhat.com; okorniev@redhat.com; Mor=
a, Jorge=0A=
Subject: Re: [BUG] NFSv3 RDMA :  READ corrupts payload when READ3res omits =
post_op_attr=0A=
=0A=
Hi,=0A=
Any update on this..?=0A=
=0A=
Regards,=0A=
Rakesh=0A=
=0A=
=0A=
________________________________________=0A=
From: Bhargava, Rakesh=0A=
Sent: Monday, August 24, 2026 21:37=0A=
To: trondmy@kernel.org; anna@kernel.org=0A=
Cc: linux-nfs@vger.kernel.org; smayhew@redhat.com; okorniev@redhat.com; Mor=
a, Jorge=0A=
Subject: [BUG] NFSv3 RDMA :  READ corrupts payload when READ3res omits post=
_op_attr=0A=
=0A=
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
Rakesh=0A=

Received: from mx0b-003fbd02.pphosted.com (mx0b-003fbd02.pphosted.com [67.231.157.221])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id A687D34AAE9
	for <linux-nfs@vger.kernel.org>; Tue,  1 Sep 2026 16:45:02 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=fail smtp.client-ip=67.231.157.221
ARC-Seal:i=3; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1788281105; cv=fail; b=IwbmO1y50gNK4iMQWTDbdnJuNEOd2D/FsQklvjSFw/xYr/zTekl3KwVOOn5IL3qoS8XfvRdsxIyKscuxiOVnrW1kQeBiUMoIcpnPX1HiH3J45XmAQogUSdDIHR/4u3MoAxBgozof8AItZZlfub8m9oZTqV37WW7bbAks5rKivSo=
ARC-Message-Signature:i=3; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1788281105; c=relaxed/simple;
	bh=kFYzBV8THSuGVr9MGdHIE8J6mlRgkhIQRQrW0tOJGkM=;
	h=From:To:CC:Subject:Date:Message-ID:References:In-Reply-To:
	 Content-Type:MIME-Version; b=P5GiuM3W6wCjxCTtidl//Ng9QzsdqjuZ0b1tfHRinQQUQk0hBQAHSIoqK0WdQVqiXKY5l0TIq4ZCbFAi2AfkFXZk2qi1tYP3wVldy1sYgrHMu+XGnbqmLCmy2S33CWsKqftMhrlKhquhco+L305btU4OXDRW3YYDMMHlitB9dcI=
ARC-Authentication-Results:i=3; smtp.subspace.kernel.org; dmarc=pass (p=reject dis=none) header.from=netapp.com; spf=pass smtp.mailfrom=netapp.com; dkim=pass (2048-bit key) header.d=netapp.com header.i=@netapp.com header.b=VtATXgdg; dkim=pass (2048-bit key) header.d=netapp.com header.i=@netapp.com header.b=xbGRbEG3; dkim=pass (2048-bit key) header.d=netapp.com header.i=@netapp.com header.b=xbGRbEG3; arc=fail smtp.client-ip=67.231.157.221
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=reject dis=none) header.from=netapp.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=netapp.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=netapp.com header.i=@netapp.com header.b="VtATXgdg";
	dkim=pass (2048-bit key) header.d=netapp.com header.i=@netapp.com header.b="xbGRbEG3";
	dkim=pass (2048-bit key) header.d=netapp.com header.i=@netapp.com header.b="xbGRbEG3"
Received: from pps.filterd (m0412383.ppops.net [127.0.0.1])
	by mx0b-003fbd02.pphosted.com (8.18.1.11/8.18.1.11) with ESMTP id 681ESZK43074009;
	Tue, 1 Sep 2026 16:33:08 GMT
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=netapp.com; h=cc
	:content-transfer-encoding:content-type:date:from:in-reply-to
	:message-id:mime-version:references:subject:to; s=pps1; bh=QTBt8
	I7AtgzH0UnObuWZCL9TRM+eE20LwNIoZX5EfQM=; b=VtATXgdgIjrE094aYB3oc
	G0Y/pa3DZ8++X+uKRxGUa8OnICOYgy+4V2p391JtckamKojKc+LIszfOXCWWgbq4
	EoZ+OLOoThy54JE5BDpFsdCUbCTkKLTG02pvO5SUmA1lMLwsie7DLTEVt7OuLHKY
	89AVcyfG8VXr8ror2LcaONAzOIbrmEe2LTC+YbrnudGWaBOa4u7aB083XGwAeYzf
	g7cI1XmB1wgLHy7fZc2hia2WKdgr4ASVTNfL7ujM74fTkfz8inwXJepJAzoJlwcw
	g7d5+ypIi8Ht7beLmXQLqeIo8ZgOC4VwFzYF0Q5Xo6ywH7lzituoMZZeBlVX/Z6X
	w==
Received: from dm5pr21cu001.outbound.protection.outlook.com (mail-centralusazon11011046.outbound.protection.outlook.com [52.101.62.46])
	by mx0b-003fbd02.pphosted.com (PPS) with ESMTPS id 4gdwucsd10-1
	(version=TLSv1.3 cipher=TLS_AES_256_GCM_SHA384 bits=256 verify=NOT);
	Tue, 01 Sep 2026 16:33:08 +0000 (GMT)
ARC-Seal: i=2; a=rsa-sha256; s=arcselector10001; d=microsoft.com; cv=pass;
 b=DulS8ZBz/qIxZaHkHfrQgFWAgucHxDqIEEcVtUG0RYJIW+mJ2iXSIIs+2t/oE0cOP2/DlAI3rrURAE+eAqzphJIxJo6BXf8zhaMUl5oA2O+zwTZY8hD1SmLgX0ZE7Bdyj8bp96aC5P+399Nd04fJcaN8PUzohmyoC8EH9cJuwVjqc9cxFGSHTrM3K0mzoFlvU7sNJtpw3uNleVMa2rEyN9fDYz4pzyCkjrx5fbS3nDSkapBAu7OSlbet41oDWIXyDseBWld+HvbsGv3aAPFDjPJla3MvZKcZgVDLjw4jkF9jPD+oJXqtFLsNWCy4tylNlmywyYnWeSGVGOWE8qxYkg==
ARC-Message-Signature: i=2; a=rsa-sha256; c=relaxed/relaxed; d=microsoft.com;
 s=arcselector10001;
 h=From:Date:Subject:Message-ID:Content-Type:MIME-Version:X-MS-Exchange-AntiSpam-MessageData-ChunkCount:X-MS-Exchange-AntiSpam-MessageData-0:X-MS-Exchange-AntiSpam-MessageData-1;
 bh=QTBt8I7AtgzH0UnObuWZCL9TRM+eE20LwNIoZX5EfQM=;
 b=ER2CkBPicH8QEraa7tcqodTgQO77C3gb2RDSabK9vJi2+S+X55/Q1vNGpQF8AiW0f2icDsmFlzl1ZyHlx8VgcXH6R844suRRgxx4cZzpzAOkRbTLUD1pdUCNqfZopDJnYbMSveeBfRc9G2hnu2XV05KrzLcbNH6h0ixCdKnHdjo7xdxyqhHkKK4K5DoEeybUsAgnxfINZUOdLPJIc4kP8tYd1HXyZlZ60zsZFt5pIlrlxId2QGFHmMOgDjkuVt35DAYqVhDHUzcJiefsHYsrNBZVYVW8/17O8BXaorGIkBdelw5pyvWuDOd8W59Ixe1hJ/3YVHjd404syLWW8aiQiA==
ARC-Authentication-Results: i=2; mx.microsoft.com 1; spf=fail (sender ip is
 136.226.142.111) smtp.rcpttodomain=vger.kernel.org smtp.mailfrom=netapp.com;
 dmarc=pass (p=reject sp=reject pct=100) action=none header.from=netapp.com;
 dkim=pass (signature was verified) header.d=netapp.com; arc=pass (0 oda=1
 ltdi=1 spf=[1,1,smtp.mailfrom=netapp.com] dkim=[1,1,header.d=netapp.com]
 dmarc=[1,1,header.from=netapp.com])
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=netapp.com;
 s=selector1;
 h=From:Date:Subject:Message-ID:Content-Type:MIME-Version:X-MS-Exchange-SenderADCheck;
 bh=QTBt8I7AtgzH0UnObuWZCL9TRM+eE20LwNIoZX5EfQM=;
 b=xbGRbEG3mvK4PZpcgc6AaVJXRGhe2BGlxo3UG6QyxnNH7hcoEiRDqtdpLnekI2eSxq0EezgbHPqwYsg4OSucGZr8wLzECfLRmyGINV6rAZcHAuhwoQ3eT6/lcR3U85rBUcQpoFQwk8/EtSKHm1hB0m9f2zbjYSdsCuo3gA0xNMlGWRi5YMX604lzPqN3R/EQMofRewt8iPjukKfUwPNkxZ7hMCowUcK34o8YjWVMBZfEi4bMGAY284j2QUarDXOh2em0+HqZP1pRa2enyS07q1Y0+bWUI05ritJzBF5KmNOywqUeg1M4BrqgANpsdZov4JNhnBrTuGY8TOAe2w9CYw==
Received: from BL1P221CA0029.NAMP221.PROD.OUTLOOK.COM (2603:10b6:208:2c5::25)
 by MN6PR06MB10504.namprd06.prod.outlook.com (2603:10b6:208:4fe::18) with
 Microsoft SMTP Server (version=TLS1_2,
 cipher=TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384) id 15.21.360.13; Tue, 1 Sep
 2026 16:33:05 +0000
Received: from BN3PEPF0000B373.namprd21.prod.outlook.com
 (2603:10b6:208:2c5:cafe::62) by BL1P221CA0029.outlook.office365.com
 (2603:10b6:208:2c5::25) with Microsoft SMTP Server (version=TLS1_3,
 cipher=TLS_AES_256_GCM_SHA384) id 15.21.360.13 via Frontend Transport; Tue, 1
 Sep 2026 16:33:05 +0000
X-MS-Exchange-Authentication-Results: spf=fail (sender IP is 136.226.142.111)
 smtp.mailfrom=netapp.com; dkim=pass (signature was verified)
 header.d=netapp.com;dmarc=pass action=none header.from=netapp.com;
Received-SPF: Fail (protection.outlook.com: domain of netapp.com does not
 designate 136.226.142.111 as permitted sender)
 receiver=protection.outlook.com; client-ip=136.226.142.111;
 helo=sjc41b2.mail.zscalertwo.net;
Received: from sjc41b2.mail.zscalertwo.net (136.226.142.111) by
 BN3PEPF0000B373.mail.protection.outlook.com (10.167.243.170) with Microsoft
 SMTP Server (version=TLS1_3, cipher=TLS_AES_256_GCM_SHA384) id 15.21.406.1
 via Frontend Transport; Tue, 1 Sep 2026 16:33:04 +0000
Received: from dm2pr04cu003.outbound.protection.outlook.com ([40.93.13.57])
	by sjc41b2.mail.zscalertwo.net ([136.226.142.95])
	with ESMTPS id 6A96FE3F08C10000;
	Tue, 01 Sep 2026 09:33:03 -0700
ARC-Seal: i=1; a=rsa-sha256; s=arcselector10001; d=microsoft.com; cv=none;
 b=cl1zGnu3ozOjLv3RByVBaetcWxK84BpzvVTgECoLu6+zHL1clUmrfKOnMEAFzkLTUVj63DkKc+QBptwq5nAXDoGKTC7UQY0Dq+Gql+niflzl8DsFlKyip0l1koo+O+PMiM61TIZ0HnbP9N/uyQo2KQLox4DJubosN5TN6xyueLvJGLe/qu2RnkcrC/Ycmlt6LS4+xlm3iurxoqzJ2KEZN+urss0dSjWY3MI3fShXxxaiaRyU8FPpReMFBSQ/4VJZpZxvyk3cPDdlJOh9yOaChUhPS/kANfkLLDhY3PZeDE8QDxSB6pnlDLMKsi6zfYtfJHbr9qEAJ59fjAk4km8/Kg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=microsoft.com;
 s=arcselector10001;
 h=From:Date:Subject:Message-ID:Content-Type:MIME-Version:X-MS-Exchange-AntiSpam-MessageData-ChunkCount:X-MS-Exchange-AntiSpam-MessageData-0:X-MS-Exchange-AntiSpam-MessageData-1;
 bh=QTBt8I7AtgzH0UnObuWZCL9TRM+eE20LwNIoZX5EfQM=;
 b=omBjUL3F0jijlInp07YPkIDdQDH0wrxdEXkE7VpFyQvQpLQh70W+n49TxXr+b9UjDtTF1Fr3eOCkiUXDDzNPNkREMkz/yxHujGL9Fh+SXyBXPkP+N+78FlNhnLqNIh2fINCCAVHrVzGHTCC/a9ru7slTJMkR0kk9g63NEnnrJsyJv9UMH81GpX4a8y0jR58I6pR77m5QjX9Ope7UaGwjFa/xWgo69VMaw9IEtdRjuleWc3wOdzbcmBlOXh/KomXasbwhZ51bTg+QcTHfxE6zczAjzkAbkZjXEz/o/NRZrNh6pcrB50TKE6vz+Lw7z0kg+ZzJYJWaGmAruRJjU0D/cA==
ARC-Authentication-Results: i=1; mx.microsoft.com 1; spf=pass
 smtp.mailfrom=netapp.com; dmarc=pass action=none header.from=netapp.com;
 dkim=pass header.d=netapp.com; arc=none
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=netapp.com;
 s=selector1;
 h=From:Date:Subject:Message-ID:Content-Type:MIME-Version:X-MS-Exchange-SenderADCheck;
 bh=QTBt8I7AtgzH0UnObuWZCL9TRM+eE20LwNIoZX5EfQM=;
 b=xbGRbEG3mvK4PZpcgc6AaVJXRGhe2BGlxo3UG6QyxnNH7hcoEiRDqtdpLnekI2eSxq0EezgbHPqwYsg4OSucGZr8wLzECfLRmyGINV6rAZcHAuhwoQ3eT6/lcR3U85rBUcQpoFQwk8/EtSKHm1hB0m9f2zbjYSdsCuo3gA0xNMlGWRi5YMX604lzPqN3R/EQMofRewt8iPjukKfUwPNkxZ7hMCowUcK34o8YjWVMBZfEi4bMGAY284j2QUarDXOh2em0+HqZP1pRa2enyS07q1Y0+bWUI05ritJzBF5KmNOywqUeg1M4BrqgANpsdZov4JNhnBrTuGY8TOAe2w9CYw==
Received: from SA6PR06MB10469.namprd06.prod.outlook.com
 (2603:10b6:806:43f::18) by PH0PR06MB999913.namprd06.prod.outlook.com
 (2603:10b6:510:11b::8) with Microsoft SMTP Server (version=TLS1_2,
 cipher=TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384) id 15.21.360.13; Tue, 1 Sep
 2026 16:33:01 +0000
Received: from SA6PR06MB10469.namprd06.prod.outlook.com
 ([fe80::927c:aeaa:a0b9:a113]) by SA6PR06MB10469.namprd06.prod.outlook.com
 ([fe80::927c:aeaa:a0b9:a113%4]) with mapi id 15.21.0360.008; Tue, 1 Sep 2026
 16:33:01 +0000
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
Thread-Index: AQHdM+KK4goiASSGVkyTcP6+M8P3aba59z1o
Date: Tue, 1 Sep 2026 16:33:01 +0000
Message-ID:
 <SA6PR06MB1046983D79F0EAEBDE949C2678BA82@SA6PR06MB10469.namprd06.prod.outlook.com>
References:
 <SA6PR06MB104695205126871E29444567A8BA02@SA6PR06MB10469.namprd06.prod.outlook.com>
In-Reply-To:
 <SA6PR06MB104695205126871E29444567A8BA02@SA6PR06MB10469.namprd06.prod.outlook.com>
Accept-Language: en-US
Content-Language: en-US
X-MS-Has-Attach:
X-MS-TNEF-Correlator:
msip_labels:
Authentication-Results-Original: dkim=none (message not signed)
 header.d=none;dmarc=none action=none header.from=netapp.com;
x-ms-traffictypediagnostic:
	SA6PR06MB10469:EE_|PH0PR06MB999913:EE_|BN3PEPF0000B373:EE_|MN6PR06MB10504:EE_
X-MS-Office365-Filtering-Correlation-Id: 1cbea3ab-3f53-4e1e-a74c-08df0846b2df
X-MS-Exchange-SenderADCheck: 1
X-MS-Exchange-AntiSpam-Relay: 0
X-Microsoft-Antispam-Untrusted:
 BCL:0;ARA:13230040|376014|1800799024|23010399003|366016|38070700021|3023799007|10067099003|11063799006|56012099006|18002099003|22082099003;
X-Microsoft-Antispam-Message-Info-Original:
 KS9S8XZnaMqeEugWfhAegie0J/8JY7zcO3zN0nF3M3bznmCcXqM2aQ4sb6DMpKFS+joyhtUuWGfxOuYWZDMixQOjk1qVO6Z2ENMgNvrCT3pMZYveFTfTtGM9ZRG6bYZlWjrJMTaU+qXxboUXjbW9asBRwyU3a63Xnrwbw5Y2/tQmO4pKa+GulwCVGH5907Iin04iwgqkeEbQfml3elTamMF+ASszlOqEsBRg/m0jBdG4/6x/oYQghx2Eqgg4CB7Juonb3EjNmEMrfmTy9j+XueMye5oGF3yRdqnGv07qLkH8niMURBtq6A1G4fKNIV3S/mzlsvHB4VTwxHVHDckRPR++Tp5ZWsDaMo4qGwpLQV6sNN1ftxndkoQitUny0Sz91WYxUgBUHhNEiBQQNGBs01Al6e6Auct2wmudyV0FL+MwPBTriqwrRKWm2hCP1xSPkb7/DUDSwOA0vPRsSq01xNksST2w1aestIrVcuVYeY5oLhKpQBLP2cd52Zuek1tk3lgof95amJUOObFLloQYpzPAVWUV4gYXC8GIr9Y88y2J7L2eu5lNhr+rkoym6wfXANg4ruJJCFsS9G653fx55sV2t/zCxcXGzrKdvhyA39oLK1FKw9U2N3wmbQCZFv/t7NJQtwb4dawbLjpwnHJH3zJ04+skg13KjExnCkMkCIUQ6PefAR512TCvG5Q/qJitZ8JZzg3tFrl6dZ/CKwyNMz923h/0WeUtvcW78XtrM1g=
X-Forefront-Antispam-Report-Untrusted:
 CIP:255.255.255.255;CTRY:;LANG:en;SCL:1;SRV:;IPV:NLI;SFV:NSPM;H:SA6PR06MB10469.namprd06.prod.outlook.com;PTR:;CAT:NONE;SFS:(13230040)(376014)(1800799024)(23010399003)(366016)(38070700021)(3023799007)(10067099003)(11063799006)(56012099006)(18002099003)(22082099003);DIR:OUT;SFP:1101;
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
X-Exchange-RoutingPolicyChecked:
 gpKuMtVN4AB1z6f+bFIOa8fVxzD9C7HwUomn6RoQIReOHOwVX8CYTojQxXUhfbmgXbzfFvHqT0s9NuM29f+huopTP+a4jsX2T1eoR3LUnz3Tj5iZ9UpBzZ8jh5IO0vuIgUrxZE0IwH2B48NJ3fgSmoAoHnW4oM1d2bdhlm269vrs6S1thTzzbC18on00pIhvpF5uFQxSKhlSGZbC6P0ennlqkpNdaO8TfA/OWFSEDJ7P+sbJ6j7NktQWxA48VEscF6C9T1IzHgYzYupP+MUpy6KLy1LJ09ru4mR6WGfBRFMcNi0U1jtQU00fPeEevX7XOlY1Y/33RFXoZz6S7GpbuA==
X-MS-Exchange-Transport-CrossTenantHeadersStamped: PH0PR06MB999913
X-Zscaler-Block: 0
X-EOPAttributedMessage: 0
X-MS-Exchange-Transport-CrossTenantHeadersStripped:
 BN3PEPF0000B373.namprd21.prod.outlook.com
X-MS-PublicTrafficType: Email
X-MS-Office365-Filtering-Correlation-Id-Prvs:
	7ffb7549-27df-4b0a-1eaf-08df0846b0df
X-Microsoft-Antispam:
	BCL:0;ARA:13230040|35042699022|1800799024|36860700016|82310400026|23010399003|376014|14060799003|22082099003|18002099003|11063799006|3023799007|56012099006|10067099003;
X-Microsoft-Antispam-Message-Info:
	QuH0sV+UtalM/ptUA8pN/omOxYfFa0vgMpEGktkYNR+PzN6YP+PhS/dAqeVViYAoMrP5MzgCvAR0x2fltrZilavgHSOm2342CgYiP6jdYIxIi8OE+BplmQnY5Kk9ZReN3YhklPTnEiSqIQB8ui9bNUsyYkXb8EIg23JlRBbuzgHVXGelv/h6zam+Jqv2Z8Kx89FxX7jTkijkkjkpqFp1vyV5C4J38G4ZiAM9cTNTF2dWFAgAwAiNuSRh7XLcs9g8JdxozYrb2/ETpEXEioVeyLxziTIaF3V7aLXOdNPb5F1wWqWTS0DkMcCky3tvdf1iZy/2qdK/z+ydSbAVwJu6K6JCSneh8ZzM2VyzsNKKxZ+cp2pt3Q+CO9M7e4EcawfpppfUXe1Kk4SWt0t1ZttTzdx1ezOcPzNc9Nmpio/kn0hs1h4bI/ihvNIXu7X7nhfJZzNvbEHmEYihzQ/2+5+i3v0FJdpiRTKp4QNNGDxwV54E6mOqQ1Plq8OUMVBXeqciuPTUEYAyqOhHeIZREluQVKSSgIwoqd9AcfTUVH7PWLlg+6J36Oc8j7XpGGMSOtKGZD13X6/mZ0W3Alh9yhHQlKIwEvBcROetTopU5Y2cSIaxwQltuPwe8PiT//s5hNB1yqsSif/VFIV4qUu8HAFfwkUIgVmCpDQ7YjHTtd3uBp0=
X-Forefront-Antispam-Report:
	CIP:136.226.142.111;CTRY:;LANG:en;SCL:1;SRV:;IPV:NLI;SFV:NSPM;H:sjc41b2.mail.zscalertwo.net;PTR:sjc41b2.mail.zscalertwo.net;CAT:NONE;SFS:(13230040)(35042699022)(1800799024)(36860700016)(82310400026)(23010399003)(376014)(14060799003)(22082099003)(18002099003)(11063799006)(3023799007)(56012099006)(10067099003);DIR:OUT;SFP:1101;
X-MS-Exchange-AntiSpam-MessageData-ChunkCount: 1
X-MS-Exchange-AntiSpam-MessageData-0:
	ejdKcsU6E2+WJ58hyrz+xHEoCC+n8ENdvmYwMks8VHIvJdCN//0KoPvm7eUFSaMuJVrwmsZbDhdbYB1D6WmW2PfQiF2BsWCWzFf+SZdt1oYDwvJosmVM3it/DCPwLeZH75SDyeeFnfM56m6PGlZq1S3PFe+62s+826weR4RgoEK7jPhk/KPm74C6Gi3WApV9dmsf8tgWNoXcK4h1Oi62jz+Em906UGTZT42/DRtjoj37o9vPcc5f+j76TUKgeAZJjz3vEl2C3R82U2jfZSbSy0qTmrN5RgvtwMk3tTSAYIj53fg594cMbAYsi3uIhsnrQpAEISCyF4njC5dTcz4Lde27zkXSj3+nRwfM8qf5nSm7JSP6nbFJsdCjLHMpSVQMI5bnqVAhocTzCD/Hkb/bJi1bVaTOQ2oxOBTzfFr82Qkk4n0AXKhQ+jTCCItM4HLM
X-Exchange-RoutingPolicyChecked:
	LLXdFOp8h43fWYdUq1tVS9v4gdviwo78aHmH/CGwg63vizOzMtll+SN4phEMrvzZiwa4FLTJeAoEV7bwkvoSDFKSTlJ/YvK/E/m/qC9RSktWRu/oNX1Cc5Xhlhu1K6aF3a1fLxaN8Xgu/oGlqG2/wMVRhePUt6kUokazdmkJWxABDnnJ8t2HorxMVLXG+cYErpblm+4jhOCsai6zHogbPojVO9breK0YmxqSrgIjzuohQf6jYJqQIsjCIKYhFcZBdsIUHLfMFt4vMimwLUJExKnU/U7seOh57HAM5IibAutG+u92ftvgzeNV55cajnxps48XW1y49nVAoVnmo52xhQ==
X-MS-Exchange-AntiSpam-ExternalHop-MessageData-ChunkCount: 1
X-MS-Exchange-AntiSpam-ExternalHop-MessageData-0:
	HRVY0vrzwc1N0ofan4ppMmyjY+JqP+Y4tD8rJnWWeoE1ERCmnWUeWIqZGZ+v6nevvdlvdbFPXMVutgw3t/duZrM93ltY6xtQOEwIM3HWZ+3+RKHy8JUm+DBfLZxGCshDwhjctqGFY0meSdDDc8O9c1A87U8ITqDX6H7MMejvoPdOfEXhdVoGhYxKMh0RsEagE3ZhYUXiqaz4D+g/UmSAplYRr/2F85bME/5bhmpnSs5+LGDmJ0h8CTg/axzflIQQZb0gR4IecdAFfLlyvrmO9xSpm7UrWQkpekyGWYMKmQ79uv2a6uJXizuOYaHEYPDGvckAT4L+JbYdr2jKm+pDcU3ITufSn8oc2Q8Aava4+OQ2uOUdacCLYO3fn9Eo84KAQWERlEh6EDEKEQwoCv/gyddRUQLKC2bv96xlmxhHJDOZeLeyRJPW96XcdXKFBYDw8op3VqoAEUghYAzDMQPFUhLZ/blZeaECxpFnnbY8cimutUdbHpy3zfOaU++noxTueUOeCPiNN59OI+k2WA/lf7SbE1L6zler0pAGdptbMYz7T6hquk7in/qqXh89/KuWIOWA4zZ4Zg3maQJzLf6hx2XpHChXv7P2vbAxfy+v3F3HPBBP2bME0AaeBN/zyZnx
X-OriginatorOrg: netapp.com
X-MS-Exchange-CrossTenant-OriginalArrivalTime: 01 Sep 2026 16:33:04.8223
 (UTC)
X-MS-Exchange-CrossTenant-Network-Message-Id: 1cbea3ab-3f53-4e1e-a74c-08df0846b2df
X-MS-Exchange-CrossTenant-Id: 4b0911a0-929b-4715-944b-c03745165b3a
X-MS-Exchange-CrossTenant-OriginalAttributedTenantConnectingIp: TenantId=4b0911a0-929b-4715-944b-c03745165b3a;Ip=[136.226.142.111];Helo=[sjc41b2.mail.zscalertwo.net]
X-MS-Exchange-CrossTenant-AuthSource:
	BN3PEPF0000B373.namprd21.prod.outlook.com
X-MS-Exchange-CrossTenant-AuthAs: Anonymous
X-MS-Exchange-CrossTenant-FromEntityHeader: HybridOnPrem
X-MS-Exchange-Transport-CrossTenantHeadersStamped: MN6PR06MB10504
X-Proofpoint-Spam-Info: AW1haW4tMjYwOTAxMDE0NiBTYWx0ZWRfX0ukax3NPLMol
 6qXoq80hPSBVHNDK+bYHaq3890cHzfIOWxPJ9K7sNnmOvxM62s23uDaMPqhrWYijZiwGjVHJRDk
 pqUZJPptUZVQS4HewPyYk0J23KC8GaI=
X-Proofpoint-Spam-Details-Enc: AW1haW4tMjYwOTAxMDE0NiBTYWx0ZWRfX8g6LIyGXDy7k
 T2qX/97U9L0Kw5WcmsCGX83D36nfO3GLxqfl0FRJJ4ktJcBuO82ejkZ/4Ni+13N4QJ6p429bJf8
 qDg7l7w8uCFeVQNn4yKla1m8CT7FJnOZURzrIBDkgiyQLvJe436LKHt5MMthwqoJ5EWT2JSNKUR
 6FzTzM4xhtSWBjLGRe3VfGCnWDzFkbpdqSWPSn6HHwlSzc7Hb3LcG5vmv00QB3R+WVHgorZB0Jz
 BHDGUIRWtKcGLKQi4RRwky9A1Xqb4QRepLg3bYHMG1R5E8+PI4+MfVBHJSJmJavQpvr5l+6c9bp
 V9DL4hEQcEti9dZbvC8eilbM+AYAkr18Y4FCpC5XBmpYCKpu7VDzv0lXqfkPIV8qomNTJP4Smrh
 9RzREGZdL6wqKY7RzWDcOAGUQgFmNaMZMw6WSekeNhEPaKKRA1OgLHDyQuWd+4xFUkMkeLuKD6y
 cqfHn9TE7xv1OQqzgpQ==
X-Proofpoint-ORIG-GUID: ogzF1eqxYa0Vz27U5XvjhVOdtkz8MCj6
X-Proofpoint-GUID: ogzF1eqxYa0Vz27U5XvjhVOdtkz8MCj6
X-Authority-Analysis: v=2.4 cv=NY3WEWD4 c=1 sm=1 tr=0 ts=6a96fe44 cx=c_pps
 a=m/LAOfpIcXRJv0ug5Ru3ZQ==:117 a=1cKNBmr56ioqABmsJRZnaw==:17
 a=6eWqkTHjU83fiwn7nKZWdM+Sl24=:19 a=lCpzRmAYbLLaTzLvsPZ7Mbvzbb8=:19
 a=xqWC_Br6kY4A:10 a=8nJEP1OIZ-IA:10 a=VdqzKS8jKosA:10 a=GWG4Yq0kndkA:10
 a=VkNPw1HP01LnGYTKEx00:22 a=1lWG0UuNQvn8UhQ8Wh4S:22 a=X7e-fZ-CKB32rjcIpVUG:22
 a=VwQbUJbxAAAA:8 a=20KFwNOVAAAA:8 a=eQ06qM7Koufcy8VxZZ8A:9 a=wPNLvfGTeEIA:10
X-Proofpoint-Virus-Version: vendor=baseguard
 engine=ICAP:2.0.293,Aquarius:18.0.1176,Hydra:6.1.134,FMLib:17.12.100.49
 definitions=2026-09-01_04,2026-09-01_02,2025-10-01_01
X-Proofpoint-Spam-Details: rule=outbound_notspam policy=outbound score=0
 adultscore=0 clxscore=1015 bulkscore=0 suspectscore=0 priorityscore=1501
 phishscore=0 lowpriorityscore=0 impostorscore=0 malwarescore=0 spamscore=0
 classifier=typeunknown authscore=0 authtc= authcc= route=outbound adjust=0
 reason=mlx scancount=1 engine=8.22.0-2606150000 definitions=main-2609010146

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

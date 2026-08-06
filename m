Received: from GVXPR05CU001.outbound.protection.outlook.com (mail-swedencentralazon11013027.outbound.protection.outlook.com [52.101.83.27])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 4D3F4330328
	for <linux-nfs@vger.kernel.org>; Thu,  6 Aug 2026 11:20:30 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=fail smtp.client-ip=52.101.83.27
ARC-Seal:i=2; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1786015232; cv=fail; b=PX2Is48vsL6SaKP/jTnTUAVF6y1ioNqyLQ7KGCYQOzZd3OgdsoB4GIFAL/O4poBQywotLxUJPyjs+ujTZJzcULOANrGXgltnRP+9e/it7Rabqyz4G0ymWEXQmtgMWD/lfL6t/yHx3r7Ci3D62nyZ3YVWbspXIMGJF0lyTVer5Z8=
ARC-Message-Signature:i=2; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1786015232; c=relaxed/simple;
	bh=Lga3h41ooeFwjLywz/5xZoPeAJy75D99aS2jDuZalM8=;
	h=From:To:Cc:Subject:Date:Message-Id:Content-Type:MIME-Version; b=Eg7cMz179KDBh7f51+C61c2N+s7JHVkeIAAyJdRdE+fwsdnIymvpeBCr6Vt5DbmrS1QHVZikzppWMZAa5tsp6le0dPzVkC1AD9xL9dSL66b3PgmubItLtFK2EM9U5ElRJSf/26sNiBnV5EuRHrosifE20ZlS39suatKe5d7yIxY=
ARC-Authentication-Results:i=2; smtp.subspace.kernel.org; dmarc=none (p=none dis=none) header.from=est.tech; spf=pass smtp.mailfrom=est.tech; dkim=pass (2048-bit key) header.d=est.tech header.i=@est.tech header.b=e+HTWqLX; arc=fail smtp.client-ip=52.101.83.27
Authentication-Results: smtp.subspace.kernel.org; dmarc=none (p=none dis=none) header.from=est.tech
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=est.tech
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=est.tech header.i=@est.tech header.b="e+HTWqLX"
ARC-Seal: i=1; a=rsa-sha256; s=arcselector10001; d=microsoft.com; cv=none;
 b=t6FSAxQyNT9l7MoZ6pHO/fyFOFf+eax88I6DWLoDyLw5o8wGs8owWfUHGkHUNTfS6Acnc82y/dP/2HJTd6S1gFvO9yfGKWRTVf7Wkd+k0pRl4+hkKNuYc14iCHplT1czg6uzsMZsX7IZar6B7eQJCdn5QC0LxGijbdJ2rXow1oSiGir70ow0/Ta4cTzcLnRCg8fDrKcEvzVfXeISsJ84EmPsMVhl/xWpNsXp2l6aLPLA5ykym1H5j4Zq9WvUjAh8V/1QSIyPJ8Yy4ygMrynvUOvXUmEAPB97WLoN3lfl1hlf5ESk39bqlN3k3yp3Rv06csnmkdv5sdyDMvlxWu+ikg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=microsoft.com;
 s=arcselector10001;
 h=From:Date:Subject:Message-ID:Content-Type:MIME-Version:X-MS-Exchange-AntiSpam-MessageData-ChunkCount:X-MS-Exchange-AntiSpam-MessageData-0:X-MS-Exchange-AntiSpam-MessageData-1;
 bh=WF6YBpLtjEtcjIdFIqcjJf0GpDkAtkuxh0pAVhnkeLE=;
 b=SHHoyOcXPdmQcZTPtc1Ni/o6QgDUwwH+H/sjO19pN/T5rENRzX4nim0BfTmp3QetI2EcgKnngqU4gjgQICQM6GbL1scCG2FKSoyghe9mIjuqjsQ66107h3+74Cz82ThHk6RZWI+PU9pq9ME4DxR1uEF+GNrpOdtehsy1ysE6KiM4ZW6Rr0EMW0EWkRtqeEGp8wY6E7YZxuQCOd5Q5xCD1+YlzFmLJTFjP54e3LMpOjLzATMGTeoGYd3tWcOvD6ElfmiHwyXEKztIgpobpD5zMUGZVgIYOmkvtw0O1KBuxsSlA9PHHsAOAMaj+ZFAhsrW5EBp8TsOh24mVvCVVCkNxA==
ARC-Authentication-Results: i=1; mx.microsoft.com 1; spf=pass
 smtp.mailfrom=est.tech; dmarc=pass action=none header.from=est.tech;
 dkim=pass header.d=est.tech; arc=none
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=est.tech; s=selector1;
 h=From:Date:Subject:Message-ID:Content-Type:MIME-Version:X-MS-Exchange-SenderADCheck;
 bh=WF6YBpLtjEtcjIdFIqcjJf0GpDkAtkuxh0pAVhnkeLE=;
 b=e+HTWqLXyMq3kKF0ycwMQKLd8pTJfuxE/I7ZPYslOniKB9QyioBpZKdYFTPrrg6MRt/ASS4Q+EP03Gh7mXamr5qAnN6Kkz/Q8hvMqr6tuBoin75b1w7mqDEXHwC3Jbu9+LF7ahA7sgGiAAd3vje1Itk5UnHEtRycDF03r0Djl28YRwfhy6LMyL6rx7qKyBhfs9B+0mX6d2h+HiTMwFKClBv+VETG/jS2L2/rxi6nAfHI4iQjGZ/1CWI3lJp8Qlak8lxBdyGrO6pTtq9OvloWZZRRG2lWjeZatUOsOttMpvAFUpHomDVYbDNNNglpFKK+/vXOHKgVAZTKYasq1aWvPg==
Authentication-Results: dkim=none (message not signed)
 header.d=none;dmarc=none action=none header.from=est.tech;
Received: from DU7PPF66507B2D7.EURP189.PROD.OUTLOOK.COM (2603:10a6:18:3::ad4)
 by DB4P189MB2239.EURP189.PROD.OUTLOOK.COM (2603:10a6:10:38d::14) with
 Microsoft SMTP Server (version=TLS1_2,
 cipher=TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384) id 15.21.315.5; Thu, 6 Aug 2026
 11:20:26 +0000
Received: from DU7PPF66507B2D7.EURP189.PROD.OUTLOOK.COM
 ([fe80::7ab2:c6af:6760:5c85]) by DU7PPF66507B2D7.EURP189.PROD.OUTLOOK.COM
 ([fe80::7ab2:c6af:6760:5c85%7]) with mapi id 15.21.0292.013; Thu, 6 Aug 2026
 11:20:26 +0000
From: Jaipaul Cheernam <jaipaul.cheernam@est.tech>
To: linux-nfs@vger.kernel.org
Cc: Jaipaul Cheernam <jaipaul.cheernam@est.tech>
Subject: [PATCH] getport: fix missing stddef.h inclusion
Date: Thu,  6 Aug 2026 13:20:23 +0200
Message-Id: <20260806112023.25090-1-jaipaul.cheernam@est.tech>
X-Mailer: git-send-email 2.39.5 (Apple Git-154)
Content-Transfer-Encoding: 8bit
Content-Type: text/plain
X-ClientProxiedBy: DU7P251CA0028.EURP251.PROD.OUTLOOK.COM
 (2603:10a6:10:551::12) To DU7PPF66507B2D7.EURP189.PROD.OUTLOOK.COM
 (2603:10a6:18:3::ad4)
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
X-MS-PublicTrafficType: Email
X-MS-TrafficTypeDiagnostic: DU7PPF66507B2D7:EE_|DB4P189MB2239:EE_
X-MS-Office365-Filtering-Correlation-Id: 48b516fe-fca3-480d-6419-08def3acb6d0
X-MS-Exchange-SenderADCheck: 1
X-MS-Exchange-AntiSpam-Relay: 0
X-Microsoft-Antispam:
	BCL:0;ARA:13230040|1800799024|366016|23010399003|376014|18002099003|11063799006|10067099003|56012099006;
X-Microsoft-Antispam-Message-Info:
	G5/KwrnuOFbg184O72K7/acC8imRIvwvsrnTivyP5yN9auneinxgNrY0AXoh1Inz5HYaIrjRohwu9wHRA7hprT0PKCTBsq6vxJVrJWd9Hd9ZzkxFq8Owy0djX+hKWHIozxbQbPnkffIqgHYOIYNYi++bYRq58qTVC/uoi0VTfzJsYU+UUGDEfqQCBSI2/k4n3IaDSEn7EV5NTHu0e0xmTFZTZr4ahkH2U9sJp8ZsQVJf9KUOk/jIdS+tmVrsGTdhfyw33wwIUA1CiCGTgs2cwekDaSaKGulNiAC2uYVjrHkwZTF+04owkT+PG9hxJpus3VbjfNuEf5dqbMR9E/NXuruXiaXKfA0WEl1T+N9mVRUp/9eONY+qH/H4qa0gJyp67siwiZa9Bi6nEuNu2Yf2k7falERzHrjJWWMTj0eU5qJrco1WVWZ3KIzCcDPpzIiIXrLROHTJL6NBpB/pWM1KaWHcJW2cq9BwKA3RjAr+373gFCyJeWaj5XMVTchaP+vAw6jZd7EbfmSA8s27122nASQ5+T9fvSdvCx8o0oRFz1Ly5xR2OxePDl7LB/Gnc7fc1p59N/XrjpjjHpQyf0qhb6W+qEuz082fO6YKWNvNmKbhjQb0rYbYX4mXytWkUcpxNttSvz7PNi7Ior1L8xQsoAN7IzlBr4S7YG1wYl/gRJM=
X-Forefront-Antispam-Report:
	CIP:255.255.255.255;CTRY:;LANG:en;SCL:1;SRV:;IPV:NLI;SFV:NSPM;H:DU7PPF66507B2D7.EURP189.PROD.OUTLOOK.COM;PTR:;CAT:NONE;SFS:(13230040)(1800799024)(366016)(23010399003)(376014)(18002099003)(11063799006)(10067099003)(56012099006);DIR:OUT;SFP:1101;
X-MS-Exchange-AntiSpam-MessageData-ChunkCount: 1
X-MS-Exchange-AntiSpam-MessageData-0:
	=?us-ascii?Q?s/DmxEdRbEa7AISBwfZ1t4ySj7bZgxAvWVRmIoW8L8XLIFPU365he8aRZgl3?=
 =?us-ascii?Q?ET6o15SPJfwsP0tUcz6nLtJ3VKDhRXe9z0QZpEVrJ8zsp4K3LtjQCjYHzDFq?=
 =?us-ascii?Q?ZyYioNHMmIrM7H4XVbfhZFsIqMKr/ZPlFBQRcUzR76cunaqoJhuGAQsf5fVu?=
 =?us-ascii?Q?ju1jCC06rIocECSpdGReYSA+nf3mv9EsKRsYpifdZyd8VwHHXmqb8FRICi5a?=
 =?us-ascii?Q?LhrwB6yOMp8wIxyl+IrwJA2pzsuiMXZ98Yy/8QjgJ1GvlMSZ/vgzMsEeHJLu?=
 =?us-ascii?Q?Y49bC6CFg18Ipj/ZlxzIpM8XkkSIGFAwJckfqOHPtBxF9N3ABnltu0YK/+Ex?=
 =?us-ascii?Q?JV3X6V/lG/fwo8EhbqQVIR7UcxaNBW84EKkaLlA4zByUj1iBk2E0+qYWPLfs?=
 =?us-ascii?Q?4hy0sBPsZl8+EKXqtNLJDJnqyTTGbV/wZEo/IVHlBFLeFdFUkjyuCUC/UwUM?=
 =?us-ascii?Q?ksqvf68qM+f5Pnv2LQxCDNeVUFHIokHs+i5i71j28bz8HEo/8HYxSNSnEYJr?=
 =?us-ascii?Q?ASH/4FbmMUJytaIH0SpzntLpQ+j6YyHRRKYI9XLfDMJZmytaClsSbqe9PLpc?=
 =?us-ascii?Q?isvF2CJpL+V2vf7rwd4egV9+6sNdjwbcsfqG5K02HoXYC43CrCGRsn2fS5I9?=
 =?us-ascii?Q?OgQNvbmtYapC1BsVDsj91z0F9H/cJkMbU2PYmPlvvgdXVAgPOAVujgs1aTx+?=
 =?us-ascii?Q?Sz/plLp9x8Jh1GMEzmIJuV90NwSPKIwDK7IoaB8SNN4Vjuj3z8T7FUPzhTAz?=
 =?us-ascii?Q?pZZu/W73z/m8+6SkU+s/PqJzwfcsK0Gyft4eBaCEz7ylhrhUEquInBHVxeZd?=
 =?us-ascii?Q?0r26trw12l+Qz4wyIOaH2OlANWVAJUL3WXHHdchBT9oSzc7jJthqXT3z2L04?=
 =?us-ascii?Q?fHL05WO6DkGgEsFOE9AYzKlwgz18EsERt8tgS/1f490MQ7sP7kf/TvW+6yD8?=
 =?us-ascii?Q?9aUJt3KecQdXrUstVoVTbw8kvBB3kDSt1NIFEILusqZe0fxSwYIVj/I4rVqG?=
 =?us-ascii?Q?NkwD4Szq+FesOqVQwKUOK036eCbQRiq+zrQNgglxfUROk3+QZAeWp8jwIboo?=
 =?us-ascii?Q?TPrEARhCi7irmCaC2xhfY5eE9C6xdUACwRCgAlQQykYHk0Bmtq66utvUESIC?=
 =?us-ascii?Q?wl01n6mp1m0Mng/VSmCBi3+NQz1aich0nOaaV1nGygv85OKUcbEykUbtW8FT?=
 =?us-ascii?Q?YqDibz5jrQc/POrDoB9EX6QKRJtx6jk8Ly2Q2FDpPz9EEQ1oYd1uzQ6e5tRd?=
 =?us-ascii?Q?rjsSHSRnCp1LIPjo2cMLC19IDXqK57nbdryFvCfZDqVK0uSJuVM69ePxkbPb?=
 =?us-ascii?Q?EuWoXf7PZcX6GM/1rrbJuCQYqsYigl85Yv+u2gGrmlFd7b+5DSppDsTYoO1Z?=
 =?us-ascii?Q?NCbbUZTx3anSrUWuyH+ShGCp9w/FankZ0gg+Wk6cM7UGI3HAsRtuEQl8mynb?=
 =?us-ascii?Q?lGexMnVEj0clg2MtB7quN87tNueFZLr+6K2kCRgMxNQ7Aq2g2gtzAumBl00i?=
 =?us-ascii?Q?TktCVmXhmvrdUTHT7ZfwkUow9/Yag8qyOPvmoUarZ8Jkv+M1YdQOYMXpwnfV?=
 =?us-ascii?Q?czKYkY0MBb62aBUZWBkWPOK0V6/xC+99Ujib+mJM5PPl3SjzIH8jWrVFd4EJ?=
 =?us-ascii?Q?wxt4heg3W0wFw3qpSkgRskUgYRlPEIxL6Kfi+bAefCFpTfrmtAAyc7Klosl+?=
 =?us-ascii?Q?qN5AeHXJp6CQmcoFOzmAmu1ggid5yZBtYLQhApNOCz1w11I138o3i0D13Ctu?=
 =?us-ascii?Q?nlIx8cxAeQ=3D=3D?=
X-OriginatorOrg: est.tech
X-MS-Exchange-CrossTenant-Network-Message-Id: 48b516fe-fca3-480d-6419-08def3acb6d0
X-MS-Exchange-CrossTenant-AuthSource: DU7PPF66507B2D7.EURP189.PROD.OUTLOOK.COM
X-MS-Exchange-CrossTenant-AuthAs: Internal
X-MS-Exchange-CrossTenant-OriginalArrivalTime: 06 Aug 2026 11:20:26.1753
 (UTC)
X-MS-Exchange-CrossTenant-FromEntityHeader: Hosted
X-MS-Exchange-CrossTenant-Id: d2585e63-66b9-44b6-a76e-4f4b217d97fd
X-MS-Exchange-CrossTenant-MailboxType: HOSTED
X-MS-Exchange-CrossTenant-UserPrincipalName: tNKVMKWuVhkA1SE1LVAjLJ9PlqjNDhkJhnxT0SboqcRMJzdftwdaD4T8ymQKkwtU1ikl2d+h4GiO6DQH2wOd0SNejWp5Gxb1KH8cjkl2+Wo=
X-MS-Exchange-Transport-CrossTenantHeadersStamped: DB4P189MB2239

getport.c uses offsetof() but does not include <stddef.h>. On glibc
this works because offsetof is pulled in transitively, but on musl it
is not available without the explicit include, causing:

  getport.c:459:41: error: implicit declaration of function 'offsetof'

Signed-off-by: Jaipaul Cheernam <jaipaul.cheernam@est.tech>
---
 support/nfs/getport.c | 1 +
 1 file changed, 1 insertion(+)

diff --git a/support/nfs/getport.c b/support/nfs/getport.c
index 608e185..6bd2f71 100644
--- a/support/nfs/getport.c
+++ b/support/nfs/getport.c
@@ -27,6 +27,7 @@
 #endif
 
 #include <sys/types.h>
+#include <stddef.h>
 #include <sys/time.h>
 #include <unistd.h>
 #include <fcntl.h>

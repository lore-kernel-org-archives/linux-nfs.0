Received: from SEYPR02CU001.outbound.protection.outlook.com (mail-koreacentralazolkn19013086.outbound.protection.outlook.com [52.103.74.86])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 009D0415F0C;
	Wed, 22 Jul 2026 20:01:07 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=fail smtp.client-ip=52.103.74.86
ARC-Seal:i=2; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1784750470; cv=fail; b=WgG0McqD8uB8krLDiBw46oOukhX23YNeDUkqWbG6ohGLeDYSyViG/dZ3srW4XBF2gn3bWrACY6tFqOLCgEUAHQfHLlB8svTKtkySdo5133jO4oDOmqqSu/71t95fkUoXQ22VbfpGSUA+V+ABjL8E/zLCEVfhMz4t8RlxdAfdxIQ=
ARC-Message-Signature:i=2; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1784750470; c=relaxed/simple;
	bh=Rd8wDRs4+I1NjD4c/ynlBkTXhNZTxa68Igogu5cjpYk=;
	h=From:To:Cc:Subject:Date:Message-ID:Content-Type:MIME-Version; b=Zf2UCCLTQHP+oNtCJs5igM3sZw3MpSGU71H39BSQAHmg7uF07yvKE5rdLHmIwQ3972Evi0Xecc8bHUuu34HGGhHhYq+3/ixgGsFW9W7DQPZG/15b7pUlwLJyWC3IQuGDkovnH92NQ37bwgX71XC6iu2uJtJXErkmxC14Eup4sVc=
ARC-Authentication-Results:i=2; smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=hotmail.com; spf=pass smtp.mailfrom=hotmail.com; dkim=pass (2048-bit key) header.d=hotmail.com header.i=@hotmail.com header.b=oj0Hq3cm; arc=fail smtp.client-ip=52.103.74.86
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=hotmail.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=hotmail.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=hotmail.com header.i=@hotmail.com header.b="oj0Hq3cm"
ARC-Seal: i=1; a=rsa-sha256; s=arcselector10001; d=microsoft.com; cv=none;
 b=Dk8YvtjqqGzp/c9LqS19ToxzFp7KbGCU4siye63qZldlZDTVr+JGw8tgmTu+t0vAj+cnfAfRVcbEELSgRETIMkmEfovnagfE6ul5Cy/YRuPNDb15VAlHVI31ILqQNWRce9DL/rIMGkXA8ozeFRo6BT8w2Y/1xYzDI/IL+AaH2c8aa3DODYUcUedP4H1XLmECz4prDDbOBKXv2ILVoxBi745pifEIYTp5Uxlfx3x7RHZ968uXoVZ9ZAtvVbjLEh5/Bl4DyPlD0lfDWqXmE8dhE1xFeV75qsMDI3ftA+KHt3OTfU9sJgegUcCnWa39gnVT8Gu4kzN0adE6An59hZnYdg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=microsoft.com;
 s=arcselector10001;
 h=From:Date:Subject:Message-ID:Content-Type:MIME-Version:X-MS-Exchange-AntiSpam-MessageData-ChunkCount:X-MS-Exchange-AntiSpam-MessageData-0:X-MS-Exchange-AntiSpam-MessageData-1;
 bh=ijiKllwtKbU+M8r0938bMtsuU7eoo0xGog6JfET/9BA=;
 b=qYl3UGEy5eVZsWGcxb+Pb+dSq70ANuqDv8sACycuVSc60KYJ1ZcUNCvnGdTlVQQ5CNY/W5MlaYsPOxbyXvHvNBqPskOSeeDO9fIXSMd+qoSHifPPw8ZsqUKwE0KixDFnM6JrOaH9NMovcDcLo/53t+ekNQoz/uUhj2u6vAFKn7z46p024cP4sLHcDQIFUPSdIGbct2BVzlAKfh/ijzvt05lZSHrNnxVfCYAEtomqhDtBTdB3hrGAJbqG9SWio2jTRYjy4qZo8KpyLiJaMGW19viVCvIRSPIEpsmgZfd20p1iGKNMYLueMdH4H2bCan2TtDMMXc8zdfZv3UAyavwTmQ==
ARC-Authentication-Results: i=1; mx.microsoft.com 1; spf=none; dmarc=none;
 dkim=none; arc=none
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=hotmail.com;
 s=selector1;
 h=From:Date:Subject:Message-ID:Content-Type:MIME-Version:X-MS-Exchange-SenderADCheck;
 bh=ijiKllwtKbU+M8r0938bMtsuU7eoo0xGog6JfET/9BA=;
 b=oj0Hq3cmNx4+eOn/mb9EsEDPFW905ZtNwOG5VoqwDoeMGbj6ZKmLKvtyF+1yDzHBshYCwjy+ZpWk2eLQIZ6VQg93S8jq3NwmX8U6P4W6N9psspTCi1vAcJpjZ/d8cxPqLCK5EJZvSDpDgEMQUKDMk8aOGvvcakcEwpXMalvRyeQu8OVYXen71AWmJrOIAH39NaqXnzWYJnU5z6aUPaacGhjEWwWzhgNJKMUJeV2mj36DUNXULbquXv3Z0KHjL2EvqvPEMVMkDm0O6RicdjFGZx8x5rFewSZJe60lz8uAnq13ImTc/GkgfWRp+IONrFsIUTvuHxmNOZNO3WDSj8/haw==
Received: from SI2PR01MB4545.apcprd01.prod.exchangelabs.com
 (2603:1096:4:1e4::5) by TYZPR01MB5925.apcprd01.prod.exchangelabs.com
 (2603:1096:405:3f::5) with Microsoft SMTP Server (version=TLS1_2,
 cipher=TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384) id 15.21.223.18; Wed, 22 Jul
 2026 20:01:03 +0000
Received: from SI2PR01MB4545.apcprd01.prod.exchangelabs.com
 ([fe80::bdc1:d700:e853:6463]) by SI2PR01MB4545.apcprd01.prod.exchangelabs.com
 ([fe80::bdc1:d700:e853:6463%4]) with mapi id 15.21.0223.017; Wed, 22 Jul 2026
 20:01:02 +0000
From: Zhansong Gao <zhsgao@hotmail.com>
To: trondmy@kernel.org,
	anna@kernel.org
Cc: linux-nfs@vger.kernel.org,
	linux-kernel@vger.kernel.org
Subject: [PATCH] NFSv4: Fix incorrect argument passed to nfs4_delete_lease() in nfs4_add_lease()
Date: Thu, 23 Jul 2026 04:00:59 +0800
Message-ID:
 <SI2PR01MB454532D657E40A783BEAD771C7C12@SI2PR01MB4545.apcprd01.prod.exchangelabs.com>
X-Mailer: git-send-email 2.53.0
Content-Transfer-Encoding: 8bit
Content-Type: text/plain
X-ClientProxiedBy: SI2P153CA0017.APCP153.PROD.OUTLOOK.COM
 (2603:1096:4:140::10) To SI2PR01MB4545.apcprd01.prod.exchangelabs.com
 (2603:1096:4:1e4::5)
X-Microsoft-Original-Message-ID: <20260722200059.24601-1-zhsgao@hotmail.com>
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
X-MS-Exchange-MessageSentRepresentingType: 1
X-MS-PublicTrafficType: Email
X-MS-TrafficTypeDiagnostic: SI2PR01MB4545:EE_|TYZPR01MB5925:EE_
X-MS-Office365-Filtering-Correlation-Id: 3675d2de-440d-4939-2c97-08dee82bf4ec
X-MS-Exchange-SLBlob-MailProps:
	02NmSoc12Dcj/mAxI/NGvzdUkjNASRo/snTSVk73K6kmJ5kcJa9qu+IQ3JhvzEtN2XQhBO+Y+OvGgipwtrMbctxF97N4IfeuRAMQVuwclzdKQtxBTjKtUER6I9goS7UitC5qhPsjLEW31OA+V34AX4kTmgMOiCWbfwiLo7PHOptKdloR5BrkEploMdSHjeolkYnrTgfMHW/nINOMFcXncnCoqjdbOs3FRnCLrQO1qz5mNQmOxHlLpvdn8qU5fU5S1mhnajHKLJbR0fpY6rfpVKf0P+5E7fUiPRf2H6haQTNB8R9YVs9BErfdOL7m/0g+8OVFr9owrWhmwdvAP/sTFsXIQsq6FKKWoZFlh9ovleK5TpEEFuYXPfzxwDLP/EJsfszAPdoEgbBWf7K43SjnfdsbvF9EvScgtXkJad/OznvgqvsycInT16Dh9R3z03hY3oSGQZfPutgCGaqZ5mNMSOWz+tG+Kf9zSOMCR5JbCIwDXadLBULSn/pY94gLEjM7wcbDnf8a7vUp/o4z8ixHZxkxZFbze3U7PZ3OgAMNUQhZuY7n9z63qDJOjsbk/iOFY6AiwHrY1UaaAwO+3tWBSROJb/q0/nvTDNIuvWi+nluaY0bIV2qS+Ry5FbBF3UF/v/RcYjsc8djb/MQ7tok7mLmh38u5vb3587d0MNXY3L5IFlxhmt2D31zMJNzQDNaMRQMuWgc7iGUYS7+KSv8Lhj/A7Kg83mxZoyLlMghE4Sui4MZy6DKC7281EiMNfG9B
X-Microsoft-Antispam:
	BCL:0;ARA:14566002|23021999003|19110799012|6050399003|4140399003|39105399006|20031999006|24071999003|22091999003|24121999003|15080799012|5072599009|24021099003|41001999006|8060799015|5062599005|26104999009|440099028|3412199025|19061999003|40105399003|26121999007|3430499035;
X-Microsoft-Antispam-Message-Info:
	=?us-ascii?Q?biXy9ej9UJkW7tSIBa6cGrKb0OpzBBPY7Nh6NbTyw5geOUmbNSBYFLGOumrv?=
 =?us-ascii?Q?HLLUbmlMQdrzz6WwHpd8Q9Ro9WkN2gzvCF2jzqAzt0TwetWjxPIx6qotUw9P?=
 =?us-ascii?Q?svG8n9Zvl/4M3CPoYuxVUZAHBHLnUHmkmO2et6gful8mZmEAn9alA9n9RiRV?=
 =?us-ascii?Q?LSvnthF0zdHX58QXZi1fE7D056MdhuVQlkGE2RNLWmA9SHyEpWglvuoM1vSO?=
 =?us-ascii?Q?qzVnIXMucZSrODt9k2f1xNa3waOTkIdjJeAxPqltylfoX+e2mEfa6Sv8b1C/?=
 =?us-ascii?Q?Ebao5WHTN7kkj59e1hiQlsjjGak/aFG/RsefbLxtGLNGtFwu6Z0gVSKg412B?=
 =?us-ascii?Q?DukATRCvqwxYmEV9lV9zTvoTz0RYo7meNJvHLgT49JXWBFuOCZZRUlUZVyll?=
 =?us-ascii?Q?IUt2+6sQUv20jDhvj2yj3u281kKG8+NySAzIj1aFZH+oC3s2bzT9X8Fq/se8?=
 =?us-ascii?Q?wkzPyakM3JfYIX+XAToATaIPcYKBt7onz6sviRaUjGSGQz6qcXbNMdOmGUlA?=
 =?us-ascii?Q?ArScpMhrimzyGM1SjbRWfs0vAarpCmCf8/1dC0ruq4cYlRPk6uKRH+BOuvAb?=
 =?us-ascii?Q?EnOH6nX7U3EyGmRW35Wd0zajYwRVF72hrkyg7XANBe22D2vOYIQ8g/CHPtiF?=
 =?us-ascii?Q?UNooqfq+1B8e+q8/4OnUUtW+U2O00Izx5GVO0tQ59cvbMCm9z/03pbNQ20rC?=
 =?us-ascii?Q?yOwODw1pL2IlEGbdnUSdNJIicKfFxRnC0r6Dggn9GGA8HUxxk/XkTWJitDmB?=
 =?us-ascii?Q?fktOx25dWqWtywamGDdV+OYpfG7Diw9LnKTexK0Oe3U2/rQfouw0UBR1/zdj?=
 =?us-ascii?Q?qO8CBs8ts/dpDN8bEphA8se34Tmy3N3mTTB7W5w9+ss9EidLb5gIS0V081aM?=
 =?us-ascii?Q?h7fFkGnO5GcdXXJW7O0ZgO2dG+TMX/p9uwozCO4RrfmUvRRZ0pBnvq2r2CIa?=
 =?us-ascii?Q?998Z83MctOWPS6fBZy4M0vX4h+uhyTRSaS3j5a3cIOn+JSYVOaeNSKqCorAl?=
 =?us-ascii?Q?I1PRnXm6kUXtZDL0ZKWS8r6kncv/7LCCl+mcvVk4G0BbsyYTeTB2ojYei07n?=
 =?us-ascii?Q?sgACc92oRqFum8gbk3rZyQsnZoQS5S6FkxNphQKWZOiAAIw2iIWRB9cq3xAm?=
 =?us-ascii?Q?lPE8xwd9tJg1o5LaWwe6fk6BRCkUQl+kUsFTm5OCSxdWeNbXH3LGN72wpojZ?=
 =?us-ascii?Q?Dl5Rfg4W7dvL6Md5?=
X-MS-Exchange-AntiSpam-MessageData-ChunkCount: 1
X-MS-Exchange-AntiSpam-MessageData-0:
	=?us-ascii?Q?HfdYXanav35lfpbzjUG3ZaxfKA+Cof0oHfGKhNwS0OrBbNph09yURiwwA0p8?=
 =?us-ascii?Q?6RsonF27zF4mKldnmK6heHz4nohr85cZvNGfnlIhOOvOGnByfQjoCT0TzmoG?=
 =?us-ascii?Q?qxscXeCyMDAJB5Fjyn/n5hH24Ix8r4AQmfEjcEMU9N8PNY7NUxjLlFPXsN1k?=
 =?us-ascii?Q?k3XFtAkJV9bo9SMI94+Fx6pvT67HUlSIKi0a9enq8g/7PLUCbh8yrulTnm5d?=
 =?us-ascii?Q?x39IESGkvd999FmcVgGFvVZrUqp0tz8xd9S1X2pws2pOtSbbpC9+WIAF096X?=
 =?us-ascii?Q?nWYCLF3EQzsRT9AqKPqj4WzD2MS/NsxUMWNVH0G6EN6BxE2uO8T9S3kj9uJ0?=
 =?us-ascii?Q?YKx6o3R0L5xsk0v4K8N6SENGSwnN7h77oeKsVw0Iwd5aLUo1EIsEc7cfu3yh?=
 =?us-ascii?Q?5JSVg8jL8v616ltfj+TuuLkuQFPcM2KGPZf9Wmm4yFZQoDQ68tGNuCJhFv5g?=
 =?us-ascii?Q?b3lKm+oyhtdRgr+Og7hPr+yef9wXlAnujUJh/Hr7l3ANSkZ9eTE7u4EoTXsv?=
 =?us-ascii?Q?zwPOKTK35HT+ZAl8w29iTGGGE/jFxSrAk8EiGRyigKwt7kzEad+zFcAG0qw5?=
 =?us-ascii?Q?8IAk2vdpt4OMvO8Z6MaIpbpOHGYNDCrINbWo4T1gpYy9dpnuPu9qemnQVGTF?=
 =?us-ascii?Q?OvyQspsvfNOLdd+DutK3lAVzQzn1LOfR180siJ0452itBxDnJerKU2SEQLa6?=
 =?us-ascii?Q?NrTEpiwtZBS3jFQNA/zHugSVg7J5yihfc5pJxvt+lc/M2Y0RU8LGqy3FSLiO?=
 =?us-ascii?Q?0CsuI69E2VYkxSimwakFOX6HBWwmByzMpW0uwrCA2XEwtxuk7Y/qw5mlhpj0?=
 =?us-ascii?Q?RdcwBN7bYJg1vPU+QPslIAlMdioPA3Iax+4XFPBgJMS2qYEbNw0cdlNwnyeG?=
 =?us-ascii?Q?xT2ZNi9CSg9VxiHbbgveVUG1LUIR1cxSQ1dddtaSwvjQHjjk980zqnyX1Ad0?=
 =?us-ascii?Q?kw1L5vcv9PQKgAa3R+LoUcZvJ4ex48iQJRi20fY3SUcC+dW0pqAw8w3531ha?=
 =?us-ascii?Q?kR7K0P7TrPJoyFj0zenkS9bsvjbdD2izUJQ2+70bONIeNtk7ZzQI/UEGyl0N?=
 =?us-ascii?Q?h3oFNBNeKJR6KoJzU5GCOSjtpbVN4iO5bKsJp2AS6hOZvXgu0vc0J8kIlJ0b?=
 =?us-ascii?Q?hloGm/rPosRJH8+Qa6lEWzrcOfJP/qiUZJ0ab3uHZTdPFkVxZ4YUFytcQ+l0?=
 =?us-ascii?Q?IpvZxMGQOIgG/rtOSGkqutfnKMq06Xp0biLr6zlYvIied8Sew7uW8RiiJTtX?=
 =?us-ascii?Q?QjTOfGOZKvffN9eJj1s3m5y48Bf4dBS9wrr83NIeILCeASS9vjtBD96MWcUc?=
 =?us-ascii?Q?Dljj/g2MXTAddDlPJegjDI/ObGDShrqQPza1vYMjs8Yuze9Fhxq49KzZ7eEd?=
 =?us-ascii?Q?TdHhmKaKO9LnKouJQ93yp9SHywfs?=
X-OriginatorOrg: sct-15-20-9412-4-msonline-outlook-3e488.templateTenant
X-MS-Exchange-CrossTenant-Network-Message-Id: 3675d2de-440d-4939-2c97-08dee82bf4ec
X-MS-Exchange-CrossTenant-AuthSource: SI2PR01MB4545.apcprd01.prod.exchangelabs.com
X-MS-Exchange-CrossTenant-AuthAs: Internal
X-MS-Exchange-CrossTenant-OriginalArrivalTime: 22 Jul 2026 20:01:02.5622
 (UTC)
X-MS-Exchange-CrossTenant-FromEntityHeader: Hosted
X-MS-Exchange-CrossTenant-Id: 84df9e7f-e9f6-40af-b435-aaaaaaaaaaaa
X-MS-Exchange-CrossTenant-RMS-PersistedConsumerOrg:
	00000000-0000-0000-0000-000000000000
X-MS-Exchange-Transport-CrossTenantHeadersStamped: TYZPR01MB5925

When nfs4_add_lease() races with a delegation return, it calls
nfs4_delete_lease() to clean up. Previously, it passed priv,
which can legitimately be NULL. Passing a NULL priv eventually
leads to a NULL pointer dereference in generic_setlease().

Fixes: e93a5e9306a5 ("NFSv4: Add support for application leases underpinned by a delegation")
Signed-off-by: Zhansong Gao <zhsgao@hotmail.com>
---
 fs/nfs/nfs4proc.c | 4 +++-
 1 file changed, 3 insertions(+), 1 deletion(-)

diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index 1360409d8de..e1de641702c 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -7762,6 +7762,7 @@ static int nfs4_add_lease(struct file *file, int arg, struct file_lease **lease,
 {
 	struct inode *inode = file_inode(file);
 	fmode_t type = arg == F_RDLCK ? FMODE_READ : FMODE_WRITE;
+	fl_owner_t owner = (*lease)->c.flc_owner;
 	int ret;
 
 	/* No delegation, no lease */
@@ -7771,7 +7772,8 @@ static int nfs4_add_lease(struct file *file, int arg, struct file_lease **lease,
 	if (ret || nfs4_have_delegation(inode, type, 0))
 		return ret;
 	/* We raced with a delegation return */
-	nfs4_delete_lease(file, priv);
+	dprintk("%s: raced with a delegation return\n", __func__);
+	nfs4_delete_lease(file, &owner);
 	return -EAGAIN;
 }
 

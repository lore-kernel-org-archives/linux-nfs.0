Received: from mx0a-00069f02.pphosted.com (mx0a-00069f02.pphosted.com [205.220.165.32])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 9E27533AD88;
	Fri, 17 Jul 2026 19:44:35 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=fail smtp.client-ip=205.220.165.32
ARC-Seal:i=2; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1784317477; cv=fail; b=B3/jUiWtFhVTn6y42RCYHyKf/w8WRrgGt6lWnhcmETx0wAtjJjZegxkdC7N2LIryH6gr51Xf6K7FwII1jFs1UKbvvGMDHhw1ElwM1iO0bX4Ywj1GCXiN9Zj94gzbod3wnnz6K1skjp2HZOmDQmoeVpy+unjLvx+z0hOtQgxHeK0=
ARC-Message-Signature:i=2; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1784317477; c=relaxed/simple;
	bh=qaariYcGWF/LQ9qEhPjhduWDkXl2ytuzDrg7U627+Gw=;
	h=Message-ID:Date:Subject:To:Cc:References:From:In-Reply-To:
	 Content-Type:MIME-Version; b=gf4DdpdPMeIpMxfkEUMO6wS9QrrOUCYnuq7WHwBnZJWxb4OFBCXp3kqmqCGcq3GnuvcOGDUp5yIc0QU617Pf/8XHtwhSze938khXgMkfzkj3lCAqh7LfhKgjVidrGZspOiU3yHDmhWzPfHqSDXUQTuH+zSCJCAEePuIlHBjHnx8=
ARC-Authentication-Results:i=2; smtp.subspace.kernel.org; dmarc=pass (p=reject dis=none) header.from=oracle.com; spf=pass smtp.mailfrom=oracle.com; dkim=pass (2048-bit key) header.d=oracle.com header.i=@oracle.com header.b=XcdGuLme; dkim=pass (1024-bit key) header.d=oracle.onmicrosoft.com header.i=@oracle.onmicrosoft.com header.b=lSjA+Fy4; arc=fail smtp.client-ip=205.220.165.32
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=reject dis=none) header.from=oracle.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=oracle.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=oracle.com header.i=@oracle.com header.b="XcdGuLme";
	dkim=pass (1024-bit key) header.d=oracle.onmicrosoft.com header.i=@oracle.onmicrosoft.com header.b="lSjA+Fy4"
Received: from pps.filterd (m0246627.ppops.net [127.0.0.1])
	by mx0b-00069f02.pphosted.com (8.18.1.11/8.18.1.11) with ESMTP id 66HFnRv83392396;
	Fri, 17 Jul 2026 19:43:29 GMT
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=oracle.com; h=cc
	:content-transfer-encoding:content-type:date:from:in-reply-to
	:message-id:mime-version:references:subject:to; s=
	corp-2025-04-25; bh=xBKbyYQ4hdZENfxsP+z5bF8MRyXvLzjQoMICMal+tcU=; b=
	XcdGuLmeQE0vz+0rlrot9wjVOM6G1GkmmQV7OR5+p5crGdnCkEBD4tTqCCd6N71s
	cyRf1pHvdbhoYYSsBzHbzM4mbKL36SyhkfBudLi457LCjbGAnDAn8+SFFiRLz02W
	R+IBGNbUluMnmq2k0MLg/t+wOI+SvTp+tF/EE9uLC7yOZnFmy0j4lzvNQHOO6oN4
	zMeOUNYu/ZvNsWG+GMK1cS/36Xymk9xFVPNnt2BRNnKlOg5hCBYZpLpbrSYZc0BA
	5FLeGX/ybM9YQkqI97mhZeQMb8sHRASOd4dzsC47f0Dx1EIPJpY41/yZQCH1fF5Y
	j6BUGa+yzZcTkzkskJX0+A==
Received: from phxpaimrmta01.imrmtpd1.prodappphxaev1.oraclevcn.com (phxpaimrmta01.appoci.oracle.com [138.1.114.2])
	by mx0b-00069f02.pphosted.com (PPS) with ESMTPS id 4fbeedtx9d-1
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Fri, 17 Jul 2026 19:43:28 +0000 (GMT)
Received: from pps.filterd (phxpaimrmta01.imrmtpd1.prodappphxaev1.oraclevcn.com [127.0.0.1])
	by phxpaimrmta01.imrmtpd1.prodappphxaev1.oraclevcn.com (8.18.1.7/8.18.1.7) with ESMTP id 66HJhAYF008650;
	Fri, 17 Jul 2026 19:43:28 GMT
Received: from bn8pr05cu002.outbound.protection.outlook.com (mail-eastus2azon11011038.outbound.protection.outlook.com [52.101.57.38])
	by phxpaimrmta01.imrmtpd1.prodappphxaev1.oraclevcn.com (PPS) with ESMTPS id 4fbc9j02ww-3
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=FAIL);
	Fri, 17 Jul 2026 19:43:28 +0000 (GMT)
ARC-Seal: i=1; a=rsa-sha256; s=arcselector10001; d=microsoft.com; cv=none;
 b=ckkwVLQJ1rgJJvyeRjOyosVnMGFCzU6n+TTaH4ym92SrpzDQpZ369Y4zJSz8IH7beW1L215Li9t2yjZer685fsvu1tGCnnCecXUDrUU+/Helo+DCRJXDexnjlZM3TiJ/lW7v7apBC479qF7MLpE9ke3EpupT2XeHvDyv2fuAYlcztPT+NsZ4sEVn4IPpM2k78FG9eltBqz90X+LldJqijzdABMHjLoz653DB4U0yCktnw5lb2y1L/9wHL1xRvUUDEFjQhgdDr6kR+oLfElqR7g6OxEkTFPHG9XRmtaXhhRyeg4fpL/DUetJDRCkBHlQcxUPHHhny4hYw5SDHFm0ntA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=microsoft.com;
 s=arcselector10001;
 h=From:Date:Subject:Message-ID:Content-Type:MIME-Version:X-MS-Exchange-AntiSpam-MessageData-ChunkCount:X-MS-Exchange-AntiSpam-MessageData-0:X-MS-Exchange-AntiSpam-MessageData-1;
 bh=xBKbyYQ4hdZENfxsP+z5bF8MRyXvLzjQoMICMal+tcU=;
 b=aJN4YlQpefESIlzpMZ5OH+AC9+cgZrx4U1Mj55x/RbYSZ/RnDgjr3ELG/n+FJkxrI3dJ1gJxZbJ2RoCCsqshpFv07SVHkK4FGos1zHlNh4hp5hK1cGFMqNgUQySWTTOEdXy69gp9b5v0HSrKY6YFdcqSJrV+91qF8UVBhbMHhwr5j57qlxm9XsQVckiQJINzM5Eb7DOcbq1BEB8MQfWWgQRiLndXfnx2gBeXRQM28IsTcyIYHqVuTQsi1D8ZteyH6efR4sYsmXhgWNf/wZxJJrL+X3pgKlCbdJ0o5F7H+9UuBxWIR6B3f+jwT0mzT2KpjezdQsau9qqLzSJzgw+PpA==
ARC-Authentication-Results: i=1; mx.microsoft.com 1; spf=pass
 smtp.mailfrom=oracle.com; dmarc=pass action=none header.from=oracle.com;
 dkim=pass header.d=oracle.com; arc=none
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
 d=oracle.onmicrosoft.com; s=selector2-oracle-onmicrosoft-com;
 h=From:Date:Subject:Message-ID:Content-Type:MIME-Version:X-MS-Exchange-SenderADCheck;
 bh=xBKbyYQ4hdZENfxsP+z5bF8MRyXvLzjQoMICMal+tcU=;
 b=lSjA+Fy4YdvporxH0G7Ysg3LXV0TGzO1OfTj5aXE2mjqlVrubghwSj6aOQK1GTDW2Xg9V54pPWzoP1stkCMwraolNQrlAw31achUHsOqPrm8wBsC+NGCJiR9Rh4HAfPl+WNvyQFcnfh8u/7lwZjDsVPQROQVw7w+oxDjATM4WAk=
Received: from MW6PR10MB7639.namprd10.prod.outlook.com (2603:10b6:303:244::14)
 by MN2PR10MB4365.namprd10.prod.outlook.com (2603:10b6:208:199::21) with
 Microsoft SMTP Server (version=TLS1_2,
 cipher=TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384) id 15.21.223.13; Fri, 17 Jul
 2026 19:42:43 +0000
Received: from MW6PR10MB7639.namprd10.prod.outlook.com
 ([fe80::8386:1d11:46b2:b163]) by MW6PR10MB7639.namprd10.prod.outlook.com
 ([fe80::8386:1d11:46b2:b163%5]) with mapi id 15.21.0223.011; Fri, 17 Jul 2026
 19:42:43 +0000
Message-ID: <159e382b-8092-4d0b-8b6a-97a54cd8da41@oracle.com>
Date: Fri, 17 Jul 2026 12:42:40 -0700
User-Agent: Mozilla Thunderbird
Subject: Re: [PATCH v6 3/6] nfsd: implement server-stats-get netlink handler
To: Chuck Lever <cel@kernel.org>, Jeff Layton <jlayton@kernel.org>,
        NeilBrown <neil@brown.name>, Olga Kornievskaia <okorniev@redhat.com>,
        Tom Talpey <tom@talpey.com>
Cc: Trond Myklebust <trondmy@kernel.org>, Anna Schumaker <anna@kernel.org>,
        Steve Dickson <steved@redhat.com>, linux-nfs@vger.kernel.org,
        linux-kernel@vger.kernel.org
References: <20260619-exportd-netlink-v6-0-ddef3499793c@kernel.org>
 <20260619-exportd-netlink-v6-3-ddef3499793c@kernel.org>
 <8173debc-96fb-4354-ba11-dff99b772523@app.fastmail.com>
 <4ef6dd5a13bfb51f72452aa30f59c89a54037404.camel@kernel.org>
 <dace51f2-0d20-443b-841a-f8452fdb85e3@app.fastmail.com>
 <8608717db0afb2baee5536caa9cdcc5d4ac85623.camel@kernel.org>
 <4f38f857-8960-4cf6-9141-d133120f06f8@app.fastmail.com>
 <c7ebc7af-9bb0-4c10-8295-7b60b8507bfd@app.fastmail.com>
Content-Language: en-US
From: Dai Ngo <dai.ngo@oracle.com>
In-Reply-To: <c7ebc7af-9bb0-4c10-8295-7b60b8507bfd@app.fastmail.com>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 8bit
X-ClientProxiedBy: CH0PR03CA0215.namprd03.prod.outlook.com
 (2603:10b6:610:e7::10) To MW6PR10MB7639.namprd10.prod.outlook.com
 (2603:10b6:303:244::14)
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
X-MS-PublicTrafficType: Email
X-MS-TrafficTypeDiagnostic: MW6PR10MB7639:EE_|MN2PR10MB4365:EE_
X-MS-Office365-Filtering-Correlation-Id: e17bfca7-f1d4-4d3c-9af4-08dee43b91e6
X-LD-Processed: 4e2c6054-71cb-48f1-bd6c-3a9705aca71b,ExtAddr
X-MS-Exchange-SenderADCheck: 1
X-MS-Exchange-AntiSpam-Relay: 0
X-Microsoft-Antispam:
 BCL:0;ARA:13230040|366016|1800799024|376014|7416014|23010399003|18002099003|22082099003|4143699003|3023799007|10067099003|56012099006|6133799003;
X-Microsoft-Antispam-Message-Info:
 knzCzalryH5DBhmf1eeRaGuUEv2y0L8rnkB66qNFU/YFom+7YeXJqydr7/ZEqcGaQJcrrhsPmmVhHd6nXtbeqgQT+TivwF9v2vhcDFh3n1+fxqPmPfHd/e+9a3jia1RIO/jOHGdd/537+TwSuuWGwbPv4aek9yRydff+TUc7gGfZ7etT/WoCF4yvKHoISiG4fxyitKxrTHOyOGucnkHknPd74XHBYRe3oAyxCpJ0H9FAbbHeSv8sHbamwh81qTRCY3PNU7sGNb+Yv+peZsVzXVM0EYH8eBaefAzy7YzfX0oQBxTs81/S6PK4toXbAO9+bWRYhr5tedOzhWgtFyf/J1ZysFMVzO7RA8Td+8222NjgcMkNQspNzRaPrFu+T0NfFDdBvMqYq93Ptf0o2XE68XzZMuRC43JG1Oo4LLggpYokar2Oq8lvH6v6EzL6oscZ+f5yxpFfH7OeU9mArRxZSfsVpdl1RfyptyVhfg3S7tS/uUnIbI+vCR7dtBw0sdvB0zlYoD2zfgA+IPTH5sA/ZIpwnhS2lr9EpHhk1YRbunmxOQ6ftic0lJXoXxFpjwWn/sw0jmvnbjYFQxvNEfZROJZU+Hbxpr0sfyQdYvEiB3XyuON7ZAq241ElrBqXJo4gA+k970SkPBIOVTbjK26x2sXKce8xxvIJki0B8W8fa2Q=
X-Forefront-Antispam-Report:
 CIP:255.255.255.255;CTRY:;LANG:en;SCL:1;SRV:;IPV:NLI;SFV:NSPM;H:MW6PR10MB7639.namprd10.prod.outlook.com;PTR:;CAT:NONE;SFS:(13230040)(366016)(1800799024)(376014)(7416014)(23010399003)(18002099003)(22082099003)(4143699003)(3023799007)(10067099003)(56012099006)(6133799003);DIR:OUT;SFP:1101;
X-MS-Exchange-AntiSpam-MessageData-ChunkCount: 1
X-MS-Exchange-AntiSpam-MessageData-0:
 =?utf-8?B?V3E2SnRmM1IwdFV6VGlQa2JvcytrKzBHVkp4dURrcWJqNnJxTDN1L1ZsOS9i?=
 =?utf-8?B?YndGOHhkWWl6SlUzR01zUWsyZmRmMTBMZ3JidTdoWU5YTGtSRXAvNmxhOVBi?=
 =?utf-8?B?anlsN3BZZ0dWK2ZXV2VIWHVMamtLT2J5WWFid2tiRFBjcTVtd0ZJc29RZU9a?=
 =?utf-8?B?YUh4SkZYZWoxR3A3dVJkZENaaUtlNkNJS0c4UVJ1d21yblJqWUk1TzlNVW8v?=
 =?utf-8?B?Y0c0aGtNSVZ0QndwdTh6YVNxYXZNdXd2MTlEVDROZzNUZW5BKzQzcDdwWG4w?=
 =?utf-8?B?NHhTS0E4dWhDRm9GWForWC8vMlcrbjkxM0QyVGxQWjBtQXdxYjZoSjJNbVFI?=
 =?utf-8?B?VWpPY3VTZjhhSmJ4ZGRoVlU1UGxtUGNoMklacnh1VEdLUHY0d0dmbGRRWnQ3?=
 =?utf-8?B?SE41WGdldS9ycWRvbkdMZmlTWHN3bmNsK3QxdUFWZitjMDd1WXp3Wk9MOG0w?=
 =?utf-8?B?QmJVV3Zja1FyRmNZQjk4a1JqNU5rMndicmx3TVRnZHZ0cjJaSVdkdjFMRlpV?=
 =?utf-8?B?N1k2dXdnUUVhaXZQMlV4Tm5pa0doUE1TdVlKeGhmY2w5Vkc2ZDRoVTRRWng5?=
 =?utf-8?B?ZlNidXN4QTM4eElqczRhaG43MlZ4dEpwUlYwNWlWV3RoYUVzR21wQnl4RmlC?=
 =?utf-8?B?RFlDeUdRcUhseUNaOGtDZ2Q4a3VoWGpFSGYyOUJVNFYwWDlvNmVaRTI1cWd4?=
 =?utf-8?B?YmhyT0FZbHpZdG1mZnY3M3B6Z0ZtaWwxRDlZK2c4MjFQUW9heUJiUVRKT1lw?=
 =?utf-8?B?Rkk1UExqeG9sK1IrRE0xeWZHbU5MSGZMNjZWV2hUM3NqeFlncmlwaDJqUXBn?=
 =?utf-8?B?bzhvOTRla2VoNkxSVWVPTzI1ZHI3d1AyNnhwYWR5ZlRMcXdXVnN0cW84K1hG?=
 =?utf-8?B?MHdLZGs2eXpHdWhVNzhyVnRJSVdNYURTYXV2MHZLcWJPeXlWUUpNSnhibHJh?=
 =?utf-8?B?bUlvNVB4eTgvNHdOMW9xREdDc2RqbDZHSW5WaFF4N0lsYnkrTE5kYXBmdUF2?=
 =?utf-8?B?MkIrZCtUVWNXWURZd0ZabHd1MG1aT3JiYUNZNTZvVUtSdHVUYjhKRVFwb3Ar?=
 =?utf-8?B?V0hsTXFxL3ZlMStCRXJxY2hHSXZjejNMWWJidzNUR3c0anlOVFp1dDJkTnQv?=
 =?utf-8?B?WUZNZlQ1L1dKcG1JTVcxK0FER2pobiszN0hMcWt2ZjhDVlJkSWpheEFaOGhN?=
 =?utf-8?B?SUozSGVvMUt4a3RmMXFoOXc4RllRbXY4cVB0RzJBT1NBK0x6SU5ZMXhqcGxY?=
 =?utf-8?B?N2M0c2daWG1BSEFzZnBCbEZkdDZtbFJYWkNJZFNCc0cwemRzUHhZelZiNDIv?=
 =?utf-8?B?N1lMSzdpRm81em9FM3h6SU5CQk1KaWE1MU0wU3drZDIwdUV3N0VDUlVGcWly?=
 =?utf-8?B?ZUlhOGQ4WVNaSnpDamt2ZUFoZGhhamhDV2NoN2h0S1YySm9ueEdmb1owalZy?=
 =?utf-8?B?dDloN0R1b2F4WEd0cmU5dU5UVWdRWm5YMXJZWXpUVkIrNG1ZZWVuaDVJV0VX?=
 =?utf-8?B?Rkl3TEFLcW45NHFZMDIrbWI3bEdaY1dpWXpuUTBqK294T1RFMkFyeHFvMi9X?=
 =?utf-8?B?RjV5MmN1U1ArRXJsMFdNRVR1aVpvNnBrVjQ2WUVFQ0FNVTVJVTEyVGZuQ1Za?=
 =?utf-8?B?YTFNWTRpdWpiWmozRlpDbUVMK3d5Mi9pS1ZkeW43V1RpQVNmMkZYcld0Q29C?=
 =?utf-8?B?b1Q0NCtUUzhvMm56clk0ejZJT1o3eVkzU0VpYWhYelN5NjhyOG1HUndGV0JV?=
 =?utf-8?B?NEZzaExDSlVDbE83LzNZUWVKcWVldTU5RER2Z2J1RExycURXS1N2cW83MHlw?=
 =?utf-8?B?YVNUY1pJNzh5MEJ0UFBmS1paSXA3L2hHL2NNY3BiamV3Nkl1bmNKVW11Z283?=
 =?utf-8?B?aW9qcUYwTVlsVGU1QUQ5d2E2RXlHdnRUdzZTaTJTYy9xczNKY09QT3JNYThO?=
 =?utf-8?B?Z3ZnZlExdW9YaUxtYisrTU1yVWZncHM4Q2FJS0hqNWRibVJBaktBbGlwa1oy?=
 =?utf-8?B?cEtsZTE5QW5oOVh6RGNMNSttUjVodDZtdEdRYmtUdWpTUWZ3Mkxyb1hqa1dJ?=
 =?utf-8?B?VDhMa0xpU3lLNS90cWdxN0JIR2tzeGNUQkhvY3lJRlZSTkFET1IvcVh3NFRh?=
 =?utf-8?B?U3pVY3BIaUVHZTNLbE5hTWFRcEplSTEvTFVDRzI0VmttM2FsVis3eTh1RXk1?=
 =?utf-8?B?R281cmMvY2FUd1daYXFDYlF5YWwxVXo5aHM0QWlmUnpUZDhkTTFTdU80QWtq?=
 =?utf-8?B?dDAxNTJrdGdGNEtEWDRzUEpLTkZ4WEVwOVI2d2V1UVJQS0l1TmUrUGYxc2JZ?=
 =?utf-8?B?SGFrTVhhNEJvWlZPSE5oZW1pUHRtemF1cU1PTHZhbkljS1JpYlVldz09?=
X-Exchange-RoutingPolicyChecked:
	dvjG+3koatxlo9r/t8OIIZOe8d2r5uQinnaw7sP9VBBK43+O+tEnEEnoMs6eE98nkjDvj9r9oCwsyRb3pmWoEt+k83JavVic8Dh3J5hzIm392t6FXYJ9LlcQsmaw3CRq+p1IzRTajhl9u1kdd4vVWS0D9IkH9/nFKt+VwXm30Miwow4TMZB500WJzvThI7gmSr3DN0iNf3LKzUoN4qTEXT5VkyI7qGADrR6AhLlUVXjnz7b/9Z8WT280y1xTJr59Pu2Js2OO7kKETifmppr5jONWAXlIlzAndSAeMlNH67IJj/ObIilIArWdBxgV9dLmE+O2rr8WinKC7hAf5RzxDw==
X-MS-Exchange-AntiSpam-ExternalHop-MessageData-ChunkCount: 1
X-MS-Exchange-AntiSpam-ExternalHop-MessageData-0:
	PZP7o7bG7oBz9bcKMva6Jc7Nd3UnTb3xXkkp/I2BkD4phxx+3M/ZZPvuadZemALS4p8kzxs9KNLZ1IAiKlpYfjfn6U3T/F+3Zze8bCFaGF0g/Z4PmABtrbFxFQNNbl7KxYhWQYvM7c+XSDKyKoVWsyoi2Wy91wWlcZABf7uLE0iN3H9t9LFIsOuNaJi2PSMUO/2b/6Z84R/ln+MHSPY/stdfZznjiczfY2JlPmnTUUkDT71iAkUujVa76F6tu/nNQ2xjiOB0YfSMrkImxBU6nASfSmGss8uI1nL+T5FnWfpE0g3fvtn0QG7dbsHwnspvoC4LJtBHKISP6brLfSPdEl9Ani4kGnRju0IFeyd3jk10F1L18nLAbmX3W/tEYbqO2N2uvsxv/WQrYT7w+OuK6UqKLrlFUgCS/GgJ7I1nruJKHfN0kbgQyearrmiXzTW2Fh+qzElkDhXA03LgwrXQjfDtHaqOTCkgyCRG3Iwu+BXX3xCoIv/A+0r974WMF+96yiWQoJHWqDE9TKuaqGT20Au0vGKmyiYz8Zeko+y/UzSkP6EwksHnfFgD8j0z1kOiKNgodnnckd0Wbqa516iyI3vn+mEeAccrxFIv0Wb/Dho=
X-OriginatorOrg: oracle.com
X-MS-Exchange-CrossTenant-Network-Message-Id: e17bfca7-f1d4-4d3c-9af4-08dee43b91e6
X-MS-Exchange-CrossTenant-AuthSource: MW6PR10MB7639.namprd10.prod.outlook.com
X-MS-Exchange-CrossTenant-AuthAs: Internal
X-MS-Exchange-CrossTenant-OriginalArrivalTime: 17 Jul 2026 19:42:43.7165
 (UTC)
X-MS-Exchange-CrossTenant-FromEntityHeader: Hosted
X-MS-Exchange-CrossTenant-Id: 4e2c6054-71cb-48f1-bd6c-3a9705aca71b
X-MS-Exchange-CrossTenant-MailboxType: HOSTED
X-MS-Exchange-CrossTenant-UserPrincipalName: xvnsDMgTXi7Gg/MqAn8OQ2uLzIl4xk8qbLUGSxEjA3NmPDHLZ5eKxWoD3otyigDprnZ9pSMmOEHHlkGR9Tgh/w==
X-MS-Exchange-Transport-CrossTenantHeadersStamped: MN2PR10MB4365
X-Proofpoint-Virus-Version: vendor=baseguard
 engine=ICAP:2.0.293,Aquarius:18.0.1143,Hydra:6.1.134,FMLib:17.12.100.49
 definitions=2026-07-17_05,2026-07-17_01,2025-10-01_01
X-Proofpoint-Spam-Details: rule=notspam policy=default score=0 spamscore=0
 mlxlogscore=999 lowpriorityscore=0 suspectscore=0 adultscore=0 phishscore=0
 malwarescore=0 mlxscore=0 bulkscore=0 classifier=spam adjust=0 reason=mlx
 scancount=1 engine=8.19.0-2606160000 definitions=main-2607170202
X-Authority-Analysis: v=2.4 cv=d+bFDxjE c=1 sm=1 tr=0 ts=6a5a85e0 cx=c_pps
 a=XiAAW1AwiKB2Y8Wsi+sD2Q==:117 a=XiAAW1AwiKB2Y8Wsi+sD2Q==:17
 a=6eWqkTHjU83fiwn7nKZWdM+Sl24=:19 a=z/mQ4Ysz8XfWz/Q5cLBRGdckG28=:19
 a=lCpzRmAYbLLaTzLvsPZ7Mbvzbb8=:19 a=xqWC_Br6kY4A:10 a=IkcTkHD0fZMA:10
 a=RAioF0-LDSMA:10 a=GoEa3M9JfhUA:10 a=VkNPw1HP01LnGYTKEx00:22
 a=jiCTI4zE5U7BLdzWsZGv:22 a=RD47p0oAkeU5bO7t-o6f:22 a=CZwKjaeMc4OMEihe6qMA:9
 a=3ZKOabzyN94A:10 a=QEXdDO2ut3YA:10
X-Proofpoint-Spam-Details-Enc: AW1haW4tMjYwNzE3MDIwMiBTYWx0ZWRfX9bV7uik0125Q
 64IU3Pp8A60JLOpdHTylVIUZ/ASZbmKZ/PeN99UHJ/79l4X20OhaGt+k1FQAiOgsYWtct4YiPLb
 OAE+UuBiKBixaoqbDfd8pWcB/rGJnqJyQCs7zKrliYyYoqwVWRL0PUDAyXGaW25vQ24j3wADpPk
 7YXBwgI/XqGwYkjOgBdJkmEdu/WcpZahNladmW/XuwvgAhsjHxZCyffs5z1WoRfsKZldxhvXLcI
 achoqwSftZO4zGCrZwIpcQmvD2sUu2sauhVf5O9AC7HDUBgffyTtqfbHXM67yjRMbFoBJp0fit8
 uRMTBcU4P1JTsoZ35mWgtwkFHcxlze4z+qxUh7h2bmeHI7lTwYKULwfd01j8r+MgblmBbVh46Ls
 q3cdqjNCgY+MGCu83vn29GmsdD3zPy5GTO4cLy9nGrTgTA2QZ7WKYfk9ylTyeA+828jAZscAn9S
 8q0O6Qd7+uCH56hAhcg==
X-Proofpoint-GUID: N53aGlyA0r_yMeobRXR2mBms7iHFE7mo
X-Proofpoint-Spam-Info: AW1haW4tMjYwNzE3MDIwMiBTYWx0ZWRfX7fEdSWCftA9N
 wavlrl5i96FIN6qt6l+DYv90rkdwP/fJX7t7G1Isy9JGTzH89KMruEX2eyY7Wdj+v6idltDFXVW
 3jfcpcJf9F7WaDLN/KqqyX2bZP/NINKbSVtV2s20eF3ojNg0Gm3S
X-Proofpoint-ORIG-GUID: N53aGlyA0r_yMeobRXR2mBms7iHFE7mo

Hi,

The|wdeleg_getattr| counter tracks the number of times a|GETATTR|
operation conflicts with an outstanding write delegation. As such,
the name|wdeleg_getattr| does not accurately describe what the
counter represents.

Furthermore, this statistic probably does not belong in|nfsstats|.
Since there are no known user-space consumers of this counter, it
would be better to remove it altogether.

Thanks,
-Dai


On 7/16/26 7:28 AM, Chuck Lever wrote:
>
> On Thu, Jul 16, 2026, at 10:16 AM, Chuck Lever wrote:
>> On Thu, Jul 16, 2026, at 10:12 AM, Jeff Layton wrote:
>>> On Thu, 2026-07-16 at 10:04 -0400, Chuck Lever wrote:
>>>> On Thu, Jul 16, 2026, at 9:53 AM, Jeff Layton wrote:
>>>>> On Fri, 2026-06-19 at 16:40 -0400, Chuck Lever wrote:
>>>>>> On Fri, Jun 19, 2026, at 11:26 AM, Jeff Layton wrote:
>>>>>>> +		/* Per-version procedure counts */
>>>>>>> +		if (statp->vs_count) {
>>>>>>> +			static const int proc_attrs[] = {
>>>>>>> +				[2] = NFSD_A_SERVER_STATS_PROC2_OPS,
>>>>>>> +				[3] = NFSD_A_SERVER_STATS_PROC3_OPS,
>>>>>>> +				[4] = NFSD_A_SERVER_STATS_PROC4_OPS,
>>>>>>> +			};
>>>>>>> +			unsigned int i;
>>>>>>> +
>>>>>>> +			for (i = 0; i < prog->pg_nvers &&
>>>>>>> +			     i < ARRAY_SIZE(proc_attrs); i++) {
>>>>>>> +				if (!prog->pg_vers[i] ||
>>>>>>> +				    !statp->vs_count[i])
>>>>>>> +					continue;
>>>>>>> +				if (!proc_attrs[i])
>>>>>>> +					continue;
>>>>>>> +				if (nfsd_nl_fill_proc_ops(skb,
>>>>>>> +						proc_attrs[i],
>>>>>>> +						statp->vs_count[i],
>>>>>>> +						prog->pg_vers[i]->vs_nproc))
>>>>>>> +					goto err_cancel;
>>>>>>> +			}
>>>>>>> +		}
>>>>>>> +
>>>>>>> +#ifdef CONFIG_NFSD_V4
>>>>>>> +		/* NFSv4 individual operation counts */
>>>>>>> +		for (int i = 0; i <= LAST_NFS4_OP; i++) {
>>>>>>> +			struct nlattr *nest;
>>>>>>> +			u64 cnt;
>>>>>>> +
>>>>>>> +			cnt = percpu_counter_sum_positive(
>>>>>>> +				&nn->counter[NFSD_STATS_NFS4_OP(i)]);
>>>>>>> +
>>>>>>> +			nest = nla_nest_start(skb,
>>>>>>> +					NFSD_A_SERVER_STATS_PROC4OPS_OPS);
>>>>>>> +			if (!nest)
>>>>>>> +				goto err_cancel;
>>>>>>> +			if (nla_put_u32(skb, NFSD_A_SERVER_PROC_ENTRY_OP, i) ||
>>>>>>> +			    nla_put_u64_64bit(skb, NFSD_A_SERVER_PROC_ENTRY_COUNT,
>>>>>>> +					      cnt, NFSD_A_SERVER_PROC_ENTRY_PAD)) {
>>>>>>> +				nla_nest_cancel(skb, nest);
>>>>>>> +				goto err_cancel;
>>>>>>> +			}
>>>>>>> +			nla_nest_end(skb, nest);
>>>>>>> +		}
>>>>>>> +#endif
>>>>>> This loop open-codes the same nest that nfsd_nl_fill_proc_ops() builds just
>>>>>> above -- nla_nest_start(), nla_put_u32(PROC_ENTRY_OP),
>>>>>> nla_put_u64_64bit(PROC_ENTRY_COUNT), nla_nest_end() -- into the same
>>>>>> NFSD_A_SERVER_STATS_PROC4OPS_OPS attribute.  Could the helper be generalized
>>>>>> to take the per-op counter source so this is not a second copy of the same
>>>>>> code?
>>>>>>
>>>>>> The per-version block above skips empty versions:
>>>>>>
>>>>>> 	if (!prog->pg_vers[i] || !statp->vs_count[i])
>>>>>> 		continue;
>>>>>>
>>>>>> but this loop emits an entry for every op 0..LAST_NFS4_OP, zero-count ops
>>>>>> included.  Is that difference intentional?  Skipping zero counts here would
>>>>>> also trim the worst-case message size above.
>>>>>>
>>>>>> There is also a counter that this dump does not emit.  /proc/net/rpc/nfsd
>>>>>> prints a wdeleg_getattr line after proc4ops:
>>>>>>
>>>>>> 	seq_printf(seq, "\nwdeleg_getattr %lld",
>>>>>> 		percpu_counter_sum_positive(&nn->counter[NFSD_STATS_WDELEG_GETATTR]));
>>>>>>
>>>>>> incremented by nfsd_stats_wdeleg_getattr_inc().  Since the goal is to expose
>>>>>> the statistics currently available via /proc/net/rpc/nfsd, should
>>>>>> wdeleg_getattr get an attribute here too, so nfsstat over netlink does not
>>>>>> drop it relative to the procfs path?
>>>>>>
>>>>> The only thing in this review that is not addressed in my current
>>>>> series is the above comment, and I think we had agreed in an earlier
>>>>> email thread that this was approximately the same value as the counter
>>>>> for CB_GETATTR calls and so it's good enough for this purpose.
>>>>>
>>>>> Are you still ok with this approach?
>>>> In spite of the email quoting, I’ve still forgotten most of the context
>>>> of that conversation.
>>>>
>>>> Looking at this now, I think someone later could get an urge to add the
>>>> wdeleg_getattr statistic to netlink… for symmetry, because it smells like
>>>> technical debt, or it might actually be useful for something.
>>>>
>>>> IMHO we should include it now.
>>>>
>>> IDGI: what's the point of collecting that stat separately when we have
>>> stats for CB_GETATTR already? I'd prefer to avoid perpetuating
>>> wdeleg_getattr as a stat here, since it's not directly tied to the
>>> protocol in the same way as the others are.
>>>
>>> The only difference between the two is that if another client does a
>>> GETATTR for the fh while there is already a CB_GETATTR in flight,
>>> wdeleg_getattr gets bumped today, whereas CB_GETATTR counter does not
>>> (since there is only a single CB_GETATTR for that).
>>>
>>> Is that difference relevant? I think Dai added wdeleg_getattr
>>> originally, so I'd really like to hear his opinion on this.
>> OK, so you are actually re-litigating whether the stat should exist
>> at all. I confess I had forgotten that context.
>>
>> I’m arguing only that the netlink and procfs APIs should remain
>> equivalent, at least initially. Deleting the stat entirely probably
>> has no consequences right now, but let’s hear from Dai when the US
>> west coast wakes up.
> Another option is to keep the stat but report it some other way.
> It is arguable whether nfsstat is the proper mechanism to report
> the different reasons for sending a CB_GETATTR.
>
>

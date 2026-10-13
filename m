Received: from TYVP286CU001.outbound.protection.outlook.com (mail-japaneastazon11011041.outbound.protection.outlook.com [52.101.125.41])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id B3793352017
	for <linux-nfs@vger.kernel.org>; Tue, 13 Oct 2026 04:52:12 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=fail smtp.client-ip=52.101.125.41
ARC-Seal:i=2; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1791867134; cv=fail; b=bb8NLikJqVlIYELf7rg5hk14IdcWyhaRUs01/j/RYdSIiILqRTphLdRFSsxR9CDmRoFUw2Vk+YU5jQovbR8ON2dy7mEytixr8Gc3bWrrSQ6+oHdhS1HtCZnDzMPwHYRFIU2gQKEyX8DOAwL4aDkwk3rYDCUZgAs6pu3ZfZAj+ww=
ARC-Message-Signature:i=2; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1791867134; c=relaxed/simple;
	bh=yQIJlIEIxRPiLb9zdpXMFMGXJR/Xwv08ofcLl7F1zds=;
	h=From:To:CC:Subject:Date:Message-ID:Content-Type:MIME-Version; b=NMDoJFnDmqxayedGygvzQB7xnhxiNwi/i6357yelnMoD0zY2SSkZd1RoigIIJ4HehD2+tnvjJo/6xmHmUvqpZaVnEESe8/Kgz18DXJYOUgFl2BMJeY4lc2nz+T7ozRMEdOfsgO/BggqdjX7cUk2t/oHeorWFVTmXHDMQGyKW9PE=
ARC-Authentication-Results:i=2; smtp.subspace.kernel.org; dmarc=pass (p=reject dis=none) header.from=fujitsu.com; spf=pass smtp.mailfrom=fujitsu.com; dkim=pass (2048-bit key) header.d=fujitsu.com header.i=@fujitsu.com header.b=E2RJYcnJ; arc=fail smtp.client-ip=52.101.125.41
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=reject dis=none) header.from=fujitsu.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=fujitsu.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=fujitsu.com header.i=@fujitsu.com header.b="E2RJYcnJ"
ARC-Seal: i=1; a=rsa-sha256; s=arcselector10001; d=microsoft.com; cv=none;
 b=KZBMP4c+J11AB/i9ZQE9oKSI4wvLd4gp7WL6MaEjoKUvsn2PXK4OJxeoaGGsHiy6z+y1n3+cyaxes9PGfBZm9ndtsPsMSCOph+GXnlSzTDKMur5eLmYrarqralrYREcHQU/jx/vVr8UamxwmL5H1t3UuDy07HEUo0eZ8CBjCDNOvsaJQt7G3Ukr/vWBTfJEq5/QIA8DaK5yskIx86knZW8XDpVcrcJ8qgLfe8ltVdGAQKZzFXqJ38fJW7S1eylPKej/Z7sMguBpurUXpug6lykb5NotVGErsyQRnjLEV8LsqIuiPSc8a11Wao1rcdUeEG4/fDIPkrhfGO6+HmfNAZA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=microsoft.com;
 s=arcselector10001;
 h=From:Date:Subject:Message-ID:Content-Type:MIME-Version:X-MS-Exchange-AntiSpam-MessageData-ChunkCount:X-MS-Exchange-AntiSpam-MessageData-0:X-MS-Exchange-AntiSpam-MessageData-1;
 bh=LBVtmGpXAdfD89TC56V9FufAFpRbAdDcxOwcAiWP2J0=;
 b=bs3ySV8VM+RHujvNEhABpL9/EXmXKzR5YZRBliI6NplUyUIaD3qwB0meqbG5is7HzoAiAueDTPhQB1/RnF6IwG8gXpBSzX2mg83PlFry6DJ2jQ0BVM2BOPv9h5tXX2nK/RX5G8MvsPva7nATI4LSKi8RR815FZ5aUM6+etypIDa6UWx3hiNOGd0685j4tcyYF1d2LIqbHfO1SnJQDqPHmX3dXq1LRfBmEY3adwWrd4t9kv539QGJskueO3WoQqMNe5VZitdGy25oElednTNt0kH19S4EZJO1ROYohDCwOUV4snvN5l/r1BV+Awrg9JiGs7gZm7igsdo4tUuUGiYDAw==
ARC-Authentication-Results: i=1; mx.microsoft.com 1; spf=pass
 smtp.mailfrom=fujitsu.com; dmarc=pass action=none header.from=fujitsu.com;
 dkim=pass header.d=fujitsu.com; arc=none
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=fujitsu.com;
 s=selector1;
 h=From:Date:Subject:Message-ID:Content-Type:MIME-Version:X-MS-Exchange-SenderADCheck;
 bh=LBVtmGpXAdfD89TC56V9FufAFpRbAdDcxOwcAiWP2J0=;
 b=E2RJYcnJZXSucnq+lq4Gx+uBDgHKHFPrX8WuOPWzsSN2MYFevQ0Ckv2YsapNF+yHDay9Lnr3WcIgJiZnsvWDv/DYploT36EtAlUGkzK8hrWcH3EDfzjt9OMsS1jhG5n2vx2+kgEB/zAQUFS+zSZPm0vK2A/rAdhrknjJb1ZO0AMQo9hWlL73+oSMwEwzZmSE3VEYifoZzfy3DcPrDHkVdRBtWBG4rYucFcBaqqbWaLPRDJGUvmqVL1OaTbt2R9H4QLsAHlAzOIr7Eaccmj0QAQulAXE46sALt7Nq1Q8PGY/M+MeKiy6dmx0eD4TxIh07uvchD4ZfEabmMWjn/7NyDg==
Received: from TYCPR01MB11476.jpnprd01.prod.outlook.com
 (2603:1096:400:3b8::10) by TYYPR01MB7086.jpnprd01.prod.outlook.com
 (2603:1096:400:de::11) with Microsoft SMTP Server (version=TLS1_2,
 cipher=TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384) id 15.21.496.23; Tue, 13 Oct
 2026 04:52:10 +0000
Received: from TYCPR01MB11476.jpnprd01.prod.outlook.com
 ([fe80::38e7:2:fa52:18cc]) by TYCPR01MB11476.jpnprd01.prod.outlook.com
 ([fe80::38e7:2:fa52:18cc%4]) with mapi id 15.21.0496.021; Tue, 13 Oct 2026
 04:52:10 +0000
From: "Seiichi Ikarashi (Fujitsu)" <s.ikarashi@fujitsu.com>
To: "'Jorge.Mora@netapp.com'" <Jorge.Mora@netapp.com>
CC: "'linux-nfs@vger.kernel.org'" <linux-nfs@vger.kernel.org>
Subject: [PATCH] nfstest: DELEG: accept the attribute delegation
Thread-Topic: [PATCH] nfstest: DELEG: accept the attribute delegation
Thread-Index: Ad1Xz153sOI/Sq/DQq6di7ahf3skFw==
Date: Tue, 13 Oct 2026 04:52:10 +0000
Message-ID:
 <TYCPR01MB114760421C10FF6E222E79F5D889E2@TYCPR01MB11476.jpnprd01.prod.outlook.com>
Accept-Language: ja-JP, en-US
Content-Language: ja-JP
X-MS-Has-Attach:
X-MS-TNEF-Correlator:
msip_labels:
 MSIP_Label_1e92ef73-0ad1-40c5-ad55-46de3396802f_ActionId=33660271-4cef-4f0f-ae40-be9a7666b7ca;MSIP_Label_1e92ef73-0ad1-40c5-ad55-46de3396802f_ContentBits=0;MSIP_Label_1e92ef73-0ad1-40c5-ad55-46de3396802f_Enabled=true;MSIP_Label_1e92ef73-0ad1-40c5-ad55-46de3396802f_Method=Privileged;MSIP_Label_1e92ef73-0ad1-40c5-ad55-46de3396802f_Name=FUJITSU-PUBLIC?;MSIP_Label_1e92ef73-0ad1-40c5-ad55-46de3396802f_SetDate=2026-10-09T09:18:43Z;MSIP_Label_1e92ef73-0ad1-40c5-ad55-46de3396802f_SiteId=a19f121d-81e1-4858-a9d8-736e267fd4c7;MSIP_Label_1e92ef73-0ad1-40c5-ad55-46de3396802f_Tag=10,
 0, 1, 1;
authentication-results: mx.microsoft.com 1; dkim=none (message not signed)
 header.d=none;dmarc=none action=none header.from=fujitsu.com;
x-ms-publictraffictype: Email
x-ms-traffictypediagnostic: TYCPR01MB11476:EE_|TYYPR01MB7086:EE_
x-ms-office365-filtering-correlation-id: 47378a61-de66-46dd-1254-08df28e5bd75
x-ms-exchange-senderadcheck: 1
x-ms-exchange-antispam-relay: 0
x-microsoft-antispam:
 BCL:0;ARA:13230040|376014|1800799024|366016|23010399003|38070700021|56012099006|11063799006|261009223027099003|10067099003|18002099003|1580799027;
x-microsoft-antispam-message-info:
 psOb1HPhUpZi9oaGuCgC4gX+L2zr88bRaY5jT+HNG1hlVR6ALZ/kxU0kybROe7++5jCchpY4ZpAInhoNiAswtdS0V+Ays8r7zGMBMk5WO+jXtijgfMM/VjbHVUMiXtDwu/72WzkZ5J6ceh8VQnKiy5C7ctdZVX0cKCF+jYbo6FTY3tDpkEZYlqgUAx7kSBJLX/Uc4Sq+uTuXWmqYzWCHaGbub1l0FTu9lxij1LjX3f91Jeiar2ShyVSqolZRTMtCBUBwgQHRAS45LH+gXpTfEXDdsYQu+ZkpRmCEK74oGtPBvrbmAhOsBidudcsRJdGDuTj74mkjqgJ+eXCjgKZ5/D7Ww/7lGuA0BbNqiK9Y7w0PmUx6sadBCnaShpbf6nKiks/2mo++k2azh8sNtegRAHUe1HRe3WKloo6Hm/B6wSX205YZEijuoxvFGuoIt9hl+4W0JOVUXALOxZXiWMTMwbptCY9a9TuJ7WS7Lwl617u+B8Idt/dsJV6K/IibZv9YHxrK2VkGkY88NI9m730+gJMgaxjsD8t15s+acnuIPxs5Ac3TbA8pwvzade9fRFlucVLvGIJ93XzjpSCF7EQdkR3GRuqsxHd2Ff3pe1nBHOFzvY1vL3F6Rh6x0w/HPPyzt/e2V9I0kNbmVlTj3unBK3fNEhsKdSMyx/AF4L9KLehyK5Is+0H2kCoCkI6EJuPkqRzZxVqVqso4M25ODrMKJm3ohUnX+iCSVxruWsOJ3bauduiAsvn7ItshzL0oUKX1
x-forefront-antispam-report:
 CIP:255.255.255.255;CTRY:;LANG:ja;SCL:1;SRV:;IPV:NLI;SFV:NSPM;H:TYCPR01MB11476.jpnprd01.prod.outlook.com;PTR:;CAT:NONE;SFS:(13230040)(376014)(1800799024)(366016)(23010399003)(38070700021)(56012099006)(11063799006)(261009223027099003)(10067099003)(18002099003)(1580799027);DIR:OUT;SFP:1101;
x-ms-exchange-antispam-messagedata-chunkcount: 1
x-ms-exchange-antispam-messagedata-0:
 =?iso-2022-jp?B?ejhhWnFUSHN5QVp4TUljRjNUVG5IQzFxRVFmcTN3N1FTcFh4d1BTeU9C?=
 =?iso-2022-jp?B?V2crL245eHpJNmZXb0xwS3lhVkp3aW0wY1RCOUlBK1BkTmtsbmk0QlNz?=
 =?iso-2022-jp?B?QjZROC9wdzVzVTF0VXZwaVE3dHFRZVkrTEZ2SzRYSTZBQUN0VGxEMXIy?=
 =?iso-2022-jp?B?SWNQYkl5OU5ZYjRWaDBMekk3cFY0UnFoRGtKdW9yM04wRVI2TjVqYUJp?=
 =?iso-2022-jp?B?WllEUnI1SUxpMndmbHlLd0NVU1NoTkFuTDVsQkZLVmZaTERrVzNWTnRZ?=
 =?iso-2022-jp?B?akZMMU9KWDFzQjZ3WHNXbXRqSDl6SEFLeHJrUk1mMHNMUElCdUhaTldp?=
 =?iso-2022-jp?B?TXdHcjd5ZGlrb3lHQmhYM3k5TFFkUlUybUNKZDFHYlJUazMvZEpmM2xz?=
 =?iso-2022-jp?B?dlZZbVdEclhyYVU1WXNUakhqb2IvenBBSnZSQmhBWkIxZjhUakFIakpB?=
 =?iso-2022-jp?B?ZXBDZXBBVFRxOVhaUFVvZDU3NExENTlQMGRKOVpQc1FzbzBwZWRQWnF0?=
 =?iso-2022-jp?B?TTlBVG1BbEc5MG9rRTNSdEhldmFNYnBIQUxuYkIzRG44THBVYk9TZU9l?=
 =?iso-2022-jp?B?U0ZmTHliZnl2YTZuMFpPcFhrcXE1d0VtY2o4RjQrcVNIZ2JESHBVK2sv?=
 =?iso-2022-jp?B?Y2MvQktRRnR4U0VUUkNJb0F5RGhoT3hDcjljUVVlTExtNUNhb2kvbVls?=
 =?iso-2022-jp?B?aCsvMDV1TFJxL2loZUh3TWhvdk5zOGpaWUIvdko0eDVrOE93N3Q1Y2h4?=
 =?iso-2022-jp?B?cXdmcUVjRjB5T2JUaW1aM2x5eFRMYWhXMlNKeVB0YWJYejROMFpzU2E0?=
 =?iso-2022-jp?B?YjFpVEg3aEY3cS9xYWFhYXVQVUZCOG5CTjduZk1jUWFJR0xSWFpOdW45?=
 =?iso-2022-jp?B?K0s2MWNKRk11LzNyUnBodkxGSUZ6Nmh2Y09KaXBmL2tmNGgyWUZUalNY?=
 =?iso-2022-jp?B?STB5dDBvQlRCdTlmZ1VTWlZyK3hWZW5manErdGgxdzhOa2paVElmVWJZ?=
 =?iso-2022-jp?B?QlEyTDZXZmg1WHc2K3h2ZHJtNnpKb0R1MzllZVBQNkRNcjNvZDk4WWdN?=
 =?iso-2022-jp?B?UmpCbVozYWRpZ2FJK0ZPS1pNVTBIQnp2MTJuQmxsOFc5aXUvUVdKamh0?=
 =?iso-2022-jp?B?WDhnUlNGUm1lQTE3RUhJRmZpYVhsUUFpKzFFSDdtWDRHRlBUS2xRN1I3?=
 =?iso-2022-jp?B?UmgvSTNUaWdYbm55aUJHOWlrVDIvUUszMGdneFZyVDlUQm5XUXppeEdB?=
 =?iso-2022-jp?B?TW9KdTNGQkZNa2Z3dWhSN0JQbWcwRUVwTUJqeU1ESEdmb2Z4NmQwak5Q?=
 =?iso-2022-jp?B?cUNpZ00zVUtnbzhFQkFNS1lqSmFjNUlIalpsOTJaa1JUTzhnVENzbmxP?=
 =?iso-2022-jp?B?VytQeSsyVk9BVGIyaktvcjJBWDdyU3lIektDdzRFc0pQV2RYazdVd0Y4?=
 =?iso-2022-jp?B?R0hWNGtDa2paRGhmQjBaOFc1aEJlTnNzckJGQkxyRFAxU2Z2cEw1eWo1?=
 =?iso-2022-jp?B?YWtWNEU3RFNWbk12ZC92QXcwR3padzJ3bG40THY3U0Y4NkU3TEtVRC95?=
 =?iso-2022-jp?B?YW1JZnp5bWJXcTRGeWVaMVUvQUg2b1p1aDNjKzZoNmNmSXBkeHU0KzNh?=
 =?iso-2022-jp?B?amN0eWd4OGc1Y21Jd0ZTd2FpTjY0bCt6cS9XWFJFUjYzV3RBc0QyaXRF?=
 =?iso-2022-jp?B?T3MxL0J5REhTbHRKMUw0VmFSWDVEbUwyUmlDb2hNQUdjU1FyeW1ZaENr?=
 =?iso-2022-jp?B?WG0rRU1mbWZrQk9iVEtyUHI1OHpSM1p1aU0xalFXTFlPaUtLd0pmUVRT?=
 =?iso-2022-jp?B?TVk2UE9YMWl4bUxDclduK29UODVDT0FVM1pSMUNPbVl3L2tQSnNNbjQ2?=
 =?iso-2022-jp?B?SXdEOWc5WFB5WjNKdUVQV2lKMUd5aFFTUXRpRmg1TVJCNVZwMFhGd2Zh?=
 =?iso-2022-jp?B?cEVJOWhvRy9kcWlOdlBEcjgwYjhkdXA3eUlhNmk5YnJvR2xYTWM2V0wx?=
 =?iso-2022-jp?B?YWJtb2hEZVh4eVNYQ1duVHZkVUV4WG1Eb1V2cnlQUEZ0UmEwZkN4c3Ny?=
 =?iso-2022-jp?B?VXc3K3ZUajR2ODFDdGpUOEhJTGNpK1cvdDZrV3hoRXhzMFRIYll5VmUv?=
 =?iso-2022-jp?B?UTJNU3B2b3ZsUGF3M2NKZSs1VVV5K1V1eTRUdHREeGJmeWFMQ2lpclJi?=
 =?iso-2022-jp?B?dEtiOXdoa3d4QWlUZEZrb0ZqTG9pWG5HMXdudm45ZUlSRWlmMW4ydWRE?=
 =?iso-2022-jp?B?ZG1zTlJ3OVlFU2w2cHVDdGRzc0cxRUFPWTRlRzZBRnFZVzlFcmhUK0gz?=
 =?iso-2022-jp?B?Q2ZFTk5aSmgzUGx5dWVhVTdJRDduQmU1ckcwL3FMa1Y0S3dJQWhEUjEz?=
 =?iso-2022-jp?B?VU42UHBneFY3SE4vczlVbmRhRWZYS0c1SkZuZlEyNm05MjdBaytMaExK?=
 =?iso-2022-jp?B?WFJiWVZDMFJCVXhIVzVsL1JKcGFtYmJTSk9VbW1NM3RlS0J4NWRyZitk?=
 =?iso-2022-jp?B?SU83R1QyOUxMOEw0dk1LMHltcmo1MEtKMXhJdz09?=
Content-Type: text/plain; charset="iso-2022-jp"
Content-Transfer-Encoding: quoted-printable
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
X-Exchange-RoutingPolicyChecked:
	Rrwcq0+mzIuLIih8e+HIOhYtMX+DXqXruhJW6ElnhgrFJaY+YRyOHZSq/cyko0iT6I4yd1ofjK94t7Vo/HrkB++BBRscadIvsOfmOSMo5mQD+L0l6B6B2N+Z/RM+3gYVGmgCyshgZn+91Ux4tHdR/WhSe2Sgay28Iv5pIVDGfNYxyC1lknQPbjyCHb6oUi+M0CqoG51R0rTFhnLRcGmrB9OtOmEfAEmwlEjlVb3Fe6opZ4vbWv7CgxuDI/28XhCrzqXYb2qsUdX/Ca8l78AnKo2zMmUW1RzdntD5nw1c+XgHfo2vA9vTBFOegaKGEociecl0YFzRB6rhoYA5gQPmzA==
X-OriginatorOrg: fujitsu.com
X-MS-Exchange-CrossTenant-AuthAs: Internal
X-MS-Exchange-CrossTenant-AuthSource: TYCPR01MB11476.jpnprd01.prod.outlook.com
X-MS-Exchange-CrossTenant-Network-Message-Id: 47378a61-de66-46dd-1254-08df28e5bd75
X-MS-Exchange-CrossTenant-originalarrivaltime: 13 Oct 2026 04:52:10.0868
 (UTC)
X-MS-Exchange-CrossTenant-fromentityheader: Hosted
X-MS-Exchange-CrossTenant-id: a19f121d-81e1-4858-a9d8-736e267fd4c7
X-MS-Exchange-CrossTenant-mailboxtype: HOSTED
X-MS-Exchange-CrossTenant-userprincipalname: GKAjFfTFln732ZZBQaQKIb1/HoOGRmC9cCSsLVA32epIZjGLHwtWt08jPE4QhwO8i3kugA6YIHZz8WjITs7yq6FLhXu6gSLNtG/axLv2GuQ=
X-MS-Exchange-Transport-CrossTenantHeadersStamped: TYYPR01MB7086

Since the commit 6237a17, the timestamp delegation is enabled
by default. Then OPEN_DELEGATE_WRITE_ATTRS_DELEG (5) is often
returned as deleg_type instead of OPEN_DELEGATE_WRITE (2) as
per RFC 9754. Current NFStest cannot handle this and fails
with "FAIL: WRITE delegation should be granted" and others.

Let's accept OPEN_DELEGATE_WRITE_ATTRS_DELEG in the case that
OPEN_DELEGATE_WRITE has been expected, at least.

Signed-off-by: Seiichi Ikarashi <s.ikarashi@jp.fujitsu.com>
---
 nfstest/nfs_util.py      | 10 +++++++---
 packet/nfs/nfs4.py       |  4 ++--
 packet/nfs/nfs4.x        |  4 +++-
 packet/nfs/nfs4_const.py |  4 ++++
 test/nfstest_delegation  |  2 ++
 test/nfstest_file        |  4 ++--
 test/nfstest_pnfs        |  2 +-
 7 files changed, 21 insertions(+), 9 deletions(-)

diff --git a/nfstest/nfs_util.py b/nfstest/nfs_util.py
index cf8d6ae..393b073 100644
--- a/nfstest/nfs_util.py
+++ b/nfstest/nfs_util.py
@@ -567,7 +567,11 @@ class NFSUtil(Host):
             save_pktcall =3D pktcall
             xid =3D pktcall.rpc.xid
             open_str =3D "RPC.xid =3D=3D %d and NFS.status =3D=3D 0 and NF=
S.resop =3D=3D %d" % (xid, OP_OPEN)
-            if deleg_type is not None:
+            if deleg_type =3D=3D OPEN_DELEGATE_READ:
+                open_str +=3D " and NFS.delegation.deleg_type in %s" % ((O=
PEN_DELEGATE_READ, OPEN_DELEGATE_READ_ATTRS_DELEG),)
+            elif deleg_type =3D=3D OPEN_DELEGATE_WRITE:
+                open_str +=3D " and NFS.delegation.deleg_type in %s" % ((O=
PEN_DELEGATE_WRITE, OPEN_DELEGATE_WRITE_ATTRS_DELEG),)
+            elif deleg_type is not None:
                 open_str +=3D " and NFS.delegation.deleg_type =3D=3D %d" %=
 deleg_type
=20
             # Find OPEN reply to get filehandle of file
@@ -591,7 +595,7 @@ class NFSUtil(Host):
                 filehandle =3D claimfh
=20
             open_stateid =3D pktreply.NFSop.stateid.other
-            if pktreply.NFSop.delegation.deleg_type in [OPEN_DELEGATE_READ=
, OPEN_DELEGATE_WRITE]:
+            if pktreply.NFSop.delegation.deleg_type in [OPEN_DELEGATE_READ=
, OPEN_DELEGATE_WRITE, OPEN_DELEGATE_READ_ATTRS_DELEG, OPEN_DELEGATE_WRITE_=
ATTRS_DELEG]:
                 deleg_stateid =3D pktreply.NFSop.delegation.stateid.other
             else:
                 deleg_stateid =3D None
@@ -1723,7 +1727,7 @@ class NFSUtil(Host):
         (self.filehandle, self.open_stateid, self.deleg_stateid) =3D self.=
find_open(filename=3Dfilename, **kwargs)
         if self.open_stateid:
             self.stid_map[self.open_stateid] =3D "OPEN stateid"
-        if self.deleg_stateid and (write is None or self.openreply.NFSop.d=
elegation.deleg_type =3D=3D deleg_type):
+        if self.deleg_stateid and (write is None or self.openreply.NFSop.d=
elegation.deleg_type in [OPEN_DELEGATE_WRITE, OPEN_DELEGATE_WRITE_ATTRS_DEL=
EG]):
             # Delegation stateid should be used for I/O
             self.stateid =3D self.deleg_stateid
             self.stid_map[self.deleg_stateid] =3D "DELEG stateid"
diff --git a/packet/nfs/nfs4.py b/packet/nfs/nfs4.py
index 1cd48da..6911a40 100644
--- a/packet/nfs/nfs4.py
+++ b/packet/nfs/nfs4.py
@@ -2455,9 +2455,9 @@ class open_delegation4(BaseObj):
=20
     def __init__(self, unpack):
         self.set_attr("deleg_type", open_delegation_type4(unpack))
-        if self.deleg_type =3D=3D const.OPEN_DELEGATE_READ:
+        if self.deleg_type in [const.OPEN_DELEGATE_READ, const.OPEN_DELEGA=
TE_READ_ATTRS_DELEG]:
             self.set_attr("read", open_read_delegation4(unpack), switch=3D=
True)
-        elif self.deleg_type =3D=3D const.OPEN_DELEGATE_WRITE:
+        elif self.deleg_type in [const.OPEN_DELEGATE_WRITE, const.OPEN_DEL=
EGATE_WRITE_ATTRS_DELEG]:
             self.set_attr("write", open_write_delegation4(unpack), switch=
=3DTrue)
         elif self.deleg_type =3D=3D const.OPEN_DELEGATE_NONE_EXT:
             self.set_attr("whynone", open_none_delegation4(unpack), switch=
=3DTrue)
diff --git a/packet/nfs/nfs4.x b/packet/nfs/nfs4.x
index a9c2b6e..cc26e51 100644
--- a/packet/nfs/nfs4.x
+++ b/packet/nfs/nfs4.x
@@ -1746,7 +1746,9 @@ enum open_delegation_type4 {
     OPEN_DELEGATE_NONE      =3D 0,
     OPEN_DELEGATE_READ      =3D 1,
     OPEN_DELEGATE_WRITE     =3D 2,
-    OPEN_DELEGATE_NONE_EXT  =3D 3 /* New to NFSv4.1 */
+    OPEN_DELEGATE_NONE_EXT  =3D 3, /* New to NFSv4.1 */
+    OPEN_DELEGATE_READ_ATTRS_DELEG   =3D 4,
+    OPEN_DELEGATE_WRITE_ATTRS_DELEG  =3D 5
 };
=20
 enum open_claim_type4 {
diff --git a/packet/nfs/nfs4_const.py b/packet/nfs/nfs4_const.py
index b76cbf7..b788e21 100644
--- a/packet/nfs/nfs4_const.py
+++ b/packet/nfs/nfs4_const.py
@@ -1021,12 +1021,16 @@ OPEN_DELEGATE_NONE     =3D 0
 OPEN_DELEGATE_READ     =3D 1
 OPEN_DELEGATE_WRITE    =3D 2
 OPEN_DELEGATE_NONE_EXT =3D 3  # New to NFSv4.1
+OPEN_DELEGATE_READ_ATTRS_DELEG  =3D 4
+OPEN_DELEGATE_WRITE_ATTRS_DELEG =3D 5
=20
 open_delegation_type4 =3D {
     0 : "OPEN_DELEGATE_NONE",
     1 : "OPEN_DELEGATE_READ",
     2 : "OPEN_DELEGATE_WRITE",
     3 : "OPEN_DELEGATE_NONE_EXT",
+    4 : "OPEN_DELEGATE_READ_ATTRS_DELEG",
+    5 : "OPEN_DELEGATE_WRITE_ATTRS_DELEG",
 }
=20
 # Enum open_claim_type4
diff --git a/test/nfstest_delegation b/test/nfstest_delegation
index 717fa97..e51feb0 100755
--- a/test/nfstest_delegation
+++ b/test/nfstest_delegation
@@ -283,6 +283,8 @@ deleg_map =3D {
 deleg_str =3D {
     OPEN_DELEGATE_READ  : "READ",
     OPEN_DELEGATE_WRITE : "WRITE",
+    OPEN_DELEGATE_READ_ATTRS_DELEG  : "READ ATTRS",
+    OPEN_DELEGATE_WRITE_ATTRS_DELEG : "WRITE ATTRS",
 }
=20
 def file_lock(fd, open_type, absfile, lock_offset=3D0, lock_len=3D0):
diff --git a/test/nfstest_file b/test/nfstest_file
index eb3ac93..fb99289 100755
--- a/test/nfstest_file
+++ b/test/nfstest_file
@@ -319,7 +319,7 @@ if not fh_list and (dirfhcrc32 is not None or len(paths=
) =3D=3D 0):
                         for item in pkt.nfs.array:
                             if item.resop =3D=3D nfs4.OP_OPEN:
                                 stid_list.append(crc32(item.stateid.other)=
)
-                                if item.delegation.deleg_type in [nfs4.OPE=
N_DELEGATE_READ, nfs4.OPEN_DELEGATE_WRITE]:
+                                if item.delegation.deleg_type in [nfs4.OPE=
N_DELEGATE_READ, nfs4.OPEN_DELEGATE_WRITE, nfs4.OPEN_DELEGATE_READ_ATTRS_DE=
LEG, nfs4.OPEN_DELEGATE_WRITE_ATTRS_DELEG]:
                                     stid_list.append(crc32(item.delegation=
.stateid.other))
                             elif item.resop =3D=3D nfs4.OP_GETFH:
                                 fh_list.append(crc32(item.fh))
@@ -354,7 +354,7 @@ if fh_list:
                         continue
                     if item.resop =3D=3D nfs4.OP_OPEN:
                         stid_list.append(crc32(item.stateid.other))
-                        if item.delegation.deleg_type in [nfs4.OPEN_DELEGA=
TE_READ, nfs4.OPEN_DELEGATE_WRITE]:
+                        if item.delegation.deleg_type in [nfs4.OPEN_DELEGA=
TE_READ, nfs4.OPEN_DELEGATE_WRITE, nfs4.OPEN_DELEGATE_READ_ATTRS_DELEG, nfs=
4.OPEN_DELEGATE_WRITE_ATTRS_DELEG]:
                             stid_list.append(crc32(item.delegation.stateid=
.other))
                     elif item.resop =3D=3D nfs4.OP_GETFH:
                         fh_list.append(crc32(item.fh))
diff --git a/test/nfstest_pnfs b/test/nfstest_pnfs
index 71e91dd..8632896 100755
--- a/test/nfstest_pnfs
+++ b/test/nfstest_pnfs
@@ -335,7 +335,7 @@ class pNFSTest(TestUtil):
             index +=3D 1
             nio_total +=3D nio
         if nio_total =3D=3D 0:
-            if iomode =3D=3D LAYOUTIOMODE4_READ and stid_str =3D=3D 'DELEG=
' and openfh['deleg_type'] =3D=3D OPEN_DELEGATE_WRITE:
+            if iomode =3D=3D LAYOUTIOMODE4_READ and stid_str =3D=3D 'DELEG=
' and openfh['deleg_type'] in [OPEN_DELEGATE_WRITE, OPEN_DELEGATE_WRITE_ATT=
RS_DELEG]:
                 self.test(True, "%s should not be sent to DS when holding =
a write delegation" % io_str)
             elif openfh.get('dtcached'):
                 self.test(True, "%s should not be sent to DS if data has b=
een cached" % io_str)

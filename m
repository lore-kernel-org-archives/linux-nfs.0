Authentication-Results: smtp.subspace.kernel.org; arc=pass header.oldest-pass=0 smtp.remote-ip=52.103.20.22
ARC-Seal: i=2; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=pass;
	t=1793953030;
	b=PfrsjFp2oMiBrhC6OFMl6Smt4eBoxph7vX6077zEVHJi9l34pMr6TPn5YzP4nv/1pX0Z
	 OzsKBZfPTJarP2MOvgba+Nhk72x81tjVR1ZeL6nrH6qkM3Z6iILKkzC/hNNuhxRcc6G9J
	 i4sNEjFH9NQIln8rUVVbt0Gh7yMMUtpInsNTIOe/zCT3N7oO9QB08FOgRvYVYlZ6CsAeW
	 H1BcB2TWFBxeMNOdTMYL3a9y7BuS/bmzZUeB44L+210YkGVtOqFG1ne/Gi/qdnVphYHvb
	 81vDb1EooU72X1c51lhrZf8l8tZgyBLgKI401gt1J02Iin1a+cea2OV0T+CfYkgl0qg==
ARC-Message-Signature: i=2; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1793953030;
	h=DMARC-Filter:DKIM-Signature:Received:Received:From:To:CC:Subject:
	 Thread-Topic:Thread-Index:Date:Message-ID:Accept-Language:
	 Content-Language:X-MS-Has-Attach:X-MS-TNEF-Correlator:
	 x-ms-publictraffictype:x-ms-traffictypediagnostic:
	 x-ms-office365-filtering-correlation-id:x-microsoft-antispam:
	 x-microsoft-antispam-message-info:
	 x-ms-exchange-antispam-messagedata-chunkcount:
	 x-ms-exchange-antispam-messagedata-0:Content-Type:
	 Content-Transfer-Encoding:MIME-Version:X-OriginatorOrg:
	 X-MS-Exchange-CrossTenant-AuthAs:X-MS-Exchange-CrossTenant-AuthSource:
	 X-MS-Exchange-CrossTenant-RMS-PersistedConsumerOrg:
	 X-MS-Exchange-CrossTenant-Network-Message-Id:
	 X-MS-Exchange-CrossTenant-originalarrivaltime:
	 X-MS-Exchange-CrossTenant-fromentityheader:
	 X-MS-Exchange-CrossTenant-id:
	 X-MS-Exchange-CrossTenant-rms-persistedconsumerorg:
	 X-MS-Exchange-Transport-CrossTenantHeadersStamped;
	bh=ho5qakr9siiQapdGeDW6RHnIhweQGS1Y7MDmDmUNmUk=;
	b=xA2kVVS6b8AdsTV1zDs1zmDjFZ7zSTHIkF2tzp3m20cSe+yPlbLKFL0xF2xccMAVCtTw
	 WLDPYsnuSo0OpbcikhSJRwQ+msRwvSLxBVZcu3OYu+2rL0ggOKpSA4z+TIbqFPh0f+weU
	 brpBV+zaM5oK+HzMXz+eXHwyt+2s8srY0OQ6ini0tMHx2oOf9dlVvq9G8oeq2HQn42h5P
	 n1uX15Wf2XOhQbTmSVAr4+qrBW9Gr+aA1p1bwFGZeX143f7x8lCwlvkeZE7S8wN0kQ5ws
	 FSY2GyVxu9ZpyWWdkQpHJmVHEwfzVs9zO6PAV/+Xw0/cd+Gwj2NC+wLkS6SVOc+d7Jw==
ARC-Authentication-Results: i=2; smtp.subspace.kernel.org; 
	dmarc=pass header.from=outlook.com;
	spf=pass smtp.mailfrom=outlook.com;
	dkim=pass header.d=outlook.com header.i=@outlook.com header.a=rsa-sha256 header.s=selector1 header.b=TV0NvvMa;
	arc=pass header.oldest-pass=0 smtp.remote-ip=52.103.20.22
Received: from CH1PR05CU001.outbound.protection.outlook.com (mail-northcentralusazolkn19010022.outbound.protection.outlook.com [52.103.20.22])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange ECDHE (secp384r1) server-signature ECDSA (prime256v1) server-digest SHA256)
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 06663606A32E;
	Fri,  6 Nov 2026 08:17:09 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.4.2 smtp.subspace.kernel.org 06663606A32E
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=outlook.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=outlook.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key, unprotected) header.d=outlook.com header.i=@outlook.com header.a=rsa-sha256 header.s=selector1 header.b=TV0NvvMa
ARC-Seal: i=1; a=rsa-sha256; s=arcselector10001; d=microsoft.com; cv=none;
 b=fdJ+b3QFQDLSGR9DyM+rwt1cptWtIxc+EPcr7kXLw5uzrjGmhmei6QZ2H09cIwwgDHHGNRXRV5kZfmd0SGHfiN5nkRbtqdWsYnRviS7z8aG/W+1jLVusi7mEtkgodqMlITJE4ijUY3v2SwFeoCRilUAcAy1fu7ehU684on+rsmCvZTC7cFOwN/Igj+vzRaXaEwSFKUsJFbUaoVqJkRQjN7FqhY+505Z+feCAsPYv4qzbQ3OlU/77HpjYD3QAQeuNXqznduK4uKyJNATuAZOkqu6A9fHVV+02fphAeHaIb7wYwpvoptxPCCkGa3oITAkRGLw8oygC2CRfN1FJdKRXdA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=microsoft.com;
 s=arcselector10001; h=From:Date:Subject:Message-ID:MIME-Version;
 bh=ho5qakr9siiQapdGeDW6RHnIhweQGS1Y7MDmDmUNmUk=;
 b=f16ZZt/k4/BuRDXkINf8IjOiljLsPsCU2RWo16JIsdASGWMyBO3xeQ0nAZiAG85nsFQGydTRgcpJQ9nJ0G23mdaqIpK2CSocl4T1zSRZCxdN2O3ZcqADLX8ryd5V8tYTAROQZhpM0k5r4ldoILv6g81R5JxAZSi/W9YONFf3IeRSGNJByNyRm7/l3cgQbU73KLYp7+t9yy9GjCV/NpmsiJgArH8fwz359y6AgtVKur/OgCFQFIFBSPRO3/orUmwzH0qmJtvj7yKFVmPftHtJIh5SJPFAaUkFGA95q7nzX9GpRBkYpK+FPItfMuG68G12JLLdroznzzdMZQoMv9Zpmw==
ARC-Authentication-Results: i=1; mx.microsoft.com 1; spf=none; dmarc=none;
 dkim=none; arc=none
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=outlook.com;
 s=selector1;
 h=From:Date:Subject:Message-ID:Content-Type:MIME-Version:X-MS-Exchange-SenderADCheck;
 bh=ho5qakr9siiQapdGeDW6RHnIhweQGS1Y7MDmDmUNmUk=;
 b=TV0NvvMaUatCiNQQ9EPwo42VWm3O2o8b+sraL/1zhQed3vmMcBY54w4hNsvJW1XKblAN08vGKEkqeLwsxUx2oo3GAzPqtOqOrnfe9n9djGC7PuoMdZ5lqDltUS+557cHhY860DIE8DFckwTutIOTGpHJuYu0Z4O74ugR3zkE2vJ2+4kkepZlfgENLPI2eDmdBVSUzMAnR5BIfKzgq/e3YyO/KlDRhDxj4Yg3G2qaYHa5m131d7CmIH96fv0cjpbhf+yeUpV+sOtZvANSnR+8sbm7k2i9bIMHgw2DGYqvQgfr6XeWB/+Nd20B7VEM4o66byh+yaqk72Zg5R3HTG8TlQ==
Received: from SA3PR05MB10385.namprd05.prod.outlook.com
 (2603:10b6:806:39d::17) by SAVPR05MB998543.namprd05.prod.outlook.com
 (2603:10b6:806:4e8::17) with Microsoft SMTP Server (version=TLS1_2,
 cipher=TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384) id 15.21.592.10; Fri, 6 Nov
 2026 08:17:08 +0000
Received: from SA3PR05MB10385.namprd05.prod.outlook.com
 ([fe80::e22f:a0f5:fcb0:9b0d]) by SA3PR05MB10385.namprd05.prod.outlook.com
 ([fe80::e22f:a0f5:fcb0:9b0d%6]) with mapi id 15.21.0592.010; Fri, 6 Nov 2026
 08:17:08 +0000
From: Yingjie Wang <x-professor@outlook.com>
To: "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
CC: Trond Myklebust <trondmy@kernel.org>, Anna Schumaker <anna@kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
Subject: [PATCH] NFS: cap the legacy DNS resolver upcall timeout
Thread-Topic: [PATCH] NFS: cap the legacy DNS resolver upcall timeout
Thread-Index: AQHdbcc2IIMvCu6LI0elEbJeFvUNFQ==
Date: Fri, 6 Nov 2026 08:17:07 +0000
Message-ID:
 <15a5964137d65b2589a2931b91b7baf1e8c60341.1793953018.git.x-professor@outlook.com>
Accept-Language: en-US, zh-CN
Content-Language: en-US
X-MS-Has-Attach:
X-MS-TNEF-Correlator:
x-ms-publictraffictype: Email
x-ms-traffictypediagnostic: SA3PR05MB10385:EE_|SAVPR05MB998543:EE_
x-ms-office365-filtering-correlation-id: 053b61c9-1de5-4c79-ff0d-08df3bde596b
x-microsoft-antispam:
 BCL:0;ARA:14566002|15080799012|19110799012|38102599003|31061999003|8062599012|8060799015|22091999003|24121999003|41001999006|24071999003|24021099003|39105399006|25010399006|4140399003|20031999006|40105399003|102099032|3412199025|440099028|26121999007;
x-microsoft-antispam-message-info:
 =?utf-8?B?RDdlUTFwUnZlc24wYXlTMXdhK1hadnRJb0oxem4rNkVLbkF1Vy9pVlcrNGd4?=
 =?utf-8?B?dHpmVjZ3VjI3N094bkJzOUQ1ZUNRL1lXMlRVK1dsaXhpd0J0bW54cjJ2NTFs?=
 =?utf-8?B?eW9scThGSWpISUFXaXhzem5nNTFhaTdMUm1aZ2x5YmRvS2d4MjdKampMQ0xR?=
 =?utf-8?B?akROanp1MStxZGVvcHBQajkraDFuSndZanQyNTU1dUw2aHhaaGczTnVEUkFT?=
 =?utf-8?B?Y2xIS0dZZ2kxa0g2Q2tjVTFkMlRIMUFOOEV1dmZXV0E0ZlF0aGRqTEhianVK?=
 =?utf-8?B?VzMwOTJSQUhlWVlsUTE4c0FpOUdjOGFtOUc5V0lQRVRiN3dsRTcyNWR6Q3Mr?=
 =?utf-8?B?SkVZODY2S25rRm5qRkJqbnBlTUozOHdVSEgyckd4Rm5lSmw3MStMbVlSMXp2?=
 =?utf-8?B?V29aNTZFZzVGNVQxQ0Z4TDVYUGRrZ1oxK2xtenRmUCtDY3FETHdVcjNyb1RR?=
 =?utf-8?B?REZ3emZ1QkJNUlh3YnF4NG5kYTg5SGI5ZStScDhJS1hzSzhRVVlEWVYyVmU1?=
 =?utf-8?B?Mm5VRzBKMXBpdXN6RjBXa3BNQzNjZllqY3VZNzYvNktwZ0VEcnVjbHQvZUt0?=
 =?utf-8?B?b25aa3NTUlFoUDY2TVcvQmplbDJKMmNqS3pvVGZBUVJEVU5FK01udWNIcTQ1?=
 =?utf-8?B?OVYweExQczBVdWE5THRBOTZ2ZFBKWWJPT3FMR1VQNWF6ZFBVSjduSzVEZ1cz?=
 =?utf-8?B?c2srcVoxekI3d0JOK3luTjNrMjNHWXJ2d2h2d2cxYURJWTQ1UnpIOWU5RVFy?=
 =?utf-8?B?V0F1KytxQ0JiZWpVbGpXdkdadklzKy9Sd1B1YllablRzRUM2dlJxUTkyZCs1?=
 =?utf-8?B?aGE5a0xPZ1Axc3RxSDZ0SU1DNUE3UlJ1dEZnemVjdXMxOCtqODc0VVdYU0RY?=
 =?utf-8?B?NXlkcUR3UXZVNmQvTzFJL1ROMFJ3TmV2eGoza0MwTGlraUtyWHgrWWNSRnRR?=
 =?utf-8?B?N3RsblRxSHA5SExuY1Q3VGxNM2ZYSWtua0pnRzdNZlpqeXlIdjV1aVNPQXli?=
 =?utf-8?B?NmV1ZHJ3WUdlTzExY05XWXhuUmhJU2lvZ3IrMWg1UTR1QVFRN3NPRlFjZEFv?=
 =?utf-8?B?bHppNm9JR3VCcWJxN1dEendCUkZBYXM1bjVDUmlwc3VNRmlwRS95Z0JwKzhB?=
 =?utf-8?B?eU5TTm1ia09WRGdlQ003WXhURVhPTDNZbWh4M1NwVjJER1F0bU1pNHNiM2xn?=
 =?utf-8?B?TmxXek5kQ3dXTlh2V01KV2VMelRNVkMrQWtDbXY4RUV3bnliR0ZLWG52UUVI?=
 =?utf-8?B?ZWJrWUtYcVpKNFNqWVBndU81cFJLa2pTNGUvWUdkZy9XQXF6WjFENzMyY2Jl?=
 =?utf-8?B?TUMvRGlFRVRkZHN2cDNXVnlBbTZ5ajZwdHhOajZNNnJzSERDS2p5b2NKQXRj?=
 =?utf-8?B?MmYyd3BNTlNYUy8xdmQ2L1M0QjN1SURzTkx0WWdkTzZHTzQyWHhnbDFzdGdF?=
 =?utf-8?B?c2UrV2pDL1Vyb0U3Y2wyZUxyTGp0bWFicWt2eUpTTkVieThacmtZL1J0U05r?=
 =?utf-8?B?a2ZQdlFZL1BQamdzKzluK1lLOEdtMG56VFB6UzIzMjFaQUR2V1RETmc2NzA2?=
 =?utf-8?B?MW1pUT09?=
x-ms-exchange-antispam-messagedata-chunkcount: 1
x-ms-exchange-antispam-messagedata-0:
 =?utf-8?B?TFE3UnR0V2JEZmN1NU83cE5sb3ZlSGdQRFBDZE9yVWJPbGVhZDQ2MDBOcHhi?=
 =?utf-8?B?N0EyNWEvUStBRlg4aEtzZ0VDM0h5VlRvTlZXM2FraURLdDAyUHltMG5PZmhV?=
 =?utf-8?B?QVpaVXJmYnZBRityQTh6UmlTWndsMGNFMnowSXpiVEEvSVJJbFl5bE8zL21H?=
 =?utf-8?B?Zmg3L2YzSjl1dlV6dEtlWDVsSnFsdG44Zyt3SFo1V2g1ekFxNGpMWHpHRjVP?=
 =?utf-8?B?WDJRS0gvRGk4eWljNDlmM001VHE2OVdhZnAxejNsRWpBc3Z6QXkwZXI1Skdu?=
 =?utf-8?B?djNHcFlxS2JKRDJqQWxNMlhrRld1OVZqckV2TnBpSGZ1aUlEMTlOa0NNQjhL?=
 =?utf-8?B?bExBN21KK2ZSdDZ5V2dZUVBLSEtkRWF0emMyUThROFgxQUxuYzgvV2NlVFpx?=
 =?utf-8?B?Ti9MZm11ejZUNU9NczhwVTNtcTdJQmc2b1doZTdPaHJ0a2FGakFhbGN1MjZi?=
 =?utf-8?B?bDdqb2F4TUlMY0IzK0IyS2JlMlpJK1VjY2VUSGJUWkl2Q2FhMFcrVHFLTStV?=
 =?utf-8?B?K3I5OFJoVFBwcmF3SDdSZFkvZUhUc2JZcmxZSXFHOVdERjBpdE9RUUFWdUNt?=
 =?utf-8?B?eVlMeEs5OUFFTW9LQ0gvUEVYazFPZTBmUEFCT3VnNTlQWDlaVW1sR2NwaS9p?=
 =?utf-8?B?WW4vVkZrRGZKTkRMajhDMzdoTFdCbldMak15THQ5Ty9wU2FnaDZvbmxDZWZE?=
 =?utf-8?B?ZWRPNmc4WW1iSGFpa0pnT2NBM05DejdDVFdzSzBiL3A5ZGtmZzFDZGpocUxU?=
 =?utf-8?B?K1ZlQkZsOXUxY1JUSVFqWXhWenZvZlh0eFRUdGV3MVZoSktlSmdyTzBETXdR?=
 =?utf-8?B?OUY4MUJXTHFHeVlVa25lVjJrR1U5NDdhV3V2R2F1U2Q0aTJydU4xZy9VZjZo?=
 =?utf-8?B?LzNoVEE4TFcrQTM4NFI3dk10RitUNFNPSHpMUERQTFBCbTIxTFJLNVRUMFZx?=
 =?utf-8?B?VG82UGhCSm9OZjJiRFJWZTJBZ1BKd3BFU2FENFZwbUNyMVpXT00wSWVieHNl?=
 =?utf-8?B?QVdCQ0pzMktsMFdiMkliWmU1SHNhQmllVzl2ODhrUVhnbTBTN3dFckxISXF1?=
 =?utf-8?B?dzArdXlvZ0E1ampCQ0kzL3JGcmptNTR4K0daS2dQa1pzaWZRa3pYOG50bmJ3?=
 =?utf-8?B?Q1hvNnBpYjRkSHpXRHA1WHlPQS9rZjlOMG1va2NwNVYvM1orUlV3ZUxEaHdn?=
 =?utf-8?B?Z1ltWGpCMWN3SVZMZnBxNVJ2QWg3NXd2bUt3N1l5aGlqS29ucUx4QUZxYlNo?=
 =?utf-8?B?MjNZWThSMEUwekdFRGZrTnZIVnNnZjVkcXVNWExuMW1zM0Z2RnpaS3dxckFW?=
 =?utf-8?B?MU1VazhBdU9laExOSXoyL0lZTVVKcGFnT29XQjI5b0w1OHhlTS83UHFzM3kz?=
 =?utf-8?B?RzAvRU9hTmFzVTVjYmozMmxxcGR0c1p4WlM2Z1lWNTNvZk9LUExnc3BDamxa?=
 =?utf-8?B?VUpTQ29lVDBiY1ZudE0zSUUxUkk5T0tUdVA5K3o3cFBnbWRjZkIzQy91ckx6?=
 =?utf-8?B?SUFGTktqY2pLNWVkM1gxQlNQNm8wdXJ1c0h6ZmdJSGlhdFVCaVlGbjFlYW1D?=
 =?utf-8?B?c3poVFZJbVVjWmxaZ3BwK2ZYRXJ5djRzeks4ZVhEY1Q2bVlWNHpWRldydU56?=
 =?utf-8?B?dVdDejMvMmk3c1htQWVnYS9PYVdFdUdETFR2WWwyR0pFbElSVFFGOUNneGpY?=
 =?utf-8?B?WjBRSVVRNTBPdTBxcnkwOGM2c1k1R3hWVkM2WmhOd09tRnJCN25WRXdoVVdq?=
 =?utf-8?B?OUV1NkJnOGErS0hrSWUxL1M0N0IxTGpOemZXeEpYSnZwVi9ONjZxUWkxcHJy?=
 =?utf-8?B?OURndFJubWpWUnk2eThNOWtOYndreExkQVVBeTEyQ20wTUM1bnNjT0NMRUlq?=
 =?utf-8?Q?QCIHvpfNM5C+T?=
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: base64
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Post: <mailto:linux-nfs@vger.kernel.org>
List-Help: <mailto:linux-nfs+help@vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
List-Owner: <mailto:linux-nfs+owner@vger.kernel.org>
Precedence: list
MIME-Version: 1.0
X-OriginatorOrg: outlook.com
X-MS-Exchange-CrossTenant-AuthAs: Internal
X-MS-Exchange-CrossTenant-AuthSource: SA3PR05MB10385.namprd05.prod.outlook.com
X-MS-Exchange-CrossTenant-RMS-PersistedConsumerOrg: 00000000-0000-0000-0000-000000000000
X-MS-Exchange-CrossTenant-Network-Message-Id: 053b61c9-1de5-4c79-ff0d-08df3bde596b
X-MS-Exchange-CrossTenant-originalarrivaltime: 06 Nov 2026 08:17:07.7869
 (UTC)
X-MS-Exchange-CrossTenant-fromentityheader: Hosted
X-MS-Exchange-CrossTenant-id: 84df9e7f-e9f6-40af-b435-aaaaaaaaaaaa
X-MS-Exchange-CrossTenant-rms-persistedconsumerorg: 00000000-0000-0000-0000-000000000000
X-MS-Exchange-Transport-CrossTenantHeadersStamped: SAVPR05MB998543

bmZzX2NhY2hlX3dhaXRfZm9yX3VwY2FsbCgpIGNvbnZlcnRzIG5mc3Y0LmNhY2hlX2dldGVudF90
aW1lb3V0IGZyb20Kc2Vjb25kcyB0byBqaWZmaWVzIGFuZCBwYXNzZXMgdGhlIHJlc3VsdCB0byB3
YWl0X2Zvcl9jb21wbGV0aW9uX3RpbWVvdXQoKS4KVGhlIHBhcmFtZXRlciBpcyBhbiB1bmJvdW5k
ZWQgdW5zaWduZWQgbG9uZywgc28gdGhlIHByb2R1Y3QgY2FuIGV4Y2VlZApMT05HX01BWCwgd2hl
cmUgc2NoZWR1bGVfdGltZW91dCgpIHByaW50cyAid3JvbmcgdGltZW91dCB2YWx1ZSIgd2l0aCBh
CnN0YWNrIGR1bXAgYW5kIHJldHVybnMgYXQgb25jZSwgb3Igd3JhcCB3aGVuIHRoZSB2YWx1ZSBp
cyBhYm92ZQpVTE9OR19NQVggLyBIWi4KClRoZSB3YWl0IGlzIHJlYWNoZWQgZnJvbSBuZnNfcGFy
c2Vfc2VydmVyX25hbWUoKSB3aGVuIGEgc2VydmVyIG5hbWUgaW4KZnNfbG9jYXRpb25zIGlzIG5v
dCBhIG51bWVyaWMgYWRkcmVzcywgaS5lLiBmb3IgcmVmZXJyYWxzLCBtaWdyYXRpb24gYW5kCnRy
dW5raW5nIGRpc2NvdmVyeSB3aXRoIENPTkZJR19ORlNfVVNFX0xFR0FDWV9ETlMuIE9uIHg4Ni02
NCB3aXRoCkhaPTEwMDAsIDkyMjMzNzIwMzY4NTQ3NzYgc2Vjb25kcyBtYWRlIHRoZSB3YWl0IGZh
aWwgd2l0aCAtRVRJTUVET1VUCmFmdGVyIDAuNSBtcywgYW5kIDE4NDQ2NzQ0MDczNzA5NTUyIHNl
Y29uZHMgd3JhcHBlZCB0byAzODQgamlmZmllcyBhbmQKZ2F2ZSB1cCBhZnRlciAwLjM5IHMgaW5z
dGVhZCBvZiB3YWl0aW5nIGZvciB0aGUgdXBjYWxsLgoKQ2FwIHRoZSBzZWNvbmRzIHZhbHVlIGF0
IHRoZSBsYXJnZXN0IHdob2xlLXNlY29uZCBkZWxheSBub3QgZXhjZWVkaW5nCk1BWF9KSUZGWV9P
RkZTRVQgYmVmb3JlIG11bHRpcGx5aW5nIGJ5IEhaLiBUaGlzIHByZXZlbnRzIGJvdGggYSBuZWdh
dGl2ZQpzaWduZWQgdGltZW91dCBhbmQgbXVsdGlwbGljYXRpb24gd3JhcC4gVGhlIHRpbWVyIHdo
ZWVsJ3MgZXhpc3RpbmcKaGFuZGxpbmcgb2YgdmVyeSBsb25nIGRlbGF5cyBpcyB1bmNoYW5nZWQu
CgpGaXhlczogZTU3MWNiZjFhNGY4ICgiTkZTOiBBZGQgYSBkbnMgcmVzb2x2ZXIgZm9yIHVzZSB3
aXRoIE5GU3Y0IHJlZmVycmFscyBhbmQgbWlncmF0aW9uIikKU2lnbmVkLW9mZi1ieTogWWluZ2pp
ZSBXYW5nIDx4LXByb2Zlc3NvckBvdXRsb29rLmNvbT4KLS0tCgpOb3RlczoKICAgIFRlc3RlZCBv
biB4ODYtNjQgKEhaPTEwMDApIGluIFFFTVUuIEEgdGVzdCBtb2R1bGUgKG91dCBvZiB0cmVlLCBu
b3QgcGFydAogICAgb2YgdGhpcyBwYXRjaCkgbG9va3MgdXAgbmZzX2NhY2hlX3dhaXRfZm9yX3Vw
Y2FsbCgpIGFuZCBjYWxscyBpdCB3aXRoIGEKICAgIGNvbXBsZXRpb24gdGhhdCBpcyBzaWduYWxs
ZWQgMTAwIG1zICgxIHMgZm9yIHRoZSB3cmFwcGluZyB2YWx1ZSkgbGF0ZXIuCiAgICBXaXRoIHRo
ZSBwYXRjaCBldmVyeSBjYXNlIHJldHVybmVkIDAgYWZ0ZXIgdGhlIGNvbXBsZXRpb247IGEgMi1z
ZWNvbmQKICAgIGNvbnRyb2wgYW5kIDkyMjMzNzIwMzY4NTQ3NzUgc2Vjb25kcyBiZWhhdmVkIHRo
ZSBzYW1lIG9uIGJvdGgga2VybmVscy4KICAgIEkgZGlkIG5vdCBzZXQgdXAgYW4gTkZTdjQgc2Vy
dmVyIHJldHVybmluZyBhIHJlZmVycmFsLiBBbHNvIGJ1aWx0IGZvcgogICAgaTM4NiB3aXRoIFc9
MS4KCiBmcy9uZnMvY2FjaGVfbGliLmMgfCA2ICsrKystLQogMSBmaWxlIGNoYW5nZWQsIDQgaW5z
ZXJ0aW9ucygrKSwgMiBkZWxldGlvbnMoLSkKCmRpZmYgLS1naXQgYS9mcy9uZnMvY2FjaGVfbGli
LmMgYi9mcy9uZnMvY2FjaGVfbGliLmMKaW5kZXggY2E0ZTgxZDRlMzE1Li41OTM4MjU2YTJjZGQg
MTAwNjQ0Ci0tLSBhL2ZzL25mcy9jYWNoZV9saWIuYworKysgYi9mcy9uZnMvY2FjaGVfbGliLmMK
QEAgLTEwNyw4ICsxMDcsMTAgQEAgc3RydWN0IG5mc19jYWNoZV9kZWZlcl9yZXEgKm5mc19jYWNo
ZV9kZWZlcl9yZXFfYWxsb2Modm9pZCkKIAogaW50IG5mc19jYWNoZV93YWl0X2Zvcl91cGNhbGwo
c3RydWN0IG5mc19jYWNoZV9kZWZlcl9yZXEgKmRyZXEpCiB7Ci0JaWYgKHdhaXRfZm9yX2NvbXBs
ZXRpb25fdGltZW91dCgmZHJlcS0+Y29tcGxldGlvbiwKLQkJCW5mc19jYWNoZV9nZXRlbnRfdGlt
ZW91dCAqIEhaKSA9PSAwKQorCXVuc2lnbmVkIGxvbmcgdGltZW91dCA9IG1pbl90KHVuc2lnbmVk
IGxvbmcsIG5mc19jYWNoZV9nZXRlbnRfdGltZW91dCwKKwkJCQkgICAgICBNQVhfSklGRllfT0ZG
U0VUIC8gSFopICogSFo7CisKKwlpZiAod2FpdF9mb3JfY29tcGxldGlvbl90aW1lb3V0KCZkcmVx
LT5jb21wbGV0aW9uLCB0aW1lb3V0KSA9PSAwKQogCQlyZXR1cm4gLUVUSU1FRE9VVDsKIAlyZXR1
cm4gMDsKIH0KCmJhc2UtY29tbWl0OiBmNjY0NjlkOTkwNWIzOWQyYzI2MGExNWQ3ZDZkYjQ1MGY0
ZGI2N2MxCi0tIAoyLjQzLjAKCg==

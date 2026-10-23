Authentication-Results: smtp.subspace.kernel.org; arc=pass header.oldest-pass=0 smtp.remote-ip=40.107.192.140
ARC-Seal: i=2; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=pass;
	t=1792798978;
	b=EY8xl0Rjr4acgbpow2BmUpJZq9mSEvyNbNdbYdCto5jx5yZb1Xez3ILHZ4ErbMoj47Wn
	 VdHLskTq/6tlHEasIyM51E5pxQVlAhguRW/nL53z+BY7Vys1OvX6KdmbgNHBYF5OOGBpu
	 c1fvririRaZnFm86mZs97TJxwCC7ljSPKtyFZc/phEN9hZztpiOemOtJ8yXAwsppYEAsh
	 r002KmTZ+du9hxRsr7t2LrXsZ4Te7M+TbExS0u0IC5sh9NlWqQOrRDsmkYlUl6XuZjTZW
	 GfsKCIMrkDaSccYIOEuGgY0cJVC8Od7rYHT8VwMmGlaj4sXsbscSOCKdAqI1JefQjug==
ARC-Message-Signature: i=2; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1792798978;
	h=DMARC-Filter:Received:Received:From:To:CC:Subject:Thread-Topic:
	 Thread-Index:Date:Message-ID:Accept-Language:Content-Language:
	 X-MS-Has-Attach:X-MS-TNEF-Correlator:msip_labels:
	 x-ms-publictraffictype:x-ms-traffictypediagnostic:
	 x-ms-office365-filtering-correlation-id:x-ms-exchange-senderadcheck:
	 x-ms-exchange-antispam-relay:x-microsoft-antispam:
	 x-microsoft-antispam-message-info:x-forefront-antispam-report:
	 x-ms-exchange-antispam-messagedata-chunkcount:
	 x-ms-exchange-antispam-messagedata-0:Content-Type:
	 Content-Transfer-Encoding:MIME-Version:X-OriginatorOrg:
	 X-MS-Exchange-CrossTenant-AuthAs:X-MS-Exchange-CrossTenant-AuthSource:
	 X-MS-Exchange-CrossTenant-Network-Message-Id:
	 X-MS-Exchange-CrossTenant-originalarrivaltime:
	 X-MS-Exchange-CrossTenant-fromentityheader:
	 X-MS-Exchange-CrossTenant-id:X-MS-Exchange-CrossTenant-mailboxtype:
	 X-MS-Exchange-CrossTenant-userprincipalname:
	 X-MS-Exchange-Transport-CrossTenantHeadersStamped;
	bh=WQtoXKB5twcPFd8Dpyy1b9JzkI2YlPpe8vt1L/L4fmc=;
	b=m4JWGUIEWmG1zJOJyefHbQaL1VIME+fjcQ9kDvapPKvp+VH+EEbp6ulwOxGKW9XqviCR
	 6oJ3fk9yPc3W2t9m8KwQlSsG/tr4nGnuinFJlxdp/cOQSkzsX66k/jKWk10XE2ZStsTbY
	 wQrqG+RRdGbhinmwtCHBglgm+q64f9HrkOQMqzMsJNXttdj2/TCq0CSCt3j0hjioh/jjy
	 /bgEYF8WHef6Mar+HPvMr3Wqwm8Jdde47x9aO6+xRhf/FwTiy4IuUszPZfHYaQxtY6yEp
	 m/GjgHEs7DQvOwCGHrdw4gHBhgVGvIeDjaokWlkYkg5AsvJuR/2xBjvkLKEOsxaEp6g==
ARC-Authentication-Results: i=2; smtp.subspace.kernel.org; 
	dmarc=none header.from=morshed.eu;
	spf=pass smtp.mailfrom=morshed.eu;
	arc=pass header.oldest-pass=0 smtp.remote-ip=40.107.192.140
Received: from YT5PR01CU002.outbound.protection.outlook.com (mail-canadacentralazon11021140.outbound.protection.outlook.com [40.107.192.140])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange ECDHE (secp384r1) server-signature ECDSA (prime256v1) server-digest SHA256)
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id C5388606A31B;
	Fri, 23 Oct 2026 23:42:57 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.4.2 smtp.subspace.kernel.org C5388606A31B
Authentication-Results: smtp.subspace.kernel.org; dmarc=none (p=none dis=none) header.from=morshed.eu
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=morshed.eu
ARC-Seal: i=1; a=rsa-sha256; s=arcselector10001; d=microsoft.com; cv=none;
 b=gQY4IfIMaMaVKqGxkREFpIsQZXRM9Ukepez7Jxumk38Te8MB0xCsgjl7U0mAWNhPzZrZMlEL4KjIYZiJfEDIJDqlJrfKTT/Ya/ybvg1f2/XLnGqvwxMEYQNNltkC9baeQwW8uQnuEPN3T9oVz61zIrpNUe265Ibhlhy+K5ioBdaZYvQLg4pp3FveC4Gugf6XTnuN6/8+kq8eHUIaEud17zIRZOXZTQXKKgf/gRpS+YOzURottEubaWbR0sDQoaaZzyP5nJcbm3RJxooEFiLaUgo9QJY1Vu6JLHy/oY3lIi1hABmwxYwKERFWWxPQqiRoHEC7zDXzONxppgyeLM+xnQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=microsoft.com;
 s=arcselector10001;
 h=From:Date:Subject:Message-ID:Content-Type:MIME-Version:X-MS-Exchange-AntiSpam-MessageData-ChunkCount:X-MS-Exchange-AntiSpam-MessageData-0:X-MS-Exchange-AntiSpam-MessageData-1;
 bh=WQtoXKB5twcPFd8Dpyy1b9JzkI2YlPpe8vt1L/L4fmc=;
 b=F+9+Czkq/szbx1jDHVpodSo3n+2HKwcTX6HLgaPqfdmzE6yybyTGuCr3V1Ugo1kyvvkUmX2qL8a6qIiIj/ilA+o1Gy/5FpxQbbPju3jCWo9WQ1IroZDLMeMhhQQh0I2HIBqS4/X8/h/Du47PfcRy+w9CLLXJ6qiPXfdSp/k1FXYmgI21Ys038AEKF806q6XXD68etApc2ksHtL8/kjNfvmdyQhH2ke0S5klNXhbvtqdy8BXlp1Pm4ef/aXih0vBMHOeInA5GNR/dzrpjpVEEot/uy3ELr3iudM9paR1AAPf2sx6dgTbbzWShoA7JHuzKUK6uKa/Y3qaWfcTWPbjcOQ==
ARC-Authentication-Results: i=1; mx.microsoft.com 1; spf=pass
 smtp.mailfrom=morshed.eu; dmarc=pass action=none header.from=morshed.eu;
 dkim=pass header.d=morshed.eu; arc=none
Received: from YQBP288MB0164.CANP288.PROD.OUTLOOK.COM (2603:10b6:c01:72::14)
 by YQBP288MB0746.CANP288.PROD.OUTLOOK.COM (2603:10b6:c01:8f::8) with
 Microsoft SMTP Server (version=TLS1_2,
 cipher=TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384) id 15.21.546.20; Fri, 23 Oct
 2026 23:42:53 +0000
Received: from YQBP288MB0164.CANP288.PROD.OUTLOOK.COM
 ([fe80::3a11:7130:faa2:1b9e]) by YQBP288MB0164.CANP288.PROD.OUTLOOK.COM
 ([fe80::3a11:7130:faa2:1b9e%7]) with mapi id 15.21.0546.019; Fri, 23 Oct 2026
 23:42:52 +0000
From: Nurullah Morshed <nurullah@morshed.eu>
To: "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>,
	"netfs@lists.linux.dev" <netfs@lists.linux.dev>
CC: "trondmy@kernel.org" <trondmy@kernel.org>, "anna@kernel.org"
	<anna@kernel.org>, "dhowells@redhat.com" <dhowells@redhat.com>,
	"pc@manguebit.org" <pc@manguebit.org>, "linux-fsdevel@vger.kernel.org"
	<linux-fsdevel@vger.kernel.org>
Subject: [BUG] NFS: fsc reads return zeroed file tails after short READ
 replies
Thread-Topic: [BUG] NFS: fsc reads return zeroed file tails after short READ
 replies
Thread-Index: AQHdY0RnkTc0c7DE4EmEoxrrYYPnVQ==
Date: Fri, 23 Oct 2026 23:42:52 +0000
Message-ID:
 <YQBP288MB016467ACB8048B62A153F00CBB642@YQBP288MB0164.CANP288.PROD.OUTLOOK.COM>
Accept-Language: en-GB, en-US
Content-Language: en-GB
X-MS-Has-Attach:
X-MS-TNEF-Correlator:
msip_labels:
authentication-results: mx.microsoft.com 1; dkim=none (message not signed)
 header.d=none;dmarc=none action=none header.from=morshed.eu;
x-ms-publictraffictype: Email
x-ms-traffictypediagnostic: YQBP288MB0164:EE_|YQBP288MB0746:EE_
x-ms-office365-filtering-correlation-id: c3cbe4de-42d1-4739-a6f5-08df315f5acf
x-ms-exchange-senderadcheck: 1
x-ms-exchange-antispam-relay: 0
x-microsoft-antispam:
 BCL:0;ARA:13230040|366016|23010399003|376014|1800799024|18002099003|5023799004|56012099006|261022105027099003|261022075727099003|261022115727099003|10067099003|261009223027099003|261021121427099003|261021135927099003|38070700021;
x-microsoft-antispam-message-info:
 9piUK6JZcyaO5B2V8kGnye81YnK/qDIXgHLSeBAstGhQXV6PJKD33d+eK3SyS+4iSSaeIpW12pALQkUC7DVrn6bu9+wdFbh82pCrphP4j1qq3VMc2SK+YnScDDuia4rEqHOtYlW+00DvZn00XmGxqTR//i7YLSDjmZ3WEgtP2erqlSVUk4CSepIL4QCJDqSz5reQWUuRwQZgW5a4Ph/wt+jDgS9dFek7r3NnIUHmGOw72QJKg6BhjF4lh6CZkAGDc1wvi0HuXGzYYieiGmBeEPx9UnBhwDy754zHEQfV1E63/aXNR5WVdFRtO/rYH4ioGYI+fI854yJIWRFE3qcShEnLYFmbxqu0VXTA7rprN/dQGjuTtr5L8v6m0WvR/+csWJOxrDwPO8nva1koW00079kgkAct8MLUmDZYWczykX38fClTKIv2vBSx8M9ZSeENqMVLoLQeeSo4NEk1apkEefvBYNfPt9KVFVYwIcRgnAYOfYtIIckQO+I+cK78gS8+7drlODJbTa0b7IsFRVnvYUuoX4xBYxNDIuxHyn3KyUmFTSlggZang5Z4P4oDIWxqDMJfwwoHfykygft1Y66S0BVMrcSt0He4lHo7blY3+oeuwzVsTYQeyuBH7hYNHsOdvVAzzHQ9JAhb6U+RPF1egSnzPP11JDkVMRBPcF95PPI=
x-forefront-antispam-report:
 CIP:255.255.255.255;CTRY:;LANG:en;SCL:1;SRV:;IPV:NLI;SFV:NSPM;H:YQBP288MB0164.CANP288.PROD.OUTLOOK.COM;PTR:;CAT:NONE;SFS:(13230040)(366016)(23010399003)(376014)(1800799024)(18002099003)(5023799004)(56012099006)(261022105027099003)(261022075727099003)(261022115727099003)(10067099003)(261009223027099003)(261021121427099003)(261021135927099003)(38070700021);DIR:OUT;SFP:1102;
x-ms-exchange-antispam-messagedata-chunkcount: 1
x-ms-exchange-antispam-messagedata-0:
 =?iso-8859-1?Q?+wCzW89YeBx5L5EZyN0COR7wwcaTBUffJaHKK58n74d8UxCSK9wSd/tJKh?=
 =?iso-8859-1?Q?W2FQAD32L2yuIEWdJ756uQCHOQH5wMKqrMfa0OAL8/ki7HBbTsBBNKp3mL?=
 =?iso-8859-1?Q?i4g7fJ8lIDvbIH8M0JXmR4lpdmysD495CaIPZ0HxITLQ2Hq0eR5GhQ7PPW?=
 =?iso-8859-1?Q?EGHlp94/Ogb5yXDeS+ukTuUu3Ut77I6mvWrP9tS2UUBKeotaNY5vestLdG?=
 =?iso-8859-1?Q?Ee5Nn/r6IkgMgkVayHRMZp3MivOyuWntt/DaU6tsZ8mOHWlfbsQlrfOE6/?=
 =?iso-8859-1?Q?RS27/rknnBzF8XsqFevtFXJ6qdq6au3GQpU4BZEox3IqjO7YaSpLhvXMHJ?=
 =?iso-8859-1?Q?Px4ksI2HknUpKw+o78FMRNAgzOSEXd1/nq9mKyP98CbAxV5kyL9Um3X/Ee?=
 =?iso-8859-1?Q?Nd5BnEBk/R93ekFKe4uVoXPosKQ017223Bo1MF0a2PyhU1zjsjmeXt9WOp?=
 =?iso-8859-1?Q?h/t/P1ujzNdsVuTA9B+pLNOykGFBPkiEx7EDrVizu/nLwv9ni3pnQRdR2C?=
 =?iso-8859-1?Q?/RcrmC6GgGRLSw8bupxMg3oC1R25FFWamDYEOPcOxZkie68qwDSJ3cNCcc?=
 =?iso-8859-1?Q?jSqNpJQm/GYrJQXMbk8JCvT43zeIptqXbpWOpPxlv/cnsPwNQBfneiQNAV?=
 =?iso-8859-1?Q?YOB0y0MF/9ScSfIhZX2J+dW+EKFOw0fAW0bWgHqgNVBZuwzmH+P1i+Jsim?=
 =?iso-8859-1?Q?MYHXpWbVNbq1IGXeEAg+ezF4iG8A+HkQy1vx6iBh+OxpUcghG6wE5X6O9d?=
 =?iso-8859-1?Q?dGB33mWcWCDhNEmvcCGQQOPGfU+pPol1npEuD5fVmAl/VP9Xp7gIV6eqEW?=
 =?iso-8859-1?Q?KzxTKESZvD81WZUy39L6hVKSTNTztbQ567zlByNJoVnkAQZss7iSW1CFZ0?=
 =?iso-8859-1?Q?/S3rHQlsLFHrBEOqC2Cz6rKWSU+Uy4gaT6TleMolgdb7Yn1hBydQ4SORod?=
 =?iso-8859-1?Q?d9EO9Jok5msY79CHW1PW1OIAtggOQCVdHkcv/jOm59g77v4k+Lfa/ardcB?=
 =?iso-8859-1?Q?3KkXqra+Gh61dF7Cco2a7goMKhuXwA4+ILbgJNwTZq39Rycc/PueHS8buG?=
 =?iso-8859-1?Q?aIlZExhiem48G4fvxEZMwlhn/7MglQxvBSBFXG5oALJDoSKhbjlErj/P/i?=
 =?iso-8859-1?Q?U12cHSTfDnLX4lUc+b2rHl7aVL60ip3UD82WV7NNLCrHLdyKf4pRFFNpEM?=
 =?iso-8859-1?Q?kEdX8TDv9KWxpJKDUMkodPb3+uTcsKU98jbX9PMGXT8aLo4M/uDEXk8V8y?=
 =?iso-8859-1?Q?T8+hVYNhCAWAr9fCKH+VR+Kl/I5bs1Pbx3NP0+qf/UwCUFKMU/IrolTSNa?=
 =?iso-8859-1?Q?Sm5yrwnJTSRTx1mRgFMGmZWJFvNeMRVSAhvbcgFXhj0uHLuZ9N+wFTwGA/?=
 =?iso-8859-1?Q?10z28n2fesEe62/7Qb+gcbgbdwhOXwYJSFp9FM+psGxB9c6YPdpyuE7hYe?=
 =?iso-8859-1?Q?1hP7bWguCViHj/XbIlxQkzmyaWHR9CFRywEgZ13tFdoUzJw8o1FtYaSsfZ?=
 =?iso-8859-1?Q?zBKeP+/hPSCX0rlYsmo1ui3goXpXgHrunlawX1eXMQN4kmjrRqQcVyyDcg?=
 =?iso-8859-1?Q?tYFbdmyYyoytMtdWwOhADTeljMGcYc4UA6MzIfQhZ/vDiJw63pHIpIKINz?=
 =?iso-8859-1?Q?RAvFVoO1Z9TEn6KbR1Df7KD+n5yu9S3cYVpZ8xUcEN+OKDEjG3olq6CqKz?=
 =?iso-8859-1?Q?T17aRM0RJWFzrkB0GF3Pu9sSs2JG635gRPeKk7IMaRV6R4b7yfUOQIaes2?=
 =?iso-8859-1?Q?pOd+cUZdaFDZPgy8ruFFIoyL38RxSpYGwkDLg53sH6qLLM?=
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Post: <mailto:linux-nfs@vger.kernel.org>
List-Help: <mailto:linux-nfs+help@vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
List-Owner: <mailto:linux-nfs+owner@vger.kernel.org>
Precedence: list
MIME-Version: 1.0
X-OriginatorOrg: morshed.eu
X-MS-Exchange-CrossTenant-AuthAs: Internal
X-MS-Exchange-CrossTenant-AuthSource: YQBP288MB0164.CANP288.PROD.OUTLOOK.COM
X-MS-Exchange-CrossTenant-Network-Message-Id: c3cbe4de-42d1-4739-a6f5-08df315f5acf
X-MS-Exchange-CrossTenant-originalarrivaltime: 23 Oct 2026 23:42:52.4211
 (UTC)
X-MS-Exchange-CrossTenant-fromentityheader: Hosted
X-MS-Exchange-CrossTenant-id: 034f4b93-8a3a-40bd-b983-78d952173bd5
X-MS-Exchange-CrossTenant-mailboxtype: HOSTED
X-MS-Exchange-CrossTenant-userprincipalname: 0JnDVITfyixHpuVg3/wCra2lKQpTkLjHEZUcjiEZEqmPcwZ7NW3MR89AYClvgK222qHVV+QARG9Ihcj37vg23g==
X-MS-Exchange-Transport-CrossTenantHeadersStamped: YQBP288MB0746

Hi,=0A=
=0A=
With fsc on an NFSv3 mount, buffered reads can return a file whose last=0A=
part is zeros: correct size, no error, and the zeros stay in the page=0A=
cache (and are written into the cache when cachefilesd is running).=0A=
O_DIRECT reads of the same file are correct. Tracing shows the server=0A=
returns all the data; it's the client who loses it in the short-read path. =
A=0A=
one-line change, tested below, fixes it. I also see an oops in=0A=
nfs_netfs_folio_unlock() on the same mounts, which is what I was=0A=
actually trying to figure out. It may be related, and a second=0A=
symptom of the same problem, but this is now beyond my knowledge.=0A=
Both issues stop when fsc is removed from the mount.=0A=
=0A=
A note on how this was put together: I used Claude (an AI assistant) to=0A=
help gather the data, run the tests and write this up. Kernel internals=0A=
are not my area. The measurements and trace lines below are real and I=0A=
can share the raw files. The explanation of the code in sections 3 and=0A=
5 is my reading of it after getting claude to break it down, =0A=
and the patch has only been tested as described in section 4, =0A=
so please review it as a lead rather than any sort of finished fix. =0A=
All that being said, I'm happy support anyway I can. I can provide =0A=
information from our systems and test fixes as well. =0A=
=0A=
How I hit it: I was migrating our GPU nodes in k8s to FS-Cache. fsc was add=
ed=0A=
to the NFS mounts on every node at once, while cachefilesd only arrives=0A=
with a node image rebuild, so the fleet was a mix of nodes with a cache=0A=
and nodes where fsc was set but no cache was bound. The crashes and the=0A=
production corruption I examined were on nodes without a bound cache. =0A=
However, on a test host, binding a cache made the corruption much =0A=
more frequent but that looks more likely to be related to spikes in traffic=
 =0A=
to the NFS.=0A=
=0A=
Kernels (Ubuntu, Oracle Cloud variant), both affected:=0A=
6.17.0-1020-oracle #20-Ubuntu=0A=
7.0.0-1013-oracle #13~24.04.1-Ubuntu=0A=
I have not built mainline, but the code below is unchanged there.=0A=
=0A=
Mount: NFSv3 to Oracle File Storage,=0A=
vers=3D3,proto=3Dtcp,nconnect=3D16,rsize=3D1048576,wsize=3D1048576,hard,=0A=
timeo=3D100,nocto,actimeo=3D120,nolock,local_lock=3Dall,noatime,fsc=0A=
=0A=
1. The corruption=0A=
-----------------=0A=
=0A=
Reproducer: N processes read many files once each with plain=0A=
open()/read() and compare each to a known MD5. On a mismatch, the file=0A=
is read again buffered (still wrong) and with O_DIRECT (right). 50,000=0A=
files of 1-90 MB, about 1 TB per pass, 32 workers, one host, stock=0A=
7.0.0-1013-oracle:=0A=
=0A=
  Mount                               nconnect   Bad files / 50,000=0A=
  ---------------------------------   --------   ------------------=0A=
  no fsc                                    16                    0=0A=
  no fsc, 64G memory cgroup                 16                    0=0A=
  fsc, no cache                             16                    0=0A=
  fsc, no cache, 64G memory cgroup          16                    1=0A=
  fsc, no cache, 64G memory cgroup           1                    3=0A=
  fsc + cachefilesd, cold                   16                   58=0A=
  fsc + cachefilesd, cold                    1                    0=0A=
  fsc + cachefilesd, warm                   16                  58*=0A=
=0A=
  * the same 58 files, now served from the cache=0A=
=0A=
In production (fsc, no cache, long-lived mounts, jobs in 64-128G=0A=
cgroups) it was about 1 file in 1,000.=0A=
=0A=
Every bad file looks the same: from some offset to EOF the data is=0A=
zeros, and the zeroed length is a whole number of 32 KiB blocks=0A=
(24 to 31 of them here, 851,968 bytes in one production case). The=0A=
server here sends short READ replies in bursts, so the rate varies a=0A=
lot from run to run.=0A=
=0A=
2. What the trace shows=0A=
-----------------------=0A=
=0A=
I traced nfs:nfs_readpage_done (eof / short / error only),=0A=
nfs:nfs_readpage_short, netfs:netfs_sreq (CLEAR_TAIL / HIT_EOF / error=0A=
only) and netfs:netfs_read during a corrupting pass. No events were=0A=
dropped. 34 files were corrupted; 33 match the pattern below exactly=0A=
(the 34th had two short replies in the trace, and the numbers fit the=0A=
other one).=0A=
=0A=
Example, a 6,284,333-byte file, zeros from byte 5,268,525 to EOF:=0A=
=0A=
nfs_readpage_done offset=3D5242880 count=3D1044480 res=3D1015808=0A=
nfs_readpage_short offset=3D5242880 count=3D1044480 res=3D1015808=0A=
nfs_readpage_done offset=3D6258688 count=3D28672 res=3D25645 eof=0A=
netfs_sreq: R=3D00b44f0d[1] DOWN N-CLR f=3D103 s=3D500000 642d/fe42d=0A=
netfs_sreq: R=3D00b44f0d[1] DOWN TERM f=3D103 s=3D500000 642d/fe42d=0A=
netfs_sreq: R=3D00b44f0d[1] DOWN CLEAR f=3D003 s=3D500000 fe42d/fe42d=0A=
=0A=
The subrequest covers the last 1,041,453 bytes (0xfe42d). The server=0A=
answers the first READ short, 1,015,808 bytes with no EOF, which is=0A=
legal. The client reads the remainder and gets 25,645 bytes with EOF.=0A=
1,015,808 + 25,645 =3D 1,041,453: the server sent everything. But netfs=0A=
records only 0x642d =3D 25,645 bytes transferred, sees a short subrequest=
=0A=
that hit EOF, and clears its tail, from 5,242,880 + 25,645 =3D 5,268,525=0A=
on. That is exactly where the zeros start, and the zeroed length is=0A=
exactly the first, dropped reply.=0A=
=0A=
3. Cause=0A=
--------=0A=
=0A=
nfs_netfs_read_completion() accounts the header with=0A=
=0A=
atomic64_add(hdr->res.count, &netfs->transferred);=0A=
=0A=
nfs_readpage_retry() resends a short READ on the same header: it=0A=
advances mds_offset and args.offset/args.count by resp->count, then=0A=
sets resp->count =3D 0. So at completion hdr->res.count holds only the=0A=
last reply, and the bytes of the earlier replies never reach=0A=
netfs->transferred. The data is in the folios; only the count is wrong.=0A=
=0A=
The same miscount hits short replies in the middle of a file: netfs is=0A=
told e.g. 0x8000 of 0x100000, with no EOF, and abandons the subrequest=0A=
with -ENODATA. In one 4-minute traced pass there were 18,667 short=0A=
replies, 18,481 abandoned subrequests and 34 tail clears.=0A=
=0A=
4. Patch and test=0A=
-----------------=0A=
=0A=
Against Ubuntu's 7.0.0-1013-oracle source (fs/nfs/fscache.c is the same=0A=
in mainline as far as I can see):=0A=
=0A=
--- a/fs/nfs/fscache.c=0A=
+++ b/fs/nfs/fscache.c=0A=
@@ -374,7 +374,13 @@=0A=
if (hdr->error)=0A=
netfs->error =3D hdr->error;=0A=
else=0A=
- atomic64_add(hdr->res.count, &netfs->transferred);=0A=
+ /*=0A=
+ * A short READ is retried on the same header: nfs_readpage_retry()=0A=
+ * advances mds_offset past each partial reply and resets res.count,=0A=
+ * so res.count alone is only the last reply. Count all of it.=0A=
+ */=0A=
+ atomic64_add(hdr->mds_offset - hdr->io_start + hdr->res.count,=0A=
+ &netfs->transferred);=0A=
=0A=
nfs_netfs_put(netfs);=0A=
hdr->netfs =3D NULL;=0A=
=0A=
mds_offset and io_start both start at req_offset(hdr->req) in=0A=
nfs_pgio_rpcsetup()/nfs_pgheader_init(), and only the retry advances=0A=
mds_offset, so this is the total received across all replies (the=0A=
pNFS layout drivers already use mds_offset + res.count as the end of=0A=
the data received). It is counted once, at the final completion.=0A=
=0A=
An earlier version added each partial reply to netfs->transferred in=0A=
nfs_readpage_retry() itself. It also fixed the problem in testing, but=0A=
on a pNFS read that is redone through the MDS (NFS_IOHDR_REDO,=0A=
nfs_pageio_resend() reuses hdr->netfs) the partial bytes would be=0A=
counted twice, since the redone header's completion is skipped. Counting=0A=
at completion avoids that. The pNFS path is untested; my mounts are=0A=
NFSv3.=0A=
=0A=
Test: the nfs modules rebuilt from Ubuntu's source with this change=0A=
and loaded on a VM running 7.0.0-1013-oracle, against the same server,=0A=
alternating with the stock modules. Each run reads a 64.5 GB corpus=0A=
(3,000 random files, MD5s computed when written) that was written just=0A=
before the run, through fsc with cachefilesd on a RAM disk,=0A=
nconnect=3D16, 64 readers:=0A=
=0A=
  Module    Runs   Short replies   Abandoned   Tail clears   Bad files=0A=
  -------   ----   -------------   ---------   -----------   ---------=0A=
  stock       10           1,359       1,338             4           4=0A=
  patched     10          11,357           0             0           0=0A=
=0A=
One patched run hit the biggest burst of short replies of the whole=0A=
investigation (11,305) with no abandons and no bad files; the stock run=0A=
right after it got 665 short replies and one bad file. Without a cache,=0A=
across 6 runs of 1 TB, stock abandoned all 172 short replies it got and=0A=
the patched modules none of 322. Run times are the same to the second.=0A=
The modules were built with a different gcc than the distro kernel=0A=
(the build warned about it); the VM never oopsed or rebooted.=0A=
=0A=
5. The oops, may be related=0A=
-----------------------------=0A=
=0A=
This is what I was chasing initially.=0A=
=0A=
On the same fsc mounts (no cache bound), under multi-node training=0A=
load, hosts panicked 10 times in two days, every time with:=0A=
=0A=
BUG: kernel NULL pointer dereference, address: 0000000000000000=0A=
Workqueue: nfsiod rpc_async_release [sunrpc]=0A=
RIP: 0010:nfs_netfs_folio_unlock+0xa/0x30 [nfs]=0A=
Call Trace:=0A=
nfs_readpage_release.isra.0+0x4e/0x80 [nfs]=0A=
nfs_read_completion+0x80/0x170 [nfs]=0A=
nfs_pgio_release+0x13/0x20 [nfs]=0A=
rpc_free_task+0x3c/0x80 [sunrpc]=0A=
rpc_async_release+0x33/0x50 [sunrpc]=0A=
=0A=
folio->mapping is NULL in nfs_netfs_folio_unlock() (it loads=0A=
folio->mapping->host). Claude's guess is that the subrequests abandoned=0A=
because of the miscount unlock folios while another NFS read for the=0A=
same folio is still in flight, so the folio can be dropped from the=0A=
page cache before nfs_readpage_release() reaches it.=0A=
=0A=
However, I could not reproduce the oops across any of my hour long runs=0A=
(in the 1st test, about 227,000 abandoned subrequests, no crash), so this p=
art is=0A=
unconfirmed, and so is whether the patch fixes it. I have the full crash lo=
gs=0A=
from pstore and can share them.=0A=
=0A=
This is not the CVE-2025-38338 fix in nfs_return_empty_folio(); both=0A=
kernels carry it.=0A=
=0A=
Workaround for now: fsc removed from the mounts, which ends both.=0A=
=0A=
I have the full trace (2.4M lines), the saved good/bad file pairs, the=0A=
reproducer and the test harness, and can test other patches on these=0A=
hosts.=0A=
=0A=
Thanks,=0A=
Nurullah Morshed=0A=

Received: from TY3P286CU002.outbound.protection.outlook.com (mail-japaneastazon11010020.outbound.protection.outlook.com [52.101.229.20])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id A664C282F18
	for <linux-nfs@vger.kernel.org>; Thu, 15 Oct 2026 01:47:59 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=fail smtp.client-ip=52.101.229.20
ARC-Seal:i=2; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1792028882; cv=fail; b=QrIYtKcmse+6kJj27djlb0VLmNhJdaXdfLIPYj0qUJ4V/aZ4Ou+wVI3c+WprbmlH2BcMyQCMdHjVUEg9lqlhXX9N9+eyYJ8qkggQeBTF0Gjf7KzPoN0x34/TDpYXaRNT+u6X6XWMGACMO7mJoKKHPtSoqBM9pfUJaDWKHB5CqpQ=
ARC-Message-Signature:i=2; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1792028882; c=relaxed/simple;
	bh=asTSSoC/khLak8TINEi4AmhZKLtL/FkYMe6Ja7f5Ytc=;
	h=From:To:CC:Subject:Date:Message-ID:Content-Type:MIME-Version; b=B0a03lUe/YwrEfMGp8O45FK/IMRS1ppmWS+DKICG69RP7BbD/8uLjqX5LbVqD/7lASJeYK+DRv9mirn8Zp8FFc5ZTjXDnP/Hrnnq2o5Yk+PptivbHY3O/XbMT+cPl+a4+nSslcpFfy2R3qfEVdVjB78Z7A5XiaiIZPXYgNCzSV8=
ARC-Authentication-Results:i=2; smtp.subspace.kernel.org; dmarc=pass (p=reject dis=none) header.from=fujitsu.com; spf=pass smtp.mailfrom=fujitsu.com; dkim=pass (2048-bit key) header.d=fujitsu.com header.i=@fujitsu.com header.b=C4T3MPs4; arc=fail smtp.client-ip=52.101.229.20
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=reject dis=none) header.from=fujitsu.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=fujitsu.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=fujitsu.com header.i=@fujitsu.com header.b="C4T3MPs4"
ARC-Seal: i=1; a=rsa-sha256; s=arcselector10001; d=microsoft.com; cv=none;
 b=CBCZeeIJJ0sr4CQlrOBUamZ/wrAxdmTW7NzVf8Ckzi19IEPePBIYGBvsqMgTfK2Fsn1e+5UEhuY0hjYuVcAX/SPPJBtPzwjUnQkJRReeDgNw4F3NOxUZAoi1le3IPvvDIUHgYYkYuzx4gnCsTkG7e/7sUY721q5jbzXd3IMQtblQfYEdYTcbNr/yfW/NQXiisxc4bRVAf8hH2FZuHH0oiTlrVcqLm6vc0NRaKI5WxdDw9X+SCsXWBFXuiNg2jtf9TSgAtPgCfCqSFxzFc8EmKnqLfEnP7ys1mfdWLRztGFb1fFu1Rubz078pc1hhNDPKHn/AxFEbaw8zeeWd6kOzTw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=microsoft.com;
 s=arcselector10001;
 h=From:Date:Subject:Message-ID:Content-Type:MIME-Version:X-MS-Exchange-AntiSpam-MessageData-ChunkCount:X-MS-Exchange-AntiSpam-MessageData-0:X-MS-Exchange-AntiSpam-MessageData-1;
 bh=Wk3Hr+YZYOnA9c4qFs52o1qMoW820mKSZKVLAjr3tPA=;
 b=ChGejCAVlhnm3lQqTnaHCz0XX6qq6PDe8tJmTEsH0M8TKvEnOanNE1cYSgIW4zzgKYpLsaUn54l8qDP4661oxPSXFr4/DIThQmDZjSRRMj+9cIsPEmrNB6UeD/VzD0MKOvypITLx+8leXYRr+wD8NVWLK8M7VlzIxPNyT/nnTLz8keejntkd3b62pOzpd2CwqfUnM5pGaSJ0PZGZLae6iAU7xIL9C30WF7D4fUENT4yOWgPC4i6pZ0EHo9sUs1GWD/0ZoInSnULNizaQq4qnasD5XMaC4MF3wi1z019azwkvK3ri2L1AbtKm69k4vIHFAC87bVaqh+hbgQ8p5Bficg==
ARC-Authentication-Results: i=1; mx.microsoft.com 1; spf=pass
 smtp.mailfrom=fujitsu.com; dmarc=pass action=none header.from=fujitsu.com;
 dkim=pass header.d=fujitsu.com; arc=none
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=fujitsu.com;
 s=selector1;
 h=From:Date:Subject:Message-ID:Content-Type:MIME-Version:X-MS-Exchange-SenderADCheck;
 bh=Wk3Hr+YZYOnA9c4qFs52o1qMoW820mKSZKVLAjr3tPA=;
 b=C4T3MPs4nKPb5L/BE1Vh5cTztj+zE4o9lySyHlluc31yPQVFhgViOCyC0PmjPJLbhiDfyVSZiBNH+D0wtPv2SWi3uAs0hG2Gi4Ij4xFTt2WXOQmoo/bVGk7pW9rIcMXC+uGhh6llg27mB8kJhS1eIFQXjF0pjEKARuzCklkye14twM28rVsbNnbbiCxYLwb0oSNA0e7hrb/N5Pzk69HmmzOnuG2D+7npiTYJ8c0x1UoQrqc+PXoKUHJhVS44IgSIqPEgdbhPBZC87C7RqdbVHLVWlRxLqS6W7bUe95+mrOMzoTPzHI65VcqCgb89ye9L3nQbZX6RiJV7tPTHQ3Obng==
Received: from TYCPR01MB11476.jpnprd01.prod.outlook.com
 (2603:1096:400:3b8::10) by OSZPR01MB8371.jpnprd01.prod.outlook.com
 (2603:1096:604:16d::9) with Microsoft SMTP Server (version=TLS1_2,
 cipher=TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384) id 15.21.522.13; Thu, 15 Oct
 2026 01:47:57 +0000
Received: from TYCPR01MB11476.jpnprd01.prod.outlook.com
 ([fe80::38e7:2:fa52:18cc]) by TYCPR01MB11476.jpnprd01.prod.outlook.com
 ([fe80::38e7:2:fa52:18cc%4]) with mapi id 15.21.0522.012; Thu, 15 Oct 2026
 01:47:57 +0000
From: "Seiichi Ikarashi (Fujitsu)" <s.ikarashi@fujitsu.com>
To: "'Jorge.Mora@netapp.com'" <Jorge.Mora@netapp.com>
CC: "'linux-nfs@vger.kernel.org'" <linux-nfs@vger.kernel.org>
Subject: [PATCH] nfstest: CACHE: skip "should have changed just after" test
 for ac{reg,dir}min
Thread-Topic: [PATCH] nfstest: CACHE: skip "should have changed just after"
 test for ac{reg,dir}min
Thread-Index: Ad1cRxqSjhjy326WQFeweYpCx1pmLw==
Date: Thu, 15 Oct 2026 01:47:57 +0000
Message-ID:
 <TYCPR01MB114767516EEDBA1EB4E688D0F889C2@TYCPR01MB11476.jpnprd01.prod.outlook.com>
Accept-Language: ja-JP, en-US
Content-Language: ja-JP
X-MS-Has-Attach:
X-MS-TNEF-Correlator:
msip_labels:
 MSIP_Label_1e92ef73-0ad1-40c5-ad55-46de3396802f_ActionId=da149ce1-051c-4b58-8e94-af90007f11e5;MSIP_Label_1e92ef73-0ad1-40c5-ad55-46de3396802f_ContentBits=0;MSIP_Label_1e92ef73-0ad1-40c5-ad55-46de3396802f_Enabled=true;MSIP_Label_1e92ef73-0ad1-40c5-ad55-46de3396802f_Method=Privileged;MSIP_Label_1e92ef73-0ad1-40c5-ad55-46de3396802f_Name=FUJITSU-PUBLIC?;MSIP_Label_1e92ef73-0ad1-40c5-ad55-46de3396802f_SetDate=2026-10-15T01:47:01Z;MSIP_Label_1e92ef73-0ad1-40c5-ad55-46de3396802f_SiteId=a19f121d-81e1-4858-a9d8-736e267fd4c7;MSIP_Label_1e92ef73-0ad1-40c5-ad55-46de3396802f_Tag=10,
 0, 1, 1;
authentication-results: mx.microsoft.com 1; dkim=none (message not signed)
 header.d=none;dmarc=none action=none header.from=fujitsu.com;
x-ms-publictraffictype: Email
x-ms-traffictypediagnostic: TYCPR01MB11476:EE_|OSZPR01MB8371:EE_
x-ms-office365-filtering-correlation-id: 44700ef3-167d-4270-b2b9-08df2a5e5667
x-ms-exchange-senderadcheck: 1
x-ms-exchange-antispam-relay: 0
x-microsoft-antispam:
 BCL:0;ARA:13230040|23010399003|1800799024|366016|376014|10067099003|18002099003|1580799027|11063799006|38070700021|56012099006;
x-microsoft-antispam-message-info:
 P0aK90cX4djiQ9vrxUIuWoovYAWYca++vIQthtsZ74u7Cwv7zagp2wx3mX4nBcKKCJ8PkGefk3KF/8P2Nbr4Q5vH/erCDzFwG737NOU5LIPdC0rStKBq2yBjwyvFbpC5uPlzRI4Jm6LmCNhQhUuH9/2Qw2AWfwtHkRARjpS5QjoywFHoGitXL+n0Y9Mtr/x47jYS+WiVlYkCIdyYkxDMTF3K2faF1cAtl/yJ99+5i6qK3p7YukdDGlPJhPprjHZgtkYMUWNTh0lzjyBybmEBifrtKoc++mmF0vLuZgF2NszxnU1BsVUvw9mbNqu7DPU2GkGxIPzuS3PfaOlQYwYApNjRYlt0sbZ7CVlt3BflOmwMzIrNEbA637UxkZOXKOjLpjUwpFVTxu3N90wL6gET26/QkA6FK06JK3YiSsk/vIWmd8a0uik8CSH3lBgd3KV03a280ijlPPWgq7+b0Q4o0KGxbqNGCy59adv9K22Cv3tI0jsyoN4grt0VT4YtHEErJLbkAhWKWcJOQv0vR45eDJapGvsfi8MZmwfvW2j21fIlWJtLH3Lqjp5gKmyiTlVH5oMTlotjQ+i7wP8PFDblLrOHjceOENU2CsqieUVNk76D+m3Rw82qyWTXnpW68CAgJ+C9A33Iv0m9iow0iaqFR2HZ5fotgeTJxVRm3BqI12JfsgjOQrCc9foiQzgRCSIupZ+hb9MvEfo3EOCn7llgswAeCwYr79O5eO/+zgMTpkdIWpluDQmj554YtU38BY0R
x-forefront-antispam-report:
 CIP:255.255.255.255;CTRY:;LANG:ja;SCL:1;SRV:;IPV:NLI;SFV:NSPM;H:TYCPR01MB11476.jpnprd01.prod.outlook.com;PTR:;CAT:NONE;SFS:(13230040)(23010399003)(1800799024)(366016)(376014)(10067099003)(18002099003)(1580799027)(11063799006)(38070700021)(56012099006);DIR:OUT;SFP:1101;
x-ms-exchange-antispam-messagedata-chunkcount: 1
x-ms-exchange-antispam-messagedata-0:
 =?iso-2022-jp?B?OUNQcDlaRVJIU1VnK1pCVWxlOW5pakJacE5CY3BSV1hlc084MUx1V3RB?=
 =?iso-2022-jp?B?Wm55eDlJd0lDQ1g1ZjY4SmY0Y0c1OWFXakcxZHpPc2tPdFNyMkhNYkJz?=
 =?iso-2022-jp?B?SmkyVnZGb3h1eGFDd216VHNGODdNWDc1ck12aEJVcUtRUGRvN293MlM5?=
 =?iso-2022-jp?B?b1RpdGlWMlBITE14Znd5ZmNTYlhHbUdIU010Q2RoLyt0aEJGMnlEWXRV?=
 =?iso-2022-jp?B?TmxGQmFPSmtKY1FIRmVGcVF2RmNtaEhxZmhOdWF2N0p1LzRLWU1VajNp?=
 =?iso-2022-jp?B?YVZ3Zm5GaWtjNmZ6LzNPcXV5MCthR08rbTVVWCt4YUZzcjBQdWZnbFFP?=
 =?iso-2022-jp?B?MjNyUFg0a09uUTVWNGQ1SE9aZGNWaVV3cDVEalIyT2h1NlRJcGlaT0hF?=
 =?iso-2022-jp?B?WGxzc0JPUStXRzhVc1FFZjg0cENlb2o0VlhyUW1EUWpzcSt6TnRscWVt?=
 =?iso-2022-jp?B?NHFSU2svcnJ0clp3OXNBcXRacHltZGdya0JmeVdOeHhzSHc0NnVlRmJ6?=
 =?iso-2022-jp?B?Qnl0a0c0TFJjcDkvSmxSZGwyQ2hHcWt3SHkrc2pKc0tsZVZqWDVUdXdv?=
 =?iso-2022-jp?B?Q05DOFdzanpqbXc1ZHBObHpUREY0aHNmUllsMG9WdFFscm1Ka0tHbHgx?=
 =?iso-2022-jp?B?Yms1NkZ0RDZPbkNnUHNJRWR1dHdncWtrNlI4TzR2by9yWm5WSWhLbUdX?=
 =?iso-2022-jp?B?R3FPVHA1bWUxZFk1S0VkNFF2cXU2cElsYzgxQkRyTmRZeFgvbm1CK0hU?=
 =?iso-2022-jp?B?eHF5aFo0YkdZNDZOdVpucHFFV043QU9yaGNaaVhoempqcWtXakF1Tnl5?=
 =?iso-2022-jp?B?N0JIK3FCb0Y2WjZRNmJOUmpjTllYTWMvbkhOQkx1SVNDTzJaZHJlOE5i?=
 =?iso-2022-jp?B?blpnTlZGNFFuL1NGY1Bkd0o1ZDhCeFdJNEJON1ZjYy9pSUEydkRxM3o3?=
 =?iso-2022-jp?B?SEc2U0xSTGVRNnp5NTNWMGgzWnExYnpPYjVDeWxtV2psNC9PUlJWTlh3?=
 =?iso-2022-jp?B?VFNTaG9aaUwvMmgyMUxYWFFoQnZ5d3hCR1dwcDk5Si9oOUZIbVlnQkxk?=
 =?iso-2022-jp?B?VWRlelY2QjFwd2sxR0M0V01DcWc5Z3Z5dGRJVHI4bVNwTHZNUnhqZkta?=
 =?iso-2022-jp?B?WGJOY2FRM250NGl4eEpnZE9wMHZBU2hiTnQxMU1kbDlCSEM2a2kxd1Q5?=
 =?iso-2022-jp?B?VktiTEdMeHJ6eTU5R0ZoNW1mRnNtYWt2VUM2QldoT3d2VFI2Mm5pQ2Fw?=
 =?iso-2022-jp?B?L0lDMHVRUUlXdGRpS3oxaDhHZW11WjBOdzJSRS9iWWtDZkE3emgxYlBM?=
 =?iso-2022-jp?B?SE1RSVJOemNMSGtsSlZsdFRDaFlvYk9QdWdlQWFDZGtXMlNnSWxvbFB3?=
 =?iso-2022-jp?B?aFo1TmdqVEJJU0ZaSVFVRWJJYkQwQ3o3UDU5dnYyUnR2enNGc09LYWgy?=
 =?iso-2022-jp?B?M3FDem4yNGQwUUFZdmhIaE5NWkZpOWM0ZERqZkVsTEhTbXJWeWJ3Rmcr?=
 =?iso-2022-jp?B?UmhoWW9CeklvY2txNGFFM1ZqbjVLOWZhZi9Henh3UnZVQ28wLy9EeGps?=
 =?iso-2022-jp?B?S1ZVcjh6L21HemVYUW00OHJ1UFhLalJkVjNyb3hOYWJhMDhlYTV0bFVi?=
 =?iso-2022-jp?B?Tk84akM0c2UxKzV6cThxM2tyZ2QyajZhdWd3cVV4OGx2TmR6TVlNaFBI?=
 =?iso-2022-jp?B?V1JRZkt6UXRMR0hHZXl6SXNKdFcyMHo2aTk4Nk9abGpWTWsxVVd0WWVx?=
 =?iso-2022-jp?B?cjBvNWt2UFRzOVNXNHVqdW5nV1Nzem93ZWhOVVhadE51aXhpQTRXTjVW?=
 =?iso-2022-jp?B?NDN4SzJxUzV3WW1OS3N0ZytISlZqL2l4WFk4TGxURWxidkg4YkVTTmZu?=
 =?iso-2022-jp?B?WHducXhDL2pheG90SGw3MnM4SURKOVp3RHA1YWxtUEYxUGJON1EyY1k1?=
 =?iso-2022-jp?B?WXdNb0NZTDkyY1ZtUWgyWHVaU1hLb25SYU1zOHl1UHg5ckdRTm1INDdC?=
 =?iso-2022-jp?B?M0RvTGlNNjBTcUduM2J1YktJR2RyYzlaMWs1bGxJNlJybXVHN0xvQ2pQ?=
 =?iso-2022-jp?B?dzBYdzhjM01mRmcyYStLMjg0a3l4azl5MDY4ait5Y29UanFUOU91WGpD?=
 =?iso-2022-jp?B?YVRTak9HOTBPVjJtUEdyWUYrNzN5WjBtZ3BaVGNpNmNjWGc5WFBDSU1T?=
 =?iso-2022-jp?B?MnErMUYzaG94Wk5FNFFmd0FZRmtldE9mYUpoZlhnQ3JGQVp0dlJZVHhR?=
 =?iso-2022-jp?B?M0taUTNONVZ4SUFFeGFNdHNwbzVjTXNrclZkdnRzYUhtYnhDc0IxcnJh?=
 =?iso-2022-jp?B?cDh5Ujg0eUJYSjM1NndhdkF4YjNEVTFuN2paYVZaaUVUTUtaQVREcmhU?=
 =?iso-2022-jp?B?RHJITHp5OWc2S0VSZGtqbGs3dWJCZGVKS0xZL1RaaVVHQWtITDd1ZnZh?=
 =?iso-2022-jp?B?bUFZSjA5Ukw4Qmtwcnk2QkUrcnlYUEc0M2pnNHdYcnV4S3pUckxRMkZu?=
 =?iso-2022-jp?B?dUxLRjk0cnBKa3NFT3R6QXpCQ2lBd2xpZ0ZGZz09?=
Content-Type: text/plain; charset="iso-2022-jp"
Content-Transfer-Encoding: quoted-printable
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
X-Exchange-RoutingPolicyChecked:
	N+klOPxGTcVd6fKHamrz18WqcHHilap4MibDu4VWoMsT2DpbMHIhDBZgXTlnrtpRvtjXnw6ugN9zAZLOozsoiZxb41eh+ZXRdcrsWZOPccRivzAhyoX2x7ehhxq3J2YWTyHywmkduy5wgfhw1s2swdLF1lJOA+0fNKMZ9lTFqHrsM2qo2L784iqtyYKUpzpVWrZcQKnt8IIcpzZwGeUd+Eu29ZEQ5ByKP4rcU9U7MyleD9YE3mFfgp9lJw+GweSs/2qZaPL+gPlxBWauDcJRFUQuKCCFr89RHf/WjkCny7WDYIXAzVJ9DH1x0uGNdmUzjReeU4Co6LydzGUlmBtW5Q==
X-OriginatorOrg: fujitsu.com
X-MS-Exchange-CrossTenant-AuthAs: Internal
X-MS-Exchange-CrossTenant-AuthSource: TYCPR01MB11476.jpnprd01.prod.outlook.com
X-MS-Exchange-CrossTenant-Network-Message-Id: 44700ef3-167d-4270-b2b9-08df2a5e5667
X-MS-Exchange-CrossTenant-originalarrivaltime: 15 Oct 2026 01:47:57.4726
 (UTC)
X-MS-Exchange-CrossTenant-fromentityheader: Hosted
X-MS-Exchange-CrossTenant-id: a19f121d-81e1-4858-a9d8-736e267fd4c7
X-MS-Exchange-CrossTenant-mailboxtype: HOSTED
X-MS-Exchange-CrossTenant-userprincipalname: Yi/G9hKZ79TRKXDMuauW+Z/8WqPER5VyTsXz/9wR8lDnLpfooO+Ue2MCiVsm/usxi6e3siuRgMk2d2tWy52B4TYrzvp5jhPEVc3UvfYy/2s=
X-MS-Exchange-Transport-CrossTenantHeadersStamped: OSZPR01MB8371

The test expects a file modification on remote client will be seen
on local client immediately after ac*max/ac*min seconds, which is
guaranteed for ac*max but is not for ac*min.

Signed-off-by: Seiichi Ikarashi <s.ikarashi@fujitsu.com>

diff --git a/test/nfstest_cache b/test/nfstest_cache
index 0014366..3e6d86e 100755
--- a/test/nfstest_cache
+++ b/test/nfstest_cache
@@ -257,11 +257,11 @@ class CacheTest(TestUtil):
             self.dprint('DBG3', "Sleeping for %f secs, just past %s" % (se=
lf.justbefore, acstr))
             sleep(self.justbefore)
=20
-            # Should go to server
-            test_expr =3D self.file_test(data_cache, fd, data+data1, dlen+=
dlen1, atime=3D(time()-stime), inwire=3DTrue)
-            self.test(test_expr, "File %s should have changed just after %=
s" % (cache_str, acstr))
-
             if acregmax:
+                # Should go to server
+                test_expr =3D self.file_test(data_cache, fd, data+data1, d=
len+dlen1, atime=3D(time()-stime), inwire=3DTrue)
+                self.test(test_expr, "File %s should have changed just aft=
er %s" % (cache_str, acstr))
+
                 stime =3D time()
                 self.dprint('DBG3', "Change file %s again from remote clie=
nt -- cache timeout should be back to acregmin" % cache_str)
                 self.clientobj.run_cmd('echo -n %s >> %s' % (data, self.ab=
sfile))
@@ -280,10 +280,6 @@ class CacheTest(TestUtil):
                 # Go just past acregmin
                 self.dprint('DBG3', "Sleeping for %f secs, just past acreg=
min" % self.justbefore)
                 sleep(self.justbefore)
-
-                # Should go to server
-                test_expr =3D self.file_test(data_cache, fd, data+data1+da=
ta, 2*dlen+dlen1, atime=3D(time()-stime), inwire=3DTrue)
-                self.test(test_expr, "File %s should have changed just aft=
er acregmin" % cache_str)
         except Exception:
             self.test(False, traceback.format_exc())
         finally:
@@ -424,13 +420,13 @@ class CacheTest(TestUtil):
             self.dprint('DBG3', "Sleeping for %f secs, just past %s" % (se=
lf.justbefore, acstr))
             sleep(self.justbefore)
=20
-            # Should go to server
-            dirlist.append(dirname2)
-            test_expr =3D self.dir_test(data_cache, dirlist, nlink+1, atim=
e=3D(time()-stime), inwire=3DTrue)
-            self.test(test_expr, "%s should have changed just after %s" % =
(cache_str.capitalize(), acstr))
-            nlink +=3D 1
-
             if acdirmax:
+                # Should go to server
+                dirlist.append(dirname2)
+                test_expr =3D self.dir_test(data_cache, dirlist, nlink+1, =
atime=3D(time()-stime), inwire=3DTrue)
+                self.test(test_expr, "%s should have changed just after %s=
" % (cache_str.capitalize(), acstr))
+                nlink +=3D 1
+
                 # Increase the hard link count by creating another sub-dir=
ectory
                 stime =3D time()
                 dirname3 =3D self.get_dirname(dir=3Ddirname)
@@ -451,11 +447,6 @@ class CacheTest(TestUtil):
                 # Go just past acdirmin
                 self.dprint('DBG3', "Sleeping for %f secs, just past acdir=
min" % self.justbefore)
                 sleep(self.justbefore)
-
-                # Should go to server
-                dirlist.append(dirname3)
-                test_expr =3D self.dir_test(data_cache, dirlist, nlink+1, =
atime=3D(time()-stime), inwire=3DTrue)
-                self.test(test_expr, "%s should have changed just after ac=
dirmin" % cache_str.capitalize())
         except Exception:
             self.test(False, traceback.format_exc())


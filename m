Received: from AM0PR02CU008.outbound.protection.outlook.com (mail-westeuropeazon11013065.outbound.protection.outlook.com [52.101.72.65])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 50EA636195A
	for <linux-nfs@vger.kernel.org>; Wed,  5 Aug 2026 07:32:44 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=fail smtp.client-ip=52.101.72.65
ARC-Seal:i=2; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1785915167; cv=fail; b=l+zEQ8vfSiEj0jTX2RbYsK5U+JAw7rOw+v/kNILysWqGpGWAWv1dxG/iAQYEuVp1SM+KTRPNX8zYX5TJPUSCo6Be3EGL4Rga1VV5j6tB3SDc4rC7Pi5VXDv5bmPbYDiAkYOXOc75ffTxnGhtR7tn4O56JKVPxJ4dskcG4DVM0ho=
ARC-Message-Signature:i=2; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1785915167; c=relaxed/simple;
	bh=ul1qRDB8v8vXMJJnKnq2IKAzvpzMI6+n5LcXXYu4Gb0=;
	h=Message-ID:Date:To:Cc:From:Subject:Content-Type:MIME-Version; b=CRA/uCXOXpk5Xn8/+SCz16EjmyfPO1lhKAyjks54yQrzyfCwtpl6EFXHLCbMKnBHxB1vzMAXcRt7RAttxkk5+4y4C+hA7RcQrAMMbJZnRGmvi+kWmhkyz5o5tgfX+1Hh6MnmK7EZuUBq5u5229n8waPbi3b6+SCdKfpUybhhsQc=
ARC-Authentication-Results:i=2; smtp.subspace.kernel.org; dmarc=none (p=none dis=none) header.from=est.tech; spf=pass smtp.mailfrom=est.tech; dkim=pass (2048-bit key) header.d=est.tech header.i=@est.tech header.b=kKtCxrhj; arc=fail smtp.client-ip=52.101.72.65
Authentication-Results: smtp.subspace.kernel.org; dmarc=none (p=none dis=none) header.from=est.tech
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=est.tech
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=est.tech header.i=@est.tech header.b="kKtCxrhj"
ARC-Seal: i=1; a=rsa-sha256; s=arcselector10001; d=microsoft.com; cv=none;
 b=Z1yAhzO6qZQ3zPOpqleywVqig5Fah4TVyidKQtBaFTy00TLI+6SBxJKnHaW4z9g5nYQOPcR0EwTBEv7kLH/d0URLJRFoPNKm1YmDko+mGD4N/ypGetyVS3cWoR2Xi0laMVkXzfvQZ+A/Z8Zi04xDOET0dzmlXnvvtX+kv6HrySJ1q9dPn9G8KSXrAADVz3JHIAR1BJJCL3XQl50y1LpddAPXu3KLj9+V3OaVNsB6QVDHwef2NuSBCaUoyb8oLsMWVKTT+0XFXutdA/P+gQLqYTBye/GfSuu9s0j6f2luBiYjz24rjsbSav7VjmimF3+Vo0yumuLlsA+oWYFtJstwkQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=microsoft.com;
 s=arcselector10001;
 h=From:Date:Subject:Message-ID:Content-Type:MIME-Version:X-MS-Exchange-AntiSpam-MessageData-ChunkCount:X-MS-Exchange-AntiSpam-MessageData-0:X-MS-Exchange-AntiSpam-MessageData-1;
 bh=aV2LvkHg/N6PSj5FfFrBoBdFAAPW7W0SXvjV7133fBk=;
 b=qQiHeUKfxNbfIwM/jP3AXb15knk4m4lVWOwuT73ixkBrIdM4DLdK6QDYlqcI10YDmRfbyhnXGlXgMOgxrQQWiRpnNVXTj4aJYlHeB+gsrnl7NOVv6MMxwsqhb8Ha/UmL+o+Ip7NStacPoMdBCd4Bi8dryzg47uQ8hF2OKMi0HN9ejS+3nC/EhnZ74R7XhAvXdA20YFBOzpCygY5FNG2K9t/J6hetUBl8k1kKfVrQ0BgxYblBULfg5axZ/4U1X5fXRan8NSZg1In03BssErudzHZoEXUCnK8rEhtrIZDPZHoiK1xH6ADRZAAMHQyGoub51BYWvi530jxmQ0JVHkApUg==
ARC-Authentication-Results: i=1; mx.microsoft.com 1; spf=pass
 smtp.mailfrom=est.tech; dmarc=pass action=none header.from=est.tech;
 dkim=pass header.d=est.tech; arc=none
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=est.tech; s=selector1;
 h=From:Date:Subject:Message-ID:Content-Type:MIME-Version:X-MS-Exchange-SenderADCheck;
 bh=aV2LvkHg/N6PSj5FfFrBoBdFAAPW7W0SXvjV7133fBk=;
 b=kKtCxrhjyLscREZ5Zjn1K0ssmKArUg8O3YrSOXjMm0Nn1ofghcKBrVmeED51sm4tkGe59l1SflY27FV21QHvALVW7J41NhYcuDspvQTceKhuGxteZea0E/NsCJbdTbmFt5xRrEIsO6fstfYRY8DkuUb0BkHxOvF+suiVfIcpVT/ug7UoZuoowsunrTuSWfG6eo/riY0eDME68hUBCOAU63id8LnbGBjZdwWi0scyTmWzb2+06vcXCa7ftTCcmdd8pJWmyPAODNmC3vpApccRnil2W9auYWwkm5mp9F+HLi6z8uHASpusxj2T22KY8KALEXawdHiew3Ghr1duUZT9QA==
Authentication-Results: dkim=none (message not signed)
 header.d=none;dmarc=none action=none header.from=est.tech;
Received: from DU7PPF66507B2D7.EURP189.PROD.OUTLOOK.COM (2603:10a6:18:3::ad4)
 by GV2P189MB2407.EURP189.PROD.OUTLOOK.COM (2603:10a6:150:db::19) with
 Microsoft SMTP Server (version=TLS1_2,
 cipher=TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384) id 15.21.315.5; Wed, 5 Aug 2026
 07:32:37 +0000
Received: from DU7PPF66507B2D7.EURP189.PROD.OUTLOOK.COM
 ([fe80::7ab2:c6af:6760:5c85]) by DU7PPF66507B2D7.EURP189.PROD.OUTLOOK.COM
 ([fe80::7ab2:c6af:6760:5c85%7]) with mapi id 15.21.0292.013; Wed, 5 Aug 2026
 07:32:36 +0000
Message-ID: <9fec9f1b-1c10-4a20-8282-dfc9addb4ee8@est.tech>
Date: Wed, 5 Aug 2026 09:32:35 +0200
User-Agent: Mozilla Thunderbird
Content-Language: en-US
To: linux-nfs@vger.kernel.org
Cc: David Partain <david.partain@est.tech>,
 Daniel Turull <daniel.turull@ericsson.com>, roland.kovacs@est.tech
From: Jaipaul Cheernam <jaipaul.cheernam@est.tech>
Subject: [BUG] nfs-utils 2.9.2: exportfs link failure with --disable-nfsdctl
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 8bit
X-ClientProxiedBy: LO4P123CA0116.GBRP123.PROD.OUTLOOK.COM
 (2603:10a6:600:192::13) To DU7PPF66507B2D7.EURP189.PROD.OUTLOOK.COM
 (2603:10a6:18:3::ad4)
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
X-MS-PublicTrafficType: Email
X-MS-TrafficTypeDiagnostic: DU7PPF66507B2D7:EE_|GV2P189MB2407:EE_
X-MS-Office365-Filtering-Correlation-Id: f1a58de1-efb3-4adc-8d2a-08def2c3b887
X-LD-Processed: d2585e63-66b9-44b6-a76e-4f4b217d97fd,ExtAddr
X-MS-Exchange-SenderADCheck: 1
X-MS-Exchange-AntiSpam-Relay: 0
X-Microsoft-Antispam:
 BCL:0;ARA:13230040|366016|1800799024|10070799003|376014|23010399003|18002099003|11063799006|56012099006|6133799003|10067099003;
X-Microsoft-Antispam-Message-Info:
 qdl6TF5VO+oCYpKn6F1T95z1n2tj9oYmtVoCZm2RGMUEiB9PE3zwKkUvKWvwaPC5FumlptL/8U6tm8KqYEOqFqP1uPkXyiEtQLd6FMUYpeUMqa3NcUu+6ck3yTXNTBTsWcl6rZq7/3GaVouwtALCMQmWypj7mjx6CaWvnTRy+TpMwky75K+MU1yd02ZyVynsPbH1X0560RICQX2A+ddYK6xfKZNp6R9fj0xDUhrCbrKX8xDDVHgpYDiAYIoTeVovY/CjXZwXyab9vkRr0b0Rg4bXV+We6zMLH9mjw1MRifzub7PmrxuwEWOgwTwjjtGZVLASx2AAVZV2WI9PoNK5965LZvRrAnJnwZUIVf4+7W5Q9OvImkRtaK5ICbQUfNryR4aU8bpC1iUwZhPqDWj1kduOru1TzNopMcS+X1mCK1aX8VnLMfynHIHCeBy4XvCUHLlLUY0W1IMFJSXCTdh1lx1KLfNzArY6hLiPm+i2uoMlXRe7FwzhNYNYh19t5b7zsvEb4CD9kCOnRJViMVMnd7eOHpEDhcFQVJAjjvk/pBOWkk8azkHaeYbzIK7OoyfmMiyepEgaQnzNBjvZUJvzasOnUI7XIQSY+b1iBAreX0nL03IRzocExI4RobruL7QGKEQxhepqy0aiHJ+UnD8qZFZptOM01nHia/AruWQylNE=
X-Forefront-Antispam-Report:
 CIP:255.255.255.255;CTRY:;LANG:en;SCL:1;SRV:;IPV:NLI;SFV:NSPM;H:DU7PPF66507B2D7.EURP189.PROD.OUTLOOK.COM;PTR:;CAT:NONE;SFS:(13230040)(366016)(1800799024)(10070799003)(376014)(23010399003)(18002099003)(11063799006)(56012099006)(6133799003)(10067099003);DIR:OUT;SFP:1101;
X-MS-Exchange-AntiSpam-MessageData-ChunkCount: 2
X-MS-Exchange-AntiSpam-MessageData-0:
 =?utf-8?B?bC9jUmswSytvV2E2NnE2UXBWeXljUVRDcVhkbUVtYTlObzhSV2JQRDhXcm5P?=
 =?utf-8?B?UDRweWgxOTFQY05jbmhveGUyUWh0a2RTaUl4SWNTZzBHa3hRaUE4TDQ1YytZ?=
 =?utf-8?B?cElDNFpaR3RCOTZVQXRTZkI3RWNFY1BDZTZYM1pTZVVRUVlkdUR3bk5QRXVl?=
 =?utf-8?B?ZUkyOXdXdjlQUHdML25rdEs4VUlyR0NuV0hlUlNhYUo3aEU0Qi9sKzgzRi9v?=
 =?utf-8?B?ai9JSHFQT3RFeDI4R0RuVkswLytWVFlCQmd0LzllQUo0UFlWOXZ4THBsVEZy?=
 =?utf-8?B?OGRWZXRLcGFndGJwUFQweUV2cHgrclF0aVdnaWR0Q0ZuNnlsNS8wK1VHYlBu?=
 =?utf-8?B?NmMyQVFobDh4NUpuK3B4RVpKc1NXcEZ4RWMvcHFNOFk2SnlQdVlVUHh2bjlB?=
 =?utf-8?B?OElNdEdkL3VPZm5aMkdJcGlMZTUrVEptZGNyTzFscndqemcvdGx4dEoydGh3?=
 =?utf-8?B?WFdVNUZEM1F0WDY2WUxac09NM0FZRTViNFVyUXhTeHRMeTNkYUxyTEpZcDBw?=
 =?utf-8?B?a0F2MC9MTmlRMEtEVWwvakE2YnJCTnRkdlh1ZVlrd2NhU2RkS3BqWVBSb3NP?=
 =?utf-8?B?ME1ncU8yTXA1SCt5a3FveGpqVUFZVkRyWjdXNVFxdWFjT01xVDlKSnJyWE5z?=
 =?utf-8?B?MkxFZ0JSODVCK0UyVWtUQzBOWFdtcHVva1FSeERwSWNTSDVTVXRsWFRCV1pJ?=
 =?utf-8?B?K09POTlrald6WHF5TmpCOXF2ai9qQndLWS95WUZxRzZaYWIwazFlcEJLblJr?=
 =?utf-8?B?UTN5OU8xVVFBajBqaC83S0llRkVNeXBxSzluOVNwVFZYN1FFK204MWx3TlYr?=
 =?utf-8?B?cGVEVmJPTkVHUW1JNFlsL3FOSUFlVU9Qa2VacjhGcUFPUDY0TTBOclNETmVC?=
 =?utf-8?B?em9TNVRZcVA4bHdDMmNsVlhvRUcrcnQwb3c4ZnF0OXZuQVlVc3VZVkhMZ2NM?=
 =?utf-8?B?b1JmQUg0RXJ1ODZuRjhZQkVGS3lHemZZcVUwOWluYjNtZVdtMWZOMndRKzgz?=
 =?utf-8?B?WjhiSXgvakljcXphRm5vUmxkejg2M2JtTnNjSlpJU0h4N0FJQW92dEhXRHQ1?=
 =?utf-8?B?WTVXWEp5bUwxbmlaK0o3Z29jRVFVQ3dSdDk4a21WVDdoTVJ1cG9nbGdMQUpj?=
 =?utf-8?B?VDVhMTFiS1FwaDdxTWU0Mys0M2YwZmZkZ0J6aUNscHlJYVZpLzI3NGlyZ2g2?=
 =?utf-8?B?dStpNVJzSVp0NGJQMXdGdCtEaTF2Rk13MUNEZG1vdVpHL2p1VWZBaXJrK0Vy?=
 =?utf-8?B?SGpkeHM4Zk1KWGN4Zm9sL2FJWU5rY01zb1Y1alliVGkyYTd4akV1QU5LOXND?=
 =?utf-8?B?QkJSVFFqcG5Ca0FudWtUcUxMTVJyWS9uTVpNUlJaTjBRRDVGa25YQXBjV0pP?=
 =?utf-8?B?MTNVOXp6d1NCK1p2T2dDUERjVUl3Qlc0SXh6UGdUUUxDdzE1eURiM2FHVGlX?=
 =?utf-8?B?OFFVeHN6clZ0MkRGeDh3SVAzT3pabGJNalU0UDhWQllKMVFNUTdKV3dGbGFS?=
 =?utf-8?B?K3pkcEI5djVyRHl1UTJOS1I3UHVQSkNyOU5UUm82UlhILzY1UTg1YnFFTTBn?=
 =?utf-8?B?UUNpbWhlc0lERXdNWFpYMDd4QWgwUFZhR2h3R3J4bHpKZTd4dzVRNnEyMjFR?=
 =?utf-8?B?V2V3WnMyYWZJd0EyREdsN3ZYejZsRzFQMC85WnV3bmNqWHRXYVpXK1Z6VGRp?=
 =?utf-8?B?b1llN0lyOGZWVUk3RW9GM1N3UnU0bmZTRDNsS0JNcDlSVlFwNlJEaSs4dU1o?=
 =?utf-8?B?UFZTUE5CL0ptYmxnbCtFOW11TVA4T1FOb1RaVnJlYjFIUUJHaGhpajF2aFMw?=
 =?utf-8?B?M1l2NnNUcGhOTlJmYWFVQktqbDBTQjdxb3BjNVNHV3BGWmQ2WFV3allVZjFG?=
 =?utf-8?B?ZWRMU25uL1VFV2w2RzdRTjcvcUZLZ3Q3bS8vdnNnQlREZGRZWUhvYnNIZEJ4?=
 =?utf-8?B?TXhKQUJRRzlKS3dnWHNOZ0hvSHNIT0Q5eFhYRjA3czE5VW1wTjJBeitMUmhR?=
 =?utf-8?B?NUJYQ2ZScGFlSU5LR1drbi9LYmw4b3gyZEwrOEJtN3BESXRIcDg0NEwyVUMv?=
 =?utf-8?B?amQ5b3ZnSjBJUXFlYTU5ZzJua015bjFwTDRpcFZMbXA0dXJidXZORHNxWDFB?=
 =?utf-8?B?THFKSktIM3JpRjFCOFZ4K0pLT253VDRpdm96cmR6YXhjNUtRbldYZnZVZXV4?=
 =?utf-8?B?dHlubzVxak01Z1hZVFc5OWQxN3Urb0RFZHNGVmwzRTJ2aE53elpncVNqa1Na?=
 =?utf-8?B?bEV1b2FlMmNZOTJsY3oycHVDRWNkc3lhYjN2c1pwckdKZS9ML09tL2hxQVhU?=
 =?utf-8?B?bmo4ODVSbUhWRFdNblVDRFViWjFZWFNIVmtWTnBsU1gwcVZKczZrQzJmbkFn?=
 =?utf-8?Q?aSssJba9aAFztr9mJpN/2QnxVYafaqKfCUMs2aqbKKRWD?=
X-MS-Exchange-AntiSpam-MessageData-1: XZUuN1mdPzV3Kv6DtzyHbnPPVVycerwG13Q=
X-OriginatorOrg: est.tech
X-MS-Exchange-CrossTenant-Network-Message-Id: f1a58de1-efb3-4adc-8d2a-08def2c3b887
X-MS-Exchange-CrossTenant-AuthSource: DU7PPF66507B2D7.EURP189.PROD.OUTLOOK.COM
X-MS-Exchange-CrossTenant-AuthAs: Internal
X-MS-Exchange-CrossTenant-OriginalArrivalTime: 05 Aug 2026 07:32:36.3475
 (UTC)
X-MS-Exchange-CrossTenant-FromEntityHeader: Hosted
X-MS-Exchange-CrossTenant-Id: d2585e63-66b9-44b6-a76e-4f4b217d97fd
X-MS-Exchange-CrossTenant-MailboxType: HOSTED
X-MS-Exchange-CrossTenant-UserPrincipalName: csoD3+3sgBtUlt9obbSsTwxR6fb8/4wPusLTqEIXF0svhQYNvO69Qd7xGUs2CzP4Pd6+v28hocBmCRc1DPqpRyxApx3Q4nFyI7yqmkj+8n4=
X-MS-Exchange-Transport-CrossTenantHeadersStamped: GV2P189MB2407

Hi,

   Building nfs-utils 2.9.2 with --disable-nfsdctl fails to link
   exportfs. This is a regression from 2.9.1.

   Reproducer:

   tar xf nfs-utils-2.9.2.tar.xz
   cd nfs-utils-2.9.2
   ./configure --disable-nfsdctl --disable-gss --disable-svcgss
   make

   (--disable-gss is just to avoid the krb5 dependency; the bug is
   triggered by --disable-nfsdctl alone.)

   Error:

   /usr/bin/ld: exportfs-exportfs.o: in function `unexportfs_parsed':
   exportfs.c:491: undefined reference to `nfsd_nl_cmd_str'
   collect2: error: ld returned 1 exit status

   Root cause:

   nfsdnl.c (new in 2.9.2) provides nfsd_nl_cmd_str() and is compiled
   into libnfs only under if CONFIG_NFSDCTL in support/nfs/Makefile.am.
   But exportfs.c calls it under #ifdef HAVE_NFSD_NETLINK, which
   configure.ac defines unconditionally:

   AC_DEFINE([HAVE_NFSD_NETLINK], 1,
             [Define to 1 if nfsd generic netlink support is available])

   So exportfs always compiles the netlink code path, but the
   implementation isn't linked in when --disable-nfsdctl is used.

   This isn't triggered with the default configuration because
   enable_nfsdctl defaults to "yes".

   Possible fixes:

   Option A — always compile nfsdnl.c into libnfs (remove the
   CONFIG_NFSDCTL guard from support/nfs/Makefile.am). exportfs would
   always have netlink unlock-export support. libnl is already
   unconditionally required so this adds no new dependency:

   --- a/support/nfs/Makefile.am
   +++ b/support/nfs/Makefile.am
   @@ -11,14 +11,10 @@
    libnfs_la_LIBADD = libnfsconf.la -luuid
    libnfs_la_CPPFLAGS = $(AM_CPPFLAGS) $(CPPFLAGS) 
-I$(top_srcdir)/support/reexport

   -if CONFIG_NFSDCTL
    libnfs_la_SOURCES += nfsdnl.c
   -libnfs_la_CPPFLAGS += $(LIBNL3_CFLAGS) $(LIBNLGENL3_CFLAGS) \
   -         -I$(top_srcdir)/utils/nfsdctl
   +libnfs_la_CPPFLAGS += $(LIBNL3_CFLAGS) $(LIBNLGENL3_CFLAGS)
    libnfs_la_LIBADD += $(LIBNL3_LIBS) $(LIBNLGENL3_LIBS)
   -endif

    libnfsconf_la_SOURCES = conffile.c xlog.c

   Option B — gate HAVE_NFSD_NETLINK on --enable-nfsdctl, so exportfs
   skips the netlink path when nfsdctl is disabled. nfsdnl.h already
   provides a static inline stub returning -ENOSYS for this case:

   --- a/configure.ac
   +++ b/configure.ac
   @@ -256,8 +256,6 @@
    PKG_CHECK_MODULES(LIBNLGENL3, libnl-genl-3.0 >= 3.1)

    AC_CHECK_HEADERS(linux/nfsd_netlink.h)
   -AC_DEFINE([HAVE_NFSD_NETLINK], 1,
   -   [Define to 1 if nfsd generic netlink support is available])

    # ensure the system netlink headers have the latest features
  AC_COMPILE_IFELSE([AC_LANG_PROGRAM([[#include <linux/nfsd_netlink.h>]],
   @@ -279,6 +277,8 @@
     enable_nfsdctl="yes")
     AM_CONDITIONAL(CONFIG_NFSDCTL, [test "$enable_nfsdctl" = "yes" ])
     if test "$enable_nfsdctl" = yes; then
   +   AC_DEFINE([HAVE_NFSD_NETLINK], 1,
   +       [Define to 1 if nfsd generic netlink support is available])
       PKG_CHECK_MODULES(LIBREADLINE, readline)
     fi


   Both build cleanly. I lean towards Option B as it preserves the design
   intent that --disable-nfsdctl disables all netlink interaction with
   nfsd, and keeps the feature gating consistent between configure.ac and
   Makefile.am. But Option A has merit if exportfs should always release
   state via netlink regardless of whether the nfsdctl utility is built.

   Which approach is preferred? Happy to send a formal patch either way.

   Thanks,
   Jaipaul


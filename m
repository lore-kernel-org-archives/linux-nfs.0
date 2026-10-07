Received: from CH1PR05CU001.outbound.protection.outlook.com (mail-northcentralusazolkn19010020.outbound.protection.outlook.com [52.103.20.20])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 4DF694D2EC8;
	Wed,  7 Oct 2026 19:03:51 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=fail smtp.client-ip=52.103.20.20
ARC-Seal:i=2; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1791399833; cv=fail; b=VcLhoOBKPOEsXr+xFswA5VaZ8NzWwH+Uo0UbbVr3rYrEMTwNrTUhTvWRC8ZQZ8md6+2j+jYjoEqbBZ/hZpgK110vRt1Ti0f21V0IgCPd/x4o5N6cEAFXEE3Ol1mLHWV7va/KUl3miH9ZTEvlTboFeGGyXDACVIForSZ/SZN7neg=
ARC-Message-Signature:i=2; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1791399833; c=relaxed/simple;
	bh=5q0l9O4z2VReiyBpTkDf/ZuYVuOrwfM/DhGxxcVgYZw=;
	h=From:To:CC:Subject:Date:Message-ID:References:In-Reply-To:
	 Content-Type:MIME-Version; b=kObwdX8GUmfiQ0F4Z4RO9NA5PcVhGtLf1ucVVSlZorlk/9mHBIHRHstv+3ZvgrS1UDFgNdTJHfcxquz3LeM2bSh90wgxLNLLWNr5dNg93w0coC7iwuBH9G2c2jKRAnsNYNqmVUf2qxLT8JjTsbfH7dwl7WkVr9Kriv79Gep64f8=
ARC-Authentication-Results:i=2; smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=hotmail.com; spf=pass smtp.mailfrom=hotmail.com; dkim=pass (2048-bit key) header.d=hotmail.com header.i=@hotmail.com header.b=oK8hyQUZ; arc=fail smtp.client-ip=52.103.20.20
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=hotmail.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=hotmail.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=hotmail.com header.i=@hotmail.com header.b="oK8hyQUZ"
ARC-Seal: i=1; a=rsa-sha256; s=arcselector10001; d=microsoft.com; cv=none;
 b=Ta1b6st9vqKdJDmuppC5bjpmMxT3pZ02Mqk8i/qAfZ877KzyV31uPZsjA/7Z3xPghSEUdR1bYUkHR1p05UjQFg45x+NIL8sklUhbGI1lEuGHuxdVxK2VzZNUyREDLsUu5V5AcgT8kZxmPOmmPGCr1RvvJ65JXJVCGSum0qe+rKgxgF3NObfsLQ8tWcQPedef6cW7sZwsl3qnmJgwKitDOva76KcYSGnIlBns+EtAqh+h/FqRnjnWsov9RlNogcRjoS1zOg3qLFTMUV6rUyjAel5KlV/awPV5XQmZ7Ae1bJN6FzQwCN0wYmsit7U0Y51GYTyzUrUCBiE9KXtBZzCV8w==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=microsoft.com;
 s=arcselector10001;
 h=From:Date:Subject:Message-ID:Content-Type:MIME-Version:X-MS-Exchange-AntiSpam-MessageData-ChunkCount:X-MS-Exchange-AntiSpam-MessageData-0:X-MS-Exchange-AntiSpam-MessageData-1;
 bh=5q0l9O4z2VReiyBpTkDf/ZuYVuOrwfM/DhGxxcVgYZw=;
 b=n9UhfHcYezn61klnlReHzLHlFxiFUo0crH7fEcxinUo3BJ/kdzqj/BFPmt+gEPXksMaUOFi/xYt7dNmlkKWVg8k3WiY6TYCFfSOx2LjClkN7eNVd2tdcFGWPPjj5/Sd3GwczFbGP8+wIVcNRM/2Ar73pfQloN4SX8kNuoF1lDDXsyT8b5gCz0NJJCjV9+xsqCpqp1J+JSMTiH/KJqYO5V9M0QrQuNUD5K9jkZvjyizZf6GWkI+cfgLmCxjzzCYAAAjS4JGWcHD/RsT5xPOcjJjlNVQhQ9Olz3HIMjCoEUjV4emy3KrLUzegi1zxZxJwuoB/VJ4TKNkVseSKA3485Sw==
ARC-Authentication-Results: i=1; mx.microsoft.com 1; spf=none; dmarc=none;
 dkim=none; arc=none
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=hotmail.com;
 s=selector1;
 h=From:Date:Subject:Message-ID:Content-Type:MIME-Version:X-MS-Exchange-SenderADCheck;
 bh=5q0l9O4z2VReiyBpTkDf/ZuYVuOrwfM/DhGxxcVgYZw=;
 b=oK8hyQUZZQaiYMk7Exc2UIAmQG31hubz1b9aHAwHoVdUBox5nhmLxJGMbJDW9x9upPBHfL2p5R3N969DvcHGFKhwxsrNhLAAmVQWrgJLU2cEMEanKoFLt1BRVJYXrpVH+mEupDLO8NrYxHJQfEOapmi7hCxLFlfDCp553wPQm0/pB/SWuR5WBt5s/NzHPQbGYQXnSXTkeM3ZrngZXQP+cfwe7aY+0vddalAuC+V02fN5Chj8uBJ2xGann/FR5Ssvye1N+5Lr10s3koKsO/tL5n2YFbQBL5X5OuFbb8jq8jMblg2DPCOyRES8IcAyurZKe6ajlP7VjIa243GNFNbU8A==
Received: from DS4PR04MB9846.namprd04.prod.outlook.com (2603:10b6:8:2ea::15)
 by PH0PR04MB9905.namprd04.prod.outlook.com (2603:10b6:510:3ae::24) with
 Microsoft SMTP Server (version=TLS1_2,
 cipher=TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384) id 15.21.496.15; Wed, 7 Oct
 2026 19:03:47 +0000
Received: from DS4PR04MB9846.namprd04.prod.outlook.com
 ([fe80::f475:2ef9:2387:5e0]) by DS4PR04MB9846.namprd04.prod.outlook.com
 ([fe80::f475:2ef9:2387:5e0%5]) with mapi id 15.21.0496.010; Wed, 7 Oct 2026
 19:03:47 +0000
From: Danny Pidutti <danny_pidutti@hotmail.com>
To: Daniel Pidutti <Danny@lightningiq.io>, Chuck Lever <cel@kernel.org>,
	Christian Brauner <brauner@kernel.org>, Al Viro <viro@zeniv.linux.org.uk>,
	Amir Goldstein <amir73il@gmail.com>
CC: "linux-fsdevel@vger.kernel.org" <linux-fsdevel@vger.kernel.org>,
	"linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH] exportfs: Release the get_name() directory file
 synchronously
Thread-Topic: [PATCH] exportfs: Release the get_name() directory file
 synchronously
Thread-Index: AQHdVnt+XztgP33s002uCdHGjnc4/bbyYivagAAN4d4=
Date: Wed, 7 Oct 2026 19:03:47 +0000
Message-ID:
 <DS4PR04MB984629798B7EB97DBB56117C8D942@DS4PR04MB9846.namprd04.prod.outlook.com>
References: <20261007164648.50493-1-cel@kernel.org>
 <LV2PR15MB538107FDEB65AB1A4CEA8D5EC6942@LV2PR15MB5381.namprd15.prod.outlook.com>
In-Reply-To:
 <LV2PR15MB538107FDEB65AB1A4CEA8D5EC6942@LV2PR15MB5381.namprd15.prod.outlook.com>
Accept-Language: en-US
Content-Language: en-US
X-MS-Has-Attach:
X-MS-TNEF-Correlator:
msip_labels:
x-ms-exchange-messagesentrepresentingtype: 1
x-ms-publictraffictype: Email
x-ms-traffictypediagnostic: DS4PR04MB9846:EE_|PH0PR04MB9905:EE_
x-ms-office365-filtering-correlation-id: 1615598e-6e96-4eea-5f08-08df24a5b77f
x-microsoft-antispam:
 BCL:0;ARA:14566002|25010399006|8060799015|25031999004|24021099003|4140399003|31061999003|37011999003|12121999013|8062599012|19110799012|41001999006|15030799006|15080799012|52005399003|40105399003|1602099012|10035399007|2607281247196008|102099032|4302099013|440099028|3412199025;
x-microsoft-antispam-message-info:
 =?iso-8859-1?Q?iTAkwaf8wZ17dRQN+/Fx1DD0hGW4rXt6jxxUQ3jwqJQ8znclfG44nRdfh0?=
 =?iso-8859-1?Q?knea9j8aYGxFdShQkb9DW5adWf9yiZ7ixtNGzPfpD5Tw2QO0TOahfyUieU?=
 =?iso-8859-1?Q?hP1VejDVrBeO3tN8V9fxaXpnu/wp9b2wBI1s1JaBk0mSh0nr3pf/vcA5BJ?=
 =?iso-8859-1?Q?U6ObH24F9IsGCxdbf/9XWk9ZTc9I1O9Y7pAgtFJb6fSELWDuvrxfhj4Fup?=
 =?iso-8859-1?Q?VElJerlotiq0PKnZxznXcXziwgkMNx3x3p3Gu7TEduYG4IpGEgnICpMtkJ?=
 =?iso-8859-1?Q?AveMdkPd7fjFNJcfwyEACeILxRCyQ42XFX9S2wjnvxr/ZhprbVz9K28ww5?=
 =?iso-8859-1?Q?dpzo5Ke7Vi/ZzbBo6ipe4ZjJeKK+TaSapKipf/QUsWvhOZi2cZ6FuBDksF?=
 =?iso-8859-1?Q?oFSI7zQtHCC7VFAPaaDYd3/5AcTjQh8GjywfPqRkB9qI4D17dqMTM4M2Bg?=
 =?iso-8859-1?Q?/hWZAnssu9Sq13WuFtg/f4W2uNvyWlPaBB5V3GpTFb2jnT4oj/Qt4Rdc52?=
 =?iso-8859-1?Q?Nxg2DhmuGr82NHHTp/Ie08BKRxJCqw17wygIDuZ7RD2SSZOM9KwvbJWQwc?=
 =?iso-8859-1?Q?pdaE9ESXN/AViYYf5Ltm4By3XZX2wv4Xg8wFQ7Q4M4r43kp7v8zoarL3D9?=
 =?iso-8859-1?Q?jyYpmOiyhPwZF3Q/2JmMSymW17oxh104iOFcVl2ktXZKzJhoVqXLQ8Pi5X?=
 =?iso-8859-1?Q?yWtDrITQEDiy9M5vTU38ol2JXe+YYtNRgswpRV9Gl5xlAzUO9ByzdayYl7?=
 =?iso-8859-1?Q?B0A1N0mvq4/gPtvyyAyIlI/Cf1BsN1goZWUvOlJQrySGe+KRbNpIyxPIgj?=
 =?iso-8859-1?Q?EwaI0RDddqphwEfYPvCctXbGavZmw4PEfFlVrvGlVrg/TpCszxRztG2tBe?=
 =?iso-8859-1?Q?MdbJ9infkcwTNiiMGrb58UTi3MhItr9X2I5HkW5SCguOYAHoAES5hnj3WC?=
 =?iso-8859-1?Q?JmQLa6z/WpY2f5WmSEvKju5FcRg7ZttzKTD7g4cJe2oM4PHxV6NNiPX9rn?=
 =?iso-8859-1?Q?6YJhmdlsgSvoS5irrvctHIIg9hNqJ10JEMW0/COGZodND0k9yGhXg7S4Fj?=
 =?iso-8859-1?Q?rhdn4QNKNLV4MyvVU8FJyqpOxc7+No+Y8QrADmUmd5gq6GHwi8o12m3nXi?=
 =?iso-8859-1?Q?ZVEvSY4x5yHkZKPEos/LkO5o3TG8naRO/9ny1egYUPQXI6U4NSCUHPimLa?=
 =?iso-8859-1?Q?7IpLlnWC4Fnf7w=3D=3D?=
x-ms-exchange-antispam-messagedata-chunkcount: 1
x-ms-exchange-antispam-messagedata-0:
 =?iso-8859-1?Q?NLWkJ1bCFe9F6Ag+tzqcrEKT2RpegM76VYV6m1xRtvbUqTp9rYNq//Z6Gv?=
 =?iso-8859-1?Q?6ZNiuyBTr2DesaNWxP3WfuPFDQydodBvmsuo9Nm7XNfCE7en2TKuxkdbHv?=
 =?iso-8859-1?Q?00n7AcyF1/ghqeT8m046N6S/AWvrSDyI74zpPxF4pvV0qnCRuAIBqMHeXN?=
 =?iso-8859-1?Q?76c6vt5a8peA1lJ7q9LV8e5SkEp/CWugG8Amv3Xm4Y1ECM3F52LiOQ6KoB?=
 =?iso-8859-1?Q?dzfoaZXGCJL3mV18MI6sn37MT0/HVxon1HeasbrQ7+h6PaVMe61Ldpw3mu?=
 =?iso-8859-1?Q?ZP9W1ePaUISB1Tp9WOA6b9T/+5V2vHQwW82qEmqPUMb1UQ453TYjOdAEk7?=
 =?iso-8859-1?Q?lSB6jbcuC3nsQegKStDKhsh8iWsyCPbqSzIADGYDqRHMlIb4VlZ+PpDPuL?=
 =?iso-8859-1?Q?2mAkoJaGrZW63hQfiEQMGkZ6S0UJivXbMSjozooBy9yIWLXjsxeNyPBAQ+?=
 =?iso-8859-1?Q?0dNTPpQtrJ25sxhsabUpcs1eo2ZDyOTNMTA02fXsx9VUbO4my92Un//es7?=
 =?iso-8859-1?Q?8dnAyDVAybshbcOrwQQDu5jjDvze48hYylyxJJ6EOsgykNvIrkPt3kiTNY?=
 =?iso-8859-1?Q?3fySI8foW3vHZ8pv46gFQ9fwQn2jGSQ7f/HjrHrQ7d9kVRV2lP9owrA+xG?=
 =?iso-8859-1?Q?WySwjthiIOXzQ/iJO3ApGW9YBT5jvQwuIyMfeyR2yvhQ9fEaUZYf/GWab1?=
 =?iso-8859-1?Q?FsWvdcJbZdsOc5snx6Ura7U1PD3w/Yuy0pCpFkQEemHAfpRKvPTbsj0Iba?=
 =?iso-8859-1?Q?Li4tA2//JMv8x+8RWZiqZq90/5/cwBdZuRCgKx1UMGe3WGgQdnOe8I5x8u?=
 =?iso-8859-1?Q?nXPTJnQLIWM5N2bZPly5F0DydNZzTiaotPGCrTiZ5PCkazHRiyaFwKLbil?=
 =?iso-8859-1?Q?b4Mkdv/sPumZ/Y1nGJ0Yp9Y0l/ZzgwcN7V+cz66pLuBTdkUxSyKig5kLIi?=
 =?iso-8859-1?Q?rSUP2Fi3OTeKz6w2jdlBfvLiFdTZzRN5nVvNLdkHlGz5lM4KEWWfxYVbiH?=
 =?iso-8859-1?Q?xZlx5eHK9qmsVHI9RGPzUx6FaG5wSbPRe66SrPY0Qt13Mfs97qF55HDM2G?=
 =?iso-8859-1?Q?v/UPjdTQYS45oDG8tifFe8ZBrDdMe2ro2jdIC9tXvYmfEh1vG1uskvrHJn?=
 =?iso-8859-1?Q?heeXlnPKsEYeOBfzHnEGMY1mWKgb+9KUWxpAW6d57763o325ha1P9i38oq?=
 =?iso-8859-1?Q?CWGKLxUHx/VjY1r9O7/N5LXeWWuVafvqM6NMx2Otnm0/xYWU0fsbkWaocf?=
 =?iso-8859-1?Q?CMCMReeMS2c8HaTM/0Ql8wY5lHbYGtJocbcF4PukGBZlg3+0WyVOOsVD07?=
 =?iso-8859-1?Q?dS1sulHxjfrc9mEUSZGjgX6Xnbg72ZOXKSFj/eWrHs+HWr0WZrKJq8wS7N?=
 =?iso-8859-1?Q?erbkkUc6k3TGBb4nQ18pbrcXgG5jV32yfLrFJTERRKhKBiGryZpZGEG+cN?=
 =?iso-8859-1?Q?WsQowbosNsb5AgOP?=
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
X-OriginatorOrg: sct-15-20-9412-4-msonline-outlook-7fd9e.templateTenant
X-MS-Exchange-CrossTenant-AuthAs: Internal
X-MS-Exchange-CrossTenant-AuthSource: DS4PR04MB9846.namprd04.prod.outlook.com
X-MS-Exchange-CrossTenant-RMS-PersistedConsumerOrg: 00000000-0000-0000-0000-000000000000
X-MS-Exchange-CrossTenant-Network-Message-Id: 1615598e-6e96-4eea-5f08-08df24a5b77f
X-MS-Exchange-CrossTenant-originalarrivaltime: 07 Oct 2026 19:03:47.6247
 (UTC)
X-MS-Exchange-CrossTenant-fromentityheader: Hosted
X-MS-Exchange-CrossTenant-id: 84df9e7f-e9f6-40af-b435-aaaaaaaaaaaa
X-MS-Exchange-CrossTenant-rms-persistedconsumerorg: 00000000-0000-0000-0000-000000000000
X-MS-Exchange-Transport-CrossTenantHeadersStamped: PH0PR04MB9905

Thanks for the quick patch. The description matches what I saw on=0A=
our server.=0A=
=0A=
I tested it on the kernel where I found the problem: Ubuntu=0A=
7.0.0-38 (7.0.14) built with this patch only, 64 nfsd threads,=0A=
vfs_cache_pressure at the default of 100, and the same parallel tree=0A=
walk over about 43 million files and 5.5 million directories.=0A=
=0A=
Before the patch, unreclaimable slab grew by about 90 MB per second=0A=
and reached the 8 GB limit of my test script. With the patch it=0A=
peaked at 1.5 GB in the first two minutes, came down to 0.6 GB while=0A=
all 64 threads were still busy, and stayed flat until the walk ended.=0A=
Open files went back to the idle count once the walk finished.=0A=
=0A=
=0A=
One question about the stable backport. The Fixes: tag goes back to=0A=
3.10, so stable may pick this up for 5.15 and 6.1. As far as I=0A=
remember, __fput_sync() on those kernels had a BUG_ON for callers=0A=
that are not kernel threads, and that was removed around 6.6.=0A=
get_name() can also be reached from open_by_handle_at() in process=0A=
context. Could you check whether the older stable kernels need a=0A=
different fix, or a guard on current->flags & PF_KTHREAD?=0A=
=0A=
=0A=
Danny Pidutti=0A=
=0A=
=0A=
=0A=
=0A=
________________________________________=0A=
From: Chuck Lever <cel@kernel.org>=0A=
Sent: Wednesday, October 7, 2026 12:46 PM=0A=
To: Daniel Pidutti <Danny@lightningiq.io>; Christian Brauner <brauner@kerne=
l.org>; Al Viro <viro@zeniv.linux.org.uk>; Amir Goldstein <amir73il@gmail.c=
om>=0A=
Cc: linux-fsdevel@vger.kernel.org <linux-fsdevel@vger.kernel.org>; linux-nf=
s@vger.kernel.org <linux-nfs@vger.kernel.org>; Danny Pidutti <danny_pidutti=
@hotmail.com>=0A=
Subject: [PATCH] exportfs: Release the get_name() directory file synchronou=
sly=0A=
=0A=
=0A=
get_name() opens the parent directory with dentry_open() and=0A=
releases it with fput(). From a kernel thread, fput() defers the=0A=
final __fput() to the delayed_fput work item. NFSD threads are=0A=
kernel threads, and NFSD reaches get_name() through=0A=
exportfs_decode_fh() whenever a file handle's dentry is not=0A=
connected to the root.=0A=
=0A=
On a filesystem with more directories than the dcache retains,=0A=
nearly every READDIRPLUS needs a reconnect. The deferred releases=0A=
arrive faster than the work item retires them, and each pending=0A=
file pins the directory's readdir state. On ext4 that state is the=0A=
htree fname cache for the last leaf block read. A 64-thread NFSv3=0A=
server under a parallel tree walk showed unreclaimable slab growing=0A=
by about 90 MB per second, and the same workload on a 5.15 kernel=0A=
ended in a global OOM.=0A=
=0A=
Commit 5ff318f645eb ("nfsd: use __fput_sync() to avoid delayed=0A=
closing of files.") stopped NFSD's own closes from feeding the=0A=
delayed_fput queue but did not cover the exportfs reconnect path.=0A=
=0A=
Release the file with __fput_sync(). get_name() opened the file=0A=
itself, read-only, on a directory, so __fput() involves nothing=0A=
that could wait on the caller.=0A=
=0A=
Fixes: 4a9d4b024a31 ("switch fput to task_work_add")=0A=
Reported-by: Danny Pidutti <danny_pidutti@hotmail.com>=0A=
Closes: https://lore.kernel.org/linux-fsdevel/DS4PR04MB9846BA3C16BC5ACED8B5=
89228D952@DS4PR04MB9846.namprd04.prod.outlook.com/=0A=
Signed-off-by: Chuck Lever <cel@kernel.org>=0A=
---=0A=
fs/exportfs/expfs.c | 6 +++++-=0A=
1 file changed, 5 insertions(+), 1 deletion(-)=0A=
=0A=
Mail from kernel.org to hotmail.com was rejected. kernel.org appears=0A=
to be on some deny-list. Reposting.=0A=
=0A=
=0A=
diff --git a/fs/exportfs/expfs.c b/fs/exportfs/expfs.c=0A=
index eafd99507afe..b5768f94fbb5 100644=0A=
--- a/fs/exportfs/expfs.c=0A=
+++ b/fs/exportfs/expfs.c=0A=
@@ -336,7 +336,11 @@ static int get_name(const struct path *path, char *nam=
e, struct dentry *child)=0A=
}=0A=
=0A=
out_close:=0A=
- fput(file);=0A=
+ /*=0A=
+ * @file is the read-only directory opened above, so __fput()=0A=
+ * cannot block on anything the caller holds.=0A=
+ */=0A=
+ __fput_sync(file);=0A=
out:=0A=
return error;=0A=
}=0A=
--=0A=
2.55.0=0A=
=0A=
=0A=
Disclaimer=0A=
The information contained in this communication from the sender is confiden=
tial. It is intended solely for use by the recipient and others authorized =
to receive it. If you are not the recipient, you are hereby notified that a=
ny disclosure, copying, distribution or taking action in relation of the co=
ntents of this information is strictly prohibited and may be unlawful.=0A=
=0A=
This email has been scanned for viruses and malware, and may have been auto=
matically archived by Mimecast, a leader in email security and cyber resili=
ence. Mimecast integrates email defenses with brand protection, security aw=
areness training, web security, compliance and other essential capabilities=
. Mimecast helps protect large and small organizations from malicious activ=
ity, human error and technology failure; and to lead the movement toward bu=
ilding a more resilient world. To find out more, visit our website.=

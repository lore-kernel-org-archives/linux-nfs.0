Return-Path: <SRS0=azWf=RW=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,
	SIGNED_OFF_BY,SPF_PASS,URIBL_BLOCKED autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id A8D9BC43381
	for <linux-nfs@archiver.kernel.org>; Tue, 19 Mar 2019 02:40:34 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 52CF32085A
	for <linux-nfs@archiver.kernel.org>; Tue, 19 Mar 2019 02:40:34 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=hammerspace.com header.i=@hammerspace.com header.b="Oan9gD3P"
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1727030AbfCSCkd (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Mon, 18 Mar 2019 22:40:33 -0400
Received: from mail-eopbgr810111.outbound.protection.outlook.com ([40.107.81.111]:16992
        "EHLO NAM01-BY2-obe.outbound.protection.outlook.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1726915AbfCSCkd (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Mon, 18 Mar 2019 22:40:33 -0400
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=hammerspace.com;
 s=selector1;
 h=From:Date:Subject:Message-ID:Content-Type:MIME-Version:X-MS-Exchange-SenderADCheck;
 bh=1FDsO+yAwy3MVHmfhxZR/Eh/30K0uJnZHBhnPVTOyj4=;
 b=Oan9gD3Pqh6C1uDg2xsrx2Akc1OMAijYNHJTI5vqItH63yc3QQYP7/vh23JR3+UWgyNtTrVGhdps2oodm42br28+MJ5x34tFGT4R3yYdviJE+rZjydaIW49G3MpR8avWOv0nsFK0AaAnzMvSVIGLpvEAMdXPrubtS+x6SvrpBVU=
Received: from SN6PR13MB2494.namprd13.prod.outlook.com (52.135.95.148) by
 SN6PR13MB2575.namprd13.prod.outlook.com (52.135.96.23) with Microsoft SMTP
 Server (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384) id
 15.20.1709.9; Tue, 19 Mar 2019 02:40:27 +0000
Received: from SN6PR13MB2494.namprd13.prod.outlook.com
 ([fe80::d1d6:9683:8c9b:3dcb]) by SN6PR13MB2494.namprd13.prod.outlook.com
 ([fe80::d1d6:9683:8c9b:3dcb%3]) with mapi id 15.20.1730.003; Tue, 19 Mar 2019
 02:40:27 +0000
From:   Trond Myklebust <trondmy@hammerspace.com>
To:     "anna.schumaker@netapp.com" <anna.schumaker@netapp.com>,
        "neilb@suse.com" <neilb@suse.com>
CC:     "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>,
        "chuck.lever@oracle.com" <chuck.lever@oracle.com>
Subject: Re: [PATCH] NFS: fix mount/umount race in nlmclnt.
Thread-Topic: [PATCH] NFS: fix mount/umount race in nlmclnt.
Thread-Index: AQHU3etj5JNP1oJmLUSrOoBVDjduUaYSPlYA
Date:   Tue, 19 Mar 2019 02:40:27 +0000
Message-ID: <4aaf0c67c164bc4bf5d13857774317e77a393e0f.camel@hammerspace.com>
References: <877ecv8zzf.fsf@notabene.neil.brown.name>
In-Reply-To: <877ecv8zzf.fsf@notabene.neil.brown.name>
Accept-Language: en-US, en-GB
Content-Language: en-US
X-MS-Has-Attach: yes
X-MS-TNEF-Correlator: 
authentication-results: spf=none (sender IP is )
 smtp.mailfrom=trondmy@hammerspace.com; 
x-originating-ip: [68.40.189.247]
x-ms-publictraffictype: Email
x-ms-office365-filtering-correlation-id: 6bcd0f85-c500-4849-a424-08d6ac143ee7
x-microsoft-antispam: BCL:0;PCL:0;RULEID:(2390118)(7020095)(4652040)(8989299)(4534185)(4627221)(201703031133081)(201702281549075)(8990200)(5600127)(711020)(4605104)(2017052603328)(7153060)(49563074)(7193020);SRVR:SN6PR13MB2575;
x-ms-traffictypediagnostic: SN6PR13MB2575:
x-microsoft-antispam-prvs: <SN6PR13MB2575205589478355313D9884B8400@SN6PR13MB2575.namprd13.prod.outlook.com>
x-forefront-prvs: 0981815F2F
x-forefront-antispam-report: SFV:NSPM;SFS:(10019020)(346002)(376002)(366004)(136003)(189003)(199004)(508600001)(36756003)(25786009)(66066001)(105586002)(6486002)(7736002)(102836004)(5660300002)(26005)(6512007)(6436002)(186003)(118296001)(106356001)(6506007)(14454004)(2906002)(86362001)(68736007)(4326008)(229853002)(8676002)(446003)(81166006)(99936001)(3846002)(53936002)(486006)(2616005)(110136005)(6246003)(71200400001)(97736004)(71190400001)(6116002)(76176011)(81156014)(54906003)(99286004)(2501003)(256004)(14444005)(305945005)(476003)(8936002)(11346002);DIR:OUT;SFP:1102;SCL:1;SRVR:SN6PR13MB2575;H:SN6PR13MB2494.namprd13.prod.outlook.com;FPR:;SPF:None;LANG:en;PTR:InfoNoRecords;MX:1;A:1;
received-spf: None (protection.outlook.com: hammerspace.com does not designate
 permitted sender hosts)
x-ms-exchange-senderadcheck: 1
x-microsoft-antispam-message-info: o7mHURPmApziBY+yfh9LRZ1KFaCjgeEFPbAX1xQVo8FiCmI9vN+OztETY9g8g0zSKfbPzGW3/jy4SGotFjwK6rcQyhbAzeaW/vmfT1NBtozZmB7IWGeFVuSWzgkFS5aEIqMllNm2XEPun4qgHVKFNN6xB3qRZgSd1OLznNGBvu+utY7czNuRJX1pNYpcdNx1qRV2nsmDEd3HyWJjxrk4j0EWcO0f8PLavWTGKAunaAGku6jBo2jNKLMxKK23Fp+zGyvUySA6wEbh7fqzk5qLt/WaMtN91RR4rw+DBXYzz/yvHs1HgZEaqX/XPHI2gIE2r4NLEc4uq1EtG5NrtrkS+VepL/8UrrFzFg9bIHXlTF2Hqol9ioZGm38YwodQzcNO5tMx7Ok87WF6ECQlpRdPi9zc924/hkoIlYUiXgJ0iL0=
Content-Type: multipart/signed; micalg="pgp-sha256";
        protocol="application/pgp-signature"; boundary="=-7BD6GcfyGoZhUBPWjsHX"
MIME-Version: 1.0
X-OriginatorOrg: hammerspace.com
X-MS-Exchange-CrossTenant-Network-Message-Id: 6bcd0f85-c500-4849-a424-08d6ac143ee7
X-MS-Exchange-CrossTenant-originalarrivaltime: 19 Mar 2019 02:40:27.2364
 (UTC)
X-MS-Exchange-CrossTenant-fromentityheader: Hosted
X-MS-Exchange-CrossTenant-id: 0d4fed5c-3a70-46fe-9430-ece41741f59e
X-MS-Exchange-CrossTenant-mailboxtype: HOSTED
X-MS-Exchange-Transport-CrossTenantHeadersStamped: SN6PR13MB2575
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

--=-7BD6GcfyGoZhUBPWjsHX
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Tue, 2019-03-19 at 11:33 +1100, NeilBrown wrote:
> If the last NFSv3 unmount from a given host races with a mount from
> the
> same host, we can destroy an nlm_host that is still in use.
>=20
> Specifically nlmclnt_lookup_host() can increment h_count on
> an nlm_host that nlmclnt_release_host() has just successfully called
> refcount_dec_and_test() on.
> Once nlmclnt_lookup_host() drops the mutex, nlm_destroy_host_lock()
> will be called to destroy the nlmclnt which is now in use again.
>=20
> The cause of the problem is that the dec_and_test happens outside the
> locked region.  This is easily fixed by using
> refcount_dec_and_mutex_lock().
>=20
> Fixes: 8ea6ecc8b075 ("lockd: Create client-side nlm_host cache")
> Cc: stable@vger.kernel.org (v2.6.38+)
> Signed-off-by: NeilBrown <neilb@suse.com>
> ---
>  fs/lockd/host.c | 3 +--
>  1 file changed, 1 insertion(+), 2 deletions(-)
>=20
> diff --git a/fs/lockd/host.c b/fs/lockd/host.c
> index 93fb7cf0b92b..f0b5c987d6ae 100644
> --- a/fs/lockd/host.c
> +++ b/fs/lockd/host.c
> @@ -290,12 +290,11 @@ void nlmclnt_release_host(struct nlm_host
> *host)
> =20
>  	WARN_ON_ONCE(host->h_server);
> =20
> -	if (refcount_dec_and_test(&host->h_count)) {
> +	if (refcount_dec_and_mutex_lock(&host->h_count,
> &nlm_host_mutex)) {
>  		WARN_ON_ONCE(!list_empty(&host->h_lockowners));
>  		WARN_ON_ONCE(!list_empty(&host->h_granted));
>  		WARN_ON_ONCE(!list_empty(&host->h_reclaim));
> =20
> -		mutex_lock(&nlm_host_mutex);
>  		nlm_destroy_host_locked(host);
>  		mutex_unlock(&nlm_host_mutex);
>  	}

Thanks Neil! Applying to linux-next.

--=20
Trond Myklebust
Linux NFS client maintainer, Hammerspace
trond.myklebust@hammerspace.com



--=-7BD6GcfyGoZhUBPWjsHX
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part
Content-Transfer-Encoding: 7bit

-----BEGIN PGP SIGNATURE-----

iQIzBAABCAAdFiEESQctxSBg8JpV8KqEZwvnipYKAPIFAlyQVpIACgkQZwvnipYK
APKLoBAAugy0YWVE5uNO+3JPypn/9x5D/c0XTusCf9wVIouqTZSI8/NtmxX2Bs7F
uOztFXBvgfBtaGcvyr3AM2M2dqMiJSiP4eZ4papRYLu01idIkb1FaePJOO8P5j8o
rAzbT5xcmceLW8mktICQnzfZUGKHZN4YGuPYX6D9gXdsgM196ih3zx3USTwj/tCW
b3cF0ufZ/0JN2tSTwsw1kcC26VFW2vEz+UbO82/WsfJ/075CJKX3p1Kw0wh+99LE
7f1Y6dQcdDQl503jlUg1jsgax2zRDTnk6ZHVNdCiN7pyNyPaDiEFRRi5XrGebCTQ
oXtCaMyydG7bmcjRMithKNATw062qrriE4/4/D8upoVj3Qex/UydNSVALjFgnCVq
Y2yJ3iJda96ehI66wCAZ4/igbPoFTVNKIdFsyiai2esMN8jGAFiiDF0VHVk4uM2R
CHSwGyu3tRn6gpuSfJNARjQqcCBf5dCa8Jkz75mu3V7T+zm5+a12wqJ1mLrROTZd
/zP6EnMA/aLkYfCNFJyFZwnT+iM34AAfYMjELttSrgWmQEI6nHJFxTww0ucP+goK
okaat/id1lyycSoZv+HMc2R7tGH2uvgktNEBmBK2KctYEfc6IM2GQX54qQ8Hqbz9
8zt/aaVsfTQqmQztfoDeY0BZVc+QiUj2P1sAPab0/aX4VFiNnPk=
=9Zr7
-----END PGP SIGNATURE-----

--=-7BD6GcfyGoZhUBPWjsHX--

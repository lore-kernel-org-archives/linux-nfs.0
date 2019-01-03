Return-Path: <SRS0=enTr=PL=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS,
	URIBL_BLOCKED autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 4A1B4C43387
	for <linux-nfs@archiver.kernel.org>; Thu,  3 Jan 2019 06:10:06 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id D62132073D
	for <linux-nfs@archiver.kernel.org>; Thu,  3 Jan 2019 06:10:05 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=hammerspace.com header.i=@hammerspace.com header.b="CMBg0ELF"
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1726885AbfACGKF (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Thu, 3 Jan 2019 01:10:05 -0500
Received: from mail-eopbgr810090.outbound.protection.outlook.com ([40.107.81.90]:2710
        "EHLO NAM01-BY2-obe.outbound.protection.outlook.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1726790AbfACGKE (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Thu, 3 Jan 2019 01:10:04 -0500
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=hammerspace.com;
 s=selector1;
 h=From:Date:Subject:Message-ID:Content-Type:MIME-Version:X-MS-Exchange-SenderADCheck;
 bh=kw0GNYTm28dTQYBBhmLgYSNZxAsfRuvyLi05TBzaVTo=;
 b=CMBg0ELFg0epDfhK4sm2NMpj3ghil4Vnq6MHvUbn1DnzQjojUxx1ViffIphQp9p71qw7BLi7p0eYNI+xEtgLm5+PH6Kln7lZGuZlmGJUuBBU5/DlkRS+cJPvllMomKVEIW4ahqE2absRlkQ9ozH0E4FyAqFwTy8X6JYsaBdV/YM=
Received: from SN6PR13MB2494.namprd13.prod.outlook.com (52.135.95.148) by
 SN6PR13MB2416.namprd13.prod.outlook.com (52.135.94.160) with Microsoft SMTP
 Server (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384) id
 15.20.1495.4; Thu, 3 Jan 2019 06:09:59 +0000
Received: from SN6PR13MB2494.namprd13.prod.outlook.com
 ([fe80::7dd2:1e4f:2de1:eb27]) by SN6PR13MB2494.namprd13.prod.outlook.com
 ([fe80::7dd2:1e4f:2de1:eb27%3]) with mapi id 15.20.1495.005; Thu, 3 Jan 2019
 06:09:59 +0000
From:   Trond Myklebust <trondmy@hammerspace.com>
To:     "torvalds@linux-foundation.org" <torvalds@linux-foundation.org>,
        "Anna.Schumaker@netapp.com" <Anna.Schumaker@netapp.com>,
        "neilb@suse.com" <neilb@suse.com>
CC:     "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Subject: Re: [GIT PULL] Please pull NFS client updates for 4.21
Thread-Topic: [GIT PULL] Please pull NFS client updates for 4.21
Thread-Index: AQHUouxyssLuTL6Yhkqph5BlSbCk6aWctiQAgABEoQCAABU9gA==
Date:   Thu, 3 Jan 2019 06:09:58 +0000
Message-ID: <55e9d0eb47662f2d6c308eba8b9a84fbba978ac8.camel@hammerspace.com>
References: <02d3ecd37f9390e7b8a7be8ec0e1cafb7fdbed26.camel@netapp.com>
         <CAHk-=whZkaZn1UQLad6v9vmfx8+BB3m8cvT0wcKdtg=k=FDbGw@mail.gmail.com>
         <87bm4yl4th.fsf@notabene.neil.brown.name>
In-Reply-To: <87bm4yl4th.fsf@notabene.neil.brown.name>
Accept-Language: en-US, en-GB
Content-Language: en-US
X-MS-Has-Attach: yes
X-MS-TNEF-Correlator: 
authentication-results: spf=none (sender IP is )
 smtp.mailfrom=trondmy@hammerspace.com; 
x-originating-ip: [68.40.189.247]
x-ms-publictraffictype: Email
x-microsoft-exchange-diagnostics: 1;SN6PR13MB2416;6:qaY8lcG6Pge41u/ths9XgGfzqHID/atgMjN5sJL5UwyegOvD9UyrHCjNN5H/I0YQqxb+x3F0ZI/mg1hcsedOmmNVDac/fmedu64SEyMFVSmEKwsYAAgk6L70MRXp1x9i2ou+OiZv+iFSffNQVYJ9VXFuHpLiA5bR6fSzYx8WfEejol+u36HrcpPxcGa+1/Llx7Y/xkuRy0Hd8bt0h8cNdVuLwEBNKEAyMdgCoA6GORH8ZncC9D2q73moQ3RvYOOSS+ZoSmxMGP/7XOLn6Ve+uwLsGjBLcsmNDqH9KOk1/52Jcb9sP/6Q7rHI0jPY4sHnfaLeFMPGqZuOqLOhIl6O9Mu+81RLTeov9cwmdwVBUt0eUSZoKG/Pt/hRj6XRNuOGJ6TqeugBOKYcwOUZ4b09/9A/xCghNuCbsaM5KrEvd757A9cjnZ7RaYCJ9Vk/GShf/Ru+gssJxtMsyR3DLoZUdw==;5:k2zsodN8AKaHhXmL/43IR3iSRVZ9AHsXDYPyJbC5XOIoAjerJaMBL3ghylscXC6dhfIFoPFAFpRlomB10uDY/YBnx17DOYVuZOvDcox0O5r6OEM4ouL/MlSu6GWqJxLH1ioL2wy/1D2Z146HoG1t8X7BtAjsvk7UrTqIbx1wSMaHSsA3zXBG07pgxiOtk+NSsUI3JsEFZbom8jv4qKZQJw==;7:DccvFS+33a+v5baIP5Zfa5oEJDbI4ugpjjaViQNlMU63M15X9FZuCsAl338ZH7gT+aWT4wANeoX4D5QdRPlNFD3OrcvsCKdFZ2ZUntVYaxtVfz4bd30CD0uhaPEtTg87F5ninQo2QfnRT6zTrgU8UQ==
x-ms-exchange-antispam-srfa-diagnostics: SOS;
x-ms-office365-filtering-correlation-id: b859f849-c657-459b-fcc5-08d671421736
x-microsoft-antispam: BCL:0;PCL:0;RULEID:(2390118)(7020095)(4652040)(8989299)(4534185)(4627221)(201703031133081)(201702281549075)(8990200)(5600109)(711020)(2017052603328)(7153060)(49563074)(7193020);SRVR:SN6PR13MB2416;
x-ms-traffictypediagnostic: SN6PR13MB2416:
x-microsoft-antispam-prvs: <SN6PR13MB24160D4E48386EE8A80D2454B88D0@SN6PR13MB2416.namprd13.prod.outlook.com>
x-exchange-antispam-report-cfa-test: BCL:0;PCL:0;RULEID:(3230021)(908002)(999002)(5005026)(102415395)(6040522)(8220060)(2401047)(8121501046)(93006095)(93001095)(3002001)(3231475)(944501520)(4983020)(52105112)(10201501046)(6041310)(20161123558120)(20161123564045)(20161123562045)(201703131423095)(201702281528075)(20161123555045)(201703061421075)(201703061406153)(20161123560045)(201708071742011)(7699051)(76991095);SRVR:SN6PR13MB2416;BCL:0;PCL:0;RULEID:;SRVR:SN6PR13MB2416;
x-forefront-prvs: 0906E83A25
x-forefront-antispam-report: SFV:NSPM;SFS:(10019020)(136003)(346002)(396003)(366004)(376002)(39830400003)(199004)(189003)(51444003)(36756003)(106356001)(105586002)(2906002)(2201001)(14444005)(256004)(81156014)(3846002)(7736002)(8676002)(71200400001)(81166006)(66066001)(2501003)(86362001)(6116002)(71190400001)(8936002)(305945005)(6512007)(11346002)(99936001)(186003)(26005)(486006)(2616005)(5660300001)(25786009)(118296001)(68736007)(476003)(53546011)(54906003)(53936002)(99286004)(4326008)(229853002)(6506007)(102836004)(316002)(76176011)(6436002)(6486002)(6246003)(97736004)(446003)(110136005)(14454004)(478600001);DIR:OUT;SFP:1102;SCL:1;SRVR:SN6PR13MB2416;H:SN6PR13MB2494.namprd13.prod.outlook.com;FPR:;SPF:None;LANG:en;PTR:InfoNoRecords;A:1;MX:1;
received-spf: None (protection.outlook.com: hammerspace.com does not designate
 permitted sender hosts)
x-ms-exchange-senderadcheck: 1
x-microsoft-antispam-message-info: 6bHkHJQS217fTGR4SAgMPVw4xicS8sTFgBt8bEisy/CaeI05g9R8BdwXwmoORi6RSF94YT7sQBpt7HFrm+A6ZTQfl7kucXM0Em/zY+CIFrVNPyC4b/6fvUHneWi9ML1WoaC+0/ghFq/fapJDTN/3yUZSpzOqOfucbHDFXeTrOymBYskegusf/jrmnxZl8svOvjf2K1vJB9FzJvhrx5ChqtzZ6XWWKz7Rx6Vh7jZzGonfdinKtR5hGUxT5g6Wsr/2qoy7g7imDYd/0FfPvn4V7vOguWFeElP5Wn4lZI7kLbMs4H8kE32+r/RL0ExL8vBN
spamdiagnosticoutput: 1:99
spamdiagnosticmetadata: NSPM
Content-Type: multipart/signed; micalg="pgp-sha256";
        protocol="application/pgp-signature"; boundary="=-h8TepRE+u8G8DM8XQDRF"
MIME-Version: 1.0
X-OriginatorOrg: hammerspace.com
X-MS-Exchange-CrossTenant-Network-Message-Id: b859f849-c657-459b-fcc5-08d671421736
X-MS-Exchange-CrossTenant-originalarrivaltime: 03 Jan 2019 06:09:58.9513
 (UTC)
X-MS-Exchange-CrossTenant-fromentityheader: Hosted
X-MS-Exchange-CrossTenant-id: 0d4fed5c-3a70-46fe-9430-ece41741f59e
X-MS-Exchange-Transport-CrossTenantHeadersStamped: SN6PR13MB2416
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

--=-h8TepRE+u8G8DM8XQDRF
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Thu, 2019-01-03 at 15:53 +1100, NeilBrown wrote:
> On Wed, Jan 02 2019, Linus Torvalds wrote:
>=20
> > On Wed, Jan 2, 2019 at 2:42 PM Schumaker, Anna
> > <Anna.Schumaker@netapp.com> wrote:
> > > We also were unable to track down a maintainer for Neil Brown's
> > > changes to
> > > the generic cred code that are prerequisites to his RPC cred
> > > cleanup patches.
> > > We've been asking around for several months without any response,
> > > so
> > > hopefully it's okay to include those patches in this pull
> > > request.
> >=20
> > Looks ok to me, although I wonder what the semantics of
> > cred_fscmp()
> > are across namespaces?
> >=20
> > IOW, it seems potentially a bit suspicious to do cred_fscmp() if
> > the
> > two creds have different namnespaces? Hmm?
> >=20
> > Is there some reason that can't happen, or some reason it doesn't
> > matter?
> >=20
> >                   Linus
>=20
> Interesting question.
> For the current use in NFS, it is consistent with existing practice
> to
> ignore the name space.
> NFS file accesses (when using the normal uid-based access checks)
> always
> use the manifest uid of the process - the one returned by getuid()
> (or
> more accurately, getfsuid()).
> Maybe this is wrong?  Maybe we should always use from_kuid() or
> whatever
> to get the uid/gid to send over the wire?
>=20
> Anna/Trond: do you have thoughts on this?  If a process in a user
> namespace accesses a file over NFS, should the UID presented to the
> server be the one in that name-space, or the one you get by mapping
> to
> the global name-space?
> Or should we map to the namespace that was active when the filesystem
> was mounted?
>=20
> I don't think cred_fscmp() should do any of this mapping, but maybe
> it
> should treat creds from different namespaces as different - as a
> precaution.
>=20
> Thanks,
> NeilBrown

The values being compared are in cred_fscmp() are all of type kuid_t or
kgid_t so that means they have already been mapped from the user
namespace into the kernel uid/gid space.
When we put those kuid/kgid values onto the wire, we currently always
use the init namespace rather than the user namespace of the mount
process.

When using strong authentication (i.e. krb5) then none of this matters,
since the server performs its own mapping of the presented RPCSEC_GSS
session into a credential. That mapping is independent of the user
namespace on the client, it just depends on which krb5 principal the
process used to identify itself.

The problem case is limited to when we're using the weak AUTH_UNIX
authentication, since the server is then implicitly trusting the client
to protect against identity spoofing. This is particularly true if the
NFS server is being accessed through NAT, in which case it has very
limited possibilities for discriminating between containers on the same
client using the export table because they will all originate from the
same source IP address. I think that for these cases, using the init
namespace is the right thing to do for the same reason we use it with
local filesystems: if we try to use a different namespace then
unprivileged userspace processes might be able to manipulate the
mapping to spoof the identities of privileged users or groups, or
otherwise gain access to files to which they normally should not have
access.

Does that argument make sense?

--=20
Trond Myklebust
Linux NFS client maintainer, Hammerspace
trond.myklebust@hammerspace.com



--=-h8TepRE+u8G8DM8XQDRF
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part
Content-Transfer-Encoding: 7bit

-----BEGIN PGP SIGNATURE-----

iQIzBAABCAAdFiEESQctxSBg8JpV8KqEZwvnipYKAPIFAlwtpysACgkQZwvnipYK
APK87w//TpoS1RM7UB8nC/rUTgiRygcFJVzuK1LiWMqlbSnjoNK3d+1JxSm1veX+
HFfntccs3hM8hBMPbGA/s7ICw2e4ugJjAW4M/WBJlNuxfVB08QuAVACT3O8c/DIi
or160Kpp0aHP/VA9hRFLWVQH/BXq36KGTcBT/mlElvZjutOuGO1OlQYonWNbKn0H
iDK4t8TqTcyiG7kQMJclz4IMHQuNq1BXoi/Zx+BFrr/9E/PNoR0lrTBoKKHhQ5kH
Ekt70zxQlHKZKoirrUmPJv4aO2KAp/3EH40h4F+Av5HkQozTPna9R3FRIvc9Arpd
rMXoK5cuxHphoQ2HaUiOgex32FAI6uIYRz5+G8g50IhJRX4jeTvJ4d1O5pp1xkBc
70jrdcqd5eDhJZzKl0GxYlM0pmp+jn+1TYU7ydTy6NMzlsJsfZ9eiKp6XVBSBBFE
TFWlHlAux8no1gHqyiOFzfKzveh61ZQa3ymLXh6dof08Tua1zZDVjUn01mTHjtcw
+U2pZHP61GFLLVCkPBDHNDkZl/To1Lsm48UAHCt4cD2Yn64kXJMUqZV0STamyAKS
ChnZfUMxu0GQNrkUeVYElNDLIyKjguvHC/ZI5DnZ0cAKGQx0I4jvsTt4kK3UADC0
IE4vwojOvsn7WQxw1bka2uAdN6C77mK8sTOaue20gQrlFnWulqw=
=4g5R
-----END PGP SIGNATURE-----

--=-h8TepRE+u8G8DM8XQDRF--

Return-Path: <SRS0=1UK0=RC=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 1BB14C43381
	for <linux-nfs@archiver.kernel.org>; Wed, 27 Feb 2019 00:13:05 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id D5C2E218D0
	for <linux-nfs@archiver.kernel.org>; Wed, 27 Feb 2019 00:13:04 +0000 (UTC)
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1727998AbfB0ANE convert rfc822-to-8bit (ORCPT
        <rfc822;linux-nfs@archiver.kernel.org>);
        Tue, 26 Feb 2019 19:13:04 -0500
Received: from mail-eopbgr660073.outbound.protection.outlook.com ([40.107.66.73]:60576
        "EHLO CAN01-QB1-obe.outbound.protection.outlook.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1726801AbfB0ANE (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Tue, 26 Feb 2019 19:13:04 -0500
Received: from QB1PR01MB3537.CANPRD01.PROD.OUTLOOK.COM (52.132.89.15) by
 QB1PR01MB3908.CANPRD01.PROD.OUTLOOK.COM (52.132.85.205) with Microsoft SMTP
 Server (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384) id
 15.20.1643.15; Wed, 27 Feb 2019 00:13:01 +0000
Received: from QB1PR01MB3537.CANPRD01.PROD.OUTLOOK.COM
 ([fe80::609b:1ecd:c908:d44c]) by QB1PR01MB3537.CANPRD01.PROD.OUTLOOK.COM
 ([fe80::609b:1ecd:c908:d44c%6]) with mapi id 15.20.1643.019; Wed, 27 Feb 2019
 00:13:00 +0000
From:   Rick Macklem <rmacklem@uoguelph.ca>
To:     Trond Myklebust <trondmy@hammerspace.com>,
        "davenoveck@gmail.com" <davenoveck@gmail.com>,
        "tigran.mkrtchyan@desy.de" <tigran.mkrtchyan@desy.de>
CC:     "devel@lists.nfs-ganesha.org" <devel@lists.nfs-ganesha.org>,
        "linux-nfs-owner@vger.kernel.org" <linux-nfs-owner@vger.kernel.org>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>,
        "nfsv4@ietf.org" <nfsv4@ietf.org>
Subject: Re: [nfsv4] file size and getattr
Thread-Topic: [nfsv4] file size and getattr
Thread-Index: xB45BipLgBZpsCd+0L6G4OWR1hcJRu0o7KH9gAAKLuOAAKAAAIAAunJt
Date:   Wed, 27 Feb 2019 00:13:00 +0000
Message-ID: <QB1PR01MB3537841A7F121CFA082B778ADD7B0@QB1PR01MB3537.CANPRD01.PROD.OUTLOOK.COM>
References: <155049372736.14318.3390584694682770373.idtracker@ietfa.amsl.com>
         <CADaq8je2Ap4oAZAPOguaWctUs8dQ=Q9g=TO39EOiJW5EJSFTGg@mail.gmail.com>
         <OFE5A6CD32.4DC48078-ON882583A9.007FB4BC-882583A9.0080ACAC@notes.na.collabserv.com>
         <CADaq8jfT=nxmVPz4mDRFAaOx36uxWqKbxitqS-YH3GCOs4CsrQ@mail.gmail.com>   ,
 <741516773.7109032.1551084577150.JavaMail.zimbra@desy.de>
        ,<QB1PR01MB3537C4C84605F9C26050DDA8DD7B0@QB1PR01MB3537.CANPRD01.PROD.OUTLOOK.COM>
         <QB1PR01MB3537215D010370E139D70843DD7B0@QB1PR01MB3537.CANPRD01.PROD.OUTLOOK.COM>,<1cbdd04ce23c5012f59b6d5dcbb6b505be0675b9.camel@hammerspace.com>
In-Reply-To: <1cbdd04ce23c5012f59b6d5dcbb6b505be0675b9.camel@hammerspace.com>
Accept-Language: en-US
Content-Language: en-US
X-MS-Has-Attach: 
X-MS-TNEF-Correlator: 
x-ms-publictraffictype: Email
x-ms-office365-filtering-correlation-id: b236ef45-c432-42da-753c-08d69c4855bc
x-microsoft-antispam: BCL:0;PCL:0;RULEID:(2390118)(7020095)(4652040)(8989299)(4534185)(4627221)(201703031133081)(201702281549075)(8990200)(5600127)(711020)(4605104)(2017052603328)(7153060)(7193020);SRVR:QB1PR01MB3908;
x-ms-traffictypediagnostic: QB1PR01MB3908:
x-ms-exchange-purlcount: 1
x-microsoft-exchange-diagnostics: =?iso-8859-1?Q?1;QB1PR01MB3908;23:EWkQH1lbNze1GHiwPL/inqVQfaxofruZ+dqlamu?=
 =?iso-8859-1?Q?SQAV/uhSRSzKqrhlpwcKeBZnLpmaDcWnm+NJwBZbkVnrIYR+Z66GFBTesR?=
 =?iso-8859-1?Q?4JvJ6szCN5zTXVJ6klgo801xpqltxEzElYAq/FvcqChAoKFRyFjCMhdHD3?=
 =?iso-8859-1?Q?ZnBGIZKCP3Pswcm1mT9l6Y/uimXCkSxNrTcraCGvV+ehx39UIcUsDTyE3G?=
 =?iso-8859-1?Q?rhg3CjgeNbECy2dwGuMaomveLItnlEt8FpK9Py/qaTnfpZbdPgYPvg2KEL?=
 =?iso-8859-1?Q?d6ZXiw/IwBzNidrKah1L4aeiIzKj4Ws3F3XJmhiW3xJEa5Gnx80Vvw16et?=
 =?iso-8859-1?Q?lXNGkOqoGHAX5gcRb/+2HiMi6Wtc5moCzFHXM267V4MqnZ45vXsiP+wpCx?=
 =?iso-8859-1?Q?i/0o7cr621+hMZWtEJpmDVdQAJsYySNleQQNztrH2x/3pC79liErcTwk7d?=
 =?iso-8859-1?Q?fGfBT1AdWv9ZUErp1TsJtA+yx3+2eJe1qkL0+VQnCIOY4lTrGREb4xst+b?=
 =?iso-8859-1?Q?2PTYh7Q76I3UyM0xPct/xZMJBaLe4UXk7mulKAo6bmyfAJncfdXESGyAyL?=
 =?iso-8859-1?Q?xsUlbUqJDg2YxVKR0eWAg5m4T1BYvqhO4fBnREeN/40l64RUkVptfRnFNt?=
 =?iso-8859-1?Q?zSsbahB4d4KpjprE/OBVn7BcG+T2USHA2P2tSmjNZIBvjuHpNN+USkYPwv?=
 =?iso-8859-1?Q?80YlTkePQHwUreveomeMNAnKO8/LN/x+4AhmjTQt+/n53fOXKQs4fKRNoZ?=
 =?iso-8859-1?Q?AoAT0n7P+8ifzr1RhZLv/eHafC4UWGnYwgVzFTZfJsZf1SBFL9HizVjuA+?=
 =?iso-8859-1?Q?V7bvTRiFL05XjmfsqCpbOPt4PxSpCXGjNQrPHSG+HQb0qEoFzMF2sexE1p?=
 =?iso-8859-1?Q?kxm+7q0f/5jGo7aLsLOZN2Q2e/FT2klVvSokN4Yq1+/WXHNsCFNkLNeETs?=
 =?iso-8859-1?Q?8P5czpWQdNZjkPVOmuDVcie7qpF11sVw9pQ6q0nBFjDFoiaW/NHketc8El?=
 =?iso-8859-1?Q?HphZT8HQjgL+Gmjt37GfNSjfD0DQVoNscxsIH/jCgWk2BAjhCowZlgcAch?=
 =?iso-8859-1?Q?Li9aYfA8GXZLhi3tbuk3WrGgl0msPi6Xw2fFSLBnLbqM/nhZnW3OdSzS84?=
 =?iso-8859-1?Q?6ffWNiUugG+VXuzxTQpKb0eUL4OuKVCg7UrNQv5FWwcH5thN4PtuBbSTG3?=
 =?iso-8859-1?Q?AdMlUOvSq042m4mrW93HQrQEj6N4B9Oqv4aWpOqpra7mxaYcu3h3noJaTe?=
 =?iso-8859-1?Q?R2+HZ7LkJ2nX8SydPMKepj9E0akNQayR69hTTIVExuxCeGEQl8hxRfuR5c?=
 =?iso-8859-1?Q?SDspSk7cqyKybrByz2jbPPnx/kXlT30Xij922s967ygmg=3D=3D?=
x-microsoft-antispam-prvs: <QB1PR01MB3908ADFD8481E8A7ED22C525DD740@QB1PR01MB3908.CANPRD01.PROD.OUTLOOK.COM>
x-forefront-prvs: 0961DF5286
x-forefront-antispam-report: SFV:NSPM;SFS:(10009020)(346002)(396003)(39860400002)(376002)(136003)(366004)(199004)(189003)(54906003)(14444005)(8936002)(81166006)(81156014)(229853002)(8676002)(106356001)(256004)(105586002)(6436002)(97736004)(74482002)(446003)(476003)(11346002)(2906002)(68736007)(33656002)(46003)(486006)(2201001)(76176011)(25786009)(5660300002)(478600001)(7696005)(86362001)(93886005)(2501003)(6346003)(966005)(6246003)(6506007)(186003)(110136005)(71200400001)(71190400001)(102836004)(99286004)(74316002)(316002)(4326008)(305945005)(786003)(14454004)(6306002)(53936002)(55016002)(9686003);DIR:OUT;SFP:1101;SCL:1;SRVR:QB1PR01MB3908;H:QB1PR01MB3537.CANPRD01.PROD.OUTLOOK.COM;FPR:;SPF:None;LANG:en;PTR:InfoNoRecords;A:1;MX:1;
received-spf: None (protection.outlook.com: uoguelph.ca does not designate
 permitted sender hosts)
authentication-results: spf=none (sender IP is )
 smtp.mailfrom=rmacklem@uoguelph.ca; 
x-ms-exchange-senderadcheck: 1
x-microsoft-antispam-message-info: pgzPFx22Bp496TCxvmaS1AbxWsDwc9mt81JeyPyLtkbJCO7tPFQOSni8waG78IGQPXg2bRJ91r1vjVg3lWfZUF3GsUMQoIGrxw1/4U0z/5zxdApfZ+AgU4pQBRD/0DSDDUUQWOgCCBxrOuNVGgia5MZFK3ry+d3A8/r9/3V0BhmO9rt5mUzPeHIBYSsS7vWU3s+MfN0/cK/ZpVclX4L/mvD6Sbw5Xxi9AhSi4qPhuov71c8NguFnlM50WwbmA9L+LeDZKR3ipGGVAw6jhv3L06vL3pvPYAUM/kVgyT3aQfRN2qdCWzdEx4Ti10FQcW8hdE6BDgvcwelXlC6asWnmJy0Mwt6LMd9FFVrGkj0kRGtQHn/yjt+eTJ7r+Uem91Mi+xvZ4qWs/2h5I1amphfoTJQGS2fhFMvnBQbod42DhSE=
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: 8BIT
MIME-Version: 1.0
X-OriginatorOrg: uoguelph.ca
X-MS-Exchange-CrossTenant-Network-Message-Id: b236ef45-c432-42da-753c-08d69c4855bc
X-MS-Exchange-CrossTenant-originalarrivaltime: 27 Feb 2019 00:13:00.9086
 (UTC)
X-MS-Exchange-CrossTenant-fromentityheader: Hosted
X-MS-Exchange-CrossTenant-id: be62a12b-2cad-49a1-a5fa-85f4f3156a7d
X-MS-Exchange-CrossTenant-mailboxtype: HOSTED
X-MS-Exchange-Transport-CrossTenantHeadersStamped: QB1PR01MB3908
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

Trond Myklebust wrote:
[stuff snipped]
> Please see the Errata ID 2751 http://www.rfc-editor.org/errata/eid2751

I'll admit I hadn't seen this errata before. However, it seems to be specific to
the File Layout. For the Flexible File Layout...

When I look in RFC-8435, I cannot find anything that states that a LayoutCommit
is only required for case(s) where a Commit to the Storage Server is required.
Sec. 2.1
   Clearly states that a Commit to the Storage Server is required before the client
   does a LayoutCommit when the write(s) were not done FILE_SYNC.
   However, I do not see any indication that the LayoutCommit is not to be done
   for the case where the write(s) are done FILE_SYNC.

FF_FLAGS_NO_LAYOUTCOMMIT can be used to indicate to a client that
LayoutCommits are not required, but this does not be dependent on how
the write(s) to the Storage Server were done.

The only way a Flexible File layout Metadata server can know what the
current file size is (when a read/write layout is issued to a client) is to do a
Getattr to the Storage Server.
If a client is not required to do a LayoutCommit when the write(s) to the
Storage Server are done FILE_SYNC, then the Metadata server must do
Getattr RPCs to the Storage Server whenever it needs an up to date file size
if a read/write layout is issued to a client.

This can result in a lot of overhead that can be avoided by requiring the
LayoutCommit to be done by a client after writing to a Storage Server,
irrespective of the need for a Commit to the Storage Server.
As such, I would rather not have this errata applied to RFC-8435.

rick


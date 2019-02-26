Return-Path: <SRS0=yawm=RB=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 363B9C43381
	for <linux-nfs@archiver.kernel.org>; Tue, 26 Feb 2019 03:23:46 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id ED863217F5
	for <linux-nfs@archiver.kernel.org>; Tue, 26 Feb 2019 03:23:45 +0000 (UTC)
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1726116AbfBZDXp convert rfc822-to-8bit (ORCPT
        <rfc822;linux-nfs@archiver.kernel.org>);
        Mon, 25 Feb 2019 22:23:45 -0500
Received: from mail-eopbgr660084.outbound.protection.outlook.com ([40.107.66.84]:50640
        "EHLO CAN01-QB1-obe.outbound.protection.outlook.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1725954AbfBZDXo (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Mon, 25 Feb 2019 22:23:44 -0500
Received: from QB1PR01MB3537.CANPRD01.PROD.OUTLOOK.COM (52.132.89.15) by
 QB1PR01MB2850.CANPRD01.PROD.OUTLOOK.COM (52.132.86.78) with Microsoft SMTP
 Server (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384) id
 15.20.1643.16; Tue, 26 Feb 2019 03:23:42 +0000
Received: from QB1PR01MB3537.CANPRD01.PROD.OUTLOOK.COM
 ([fe80::609b:1ecd:c908:d44c]) by QB1PR01MB3537.CANPRD01.PROD.OUTLOOK.COM
 ([fe80::609b:1ecd:c908:d44c%6]) with mapi id 15.20.1643.019; Tue, 26 Feb 2019
 03:23:42 +0000
From:   Rick Macklem <rmacklem@uoguelph.ca>
To:     "Mkrtchyan, Tigran" <tigran.mkrtchyan@desy.de>,
        Dave Noveck <davenoveck@gmail.com>
CC:     linux-nfs-owner <linux-nfs-owner@vger.kernel.org>,
        linux-nfs <linux-nfs@vger.kernel.org>, NFSv4 <nfsv4@ietf.org>,
        Ganesha-devel <devel@lists.nfs-ganesha.org>
Subject: Re: [nfsv4] file size and getattr
Thread-Topic: [nfsv4] file size and getattr
Thread-Index: xB45BipLgBZpsCd+0L6G4OWR1hcJRu0o7KH9gAAKLuM=
Date:   Tue, 26 Feb 2019 03:23:42 +0000
Message-ID: <QB1PR01MB3537215D010370E139D70843DD7B0@QB1PR01MB3537.CANPRD01.PROD.OUTLOOK.COM>
References: <155049372736.14318.3390584694682770373.idtracker@ietfa.amsl.com>
 <CADaq8je2Ap4oAZAPOguaWctUs8dQ=Q9g=TO39EOiJW5EJSFTGg@mail.gmail.com>
 <OFE5A6CD32.4DC48078-ON882583A9.007FB4BC-882583A9.0080ACAC@notes.na.collabserv.com>
 <CADaq8jfT=nxmVPz4mDRFAaOx36uxWqKbxitqS-YH3GCOs4CsrQ@mail.gmail.com>,
 <741516773.7109032.1551084577150.JavaMail.zimbra@desy.de>,<QB1PR01MB3537C4C84605F9C26050DDA8DD7B0@QB1PR01MB3537.CANPRD01.PROD.OUTLOOK.COM>
In-Reply-To: <QB1PR01MB3537C4C84605F9C26050DDA8DD7B0@QB1PR01MB3537.CANPRD01.PROD.OUTLOOK.COM>
Accept-Language: en-US
Content-Language: en-US
X-MS-Has-Attach: 
X-MS-TNEF-Correlator: 
authentication-results: spf=none (sender IP is )
 smtp.mailfrom=rmacklem@uoguelph.ca; 
x-ms-publictraffictype: Email
x-ms-office365-filtering-correlation-id: a31fcdef-e4eb-4ad9-24a6-08d69b99cf05
x-microsoft-antispam: BCL:0;PCL:0;RULEID:(2390118)(7020095)(4652040)(8989299)(4534185)(4627221)(201703031133081)(201702281549075)(8990200)(5600127)(711020)(4605104)(2017052603328)(7153060)(7193020);SRVR:QB1PR01MB2850;
x-ms-traffictypediagnostic: QB1PR01MB2850:
x-microsoft-exchange-diagnostics: =?iso-8859-1?Q?1;QB1PR01MB2850;23:fYjVNlMpzYJuNP5sMGPKBmQmSvNNrz2lR3kS8pz?=
 =?iso-8859-1?Q?ZVua91bY7rLo/8cSUlxWXsE/Gc+EQtLu35tjO57N65/CVPUoFTfOhAgsNb?=
 =?iso-8859-1?Q?b9lqAnT3SKrr5wHpjHD43DQ56vrfFTI6u07mOezyUefOBT5Z0KM+ZqGAPW?=
 =?iso-8859-1?Q?2l8tsGFUfZV2mhWxwcFoUHLe7aPx7QFVhbZnL09Zfz1r0l4PqBBk7qjK8w?=
 =?iso-8859-1?Q?XT/G8ra6OjKakPJfsUqXD8KUhzzCL4BoynhMAgvvIPV2NRiFDQm0BFHpP8?=
 =?iso-8859-1?Q?Oj8Uv/n/Dmv1LK5ljxXYIxHMDPqNfNvQeDzdEr92w751Z2gA437z2/VZQk?=
 =?iso-8859-1?Q?ZWVC6gmrJw27GNhq2OsSVTwMx5mpY8TtJD8g57MWH/4Aft5jLEPKi8yOlk?=
 =?iso-8859-1?Q?KrjgZZI8DUL/fhLwyKkCTIf7ha27c/Tzi8PyoLU4EkSXcvl15d0DMGLFR3?=
 =?iso-8859-1?Q?WdRCDBxTWFlNizy5D17MdRrrP4u0RUdpbtzXGTh+dMIbUaePk641dLhXAY?=
 =?iso-8859-1?Q?hupKPzWBGt/ymL7GSj1ruc1lS9l5JJn/aKq87QgGi+h42YVKnCCLchpv/T?=
 =?iso-8859-1?Q?4PZXYq3FOIfDOMJ2ITAcTS9CR7Rsd1EJdWLcvnO9ncJ6Z6DkPfzxPEYo1c?=
 =?iso-8859-1?Q?AYc08usvoXSVpFZaqhWv00gMGvWhWHZpiZocV/moYYr7fvpPySp4i7AGk8?=
 =?iso-8859-1?Q?nko1nSXuTQU9UU0bGC2C90tfTyQcOX5zt5x4SmXWHOxmLJB8Lwnif85OWW?=
 =?iso-8859-1?Q?MINhGctsK8uXTVMs7qlNPTaoVTtPIN4gX5VCqtx8xKdhnapD8OdlUMG8LY?=
 =?iso-8859-1?Q?vTrl+U9lvcAR+yb1SyCUCJGEQfsBRYk32kQQTYFSPE79nb4BugI++6f6rW?=
 =?iso-8859-1?Q?RliIpio9JwFWal5NEPC8ngL36rtC2oom1daHlpCgPbyVaDhwgFnxY6gUOY?=
 =?iso-8859-1?Q?EUL27xwyMAdSque/uLtZl8/3FDpQi6vW064i9Jn6WC0f1BtCQ+DCvKRDXq?=
 =?iso-8859-1?Q?O/sU3uC7I25qNpO+nCkC03EISPg0kHdwzEscpQaqCNOhCkJTSkeSLDxZWn?=
 =?iso-8859-1?Q?uu2mbHA6c65WCEVGeRuJx7SboYQ7bhhq93GqBRJnq9YSllJP7I2Jbphj/K?=
 =?iso-8859-1?Q?ZjYPGR/EgGWE58vKxN9MQZP9zpRaQaK6cY01SDPyeVVjcK5ZdHLpadAVYv?=
 =?iso-8859-1?Q?R0T0CjNBB2gQULrlYVJFBbsv5ARXJO5PGhwUOtOEVo8nqbfeQPdRNhs1qC?=
 =?iso-8859-1?Q?VCr3fgmQWQicFhfAjvr1jv/bu9Ja1f+UrYn3IBKPRLlyzZwx/OMXTxK8uf?=
 =?iso-8859-1?Q?mE=3D?=
x-microsoft-antispam-prvs: <QB1PR01MB285004C11138A652FD8DAFF7DD7B0@QB1PR01MB2850.CANPRD01.PROD.OUTLOOK.COM>
x-forefront-prvs: 096029FF66
x-forefront-antispam-report: SFV:NSPM;SFS:(10009020)(396003)(376002)(39860400002)(366004)(136003)(346002)(189003)(199004)(53936002)(229853002)(33656002)(99286004)(55016002)(14444005)(97736004)(93156006)(6436002)(106356001)(9686003)(256004)(93886005)(86362001)(305945005)(74316002)(105586002)(786003)(316002)(8676002)(110136005)(8936002)(81166006)(71190400001)(2940100002)(74482002)(102836004)(486006)(2906002)(478600001)(11346002)(446003)(4326008)(68736007)(25786009)(476003)(46003)(6246003)(76176011)(7696005)(5660300002)(71200400001)(186003)(54906003)(81156014)(14454004)(6506007);DIR:OUT;SFP:1101;SCL:1;SRVR:QB1PR01MB2850;H:QB1PR01MB3537.CANPRD01.PROD.OUTLOOK.COM;FPR:;SPF:None;LANG:en;PTR:InfoNoRecords;MX:1;A:1;
received-spf: None (protection.outlook.com: uoguelph.ca does not designate
 permitted sender hosts)
x-ms-exchange-senderadcheck: 1
x-microsoft-antispam-message-info: eDzcIE4dY5BUa6KwbmzLHR9V49jfn7FBP7VZsvMWFzSe59Zd7mBgSeu0YgcvC6Pd8sFrZ57YXf+oDL3CtBD3CzvCn4NDrxKeBA6uDomAywVAKK5WttAkIE30q70OVanwtpPNQwfr1+a3QENqDWiRlFcm5F/yeVUOC0Y23XsTwyIPixhfrh+DIK4FURLRmoGMkXMviuYtFzctcpPNTJemXafm/WfNnI+Q3PSZSmdm8se4vRT0qi8+BqcXXkbDvrBecSeIKVH0Z10+p/3b6/C7V8YfdXfHKooyf3vo4NJmdHqXNr2x8VIFKFFMWdN5SD6WiS4xKGEXgyLGcHVb0BFxMZACor/l/FFgzU7gvceO3z9xdyOTD5erq1EywFn9eIALOnMPzy23vH4ndT+67JfzMTEHTVzjaCPqfr7DEL6wdek=
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: 8BIT
MIME-Version: 1.0
X-OriginatorOrg: uoguelph.ca
X-MS-Exchange-CrossTenant-Network-Message-Id: a31fcdef-e4eb-4ad9-24a6-08d69b99cf05
X-MS-Exchange-CrossTenant-originalarrivaltime: 26 Feb 2019 03:23:42.4505
 (UTC)
X-MS-Exchange-CrossTenant-fromentityheader: Hosted
X-MS-Exchange-CrossTenant-id: be62a12b-2cad-49a1-a5fa-85f4f3156a7d
X-MS-Exchange-CrossTenant-mailboxtype: HOSTED
X-MS-Exchange-Transport-CrossTenantHeadersStamped: QB1PR01MB2850
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

I wrote:
[stuff snipped]
>For the pNFS case, when I implemented a pNFS server for FreeBSD, I assumed
>that the Metadata server only needed to return a correct size for a file
>to a client doing a Getattr with a read/write layout after it did a LayoutCommit.
>This implementation worked ok for the FreeBSD client, but did not work
>correctly for the Linux-4.17-rc2 kernel.
>To fix the server implementation to interoperate with the above Linux kernel,
>I had to add a tunable that makes the server get an up to date size for the
>Getattr operation for a client when a read/write layout is issued to the client.
>Just to be clear, I am referring to the case where the Getattr was done by the
>client that holds the read/write layout and not another client.
>(This does result in additional overheads whenever a client holds a read/write
> layout for the file.)
>I can't remember exactly how the Linux client failed, but I suspect it would
>see a premature EOF when the size returned by the MDS was smaller than
>the actual size of the file on the DS.
>
>I honestly don't know if this is a bug in the Linux client or a misinterpretation
>of RFC5661?
A little more info on this.

If I recall correctly, the Linux client only did LayoutCommits after Commits.
As such, no LayoutCommit were done after writes to a DS that were FILE_SYNC
(or stable, if you prefer). Without the LayoutCommit, the pNFS server didn't
know when it needed to get an up to date size.
The FreeBSD client does a LayoutCommit after writing to a DS whenever it is done
writing, such as an fsync() or close() syscall on the file or an unlock of a write lock
on the file.

rick


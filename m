Return-Path: <SRS0=ZVvz=NR=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS,URIBL_BLOCKED autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 8604CC32789
	for <linux-nfs@archiver.kernel.org>; Tue,  6 Nov 2018 22:17:26 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 44BB120830
	for <linux-nfs@archiver.kernel.org>; Tue,  6 Nov 2018 22:17:26 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 44BB120830
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=uoguelph.ca
Authentication-Results: mail.kernel.org; spf=none smtp.mailfrom=linux-nfs-owner@vger.kernel.org
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1726462AbeKGHot convert rfc822-to-8bit (ORCPT
        <rfc822;linux-nfs@archiver.kernel.org>);
        Wed, 7 Nov 2018 02:44:49 -0500
Received: from mail-eopbgr670040.outbound.protection.outlook.com ([40.107.67.40]:56832
        "EHLO CAN01-TO1-obe.outbound.protection.outlook.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1726403AbeKGHot (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Wed, 7 Nov 2018 02:44:49 -0500
Received: from YTOPR0101MB1162.CANPRD01.PROD.OUTLOOK.COM (52.132.50.155) by
 YTOPR0101MB1292.CANPRD01.PROD.OUTLOOK.COM (52.132.45.19) with Microsoft SMTP
 Server (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384) id
 15.20.1294.21; Tue, 6 Nov 2018 22:17:22 +0000
Received: from YTOPR0101MB1162.CANPRD01.PROD.OUTLOOK.COM
 ([fe80::9c71:6eb6:1bff:727b]) by YTOPR0101MB1162.CANPRD01.PROD.OUTLOOK.COM
 ([fe80::9c71:6eb6:1bff:727b%3]) with mapi id 15.20.1294.034; Tue, 6 Nov 2018
 22:17:22 +0000
From:   Rick Macklem <rmacklem@uoguelph.ca>
To:     Bill Baker <Bill.Baker@Oracle.com>,
        "Mkrtchyan, Tigran" <tigran.mkrtchyan@desy.de>,
        Malahal Naineni <malahal@gmail.com>
CC:     NeilBrown <neilb@suse.com>, Marc Eshel <eshel@us.ibm.com>,
        Benjamin Coddington <bcodding@redhat.com>,
        linux-nfs <linux-nfs@vger.kernel.org>,
        "linux-nfs-owner@vger.kernel.org" <linux-nfs-owner@vger.kernel.org>,
        Matt Benjamin <mbenjami@redhat.com>,
        trondmy <trondmy@hammerspace.com>
Subject: Re: "(deleted)" directories
Thread-Topic: "(deleted)" directories
Thread-Index: AQHUdgaCl3gmVS2nxEqPUZFsz3a526VDS2S0
Date:   Tue, 6 Nov 2018 22:17:22 +0000
Message-ID: <YTOPR0101MB1162EF371A0C05ABCD44259EDDCB0@YTOPR0101MB1162.CANPRD01.PROD.OUTLOOK.COM>
References: <CAGD+tkyTyOb-iiykQLYMoa1h5cmizbe_0M0_HS=9cQC1NDznSw@mail.gmail.com>
 <OF63D29519.B9156C69-ON8825833A.000DEE9B-8825833A.000E8123@notes.na.collabserv.com>
 <87a7mp1k9a.fsf@notabene.neil.brown.name>
 <OFEF532072.6C501ABB-ON8825833B.006B930A-8825833B.006CB5D7@notes.na.collabserv.com>
 <87sh0gz7mt.fsf@notabene.neil.brown.name>
 <CAGD+tkwz_HvBmjwQgLbftf6qU-pL75SJ6a1zq_P239eXMOUDgg@mail.gmail.com>
 <87muqoyutl.fsf@notabene.neil.brown.name>
 <CAGD+tkw5QqZet6n82NavneWK8-_uHo24muxYPj+gqrY=tbk2yA@mail.gmail.com>
 <2003075164.16045771.1541493796820.JavaMail.zimbra@desy.de>,<d4c78362-a80c-cff6-8da9-b8872fb750d5@Oracle.com>
In-Reply-To: <d4c78362-a80c-cff6-8da9-b8872fb750d5@Oracle.com>
Accept-Language: en-US
Content-Language: en-US
X-MS-Has-Attach: 
X-MS-TNEF-Correlator: 
authentication-results: spf=none (sender IP is )
 smtp.mailfrom=rmacklem@uoguelph.ca; 
x-ms-publictraffictype: Email
x-microsoft-exchange-diagnostics: 1;YTOPR0101MB1292;6:C91ptrCVlCTD2wb1SVYPA7VRWJD9rKTYwnEB2KQe6ovaARCkhIUlyy4nnDerVMHY7hovlSp2DzReofELePknPwblNBfr1YOLeYA4lL4749EfMQmq/rIYEUMRM6oBb2TCGw6GWuqN0NuY79m5j49RuyNVMMOhcO2KeyY3lFGQc5PG1KBIUyYhf0Dd1K2O7uN4xWFC9YPjfSMxPmjzTC15zzgunlBpFquTZ7LaoJluHeYvftgYaP3vXdtdGn3u/e0gjlpuV2Gdcs34EukH+NbPFaZKutf9uqDFyeihzA+G2XXROPHddst7bK8vCFujg3TeJ4zzSxzP2AexMY8+HKA7bkSUzSER2c6p/dP20v+2BenGaKa7U2Zdt9uiI7PwyxxMsqGsOE3NFZWbhz5oV+6aT1fj1H67kE730k3Xpi3v7xZ4o7dCobl+OJ+5hW0x68NUsL4RyMQLh3zKb+3Pj0bpxQ==;5:3h/+0eaGR2HkS4hja/hiRvoDmsN05qi8/GyI/+r+jNE3kcgUP15bG9ILuhh1okG0niRP4aA5VH+miOZppC0KhSqAeDaZ7mQw0X3qLLUfhh6s5yoadJ59ojAQxMeLenB60FcMYt+8nBw5rV0TzRbkaCu79S5/ATtWPR10kdBG3EU=;7:kEc4ImsfYuEjvLAlf7M2YgNg22BpZFzZi03ec5ucnMyAoz7DN3fGCdQ5GxUTfX1J8Pzjy/OA7YA+RyUpo13dcJe3OErlIm0jUT03sF/nzuu/rT8crmwzoGMAP2bxOEw0p76ttgznPuRKMZQtjbAa3A==
x-ms-exchange-antispam-srfa-diagnostics: SOS;
x-ms-office365-filtering-correlation-id: 56b70fa2-0455-49c2-adfd-08d644359ff6
x-microsoft-antispam: BCL:0;PCL:0;RULEID:(7020095)(4652040)(8989299)(5600074)(711020)(4534185)(4627221)(201703031133081)(201702281549075)(8990200)(2017052603328)(7153060)(7193020);SRVR:YTOPR0101MB1292;
x-ms-traffictypediagnostic: YTOPR0101MB1292:
x-microsoft-antispam-prvs: <YTOPR0101MB1292315490139CF963E97FBADDCB0@YTOPR0101MB1292.CANPRD01.PROD.OUTLOOK.COM>
x-exchange-antispam-report-test: UriScan:(9452136761055)(158342451672863)(85827821059158)(274839183919467)(104084551191319);
x-ms-exchange-senderadcheck: 1
x-exchange-antispam-report-cfa-test: BCL:0;PCL:0;RULEID:(6040522)(2401047)(8121501046)(5005006)(93006095)(93001095)(10201501046)(3002001)(3231382)(944501410)(52105095)(148016)(149066)(150057)(6041310)(20161123562045)(20161123558120)(20161123560045)(20161123564045)(201703131423095)(201702281529075)(201702281528075)(20161123555045)(201703061421075)(201703061406153)(201708071742011)(7699051)(76991095);SRVR:YTOPR0101MB1292;BCL:0;PCL:0;RULEID:;SRVR:YTOPR0101MB1292;
x-forefront-prvs: 0848C1A6AA
x-forefront-antispam-report: SFV:NSPM;SFS:(10009020)(396003)(376002)(366004)(346002)(39860400002)(136003)(51444003)(189003)(199004)(71200400001)(229853002)(105586002)(76176011)(2900100001)(25786009)(478600001)(486006)(7416002)(446003)(2906002)(11346002)(4326008)(5660300001)(39060400002)(256004)(68736007)(305945005)(476003)(46003)(99286004)(33656002)(93886005)(7696005)(97736004)(74316002)(106356001)(102836004)(74482002)(55016002)(86362001)(186003)(6436002)(8936002)(81166006)(110136005)(81156014)(53936002)(786003)(6246003)(316002)(6506007)(8676002)(14454004)(9686003)(71190400001)(54906003);DIR:OUT;SFP:1101;SCL:1;SRVR:YTOPR0101MB1292;H:YTOPR0101MB1162.CANPRD01.PROD.OUTLOOK.COM;FPR:;SPF:None;LANG:en;PTR:InfoNoRecords;MX:1;A:1;
received-spf: None (protection.outlook.com: uoguelph.ca does not designate
 permitted sender hosts)
x-microsoft-antispam-message-info: JojGMHapYzSotE+ghCHa3ecgtIuH7cG92q1xF5IpeLZwejF+AsZHfnBULgvlRkTuwqIJCiS8ahLMsF0G6yFI/JdBJJQZTJENM6Tw6BhA2Qw7Mm2maVKIFPAeTeLB5squfMXduiloA0RodS3zfoKY6lBqQwZzb37kNFJZFcHIii87yKdfhCGUim+gRj/ySf3C+fFGSn0HqoWqLtw4Lw13v5xMXWJm83uetlv5Gu/BgCjJJIfya1cVbitLu+IccIDCF2+D8EqmSwtC/05MBLCBfgpEV32nSKgFkdV3WjyYTOYSaNv3eQxjnPfbkRtMzkA2nkDs+1suAU+MUFHnJXJv4SLw0aFmSlppfwRVJB4yfQU=
spamdiagnosticoutput: 1:99
spamdiagnosticmetadata: NSPM
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: 8BIT
MIME-Version: 1.0
X-OriginatorOrg: uoguelph.ca
X-MS-Exchange-CrossTenant-Network-Message-Id: 56b70fa2-0455-49c2-adfd-08d644359ff6
X-MS-Exchange-CrossTenant-originalarrivaltime: 06 Nov 2018 22:17:22.6578
 (UTC)
X-MS-Exchange-CrossTenant-fromentityheader: Hosted
X-MS-Exchange-CrossTenant-id: be62a12b-2cad-49a1-a5fa-85f4f3156a7d
X-MS-Exchange-Transport-CrossTenantHeadersStamped: YTOPR0101MB1292
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

I'll admit I lost the indentations indicating who wrote what, but my comment
is fairly generic w.r.t. this.
>> From: "Malahal Naineni" <malahal@gmail.com>
>> To: "NeilBrown" <neilb@suse.com>
>> Cc: "Marc Eshel" <eshel@us.ibm.com>, "Benjamin Coddington" <bcodding@redhat.com>, "linux-nfs"
>> <linux-nfs@vger.kernel.org>, linux-nfs-owner@vger.kernel.org, "Matt Benjamin" <mbenjami@redhat.com>, "trondmy"
>> <trondmy@hammerspace.com>
>> Sent: Monday, November 5, 2018 8:40:16 AM
>> Subject: Re: "(deleted)" directories
>
>>>> My reading of section 10.3.4 of RFC7530 suggests that the client should
>> generally compare fsid and fileid to see if two different filehandles refer to
>> the same object or not.
>>
>> Section 10.3.4 is for files only correct? The issue here is for
>> directories. Also, Trond clearly pointed that Linux breaks section
>> 10.3.4 from his email stating "We treat always different filehandles
>> as if they refer to different
>> files. It has long been the case that snapshots from several vendors
>> are encoded to look like the same file (same fileid + same  fsid) and
>> differing only by filehandle. If we were to try to consolidate those
>> inodes we would end up corrupting application data."
>>
>> We don't respect either NFSv3 or NFSv4 RFCs in this regard!
Part of the question for NFSv4 is whether or not the server returns
"unique_handles == true"?

For example, if Netapp filers return "unique_handles" as true, then they are
fine for NFSv4 using the same (fsid, fileno) for two distinct files.
(Second bullet point in RFC 7530 Sec. 10.3.4.)
Is there an example (like Netapp) where the only difference is the file handle
and the server returns "unique_handles == false"?

One approach for a client might be the following:
- if NFSv3
      - set unique_handles true

- if file handles same
      - same file object
  else if unique_handles == true
       - different file object
  else
       - if fsid or fileno not same
                - different file object
          else
                - same file object

Btw, Sec. 10.3.4 of RFC7530 discusses file objects, so I'd think it is meant to
apply to directories as well as regular files. (It does talk about "file data", but
I think that can refer to directory contents?)

I'll admit I can't remember what the behaviour of the FreeBSD NFS client is
for non-unique file handles, but I might take a look and try to make it use the
above algorithm.

rick

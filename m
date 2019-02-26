Return-Path: <SRS0=yawm=RB=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 2526EC43381
	for <linux-nfs@archiver.kernel.org>; Tue, 26 Feb 2019 02:54:52 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id E1DE12147C
	for <linux-nfs@archiver.kernel.org>; Tue, 26 Feb 2019 02:54:51 +0000 (UTC)
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1726082AbfBZCyv convert rfc822-to-8bit (ORCPT
        <rfc822;linux-nfs@archiver.kernel.org>);
        Mon, 25 Feb 2019 21:54:51 -0500
Received: from mail-eopbgr670055.outbound.protection.outlook.com ([40.107.67.55]:37968
        "EHLO CAN01-TO1-obe.outbound.protection.outlook.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1725954AbfBZCyv (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Mon, 25 Feb 2019 21:54:51 -0500
Received: from QB1PR01MB3537.CANPRD01.PROD.OUTLOOK.COM (52.132.89.15) by
 QB1PR01MB3508.CANPRD01.PROD.OUTLOOK.COM (52.132.88.220) with Microsoft SMTP
 Server (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384) id
 15.20.1643.18; Tue, 26 Feb 2019 02:54:08 +0000
Received: from QB1PR01MB3537.CANPRD01.PROD.OUTLOOK.COM
 ([fe80::609b:1ecd:c908:d44c]) by QB1PR01MB3537.CANPRD01.PROD.OUTLOOK.COM
 ([fe80::609b:1ecd:c908:d44c%6]) with mapi id 15.20.1643.019; Tue, 26 Feb 2019
 02:54:08 +0000
From:   Rick Macklem <rmacklem@uoguelph.ca>
To:     "Mkrtchyan, Tigran" <tigran.mkrtchyan@desy.de>,
        Dave Noveck <davenoveck@gmail.com>
CC:     Marc Eshel <eshel@us.ibm.com>,
        linux-nfs <linux-nfs@vger.kernel.org>,
        Ganesha-devel <devel@lists.nfs-ganesha.org>,
        NFSv4 <nfsv4@ietf.org>,
        linux-nfs-owner <linux-nfs-owner@vger.kernel.org>
Subject: Re: [nfsv4] file size and getattr
Thread-Topic: [nfsv4] file size and getattr
Thread-Index: xB45BipLgBZpsCd+0L6G4OWR1hcJRu0o7KH9
Date:   Tue, 26 Feb 2019 02:54:08 +0000
Message-ID: <QB1PR01MB3537C4C84605F9C26050DDA8DD7B0@QB1PR01MB3537.CANPRD01.PROD.OUTLOOK.COM>
References: <155049372736.14318.3390584694682770373.idtracker@ietfa.amsl.com>
 <CADaq8je2Ap4oAZAPOguaWctUs8dQ=Q9g=TO39EOiJW5EJSFTGg@mail.gmail.com>
 <OFE5A6CD32.4DC48078-ON882583A9.007FB4BC-882583A9.0080ACAC@notes.na.collabserv.com>
 <CADaq8jfT=nxmVPz4mDRFAaOx36uxWqKbxitqS-YH3GCOs4CsrQ@mail.gmail.com>,<741516773.7109032.1551084577150.JavaMail.zimbra@desy.de>
In-Reply-To: <741516773.7109032.1551084577150.JavaMail.zimbra@desy.de>
Accept-Language: en-US
Content-Language: en-US
X-MS-Has-Attach: 
X-MS-TNEF-Correlator: 
authentication-results: spf=none (sender IP is )
 smtp.mailfrom=rmacklem@uoguelph.ca; 
x-ms-publictraffictype: Email
x-ms-office365-filtering-correlation-id: 6b6dcb9f-0a21-4a19-089d-08d69b95adc8
x-microsoft-antispam: BCL:0;PCL:0;RULEID:(2390118)(7020095)(4652040)(8989299)(4534185)(4627221)(201703031133081)(201702281549075)(8990200)(5600127)(711020)(4605104)(2017052603328)(7153060)(7193020);SRVR:QB1PR01MB3508;
x-ms-traffictypediagnostic: QB1PR01MB3508:
x-microsoft-exchange-diagnostics: =?iso-8859-1?Q?1;QB1PR01MB3508;23:yn3qZ3xtA/f2K55TYgjEwzakh4j1Q8QWrBRzgF1?=
 =?iso-8859-1?Q?CfmyxXt/JSfFW9+IlvE08Rx/6xLQ9+ZHEpkBgbMcXHUg+sH/efbzjmdE2/?=
 =?iso-8859-1?Q?qeYYmkOix9dRklJldkLlLfGD1K4QgmJW43sfXYZp7YjydVG+mnGi7utCq1?=
 =?iso-8859-1?Q?+C9l+w9XOnWLdv7OUac3l/drTXyL35MRCNEfV1/KMad9aq17C5MrAKb77V?=
 =?iso-8859-1?Q?EqQ2odMwZu3d7WcIptQ+cZQOke75P6aQLXxjfmt/S9u3pfpB0MYDQWzj2L?=
 =?iso-8859-1?Q?YS06nswvMl3raWVgcJvuZVcAaBJlasf5mj05VLqSay+31v/6BLRKpF7RES?=
 =?iso-8859-1?Q?dL7ixi6y3zxYTbl0WHvYh8p1BhVIGCSuJLHG5gpYIKJ541r8HI4OyDNBDG?=
 =?iso-8859-1?Q?V7BU6XXNAtHoswkTYw3wTVY6KMdMIRCRw4xIZ2c4/QXbb9R+gpi3lFq/ni?=
 =?iso-8859-1?Q?KVT/rojbKvigYL26E5jBsyMyCH49wgbGlgaKzB5jGyKoRa0RDB4Hzqlnl+?=
 =?iso-8859-1?Q?ujdhWroo8wqqzX/+jfvJ8YgI+NmkMc8DeOc2Aoe/U/BPuJAZph7kKHC9Jm?=
 =?iso-8859-1?Q?V4oGMzNJRPxYMnIAVd5VILSKZf5x8Xj9FHDss4AZA85YldkZJyeImnd0Pw?=
 =?iso-8859-1?Q?Kx0Ct9nZnBUrBsby9uGvBrhqf+sO37rjR+EkWmeQmbzUf2qPrsnU722+99?=
 =?iso-8859-1?Q?brlfzum7tUrqs4Bv8U2X9IRM3+QC74kfe8B4/bkV7IsqFEX+QQIM0rir7z?=
 =?iso-8859-1?Q?LLj77xhVnAfJifmr+2CbTTcpja8acZh/heyWsYRqHd3oXxF1NQOboaAG6j?=
 =?iso-8859-1?Q?9VarDAQGsOtFUQCr5JuHyg6i9ogFvsVzbCjP9wz5JFHQvFqv0W4zA1Cgtl?=
 =?iso-8859-1?Q?//q/mD11Nx5C2Ifrs9JVwcX1FFaJx1/Dcn5ihMBAGBP07e83k0rx2TskLW?=
 =?iso-8859-1?Q?hE++bMggrMQVZcb4PDsACStdqhCXYoES19iKzHS1iD3iNqXcgzXvCRjKxz?=
 =?iso-8859-1?Q?Jx2FBtxqvGT5u7bcOBlctox9VZ/Ex5MbEoOL0MJagWu82I6IOeBAwJVrb8?=
 =?iso-8859-1?Q?/rSp6LnqCPIQYathC0rzYvfGKWYJPVB7l8xqkNPS/QXaP9Pd9HAioUIJK7?=
 =?iso-8859-1?Q?sD0VEuyvp10aJHGJEZ45CJ9eGquPujTa9LkKwgD/4acQLk0FNJgpa/FvcH?=
 =?iso-8859-1?Q?g+QuSCuyu3Vz4j8vIkHUj67vLaFtwNGdK5IVizw7tzaBMjEx+W4Gdc=3D?=
x-microsoft-antispam-prvs: <QB1PR01MB35084E3C93F1207DCA8CC4D3DD7B0@QB1PR01MB3508.CANPRD01.PROD.OUTLOOK.COM>
x-forefront-prvs: 096029FF66
x-forefront-antispam-report: SFV:NSPM;SFS:(10009020)(376002)(396003)(366004)(39860400002)(346002)(136003)(199004)(189003)(105586002)(786003)(106356001)(305945005)(102836004)(97736004)(6506007)(8936002)(53936002)(68736007)(93886005)(99286004)(110136005)(25786009)(33656002)(4326008)(316002)(5660300002)(54906003)(74482002)(14444005)(2906002)(76176011)(256004)(7696005)(476003)(6246003)(71190400001)(71200400001)(14454004)(9686003)(8676002)(81166006)(81156014)(55016002)(229853002)(478600001)(6436002)(11346002)(74316002)(486006)(186003)(446003)(86362001)(46003);DIR:OUT;SFP:1101;SCL:1;SRVR:QB1PR01MB3508;H:QB1PR01MB3537.CANPRD01.PROD.OUTLOOK.COM;FPR:;SPF:None;LANG:en;PTR:InfoNoRecords;A:1;MX:1;
received-spf: None (protection.outlook.com: uoguelph.ca does not designate
 permitted sender hosts)
x-ms-exchange-senderadcheck: 1
x-microsoft-antispam-message-info: JVIhy2hESDEcETzlfKd4SGnYw0g59Dyo2de9Y5+QsPp/q9YuOaQnr4EM6th80DJ1NqHd6xc8Bd9eZPxgLPSosD650/8cNKjMUcd9sgz9IEbY4cvRxbyYFaC2Z38WTOevZCYd8UE1s7L4GE+UgqOK6ApnSds3MvhLhi7x33wDPt/GF+quolxxGfkqtBbbVxEckqvjUmCusm1q566tlOURnVL1OF9I/3pKrtVYC8TuvIjxiiTOig61V2NkeEnVYocDRZJfgZOajckfv63YPVu+x/CQkeWmlZ1+BbQz/89RDpnLkMCDjrBX/nCudLKryyXo1NWQLRvH+NJmkEuCq3V37pmEqtiKT2Jk8/FXiy82LBHgNReSZhG3aoBw2jmmVgW5M8EyILXpae1YkK7VG3U86d5J9eCXVAgn5tN+5PNPfho=
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: 8BIT
MIME-Version: 1.0
X-OriginatorOrg: uoguelph.ca
X-MS-Exchange-CrossTenant-Network-Message-Id: 6b6dcb9f-0a21-4a19-089d-08d69b95adc8
X-MS-Exchange-CrossTenant-originalarrivaltime: 26 Feb 2019 02:54:08.6113
 (UTC)
X-MS-Exchange-CrossTenant-fromentityheader: Hosted
X-MS-Exchange-CrossTenant-id: be62a12b-2cad-49a1-a5fa-85f4f3156a7d
X-MS-Exchange-CrossTenant-mailboxtype: HOSTED
X-MS-Exchange-Transport-CrossTenantHeadersStamped: QB1PR01MB3508
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

Mkrtchyan, Tigran wrote:
>> From: "Dave Noveck" <davenoveck@gmail.com>
>> To: "Marc Eshel" <eshel@us.ibm.com>
>> Cc: "linux-nfs" <linux-nfs@vger.kernel.org>, "Ganesha-devel" <devel@lists.nfs-ganesha.org>, "NFSv4" <nfsv4@ietf.org>,
>> "linux-nfs-owner" <linux-nfs-owner@vger.kernel.org>
>> Sent: Saturday, February 23, 2019 12:38:56 AM
>> Subject: Re: [nfsv4] file size and getattr
>>
>>> Does the NFSv4 spec allows the server to return file size that doesn't
>>> include the unstable write to the writer or any other NFS client?
>>
>> I would say "no".   Consider the followiing sentence in the description of
>> COMMIT.
>>
>
>I would say "yes". Let's have a look at LAYOUTCOMMIT. Spec says:
>
>"The metadata server may
>   use this information to determine whether the file's size needs to be
>   updated.  If the metadata server updates the file's size as the
>   result of the LAYOUTCOMMIT operation, it must return the new size
>   (locr_newsize.ns_size) as part of the results."
>
>I read this as: Metadata server may not know real file size until client sends
>the file size information. Our DSes return DATA_SYNC and relay on client to
>issue LAYOUTCOMMIT to update file size (well, on close we force data servers
>up update file anyway).

For the pNFS case, when I implemented a pNFS server for FreeBSD, I assumed
that the Metadata server only needed to return a correct size for a file
to a client doing a Getattr with a read/write layout after it did a LayoutCommit.
This implementation worked ok for the FreeBSD client, but did not work
correctly for the Linux-4.17-rc2 kernel.
To fix the server implementation to interoperate with the above Linux kernel,
I had to add a tunable that makes the server get an up to date size for the
Getattr operation for a client when a read/write layout is issued to the client.
Just to be clear, I am referring to the case where the Getattr was done by the
client that holds the read/write layout and not another client.
(This does result in additional overheads whenever a client holds a read/write
 layout for the file.)
I can't remember exactly how the Linux client failed, but I suspect it would
see a premature EOF when the size returned by the MDS was smaller than
the actual size of the file on the DS.

I honestly don't know if this is a bug in the Linux client or a misinterpretation
of RFC5661?

rick


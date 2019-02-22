Return-Path: <SRS0=ibFv=Q5=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id DE787C43381
	for <linux-nfs@archiver.kernel.org>; Fri, 22 Feb 2019 23:25:35 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id AD290206A3
	for <linux-nfs@archiver.kernel.org>; Fri, 22 Feb 2019 23:25:35 +0000 (UTC)
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1725774AbfBVXZf convert rfc822-to-8bit (ORCPT
        <rfc822;linux-nfs@archiver.kernel.org>);
        Fri, 22 Feb 2019 18:25:35 -0500
Received: from mx0a-001b2d01.pphosted.com ([148.163.156.1]:36900 "EHLO
        mx0a-001b2d01.pphosted.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1725811AbfBVXZe (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Fri, 22 Feb 2019 18:25:34 -0500
Received: from pps.filterd (m0098396.ppops.net [127.0.0.1])
        by mx0a-001b2d01.pphosted.com (8.16.0.27/8.16.0.27) with SMTP id x1MNNa0N131840
        for <linux-nfs@vger.kernel.org>; Fri, 22 Feb 2019 18:25:34 -0500
Received: from smtp.notes.na.collabserv.com (smtp.notes.na.collabserv.com [192.155.248.73])
        by mx0a-001b2d01.pphosted.com with ESMTP id 2qtqu8r1xn-1
        (version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=NOT)
        for <linux-nfs@vger.kernel.org>; Fri, 22 Feb 2019 18:25:34 -0500
Received: from localhost
        by smtp.notes.na.collabserv.com with smtp.notes.na.collabserv.com ESMTP
        for <linux-nfs@vger.kernel.org> from <eshel@us.ibm.com>;
        Fri, 22 Feb 2019 23:25:33 -0000
Received: from us1a3-smtp07.a3.dal06.isc4sb.com (10.146.103.14)
        by smtp.notes.na.collabserv.com (10.106.227.90) with smtp.notes.na.collabserv.com ESMTP;
        Fri, 22 Feb 2019 23:25:27 -0000
Received: from us1a3-mail148.a3.dal06.isc4sb.com ([10.146.38.117])
          by us1a3-smtp07.a3.dal06.isc4sb.com
          with ESMTP id 2019022223252604-986975 ;
          Fri, 22 Feb 2019 23:25:26 +0000 
In-Reply-To: <CADaq8je2Ap4oAZAPOguaWctUs8dQ=Q9g=TO39EOiJW5EJSFTGg@mail.gmail.com>
To:     David Noveck <davenoveck@gmail.com>
Cc:     NFSv4 <nfsv4@ietf.org>, linux-nfs@vger.kernel.org,
        linux-nfs-owner@vger.kernel.org,
        "'Ganesha-devel'" <devel@lists.nfs-ganesha.org>
Subject: file size and getattr
From:   "Marc Eshel" <eshel@us.ibm.com>
Date:   Fri, 22 Feb 2019 15:25:26 -0800
References: <155049372736.14318.3390584694682770373.idtracker@ietfa.amsl.com>
 <CADaq8je2Ap4oAZAPOguaWctUs8dQ=Q9g=TO39EOiJW5EJSFTGg@mail.gmail.com>
MIME-Version: 1.0
X-KeepSent: E5A6CD32:4DC48078-882583A9:007FB4BC;
 type=4; name=$KeepSent
X-Mailer: IBM Notes Release 9.0.1EXT SHF993 September 20, 2018
X-LLNOutbound: False
X-Disclaimed: 1303
X-TNEFEvaluated: 1
x-cbid: 19022223-3107-0000-0000-00000A1E778A
X-IBM-SpamModules-Scores: BY=0.000003; FL=0; FP=0; FZ=0; HX=0; KW=0; PH=0;
 SC=0.415652; ST=0; TS=0; UL=0; ISC=; MB=0.001065
X-IBM-SpamModules-Versions: BY=3.00010646; HX=3.00000242; KW=3.00000007;
 PH=3.00000004; SC=3.00000281; SDB=6.01164942; UDB=6.00608383; IPR=6.00945530;
 BA=6.00006239; NDR=6.00000001; ZLA=6.00000005; ZF=6.00000009; ZB=6.00000000;
 ZP=6.00000000; ZH=6.00000000; ZU=6.00000002; MB=3.00025703; XFM=3.00000015;
 UTC=2019-02-22 23:25:30
X-IBM-AV-DETECTION: SAVI=unsuspicious REMOTE=unsuspicious XFE=unused
X-IBM-AV-VERSION: SAVI=2019-02-22 19:55:20 - 6.00009618
x-cbparentid: 19022223-3108-0000-0000-00005CCE90B7
Message-Id: <OFE5A6CD32.4DC48078-ON882583A9.007FB4BC-882583A9.0080ACAC@notes.na.collabserv.com>
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 8BIT
X-Proofpoint-Virus-Version: vendor=fsecure engine=2.50.10434:,, definitions=2019-02-22_14:,,
 signatures=0
X-Proofpoint-Spam-Reason: safe
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

What is the file size returned by the NFS server for getattr after an 
unstable write to the NFS client that did the write or to other NFS 
clients.

As far as I know most file systems will always return the file size that 
includes the unstable writes. 

Does the NFSv4 spec allows the server to return file size that doesn't 
include the unstable write to the writer or any other NFS client?

Marc.


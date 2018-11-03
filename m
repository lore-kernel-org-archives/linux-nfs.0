Return-Path: <SRS0=m0hb=NO=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.8 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS,URIBL_BLOCKED autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 4D44EC32789
	for <linux-nfs@archiver.kernel.org>; Sat,  3 Nov 2018 02:38:35 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id E7FD62082D
	for <linux-nfs@archiver.kernel.org>; Sat,  3 Nov 2018 02:38:34 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org E7FD62082D
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=us.ibm.com
Authentication-Results: mail.kernel.org; spf=none smtp.mailfrom=linux-nfs-owner@vger.kernel.org
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1728372AbeKCLsO convert rfc822-to-8bit (ORCPT
        <rfc822;linux-nfs@archiver.kernel.org>);
        Sat, 3 Nov 2018 07:48:14 -0400
Received: from mx0b-001b2d01.pphosted.com ([148.163.158.5]:36974 "EHLO
        mx0a-001b2d01.pphosted.com" rhost-flags-OK-OK-OK-FAIL)
        by vger.kernel.org with ESMTP id S1728356AbeKCLsO (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Sat, 3 Nov 2018 07:48:14 -0400
Received: from pps.filterd (m0098420.ppops.net [127.0.0.1])
        by mx0b-001b2d01.pphosted.com (8.16.0.22/8.16.0.22) with SMTP id wA32Y5HZ111309
        for <linux-nfs@vger.kernel.org>; Fri, 2 Nov 2018 22:38:32 -0400
Received: from smtp.notes.na.collabserv.com (smtp.notes.na.collabserv.com [192.155.248.93])
        by mx0b-001b2d01.pphosted.com with ESMTP id 2ngy97e2u3-1
        (version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=NOT)
        for <linux-nfs@vger.kernel.org>; Fri, 02 Nov 2018 22:38:32 -0400
Received: from localhost
        by smtp.notes.na.collabserv.com with smtp.notes.na.collabserv.com ESMTP
        for <linux-nfs@vger.kernel.org> from <eshel@us.ibm.com>;
        Sat, 3 Nov 2018 02:38:32 -0000
Received: from us1a3-smtp05.a3.dal06.isc4sb.com (10.146.71.159)
        by smtp.notes.na.collabserv.com (10.106.227.39) with smtp.notes.na.collabserv.com ESMTP;
        Sat, 3 Nov 2018 02:38:26 -0000
Received: from us1a3-mail148.a3.dal06.isc4sb.com ([10.146.38.117])
          by us1a3-smtp05.a3.dal06.isc4sb.com
          with ESMTP id 2018110302382559-1153317 ;
          Sat, 3 Nov 2018 02:38:25 +0000 
In-Reply-To: <a45a428ad45e5834fa7030088a75275584b13ab2.camel@hammerspace.com>
To:     Trond Myklebust <trondmy@hammerspace.com>
Cc:     "bcodding@redhat.com" <bcodding@redhat.com>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>,
        linux-nfs-owner@vger.kernel.org,
        "malahal@gmail.com" <malahal@gmail.com>,
        "mbenjami@redhat.com" <mbenjami@redhat.com>
Subject: Re: "(deleted)" directories
From:   "Marc Eshel" <eshel@us.ibm.com>
Date:   Fri, 2 Nov 2018 18:38:25 -0800
References: <CAGD+tkyTyOb-iiykQLYMoa1h5cmizbe_0M0_HS=9cQC1NDznSw@mail.gmail.com>
         <24BEBD2F-BCC2-4AE0-81D7-185D6CAB8CD7@redhat.com>
         <CAGD+tkzyDoq6tdseFQu4ymJCc-+-2i6XEUmBGKe4mu4_ngv7QA@mail.gmail.com>
         <435a5a0fcdbefc30201c91b0a36b6159f6df32eb.camel@hammerspace.com>
         <CAKOnarkG4tpA7F306hgpk14XNELEFY1gaY7=QY4h6Dr-zSQzRw@mail.gmail.com>
 <a45a428ad45e5834fa7030088a75275584b13ab2.camel@hammerspace.com>
MIME-Version: 1.0
X-KeepSent: 63D29519:B9156C69-8825833A:000DEE9B;
 type=4; name=$KeepSent
X-Mailer: IBM Notes Release 9.0.1EXT SHF766 December 14, 2016
X-LLNOutbound: False
X-Disclaimed: 45219
X-TNEFEvaluated: 1
x-cbid: 18110302-1799-0000-0000-000008F1B706
X-IBM-SpamModules-Scores: BY=0; FL=0; FP=0; FZ=0; HX=0; KW=0; PH=0;
 SC=0.365752; ST=0; TS=0; UL=0; ISC=; MB=0.283038
X-IBM-SpamModules-Versions: BY=3.00009973; HX=3.00000242; KW=3.00000007;
 PH=3.00000004; SC=3.00000268; SDB=6.01111850; UDB=6.00576226; IPR=6.00891941;
 BA=6.00006137; NDR=6.00000001; ZLA=6.00000005; ZF=6.00000009; ZB=6.00000000;
 ZP=6.00000000; ZH=6.00000000; ZU=6.00000002; MB=3.00024008; XFM=3.00000015;
 UTC=2018-11-03 02:38:30
X-IBM-AV-DETECTION: SAVI=unsuspicious REMOTE=unsuspicious XFE=unused
X-IBM-AV-VERSION: SAVI=2018-11-03 02:06:46 - 6.00009171
x-cbparentid: 18110302-1800-0000-0000-0000BBF6EB3C
Message-Id: <OF63D29519.B9156C69-ON8825833A.000DEE9B-8825833A.000E8123@notes.na.collabserv.com>
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 8BIT
X-Proofpoint-Virus-Version: vendor=fsecure engine=2.50.10434:,, definitions=2018-11-02_17:,,
 signatures=0
X-Proofpoint-Spam-Reason: safe
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

One reason to have different FHs for the same file is that a file can be 
linked from multiple directories.
Adding the parent inode to the FH help finding the the name of the file by 
looking for the file inode in
the parent directoy.

Marc.

linux-nfs-owner@vger.kernel.org wrote on 11/02/2018 05:15:42 PM:

> From: Trond Myklebust <trondmy@hammerspace.com>
> To: "mbenjami@redhat.com" <mbenjami@redhat.com>
> Cc: "bcodding@redhat.com" <bcodding@redhat.com>, "malahal@gmail.com"
> <malahal@gmail.com>, "linux-nfs@vger.kernel.org" 
<linux-nfs@vger.kernel.org>
> Date: 11/02/2018 05:15 PM
> Subject: Re: "(deleted)" directories
> Sent by: linux-nfs-owner@vger.kernel.org
> 
> On Fri, 2018-11-02 at 18:07 -0400, Matt Benjamin wrote:
> > It sounds like a pretty good one, that goes to the heart of what a
> > specification is
> > 
> 
> While admittedly it is (still) Dia de los Muertos today, I would think
> that someone who resurrected a part of the NFSv3 spec that has been
> unused for the full 23 years of its existence might have some
> explanation for why they did so?
> 
> IOW: not being of a particularly religious persuasion, I usually want
> to understand why features are needed rather than having blind faith in
> the person who wrote the spec.
> 
> > Matt
> > 
> > On Fri, Nov 2, 2018 at 4:26 PM, Trond Myklebust <
> > trondmy@hammerspace.com> wrote:
> > > On Fri, 2018-11-02 at 21:24 +0530, Malahal Naineni wrote:
> > > > Ben, NFSv3 RFC1813.txt states: "If two file handles from the same
> > > > server are equal, they must refer to the same file, but if
> > > > they  are
> > > > not equal, no conclusions can be drawn." Ganesha does return same
> > > > fileid here (inode).
> > > > 
> > > > In NFSv4, they have introduced "unique_handles" attribute. I
> > > > don't
> > > > see
> > > > Linux NFS client using this at all though.
> > > 
> > > Why does your server need to have multiple filehandles refer to the
> > > same file, and why do you expect clients to support this?
> > > 
> > > Yes, the spec allows it, but that's not a sufficient reason.
> > > 
> > > > Regards, Malahal.
> > > > On Fri, Nov 2, 2018 at 4:35 PM Benjamin Coddington <
> > > > bcodding@redhat.com> wrote:
> > > > > On 2 Nov 2018, at 1:26, Malahal Naineni wrote:
> > > > > 
> > > > > > Hi All, we are using NFS-Ganesha with Linux NFS clients. The
> > > > > > client's
> > > > > > shell reports the following. Based on lsof, the directory is
> > > > > > marked
> > > > > > deleted. "cd to ROOT and cd to the same home directory fixes
> > > > > > the
> > > > > > issue. The client behaves as though the directory is deleted
> > > > > > and
> > > > > > recreated! Our NFS-Ganesha server implementation uses
> > > > > > multiple
> > > > > > file
> > > > > > handles that point to the same object. NFS spec says this
> > > > > > should
> > > > > > be
> > > > > > fine, but Linux NFS seems to be broken in this regard.
> > > > > > tcpdump
> > > > > > does
> > > > > > indicate file handle change (note that all file handles are
> > > > > > permanent,
> > > > > > meaning they are valid at the server any time) around this
> > > > > > issue
> > > > > > time.
> > > > > > 
> > > > > > "shell-init: error retrieving current directory: getcwd:
> > > > > > cannot
> > > > > > access
> > > > > > parent directories: No such file or directory"
> > > > > > sh        112544            malahal  cwd       DIR
> > > > > > 0,67
> > > > > >      65536   45605209 /home/malahal (deleted)
> > > > > > (10.120.154.42:/nfs/malahal-export/)
> > > > > > 
> > > > > > Function nfs_prime_dcache() seems to invalidate the dcache
> > > > > > entry
> > > > > > if
> > > > > > nfs_same_file() returns false. nfs_same_file() does seem to
> > > > > > return
> > > > > > false with the following change, if I read it correctly, if
> > > > > > there
> > > > > > is a
> > > > > > file handle change. Can this be the source of my issue? It
> > > > > > seems
> > > > > > that
> > > > > > the client should do this only if the file handle is NOT
> > > > > > valid
> > > > > > (e.g.
> > > > > > if it gets ESTALE), right?
> > > > > > 
> > > > > > The following commit seems to assume that the objects are
> > > > > > different if
> > > > > > they have different file handles!
> > > > > > commit 7dc72d5f7a0ec97a53e126c46e2cbd2560757955
> > > > > > Author: Trond Myklebust <trond.myklebust@primarydata.com>
> > > > > > Date:   Thu Sep 22 13:38:52 2016 -0400
> > > > > > 
> > > > > >     NFS: Fix inode corruption in nfs_prime_dcache()
> > > > > 
> > > > > My understanding is that for NFSv3 we have to assume that
> > > > > distinct
> > > > > filehandles are distinct objects, but maybe I'm wrong about
> > > > > this.
> > > > > 
> > > > > For NFSv4.x, we can follow the guidance in RFCs 5661 or 7530
> > > > > section 10.3.4
> > > > > to determine if the differing filehandles are the same object,
> > > > > specifically
> > > > > the fileid recommended attribute needs to be implemented.  Is
> > > > > Ganesha
> > > > > returning the same fileid for both filehandles?
> > > > > 
> > > > > Ben
> > > --
> > > Trond Myklebust
> > > CTO, Hammerspace Inc
> > > 4300 El Camino Real, Suite 105
> > > Los Altos, CA 94022
> > > www.hammer.space
> > > 
> > > 
> > 
> > 
> -- 
> Trond Myklebust
> CTO, Hammerspace Inc
> 4300 El Camino Real, Suite 105
> Los Altos, CA 94022
> www.hammer.space
> 
> 



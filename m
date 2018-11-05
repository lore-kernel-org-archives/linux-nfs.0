Return-Path: <SRS0=wnB3=NQ=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.8 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS,URIBL_BLOCKED autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 9E95BC0044C
	for <linux-nfs@archiver.kernel.org>; Mon,  5 Nov 2018 04:48:28 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 3515820685
	for <linux-nfs@archiver.kernel.org>; Mon,  5 Nov 2018 04:48:28 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 3515820685
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=us.ibm.com
Authentication-Results: mail.kernel.org; spf=none smtp.mailfrom=linux-nfs-owner@vger.kernel.org
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1728870AbeKEOGK convert rfc822-to-8bit (ORCPT
        <rfc822;linux-nfs@archiver.kernel.org>);
        Mon, 5 Nov 2018 09:06:10 -0500
Received: from mx0b-001b2d01.pphosted.com ([148.163.158.5]:45922 "EHLO
        mx0a-001b2d01.pphosted.com" rhost-flags-OK-OK-OK-FAIL)
        by vger.kernel.org with ESMTP id S1728165AbeKEOGK (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Mon, 5 Nov 2018 09:06:10 -0500
Received: from pps.filterd (m0098421.ppops.net [127.0.0.1])
        by mx0a-001b2d01.pphosted.com (8.16.0.22/8.16.0.22) with SMTP id wA54cqKo143978
        for <linux-nfs@vger.kernel.org>; Sun, 4 Nov 2018 23:48:26 -0500
Received: from smtp.notes.na.collabserv.com (smtp.notes.na.collabserv.com [192.155.248.90])
        by mx0a-001b2d01.pphosted.com with ESMTP id 2njab2gg91-1
        (version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=NOT)
        for <linux-nfs@vger.kernel.org>; Sun, 04 Nov 2018 23:48:26 -0500
Received: from localhost
        by smtp.notes.na.collabserv.com with smtp.notes.na.collabserv.com ESMTP
        for <linux-nfs@vger.kernel.org> from <eshel@us.ibm.com>;
        Mon, 5 Nov 2018 04:48:25 -0000
Received: from us1a3-smtp06.a3.dal06.isc4sb.com (10.146.103.243)
        by smtp.notes.na.collabserv.com (10.106.227.141) with smtp.notes.na.collabserv.com ESMTP;
        Mon, 5 Nov 2018 04:48:19 -0000
Received: from us1a3-mail148.a3.dal06.isc4sb.com ([10.146.38.117])
          by us1a3-smtp06.a3.dal06.isc4sb.com
          with ESMTP id 2018110504481883-153980 ;
          Mon, 5 Nov 2018 04:48:18 +0000 
In-Reply-To: <87sh0gz7mt.fsf@notabene.neil.brown.name>
To:     NeilBrown <neilb@suse.com>
Cc:     "bcodding\@redhat.com" <bcodding@redhat.com>,
        "linux-nfs\@vger.kernel.org" <linux-nfs@vger.kernel.org>,
        linux-nfs-owner@vger.kernel.org,
        "malahal\@gmail.com" <malahal@gmail.com>,
        "mbenjami\@redhat.com" <mbenjami@redhat.com>,
        "Trond Myklebust" <trondmy@hammerspace.com>
Subject: Re: "(deleted)" directories
From:   "Marc Eshel" <eshel@us.ibm.com>
Date:   Sun, 4 Nov 2018 20:48:18 -0800
References: <CAGD+tkyTyOb-iiykQLYMoa1h5cmizbe_0M0_HS=9cQC1NDznSw@mail.gmail.com>
 <24BEBD2F-BCC2-4AE0-81D7-185D6CAB8CD7@redhat.com>
 <CAGD+tkzyDoq6tdseFQu4ymJCc-+-2i6XEUmBGKe4mu4_ngv7QA@mail.gmail.com>
 <435a5a0fcdbefc30201c91b0a36b6159f6df32eb.camel@hammerspace.com>
 <CAKOnarkG4tpA7F306hgpk14XNELEFY1gaY7=QY4h6Dr-zSQzRw@mail.gmail.com>
 <a45a428ad45e5834fa7030088a75275584b13ab2.camel@hammerspace.com>
 <OF63D29519.B9156C69-ON8825833A.000DEE9B-8825833A.000E8123@notes.na.collabserv.com>
 <87a7mp1k9a.fsf@notabene.neil.brown.name>
 <OFEF532072.6C501ABB-ON8825833B.006B930A-8825833B.006CB5D7@notes.na.collabserv.com>
 <87sh0gz7mt.fsf@notabene.neil.brown.name>
MIME-Version: 1.0
X-KeepSent: 273E51BC:1E5F740F-8825833C:0019963F;
 type=4; name=$KeepSent
X-Mailer: IBM Notes Release 9.0.1EXT SHF766 December 14, 2016
X-LLNOutbound: False
X-Disclaimed: 48839
X-TNEFEvaluated: 1
x-cbid: 18110504-9717-0000-0000-000009DEC152
X-IBM-SpamModules-Scores: BY=0; FL=0; FP=0; FZ=0; HX=0; KW=0; PH=0;
 SC=0.365752; ST=0; TS=0; UL=0; ISC=; MB=0.374749
X-IBM-SpamModules-Versions: BY=3.00009973; HX=3.00000242; KW=3.00000007;
 PH=3.00000004; SC=3.00000268; SDB=6.01111999; UDB=6.00576316; IPR=6.00892090;
 BA=6.00000000; NDR=6.00000000; ZLA=6.00000000; ZF=6.00000000; ZB=6.00000000;
 ZP=6.00000000; ZH=6.00000000; ZU=6.00000000; MB=3.00024008; XFM=3.00000015;
 UTC=2018-11-05 04:48:24
X-IBM-AV-DETECTION: SAVI=unsuspicious REMOTE=unsuspicious XFE=unused
X-IBM-AV-VERSION: SAVI=2018-11-03 07:02:04 - 6.00009172
x-cbparentid: 18110504-9718-0000-0000-00002E6AD547
Message-Id: <OF273E51BC.1E5F740F-ON8825833C.0019963F-8825833C.001A653C@notes.na.collabserv.com>
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 8BIT
X-Proofpoint-Virus-Version: vendor=fsecure engine=2.50.10434:,, definitions=2018-11-05_03:,,
 signatures=0
X-Proofpoint-Spam-Reason: safe
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

This thread got split, Malahal is trying to resolve a specific problem and 
he know much more about it so I will butt out and let him continue to 
drive his thread. 
Marc.



From:   NeilBrown <neilb@suse.com>
To:     Marc Eshel <eshel@us.ibm.com>
Cc:     "bcodding\@redhat.com" <bcodding@redhat.com>, 
"linux-nfs\@vger.kernel.org" <linux-nfs@vger.kernel.org>, 
linux-nfs-owner@vger.kernel.org, "malahal\@gmail.com" <malahal@gmail.com>, 
"mbenjami\@redhat.com" <mbenjami@redhat.com>, "Trond Myklebust" 
<trondmy@hammerspace.com>
Date:   11/04/2018 04:33 PM
Subject:        Re: "(deleted)" directories
Sent by:        linux-nfs-owner@vger.kernel.org



On Sun, Nov 04 2018, Marc Eshel wrote:

> linux-nfs-owner@vger.kernel.org wrote on 11/03/2018 10:31:29 PM:
>
>> From: NeilBrown <neilb@suse.com>
>> To: Marc Eshel <eshel@us.ibm.com>, Trond Myklebust 
> <trondmy@hammerspace.com>
>> Cc: "bcodding\@redhat.com" <bcodding@redhat.com>, "linux-nfs
>> \@vger.kernel.org" <linux-nfs@vger.kernel.org>, linux-nfs-
>> owner@vger.kernel.org, "malahal\@gmail.com" <malahal@gmail.com>, 
>> "mbenjami\@redhat.com" <mbenjami@redhat.com>
>> Date: 11/03/2018 10:41 PM
>> Subject: Re: "(deleted)" directories
>> Sent by: linux-nfs-owner@vger.kernel.org
>> 
>> On Fri, Nov 02 2018, Marc Eshel wrote:
>> 
>> > One reason to have different FHs for the same file is that a file can 

> be 
>> > linked from multiple directories.
>> 
>> This has some based when considering filehandles for non-directories.
>> However the original problem was with filehandles for directories.....
>
> This was just an example of why FH might be different, I don't think we 
> depend on it for the parent information anymore. Malahal listed some 
other 
> reasons for having different FH for the same file. I believe that 
Ganesha 
> split the FH to the key portion (the unique id of the file) and some 
other 
> information that is file system dependent. If the NFS client can not 
> handle the spec definition of FH maybe the spec should be updated to 
> something like Ganesha does.
> Marc. 

Do we know exactly why the FH changed in this particular circumstance?
Is there some way to find out?

The NFSv3 spec has been updated - it is called "NFSv4" (now 4.2).  It
says a lot more things about filehandles, but even there, the spec is
only as good as the what has been implemented and tested.  I'm pretty
sure that there are parts of the FH spec that have never been put into
practice - so using them would not be wise (I'm particularly thinking of
volatile file handles).

For better or worse, Linux requires directories to have stable
filehandles for NFSv3.  This requirement is effectively imposed by the
dcache.  If there were some way to reliably check if two filehandles
referred to the same directory, then we could relax that restriction,
but I don't think there is.

I think the other possible reason mentioned for changing the filehandle
is to support migration.  NFSv3 definitely doesn't support migration.
NFSv4 explicitly tries to.

NeilBrown


>
>> 
>> > Adding the parent inode to the FH help finding the the name of the 
> file by 
>> > looking for the file inode in
>> > the parent directoy.
>> >
>> 
>> ....and directories have a ".." link, obviating the need to store 
parent
>> information in the filehandle.
>> 
>> NeilBrown
>> 
>> 
>> > Marc.
>> >
>> > linux-nfs-owner@vger.kernel.org wrote on 11/02/2018 05:15:42 PM:
>> >
>> >> From: Trond Myklebust <trondmy@hammerspace.com>
>> >> To: "mbenjami@redhat.com" <mbenjami@redhat.com>
>> >> Cc: "bcodding@redhat.com" <bcodding@redhat.com>, "malahal@gmail.com"
>> >> <malahal@gmail.com>, "linux-nfs@vger.kernel.org" 
>> > <linux-nfs@vger.kernel.org>
>> >> Date: 11/02/2018 05:15 PM
>> >> Subject: Re: "(deleted)" directories
>> >> Sent by: linux-nfs-owner@vger.kernel.org
>> >> 
>> >> On Fri, 2018-11-02 at 18:07 -0400, Matt Benjamin wrote:
>> >> > It sounds like a pretty good one, that goes to the heart of what a
>> >> > specification is
>> >> > 
>> >> 
>> >> While admittedly it is (still) Dia de los Muertos today, I would 
> think
>> >> that someone who resurrected a part of the NFSv3 spec that has been
>> >> unused for the full 23 years of its existence might have some
>> >> explanation for why they did so?
>> >> 
>> >> IOW: not being of a particularly religious persuasion, I usually 
want
>> >> to understand why features are needed rather than having blind faith 

> in
>> >> the person who wrote the spec.
>> >> 
>> >> > Matt
>> >> > 
>> >> > On Fri, Nov 2, 2018 at 4:26 PM, Trond Myklebust <
>> >> > trondmy@hammerspace.com> wrote:
>> >> > > On Fri, 2018-11-02 at 21:24 +0530, Malahal Naineni wrote:
>> >> > > > Ben, NFSv3 RFC1813.txt states: "If two file handles from the 
> same
>> >> > > > server are equal, they must refer to the same file, but if
>> >> > > > they  are
>> >> > > > not equal, no conclusions can be drawn." Ganesha does return 
> same
>> >> > > > fileid here (inode).
>> >> > > > 
>> >> > > > In NFSv4, they have introduced "unique_handles" attribute. I
>> >> > > > don't
>> >> > > > see
>> >> > > > Linux NFS client using this at all though.
>> >> > > 
>> >> > > Why does your server need to have multiple filehandles refer to 
> the
>> >> > > same file, and why do you expect clients to support this?
>> >> > > 
>> >> > > Yes, the spec allows it, but that's not a sufficient reason.
>> >> > > 
>> >> > > > Regards, Malahal.
>> >> > > > On Fri, Nov 2, 2018 at 4:35 PM Benjamin Coddington <
>> >> > > > bcodding@redhat.com> wrote:
>> >> > > > > On 2 Nov 2018, at 1:26, Malahal Naineni wrote:
>> >> > > > > 
>> >> > > > > > Hi All, we are using NFS-Ganesha with Linux NFS clients. 
> The
>> >> > > > > > client's
>> >> > > > > > shell reports the following. Based on lsof, the directory 
> is
>> >> > > > > > marked
>> >> > > > > > deleted. "cd to ROOT and cd to the same home directory 
> fixes
>> >> > > > > > the
>> >> > > > > > issue. The client behaves as though the directory is 
> deleted
>> >> > > > > > and
>> >> > > > > > recreated! Our NFS-Ganesha server implementation uses
>> >> > > > > > multiple
>> >> > > > > > file
>> >> > > > > > handles that point to the same object. NFS spec says this
>> >> > > > > > should
>> >> > > > > > be
>> >> > > > > > fine, but Linux NFS seems to be broken in this regard.
>> >> > > > > > tcpdump
>> >> > > > > > does
>> >> > > > > > indicate file handle change (note that all file handles 
are
>> >> > > > > > permanent,
>> >> > > > > > meaning they are valid at the server any time) around this
>> >> > > > > > issue
>> >> > > > > > time.
>> >> > > > > > 
>> >> > > > > > "shell-init: error retrieving current directory: getcwd:
>> >> > > > > > cannot
>> >> > > > > > access
>> >> > > > > > parent directories: No such file or directory"
>> >> > > > > > sh        112544            malahal  cwd       DIR
>> >> > > > > > 0,67
>> >> > > > > >      65536   45605209 /home/malahal (deleted)
>> >> > > > > > (10.120.154.42:/nfs/malahal-export/)
>> >> > > > > > 
>> >> > > > > > Function nfs_prime_dcache() seems to invalidate the dcache
>> >> > > > > > entry
>> >> > > > > > if
>> >> > > > > > nfs_same_file() returns false. nfs_same_file() does seem 
to
>> >> > > > > > return
>> >> > > > > > false with the following change, if I read it correctly, 
if
>> >> > > > > > there
>> >> > > > > > is a
>> >> > > > > > file handle change. Can this be the source of my issue? It
>> >> > > > > > seems
>> >> > > > > > that
>> >> > > > > > the client should do this only if the file handle is NOT
>> >> > > > > > valid
>> >> > > > > > (e.g.
>> >> > > > > > if it gets ESTALE), right?
>> >> > > > > > 
>> >> > > > > > The following commit seems to assume that the objects are
>> >> > > > > > different if
>> >> > > > > > they have different file handles!
>> >> > > > > > commit 7dc72d5f7a0ec97a53e126c46e2cbd2560757955
>> >> > > > > > Author: Trond Myklebust <trond.myklebust@primarydata.com>
>> >> > > > > > Date:   Thu Sep 22 13:38:52 2016 -0400
>> >> > > > > > 
>> >> > > > > >     NFS: Fix inode corruption in nfs_prime_dcache()
>> >> > > > > 
>> >> > > > > My understanding is that for NFSv3 we have to assume that
>> >> > > > > distinct
>> >> > > > > filehandles are distinct objects, but maybe I'm wrong about
>> >> > > > > this.
>> >> > > > > 
>> >> > > > > For NFSv4.x, we can follow the guidance in RFCs 5661 or 7530
>> >> > > > > section 10.3.4
>> >> > > > > to determine if the differing filehandles are the same 
> object,
>> >> > > > > specifically
>> >> > > > > the fileid recommended attribute needs to be implemented. Is
>> >> > > > > Ganesha
>> >> > > > > returning the same fileid for both filehandles?
>> >> > > > > 
>> >> > > > > Ben
>> >> > > --
>> >> > > Trond Myklebust
>> >> > > CTO, Hammerspace Inc
>> >> > > 4300 El Camino Real, Suite 105
>> >> > > Los Altos, CA 94022
>> >> > > www.hammer.space
>> >> > > 
>> >> > > 
>> >> > 
>> >> > 
>> >> -- 
>> >> Trond Myklebust
>> >> CTO, Hammerspace Inc
>> >> 4300 El Camino Real, Suite 105
>> >> Los Altos, CA 94022
>> >> www.hammer.space
>> >> 
>> >> 
>> [attachment "signature.asc" deleted by Marc Eshel/Almaden/IBM] 
[attachment "signature.asc" deleted by Marc Eshel/Almaden/IBM] 




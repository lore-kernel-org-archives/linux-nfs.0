Return-Path: <SRS0=ZVvz=NR=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS,
	URIBL_BLOCKED autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 2AACCC32789
	for <linux-nfs@archiver.kernel.org>; Tue,  6 Nov 2018 08:43:25 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 9058C20862
	for <linux-nfs@archiver.kernel.org>; Tue,  6 Nov 2018 08:43:24 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=desy.de header.i=@desy.de header.b="GNnGwXN1"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 9058C20862
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=desy.de
Authentication-Results: mail.kernel.org; spf=none smtp.mailfrom=linux-nfs-owner@vger.kernel.org
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S2387480AbeKFSH3 (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Tue, 6 Nov 2018 13:07:29 -0500
Received: from smtp-o-3.desy.de ([131.169.56.156]:56186 "EHLO smtp-o-3.desy.de"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S2387872AbeKFSH3 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Tue, 6 Nov 2018 13:07:29 -0500
Received: from smtp-buf-2.desy.de (smtp-buf-2.desy.de [131.169.56.165])
        by smtp-o-3.desy.de (DESY-O-3) with ESMTP id 4741B28039F
        for <linux-nfs@vger.kernel.org>; Tue,  6 Nov 2018 09:43:17 +0100 (CET)
DKIM-Filter: OpenDKIM Filter v2.11.0 smtp-o-3.desy.de 4741B28039F
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=desy.de; s=default;
        t=1541493797; bh=qSJ+bjJg7L0irnOI8zt/qj61XdHwQx69ukk3fn3u0HA=;
        h=Date:From:To:Cc:In-Reply-To:References:Subject:From;
        b=GNnGwXN1GoApWBTkjBVOO7rLCwujEEkZtgCoO3tbK1kSxuxC0qHlsPUuzQcFEFc9K
         ONKnwxZvdpieuETixr0sPaZGAuPrsbzl1xHhoU4tYQks092rrm7rmv6JfyKZ4zKH9N
         tw0XsJdH1v0laRNJqGNHpC1ma95xoIaXlYC0fRcE=
Received: from smtp-m-2.desy.de (smtp-m-2.desy.de [IPv6:2001:638:700:1038::1:82])
        by smtp-buf-2.desy.de (Postfix) with ESMTP id 3D2C21A00BF;
        Tue,  6 Nov 2018 09:43:17 +0100 (CET)
X-Virus-Scanned: amavisd-new at desy.de
Received: from z-mbx-2.desy.de (z-mbx-2.desy.de [131.169.55.140])
        by smtp-intra-3.desy.de (DESY-INTRA-3) with ESMTP id E4C401029;
        Tue,  6 Nov 2018 09:43:16 +0100 (MET)
Date:   Tue, 6 Nov 2018 09:43:16 +0100 (CET)
From:   "Mkrtchyan, Tigran" <tigran.mkrtchyan@desy.de>
To:     Malahal Naineni <malahal@gmail.com>
Cc:     NeilBrown <neilb@suse.com>, Marc Eshel <eshel@us.ibm.com>,
        Benjamin Coddington <bcodding@redhat.com>,
        linux-nfs <linux-nfs@vger.kernel.org>,
        linux-nfs-owner@vger.kernel.org,
        Matt Benjamin <mbenjami@redhat.com>,
        trondmy <trondmy@hammerspace.com>, bill.baker@oracle.com
Message-ID: <2003075164.16045771.1541493796820.JavaMail.zimbra@desy.de>
In-Reply-To: <CAGD+tkw5QqZet6n82NavneWK8-_uHo24muxYPj+gqrY=tbk2yA@mail.gmail.com>
References: <CAGD+tkyTyOb-iiykQLYMoa1h5cmizbe_0M0_HS=9cQC1NDznSw@mail.gmail.com> <OF63D29519.B9156C69-ON8825833A.000DEE9B-8825833A.000E8123@notes.na.collabserv.com> <87a7mp1k9a.fsf@notabene.neil.brown.name> <OFEF532072.6C501ABB-ON8825833B.006B930A-8825833B.006CB5D7@notes.na.collabserv.com> <87sh0gz7mt.fsf@notabene.neil.brown.name> <CAGD+tkwz_HvBmjwQgLbftf6qU-pL75SJ6a1zq_P239eXMOUDgg@mail.gmail.com> <87muqoyutl.fsf@notabene.neil.brown.name> <CAGD+tkw5QqZet6n82NavneWK8-_uHo24muxYPj+gqrY=tbk2yA@mail.gmail.com>
Subject: Re: "(deleted)" directories
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
X-Mailer: Zimbra 8.7.11_GA_1854 (ZimbraWebClient - FF63 (Linux)/8.7.11_GA_1854)
Thread-Topic: "(deleted)" directories
Thread-Index: xt+QHo3wE+xRqjN7Ng+Ud5JS0mOjiQ==
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org



----- Original Message -----
> From: "Malahal Naineni" <malahal@gmail.com>
> To: "NeilBrown" <neilb@suse.com>
> Cc: "Marc Eshel" <eshel@us.ibm.com>, "Benjamin Coddington" <bcodding@redhat.com>, "linux-nfs"
> <linux-nfs@vger.kernel.org>, linux-nfs-owner@vger.kernel.org, "Matt Benjamin" <mbenjami@redhat.com>, "trondmy"
> <trondmy@hammerspace.com>
> Sent: Monday, November 5, 2018 8:40:16 AM
> Subject: Re: "(deleted)" directories

>>> My reading of section 10.3.4 of RFC7530 suggests that the client should
> generally compare fsid and fileid to see if two different filehandles refer to
> the same object or not.
> 
> Section 10.3.4 is for files only correct? The issue here is for
> directories. Also, Trond clearly pointed that Linux breaks section
> 10.3.4 from his email stating "We treat always different filehandles
> as if they refer to different
> files. It has long been the case that snapshots from several vendors
> are encoded to look like the same file (same fileid + same  fsid) and
> differing only by filehandle. If we were to try to consolidate those
> inodes we would end up corrupting application data."
> 
> We don't respect either NFSv3 or NFSv4 RFCs in this regard!


In general, you are right. The spec is our source of truth. However,
I wouldn't rely on any word in the rfc if it wasn't implemented and
tested by various client and server implementations (this is IETF requirement!).
That's why we run multiple bake-a-thons and connectathons. Moreover,
from my experience of having outsider server implementation I can say,
that even if desired change end-up in upstream kernel, there are clients
around that don't support that functionality and will force you to solve
have a solutionin the server side.

BTW, at the one of the connectathons, Bill Baker from Oracle was telling
about migration implementation on Solaris server. And one of the issues
that thy suffer from was that file handles was in host native format and
they had a problems in migration from SPARC to x64. I am supersized, that
you run into the same issue.

Regards,
   Tigran.

> 
> Regards, Malahal.
> 
> 
> Regards, Malahal.
> On Mon, Nov 5, 2018 at 10:39 AM NeilBrown <neilb@suse.com> wrote:
>>
>> On Mon, Nov 05 2018, Malahal Naineni wrote:
>>
>> >> Do we know exactly why the FH changed in this particular circumstance?
>> >
>> > In this instance, this is due to a code bug but obviously, there are
>> > legitimate cases where this occur with Ganesha.
>>
>> Good to know that bug has been found, and presumably fixed.
>> It is not obvious to me that there are any such legitimate cases for
>> directories.
>>
>> >
>> >> (I'm particularly thinking of volatile file handles).
>> >
>> > NFS4 RFC has "unique filehandles" concept as well. Linux NFS client
>> > doesn't seem to use "unique filehandles" attribute as well.
>>
>> A client doesn't need to use that attribute.
>> My reading of section 10.3.4 of RFC7530 suggests that the client should
>> generally compare fsid and fileid to see if two different filehandles refer to
>> the same object or not.
>> If unique_handles is known to be set for a given fsid, then different
>> filehandles imply different files, without bothering to check the
>> fileid.
>> So the use of unique_handles is an optimization.
>>
>> I haven't looked at the Linux/NFS code to see if it conforms to 10.3.4.
>>
>> NeilBrown
>>
>>
>> >
>> > On Mon, Nov 5, 2018 at 6:02 AM NeilBrown <neilb@suse.com> wrote:
>> >>
>> >> On Sun, Nov 04 2018, Marc Eshel wrote:
>> >>
>> >> > linux-nfs-owner@vger.kernel.org wrote on 11/03/2018 10:31:29 PM:
>> >> >
>> >> >> From: NeilBrown <neilb@suse.com>
>> >> >> To: Marc Eshel <eshel@us.ibm.com>, Trond Myklebust
>> >> > <trondmy@hammerspace.com>
>> >> >> Cc: "bcodding\@redhat.com" <bcodding@redhat.com>, "linux-nfs
>> >> >> \@vger.kernel.org" <linux-nfs@vger.kernel.org>, linux-nfs-
>> >> >> owner@vger.kernel.org, "malahal\@gmail.com" <malahal@gmail.com>,
>> >> >> "mbenjami\@redhat.com" <mbenjami@redhat.com>
>> >> >> Date: 11/03/2018 10:41 PM
>> >> >> Subject: Re: "(deleted)" directories
>> >> >> Sent by: linux-nfs-owner@vger.kernel.org
>> >> >>
>> >> >> On Fri, Nov 02 2018, Marc Eshel wrote:
>> >> >>
>> >> >> > One reason to have different FHs for the same file is that a file can
>> >> > be
>> >> >> > linked from multiple directories.
>> >> >>
>> >> >> This has some based when considering filehandles for non-directories.
>> >> >> However the original problem was with filehandles for directories.....
>> >> >
>> >> > This was just an example of why FH might be different, I don't think we
>> >> > depend on it for the parent information anymore. Malahal listed some other
>> >> > reasons for having different FH for the same file. I believe that Ganesha
>> >> > split the FH to the key portion (the unique id of the file) and some other
>> >> > information that is file system dependent. If the NFS client can not
>> >> > handle the spec definition of FH maybe the spec should be updated to
>> >> > something like Ganesha does.
>> >> > Marc.
>> >>
>> >> Do we know exactly why the FH changed in this particular circumstance?
>> >> Is there some way to find out?
>> >>
>> >> The NFSv3 spec has been updated - it is called "NFSv4" (now 4.2).  It
>> >> says a lot more things about filehandles, but even there, the spec is
>> >> only as good as the what has been implemented and tested.  I'm pretty
>> >> sure that there are parts of the FH spec that have never been put into
>> >> practice - so using them would not be wise (I'm particularly thinking of
>> >> volatile file handles).
>> >>
>> >> For better or worse, Linux requires directories to have stable
>> >> filehandles for NFSv3.  This requirement is effectively imposed by the
>> >> dcache.  If there were some way to reliably check if two filehandles
>> >> referred to the same directory, then we could relax that restriction,
>> >> but I don't think there is.
>> >>
>> >> I think the other possible reason mentioned for changing the filehandle
>> >> is to support migration.  NFSv3 definitely doesn't support migration.
>> >> NFSv4 explicitly tries to.
>> >>
>> >> NeilBrown
>> >>
>> >>
>> >> >
>> >> >>
>> >> >> > Adding the parent inode to the FH help finding the the name of the
>> >> > file by
>> >> >> > looking for the file inode in
>> >> >> > the parent directoy.
>> >> >> >
>> >> >>
>> >> >> ....and directories have a ".." link, obviating the need to store parent
>> >> >> information in the filehandle.
>> >> >>
>> >> >> NeilBrown
>> >> >>
>> >> >>
>> >> >> > Marc.
>> >> >> >
>> >> >> > linux-nfs-owner@vger.kernel.org wrote on 11/02/2018 05:15:42 PM:
>> >> >> >
>> >> >> >> From: Trond Myklebust <trondmy@hammerspace.com>
>> >> >> >> To: "mbenjami@redhat.com" <mbenjami@redhat.com>
>> >> >> >> Cc: "bcodding@redhat.com" <bcodding@redhat.com>, "malahal@gmail.com"
>> >> >> >> <malahal@gmail.com>, "linux-nfs@vger.kernel.org"
>> >> >> > <linux-nfs@vger.kernel.org>
>> >> >> >> Date: 11/02/2018 05:15 PM
>> >> >> >> Subject: Re: "(deleted)" directories
>> >> >> >> Sent by: linux-nfs-owner@vger.kernel.org
>> >> >> >>
>> >> >> >> On Fri, 2018-11-02 at 18:07 -0400, Matt Benjamin wrote:
>> >> >> >> > It sounds like a pretty good one, that goes to the heart of what a
>> >> >> >> > specification is
>> >> >> >> >
>> >> >> >>
>> >> >> >> While admittedly it is (still) Dia de los Muertos today, I would
>> >> > think
>> >> >> >> that someone who resurrected a part of the NFSv3 spec that has been
>> >> >> >> unused for the full 23 years of its existence might have some
>> >> >> >> explanation for why they did so?
>> >> >> >>
>> >> >> >> IOW: not being of a particularly religious persuasion, I usually want
>> >> >> >> to understand why features are needed rather than having blind faith
>> >> > in
>> >> >> >> the person who wrote the spec.
>> >> >> >>
>> >> >> >> > Matt
>> >> >> >> >
>> >> >> >> > On Fri, Nov 2, 2018 at 4:26 PM, Trond Myklebust <
>> >> >> >> > trondmy@hammerspace.com> wrote:
>> >> >> >> > > On Fri, 2018-11-02 at 21:24 +0530, Malahal Naineni wrote:
>> >> >> >> > > > Ben, NFSv3 RFC1813.txt states: "If two file handles from the
>> >> > same
>> >> >> >> > > > server are equal, they must refer to the same file, but if
>> >> >> >> > > > they  are
>> >> >> >> > > > not equal, no conclusions can be drawn." Ganesha does return
>> >> > same
>> >> >> >> > > > fileid here (inode).
>> >> >> >> > > >
>> >> >> >> > > > In NFSv4, they have introduced "unique_handles" attribute. I
>> >> >> >> > > > don't
>> >> >> >> > > > see
>> >> >> >> > > > Linux NFS client using this at all though.
>> >> >> >> > >
>> >> >> >> > > Why does your server need to have multiple filehandles refer to
>> >> > the
>> >> >> >> > > same file, and why do you expect clients to support this?
>> >> >> >> > >
>> >> >> >> > > Yes, the spec allows it, but that's not a sufficient reason.
>> >> >> >> > >
>> >> >> >> > > > Regards, Malahal.
>> >> >> >> > > > On Fri, Nov 2, 2018 at 4:35 PM Benjamin Coddington <
>> >> >> >> > > > bcodding@redhat.com> wrote:
>> >> >> >> > > > > On 2 Nov 2018, at 1:26, Malahal Naineni wrote:
>> >> >> >> > > > >
>> >> >> >> > > > > > Hi All, we are using NFS-Ganesha with Linux NFS clients.
>> >> > The
>> >> >> >> > > > > > client's
>> >> >> >> > > > > > shell reports the following. Based on lsof, the directory
>> >> > is
>> >> >> >> > > > > > marked
>> >> >> >> > > > > > deleted. "cd to ROOT and cd to the same home directory
>> >> > fixes
>> >> >> >> > > > > > the
>> >> >> >> > > > > > issue. The client behaves as though the directory is
>> >> > deleted
>> >> >> >> > > > > > and
>> >> >> >> > > > > > recreated! Our NFS-Ganesha server implementation uses
>> >> >> >> > > > > > multiple
>> >> >> >> > > > > > file
>> >> >> >> > > > > > handles that point to the same object. NFS spec says this
>> >> >> >> > > > > > should
>> >> >> >> > > > > > be
>> >> >> >> > > > > > fine, but Linux NFS seems to be broken in this regard.
>> >> >> >> > > > > > tcpdump
>> >> >> >> > > > > > does
>> >> >> >> > > > > > indicate file handle change (note that all file handles are
>> >> >> >> > > > > > permanent,
>> >> >> >> > > > > > meaning they are valid at the server any time) around this
>> >> >> >> > > > > > issue
>> >> >> >> > > > > > time.
>> >> >> >> > > > > >
>> >> >> >> > > > > > "shell-init: error retrieving current directory: getcwd:
>> >> >> >> > > > > > cannot
>> >> >> >> > > > > > access
>> >> >> >> > > > > > parent directories: No such file or directory"
>> >> >> >> > > > > > sh        112544            malahal  cwd       DIR
>> >> >> >> > > > > > 0,67
>> >> >> >> > > > > >      65536   45605209 /home/malahal (deleted)
>> >> >> >> > > > > > (10.120.154.42:/nfs/malahal-export/)
>> >> >> >> > > > > >
>> >> >> >> > > > > > Function nfs_prime_dcache() seems to invalidate the dcache
>> >> >> >> > > > > > entry
>> >> >> >> > > > > > if
>> >> >> >> > > > > > nfs_same_file() returns false. nfs_same_file() does seem to
>> >> >> >> > > > > > return
>> >> >> >> > > > > > false with the following change, if I read it correctly, if
>> >> >> >> > > > > > there
>> >> >> >> > > > > > is a
>> >> >> >> > > > > > file handle change. Can this be the source of my issue? It
>> >> >> >> > > > > > seems
>> >> >> >> > > > > > that
>> >> >> >> > > > > > the client should do this only if the file handle is NOT
>> >> >> >> > > > > > valid
>> >> >> >> > > > > > (e.g.
>> >> >> >> > > > > > if it gets ESTALE), right?
>> >> >> >> > > > > >
>> >> >> >> > > > > > The following commit seems to assume that the objects are
>> >> >> >> > > > > > different if
>> >> >> >> > > > > > they have different file handles!
>> >> >> >> > > > > > commit 7dc72d5f7a0ec97a53e126c46e2cbd2560757955
>> >> >> >> > > > > > Author: Trond Myklebust <trond.myklebust@primarydata.com>
>> >> >> >> > > > > > Date:   Thu Sep 22 13:38:52 2016 -0400
>> >> >> >> > > > > >
>> >> >> >> > > > > >     NFS: Fix inode corruption in nfs_prime_dcache()
>> >> >> >> > > > >
>> >> >> >> > > > > My understanding is that for NFSv3 we have to assume that
>> >> >> >> > > > > distinct
>> >> >> >> > > > > filehandles are distinct objects, but maybe I'm wrong about
>> >> >> >> > > > > this.
>> >> >> >> > > > >
>> >> >> >> > > > > For NFSv4.x, we can follow the guidance in RFCs 5661 or 7530
>> >> >> >> > > > > section 10.3.4
>> >> >> >> > > > > to determine if the differing filehandles are the same
>> >> > object,
>> >> >> >> > > > > specifically
>> >> >> >> > > > > the fileid recommended attribute needs to be implemented.  Is
>> >> >> >> > > > > Ganesha
>> >> >> >> > > > > returning the same fileid for both filehandles?
>> >> >> >> > > > >
>> >> >> >> > > > > Ben
>> >> >> >> > > --
>> >> >> >> > > Trond Myklebust
>> >> >> >> > > CTO, Hammerspace Inc
>> >> >> >> > > 4300 El Camino Real, Suite 105
>> >> >> >> > > Los Altos, CA 94022
>> >> >> >> > > www.hammer.space
>> >> >> >> > >
>> >> >> >> > >
>> >> >> >> >
>> >> >> >> >
>> >> >> >> --
>> >> >> >> Trond Myklebust
>> >> >> >> CTO, Hammerspace Inc
>> >> >> >> 4300 El Camino Real, Suite 105
>> >> >> >> Los Altos, CA 94022
>> >> >> >> www.hammer.space
>> >> >> >>
>> >> >> >>
> > >> >> [attachment "signature.asc" deleted by Marc Eshel/Almaden/IBM]

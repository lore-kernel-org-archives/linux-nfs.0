Return-Path: <SRS0=6MPh=RA=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,HK_RANDOM_FROM,MAILING_LIST_MULTI,
	SPF_PASS,URIBL_BLOCKED autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id A97D7C43381
	for <linux-nfs@archiver.kernel.org>; Mon, 25 Feb 2019 08:49:42 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 4BA912087C
	for <linux-nfs@archiver.kernel.org>; Mon, 25 Feb 2019 08:49:42 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=desy.de header.i=@desy.de header.b="UMrpLsiy"
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1726180AbfBYItl (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Mon, 25 Feb 2019 03:49:41 -0500
Received: from smtp-o-1.desy.de ([131.169.56.154]:41823 "EHLO smtp-o-1.desy.de"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1725863AbfBYItl (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Mon, 25 Feb 2019 03:49:41 -0500
Received: from smtp-buf-1.desy.de (smtp-buf-1.desy.de [131.169.56.164])
        by smtp-o-1.desy.de (DESY-O-1) with ESMTP id 9C9F5280663
        for <linux-nfs@vger.kernel.org>; Mon, 25 Feb 2019 09:49:37 +0100 (CET)
DKIM-Filter: OpenDKIM Filter v2.11.0 smtp-o-1.desy.de 9C9F5280663
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=desy.de; s=default;
        t=1551084577; bh=f7x3qrAgta0jbMTkNr8/tmftq3i3AVbqvMJjGoTyjPc=;
        h=Date:From:To:Cc:In-Reply-To:References:Subject:From;
        b=UMrpLsiyNEhNYzGKeBVY+Z1HqvB0KnbSgQAYlaLIJy/3RXK5XiRS7X6OcuriN2V6m
         D00sk5BEwE8ozD6Bsr4hUmEkp/5mqlxSV85DefY3xZ7EP/GT8iREue3qoiCc9De88U
         iGRg/isd/1k5aF+WcAFq7HUo/XDfWTKMjSL5nUtI=
Received: from smtp-m-1.desy.de (smtp-m-1.desy.de [131.169.56.129])
        by smtp-buf-1.desy.de (Postfix) with ESMTP id 93D6F1201DE;
        Mon, 25 Feb 2019 09:49:37 +0100 (CET)
X-Virus-Scanned: amavisd-new at desy.de
Received: from z-mbx-2.desy.de (z-mbx-2.desy.de [131.169.55.140])
        by smtp-intra-3.desy.de (DESY-INTRA-3) with ESMTP id 5D2301121;
        Mon, 25 Feb 2019 09:49:37 +0100 (MET)
Date:   Mon, 25 Feb 2019 09:49:37 +0100 (CET)
From:   "Mkrtchyan, Tigran" <tigran.mkrtchyan@desy.de>
To:     Dave Noveck <davenoveck@gmail.com>
Cc:     Marc Eshel <eshel@us.ibm.com>,
        linux-nfs <linux-nfs@vger.kernel.org>,
        Ganesha-devel <devel@lists.nfs-ganesha.org>,
        NFSv4 <nfsv4@ietf.org>,
        linux-nfs-owner <linux-nfs-owner@vger.kernel.org>
Message-ID: <741516773.7109032.1551084577150.JavaMail.zimbra@desy.de>
In-Reply-To: <CADaq8jfT=nxmVPz4mDRFAaOx36uxWqKbxitqS-YH3GCOs4CsrQ@mail.gmail.com>
References: <155049372736.14318.3390584694682770373.idtracker@ietfa.amsl.com> <CADaq8je2Ap4oAZAPOguaWctUs8dQ=Q9g=TO39EOiJW5EJSFTGg@mail.gmail.com> <OFE5A6CD32.4DC48078-ON882583A9.007FB4BC-882583A9.0080ACAC@notes.na.collabserv.com> <CADaq8jfT=nxmVPz4mDRFAaOx36uxWqKbxitqS-YH3GCOs4CsrQ@mail.gmail.com>
Subject: Re: [nfsv4] file size and getattr
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
X-Mailer: Zimbra 8.8.10_GA_3713 (ZimbraWebClient - FF65 (Linux)/8.8.10_GA_3041)
Thread-Topic: file size and getattr
Thread-Index: xB45BipLgBZpsCd+0L6G4OWR1hcJRg==
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org



----- Original Message -----
> From: "Dave Noveck" <davenoveck@gmail.com>
> To: "Marc Eshel" <eshel@us.ibm.com>
> Cc: "linux-nfs" <linux-nfs@vger.kernel.org>, "Ganesha-devel" <devel@lists.nfs-ganesha.org>, "NFSv4" <nfsv4@ietf.org>,
> "linux-nfs-owner" <linux-nfs-owner@vger.kernel.org>
> Sent: Saturday, February 23, 2019 12:38:56 AM
> Subject: Re: [nfsv4] file size and getattr

>> Does the NFSv4 spec allows the server to return file size that doesn't
>> include the unstable write to the writer or any other NFS client?
> 
> I would say "no".   Consider the followiing sentence in the description of
> COMMIT.
> 

I would say "yes". Let's have a look at LAYOUTCOMMIT. Spec says:

"The metadata server may
   use this information to determine whether the file's size needs to be
   updated.  If the metadata server updates the file's size as the
   result of the LAYOUTCOMMIT operation, it must return the new size
   (locr_newsize.ns_size) as part of the results."

I read this as: Metadata server may not know real file size until client sends
the file size information. Our DSes return DATA_SYNC and relay on client to
issue LAYOUTCOMMIT to update file size (well, on close we force data servers
up update file anyway).

Tigran. 


>> If the count is zero, a flush from the offset to the end of the file is
> done.
> 
> Note that he size returned by GETATTR gives you the end of the file so
> that, if it did not
> reflect the unstable writes, COMMIT wouldn't work right.
> 
> On Fri, Feb 22, 2019 at 6:25 PM Marc Eshel <eshel@us.ibm.com> wrote:
> 
>> What is the file size returned by the NFS server for getattr after an
>> unstable write to the NFS client that did the write or to other NFS
>> clients.
>>
>> As far as I know most file systems will always return the file size that
>> includes the unstable writes.
>>
>> Does the NFSv4 spec allows the server to return file size that doesn't
>> include the unstable write to the writer or any other NFS client?
>>
>> Marc.
>>
>>
> 
> _______________________________________________
> nfsv4 mailing list
> nfsv4@ietf.org
> https://www.ietf.org/mailman/listinfo/nfsv4

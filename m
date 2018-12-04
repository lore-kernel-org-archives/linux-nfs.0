Return-Path: <SRS0=juBO=ON=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id C83C4C04EB8
	for <linux-nfs@archiver.kernel.org>; Tue,  4 Dec 2018 22:14:44 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 784B32082B
	for <linux-nfs@archiver.kernel.org>; Tue,  4 Dec 2018 22:14:44 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 784B32082B
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=none smtp.mailfrom=linux-nfs-owner@vger.kernel.org
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1725912AbeLDWOo (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Tue, 4 Dec 2018 17:14:44 -0500
Received: from mail-oi1-f180.google.com ([209.85.167.180]:38141 "EHLO
        mail-oi1-f180.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1725904AbeLDWOn (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Tue, 4 Dec 2018 17:14:43 -0500
Received: by mail-oi1-f180.google.com with SMTP id a77so15745317oii.5
        for <linux-nfs@vger.kernel.org>; Tue, 04 Dec 2018 14:14:42 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:mime-version:references:in-reply-to:from:date
         :message-id:subject:to:cc;
        bh=72OoxRAiffpk7fqY7TKK2RiOrF8a+kOQreKsyC+Fm2A=;
        b=idic0WwebWQ9R1LFOmU/oetg/Z/WFHq81eoeMR9pk5drd6H3En+JYaKnHxZQcveZXu
         5E5NhY9Zsav7yQUuIP6g6OXwyVIY/+WMKQAEg/tfFyUnLXMwqLsja+1ZjkxU0DNCzwFN
         +zS1Mxi5SdJGTJXK54CHWumPt5nijtTVsfOrnuQh69refbYLeK0y7WN9zSPZvT5sJyCO
         ex3nRa2trnFGYrU38oxxaTFsVXN7BfFJaoGjV5qXOpY+rRoWb8dDPyZNUd0rvylsVxY9
         XHAcBOQQS0Ps5SiY3ADstZPOTpGe78JIj84pSOY1spXR1qHRPIJm85r0jjkPa4HzDpv7
         /fSQ==
X-Gm-Message-State: AA+aEWYoCemNVoGoYvJwKNrp6HXgLwyv/08bQYMGtKamI26QfgfSMmBF
        sBOh8r79u2c1miLlLAOBwBSNVrRjyw2IGmOfxoKvEw==
X-Google-Smtp-Source: AFSGD/WY4P1z2VT/eJlrKtx1/TW/bLGT770/oHMO2ldZVEQCAAAr6NDGz3FnrJmj91UuRxKc0MCti2Llvrr9xbLxOro=
X-Received: by 2002:aca:6c8b:: with SMTP id h133mr8777726oic.33.1543961682499;
 Tue, 04 Dec 2018 14:14:42 -0800 (PST)
MIME-Version: 1.0
References: <alpine.LNX.2.21.1.1811241957260.23228@winds.org>
 <20181126140730.GC27372@fieldses.org> <CAHc6FU4jup+MxRky2pmVm89L=D42E2Q35s6G-sUSUL-tmXzX-w@mail.gmail.com>
 <alpine.LNX.2.21.1.1811302156420.6541@winds.org> <20181204193912.GA3903@fieldses.org>
 <20181204195302.GB3903@fieldses.org>
In-Reply-To: <20181204195302.GB3903@fieldses.org>
From:   Andreas Gruenbacher <agruenba@redhat.com>
Date:   Tue, 4 Dec 2018 23:14:31 +0100
Message-ID: <CAHc6FU5QOw_Gy0JNRq1Box6m=n1DEBJvV6tVfzqRwAiaz2deGQ@mail.gmail.com>
Subject: Re: NFS v4.2 umask getting dropped
To:     "J. Bruce Fields" <bfields@fieldses.org>
Cc:     gandalf@winds.org, jlayton@kernel.org,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Content-Type: text/plain; charset="UTF-8"
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

On Tue, 4 Dec 2018 at 20:53, J. Bruce Fields <bfields@fieldses.org> wrote:
>
> On Tue, Dec 04, 2018 at 02:39:12PM -0500, J. Bruce Fields wrote:
> > On Fri, Nov 30, 2018 at 10:13:59PM -0500, Byron Stanoszek wrote:
> > > On Mon, 26 Nov 2018, Andreas Gruenbacher wrote:
> > >
> > > >On Mon, 26 Nov 2018 at 15:07, J. Bruce Fields <bfields@fieldses.org> wrote:
> > > >>
> > > >>On Sat, Nov 24, 2018 at 08:18:40PM -0500, Byron Stanoszek wrote:
> > > >>>I would like to report a problem with NFS v4.2: the umask seems to be
> > > >>>getting dropped when creating files. This works as expected when
> > > >>>connecting with a v4.1 client or any version prior.
> > > >>
> > > >>Watching the network traffic in wireshark might help determine which
> > > >>side is at fault.
> > > >
> > > >Right, a network dump (tcpdump -w) of the incorrect operation(s) would
> > > >be great so that we can have a look with wireshark.
> > >
> > > Sorry for the delay. I attached the two tcpdump files from the client side. The
> > > server is 10.0.0.2 (lnxsvr1) and the client is 10.0.0.13 (burner). In both
> > > cases, I ran:
> > >
> > > mount lnxsvr1:/test -overs=4.x /ext0
> > > touch /ext0/blah
> > > umount /ext0
> > >
> > > and waited ~3 seconds between each command entry.
> >
> > Thanks!
> >
> > I looked at nfs4_2.pcap.  You can see the OPEN that creates the file in
> > frame 56.  If expand OPEN->Open Type you'll see the only attribute it's
> > setting htere is mode_umask, with mode 0666 and umask 022.
> >
> > There's a GETATTR later in the compound which queries attributes
> > including the mode.  The reply, in frame frame 57, gives 0666 for the
> > mode.
> >
> > So, that's a server bug: for some reason the server isn't applying the
> > umask it was given.
> >
> > > >In 4.2 the umask is sent in a separate attribute, in earlier versions the
> > > >umask and open mode are combined by the client and only the result is sent.
> > >
> > > Does "separate attribute" mean "future packet transmission", or is the
> > > file_create+change_mode operation still atomic? I'm concerned that if "root"
> > > creates an unexpected mode 666 file via the nfs client for a short period of
> > > time, that opens up an avenue for a non-root user on the server side to write
> > > things into the file before the nfs server processes the "umask"
> > > command/packet.
> >
> > So the mode_umask is being sent as part of the OPEN, and knfsd is
> > supposed to apply the mode and umask atomically.
> >
> > > >What filesystem type is /users/files on on lnxsvr1?
> > >
> > > reiserfs, with XATTRs disabled:
> > >
> > > CONFIG_REISERFS_FS=y
> > > # CONFIG_REISERFS_CHECK is not set
> > > # CONFIG_REISERFS_PROC_INFO is not set
> > > # CONFIG_REISERFS_FS_XATTR is not set
> >
> > OK, seems unlikely to be a reiserfs bug, but that's also something
> > that's probably doesn't get a lot of testing.
>
> Hm, OK I'll be honest I'm reluctant to devote a lot of time to debugging
> this unusual combination (reiserfs with posix acl support configured
> out), but on a quick skim it looks like reiser *might* depend on
> reiserfs_inherit_default_acl() to apply the umask, but in your case
> that's probably configured to be a dummy function that does nothing.
> And in that case the vfs should take responsibility for applying the
> umask, but that depends on SB_POSIXACL being unset on the superblock--I
> wonder if that could be set incorrectly?

I wonder if ext4 shows the same behavior with POSIX ACLs configured out?

Andreas

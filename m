Return-Path: <SRS0=4rwz=SG=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=DKIMWL_WL_MED,DKIM_SIGNED,
	DKIM_VALID,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS,
	URIBL_BLOCKED autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 5E150C4360F
	for <linux-nfs@archiver.kernel.org>; Thu,  4 Apr 2019 15:45:10 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 2F654206BA
	for <linux-nfs@archiver.kernel.org>; Thu,  4 Apr 2019 15:45:10 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=poochiereds-net.20150623.gappssmtp.com header.i=@poochiereds-net.20150623.gappssmtp.com header.b="qUreoGtO"
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1727258AbfDDPpJ (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Thu, 4 Apr 2019 11:45:09 -0400
Received: from mail-ed1-f67.google.com ([209.85.208.67]:42743 "EHLO
        mail-ed1-f67.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1726942AbfDDPpJ (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Thu, 4 Apr 2019 11:45:09 -0400
Received: by mail-ed1-f67.google.com with SMTP id x61so2649537edc.9
        for <linux-nfs@vger.kernel.org>; Thu, 04 Apr 2019 08:45:08 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=poochiereds-net.20150623.gappssmtp.com; s=20150623;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=mCHenAWmLa0eciHPCRHn1UOpdHCxo560Pc7cwWWC0Bw=;
        b=qUreoGtOq+ITfW6Arr/RYSpqFENOVkQjkqZoR5NVZdwbzyCt0quHclKSjH2jfWNqcg
         LBB30lP5N+La3vx4EOwfmoQL0dp/QG5HVNIK5a/5pW3MMLv/uAd8ikzjdIoVtcgnVvvo
         77B5bXjhAIM736BxsCfhsXzN8jBb+dJcSDOUAAUim/yJaUMiBvxbHjIzVjghoeYlapig
         67DuxlkobWsyzkgzd/luwlUIqh1HPJLl1Ljv2rr6Rpud1dJKeu+3+KNNSfhuBpZOWIM+
         M/2p6qXg+E3UK3RdF3Ts/+a6bKQntDeaeI22enta7lPOzzjMwrdMDRsM0/lkiHPhIFpc
         t6eQ==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:mime-version:references:in-reply-to:from:date
         :message-id:subject:to:cc;
        bh=mCHenAWmLa0eciHPCRHn1UOpdHCxo560Pc7cwWWC0Bw=;
        b=XzS8hE2IvreoEveOjtABXRT1QC5vbZi4T53WhioexevKleuZmfm0K2cglp0gvi24PF
         kfdH1qHs/uvcgCyZrlyryoNqawz0/Q7NoEW9xqjZ/V94iqdvn6CZ5B6h7RC3zjNYrfKi
         w697U8JB/VHfaiAFHupX+ImS0Ll4i1Qa64v0HsISmZ+usGbTWeXNOpFYS+5n5QFbBhWL
         R2HIIinmFpzq8WF8cR6w/tNBuPWvl5uS89FGjRBMHG8chRHJAtCsBR5kzi5/h55HNQUE
         /kO2mKJn5/JKW+fW/dwA0mVkxvohM5hBdcKdd9bXc47tDpL5vA+neQu8nYIducL8+1TR
         8p1g==
X-Gm-Message-State: APjAAAVsnzVaut0EtbuutuAdm7/chSnZrtWOuq9ZrviWS75jl+ytSDu3
        SpZqtwIa4fXVWO03sqc3YPE9i+/gyHfpemsb5hcUhQ==
X-Google-Smtp-Source: APXvYqz2zJ5kjHuzArXxOpcMdBOl74h9S7N+5n0HHsHOmUpqcx6HtDESn3F5nJ7/PTgLFSpbF784e1itlpNaEXgjBjQ=
X-Received: by 2002:a17:906:960a:: with SMTP id s10mr3935195ejx.141.1554392707258;
 Thu, 04 Apr 2019 08:45:07 -0700 (PDT)
MIME-Version: 1.0
References: <20190402161116.GA2828@fieldses.org> <2f1f6582-3672-1361-4392-80cb1e62e19c@oracle.com>
 <20190402194148.GA5269@fieldses.org> <58230e155813e866cb057e6543ab7e61f51fedf6.camel@hammerspace.com>
 <20190403002822.GA7667@fieldses.org> <ec8d33473da41b3bde45f5ef1b4a02b98a535ac5.camel@hammerspace.com>
 <20190403020750.GA8272@fieldses.org> <c538dd35-fd1f-bab6-1cd3-6c9639462eab@oracle.com>
 <20190404010559.GA17840@fieldses.org> <CAOhYWNLZ2OmnGo2nEegmuXOrU_ncmAwWgQSAMXxKfn3JP-UMUw@mail.gmail.com>
 <20190404153740.GB24021@fieldses.org>
In-Reply-To: <20190404153740.GB24021@fieldses.org>
From:   Jeff Layton <jlayton@poochiereds.net>
Date:   Thu, 4 Apr 2019 11:44:55 -0400
Message-ID: <CAOhYWNLYuyS19PZW+3LdP_pZQMS+nWN_+=iByW39+FVsdw8HTA@mail.gmail.com>
Subject: Re: directory delegations
To:     "bfields@fieldses.org" <bfields@fieldses.org>
Cc:     "Bradley C. Kuszmaul" <bradley.kuszmaul@oracle.com>,
        Trond Myklebust <trondmy@hammerspace.com>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Content-Type: text/plain; charset="UTF-8"
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

On Thu, Apr 4, 2019 at 11:37 AM bfields@fieldses.org
<bfields@fieldses.org> wrote:
>
> On Thu, Apr 04, 2019 at 11:09:47AM -0400, Jeff Layton wrote:
> > On Wed, Apr 3, 2019 at 9:06 PM bfields@fieldses.org <bfields@fieldses.org> wrote:
> > The serialized create with something like an untar is a
> > performance-killer though.
>
> Yes.  And Trond's proposal only allows hiding the server-to-disk round
> trip time, not the client-to-server round trip time.  On the other hand,
> it seems a lot easier than write delegations.
>
> > FWIW, I'm working on something similar right now for Ceph. If a ceph
> > client has adequate caps [1] for a directory and the dentry inode,
> > then we should (in principle) be able to buffer up directory morphing
> > operations and flush them out to the server asynchronously.
> >
> > I'm starting with unlink (mostly because it's simpler), and am mainly
> > just returning early when we do have the right caps -- after issuing
> > the call but before the reply comes in. We should be able to do the
> > same for link, rename and create too. Create will require the Ceph MDS
> > to delegate out a range of inode numbers (and that bit hasn't been
> > implemented yet).
>
> Is there some reason it's impossible for the client to return from
> create before it has an inode number?
>

Not necessarily, but you can't handle a stat() at that point until the
create returns. Also for cephfs, we can't issue data writes to the
OSDs until we know the inode number (the underlying objects are named
with the format "inode_number.chunk_index"). Cephfs works a little
like pNFS, in that we do reads and writes directly to/from the OSDs,
but the data is placed algorithmically so we know what the layout will
be if we know the inode number.

> > My thinking with all of this is that the buffering of directory
> > morphing operations is not as helpful as something like a pagecache
> > write is, as we aren't that interested in merging operations that
> > change the same dentry. However, being able to do them asynchronously
> > should work really well. That should allow us to better parallellize
> > create/link/unlink/rename on different dentries even when they are
> > issued serially by a single task.
> >
> > RFC5661 doesn't currently provide for writeable directory delegations,
> > AFAICT, but they could eventually be implemented in a similar way.
>
> People also worried about delegating create in the face of differing
> rules about case insensitivity and about which characters are legal in
> filenames.  But I really think there should be some way to manage that.
>

Oh, good god. I hadn't even considered that.

I tend to think at that point, we could just return EINVAL on a
subsequent fsync of the dir or something, and let the program sort out
what went wrong.
-- 
Jeff Layton <jlayton@poochiereds.net>

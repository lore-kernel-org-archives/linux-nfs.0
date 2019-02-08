Return-Path: <SRS0=erep=QP=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.6 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS,
	USER_AGENT_MUTT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id A88C0C169C4
	for <linux-nfs@archiver.kernel.org>; Fri,  8 Feb 2019 22:44:18 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 728E521908
	for <linux-nfs@archiver.kernel.org>; Fri,  8 Feb 2019 22:44:18 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=samba.org header.i=@samba.org header.b="nfC1hSN1"
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1726211AbfBHWoR (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Fri, 8 Feb 2019 17:44:17 -0500
Received: from hr2.samba.org ([144.76.82.148]:34036 "EHLO hr2.samba.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1726747AbfBHWoR (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Fri, 8 Feb 2019 17:44:17 -0500
X-Greylist: delayed 1892 seconds by postgrey-1.27 at vger.kernel.org; Fri, 08 Feb 2019 17:44:17 EST
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/relaxed; d=samba.org;
         s=42627210; h=Message-ID:Cc:To:From:Date;
        bh=uQ3HlU5JmJa5lpRwZaMQY+rMHoktxfevZ6c47gWks+E=; b=nfC1hSN17VzQBhkKYgFGOWVNA+
        11cnSKpPw+kZIjrCh/6g9sL2tFSfRkfmKT+HhEo96E7Tt2K4Xm1YAZ3guUShgxA55TuTihlIpZ6/F
        Z4rmWl6JAcbJxmjBhQiBZ8snKoRKyUYlomqNMLaVArwiaM3ssdVxIO1sAcDJUj2y8TEY=;
Received: from [127.0.0.2] (localhost [127.0.0.1])
        by hr2.samba.org with esmtpsa (TLS1.2:ECDHE_ECDSA_CHACHA20_POLY1305:256)
        (Exim)
        id 1gsEO2-0003Li-JA; Fri, 08 Feb 2019 22:12:42 +0000
Date:   Fri, 8 Feb 2019 14:12:39 -0800
From:   Jeremy Allison <jra@samba.org>
To:     Amir Goldstein <amir73il@gmail.com>
Cc:     "J. Bruce Fields" <bfields@fieldses.org>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>,
        Volker.Lendecke@sernet.de, Jeff Layton <jlayton@kernel.org>,
        samba-technical@lists.samba.org,
        linux-fsdevel <linux-fsdevel@vger.kernel.org>
Subject: Re: Better interop for NFS/SMB file share mode/reservation
Message-ID: <20190208221239.GA199180@jra3>
Reply-To: Jeremy Allison <jra@samba.org>
References: <CAOQ4uxjQdLrZXkpP30Pq_=Cckcb=mADrEwQUXmsG92r-gn2y5w@mail.gmail.com>
 <379106947f859bdf5db4c6f9c4ab8c44f7423c08.camel@kernel.org>
 <CAOQ4uxgewN=j3ju5MSowEvwhK1HqKG3n1hBRUQTi1W5asaO1dQ@mail.gmail.com>
 <20190208155052.GB20573@fieldses.org>
 <CAOQ4uxg9NGPRpMZt0KgH9HUKMRpn0dFta7EnP1WioRb917n4+A@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CAOQ4uxg9NGPRpMZt0KgH9HUKMRpn0dFta7EnP1WioRb917n4+A@mail.gmail.com>
User-Agent: Mutt/1.10.1 (2018-07-13)
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

On Fri, Feb 08, 2019 at 10:02:43PM +0200, Amir Goldstein via samba-technical wrote:
> On Fri, Feb 8, 2019 at 5:51 PM J. Bruce Fields <bfields@fieldses.org> wrote:
> >
> > On Fri, Feb 08, 2019 at 04:45:46PM +0200, Amir Goldstein wrote:
> > > - check_conflicting_open() is changed to use inode_is_open_for_read()
> > >   instead of checking d_count and i_count.
> >
> > Independently of the rest, I'd love to do away with those
> > d_count/i_count checks.  What's inode_is_open_for_read()?
> >
> 
> It would look maybe something like this:
> 
> static inline bool file_is_open_for_read(const struct inode *file)
> {
>         struct inode *inode = file_inode(file);
>         int countself = (file->f_mode & (FMODE_READ | FMODE_WRITE)) ==
> FMODE_READ) ? 1 : 0;
> 
>         return atomic_read(&inode->i_readcount) > countself;
> }
> 
> And it would allow for acquiring F_WRLCK lease if other
> instances of inode are open O_PATH.
> A slight change of semantics that seems harmless(?)
> and will allow some flexibility.
> 
> But if samba can't figure out a way to keep a single open file
> descriptor for oplocks per client-file, then this model doesn't
> help us make any progress.

Samba uses a single file descriptor per SMB2 open file
handle. Is this what you meant ? We need this to keep
the per-handle OFD locks around.

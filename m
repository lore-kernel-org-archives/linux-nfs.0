Return-Path: <SRS0=erep=QP=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS,USER_AGENT_MUTT autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 40F65C169C4
	for <linux-nfs@archiver.kernel.org>; Fri,  8 Feb 2019 20:16:51 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 125362177B
	for <linux-nfs@archiver.kernel.org>; Fri,  8 Feb 2019 20:16:51 +0000 (UTC)
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1727099AbfBHUQu (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Fri, 8 Feb 2019 15:16:50 -0500
Received: from fieldses.org ([173.255.197.46]:57128 "EHLO fieldses.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1726211AbfBHUQu (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Fri, 8 Feb 2019 15:16:50 -0500
Received: by fieldses.org (Postfix, from userid 2815)
        id B33091F01; Fri,  8 Feb 2019 15:16:49 -0500 (EST)
Date:   Fri, 8 Feb 2019 15:16:49 -0500
From:   "J. Bruce Fields" <bfields@fieldses.org>
To:     Amir Goldstein <amir73il@gmail.com>
Cc:     Jeff Layton <jlayton@kernel.org>, Volker.Lendecke@sernet.de,
        samba-technical@lists.samba.org,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>,
        linux-fsdevel <linux-fsdevel@vger.kernel.org>,
        Pavel Shilovsky <piastryyy@gmail.com>
Subject: Re: Better interop for NFS/SMB file share mode/reservation
Message-ID: <20190208201649.GA23657@fieldses.org>
References: <CAOQ4uxjQdLrZXkpP30Pq_=Cckcb=mADrEwQUXmsG92r-gn2y5w@mail.gmail.com>
 <379106947f859bdf5db4c6f9c4ab8c44f7423c08.camel@kernel.org>
 <CAOQ4uxgewN=j3ju5MSowEvwhK1HqKG3n1hBRUQTi1W5asaO1dQ@mail.gmail.com>
 <20190208155052.GB20573@fieldses.org>
 <CAOQ4uxg9NGPRpMZt0KgH9HUKMRpn0dFta7EnP1WioRb917n4+A@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CAOQ4uxg9NGPRpMZt0KgH9HUKMRpn0dFta7EnP1WioRb917n4+A@mail.gmail.com>
User-Agent: Mutt/1.5.21 (2010-09-15)
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

On Fri, Feb 08, 2019 at 10:02:43PM +0200, Amir Goldstein wrote:
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

How did I not know about i_readcount?  (Looking)  I guess it would mean
adding some dependence on CONFIG_IMA, hm.

--b.

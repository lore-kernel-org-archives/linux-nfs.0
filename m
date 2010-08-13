Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-ew0-f46.google.com ([209.85.215.46]:54732 "EHLO
	mail-ew0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753834Ab0HMSav convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 13 Aug 2010 14:30:51 -0400
In-Reply-To: <20100813123635.GA8945@fieldses.org>
References: <87lj8ckb1e.fsf@patl.com>
	<8762zgmmer.fsf@patl.com>
	<1281628195.2873.12.camel@heimdal.trondhjem.org>
	<AANLkTi=WzNzq7wKf0qa+VFuOBYy4yW==0QvdKsTQ88+x@mail.gmail.com>
	<1281634004.14329.14.camel@heimdal.trondhjem.org>
	<AANLkTikStDSBi2Dm0oMAEpVbE9PFZOTmOkW6Wy92wjj-@mail.gmail.com>
	<AANLkTi=OEkPuL+0E_VhPOn-U6neR=jJWunz-2DT755aB@mail.gmail.com>
	<20100813123635.GA8945@fieldses.org>
Date: Fri, 13 Aug 2010 11:30:49 -0700
Message-ID: <AANLkTimJ8y3CgAN-bXsQVoc68wGs8hnQCoKd9vw3mZzB@mail.gmail.com>
Subject: Re: [PATCH] nfs: lookupcache coherence bugs in WCC update path (revised)
From: "Patrick J. LoPresti" <lopresti@gmail.com>
To: "J. Bruce Fields" <bfields@fieldses.org>
Cc: linux-nfs@vger.kernel.org, Trond Myklebust <trond.myklebust@fys.uio.no>,
        linux-fsdevel@vger.kernel.org
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Fri, Aug 13, 2010 at 5:36 AM, J. Bruce Fields <bfields@fieldses.org> wrote:
>
> If you have an easy reproducer it might also be worth experimenting with
> NFSv4 exports of an ext4 system mounted with the i_version option.

I may give that a try.

> Actually: should the NFSv4 server always be using i_version as the
> change attribute for directories?  (Does every exportable filesystem
> update it on every directory modification?)

It appears to be an option for ext4.  I do not see it referenced in XFS.

> (And if so, maybe on directories we should factor the i_version into the
> low bits of the mtime reported to NFSv3 client?)

Probably a bad idea.  Runs the risk of "change file A then change file
B" resulting in backwards timestamps, which is even worse than 4
millisecond timestamps.

 - Pat

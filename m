Return-Path: <SRS0=PHUf=OT=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.4 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS,USER_AGENT_MUTT autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id B1C11C04EB8
	for <linux-nfs@archiver.kernel.org>; Mon, 10 Dec 2018 19:53:48 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 71F5420821
	for <linux-nfs@archiver.kernel.org>; Mon, 10 Dec 2018 19:53:48 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 71F5420821
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=fieldses.org
Authentication-Results: mail.kernel.org; spf=none smtp.mailfrom=linux-nfs-owner@vger.kernel.org
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1728090AbeLJTxr (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Mon, 10 Dec 2018 14:53:47 -0500
Received: from fieldses.org ([173.255.197.46]:59588 "EHLO fieldses.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1726677AbeLJTxr (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Mon, 10 Dec 2018 14:53:47 -0500
Received: by fieldses.org (Postfix, from userid 2815)
        id 20E24315; Mon, 10 Dec 2018 14:53:47 -0500 (EST)
Date:   Mon, 10 Dec 2018 14:53:47 -0500
From:   "J. Bruce Fields" <bfields@fieldses.org>
To:     Jeff Layton <jlayton@redhat.com>
Cc:     linux-nfs@vger.kernel.org, linux-fsdevel@vger.kernel.org
Subject: Re: listing knfsd-held locks and opens
Message-ID: <20181210195347.GA4392@fieldses.org>
References: <20181210174720.GA2925@fieldses.org>
 <0ff22d33d5d7d2b3fad241ebb2aa0e5c5cb70396.camel@redhat.com>
 <20181210192310.GC2925@fieldses.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20181210192310.GC2925@fieldses.org>
User-Agent: Mutt/1.5.21 (2010-09-15)
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

On Mon, Dec 10, 2018 at 02:23:10PM -0500, J. Bruce Fields wrote:
> On Mon, Dec 10, 2018 at 01:12:31PM -0500, Jeff Layton wrote:
> > On Mon, 2018-12-10 at 12:47 -0500, J. Bruce Fields wrote:
> > > We've got a long-standing complaint that tools like lsof, when run on an
> > > NFS server, overlook opens and locks held by NFS clients.
> > > 
> > > The information's all there, it's just a question of how to expose it.
> > > 
> > > Easiest might be a single flat file like /proc/locks, but I've always
> > > hoped we could do something slightly more structured, using a
> > > subdirectory per NFS client.
> > > 
> > > Jeff Layton looked into this several years ago.  I don't remember if
> > > there was some particular issue or if he just got bogged down in VFS
> > > details.
> > > 
> > 
> > I think I had a patch that generated a single flat file for locks, but
> > you wanted to present a directory or file per-client, and I just never
> > got around to reworking the earlier patch.
> 
> Oh, OK, makes sense.

(But, um, if anyone has a good starting point to recommend to me here,
I'm interested.  E.g. another pseudofs that's a good example to follow.)

--b.

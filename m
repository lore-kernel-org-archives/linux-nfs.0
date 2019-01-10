Return-Path: <SRS0=3Jq2=PS=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS,URIBL_BLOCKED,USER_AGENT_MUTT autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id E1696C43387
	for <linux-nfs@archiver.kernel.org>; Thu, 10 Jan 2019 20:33:21 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id BC8CD2173B
	for <linux-nfs@archiver.kernel.org>; Thu, 10 Jan 2019 20:33:21 +0000 (UTC)
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1729367AbfAJUdV (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Thu, 10 Jan 2019 15:33:21 -0500
Received: from fieldses.org ([173.255.197.46]:48886 "EHLO fieldses.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1728818AbfAJUdV (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Thu, 10 Jan 2019 15:33:21 -0500
Received: by fieldses.org (Postfix, from userid 2815)
        id 9BE7FBCE; Thu, 10 Jan 2019 15:33:20 -0500 (EST)
Date:   Thu, 10 Jan 2019 15:33:20 -0500
To:     Ashish Sangwan <ashishsangwan2@gmail.com>
Cc:     neilb@suse.com, linux-nfs@vger.kernel.org
Subject: Re: Handling of duplicate inode numbers for the directories in the
 nfs v3 kernel client
Message-ID: <20190110203320.GE15492@fieldses.org>
References: <CAOiN93mX240ijc8mcX1OSKrQaP12At9t5c9cE3-T0gEuLC9RkA@mail.gmail.com>
 <878t0uuzxv.fsf@notabene.neil.brown.name>
 <CAOiN93=bh8WrCD8gZ+En4EfzTv2iHMn5n4w5=rYJOr6RbUkCKQ@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CAOiN93=bh8WrCD8gZ+En4EfzTv2iHMn5n4w5=rYJOr6RbUkCKQ@mail.gmail.com>
User-Agent: Mutt/1.5.21 (2010-09-15)
From:   bfields@fieldses.org (J. Bruce Fields)
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

On Thu, Dec 13, 2018 at 09:17:31AM +0530, Ashish Sangwan wrote:
> Thanks for the clarification!
> 
> On Thu, 13 Dec 2018, 4:15 am NeilBrown <neilb@suse.com wrote:
> >
> > On Thu, Dec 13 2018, Ashish Sangwan wrote:
> >
> > > Hi,
> > >
> > > Our NFS filer can sometimes return same inode number for different directories.
> >
> > Why?
> The NFS fileserver is handling file systems over different nodes at
> the same time.
> To the client however, we want to present with a single pseudo fsid
> (sent as part of the getattr) so that submounts can be avoided.

Out of curiosity, why do you want to avoid submounts?

--b.

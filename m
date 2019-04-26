Return-Path: <SRS0=vcFy=S4=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS,URIBL_BLOCKED,USER_AGENT_MUTT autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id E1601C43218
	for <linux-nfs@archiver.kernel.org>; Fri, 26 Apr 2019 12:56:12 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id B21DB206BF
	for <linux-nfs@archiver.kernel.org>; Fri, 26 Apr 2019 12:56:12 +0000 (UTC)
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1726123AbfDZM4M (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Fri, 26 Apr 2019 08:56:12 -0400
Received: from fieldses.org ([173.255.197.46]:52824 "EHLO fieldses.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1726013AbfDZM4M (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Fri, 26 Apr 2019 08:56:12 -0400
Received: by fieldses.org (Postfix, from userid 2815)
        id 83D5B1C83; Fri, 26 Apr 2019 08:56:11 -0400 (EDT)
Date:   Fri, 26 Apr 2019 08:56:11 -0400
To:     Andreas Dilger <adilger@dilger.ca>
Cc:     NeilBrown <neilb@suse.com>, "J. Bruce Fields" <bfields@redhat.com>,
        linux-nfs <linux-nfs@vger.kernel.org>,
        linux-fsdevel <linux-fsdevel@vger.kernel.org>, abe@purdue.edu,
        lsof-l@lists.purdue.edu, util-linux@vger.kernel.org,
        Jeff Layton <jlayton@redhat.com>,
        James Simmons <uja.ornl@gmail.com>
Subject: Re: [PATCH 00/10] exposing knfsd opens to userspace
Message-ID: <20190426125611.GA23112@fieldses.org>
References: <1556201060-7947-1-git-send-email-bfields@redhat.com>
 <B37B2837-E8C8-41EA-9A2D-3F8B93304FDD@dilger.ca>
 <87lfzx65ax.fsf@notabene.neil.brown.name>
 <60EB550C-B79C-4DB4-AE3D-F1FCEB49EDA1@dilger.ca>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <60EB550C-B79C-4DB4-AE3D-F1FCEB49EDA1@dilger.ca>
User-Agent: Mutt/1.5.21 (2010-09-15)
From:   bfields@fieldses.org (J. Bruce Fields)
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

On Fri, Apr 26, 2019 at 01:00:19PM +0200, Andreas Dilger wrote:
> 
> On Apr 26, 2019, at 1:20 AM, NeilBrown <neilb@suse.com> wrote:
> > /proc/fs/nfsd is the (standard) mount point for a separate NFSD-specific
> > filesystem, originally created to replace the nfsd-specific systemcall.
> > So the nfsd developers have a fair degree of latitude as to what can go
> > in there.
> > 
> > But I *don't* think it is a good idea to follow this pattern.  Creating
> > a separate control filesystem for every different module that thinks it
> > has different needs doesn't scale well.  We could end up with dozens of
> > tiny filesystems that all need to be mounted at just the right place.

Aren't we already there?  My laptop, Fedora 29 with everything pretty much
default:

$  findmnt -n -oFSTYPE|sort|uniq -c
      1 autofs
      1 bpf
     11 cgroup
      1 cgroup2
      1 configfs
      1 debugfs
      1 devpts
      1 devtmpfs
      3 ext4
      1 fusectl
      1 fuse.gvfsd-fuse
      1 hugetlbfs
      1 mqueue
      1 proc
      1 pstore
      1 rpc_pipefs
      1 securityfs
      1 selinuxfs
      1 sysfs
      5 tmpfs

> > I don't think that is healthy for Linus.

What are the problems you see?

> > Nor do I think we should be stuffing stuff into debugfs that isn't
> > really for debugging.  That isn't healthy either.
> > 
> > If sysfs doesn't meet our needs, then we need to raise that in
> > appropriate fora and present a clear case and try to build consensus -
> > because if we see a problem, then it is likely that others do to.
> 
> I definitely *do* see the restrictions sysfs as being a problem, and I'd
> guess NFS developers thought the same,

For what it's worth, the nfsd filesystem predated sysfs, just barely.

Looking at the history....  It was actually Al that introduced it in March
2002.  Patrick Mochel added sysfs in October 2002.

But it's true that from the start nfsd didn't really fit the model of a single
(possibly writeable) attribute per file.

(Might be interesting to look at the distribution of new filesystem types over
time, there may have been a peak around then.)

--b.

Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:14737 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756267AbaAITz3 convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 9 Jan 2014 14:55:29 -0500
Date: Thu, 9 Jan 2014 14:55:24 -0500
From: Jeff Layton <jlayton@redhat.com>
To: Trond Myklebust <trond.myklebust@primarydata.com>
Cc: "Yin.JianHong" <jiyin@redhat.com>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH RFC] nfs: remove nfs_show_devname
Message-ID: <20140109145524.7c50ab8c@corrin.poochiereds.net>
In-Reply-To: <7AA69B49-5971-4548-BE27-B8F90D1C0F10@primarydata.com>
References: <1389293995-634-1-git-send-email-jlayton@redhat.com>
	<6FE57B0D-2373-4B40-BA14-E6F2BF3C44E3@primarydata.com>
	<20140109141259.553c58f0@tlielax.poochiereds.net>
	<7AA69B49-5971-4548-BE27-B8F90D1C0F10@primarydata.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, 9 Jan 2014 14:27:04 -0500
Trond Myklebust <trond.myklebust@primarydata.com> wrote:

> 
> On Jan 9, 2014, at 14:12, Jeff Layton <jlayton@redhat.com> wrote:
> 
> > On Thu, 9 Jan 2014 14:06:54 -0500
> > Trond Myklebust <trond.myklebust@primarydata.com> wrote:
> > 
> >> 
> >> On Jan 9, 2014, at 13:59, Jeff Layton <jlayton@redhat.com> wrote:
> >> 
> >>> The nfs code will currently construct a devname to show in places like
> >>> /proc/mounts by turning a dentry into a path. Unfortunately, that's
> >>> somewhat problematic if the user ended up mounting through a symlink on
> >>> the server. The devname that then shows up in /proc/mounts now doesn't
> >>> match the one that was originally passed into the mount request.
> >> 
> >> This is 100% according to design. Why is it suddenly a problem?
> >> 
> >> By displaying the original pathname, you also end up bypassing referral resolution, etc. This is exactly why the .show_devname operation was introduced in the first place.
> >> 
> > 
> > AFAIU, the main issue is that when /etc/mtab is a symlink
> > to /proc/mounts, you can't do this in the example in the patch
> > description:
> > 
> >    # mount server:/export/bar /mnt/bar
> >    # umount server:/export/bar
> > 
> > ...since umount will try to ID the mountpoint by looking up the devname
> > in /etc/mtab.
> 
> The NFS pathname is NOT a devname. It shouldn’t be abused as a substitute for a mount point.
> 
> Particularly not so when you consider that the same NFS path can be mounted in several different places with different mount options. The same path can even refer to completely different locations (i.e. different file handles) if, say, the original directory has been renamed on the server.
> 
> > What exactly would this break with referrals?
> > 
> 
> It would “break” in the sense that the admin would have no clue that his client is actually talking to a different server than the one specified in the mount.
> 

Good point. Ok, I don't think the problem really rises above the level
of annoyance, so let's just drop this patch.

Thanks,
-- 
Jeff Layton <jlayton@redhat.com>

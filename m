Return-Path: <SRS0=mk5Y=RJ=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id DC46AC43381
	for <linux-nfs@archiver.kernel.org>; Wed,  6 Mar 2019 04:36:09 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id AE77E20663
	for <linux-nfs@archiver.kernel.org>; Wed,  6 Mar 2019 04:36:09 +0000 (UTC)
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1726699AbfCFEgI convert rfc822-to-8bit (ORCPT
        <rfc822;linux-nfs@archiver.kernel.org>);
        Tue, 5 Mar 2019 23:36:08 -0500
Received: from mx1.redhat.com ([209.132.183.28]:50074 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1726655AbfCFEgI (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Tue, 5 Mar 2019 23:36:08 -0500
Received: from smtp.corp.redhat.com (int-mx06.intmail.prod.int.phx2.redhat.com [10.5.11.16])
        (using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
        (No client certificate requested)
        by mx1.redhat.com (Postfix) with ESMTPS id E9709309264F;
        Wed,  6 Mar 2019 04:36:07 +0000 (UTC)
Received: from colo-mx.corp.redhat.com (colo-mx01.intmail.prod.int.phx2.redhat.com [10.5.11.20])
        by smtp.corp.redhat.com (Postfix) with ESMTPS id E08B417115;
        Wed,  6 Mar 2019 04:36:07 +0000 (UTC)
Received: from zmail21.collab.prod.int.phx2.redhat.com (zmail21.collab.prod.int.phx2.redhat.com [10.5.83.24])
        by colo-mx.corp.redhat.com (Postfix) with ESMTP id CC1F81819AFB;
        Wed,  6 Mar 2019 04:36:07 +0000 (UTC)
Date:   Tue, 5 Mar 2019 23:36:07 -0500 (EST)
From:   Jianhong Yin <jiyin@redhat.com>
To:     Steve Dickson <SteveD@RedHat.com>
Cc:     "Jianhong.Yin" <yin-jianhong@163.com>, linux-nfs@vger.kernel.org
Message-ID: <569350425.9942929.1551846967676.JavaMail.zimbra@redhat.com>
In-Reply-To: <813b5167-8c4a-dd64-eb95-d29b4463d54a@RedHat.com>
References: <20190228050842.15827-1-yin-jianhong@163.com> <813b5167-8c4a-dd64-eb95-d29b4463d54a@RedHat.com>
Subject: Re: [PATCH] mount.nfs: fix ignore EBUSY problem in special scenario
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 8BIT
X-Originating-IP: [10.66.12.115, 10.4.195.23]
Thread-Topic: mount.nfs: fix ignore EBUSY problem in special scenario
Thread-Index: jdRtCuA1VfG89YCOAeyLwCeG4toh6w==
X-Scanned-By: MIMEDefang 2.79 on 10.5.11.16
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.43]); Wed, 06 Mar 2019 04:36:07 +0000 (UTC)
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org


----- 原始邮件 -----
> 发件人: "Steve Dickson" <SteveD@RedHat.com>
> 收件人: "Jianhong.Yin" <yin-jianhong@163.com>
> 抄送: linux-nfs@vger.kernel.org, jiyin@redhat.com
> 发送时间: 星期三, 2019年 3 月 06日 上午 2:00:02
> 主题: Re: [PATCH] mount.nfs: fix ignore EBUSY problem in special scenario
> 
> Hello,
> 
> I apologies for taking so long to get to this...
> 
> On 2/28/19 12:08 AM, Jianhong.Yin wrote:
> > now mount.nfs ignore EBUSY when the $dir is a mountpoint,
> > it's not correct in specail scenario for example:
> >   $dir is a mountpoint of other filesystem(let's say tmpfs)
> > so we must be sure: current nfs mounting has mounted on $dir, then
> > ignore the EBUSY for user.
> > 
> > - if (errno == EBUSY && is_mountpoint(mi->node))
> > + if (errno == EBUSY && is_mountpoint(mi->node) && has_mounted_on(mi->spec,
> > mi->node))
> > 
> > reproducer:
> > '''
> > mkdir -p /expdir /mnt/nfsmp /mnt/tmpfs
> > echo "/expdir *(rw,no_root_squash)" >/etc/exports
> > service nfs restart
> > mount -t tmpfs tmpfs /mnt/tmpfs
> > mount -osharecache localhost:/expdir /mnt/nfsmp #success
> > mount -osharecache localhost:/expdir /mnt/nfsmp #mounted already, return
> > 0(pass)
> > mount -osharecache localhost:/expdir /mnt/tmpfs #success
> > mount -osharecache localhost:/expdir /mnt/tmpfs #mounted already, return
> > 0(pass)
> > umount /mnt/nfsmp
> > umount /mnt/tmpfs
> > 
> > mount -ocontext=system_u:object_r:xferlog_t:s0,sharecache localhost:/expdir
> > /mnt/nfsmp
> > mount -ocontext=system_u:object_r:user_home_dir_t:s0,sharecache
> > localhost:/expdir /mnt/tmpfs
> > [[ $? = 0 ]] && echo "***test fail: hasn't mounted, should return fail ***"
> > 
> > umount /mnt/nfsmp
> What real world problem is this solving or better yet what real world
> situation would something like this be done??
> 
> I see this more of a pilot error... no one uses tmpfs to make mount to fail
> (or not fail in this case)... It's just not how tmpfs is used.
replace tmpfs with ext4/xfs ... will get same unexpected result.

> 
> Plus who uses -ocontext= this way? If some one is that sophisticated to
> use mount like that.... and get wrong... they need to be a little
> more sophisticated ;-)
> 
> Finally, when tmpfs is not in the picture things work as expected....
> 
> Maybe I'm missing something... I don't this as a problem or a situation
> the people will run into... again... maybe I'm missing something.

something you missing might be:
  "$Dir is a mountpoint"  doesn't mean  "$Dir has mounted on a nfs:/share you want"
     (it might be tmpfs/ext4/xfs/btrfs/... or another nfs that is not your expect)

I know this test path is very ... abnormal. I just think
I think the plane should not ignore "Landing gear failure"(EBUSY), even if the pilot 
did a very unconventional operation :)

I'm just want you understand what will happen in this corner corner case.
It's up to you(won't fix/or fix)

Jianhong

> 
> steved.
> > '''
> > 
> > Signed-off-by: Jianhong Yin <yin-jianhong@163.com>
> > ---
> >  support/include/misc.h    |  1 +
> >  support/misc/mountpoint.c | 26 +++++++++++++++++++++++++-
> >  utils/mount/stropts.c     |  2 +-
> >  3 files changed, 27 insertions(+), 2 deletions(-)
> > 
> > diff --git a/support/include/misc.h b/support/include/misc.h
> > index 06e2a0c..bd02bfc 100644
> > --- a/support/include/misc.h
> > +++ b/support/include/misc.h
> > @@ -19,6 +19,7 @@ char *generic_make_pathname(const char *, const char *);
> >  _Bool generic_setup_basedir(const char *, const char *, char *, const
> >  size_t);
> >  
> >  extern int is_mountpoint(char *path);
> > +extern int has_mounted_on(const char *fsname, const char *dir);
> >  
> >  /* size of the file pointer buffers for rpc procfs files */
> >  #define RPC_CHAN_BUF_SIZE 32768
> > diff --git a/support/misc/mountpoint.c b/support/misc/mountpoint.c
> > index 9f9ce44..7f8a89f 100644
> > --- a/support/misc/mountpoint.c
> > +++ b/support/misc/mountpoint.c
> > @@ -3,9 +3,11 @@
> >   * check if a given path is a mountpoint
> >   */
> >  
> > +#include <stdio.h>
> >  #include <string.h>
> > -#include "xcommon.h"
> > +#include <mntent.h>
> >  #include <sys/stat.h>
> > +#include "xcommon.h"
> >  #include "misc.h"
> >  
> >  int
> > @@ -38,3 +40,25 @@ is_mountpoint(char *path)
> >  	free(dotdot);
> >  	return rv;
> >  }
> > +
> > +int
> > +has_mounted_on(const char *fsname, const char *dir)
> > +{
> > +	struct mntent *ent;
> > +	FILE *fp;
> > +	int ret = 0;
> > +
> > +	fp = setmntent("/proc/mounts", "r");
> > +	if (fp == NULL) {
> > +		perror("[unlikely] setmntent(3) fail");
> > +		exit(1);
> > +	}
> > +	while (NULL != (ent = getmntent(fp))) {
> > +		if (!strcmp(ent->mnt_fsname, fsname) && !strcmp(ent->mnt_dir, dir)) {
> > +			ret = 1;
> > +			break;
> > +		}
> > +	}
> > +	endmntent(fp);
> > +	return ret;
> > +}
> > diff --git a/utils/mount/stropts.c b/utils/mount/stropts.c
> > index a093926..bffb74a 100644
> > --- a/utils/mount/stropts.c
> > +++ b/utils/mount/stropts.c
> > @@ -1081,7 +1081,7 @@ static int nfsmount_fg(struct nfsmount_info *mi)
> >  			return EX_SUCCESS;
> >  
> >  #pragma GCC diagnostic ignored "-Wdiscarded-qualifiers"
> > -		if (errno == EBUSY && is_mountpoint(mi->node)) {
> > +		if (errno == EBUSY && is_mountpoint(mi->node) &&
> > has_mounted_on(mi->spec, mi->node)) {
> >  #pragma GCC diagnostic warning "-Wdiscarded-qualifiers"
> >  			/*
> >  			 * EBUSY can happen when mounting a filesystem that
> > 
> 

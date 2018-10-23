Return-Path: <SRS0=j1eS=ND=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.8 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 305B4C67863
	for <linux-nfs@archiver.kernel.org>; Tue, 23 Oct 2018 02:40:48 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 1DD7B20652
	for <linux-nfs@archiver.kernel.org>; Tue, 23 Oct 2018 02:40:48 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 1DD7B20652
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=none smtp.mailfrom=linux-nfs-owner@vger.kernel.org
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1727201AbeJWLCC convert rfc822-to-8bit (ORCPT
        <rfc822;linux-nfs@archiver.kernel.org>);
        Tue, 23 Oct 2018 07:02:02 -0400
Received: from mx1.redhat.com ([209.132.183.28]:53870 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1726894AbeJWLCC (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Tue, 23 Oct 2018 07:02:02 -0400
Received: from smtp.corp.redhat.com (int-mx01.intmail.prod.int.phx2.redhat.com [10.5.11.11])
        (using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
        (No client certificate requested)
        by mx1.redhat.com (Postfix) with ESMTPS id 6F915307D90F;
        Tue, 23 Oct 2018 02:40:46 +0000 (UTC)
Received: from colo-mx.corp.redhat.com (colo-mx01.intmail.prod.int.phx2.redhat.com [10.5.11.20])
        by smtp.corp.redhat.com (Postfix) with ESMTPS id 6184560182;
        Tue, 23 Oct 2018 02:40:46 +0000 (UTC)
Received: from zmail21.collab.prod.int.phx2.redhat.com (zmail21.collab.prod.int.phx2.redhat.com [10.5.83.24])
        by colo-mx.corp.redhat.com (Postfix) with ESMTP id 489C81809545;
        Tue, 23 Oct 2018 02:40:46 +0000 (UTC)
Date:   Mon, 22 Oct 2018 22:40:46 -0400 (EDT)
From:   Jianhong Yin <jiyin@redhat.com>
To:     Steve Dickson <SteveD@RedHat.com>
Cc:     =?utf-8?B?5bC55YmR6Jm5?= <yin-jianhong@163.com>,
        linux-nfs@vger.kernel.org
Message-ID: <1792890688.23335447.1540262446122.JavaMail.zimbra@redhat.com>
In-Reply-To: <ab0b498f-16a8-28a4-7bb4-f9478f865e48@RedHat.com>
References: <20181019080354.26141-1-jiyin@redhat.com> <907dd179-13d7-071e-8c60-eb9915762299@RedHat.com> <17c11e3b.5987.1668f873fb0.Coremail.yin-jianhong@163.com> <b6880ebf-80ca-e101-b40c-847a81f7f17f@RedHat.com> <1130807003.22494855.1540176991895.JavaMail.zimbra@redhat.com> <397071301.22496063.1540178057085.JavaMail.zimbra@redhat.com> <ab0b498f-16a8-28a4-7bb4-f9478f865e48@RedHat.com>
Subject: Re: [PATCH] [nfs-utils] fix issue: mount -osharecache failure but
 return 'true'
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 8BIT
X-Originating-IP: [10.72.12.176, 10.4.195.10]
Thread-Topic: fix issue: mount -osharecache failure but return 'true'
Thread-Index: dHoFc4vEBl0TqAlAl+4EkDH2sBjO5w==
X-Scanned-By: MIMEDefang 2.79 on 10.5.11.11
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.48]); Tue, 23 Oct 2018 02:40:46 +0000 (UTC)
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org



----- 原始邮件 -----
> 发件人: "Steve Dickson" <SteveD@RedHat.com>
> 收件人: "Jianhong Yin" <jiyin@redhat.com>
> 抄送: "尹剑虹" <yin-jianhong@163.com>, linux-nfs@vger.kernel.org
> 发送时间: 星期一, 2018年 10 月 22日 下午 10:10:57
> 主题: Re: [PATCH] [nfs-utils] fix issue: mount -osharecache failure but return 'true'
> 
> 
> 
> On 10/21/18 11:14 PM, Jianhong Yin wrote:
> > 
> > ----- 原始邮件 -----
> >> 发件人: "Jianhong Yin" <jiyin@redhat.com>
> >> 收件人: "Steve Dickson" <SteveD@RedHat.com>
> >> 抄送: "尹剑虹" <yin-jianhong@163.com>, linux-nfs@vger.kernel.org
> >> 发送时间: 星期一, 2018年 10 月 22日 上午 10:56:31
> >> 主题: Re: [PATCH] [nfs-utils] fix issue: mount -osharecache failure but
> >> return 'true'
> >>
> >>
> >> ----- 原始邮件 -----
> >>> 发件人: "Steve Dickson" <SteveD@RedHat.com>
> >>> 收件人: "尹剑虹" <yin-jianhong@163.com>
> >>> 抄送: jiyin@redhat.com, linux-nfs@vger.kernel.org
> >>> 发送时间: 星期六, 2018年 10 月 20日 下午 10:35:48
> >>> 主题: Re: [PATCH] [nfs-utils] fix issue: mount -osharecache failure but
> >>> return 'true'
> >>>
> >>> Hello,
> >>>
> >>> On 10/19/18 11:31 PM, 尹剑虹 wrote:
> >>>>
> >>>> Hi Steved
> >>>>
> >>>> The scenario is: these two mountings use different "context=" and
> >>>> sharecache option, in this case mount(2) return fail with EBUSY.
> >>> Fair enough.... I did miss the different contexts...
> >>>
> >>> But we already have a routine that check mount points
> >>> is_mountpoint() used my mountd. I would rather use that.
> > 
> > Hi Sir
> > 
> >   I reviewed function is_mountpoint(), seems it just check if the
> >   mountpoint is a root-fs，
> >   our goal is check if special dev has been mounted on specail path.
> No. It check to see if the directory above the path (aka /..)
> is on the same device (or filesystem) as path is. When the
> device numbers are the same, both paths are on the same filesystem.
> When they are not the same, the paths are on different filesystems
I know.. ah sorry I used wrong word root-fs(not top rootfs, just means mountpoint).

What I want to say is:
  Two(or more) devices could be mounted on same mountpoint on Linux,
  only check "mi->node" is a mountpoint is not enough
   we have to check if "mi->node" is a mountpoint *and* mounted on "mi->spec"

Jianhong
 
> steved.
> 
> > 
> >   WDYT?
> > 
> >> Got it, good to know.
> >>
> >>>
> >>> I'll resend the patch...
> >>>
> >>> Thanks!!
> >>>
> >>> steved.
> >>>
> >>>>
> >>>> Jianhong
> >>>>
> >>>>
> >>>> 	
> >>>> 尹剑虹
> >>>> 邮箱：yin-jianhong@163.com
> >>>>
> >>>> <https://maas.mail.163.com/dashi-web-extend/html/proSignature.html?iconUrl=https%3A%2F%2Fmail-online.nosdn.127.net%2Fqiyelogo%2FdefaultAvatar.png&name=%E5%B0%B9%E5%89%91%E8%99%B9&uid=yin-jianhong%40163.com&ftlId=1&items=%5B%22%E9%82%AE%E7%AE%B1%EF%BC%9Ayin-jianhong%40163.com%22%5D>
> >>>>
> >>>> 签名由 网易邮箱大师 <https://mail.163.com/dashi/dlpro.html?from=mail88> 定制
> >>>>
> >>>>         On 10/20/2018 01:36, Steve Dickson <mailto:SteveD@RedHat.com>
> >>>>         wrote:
> >>>>
> >>>>
> >>>>         On 10/19/18 4:03 AM, jiyin@redhat.com wrote:
> >>>>         > From: "Jianhong.Yin" <yin-jianhong@163.com>
> >>>>         >
> >>>>         > see: https://bugzilla.redhat.com/show_bug.cgi?id=1629705
> >>>>         > mount.nfs4 -o
> >>>>         > context=system_u:object_r:user_home_dir_t:s0,sharecache
> >>>>         > $serv:$expdir $nfsmp
> >>>>         > mount.nfs4 -o
> >>>>         > context=system_u:object_r:xferlog_t:s0,sharecache
> >>>>         > $serv:$expdir $nfsmp2
> >>>>         > ^^^ here mount fail, but return true. it confuse user!
> >>>>         Why should it fail? Two different mounts are being used and
> >>>>         using
> >>>>         -o sharecache
> >>>>         which is the default the way...
> >>>>
> >>>>         steved.
> >>>>         >
> >>>>         > according:
> >>>>         > https://patchwork.kernel.org/patch/10602607/#22234047
> >>>>         > add function is_mounted_already()
> >>>>         > -          if (errno == EBUSY)
> >>>>         > +          if (errno == EBUSY && is_mounted_already(mi->spec,
> >>>>         > mi->node))
> >>>>         >                return EX_SUCCESS;
> >>>>         >
> >>>>         > Signed-off-by: Jianhong Yin <yin-jianhong@163.com>
> >>>>         > ---
> >>>>         >  utils/mount/stropts.c | 31 ++++++++++++++++++++++++-------
> >>>>         >  1 file changed, 24 insertions(+), 7 deletions(-)
> >>>>         >
> >>>>         > diff --git a/utils/mount/stropts.c b/utils/mount/stropts.c
> >>>>         > index 4d2e37e..4be7e61 100644
> >>>>         > --- a/utils/mount/stropts.c
> >>>>         > +++ b/utils/mount/stropts.c
> >>>>         > @@ -48,6 +48,7 @@
> >>>>         >  #include "version.h"
> >>>>         >  #include "parse_dev.h"
> >>>>         >  #include "conffile.h"
> >>>>         > +#include <mntent.h>
> >>>>         >  
> >>>>         >  #ifndef NFS_PROGRAM
> >>>>         >  #define NFS_PROGRAM     (100003)
> >>>>         > @@ -1056,6 +1057,27 @@ static int nfs_is_permanent_error(int
> >>>>         > error)
> >>>>         >       }
> >>>>         >  }
> >>>>         >  
> >>>>         > +static int is_mounted_already(const char *fsname, const char
> >>>>         > *dir)
> >>>>         > +{
> >>>>         > +     struct mntent *ent;
> >>>>         > +     FILE *fp;
> >>>>         > +     int ret = 0;
> >>>>         > +
> >>>>         > +     fp = setmntent("/proc/mounts", "r");
> >>>>         > +     if (fp == NULL) {
> >>>>         > +          perror("[unlikely] setmntent(3) fail");
> >>>>         > +          exit(1);
> >>>>         > +     }
> >>>>         > +     while (NULL != (ent = getmntent(fp))) {
> >>>>         > +          if (!strcmp(ent->mnt_fsname, fsname) &&
> >>>>         > !strcmp(ent->mnt_dir, dir)) {
> >>>>         > +               ret = 1;
> >>>>         > +               break;
> >>>>         > +          }
> >>>>         > +     }
> >>>>         > +     endmntent(fp);
> >>>>         > +     return ret;
> >>>>         > +}
> >>>>         > +
> >>>>         >  /*
> >>>>         >   * Handle "foreground" NFS mounts.
> >>>>         >   *
> >>>>         > @@ -1078,13 +1100,8 @@ static int nfsmount_fg(struct
> >>>>         > nfsmount_info *mi)
> >>>>         >            if (nfs_try_mount(mi))
> >>>>         >                 return EX_SUCCESS;
> >>>>         >  
> >>>>         > -          if (errno == EBUSY)
> >>>>         > -               /* The only cause of EBUSY is if exactly the
> >>>>         > desired
> >>>>         > -                * filesystem is already mounted.  That can
> >>>>         > arguably
> >>>>         > -                * be seen as success.  "mount -a" tries to
> >>>>         > optimise
> >>>>         > -                * out this case but sometimes fails.  Help it
> >>>>         > out
> >>>>         > -                * by pretending everything is rosy
> >>>>         > -                */
> >>>>         > +          /* if EBUSY is caused by re-mount, ignore the error
> >>>>         > */
> >>>>         > +          if (errno == EBUSY && is_mounted_already(mi->spec,
> >>>>         > mi->node))
> >>>>         >                 return EX_SUCCESS;
> >>>>         >  
> >>>>         >            if (nfs_is_permanent_error(errno))
> >>>>         >
> >>>>
> >>>
> >>
> 

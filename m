Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:37782 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1727404AbeJTWqa (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Sat, 20 Oct 2018 18:46:30 -0400
Subject: Re: [PATCH] [nfs-utils] fix issue: mount -osharecache failure but
 return 'true'
To: =?UTF-8?B?5bC55YmR6Jm5?= <yin-jianhong@163.com>
Cc: "jiyin@redhat.com" <jiyin@redhat.com>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
References: <20181019080354.26141-1-jiyin@redhat.com>
 <907dd179-13d7-071e-8c60-eb9915762299@RedHat.com>
 <17c11e3b.5987.1668f873fb0.Coremail.yin-jianhong@163.com>
From: Steve Dickson <SteveD@RedHat.com>
Message-ID: <b6880ebf-80ca-e101-b40c-847a81f7f17f@RedHat.com>
Date: Sat, 20 Oct 2018 10:35:48 -0400
MIME-Version: 1.0
In-Reply-To: <17c11e3b.5987.1668f873fb0.Coremail.yin-jianhong@163.com>
Content-Type: text/plain; charset=utf-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hello,

On 10/19/18 11:31 PM, 尹剑虹 wrote:
> 
> Hi Steved
> 
> The scenario is: these two mountings use different "context=" and sharecache option, in this case mount(2) return fail with EBUSY.
Fair enough.... I did miss the different contexts... 

But we already have a routine that check mount points
is_mountpoint() used my mountd. I would rather use that.

I'll resend the patch... 

Thanks!!

steved.

> 
> Jianhong
> 
> 
> 	
> 尹剑虹
> 邮箱：yin-jianhong@163.com
> 
> <https://maas.mail.163.com/dashi-web-extend/html/proSignature.html?iconUrl=https%3A%2F%2Fmail-online.nosdn.127.net%2Fqiyelogo%2FdefaultAvatar.png&name=%E5%B0%B9%E5%89%91%E8%99%B9&uid=yin-jianhong%40163.com&ftlId=1&items=%5B%22%E9%82%AE%E7%AE%B1%EF%BC%9Ayin-jianhong%40163.com%22%5D>
> 
> 签名由 网易邮箱大师 <https://mail.163.com/dashi/dlpro.html?from=mail88> 定制
> 
>         On 10/20/2018 01:36, Steve Dickson <mailto:SteveD@RedHat.com> wrote:
> 
> 
>         On 10/19/18 4:03 AM, jiyin@redhat.com wrote:
>         > From: "Jianhong.Yin" <yin-jianhong@163.com>
>         >
>         > see: https://bugzilla.redhat.com/show_bug.cgi?id=1629705
>         > mount.nfs4 -o context=system_u:object_r:user_home_dir_t:s0,sharecache $serv:$expdir $nfsmp
>         > mount.nfs4 -o context=system_u:object_r:xferlog_t:s0,sharecache $serv:$expdir $nfsmp2
>         > ^^^ here mount fail, but return true. it confuse user!
>         Why should it fail? Two different mounts are being used and using -o sharecache
>         which is the default the way...
> 
>         steved.
>         >
>         > according: https://patchwork.kernel.org/patch/10602607/#22234047
>         > add function is_mounted_already()
>         > -          if (errno == EBUSY)
>         > +          if (errno == EBUSY && is_mounted_already(mi->spec, mi->node))
>         >                return EX_SUCCESS;
>         >
>         > Signed-off-by: Jianhong Yin <yin-jianhong@163.com>
>         > ---
>         >  utils/mount/stropts.c | 31 ++++++++++++++++++++++++-------
>         >  1 file changed, 24 insertions(+), 7 deletions(-)
>         >
>         > diff --git a/utils/mount/stropts.c b/utils/mount/stropts.c
>         > index 4d2e37e..4be7e61 100644
>         > --- a/utils/mount/stropts.c
>         > +++ b/utils/mount/stropts.c
>         > @@ -48,6 +48,7 @@
>         >  #include "version.h"
>         >  #include "parse_dev.h"
>         >  #include "conffile.h"
>         > +#include <mntent.h>
>         >  
>         >  #ifndef NFS_PROGRAM
>         >  #define NFS_PROGRAM     (100003)
>         > @@ -1056,6 +1057,27 @@ static int nfs_is_permanent_error(int error)
>         >       }
>         >  }
>         >  
>         > +static int is_mounted_already(const char *fsname, const char *dir)
>         > +{
>         > +     struct mntent *ent;
>         > +     FILE *fp;
>         > +     int ret = 0;
>         > +
>         > +     fp = setmntent("/proc/mounts", "r");
>         > +     if (fp == NULL) {
>         > +          perror("[unlikely] setmntent(3) fail");
>         > +          exit(1);
>         > +     }
>         > +     while (NULL != (ent = getmntent(fp))) {
>         > +          if (!strcmp(ent->mnt_fsname, fsname) && !strcmp(ent->mnt_dir, dir)) {
>         > +               ret = 1;
>         > +               break;
>         > +          }
>         > +     }
>         > +     endmntent(fp);
>         > +     return ret;
>         > +}
>         > +
>         >  /*
>         >   * Handle "foreground" NFS mounts.
>         >   *
>         > @@ -1078,13 +1100,8 @@ static int nfsmount_fg(struct nfsmount_info *mi)
>         >            if (nfs_try_mount(mi))
>         >                 return EX_SUCCESS;
>         >  
>         > -          if (errno == EBUSY)
>         > -               /* The only cause of EBUSY is if exactly the desired
>         > -                * filesystem is already mounted.  That can arguably
>         > -                * be seen as success.  "mount -a" tries to optimise
>         > -                * out this case but sometimes fails.  Help it out
>         > -                * by pretending everything is rosy
>         > -                */
>         > +          /* if EBUSY is caused by re-mount, ignore the error */
>         > +          if (errno == EBUSY && is_mounted_already(mi->spec, mi->node))
>         >                 return EX_SUCCESS;
>         >  
>         >            if (nfs_is_permanent_error(errno))
>         >
> 

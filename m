Return-Path: linux-kernel-owner@vger.kernel.org
Message-ID: <54DE4002.6050805@infradead.org>
Date: Fri, 13 Feb 2015 10:18:42 -0800
From: Randy Dunlap <rdunlap@infradead.org>
MIME-Version: 1.0
To: Stephen Rothwell <sfr@canb.auug.org.au>, linux-next@vger.kernel.org
CC: linux-kernel@vger.kernel.org, linux-nfs@vger.kernel.org,
        "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: linux-next: Tree for Feb 13 (nfsd)
References: <20150213165615.1ad43047@canb.auug.org.au>
In-Reply-To: <20150213165615.1ad43047@canb.auug.org.au>
Content-Type: text/plain; charset=utf-8
Sender: linux-kernel-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 02/12/15 21:56, Stephen Rothwell wrote:
> Hi all,
> 
> Please do not add any material destined for v3.21 to your linux-next
> included trees until after v3.20-rc1 has been released.
> 
> Changes since 20150212:

on x86_64, when
# CONFIG_NFS_FS is not set
CONFIG_NFSD=y
# CONFIG_NFSD_V3 is not set
# CONFIG_NFSD_V4 is not set

In file included from ../include/linux/linkage.h:4:0,
                 from ../include/linux/preempt.h:9,
                 from ../include/linux/spinlock.h:50,
                 from ../include/linux/mmzone.h:7,
                 from ../include/linux/gfp.h:5,
                 from ../include/linux/slab.h:14,
                 from ../fs/nfsd/nfsctl.c:7:
../fs/nfsd/xdr4.h: In function 'set_change_info':
../fs/nfsd/xdr4.h:633:13: error: 'struct svc_fh' has no member named 'fh_pre_saved'
  BUG_ON(!fhp->fh_pre_saved);
             ^
../include/linux/compiler.h:164:42: note: in definition of macro 'unlikely'
 # define unlikely(x) __builtin_expect(!!(x), 0)
                                          ^
../fs/nfsd/xdr4.h:633:2: note: in expansion of macro 'BUG_ON'
  BUG_ON(!fhp->fh_pre_saved);
  ^
In file included from ../fs/nfsd/pnfs.h:8:0,
                 from ../fs/nfsd/nfsctl.c:24:
../fs/nfsd/xdr4.h:634:21: error: 'struct svc_fh' has no member named 'fh_post_saved'
  cinfo->atomic = fhp->fh_post_saved;
                     ^
../fs/nfsd/xdr4.h:637:28: error: 'struct svc_fh' has no member named 'fh_pre_change'
  cinfo->before_change = fhp->fh_pre_change;
                            ^
../fs/nfsd/xdr4.h:638:27: error: 'struct svc_fh' has no member named 'fh_post_change'
  cinfo->after_change = fhp->fh_post_change;
                           ^
../fs/nfsd/xdr4.h:639:31: error: 'struct svc_fh' has no member named 'fh_pre_ctime'
  cinfo->before_ctime_sec = fhp->fh_pre_ctime.tv_sec;
                               ^
../fs/nfsd/xdr4.h:640:32: error: 'struct svc_fh' has no member named 'fh_pre_ctime'
  cinfo->before_ctime_nsec = fhp->fh_pre_ctime.tv_nsec;
                                ^
../fs/nfsd/xdr4.h:641:30: error: 'struct svc_fh' has no member named 'fh_post_attr'
  cinfo->after_ctime_sec = fhp->fh_post_attr.ctime.tv_sec;
                              ^
../fs/nfsd/xdr4.h:642:31: error: 'struct svc_fh' has no member named 'fh_post_attr'
  cinfo->after_ctime_nsec = fhp->fh_post_attr.ctime.tv_nsec;
                               ^



-- 
~Randy

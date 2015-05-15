Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from aserp1040.oracle.com ([141.146.126.69]:32263 "EHLO
	aserp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1946018AbbEOO1l convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 15 May 2015 10:27:41 -0400
Content-Type: text/plain; charset=us-ascii
Mime-Version: 1.0 (Mac OS X Mail 7.3 \(1878.6\))
Subject: Re: NFS client broken in 4.1.0-rc2
From: Chuck Lever <chuck.lever@oracle.com>
In-Reply-To: <20150515142403.GL2067@n2100.arm.linux.org.uk>
Date: Fri, 15 May 2015 10:26:48 -0400
Cc: Trond Myklebust <trond.myklebust@primarydata.com>,
        Anna Schumaker <anna.schumaker@netapp.com>,
        linux-fsdevel@vger.kernel.org,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>,
        linux-kernel@vger.kernel.org, linux-arm-kernel@lists.infradead.org
Message-Id: <F423EE93-1A93-42F8-8593-9D2E4F85CB3B@oracle.com>
References: <20150515142403.GL2067@n2100.arm.linux.org.uk>
To: Russell King - ARM Linux <linux@arm.linux.org.uk>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


On May 15, 2015, at 10:24 AM, Russell King - ARM Linux <linux@arm.linux.org.uk> wrote:

> While trying to update a kernel and modules on one of my test systems,
> I was greeted by these errors:
> 
> tar: lib/modules/4.1.0-rc2+/kernel/drivers/media/platform/coda/coda.ko: Cannot utime
> tar: lib/modules/4.1.0-rc2+/kernel/drivers/media/dvb-frontends/drx39xyj/drx39xyj.ko: Cannot utime
> tar: lib/modules/4.1.0-rc2+/kernel/drivers/media/usb/em28xx/em28xx.ko: Cannot utime
> tar: lib/modules/4.1.0-rc2+/kernel/drivers/usb/serial/option.ko: Cannot utime
> tar: lib/modules/4.1.0-rc2+/kernel/drivers/usb/serial/ftdi_sio.ko: Cannot utime
> tar: lib/modules/4.1.0-rc2+/kernel/drivers/net/wireless/brcm80211/brcmfmac/brcmfmac.ko: Cannot utime
> tar: lib/modules/4.1.0-rc2+/kernel/drivers/input/mouse/psmouse.ko: Cannot utime
> tar: lib/modules/4.1.0-rc2+/kernel/fs/udf/udf.ko: Cannot utime
> tar: lib/modules/4.1.0-rc2+/kernel/fs/fuse/fuse.ko: Cannot utime
> tar: lib/modules/4.1.0-rc2+/kernel/fs/nfsd/nfsd.ko: Cannot utime
> tar: lib/modules/4.1.0-rc2+/kernel/sound/soc/codecs/snd-soc-wm8962.ko: Cannot utime
> tar: lib/modules/4.1.0-rc2+/kernel/net/bluetooth/bluetooth.ko: Cannot utime
> tar: lib/modules/4.1.0-rc2+/modules.alias.bin: Cannot utime
> tar: lib/modules/4.1.0-rc2+/modules.alias: Cannot utime
> tar: Exiting with failure status due to previous errors
> 
> Searching google wasn't helpful, as all the "Cannot utime" errors that
> google could find are followed by an errno string.
> 
> stracing at first sight didn't seem to be helpful, as no syscalls (apart
> from openat() with a pre-existing file) were failing.
> 
> Having recently updated to fc21 tar generating the archive, I thought
> maybe it was a tar format bug between fc21 tar and the target's tar.
> That was until I tried to "apt-get source tar" on the target, and was
> greeted by the same error.
> 
> So I then tried untaring the tar source archive onto a ramfs, which
> worked without complaint.  The difference being that it's a root NFS
> box, and so I was untaring onto NFS.
> 
> Here's the entry from /proc/mounts:
> 
> x.y.z.221:/var/boot/ci on / type nfs (rw,nolock,vers=4,addr=x.y.z.221,clientaddr=a.b.c.55)
> 
> Looking closer at the strace reveals this:
> 
> openat(AT_FDCWD, "lib/modules/4.1.0-rc2+/kernel/drivers/media/platform/coda/coda.ko", O_WRONLY|O_CREAT|O_EXCL|O_NOCTTY|O_NONBLOCK|O_LARGEFILE|O_CLOEXEC, 0600) = -1 EEXIST (File exists)
> unlinkat(AT_FDCWD, "lib/modules/4.1.0-rc2+/kernel/drivers/media/platform/coda/coda.ko", 0) = 0
> openat(AT_FDCWD, "lib/modules/4.1.0-rc2+/kernel/drivers/media/platform/coda/coda.ko", O_WRONLY|O_CREAT|O_EXCL|O_NOCTTY|O_NONBLOCK|O_LARGEFILE|O_CLOEXEC, 0600) = 4
> write(4, "\177ELF\1\1\1\0\0\0\0\0\0\0\0\0\1\0(\0\1\0\0\0\0\0\0\0\0\0\0\0"..., 4096) = 4096
> ...
> write(4, "\300H\0\0\34\345\1\0\314H\0\0\34\345\1\0\330H\0\0\34\345\1\0<I\0\0\34\370\1\0"..., 7312) = 7312
> dup2(4, 4)                              = 4
> fstat64(4, {st_mode=0757221, st_size=13181880119170311768, ...}) = 21
> write(2, "tar: ", 5)                    = 5
> write(2, "lib/modules/4.1.0-rc2+/kernel/dr"..., 79) = 79
> write(2, "\n", 1)                       = 1
> fchown32(4, 0, 0)                       = 0
> fchmod(4, 0664)                         = 0
> close(4)                                = 0
> 
> Look closely at that fstat64, and you'll notice that it's returning crap.

This is likely fixed by:

  http://marc.info/?l=linux-nfs&m=143095122604344&w=2


> The file is not 11 exabytes, and it definitely would not have an octal
> mode of 0757221 at this point, having only just been created by the
> kernel.
> 
> For comparison, untaring onto a ramfs filesystem gives this:
> 
> openat(AT_FDCWD, "lib/modules/4.1.0-rc2+/kernel/drivers/media/platform/coda/coda.ko", O_WRONLY|O_CREAT|O_EXCL|O_NOCTTY|O_NONBLOCK|O_LARGEFILE|O_CLOEXEC, 0600) = 4
> write(4, "\177ELF\1\1\1\0\0\0\0\0\0\0\0\0\1\0(\0\1\0\0\0\0\0\0\0\0\0\0\0"..., 4096) = 4096
> ...
> write(4, "\300H\0\0\34\345\1\0\314H\0\0\34\345\1\0\330H\0\0\34\345\1\0<I\0\0\34\370\1\0"..., 7312) = 7312
> dup2(4, 4)                              = 4
> fstat64(4, {st_mode=S_IFREG|0600, st_size=83088, ...}) = 0
> utimensat(4, NULL, {{1431698625, 21832730}, {1431694673, 0}}, 0) = 0
> fchown32(4, 0, 0)                       = 0
> fchmod(4, 0664)                         = 0
> close(4)                                = 0
> 
> The reason for the strange dup2() above is this code in tar:
> 
>  /* Require that at least one of FD or FILE are valid.  Works around
>     a Linux bug where futimens (AT_FDCWD, NULL) changes "." rather
>     than failing.  */
>  if (!file)
>    {
>      if (fd < 0)
>        {
>          errno = EBADF;
>          return -1;
>        }
>      if (dup2 (fd, fd) != fd)
>        return -1;
>    }
> 
> The call path in tar is:
> 
> fdutimensat (fd, dir, file, ts, atflag)
> `-futimens (fd, ts)
>  `-fdutimens (fd, NULL, ts);
> 
> I'm assuming that the reason for this fstat() call is:
> 
> # if __linux__
>      /* As recently as Linux kernel 2.6.32 (Dec 2009), several file
>         systems (xfs, ntfs-3g) have bugs with a single UTIME_OMIT,
>         but work if both times are either explicitly specified or
>         UTIME_NOW.  Work around it with a preparatory [f]stat prior
>         to calling futimens/utimensat; fortunately, there is not much
>         timing impact due to the extra syscall even on file systems
>         where UTIME_OMIT would have worked.  FIXME: Simplify this in
>         2012, when file system bugs are no longer common.  */
>      if (adjustment_needed == 2)
>        {
>          if (fd < 0 ? stat (file, &st) : fstat (fd, &st))
>            return -1;
>          if (ts[0].tv_nsec == UTIME_OMIT)
>            ts[0] = get_stat_atime (&st);
>          else if (ts[1].tv_nsec == UTIME_OMIT)
>            ts[1] = get_stat_mtime (&st);
>          /* Note that st is good, in case utimensat gives ENOSYS.  */
>          adjustment_needed++;
>        }
> # endif /* __linux__ */
> # if HAVE_UTIMENSAT
>      if (fd < 0)
>        {
>          result = utimensat (AT_FDCWD, file, ts, 0);
> #  ifdef __linux__
>          /* Work around a kernel bug:
>             http://bugzilla.redhat.com/442352
>             http://bugzilla.redhat.com/449910
>             It appears that utimensat can mistakenly return 280 rather
>             than -1 upon ENOSYS failure.
>             FIXME: remove in 2010 or whenever the offending kernels
>             are no longer in common use.  */
>          if (0 < result)
>            errno = ENOSYS;
> #  endif /* __linux__ */
>          if (result == 0 || errno != ENOSYS)
>            {
>              utimensat_works_really = 1;
>              return result;
>            }
>        }
> # endif /* HAVE_UTIMENSAT */

--
Chuck Lever
chuck[dot]lever[at]oracle[dot]com




Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:44876 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752812AbcAPV7m (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Sat, 16 Jan 2016 16:59:42 -0500
Received: from int-mx14.intmail.prod.int.phx2.redhat.com (int-mx14.intmail.prod.int.phx2.redhat.com [10.5.11.27])
	by mx1.redhat.com (Postfix) with ESMTPS id D1E478DFE2
	for <linux-nfs@vger.kernel.org>; Sat, 16 Jan 2016 21:59:42 +0000 (UTC)
Subject: Re: [nfs-utils PATCH] Set right error after getaddrinfo fails bz
 1287468
To: Rinku Kothiya <rkothiya@redhat.com>
References: <1449635027-10764-1-git-send-email-rkothiya@redhat.com>
 <5667AE42.4090802@redhat.com>
Cc: Mohit Agrawal <moagrawa@redhat.com>, linux-nfs@vger.kernel.org
From: Steve Dickson <SteveD@redhat.com>
Message-ID: <569ABD4D.4090208@RedHat.com>
Date: Sat, 16 Jan 2016 16:59:41 -0500
MIME-Version: 1.0
In-Reply-To: <5667AE42.4090802@redhat.com>
Content-Type: text/plain; charset=windows-1252
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>



On 12/08/2015 11:29 PM, Rinku Kothiya wrote:
> 
> 
> From: Rinku Kothiya <rkothiya@redhat.com>
> 
> Signed-off-by: Rinku Kothiya <rkothiya@redhat.com>
> Signed-off-by: Mohit Agrawal <moagrawa@redhat.com>
> ---
>  nfs-utils-1.3.0-set-errno.patch | 29 +++++++++++++++++++++++++++++
>  nfs-utils.spec                  | 23 ++++++++++++-----------
>  2 files changed, 41 insertions(+), 11 deletions(-)
>  create mode 100644 nfs-utils-1.3.0-set-errno.patch
We finally got this committed! ;-) 

steved
> 
> diff --git a/nfs-utils-1.3.0-set-errno.patch b/nfs-utils-1.3.0-set-errno.patch
> new file mode 100644
> index 0000000..7c9d381
> --- /dev/null
> +++ b/nfs-utils-1.3.0-set-errno.patch
> @@ -0,0 +1,29 @@
> +diff -up nfs-utils-1.3.0/support/export/hostname.c.orig nfs-utils-1.3.0/support/export/hostname.c
> +--- nfs-utils-1.3.0/support/export/hostname.c.orig    2015-12-08 15:24:36.705047453 +0530
> ++++ nfs-utils-1.3.0/support/export/hostname.c    2015-12-08 15:25:46.614047453 +0530
> +@@ -179,11 +179,11 @@
> +     case 0:
> +         return ai;
> +     case EAI_SYSTEM:
> +-        xlog(D_GENERAL, "%s: failed to resolve %s: (%d) %m",
> ++        xlog(L_WARNING, "%s: failed to resolve %s: (%d) %m",
> +                 __func__, hostname, errno);
> +         break;
> +     default:
> +-        xlog(D_GENERAL, "%s: failed to resolve %s: %s",
> ++        xlog(L_WARNING, "%s: failed to resolve %s: %s",
> +                 __func__, hostname, gai_strerror(error));
> +         break;
> +     }
> +diff -up nfs-utils-1.3.0/support/nfs/client.c.orig nfs-utils-1.3.0/support/nfs/client.c
> +--- nfs-utils-1.3.0/support/export/client.c.orig    2015-12-08 17:08:45.469047453 +0530
> ++++ nfs-utils-1.3.0/support/export/client.c    2015-12-08 17:09:01.159047453 +0530
> +@@ -277,7 +277,7 @@
> +     if (htype == MCL_FQDN && !canonical) {
> +         ai = host_addrinfo(hname);
> +         if (!ai) {
> +-            xlog(L_ERROR, "Failed to resolve %s", hname);
> ++            xlog(L_WARNING, "Failed to resolve %s", hname);
> +             goto out;
> +         }
> +         hname = ai->ai_canonname;
> diff --git a/nfs-utils.spec b/nfs-utils.spec
> index 2fe1cc5..e881914 100644
> --- a/nfs-utils.spec
> +++ b/nfs-utils.spec
> @@ -2,7 +2,7 @@ Summary: NFS utilities and supporting clients and daemons for the kernel NFS ser
>  Name: nfs-utils
>  URL: http://sourceforge.net/projects/nfs
>  Version: 1.3.0
> -Release: 0.22%{?dist}
> +Release: 0.22%{?dist}_sfdc_01536441
>  Epoch: 1
>  
>  # group all 32bit related archs
> @@ -61,6 +61,7 @@ Patch100: nfs-utils-1.2.1-statdpath-man.patch
>  Patch101: nfs-utils-1.2.1-exp-subtree-warn-off.patch
>  Patch102: nfs-utils-1.2.3-sm-notify-res_init.patch
>  Patch103: nfs-utils-1.2.5-idmap-errmsg.patch
> +Patch104: nfs-utils-1.3.0-set-errno.patch
>  
>  Group: System Environment/Daemons
>  Provides: exportfs    = %{epoch}:%{version}-%{release}
> @@ -101,16 +102,12 @@ Requires: gssproxy >= 0.3.0-0
>  Conflicts: gssproxy < 0.3.0-10
>  
>  %description
> -The nfs-utils package provides a daemon for the kernel NFS server and
> -related tools, which provides a much higher level of performance than the
> -traditional Linux NFS server used by most users.
> -
> -This package also contains the showmount program.  Showmount queries the
> -mount daemon on a remote host for information about the NFS (Network File
> -System) server on the remote host.  For example, showmount can display the
> -clients which are mounted on that host.
> -
> -This package also contains the mount.nfs and umount.nfs program.
> +This RPM has been provided by Red Hat for testing purposes only and is
> +NOT supported for any other use. This RPM may contain changes that are
> +necessary for debugging but that are not appropriate for other uses,
> +or that are not compatible with third-party hardware or software. This
> +RPM should NOT be deployed for purposes other than testing and
> +debugging.
>  
>  %prep
>  %setup -q
> @@ -185,6 +182,7 @@ This package also contains the mount.nfs and umount.nfs program.
>  %patch101 -p1
>  %patch102 -p1
>  %patch103 -p1
> +%patch104 -p1
>  
>  # Remove .orig files
>  find . -name "*.orig" | xargs rm -f
> @@ -418,6 +416,9 @@ fi
>  /sbin/umount.nfs4
>  
>  %changelog
> +* Tue Dec  8 2015 Rinku Kothiya <rkothiya@redhat.com> 1.3.0-0.22_sfdc_01536441
> +- exportfs: Set the correct error type after getaddrinfo fails in host_addrinfo (bz 1287468)
> +
>  * Thu Dec  3 2015 Steve Dickson <steved@redhat.com> 1.3.0-0.22
>  - nfsidmap: Correct a failure to set key timeout values (bz 1161222)
>  - exportfs: Restore the EAI_NONAME check in host_pton() (bz 1276099)

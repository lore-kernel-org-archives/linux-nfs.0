Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-qg0-f51.google.com ([209.85.192.51]:38371 "EHLO
	mail-qg0-f51.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753100AbaKLSge (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 12 Nov 2014 13:36:34 -0500
MIME-Version: 1.0
In-Reply-To: <1414775040-4051-2-git-send-email-eguan@redhat.com>
References: <1414775040-4051-1-git-send-email-eguan@redhat.com> <1414775040-4051-2-git-send-email-eguan@redhat.com>
From: Steve French <smfrench@gmail.com>
Date: Wed, 12 Nov 2014 12:36:13 -0600
Message-ID: <CAH2r5muuJRcC4YgFkwUeUcCeEntgY+4POF8-bwmox64wXykuTw@mail.gmail.com>
Subject: Re: [PATCH v2 1/5] common: re-enable tests that require scratch dev
 on NFS
To: Eryu Guan <eguan@redhat.com>
Cc: fstests@vger.kernel.org,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>,
        "linux-cifs@vger.kernel.org" <linux-cifs@vger.kernel.org>,
        dros@primarydata.com
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

There should be a check to make sure SCRATCH_MNT exists before you
wipe the whole disk ....

+# remove all files in $SCRATCH_MNT, useful when testing on NFS/CIFS
+_scratch_cleanup_files()
+{
+       _scratch_mount
+       rm -rf $SCRATCH_MNT/*
+       _scratch_unmount
+}
+
so if no SCRATCH_MNT then this does rm -rf/*
right ... (and wipes out your whole system ...)

On Fri, Oct 31, 2014 at 12:03 PM, Eryu Guan <eguan@redhat.com> wrote:
> This commit disables tests requires scratch dev running on NFS
>
> c041421 xfstests: stop special casing nfs and udf
>
> Now re-enable them to get a larger test coverage on NFS.
>
> Signed-off-by: Eryu Guan <eguan@redhat.com>
> ---
>  common/rc | 22 +++++++++++++++++++---
>  1 file changed, 19 insertions(+), 3 deletions(-)
>
> diff --git a/common/rc b/common/rc
> index 747cf72..ae03712 100644
> --- a/common/rc
> +++ b/common/rc
> @@ -551,6 +551,14 @@ _mkfs_dev()
>      rm -f $tmp_dir.mkfserr $tmp_dir.mkfsstd
>  }
>
> +# remove all files in $SCRATCH_MNT, useful when testing on NFS/CIFS
> +_scratch_cleanup_files()
> +{
> +       _scratch_mount
> +       rm -rf $SCRATCH_MNT/*
> +       _scratch_unmount
> +}
> +
>  _scratch_mkfs()
>  {
>      case $FSTYP in
> @@ -558,7 +566,9 @@ _scratch_mkfs()
>          _scratch_mkfs_xfs $*
>         ;;
>      nfs*)
> -       # do nothing for nfs
> +       # unable to re-create NFS, just remove all files in $SCRATCH_MNT to
> +       # avoid EEXIST caused by the leftover files created in previous runs
> +        _scratch_cleanup_files
>         ;;
>      cifs)
>         # do nothing for cifs
> @@ -1032,8 +1042,14 @@ _require_scratch_nocheck()
>  {
>      case "$FSTYP" in
>         nfs*)
> -                 _notrun "requires a scratch device"
> -                ;;
> +               echo $SCRATCH_DEV | grep -q ":/" > /dev/null 2>&1
> +               if [ -z "$SCRATCH_DEV" -o "$?" != "0" ]; then
> +                       _notrun "this test requires a valid \$SCRATCH_DEV"
> +               fi
> +               if [ ! -d "$SCRATCH_MNT" ]; then
> +                       _notrun "this test requires a valid \$SCRATCH_MNT"
> +               fi
> +               ;;
>         cifs)
>                 _notrun "requires a scratch device"
>                 ;;
> --
> 1.9.3
>
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html



-- 
Thanks,

Steve

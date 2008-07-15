From: "Chuck Lever" <chuck.lever@oracle.com>
Subject: Re: [PATCH] umount: fix problems when portmap doesn't listen on UDP.
Date: Tue, 15 Jul 2008 11:42:59 -0400
Message-ID: <76bd70e30807150842t7f16ae1aq7be4530b8a690c58@mail.gmail.com>
References: <18556.40326.764642.102066@notabene.brown>
Reply-To: chucklever@gmail.com
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: "Steve Dickson" <SteveD@redhat.com>, linux-nfs@vger.kernel.org
To: "Neil Brown" <neilb@suse.de>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mu-out-0910.google.com ([209.85.134.188]:41103 "EHLO
	mu-out-0910.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753492AbYGOPnD (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 15 Jul 2008 11:43:03 -0400
Received: by mu-out-0910.google.com with SMTP id w8so934mue.1
        for <linux-nfs@vger.kernel.org>; Tue, 15 Jul 2008 08:43:00 -0700 (PDT)
In-Reply-To: <18556.40326.764642.102066-wvvUuzkyo1EYVZTmpyfIwg@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, Jul 15, 2008 at 8:52 AM, Neil Brown <neilb@suse.de> wrote:
>
> Another patch that can be pulled from
>     git://neil.brown.name/nfs-utils for-steved
>
> This and the next deal with problems with the new 'string based
> option' code when portmap can only be contacted via TCP.
>
> Some people seem to turn of string based options to avoid this
> problem:
>  https://bugs.launchpad.net/ubuntu/+bug/213444/comments/23
>
> This can partly be avoided using mountproto=tcp, but that
>  a/ shouldn't be needed (isn't with the old code)
>  b/ doesn't help the unmount case.
>
> This first patch make umount work better if mountproto=tcp was given
> to mount.
> The next patch gives mountproto=tcp to mount if it is needed.
>
> NeilBrown
>
>
>
> From 863af3c54b574a588ac6d7bd05a1f250784159bd Mon Sep 17 00:00:00 2001
> From: Neil Brown <neilb@suse.de>
> Date: Tue, 15 Jul 2008 17:36:57 +1000
>
> If portmap is not listening on UDP (as apparently happens with
> MS-Windows-Server2003R2SP2), then nfs mounts have to be mounted
> with -o mountproto=tcp to succeed.
>
> In this case a umount will still try UDP and will fail to contact the
> server.  It will still succeed with the local unmount (after a
> timeout) but exits with a non-zero exit status.  This causes
> /bin/mount to retry so we get a strange error about the filesystem
> not being mounted.
>
> So:
>  get umount to use tcp if "mountproto=tcp" appears in mtab
>  ignore any failure message from the server that would overwrite
>     a success message from the local umount syscall.
>
> Signed-off-by: NeilBrown <neilb@suse.de>
> ---
>  utils/mount/nfsumount.c |   19 +++++++++++++++----
>  1 files changed, 15 insertions(+), 4 deletions(-)
>
> diff --git a/utils/mount/nfsumount.c b/utils/mount/nfsumount.c
> index 285273b..9e1855d 100644
> --- a/utils/mount/nfsumount.c
> +++ b/utils/mount/nfsumount.c
> @@ -203,9 +203,15 @@ static int do_nfs_umount23(const char *spec, char *opts)
>                pmap->pm_vers = nfsvers_to_mnt(atoi(p+5));
>        if (opts && (p = strstr(opts, "mountvers=")) && isdigit(*(p+10)))
>                pmap->pm_vers = atoi(p+10);
> -       if (opts && (hasmntopt(&mnt, "udp") || hasmntopt(&mnt, "proto=udp")))
> +       if (opts && (hasmntopt(&mnt, "udp")
> +                    || hasmntopt(&mnt, "proto=udp")
> +                    || hasmntopt(&mnt, "mountproto=udp")
> +                   ))
>                pmap->pm_prot = IPPROTO_UDP;
> -       if (opts && (hasmntopt(&mnt, "tcp") || hasmntopt(&mnt, "proto=tcp")))
> +       if (opts && (hasmntopt(&mnt, "tcp")
> +                    || hasmntopt(&mnt, "proto=tcp")
> +                    || hasmntopt(&mnt, "mountproto=tcp")
> +                   ))
>                pmap->pm_prot = IPPROTO_TCP;

That's a good fix.  I have a patch later in my IPv6 series that does
this along with many other things.  Again, it's reasonable to address
this now.

>
>        if (!nfs_gethostbyname(hostname, &mnt_server.saddr)) {
> @@ -347,8 +353,13 @@ int nfsumount(int argc, char *argv[])
>        ret = 0;
>        if (mc) {
>                if (!lazy && strcmp(mc->m.mnt_type, "nfs4") != 0)
> -                       ret = do_nfs_umount23(mc->m.mnt_fsname, mc->m.mnt_opts);
> -               ret = del_mtab(mc->m.mnt_fsname, mc->m.mnt_dir) ?: ret;
> +                       /* We ignore the error from do_nfs_umount23.
> +                        * If the actual umount succeeds (in del_mtab),
> +                        * we don't want to signal an error, as that
> +                        * could cause /sbin/mount to retry!
> +                        */
> +                       do_nfs_umount23(mc->m.mnt_fsname, mc->m.mnt_opts);
> +               ret = del_mtab(mc->m.mnt_fsname, mc->m.mnt_dir);

Well, NFSv2/v3 UMNT is advisory only.  I think this should have been
ignoring the result of the UMNT RPC already anyway.  In fact, Solaris
doesn't even wait for the RPC reply... (and we shouldn't either --
that will just block the umount if the server isn't available).

But I've never seen /sbin/mount retry a umount request... so I don't
quite understand the new comment here.  I could be off base...

>        } else if (*spec != '/') {
>                if (!lazy)
>                        ret = do_nfs_umount23(spec, "tcp,v3");

If you're going to ignore the return code above, why not here as well?
 And you might as well make do_nfs_umount23() return void while you're
at it.

If you do that, you can move your new comment to a block comment in
front of do_nfs_umount23() -- that would be easier to read, I think.

> --
> 1.5.6.2

-- 
Chuck Lever

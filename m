Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-qg0-f53.google.com ([209.85.192.53]:36514 "EHLO
	mail-qg0-f53.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753425AbbJTIkr (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 20 Oct 2015 04:40:47 -0400
Received: by qgad10 with SMTP id d10so8500394qga.3
        for <linux-nfs@vger.kernel.org>; Tue, 20 Oct 2015 01:40:47 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <CALr0QzH-pcLs_ei2uB3AogPQWj-aNkLfQaPMc5J+XsTAFdSvVQ@mail.gmail.com>
References: <CALr0QzH-pcLs_ei2uB3AogPQWj-aNkLfQaPMc5J+XsTAFdSvVQ@mail.gmail.com>
Date: Tue, 20 Oct 2015 10:40:46 +0200
Message-ID: <CALr0QzFihE251wbVcoRQbYHxH5Ca_pA6NJJRvWaRr40-GZPUOA@mail.gmail.com>
Subject: Re: Nfsv4 referrals over bind mounted subtree, mount order problem
From: Prunk Dump <prunkdump@gmail.com>
To: linux-nfs@vger.kernel.org
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

2015-10-19 14:09 GMT+02:00 Prunk Dump <prunkdump@gmail.com>:
> Hello NFS team !
>
> I have sometimes trouble using NFSv4 referrals and I don't really
> understand where the problem come from. Here the configuration steps
> that expose the situation :
>
> ---------------------------------------------
> 1) standard nfs4 export (works)
> ---------------------------------------------
> My server export a file tree like this :
>
> /myexport/dirA
> /myexport/dirB
>
> To do this I have bind mounted as usual the tree root in the NFS root :
>
> mount --bind /myexport /srv/nfs4/myexport
> /srv/nfs4/myexport
> 172.16.0.0/16(sec=krb5,rw,async,no_subtree_check)  (in /etc/exports)
>
> Everything is OK.
>
> -----------------------------------------------------------------
> 2) dirA redirection, bind mounted to itself (works)
> -----------------------------------------------------------------
>
> I now want to redirect dirA to another server "anotherserver". So I
> bind mount the dirA folder to itself.
>
> mount --bind /srv/nfs4/myexport/dirA /srv/nfs4/myexport/dirA
> /srv/nfs4/myexport/dirA
> 172.16.0.0/16(refer=/myexport/dirA@anotherserver,sec=krb5,rw,async,no_subtree_check)
>  (in /etc/exports)
>
> Now the redirection works as expected.
>
> ----------------------------------------------------------------------------------
> 3) mount remote dirA on the original server (first problem)
> -----------------------------------------------------------------------------------
>
> But the original server need to keep access to the "dirA" files. So I
> need to mount the redirected "dirA@anotherserver" tree on "myserver".
>
> mount -t nfs4 -o sec=krb5 anotherserver:/myexport/dirA  /myexport/dirA
>
> But as /myexport is bind mounted, this command create another mount
> point on /srv/nfs4/myexport/dirA.
>
> # mount
> ...
> anotherserver:/myexport/dirA on /myexport/dirA ...
> anotherserver:/myexport/dirA on /srv/nfs4/myexport/dirA ...
>
> So, as this command create a mount point at the right position, where
> the redirection start, I initially think that the initial self binded
> mount /srv/nfs4/myexport/dirA is useless now. So I keep the only the
> nfs4 mount.
>
> But strangely the redirection does not works anymore. And I don't
> understand where is the problem.
>
> ######
> first solution tried : mount remote to /myexport/dirA, adding an
> additional bind mount (don't works)
> ######
>
> I tried to add another bind mount over the nfs mount. I now have four
> mount points !
>
> anotherserver:/myexport/dirA on /myexport/dirA ...
> anotherserver:/myexport/dirA on /srv/nfs4/myexport/dirA ...
> anotherserver:/myexport/dirA on /srv/nfs4/myexport/dirA ...
> anotherserver:/myexport/dirA on /myexport/dirA ...
>
> But this does not solve the problem. No redirection.
>
> ######
> second solution tried : mount remote nfs directly to
> /srv/nfs4/myexport/dirA (works !)
> ######
>
> If a mount the remote share directly to /srv/nfs4/myexport/dirA :
>
> mount -t nfs4 -o sec=krb5 anotherserver:/myexport/dirA /srv/nfs4/myexport/dirA
>
> as /myexport is bind mounted, this create another mount point on
> /myexport/dirA :
>
> # mount
> anotherserver:/myexport/dirA on /srv/nfs4/myexport/dirA ...
> anotherserver:/myexport/dirA on /myexport/dirA ...
>
> But the mount points are in reverse order now.  And in this case it
> works ! I can access the remote share in /myexport/dirA. And the other
> clients are redirected to anotherserver.
>
> But I can't understand why...
>
> Why the mount order is so important ?
>
> Thanks !
>
> Baptiste.

Excuse me !

In reality the solution proposed above does not work ! The NFS server
say :  "/myexport/dirA does not support NFS export" as it is a NFS
mounted filesystem.

Can anyone help me !?

Is this possible to avoid duplicating mount point when mounting over
bind mount ?

/myexport and /srv/nfs4/myexport are the same mount. But I want to do
a nfs4 mount on /myexpot/dirA and a bind mount on
/srv/nfs4/myexport/dirA.

Thanks.

Baptiste.

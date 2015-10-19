Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-qg0-f47.google.com ([209.85.192.47]:33077 "EHLO
	mail-qg0-f47.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752654AbbJSMJW (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 19 Oct 2015 08:09:22 -0400
Received: by qgeo38 with SMTP id o38so110559603qge.0
        for <linux-nfs@vger.kernel.org>; Mon, 19 Oct 2015 05:09:21 -0700 (PDT)
MIME-Version: 1.0
Date: Mon, 19 Oct 2015 14:09:21 +0200
Message-ID: <CALr0QzH-pcLs_ei2uB3AogPQWj-aNkLfQaPMc5J+XsTAFdSvVQ@mail.gmail.com>
Subject: Nfsv4 referrals over bind mounted subtree, mount order problem
From: Prunk Dump <prunkdump@gmail.com>
To: linux-nfs@vger.kernel.org
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hello NFS team !

I have sometimes trouble using NFSv4 referrals and I don't really
understand where the problem come from. Here the configuration steps
that expose the situation :

---------------------------------------------
1) standard nfs4 export (works)
---------------------------------------------
My server export a file tree like this :

/myexport/dirA
/myexport/dirB

To do this I have bind mounted as usual the tree root in the NFS root :

mount --bind /myexport /srv/nfs4/myexport
/srv/nfs4/myexport
172.16.0.0/16(sec=krb5,rw,async,no_subtree_check)  (in /etc/exports)

Everything is OK.

-----------------------------------------------------------------
2) dirA redirection, bind mounted to itself (works)
-----------------------------------------------------------------

I now want to redirect dirA to another server "anotherserver". So I
bind mount the dirA folder to itself.

mount --bind /srv/nfs4/myexport/dirA /srv/nfs4/myexport/dirA
/srv/nfs4/myexport/dirA
172.16.0.0/16(refer=/myexport/dirA@anotherserver,sec=krb5,rw,async,no_subtree_check)
 (in /etc/exports)

Now the redirection works as expected.

----------------------------------------------------------------------------------
3) mount remote dirA on the original server (first problem)
-----------------------------------------------------------------------------------

But the original server need to keep access to the "dirA" files. So I
need to mount the redirected "dirA@anotherserver" tree on "myserver".

mount -t nfs4 -o sec=krb5 anotherserver:/myexport/dirA  /myexport/dirA

But as /myexport is bind mounted, this command create another mount
point on /srv/nfs4/myexport/dirA.

# mount
...
anotherserver:/myexport/dirA on /myexport/dirA ...
anotherserver:/myexport/dirA on /srv/nfs4/myexport/dirA ...

So, as this command create a mount point at the right position, where
the redirection start, I initially think that the initial self binded
mount /srv/nfs4/myexport/dirA is useless now. So I keep the only the
nfs4 mount.

But strangely the redirection does not works anymore. And I don't
understand where is the problem.

######
first solution tried : mount remote to /myexport/dirA, adding an
additional bind mount (don't works)
######

I tried to add another bind mount over the nfs mount. I now have four
mount points !

anotherserver:/myexport/dirA on /myexport/dirA ...
anotherserver:/myexport/dirA on /srv/nfs4/myexport/dirA ...
anotherserver:/myexport/dirA on /srv/nfs4/myexport/dirA ...
anotherserver:/myexport/dirA on /myexport/dirA ...

But this does not solve the problem. No redirection.

######
second solution tried : mount remote nfs directly to
/srv/nfs4/myexport/dirA (works !)
######

If a mount the remote share directly to /srv/nfs4/myexport/dirA :

mount -t nfs4 -o sec=krb5 anotherserver:/myexport/dirA /srv/nfs4/myexport/dirA

as /myexport is bind mounted, this create another mount point on
/myexport/dirA :

# mount
anotherserver:/myexport/dirA on /srv/nfs4/myexport/dirA ...
anotherserver:/myexport/dirA on /myexport/dirA ...

But the mount points are in reverse order now.  And in this case it
works ! I can access the remote share in /myexport/dirA. And the other
clients are redirected to anotherserver.

But I can't understand why...

Why the mount order is so important ?

Thanks !

Baptiste.

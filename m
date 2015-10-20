Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([173.255.197.46]:50925 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751285AbbJTSal (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 20 Oct 2015 14:30:41 -0400
Date: Tue, 20 Oct 2015 14:30:39 -0400
To: Prunk Dump <prunkdump@gmail.com>
Cc: linux-nfs@vger.kernel.org
Subject: Re: Nfsv4 referrals over bind mounted subtree, mount order problem
Message-ID: <20151020183039.GB21687@fieldses.org>
References: <CALr0QzH-pcLs_ei2uB3AogPQWj-aNkLfQaPMc5J+XsTAFdSvVQ@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <CALr0QzH-pcLs_ei2uB3AogPQWj-aNkLfQaPMc5J+XsTAFdSvVQ@mail.gmail.com>
From: bfields@fieldses.org (J. Bruce Fields)
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, Oct 19, 2015 at 02:09:21PM +0200, Prunk Dump wrote:
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

I'm not sure why you're doing this.

(It used to be necessary to do something like this (with the addition of
an fsid=0 option on the root export) for NFSv4 exports, but that hasn't
been necessary for a while.  You can skip this step and just mount
server:/myexport/dirA from the client.

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

I'd recommend mounting it someplace that isn't under an export,
otherwise this will get a bit complicated.

--b.

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
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

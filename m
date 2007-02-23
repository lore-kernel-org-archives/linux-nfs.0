From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: LinuxFC6 NFS client problem: cannot distinguish
	between	sub-volumes
Date: Fri, 23 Feb 2007 00:42:39 -0500
Message-ID: <1172209359.13706.20.camel@heimdal.trondhjem.org>
References: <mailman.653.1172186165.14402.nfs@lists.sourceforge.net>
	<Pine.GSO.4.64.0702221830010.4782@mnc.zngu.hop.pn>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net
To: Joseph Tam <tam@math.ubc.ca>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1HKTCo-0003va-86
	for nfs@lists.sourceforge.net; Thu, 22 Feb 2007 21:42:54 -0800
Received: from pat.uio.no ([129.240.10.15]
	ident=[U2FsdGVkX18juMlBqNvapE69/A9i6VLVKB1IhUDd0nQ=])
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1HKTCp-00021H-P4
	for nfs@lists.sourceforge.net; Thu, 22 Feb 2007 21:42:56 -0800
In-Reply-To: <Pine.GSO.4.64.0702221830010.4782@mnc.zngu.hop.pn>
List-Id: "Discussion of NFS under Linux development, interoperability,
	and testing." <nfs.lists.sourceforge.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=nfs>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
Sender: nfs-bounces@lists.sourceforge.net
Errors-To: nfs-bounces@lists.sourceforge.net

On Thu, 2007-02-22 at 18:35 -0800, Joseph Tam wrote:
> I have two problems that seem to stem from the same cause.
> 
> The situation is that I have a NetApp filer (but it also exhibits these
> problems when using a Solaris NFS server) that has a large volume, with individual
> sub-volumes or qtrees (should the term here be "logical volumes") which
> behave like individual filesystems (i.e. they can be mounted individually,
> have theor own quotas, etc.).
> 
> The logical volumes are mounted on the LinuxFC6 client (kernel 2.6.19-1.2911.fc6)
> via automount (NFSv3).
> 
> However, the Linux FC6 client NFS cannot distinguish between these automounted
> directories (the FSID in /proc/fs/nfsfs/volumes seem to be the same) with the
> following consequences:
> 
>  	- quota reporting is curtailed.  It reports on maybe the first
>  	mounted filesystem, and ignored the rest since it thinks it
>  	it has the same quotas.
> 
>  	- the order of mounting becomes important: the first mounted
>  	filesystem has its mount options override the mount options for
>  	later mounts.
> 
> The first problem has been partially fixed: the author of quota-tools (Jan Kara)
> has quite kindly wrote an -A option to his quota program that will work
> around this (I think it uses a fallback method of doing a stat() call).
> 
> However, I cannot seem to cope with the second.  An example of this
> would be having read-only mounts (like /usr/local) and read/write home
> directories (/nfs/user1) both being mounted.
> 
> If this happens,
> 
>  	mount -o rw nfs-server:/vol/home/user1 /nfs/user1
>  	mount -o ro nfs-server:/vol/local/linux /nfs/local
> 
> then /nfs/local is actually mounted r/w (according to /proc/mounts) but this
> is workable since the NFS server will enforce the r/o policy.  If the order
> is reversed, this is disastrous as the user will end up with a non-writable
> home directory.
> 
> Has any of the recent patches addressed this problem (I see hints like
> 
>  	http://marc.theaimsgroup.com/?l=linux-nfs&m=117041136218203&w=2
>  	http://marc.theaimsgroup.com/?l=linux-nfs&m=117126072001306&w=2
> 
> ), but I'm not technically savvy enough about NFS to figure out whether these
> patches help.  I've also tried putting fsid=xxx in the automount maps, but
> this doesn't seem to get passed to the client (fsid= is only a /etc/exports
> option, right?).  There doesn't seem anything on the server side that can
> help me either.
> 
> So I'm stuck.  Help, please?

Sorry, but we're not able to support this type of configuration at the
present time. There are plans to support per-mountpoint read only flags
at the VFS level (see the patches by Dave Hansen that were recently
posted on the lkml and linux-fsdevel mailing lists). Those patches will
allow you to do this not only for NFS, but also for local filesystems
(i.e. will allow you to do 'mount --bind -oro /foo/bar /baz'). Until
they are merged into mainline, then the ro/rw flag will apply to the
entire filesystem that is exported by the server.

Cheers
  Trond


-------------------------------------------------------------------------
Take Surveys. Earn Cash. Influence the Future of IT
Join SourceForge.net's Techsay panel and you'll get the chance to share your
opinions on IT & business topics through brief surveys-and earn cash
http://www.techsay.com/default.php?page=join.php&p=sourceforge&CID=DEVDEV
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs

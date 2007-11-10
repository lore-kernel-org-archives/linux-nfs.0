From: devzero@web.de
Subject: Re: nfs exports & bind mounts
Date: Sat, 10 Nov 2007 23:39:54 +0100
Message-ID: <2077851898@web.de>
Mime-Version: 1.0
Content-Type: text/plain; charset="iso-8859-15"
Cc: NFS@lists.sourceforge.net
To: Trond Myklebust <trond.myklebust@fys.uio.no>
Return-path: <nfs-bounces@lists.sourceforge.net>
List-Id: "Discussion of NFS under Linux development, interoperability,
	and testing." <nfs.lists.sourceforge.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=nfs>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
Sender: nfs-bounces@lists.sourceforge.net
Errors-To: nfs-bounces@lists.sourceforge.net

ok, that explains why bind-mounting and exporting directories works, but no=
t files.

thanks!
 =

> -----Urspr=FCngliche Nachricht-----
> Von: Trond Myklebust <trond.myklebust@fys.uio.no>
> Gesendet: 10.11.07 23:26:35
> An: devzero@web.de
> CC: NFS@lists.sourceforge.net
> Betreff: Re: [NFS] nfs exports & bind mounts


> =

> =

> On Sat, 2007-11-10 at 22:36 +0100, devzero@web.de wrote:
> > Hi !
> > =

> > i think everybody knows bind mounts.
> > =

> > i can do:
> > =

> > touch /otherpath/dummyfile
> > mount -bind /path/file /otherpath/dummyfile
> > =

> > so /path/file becomes accessible via /otherpath/dummyfile - dummyfile h=
as the same size as file after successful bind-mount
> > =

> > i can loopback-mount /otherpath/dummyfile to /otherpath/mnt if file/dum=
myfile contains a filesystem
> > =

> > when i export /otherpath via nfs (crossmnt), from the client side i can=
 access the contents of the filesystem inside file/dummyfile via /otherpath=
/mnt  - but i cannot access the contents of dummyfile itself, i.e. the bind=
-mount seems to get lost on export.
> > =

> > can someone tell if this is expected behaviour or if this is a bug ?
> =

> The NFS client will not cross a mount point unless the target is a
> directory. That is not a bug, it is expected behaviour.
> =

> Trond
> =

> =



______________________________________________________________________
XXL-Speicher, PC-Virenschutz, Spartarife & mehr: Nur im WEB.DE Club!		=

Jetzt testen! http://produkte.web.de/club/?mc=3D021130


-------------------------------------------------------------------------
This SF.net email is sponsored by: Splunk Inc.
Still grepping through log files to find problems?  Stop.
Now Search log events and configuration files using AJAX and a browser.
Download your FREE copy of Splunk now >> http://get.splunk.com/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs

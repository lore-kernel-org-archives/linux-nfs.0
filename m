From: "Lever, Charles" <Charles.Lever@netapp.com>
Subject: RE: NFSv4 and client caching to local disk?
Date: Fri, 28 Mar 2003 07:16:16 -0800
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <6440EA1A6AA1D5118C6900902745938E07D55473@black.eng.netapp.com>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Cc: <nfs@lists.sourceforge.net>
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from mx01.netapp.com ([198.95.226.53])
	by sc8-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 18yvak-0000TQ-00
	for <nfs@lists.sourceforge.net>; Fri, 28 Mar 2003 07:16:26 -0800
To: "James Pearson" <james-p@moving-picture.com>
Errors-To: nfs-admin@lists.sourceforge.net
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
List-Id: Discussion of NFS under Linux development,
	interoperability,
	and testing. <nfs.lists.sourceforge.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=nfs>

hi james-

> I'm trying to find out more about 'cachefs' type file systems=20
> that can=20
> cache NFS data to a client's local disk - I've come across a=20
> couple of=20
> references that seem to indicate that this may be possible with NFSv4.
>=20
> Does (will?) the Linux NFSv4 client support this feature?

Sun implemented cachefs on Solaris for earlier versions of NFS.
it really has nothing to do with which version of NFS that is
in use.

there is sporadic interest in a cachefs on Linux, and i know of
at least one generic prototype.  a specific implementation of
client-side disk caching that is available today is contained
in the Linux OpenAFS client (known as the AFS cache manager).

cachefs becomes rather more interesting when used in conjunction
with NFSv4 file delegations -- that makes NFS behave in a fashion
similar to AFS client-side disk caching with callbacks.

there currently is no explicit plan to implement cachefs by the
team that is working on NFSv4 for Linux.  a disk cache has
rather limited usefulness compared to a memory cache.  what is
your application for it?



-------------------------------------------------------
This SF.net email is sponsored by:
The Definitive IT and Networking Event. Be There!
NetWorld+Interop Las Vegas 2003 -- Register today!
http://ads.sourceforge.net/cgi-bin/redirect.pl?keyn0001en
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs

From: Ragnar =?iso-8859-15?Q?Kjo=F8rstad?= <nfs@ragnark.vestdata.no>
Subject: Re: failover-NFS server problem
Date: Tue, 20 Apr 2004 01:10:18 +0200
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <20040419231018.GU22684@vestdata.no>
References: <5.1.0.14.2.20040419123002.00acb6a8@pop.ncsa.uiuc.edu>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Cc: nfs@lists.sourceforge.net, alan Robertson <alanr@unix.sh>,
	bruce.allan@us.ibm.com
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.12] helo=sc8-sf-mx2.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1BFhuN-0005jV-7V
	for nfs@lists.sourceforge.net; Mon, 19 Apr 2004 16:10:35 -0700
Received: from stine.vestdata.no ([195.204.68.10])
	by sc8-sf-mx2.sourceforge.net with esmtp (TLSv1:DES-CBC3-SHA:168)
	(Exim 4.30)
	id 1BFhuM-0004i6-ER
	for nfs@lists.sourceforge.net; Mon, 19 Apr 2004 16:10:34 -0700
To: Guochun Shi <gshi@ncsa.uiuc.edu>
In-Reply-To: <5.1.0.14.2.20040419123002.00acb6a8@pop.ncsa.uiuc.edu>
Errors-To: nfs-admin@lists.sourceforge.net
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Id: Discussion of NFS under Linux development,
	interoperability,
	and testing. <nfs.lists.sourceforge.net>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=nfs>

On Mon, Apr 19, 2004 at 01:14:24PM -0500, Guochun Shi wrote:
> I ran into some problem in running Connectathon with NFS. The scenario =
I want to test is if NFS works fine in case of the server is failed back =
and forth (linuxHA controls that. Linux-Ha is in www.linux-ha.org ). The =
following is my setup:
>=20
> 1. Machine A and Machine B are servers, there is one and only server ac=
tive any time. The active machine has a floating IP as the service IP.
> 2. Machine C is the client. It mounts a directory from the floating IP
> 3. Machine A and Machine B have a fiber channel share disk. The exporte=
d filesystem resides in shared disk. On both machines,=20
> /var/lib/nfs is a symbolic link to a directory in the shared disk.
>=20
> all machines are running Redhat 9, kernel 2.4.26, with nfs-utils-1.0.1-=
2.9
>=20
> The server will switch between A and B, in each switching:
> the original server will stop nfs, stop nfslock, umount from the shared=
 disk and give out the floating ip,=20
> the backup server will grab the floaing ip, mount the shared disk, star=
t nfslock and start nfs

Did you modify the init-scripts to supply the "-n" option to rpc.statd?

Statd needs to use the same name on both servers (the one used by your
clients to mount filesystems) for locking to work accross failures.

The init-script in nfs-utils in RH9 doesn't support this. Take a look at
the init-script in Fedora Core 1 or the official nfs-utils package.
(Possible you can just upgrade to FC1's nfs-utils 1.0.6.

Then you need to change the sysconfig-files to set the STATD_HOSTNAME
variable to match the name of the floating IP.=20


--=20
Ragnar Kjo=F8rstad
Software Engineer
Scali - http://www.scali.com
High Performance Clustering


-------------------------------------------------------
This SF.Net email is sponsored by: IBM Linux Tutorials
Free Linux tutorial presented by Daniel Robbins, President and CEO of
GenToo technologies. Learn everything from fundamentals to system
administration.http://ads.osdn.com/?ad_id=1470&alloc_id=3638&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs

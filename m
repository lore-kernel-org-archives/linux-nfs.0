From: Guochun Shi <gshi@ncsa.uiuc.edu>
Subject: Re: failover-NFS server problem
Date: Tue, 18 May 2004 19:37:45 -0500
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <5.1.0.14.2.20040518193315.0442a150@pop.ncsa.uiuc.edu>
References: <5.1.0.14.2.20040419123002.00acb6a8@pop.ncsa.uiuc.edu>
 <5.1.0.14.2.20040419123002.00acb6a8@pop.ncsa.uiuc.edu> <20040419231018.GU22684@vestdata.no>
Mime-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1BQF5i-000651-60
	for nfs@lists.sourceforge.net; Tue, 18 May 2004 17:37:50 -0700
Received: from mail.ncsa.uiuc.edu ([141.142.2.28])
	by sc8-sf-mx1.sourceforge.net with esmtp (Exim 4.30)
	id 1BQF5h-0000gO-RC
	for nfs@lists.sourceforge.net; Tue, 18 May 2004 17:37:49 -0700
Received: from gship4.ncsa.uiuc.edu (gship4.ncsa.uiuc.edu [141.142.98.127])
	by mail.ncsa.uiuc.edu (8.11.7/8.11.7) with ESMTP id i4J0bgx06645
	for <nfs@lists.sourceforge.net>; Tue, 18 May 2004 19:37:42 -0500
To: nfs@lists.sourceforge.net
In-Reply-To: <20040419231018.GU22684@vestdata.no>
References: <5.1.0.14.2.20040419123002.00acb6a8@pop.ncsa.uiuc.edu>
 <5.1.0.14.2.20040419123002.00acb6a8@pop.ncsa.uiuc.edu>
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

I added the "-n clustername" in the /etc/init.d/nfslockd and ran test again,=
 same results.

I also tried multiple clients competing the same file lock tests, they all=
 failed. A detail description is here
http://wiki.trick.ca/linux-ha/HaNFS

any comment and suggestion is welcome

Thanks
Guochun


At 01:10 AM 4/20/2004 +0200, Ragnar =3D?iso-8859-15?Q?Kjo=3DF8rstad?=3D=
 wrote:
>On Mon, Apr 19, 2004 at 01:14:24PM -0500, Guochun Shi wrote:
>> I ran into some problem in running Connectathon with NFS. The scenario I=
 want to test is if NFS works fine in case of the server is failed back and=
 forth (linuxHA controls that. Linux-Ha is in www.linux-ha.org ). The=
 following is my setup:
>>=20
>> 1. Machine A and Machine B are servers, there is one and only server=
 active any time. The active machine has a floating IP as the service IP.
>> 2. Machine C is the client. It mounts a directory from the floating IP
>> 3. Machine A and Machine B have a fiber channel share disk. The exported=
 filesystem resides in shared disk. On both machines,=20
>> /var/lib/nfs is a symbolic link to a directory in the shared disk.
>>=20
>> all machines are running Redhat 9, kernel 2.4.26, with=
 nfs-utils-1.0.1-2.9
>>=20
>> The server will switch between A and B, in each switching:
>> the original server will stop nfs, stop nfslock, umount from the shared=
 disk and give out the floating ip,=20
>> the backup server will grab the floaing ip, mount the shared disk, start=
 nfslock and start nfs
>
>Did you modify the init-scripts to supply the "-n" option to rpc.statd?
>
>Statd needs to use the same name on both servers (the one used by your
>clients to mount filesystems) for locking to work accross failures.
>
>The init-script in nfs-utils in RH9 doesn't support this. Take a look at
>the init-script in Fedora Core 1 or the official nfs-utils package.
>(Possible you can just upgrade to FC1's nfs-utils 1.0.6.
>
>Then you need to change the sysconfig-files to set the STATD_HOSTNAME
>variable to match the name of the floating IP.=20
>
>
>--=20
>Ragnar Kjo=F8rstad
>Software Engineer
>Scali - http://www.scali.com
>High Performance Clustering



-------------------------------------------------------
This SF.Net email is sponsored by: SourceForge.net Broadband
Sign-up now for SourceForge Broadband and get the fastest
6.0/768 connection for only $19.95/mo for the first 3 months!
http://ads.osdn.com/?ad_id=2562&alloc_id=6184&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs

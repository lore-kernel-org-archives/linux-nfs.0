From: Vincent ROQUETA <vincent.roqueta@ext.bull.net>
Subject: Re: Re: NFSv4 stability: export unused a night
Date: Thu, 5 Feb 2004 18:13:46 +0100
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <200402051813.46504.vincent.roqueta@ext.bull.net>
Reply-To: vincent.roqueta@ext.bull.net
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Cc: Linux NFS Mailing List <nfs@lists.sourceforge.net>
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.12] helo=sc8-sf-mx2.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1Aon2V-0001cY-Ah
	for nfs@lists.sourceforge.net; Thu, 05 Feb 2004 09:11:43 -0800
Received: from ecbull20.frec.bull.fr ([129.183.4.3])
	by sc8-sf-mx2.sourceforge.net with esmtp (Exim 4.30)
	id 1Aon2U-0002o9-HP
	for nfs@lists.sourceforge.net; Thu, 05 Feb 2004 09:11:42 -0800
To: Vincent ROQUETA <vincent.roqueta@ext.bull.net>
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


Le Jeudi 05 F=E9vrier 2004 17:13, Vincent ROQUETA a =E9crit :
> Le Jeudi 05 F=E9vrier 2004 14:07, Vincent ROQUETA a =E9crit :
> > 1/
> >
> > When I lived yesterday server computer test was up, configured with 1
> > export partition.
> > This export was moutable from the client side.
> >
> > Threre was no reboot of the server this night.
> > This morning, I was unable to mount the exported directory.
> >
> > After reboot, all was OK.
>
> More precisions. I have reproduced the bug:
>
> 1/ Server up, client up
> 2/ client mount a nfs4 fs.
> 3/ reboot client (without umounting )
> 4/ Client can't mount nfs , server answer: permission denied

Still answering to my owns questions ;)
I yet have the permissions (I don't really understand what I have changed...
 ) remounting looks to work (I don't have "permission denied" and the mount
 returns without errors), but I can't see thedirectory correctly...

After a reboot and re mounting the partition:
[root@roquetav root]# ls /mnt/nfs/vincent/
[root@roquetav root]#

and without rebooting:
[root@roquetav root]# ls /mnt/nfs/vincent/
913                                module-init-tools-3.0-pre7
bind-9.2.1                          modules-init-tools.tgz
bind-9.2.1-16.i386.rpm              named
bind9_9.2.1.orig.tar.gz             nfs4st
bind-utils-9.2.1-16.i386.rpm        nfs-utils-1.0.6
binutils-2.13.90.0.18-9.i386.rpm    nfs-utils-1.0.6-patchs.tgz
exportnfs                           nfs-utils-1.0.6.tar.gz
gssd                                ntp
gssd-2004-01-20.tar.gz              pynfs-citi-2004-01-30.tar.gz
idmapd-1.5                          redhat-config-bind-1.9.0-13.noarch.rpm
krb5-configs-1.1.1-40.i386.rpm      start_kerberos
krb5-devel-1.2.7-10.i386.rpm        suite-tests
krb5-libs-1.2.7-10.i386.rpm         test
krb5-libs-1.3.1-7.i386.rpm          test~
krb5-server-1.2.7-10.i386.rpm       tests
krb5-workstation-1.2.7-10.i386.rpm  util-linux-2.11z
krb5-workstation-1.3.1-7.i386.rpm   util-linux-2.11z.tar
linux-2.6.1-CITI_NFS4_ALL.patch     ypbind-1.11-4.i386.rpm
linux.tgz

Logs:

=46eb  5 18:01:36 roquetav kernel: nfs_stat_to_errno: bad nfs status return
value: 10011
=46eb  5 18:02:16 roquetav last message repeated 2 times
=46eb  5 18:03:36 roquetav last message repeated 4 times
=46eb  5 18:04:56 roquetav last message repeated 4 times
=46eb  5 18:06:16 roquetav last message repeated 4 times
=46eb  5 18:07:36 roquetav last message repeated 4 times

=2D------------------------------------------------------



-------------------------------------------------------
The SF.Net email is sponsored by EclipseCon 2004
Premiere Conference on Open Tools Development and Integration
See the breadth of Eclipse activity. February 3-5 in Anaheim, CA.
http://www.eclipsecon.org/osdn
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs

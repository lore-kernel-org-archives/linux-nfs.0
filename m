From: Vincent ROQUETA <vincent.roqueta@ext.bull.net>
Subject: Re: Poor NFS performance, kernel 2.6.6.
Date: Wed, 2 Jun 2004 15:14:00 +0200
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <200406021514.00838.vincent.roqueta@ext.bull.net>
References: <1086179633.3325.0.camel@tesla.mmt.bellhowell.com>
Reply-To: vincent.roqueta@ext.bull.net
Mime-Version: 1.0
Content-Type: text/plain;
  charset="utf-8"
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.12] helo=sc8-sf-mx2.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1BVVW7-0007Xr-Ds
	for nfs@lists.sourceforge.net; Wed, 02 Jun 2004 06:10:51 -0700
Received: from ecbull20.frec.bull.fr ([129.183.4.3])
	by sc8-sf-mx2.sourceforge.net with esmtp (Exim 4.30)
	id 1BVVW5-0007I2-OX
	for nfs@lists.sourceforge.net; Wed, 02 Jun 2004 06:10:50 -0700
To: Jeffrey Layton <jtlayton@poochiereds.net>, nfs@lists.sourceforge.net
In-Reply-To: <1086179633.3325.0.camel@tesla.mmt.bellhowell.com>
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

Le Mercredi 02 Juin 2004 14:33, Jeffrey Layton a =C3=A9crit :
> I haven't been following this thread closely, but figured I'd chime in
> with my own experience with this. Here's a rather unscientific test,
> dd'ing to a file on an NFS-mounted filesystem. Mount options are:
>
> udp,soft,intr,nfsvers=3D3
>
> (I'm using UDP as I'm trying to set up a HA-NFS server, and the clients
> seem to recover much faster when using UDP as a transport).
>
> With a 2.4 kernel server:
>
> % time dd if=3D/dev/zero of=3D./testfile bs=3D100M count=3D1
> 1+0 records in
> 1+0 records out
> 104857600 bytes transferred in 11.806235 seconds (8881544 bytes/sec)
> dd if=3D/dev/zero of=3D./testfile bs=3D100M count=3D1  0.00s user 0.28s s=
ystem
> 2% cpu 12.147 total
>
> With a 2.6 kernel server:
>
> % time dd if=3D/dev/zero of=3D./testfile bs=3D100M count=3D1
> 1+0 records in
> 1+0 records out
> 104857600 bytes transferred in 66.997572 seconds (1565096 bytes/sec)
> dd if=3D/dev/zero of=3D./testfile bs=3D100M count=3D1  0.00s user 0.29s s=
ystem
> 0% cpu 1:07.06 total
>
>
> The machines are different hardware, but local write performance is
> pretty comparable (in fact the 2.6 box is a faster machine, and is
> currently less utilized than the 2.4 kernel machine). Both are using
> reiserfs as the underlying filesystem.
>
> Write performance in this cursory test was 10x worse! Clearly, there's
> some sort of problem with NFS on 2.6. I'll be happy to send in what info
> I can. My 2.4 machine is currently a production box, but I can run an
> instrumented kernel, etc. on the 2.6 box in the near future if anyone
> here can guide me on what I can do to help.
>
> -- Jeff
>

What appends with linux 2.6.6?
Is NFSv4 enabled?
Can you use bonnie / IOzone and repport activity?
 (-> http://nfsv4.bullopensource.org/tools/sondage.php for performances too=
ls=20
)
=20


-------------------------------------------------------
This SF.Net email is sponsored by the new InstallShield X.

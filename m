From: Vincent ROQUETA <vincent.roqueta@ext.bull.net>
Subject: Re :Re: NFSv4  and vi
Date: Mon, 23 Feb 2004 14:01:12 +0100
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <200402231401.12339.vincent.roqueta@ext.bull.net>
Reply-To: vincent.roqueta@ext.bull.net
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1AvFnp-0006xB-IN
	for nfs@lists.sourceforge.net; Mon, 23 Feb 2004 05:07:17 -0800
Received: from ecbull20.frec.bull.fr ([129.183.4.3])
	by sc8-sf-mx1.sourceforge.net with esmtp (Exim 4.30)
	id 1AvFg1-00013l-91
	for nfs@lists.sourceforge.net; Mon, 23 Feb 2004 04:59:14 -0800
Received: from roquetav (roquetav.frec.bull.fr [129.183.101.52])
	by ecbull20.frec.bull.fr (8.9.2/8.9.1) with ESMTP id NAA09494
	for <nfs@lists.sourceforge.net>; Mon, 23 Feb 2004 13:59:06 +0100
To: nfs@lists.sourceforge.net
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


> On Thu, Feb 19, 2004 at 06:00:44PM +0100, Vincent ROQUETA wrote:
> > Le Jeudi 19 F=E9vrier 2004 16:49, J. Bruce Fields a =E9crit :
> > > On Thu, Feb 19, 2004 at 09:58:38AM +0100, Vincent ROQUETA wrote:
> > > > Here are vi traces for opening "/mnt/nfs/vincent/suite-tests/toto3"
> > >
> > > These bug reports are no help if you won't remind us, on each bug
> > > report, which kernel you're using, with which (if any) patches.  Also,
> > > it'd help if you could test with the latest CITI NFSv4 patches
> > > (http://www.citi.umich.edu/projects/nfsv4/linux/).  I suspect the
> > > problem you're seeing is a problem that's already fixed with those
> > > patches.
> > >
> > > --Bruce Fields
> >
> > The problem still appear with kernel 2.6.2 and all patches.
> > (Linux roquetav 2.6.2-CITI_NFS4_ALL-1)
>
> This is on both the client and the server?
>
> The following would also help (again, it would be helpful to include
> this information with all bug reports):
>
> 	server export options (output from 'exportfs -v')
> 	mount options (output from 'mount')
>
> --b.

Configuration:
server 2.6.2-CITI_NFS4_ALL-1 #2 SMP
client 2.6.2-CITI_NFS4_ALL-1

ptoblem: mount fail:
error (client side):
mount: type de sys. de fichiers erron=E9, option erron=E9e, super bloc erro=
n=E9 sur
172.16.109.31:/, ou trop de syst=E8mes de fichiers mont=E9s

(mout: bad filesystem type, bad options, bad super bloc on 172.16.109.31:/ =
or
too many filesytems mounted.)
______________________________________________________

With this config:
client 2.6.2-all patches
server: linux 2.6.3-mm1

Problem with vi as reported in the first mail.
 (So there is a problem on the server side?)
______________________________________________________
exports operations (both configurations):
mount --bind -v /home/vincent/ /export/vincent
/home/vincent on /export/vincent type none (rw,bind)
exportfs -i -v -ofsid=3D0 *:/export
exporting *:/export
exportfs -i -v -orw,nohide *:/export/vincent
exporting *:/export/vincent

=2D------------------------------------------------------



-------------------------------------------------------
SF.Net is sponsored by: Speed Start Your Linux Apps Now.
Build and deploy apps & Web services for Linux with
a free DVD software kit from IBM. Click Now!
http://ads.osdn.com/?ad_id=1356&alloc_id=3438&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs

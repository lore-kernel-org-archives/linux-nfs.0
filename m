From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: Re :Re: NFSv4  and vi
Date: Mon, 23 Feb 2004 13:23:32 -0500
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <20040223182331.GA5074@fieldses.org>
References: <200402231401.12339.vincent.roqueta@ext.bull.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-list1-b.sourceforge.net ([10.3.1.7] helo=sc8-sf-list1.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1AvMFz-00011l-KI
	for nfs@lists.sourceforge.net; Mon, 23 Feb 2004 12:00:47 -0800
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list1.sourceforge.net with esmtp (Exim 4.30)
	id 1AvKrh-0005c6-1E
	for nfs@lists.sourceforge.net; Mon, 23 Feb 2004 10:31:37 -0800
Received: from dsl093-002-214.det1.dsl.speakeasy.net
	([66.93.2.214] helo=pumpkin.fieldses.org ident=Debian-exim)
	by sc8-sf-mx1.sourceforge.net with esmtp (TLSv1:RC4-SHA:128)
	(Exim 4.30)
	id 1AvKjw-00007A-K3
	for nfs@lists.sourceforge.net; Mon, 23 Feb 2004 10:23:36 -0800
To: Vincent ROQUETA <vincent.roqueta@ext.bull.net>
In-Reply-To: <200402231401.12339.vincent.roqueta@ext.bull.net>
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

On Mon, Feb 23, 2004 at 02:01:12PM +0100, Vincent ROQUETA wrote:
> Configuration:
> server 2.6.2-CITI_NFS4_ALL-1 #2 SMP
> client 2.6.2-CITI_NFS4_ALL-1
> 
> ptoblem: mount fail:
> error (client side):
> mount: type de sys. de fichiers erroné, option erronée, super bloc erroné sur
> 172.16.109.31:/, ou trop de systèmes de fichiers montés
> 
> (mout: bad filesystem type, bad options, bad super bloc on 172.16.109.31:/ or
> too many filesytems mounted.)

Which version of the nfs-utils is your mountd built from?  This could be
caused by not having the latest nfs-utils patches (in particular,
http://www.citi.umich.edu/projects/nfsv4/linux/nfs-utils-patches/1.0.6-5/nfs-utils-04-upcall_export_check.dif
is needed).

For any further diagnosis a network trace would help (run tcpdump
-wtmp.pcap -s0, and mail me tmp.pcap)

> With this config:
> client 2.6.2-all patches
> server: linux 2.6.3-mm1
> 
> Problem with vi as reported in the first mail.
>  (So there is a problem on the server side?)

It's possible.  I've tested with 2.6.3-CITI_NFS4_ALL-2 (server and
client) and I'm not able to reproduce the problem you report either with
vi or with a c program that similarly tries open's on nonexistant files.

--Bruce Fields


-------------------------------------------------------
SF.Net is sponsored by: Speed Start Your Linux Apps Now.
Build and deploy apps & Web services for Linux with
a free DVD software kit from IBM. Click Now!
http://ads.osdn.com/?ad_id=1356&alloc_id=3438&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs

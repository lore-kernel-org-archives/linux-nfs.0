From: Erik Walthinsen <omega@pdxcolo.net>
Subject: RE: NAS server avalanche overload
Date: Wed, 03 Mar 2004 14:34:20 -0800
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <1078353259.815.53.camel@localhost>
References: <482A3FA0050D21419C269D13989C61130435DCCB@lavender-fe.eng.netapp.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: "Lever, Charles" <Charles.Lever@netapp.com>
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1Ayf25-0001V0-MR
	for nfs@lists.sourceforge.net; Wed, 03 Mar 2004 14:40:05 -0800
Received: from mail.pdxcolo.net ([64.146.134.17] helo=palantir.pdxcolo.net)
	by sc8-sf-mx1.sourceforge.net with esmtp (TLSv1:DES-CBC3-SHA:168)
	(Exim 4.30)
	id 1AyewY-0002me-Cm
	for nfs@lists.sourceforge.net; Wed, 03 Mar 2004 14:34:22 -0800
To: nfs@lists.sourceforge.net
In-Reply-To: <482A3FA0050D21419C269D13989C61130435DCCB@lavender-fe.eng.netapp.com>
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

On Wed, 2004-03-03 at 14:20, Lever, Charles wrote:
> careful:  greg said "export options" not "mount options."
> what export options are you using on your NFS server?

Hmm, async is specified in /etc/exports.  However, in my early testing I
found that there was no discernible performance difference (with
bonnie++ iirc) between setting the exports one way and setting the
client mount option instead.  Either one set to sync would cause
performance drops, as expected, but to the same degree.

I can't change either the exports or client mount options for another
month however, until our quarterly downtime.

- Omega
  aka Erik Walthinsen
  omega@pdxcolo.net



-------------------------------------------------------
This SF.Net email is sponsored by: IBM Linux Tutorials
Free Linux tutorial presented by Daniel Robbins, President and CEO of
GenToo technologies. Learn everything from fundamentals to system
administration.http://ads.osdn.com/?ad_id=1470&alloc_id=3638&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs

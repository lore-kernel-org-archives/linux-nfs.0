From: Neil Brown <neilb@suse.de>
Subject: Re: Portmap - was Re: Does mountd/statd really need to listen
 on a privileged port??
Date: Tue, 24 Apr 2007 09:09:03 +1000
Message-ID: <17965.15503.703515.820793@notabene.brown>
References: <17958.48121.280256.493824@notabene.brown>
	<20070419012154.GB19063@javifsp.no-ip.org>
	<17960.11704.321124.641669@notabene.brown>
	<4629120C.60803@RedHat.com>
	<17964.12324.307985.65596@notabene.brown>
	<462CB496.6000308@RedHat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: Matthias Koenig <mkoenig@novell.com>, nfs@lists.sourceforge.net,
	Olaf Kirch <olaf.kirch@oracle.com>,
	=?ISO-8859-1?Q?Javier_Fern=E1ndez-Sanguino_Pe=F1a?= <jfs@computer.org>,
	anibal@debian.org
To: Steve Dickson <SteveD@redhat.com>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1Hg7eu-0001A8-Ib
	for nfs@lists.sourceforge.net; Mon, 23 Apr 2007 16:09:24 -0700
Received: from cantor.suse.de ([195.135.220.2] helo=mx1.suse.de)
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1Hg7et-0006hs-JJ
	for nfs@lists.sourceforge.net; Mon, 23 Apr 2007 16:09:27 -0700
In-Reply-To: message from Steve Dickson on Monday April 23
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

On Monday April 23, SteveD@redhat.com wrote:
> > 
> >> I (hastily) created two git trees:
> >> git://git.infradead.org/~steved/libtirpc.git
> >> git://git.infradead.org/~steved/rpcbind.git
> >>
> >> I think if you take a look, you'll see that
> >> this code may not be as mature as the portmap
> >> code, but its a much better start... imho..
> > 
> > Yes, very hasty.  Several #temporary# and back~ files :-)
> Yeah... for some reason those temporary files are in the
> the tar ball... I'll work to get that cleaned up..

Is there someone "maintaining" rpcbind?  Should there be?
I notice there is an rpcbind at Wietse Venema's site:
  ftp://ftp.porcupine.org/pub/security/index.html

Is this rpcbind derived from that?

Should rpcbind and portmap "live" close together so that people
looking for one will find the other, and so that compatibility
(features, options) can be maximised?

> 
> > 
> > I notice that it has a concept of who 'owns' a registration, but it
> > only works if unix-domain sockets are used for the registration.
> > Adding 'superuser' ownership for localhost/privport registrations is
> > probably a 3 line patch....
> I'm not sure I understand.. are you talking about how getowner()
> is being used?

Sort of.  I was actually looking in pmapproc_change which seems to
have 'getowner' open-coded in it.
Both call __rpc_get_local_uid.
That function (in libritpc) returns -1 ( => "unknown") for a AF_INET
connection.
I believe that for AF_INET, it should check sin_addr and sin_port.
If addr == 127.0.0.1 and sin_port < 1024, then uid should be set to
0.

It would be nice if the libritpc version of bindrecvport could be
configured to avoid some list of ports, whether from /etc/services or
from elsewhere.

NeilBrown

-------------------------------------------------------------------------
This SF.net email is sponsored by DB2 Express
Download DB2 Express C - the FREE version of DB2 express and take
control of your XML. No limits. Just data. Click to get it now.
http://sourceforge.net/powerbar/db2/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs

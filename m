From: Steve Dickson <SteveD@redhat.com>
Subject: Re: Portmap - was Re: Does mountd/statd really need to listen
 on a privileged port??
Date: Tue, 24 Apr 2007 10:38:34 -0400
Message-ID: <462E166A.3060904@RedHat.com>
References: <17958.48121.280256.493824@notabene.brown>	<20070419012154.GB19063@javifsp.no-ip.org>	<17960.11704.321124.641669@notabene.brown>	<4629120C.60803@RedHat.com>	<17964.12324.307985.65596@notabene.brown>	<462CB496.6000308@RedHat.com>
	<17965.15503.703515.820793@notabene.brown>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: Matthias Koenig <mkoenig@novell.com>,
	Tony Reix <tony.reix@bull.net>,
	=?ISO-8859-1?Q?Javier_Fern=E1ndez-Sanguino_Pe=F1a?= <jfs@computer.org>,
	nfs@lists.sourceforge.net, Olaf Kirch <olaf.kirch@oracle.com>,
	anibal@debian.org
To: Neil Brown <neilb@suse.de>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1HgMAQ-0002Kw-67
	for nfs@lists.sourceforge.net; Tue, 24 Apr 2007 07:38:54 -0700
Received: from mx1.redhat.com ([66.187.233.31])
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1HgMAR-0007Kx-GG
	for nfs@lists.sourceforge.net; Tue, 24 Apr 2007 07:38:56 -0700
In-Reply-To: <17965.15503.703515.820793@notabene.brown>
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



Neil Brown wrote:
> On Monday April 23, SteveD@redhat.com wrote:
>>>> I (hastily) created two git trees:
>>>> git://git.infradead.org/~steved/libtirpc.git
>>>> git://git.infradead.org/~steved/rpcbind.git
>>>>
>>>> I think if you take a look, you'll see that
>>>> this code may not be as mature as the portmap
>>>> code, but its a much better start... imho..
>>> Yes, very hasty.  Several #temporary# and back~ files :-)
>> Yeah... for some reason those temporary files are in the
>> the tar ball... I'll work to get that cleaned up..
> 
> Is there someone "maintaining" rpcbind?  Should there be?
Well the I got the current code from Bull:
http://nfsv4.bullopensource.org/doc/tirpc_rpcbind.php

As far as maintaining it.. since I have vested interested
in see this code work (being it now in FC7), I will be
playing a active roll in the maintenance, but Bull
should probably be seen as the upstream for this code..

> I notice there is an rpcbind at Wietse Venema's site:
>   ftp://ftp.porcupine.org/pub/security/index.html
> 
> Is this rpcbind derived from that?
No clue... Added Tony to the cc list to see if he knows...
but I must say it certainly has the look and feel of the
current rpcbind code...

> 
> Should rpcbind and portmap "live" close together so that people
> looking for one will find the other, and so that compatibility
> (features, options) can be maximised?
> 
>>> I notice that it has a concept of who 'owns' a registration, but it
>>> only works if unix-domain sockets are used for the registration.
>>> Adding 'superuser' ownership for localhost/privport registrations is
>>> probably a 3 line patch....
>> I'm not sure I understand.. are you talking about how getowner()
>> is being used?
> 
> Sort of.  I was actually looking in pmapproc_change which seems to
> have 'getowner' open-coded in it.
> Both call __rpc_get_local_uid.
> That function (in libritpc) returns -1 ( => "unknown") for a AF_INET
> connection.
> I believe that for AF_INET, it should check sin_addr and sin_port.
> If addr == 127.0.0.1 and sin_port < 1024, then uid should be set to
> 0.
Ah... I see your point...

steved.

-------------------------------------------------------------------------
This SF.net email is sponsored by DB2 Express
Download DB2 Express C - the FREE version of DB2 express and take
control of your XML. No limits. Just data. Click to get it now.
http://sourceforge.net/powerbar/db2/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs

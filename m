From: Mike Waychison <Michael.Waychison@Sun.COM>
Subject: Re: [PATCH] xprt sharing (was Re: xprt_bindresvport)
Date: Wed, 08 Dec 2004 16:58:00 -0500
Message-ID: <41B778E8.7000602@sun.com>
References: <482A3FA0050D21419C269D13989C61130435EC70@lavender-fe.eng.netapp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: Olaf Kirch <okir@suse.de>, nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1Cc9p5-0001qK-Hj
	for nfs@lists.sourceforge.net; Wed, 08 Dec 2004 13:58:11 -0800
Received: from brmea-mail-4.sun.com ([192.18.98.36])
	by sc8-sf-mx1.sourceforge.net with esmtp (Exim 4.41)
	id 1Cc9p4-0004ni-G1
	for nfs@lists.sourceforge.net; Wed, 08 Dec 2004 13:58:11 -0800
Received: from phys-mpk-1 ([129.146.11.81])
	by brmea-mail-4.sun.com (8.12.10/8.12.9) with ESMTP id iB8LwAdt018372
	for <nfs@lists.sourceforge.net>; Wed, 8 Dec 2004 14:58:10 -0700 (MST)
Received: from conversion-daemon.mpk-mail1.sfbay.sun.com by
 mpk-mail1.sfbay.sun.com
 (iPlanet Messaging Server 5.2 HotFix 1.24 (built Dec 19 2003))
 id <0I8F00H01BKD1N@mpk-mail1.sfbay.sun.com>
 (original mail from Michael.Waychison@Sun.COM) for nfs@lists.sourceforge.net;
 Wed, 08 Dec 2004 13:58:10 -0800 (PST)
In-reply-to: <482A3FA0050D21419C269D13989C61130435EC70@lavender-fe.eng.netapp.com>
To: "Lever, Charles" <Charles.Lever@netapp.com>
Sender: nfs-admin@lists.sourceforge.net
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

-----BEGIN PGP SIGNED MESSAGE-----
Hash: SHA1

Lever, Charles wrote:
>>>but also notice this cuts the usable port range in half 
>>
>>(from ~800 to
>>
>>>~420).  we need some form of mitigation to ensure we aren't 
>>
>>limiting the
>>
>>>number of NFS mounts a client can have.
>>
>>This has been bugging me for a while.  The fact that we are limitting
>>ourselves to a single nfs mount per port.  From what I can 
>>tell, Solaris
>>shares the transports between nfs mounts from the same server 
>>and saves
>>themselves a lot of trouble with running out of port numbers 
>>in doing so.
>>
>>The attached patch does the same for Linux against 2.6.9.  We share
>>xprts from existing connections, effectively removing any limit on the
>>number of nfs mounts we have in the system.
>>
>>The only thing to worry about now is any talking to the portmapper or
>>mountd from userspace using tcp, which will put the reserved ports in
>>TIME_WAIT state.  This can limit the 'speed' at which we 
>>mount many mounts.
> 
> 
> we're looking at a similar solution.  we want to make sure we don't
> limit the scalability of everyone's mount point by making them all
> funnel through a single slot table.
> 

Can you post any work in progress for this?   The xprt patch I posted
was written a while ago, and I just realized this afternoon that it
doesn't seem to do the right thing for tcp sockets that are autoclosed.

If you have a similar patch that works, it would save me the trouble ;)


- --
Mike Waychison
Sun Microsystems, Inc.
1 (650) 352-5299 voice
1 (416) 202-8336 voice

~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
NOTICE:  The opinions expressed in this email are held by me,
and may not represent the views of Sun Microsystems, Inc.
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.2.5 (GNU/Linux)
Comment: Using GnuPG with Thunderbird - http://enigmail.mozdev.org

iD8DBQFBt3jodQs4kOxk3/MRArXNAKCaahtv7uNfhX2n2yaz/N3D18t0vgCfSOLa
rOARY+qtJrFfWOtb0m18cSk=
=HlXX
-----END PGP SIGNATURE-----


-------------------------------------------------------
SF email is sponsored by - The IT Product Guide
Read honest & candid reviews on hundreds of IT Products from real users.
Discover which products truly live up to the hype. Start reading now. 
http://productguide.itmanagersjournal.com/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs

From: Mike Waychison <Michael.Waychison@Sun.COM>
Subject: Re: Intermittent RHE3-u3 client mount failures to Netapp
 fileserver
Date: Wed, 15 Dec 2004 11:43:29 -0500
Message-ID: <41C069B1.9090608@sun.com>
References: <482A3FA0050D21419C269D13989C61130853955E@lavender-fe.eng.netapp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: David Meleedy <david.meleedy@analog.com>, nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.12] helo=sc8-sf-mx2.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1CecFo-0008Uw-95
	for nfs@lists.sourceforge.net; Wed, 15 Dec 2004 08:43:56 -0800
Received: from brmea-mail-4.sun.com ([192.18.98.36])
	by sc8-sf-mx2.sourceforge.net with esmtp (Exim 4.41)
	id 1CecFn-0000HQ-2S
	for nfs@lists.sourceforge.net; Wed, 15 Dec 2004 08:43:55 -0800
Received: from phys-mpk-1 ([129.146.11.81])
	by brmea-mail-4.sun.com (8.12.10/8.12.9) with ESMTP id iBFGhodv008887
	for <nfs@lists.sourceforge.net>; Wed, 15 Dec 2004 09:43:50 -0700 (MST)
Received: from conversion-daemon.mpk-mail1.sfbay.sun.com by
 mpk-mail1.sfbay.sun.com
 (iPlanet Messaging Server 5.2 HotFix 1.24 (built Dec 19 2003))
 id <0I8R00401VOCWX@mpk-mail1.sfbay.sun.com>
 (original mail from Michael.Waychison@Sun.COM) for nfs@lists.sourceforge.net;
 Wed, 15 Dec 2004 08:43:50 -0800 (PST)
In-reply-to: <482A3FA0050D21419C269D13989C61130853955E@lavender-fe.eng.netapp.com>
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
> 
> and check the hardware too.  we had an IPMI hardware implementation from
> Intel at one point that took a port without notifying the operating
> system, and that caused similar failures.
> 

I've seen this too with e1000 hardware.  I usually blacklist the ports
by adding the 623 for udp / tcp to my (x)inetd config and pointing them
to /bin/true.

I'm wondering if anybody has figured out a way to 'blacklist' these
ports somehow from within the drivers..    ..probably best left as a
hotplug event.


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

iD8DBQFBwGmxdQs4kOxk3/MRApeFAJkBj5Dn2KDsdkmknxUh+fmunZrALQCfTGm6
7N0fuLRQ22ff2MIUtzTS6KM=
=xdDY
-----END PGP SIGNATURE-----


-------------------------------------------------------
SF email is sponsored by - The IT Product Guide
Read honest & candid reviews on hundreds of IT Products from real users.
Discover which products truly live up to the hype. Start reading now. 
http://productguide.itmanagersjournal.com/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs

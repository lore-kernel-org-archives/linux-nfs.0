From: Mike Waychison <Michael.Waychison@Sun.COM>
Subject: Re: udp ports not being released
Date: Mon, 22 Nov 2004 14:56:03 -0500
Message-ID: <41A24453.6000907@sun.com>
References: <41A2413A.9020800@analog.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: nfs@lists.sourceforge.net, autofs@linux.kernel.org,
	Ian Kent <raven@themaw.net>
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.12] helo=sc8-sf-mx2.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1CWKIa-0004dg-Tf
	for nfs@lists.sourceforge.net; Mon, 22 Nov 2004 11:56:32 -0800
Received: from brmea-mail-4.sun.com ([192.18.98.36])
	by sc8-sf-mx2.sourceforge.net with esmtp (Exim 4.41)
	id 1CWKIZ-0002zO-3D
	for nfs@lists.sourceforge.net; Mon, 22 Nov 2004 11:56:32 -0800
Received: from phys-mpk-2 ([129.146.11.82])
	by brmea-mail-4.sun.com (8.12.10/8.12.9) with ESMTP id iAMJuPur026896
	for <nfs@lists.sourceforge.net>; Mon, 22 Nov 2004 12:56:30 -0700 (MST)
Received: from conversion-daemon.mpk-mail1.sfbay.sun.com by
 mpk-mail1.sfbay.sun.com
 (iPlanet Messaging Server 5.2 HotFix 1.24 (built Dec 19 2003))
 id <0I7L00401J78J6@mpk-mail1.sfbay.sun.com>
 (original mail from Michael.Waychison@Sun.COM) for nfs@lists.sourceforge.net;
 Mon, 22 Nov 2004 11:56:25 -0800 (PST)
In-reply-to: <41A2413A.9020800@analog.com>
To: Dwight Marzolf <dwight.marzolf@analog.com>
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

Dwight Marzolf wrote:
> We are running RedHat 8, kernel 2.4.20-20.8smp and autofs 4.1.2.  We
> were having a variety of automount problems until a kernel patch was
> recommended.  We added this patch, recompiled our kernel, and
> distributed the patched kernel to all of our workstations.  About 90% of
> our problems disappeared.  But one problem seems to remain.
> 
> When /net is used to mount directories, most of the time the udp port
> used for that nfs mount operation is not released once the /net mount
> times out.   Depending on the level of activity on a machine, over the
> period of several days, all the available reserved ports are used up. 
> At that point the user on the workstation cannot cd to any mount points
> in our automount maps except the ones already mounted.  In the
> /var/log/messages the following error occurs for attempted mounts:

IIRC, automount 4.1.2 had a fd leak, that was fixed in 4.1.3

Ian?

> 
> RPC: Can't bind to reserved port
> 
> In my experiments I found that doing a "umount -l /net" releases all the
> udp ports immediately.  Our workaround has been to kill all the autofs
> processes, do a umount -l on all mount points in /etc/mtab, and them
> restart the autofs process.
> 
> My question is (1) is there any fix for this problem or some switch I
> need to turn on/off in order for these udp ports to be released when the
> mount point times out and (2) is there some command that I can use to
> release these ports rather than going through the multiple step process
> I described above to clean up a machine?
> 
> Dwight Marzolf
> 
> 
> 
> 
> -------------------------------------------------------
> SF email is sponsored by - The IT Product Guide
> Read honest & candid reviews on hundreds of IT Products from real users.
> Discover which products truly live up to the hype. Start reading now.
> http://productguide.itmanagersjournal.com/
> _______________________________________________
> NFS maillist  -  NFS@lists.sourceforge.net
> https://lists.sourceforge.net/lists/listinfo/nfs


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

iD8DBQFBokRTdQs4kOxk3/MRAmNFAJ9vYo0GjHbM2RlquSgAVjbJ32lnlQCeOZkc
8hRRC7gWmZwspf9ySrnkZE4=
=H26H
-----END PGP SIGNATURE-----


-------------------------------------------------------
SF email is sponsored by - The IT Product Guide
Read honest & candid reviews on hundreds of IT Products from real users.
Discover which products truly live up to the hype. Start reading now. 
http://productguide.itmanagersjournal.com/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs

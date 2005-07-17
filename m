From: =?iso-8859-1?Q?Peter_=C5strand?= <astrand@cendio.se>
Subject: Re: [PATCH] Fix xprt_bindresvport
Date: Sun, 17 Jul 2005 22:49:31 +0200 (CEST)
Message-ID: <Pine.LNX.4.61.0507172244080.30548@maggie.lkpg.cendio.se>
References: <20050711092556.GD27163@suse.de> <42D68C0B.9000106@RedHat.com>
 <20050716071144.GA7451@suse.de> <42DA42C6.1020005@RedHat.com>
Mime-Version: 1.0
Content-Type: MULTIPART/MIXED; BOUNDARY="789237761-1319272407-1121633256=:30548"
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92] helo=sc8-sf-mx2.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1DuG5Z-00070c-M5
	for nfs@lists.sourceforge.net; Sun, 17 Jul 2005 13:50:17 -0700
Received: from mail.cendio.se ([193.12.253.69])
	by sc8-sf-mx2.sourceforge.net with esmtp (Exim 4.44)
	id 1DuG56-00042P-AX
	for nfs@lists.sourceforge.net; Sun, 17 Jul 2005 13:50:17 -0700
To: Steve Dickson <SteveD@redhat.com>
In-Reply-To: <42DA42C6.1020005@RedHat.com>
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

  This message is in MIME format.  The first part should be readable text,
  while the remaining parts are likely unreadable without MIME-aware tools.

--789237761-1319272407-1121633256=:30548
Content-Type: TEXT/PLAIN; CHARSET=iso-8859-1; format=flowed
Content-ID: <Pine.LNX.4.61.0507172247571.30548@maggie.lkpg.cendio.se>
Content-Transfer-Encoding: quoted-printable

On Sun, 17 Jul 2005, Steve Dickson wrote:

>> And in an environment where the admin doesn't care for privileged
>> vs unprivileged ports, it's good to give him the choice of allowing
>> the kernel to bind to any port.
> If such an environment exists, then I agree... but I don't think this
> is the norm... I'm pretty sure a lot of RPC daemons check for
> privileged port by default... Something I don't think admits can
> turn off...

Novell Netware is one system which does not check for privileged ports.=20
Also, when using SSH tunnels, typically you do not use privileged ports.=20
(With unfs3 this can actually be done in a secure way by using the one=20
time password feature.)


> Don't get me wrong, I really like the idea of being able to define
> the range of privileged ports the kernel can use (I think it will be
> very handy), but by definition a privileged port is between 1 and 1023
> and by setting the max port to 1023 we would be maintaining that
> definition...

I agree with that definition, but I also agree with Olaf Kirch: Adding a=20
"noprivports" option is not as elegant.

--=20
Peter =C5strand		Chief Developer
Cendio			www.thinlinc.com
Teknikringen 3		www.cendio.se
583 30 Link=F6ping        Phone: +46-13-21 46 00
--789237761-1319272407-1121633256=:30548--


-------------------------------------------------------
SF.Net email is sponsored by: Discover Easy Linux Migration Strategies
from IBM. Find simple to follow Roadmaps, straightforward articles,
informative Webcasts and more! Get everything you need to get up to
speed, fast. http://ads.osdn.com/?ad_id=7477&alloc_id=16492&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs

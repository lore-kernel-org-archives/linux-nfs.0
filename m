From: dwight@supercomputer.org
Subject: Re: RE: Linux client on Solaris 7 NFS server
Date: Mon, 05 Jan 2004 09:11:01 -0800
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <200401051711.i05HB1d15444@supercomputer.org>
References: <Charles.Lever@netapp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.12] helo=sc8-sf-mx2.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.24)
	id 1AdYFj-0003Mw-5D
	for nfs@lists.sourceforge.net; Mon, 05 Jan 2004 09:10:55 -0800
Received: from supercomputer.org ([69.17.34.169] helo=mail.supercomputer.org)
	by sc8-sf-mx2.sourceforge.net with esmtp (Exim 4.30)
	id 1AdYFi-0000Ml-Oe
	for nfs@lists.sourceforge.net; Mon, 05 Jan 2004 09:10:54 -0800
To: "Lever, Charles" <Charles.Lever@netapp.com>
In-Reply-To: Message from "Lever, Charles" <Charles.Lever@netapp.com>
   of "Tue, 30 Dec 2003 09:58:27 PST." <482A3FA0050D21419C269D13989C6113020AC965@lavender-fe.eng.netapp.com>
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

Chareles Lever wrote:

> does "tcp,rsize2768,wsize2768" work?  the Linux defaults are
> UDP and r/wsize@96, which work adequately with Linux servers,
> but probably are trouble for Solaris.
> =

> which Linux kernels, specifically, have you tried on your clients?
> =

> what performance do you see, and what do you expect?

Well, yes, it works, but there's no noticeable performance =

improvement. I'll caveat that with the observation that this was in
a more complicated production environment. I haven't tried it yet
with V3 in a semi-isolated environment.

One of the more significant speed-ups I've noticed was with
completely turning off Version 3 NFS support in the kernel, and
forcing all transactions between Solaris and Linux to be Version 2.
Just specifying V2 as a mount option improves things a bit; but using
a 2.4.24-pre1 kernel without V3 support built in dropped the test
time from about 6 minutes to 3.0 minutes. Just specifying V2 as a =

mount option drops the performance from 6 minutes to 4 min, 45 seconds.

In comparision, the pure Linux server and client test ran about 30
seconds (UDP and TCP); and the pure Solaris environment ran about
the same. Mind you, the Solaris 8 systems are much slower CPU's in =

my test bed the same.  Mind you, the Solaris 8 systems are much =

slower CPU's in my test bed

Another rather interesting thing is that a Solaris client using a =

Linux server runs the test at the same speed as the pure Solaris or =

pure Linux environment. So this behaviour is specific to the =

Linux-client/Solaris-server situation.

As for what kind of results I was expecting, I was hoping for =

something comparable to the other 3 pairs of combinations. Perhaps =

even just double would be of use; but not a factor of 6.

As far as the kernels used, the same consistent results have been =

seen across the range of 2.4 kernels. Mostly the RH variations of =

2.4.18, but earlier ones as well, and right now I'm looking at the =

2.4.24 pre-releases. However, I will note that the one's prior to =

2.4.18 were done in the production environment, and not with some =

attempt at isolation.

Also, the problem seems unaffected by using the latest version of =

nfsutils.

The overall throughput seems to be pegged at about 11 Mbps IIRC. =

Googling shows that other people have also reported this issue over =

the years, and there is no clear solution.  =


So, in summary, this seems to be a constant issue with Linux/Solaris
interaction. There also seem to be be issues with V3 in this
environment.

Any suggestions and/or ideas would be welcome.

Best Regards,

        -dwight-




-------------------------------------------------------
This SF.net email is sponsored by: IBM Linux Tutorials.
Become an expert in LINUX or just sharpen your skills.  Sign up for IBM's
Free Linux Tutorials.  Learn everything from the bash shell to sys admin.
Click now! http://ads.osdn.com/?ad_id=1278&alloc_id=3371&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs

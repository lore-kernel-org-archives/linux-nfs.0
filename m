From: David Dougall <davidd@et.byu.edu>
Subject: Re: Linux NFS server for heterogeneous production environment
Date: Thu, 21 Oct 2004 14:47:07 -0600 (MDT)
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <Pine.LNX.4.58.0410211432490.24571@lewis.et.byu.edu>
References: <B9F4645CD7B0D511BE8300508B68C327025EB483@tnscapp02.pcacorp.net>
  <Pine.LNX.4.58.0410210824040.24571@lewis.et.byu.edu>
 <14252.1098381653@marajade.sandelman.ottawa.on.ca>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: "Stuckless, Colin" <cstuckless@petro-canada.ca>,
        "'nfs@lists.sourceforge.net'" <nfs@lists.sourceforge.net>
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.12] helo=sc8-sf-mx2.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1CKjqA-0006YF-22
	for nfs@lists.sourceforge.net; Thu, 21 Oct 2004 13:47:18 -0700
Received: from postal1.et.byu.edu ([128.187.122.131])
	by sc8-sf-mx2.sourceforge.net with esmtp (Exim 4.41)
	id 1CKjq8-0007g5-JL
	for nfs@lists.sourceforge.net; Thu, 21 Oct 2004 13:47:17 -0700
To: Michael Richardson <mcr@sandelman.ottawa.on.ca>
In-Reply-To: <14252.1098381653@marajade.sandelman.ottawa.on.ca>
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

I had locking trouble with both nfsv2 and nfsv3.  HPUX locking would work
based on whatever patchset was blessed by the gods.  If I upgraded a patch
on client or server out of step with all the others, it would cease to
work, etc.
Anyway, are your questions referring to before or after we changed to
linux NFS?  I assume after, so I will answer that.
We do lots of locking now.  Our HPUX machines still have trouble at times.
We used to do mbox mailboxes over nfs.  That was very ugly.  We moved to
mbox mailboxes on a local drive, but we have since moved to maildir files
over nfs.  It works without a hitch.
We have tons of simulations that take lots of time.  Some program
simulations run for months on end over NFS.  (Although some would argue
that if it wasn't over NFS it would take a lot less time :P)
--David Dougall


On Thu, 21 Oct 2004, Michael Richardson wrote:

> -----BEGIN PGP SIGNED MESSAGE-----
>
>
> >>>>> "David" == David Dougall <davidd@et.byu.edu> writes:
>     David> faster in many cases.  As far as clients, we have lots of
>     David> HPUX, linux, Irix, AIX and MAC.  Unfortunately, I have no
>     David> experience with solaris clients.  I have had little to no
>
>   Solaris clients are the most demanding of clients, protocol-wise.
>
>     David> problems with any of them except HPUX client locking code is
>     David> really flaky(although it was flaky even with HPUX as the
>
>   Yes, HPUX never did get the locking code right.
>   Were you using NFSv2 or v3? Did it vary by client?
>
>   Did you do lots of locking?
>   Did you have mailspool on NFS?
>   Any big, long running jobs? (e.g. Verilog simulations)
>
> - --
> ]     "Elmo went to the wrong fundraiser" - The Simpson         |  firewalls  [
> ]   Michael Richardson,    Xelerance Corporation, Ottawa, ON    |net architect[
> ] mcr@xelerance.com      http://www.sandelman.ottawa.on.ca/mcr/ |device driver[
> ] panic("Just another Debian GNU/Linux using, kernel hacking, security guy"); [
> -----BEGIN PGP SIGNATURE-----
> Version: GnuPG v1.2.2 (GNU/Linux)
> Comment: Finger me for keys
>
> iQCVAwUBQXf5VIqHRg3pndX9AQFEIAQAk0aSi6wJn3CAh5Rc+FbjzF78lkd5mWe1
> IgNkdMEMa+Jle9HJIOYYvXwnbYapHWu80T4ydJ8Ihyfg+fYavGNituyDVoSp3CX5
> d5V/+cAbz0O4NaqhTQBO1L4LST4oKAEWnWsvte8MmFyycIQ9wwbHPHPiw/6/84Kw
> we0WeOIf1PA=
> =YF6E
> -----END PGP SIGNATURE-----
>
>
>


-------------------------------------------------------
This SF.net email is sponsored by: IT Product Guide on ITManagersJournal
Use IT products in your business? Tell us what you think of them. Give us
Your Opinions, Get Free ThinkGeek Gift Certificates! Click to find out more
http://productguide.itmanagersjournal.com/guidepromo.tmpl
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs

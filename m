From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: Re: pf: to scrub or not to scrub?
Date: Sun, 28 Jul 2002 18:21:26 +0200
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <41128.2105757438$1027873455@news.gmane.org>
References: <Pine.GSO.4.33.0207241828330.586-100000@loogie.intranet.csupomona.edu>
	<20020725094904.GE8969@skywalker.bsws.de>
	<20020725183112.GA4708@esme.xs4all.nl>
	<20020725190243.GB8076@w4g.org>
	<20020727232451.GG26763@han.myip.org>
	<shsk7nfhoit.fsf@charged.uio.no>
	<20020728155152.GA13040@han.myip.org>
Reply-To: trond.myklebust@fys.uio.no
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: misc@openbsd.org,
    NFS maillist <nfs@lists.sourceforge.net>
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from pat.uio.no ([129.240.130.16])
	by usw-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 17Yqng-00060Q-00
	for <nfs@lists.sourceforge.net>; Sun, 28 Jul 2002 09:21:44 -0700
To: Han <han@boetes.org>
In-Reply-To: <20020728155152.GA13040@han.myip.org>
Errors-To: nfs-admin@lists.sourceforge.net
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
List-Id: Discussion of NFS under Linux development,
	interoperability,
	and testing. <nfs.lists.sourceforge.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://www.geocrawler.com/redir-sf.php3?list=nfs>


    >> Mind explaining exactly what is causing the OpenBSD 'scrub'
    >> filter to fail to pass these packets?

Hmm... From your forwarded mail. Looks like they were saying that the
firewall doesn't like IP_DF + IP_MF. That basically means that it is
incompatible with standard Path MTU discovery (see RFC 1191).

Try turning off path MTU discovery using
  echo "1" >/proc/sys/net/ipv4/ip_no_pmtu_disc

and it should probably work (or set the wsize to 1024 - means no
fragmentation of the writes).

Cheers,
  Trond


-------------------------------------------------------
This sf.net email is sponsored by:ThinkGeek
Welcome to geek heaven.
http://thinkgeek.com/sf
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs

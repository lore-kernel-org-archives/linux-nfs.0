From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: Linux Client -> Solaris Server
Date: Wed, 02 Jun 2004 08:24:12 -0700
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <1086189852.17378.66.camel@lade.trondhjem.org>
References: <40BDE65F.1000009@inf.ethz.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1BVXbJ-0004d6-DY
	for nfs@lists.sourceforge.net; Wed, 02 Jun 2004 08:24:21 -0700
Received: from [209.101.250.228] (helo=lade.trondhjem.org)
	by sc8-sf-mx1.sourceforge.net with esmtp (TLSv1:RC4-SHA:128)
	(Exim 4.30)
	id 1BVXbJ-0001nP-0g
	for nfs@lists.sourceforge.net; Wed, 02 Jun 2004 08:24:21 -0700
To: Marc Schmitt <mschmitt@inf.ethz.ch>
In-Reply-To: <40BDE65F.1000009@inf.ethz.ch>
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

P=E5 on , 02/06/2004 klokka 07:38, skreiv Marc Schmitt:

> that the network layer is ok. I did the test using -o=20
> tcp,nfsvers=3D3,rsize=3D32768,wsize=3D32768, too, it made no difference a=
t all.

Exactly how did you do this test? Could you check that the
tcp,rsize=3D32k,wsize=3D32k also turn up in /proc/mounts, and then retest?

The reason I ask is that there are 2 things that could corrupt your
test:

  You used "-oremount" to change from udp to tcp. That won't work!

  You may have had the same filesystem mounted as udp on another
mountpoint. In that case the udp filesystem will be replicated on the
new mountpoint.

Cheers,
  Trond


-------------------------------------------------------
This SF.Net email is sponsored by the new InstallShield X.

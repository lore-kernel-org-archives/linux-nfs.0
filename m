From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: Stale mounts - very nasty
Date: 14 May 2003 17:29:07 +0200
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <shshe7xbl8c.fsf@charged.uio.no>
References: <5CA6F03EF05E0046AC5594562398B916A32939@POEXMB3.conoco.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: <nfs@lists.sourceforge.net>
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from pat.uio.no ([129.240.130.16])
	by sc8-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 19FyBv-0004ST-00
	for <nfs@lists.sourceforge.net>; Wed, 14 May 2003 08:29:15 -0700
To: "Heflin, Roger A." <Roger.A.Heflin@conocophillips.com>
In-Reply-To: <5CA6F03EF05E0046AC5594562398B916A32939@POEXMB3.conoco.net>
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
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=nfs>

>>>>> " " == Roger A Heflin <Heflin> writes:

     > Guys, I have one of these, where it went into this state in the
     > middle of a copy, ie part of the a file got copied and then the
     > nfs partition when into this broken state, all with the server
     > doing nothing bad.

     > And I have now confirmed that it does it against Sun Solaris 8
     > servers, which makes it look like a client problem, and not a
     > server problem.

Mind showing us a tcpdump of a copy that fails? I don't buy that
'server doing nothing bad' theory without proof.

Under a reboot, the server may indeed use ESTALE to deny access to
files. Normally you ensure that this doesn't happen by killing nfsd
before you unexport the mounts, and by re-exporting before you start
nfsd (see the NFS list archives about the 'exportfs' ordering bugs in
older versions of nfs-utils).

If the server does return ESTALE, then the client is perfectly correct
in assuming that is a fatal error.

Cheers,
  Trond


-------------------------------------------------------
Enterprise Linux Forum Conference & Expo, June 4-6, 2003, Santa Clara
The only event dedicated to issues related to Linux enterprise solutions
www.enterpriselinuxforum.com

_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs

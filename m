From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: SM_UNMON again -> kernel
Date: 21 Jul 2003 01:28:40 +0200
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <shsptk4n5g7.fsf@charged.uio.no>
References: <20030711061615.GA1924@quasar.nro.au.com>
	<shsr84x768e.fsf@charged.uio.no> <87smpbkt55.fsf@ceramic.fifi.org>
	<shs8yr2h2jr.fsf@charged.uio.no> <87k7aml330.fsf@ceramic.fifi.org>
	<shsptkdij1a.fsf@charged.uio.no> <87vfu0ej5k.fsf@ceramic.fifi.org>
	<87n0fb42o5.fsf@ceramic.fifi.org> <20030719162218.GB7166@async.com.br>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Philippe Troin <phil@fifi.org>,
	  nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from pat.uio.no ([129.240.130.16] ident=7411)
	by sc8-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 19eNc1-00079f-00
	for <nfs@lists.sourceforge.net>; Sun, 20 Jul 2003 16:29:05 -0700
To: Christian Reis <kiko@async.com.br>
In-Reply-To: <20030719162218.GB7166@async.com.br>
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

>>>>> " " == Christian Reis <kiko@async.com.br> writes:

     > If there's one thing special, it's that this server also runs
     > an iptables firewall that does masquerading and supports
     > connection tracking. Could it be mangling the lock packets?

Huh? "Special" sounds like it would only begin to describe such a
setup...



The client has to be able to contact the server for portmapper, lockd,
nfs and statd. Exactly how are you doing this with masquerading
enabled?

In particular, how are you ensuring that the portmapper returns
correct information?

Cheers,
  Trond


-------------------------------------------------------
This SF.net email is sponsored by: VM Ware
With VMware you can run multiple operating systems on a single machine.
WITHOUT REBOOTING! Mix Linux / Windows / Novell virtual machines at the
same time. Free trial click here: http://www.vmware.com/wl/offer/345/0
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs

From: Philippe Troin <phil@fifi.org>
Subject: Re: SM_UNMON again -> kernel
Date: 12 Jul 2003 20:22:30 -0700
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <87smpbkt55.fsf@ceramic.fifi.org>
References: <20030711061615.GA1924@quasar.nro.au.com>
	<shsr84x768e.fsf@charged.uio.no>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Lawrence Ong <lawrence.ong@netregistry.com.au>, nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from tantale.fifi.org ([216.27.190.146] ident=root)
	by sc8-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 19bXSm-0004Nb-00
	for <nfs@lists.sourceforge.net>; Sat, 12 Jul 2003 20:23:48 -0700
To: Trond Myklebust <trond.myklebust@fys.uio.no>
In-Reply-To: <shsr84x768e.fsf@charged.uio.no>
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

Trond Myklebust <trond.myklebust@fys.uio.no> writes:

> Is /etc/hosts consistent? The kernel only sends MON/UNMON requests on
> the loopback port, so this suggests that something is translating
> 127.0.0.1<->"mymachine" instead of to "localhost".

I've also been seeing this forever... Which also means that locks are
never recovered after a server reboot, which is midly annoying.

What do you mean by "consistent" /etc/hosts?

% getent hosts localhost
127.0.0.1       localhost
% getent hosts 127.0.0.1
127.0.0.1       localhost
% host localhost
localhost has address 127.0.0.1
% host 127.0.0.1
1.0.0.127.in-addr.arpa domain name pointer localhost.

Is that consistent enough?

Phil.


-------------------------------------------------------
This SF.Net email sponsored by: Parasoft
Error proof Web apps, automate testing & more.
Download & eval WebKing and get a free book.
www.parasoft.com/bulletproofapps1
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs

From: Philippe Troin <phil@fifi.org>
Subject: Re: SM_UNMON again -> kernel
Date: 13 Jul 2003 11:00:03 -0700
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <87k7aml330.fsf@ceramic.fifi.org>
References: <20030711061615.GA1924@quasar.nro.au.com>
	<shsr84x768e.fsf@charged.uio.no> <87smpbkt55.fsf@ceramic.fifi.org>
	<shs8yr2h2jr.fsf@charged.uio.no>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Lawrence Ong <lawrence.ong@netregistry.com.au>, nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from tantale.fifi.org ([216.27.190.146] ident=root)
	by sc8-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 19bl9O-0005OK-00
	for <nfs@lists.sourceforge.net>; Sun, 13 Jul 2003 11:00:42 -0700
To: Trond Myklebust <trond.myklebust@fys.uio.no>
In-Reply-To: <shs8yr2h2jr.fsf@charged.uio.no>
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

> >>>>> " " == Philippe Troin <phil@fifi.org> writes:
> 
>      > Trond Myklebust <trond.myklebust@fys.uio.no> writes:
>     >> Is /etc/hosts consistent? The kernel only sends MON/UNMON
>     >> requests on the loopback port, so this suggests that something
>     >> is translating 127.0.0.1<->"mymachine" instead of to
>     >> "localhost".
> 
>      > I've also been seeing this forever... Which also means that
>      > locks are never recovered after a server reboot, which is midly
>      > annoying.
> 
> The *same* error, with a message that appears not to be originating
> from 127.0.0.l?

Yup.

On machine #1:
ceramic rpc.statd[30693]: Received erroneous SM_UNMON request from ceramic for 216.27.190.149

On machine #2:
tantale rpc.statd[18416]: Received erroneous SM_UNMON request from tantale for 216.27.190.148

>      > What do you mean by "consistent" /etc/hosts?
> 
> I mean crap like
> 
> 127.0.0.l     localhost mymachine
> 
> in /etc/hosts, together with a DNS entry translates the name
> "mymachine" into another IP address.
> 
> Believe me. It's been done...

Oh, I'm sure about that :-)

Phil.


-------------------------------------------------------
This SF.Net email sponsored by: Parasoft
Error proof Web apps, automate testing & more.
Download & eval WebKing and get a free book.
www.parasoft.com/bulletproofapps1
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs

From: Lawrence Ong <lawrence.ong@netregistry.com.au>
Subject: Re: SM_UNMON again -> kernel
Date: Mon, 14 Jul 2003 09:36:27 +1000
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <20030713233627.GA17548@quasar.nro.au.com>
References: <20030711061615.GA1924@quasar.nro.au.com> <shsr84x768e.fsf@charged.uio.no> <87smpbkt55.fsf@ceramic.fifi.org> <shs8yr2h2jr.fsf@charged.uio.no> <87k7aml330.fsf@ceramic.fifi.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Trond Myklebust <trond.myklebust@fys.uio.no>, nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from mail.netregistry.net ([203.202.16.100] helo=roanoak.netregistry.net)
	by sc8-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 19bqbP-0002aB-00
	for <nfs@lists.sourceforge.net>; Sun, 13 Jul 2003 16:49:59 -0700
Received: from proxy.netregistry.net ([203.202.16.2] helo=quasar.nro.au.com)
	by roanoak.netregistry.net with esmtp (Exim 3.35 #1 (Debian))
	id 19bqam-0007Sy-00
	for <nfs@lists.sourceforge.net>; Mon, 14 Jul 2003 09:49:20 +1000
Received: from long by quasar.nro.au.com with local (Exim 3.36 #1 (Debian))
	id 19bqaG-0004d1-00
	for <nfs@lists.sourceforge.net>; Mon, 14 Jul 2003 09:48:48 +1000
To: Philippe Troin <phil@fifi.org>
In-Reply-To: <87k7aml330.fsf@ceramic.fifi.org>
Resent-Message-Id: <E19bqaG-0004d1-00@quasar.nro.au.com>
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

On Sun, Jul 13, 2003 at 11:00:03AM -0700, Philippe Troin wrote:
> > I mean crap like
> > 
> > 127.0.0.l     localhost mymachine
> > 
> > in /etc/hosts, together with a DNS entry translates the name
> > "mymachine" into another IP address.
> > 
> > Believe me. It's been done...
> 
> Oh, I'm sure about that :-)
> 
> Phil.

The funny thing is that when i PUT in crap like that, the erroneous
error disappeared.  Of course, it's not suppose to be correct.  Just
placed it in there for testing.

Lawrence


-------------------------------------------------------
This SF.Net email sponsored by: Parasoft
Error proof Web apps, automate testing & more.
Download & eval WebKing and get a free book.
www.parasoft.com/bulletproofapps1
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs

From: Christian Reis <kiko@async.com.br>
Subject: Re: SM_UNMON again -> kernel
Date: Sun, 20 Jul 2003 20:45:58 -0300
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <20030720234558.GD1570@async.com.br>
References: <20030711061615.GA1924@quasar.nro.au.com> <shsr84x768e.fsf@charged.uio.no> <87smpbkt55.fsf@ceramic.fifi.org> <shs8yr2h2jr.fsf@charged.uio.no> <87k7aml330.fsf@ceramic.fifi.org> <shsptkdij1a.fsf@charged.uio.no> <87vfu0ej5k.fsf@ceramic.fifi.org> <87n0fb42o5.fsf@ceramic.fifi.org> <20030719162218.GB7166@async.com.br> <shsptk4n5g7.fsf@charged.uio.no>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Philippe Troin <phil@fifi.org>, nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from 200-206-134-238.async.com.br
	([200.206.134.238] helo=anthem.async.com.br ident=root)
	by sc8-sf-list1.sourceforge.net with esmtp
	(Cipher TLSv1:DES-CBC3-SHA:168) (Exim 3.31-VA-mm2 #1 (Debian))
	id 19eNsf-0002cM-00
	for <nfs@lists.sourceforge.net>; Sun, 20 Jul 2003 16:46:18 -0700
To: Trond Myklebust <trond.myklebust@fys.uio.no>
In-Reply-To: <shsptk4n5g7.fsf@charged.uio.no>
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

On Mon, Jul 21, 2003 at 01:28:40AM +0200, Trond Myklebust wrote:
> >>>>> " " == Christian Reis <kiko@async.com.br> writes:
> 
>      > If there's one thing special, it's that this server also runs
>      > an iptables firewall that does masquerading and supports
>      > connection tracking. Could it be mangling the lock packets?
> 
> Huh? "Special" sounds like it would only begin to describe such a
> setup...

Oh, the masquerading has nothing to do with NFS. The NFS clients and the
server are all on the same local subnet. I just mentioned this to
indicate that something special might be happening on the packet level
(unfrag/frag) because this box is also a firewall, not that the clients
communicate with the server through a firewall.

Take care,
--
Christian Reis, Senior Engineer, Async Open Source, Brazil.
http://async.com.br/~kiko/ | [+55 16] 261 2331 | NMFL


-------------------------------------------------------
This SF.net email is sponsored by: VM Ware
With VMware you can run multiple operating systems on a single machine.
WITHOUT REBOOTING! Mix Linux / Windows / Novell virtual machines at the
same time. Free trial click here: http://www.vmware.com/wl/offer/345/0
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs

From: Christian Reis <kiko@async.com.br>
Subject: Re: SM_UNMON again -> kernel
Date: Sat, 19 Jul 2003 13:22:18 -0300
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <20030719162218.GB7166@async.com.br>
References: <20030711061615.GA1924@quasar.nro.au.com> <shsr84x768e.fsf@charged.uio.no> <87smpbkt55.fsf@ceramic.fifi.org> <shs8yr2h2jr.fsf@charged.uio.no> <87k7aml330.fsf@ceramic.fifi.org> <shsptkdij1a.fsf@charged.uio.no> <87vfu0ej5k.fsf@ceramic.fifi.org> <87n0fb42o5.fsf@ceramic.fifi.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Trond Myklebust <trond.myklebust@fys.uio.no>, nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from 200-206-134-238.async.com.br
	([200.206.134.238] helo=anthem.async.com.br ident=root)
	by sc8-sf-list1.sourceforge.net with esmtp
	(Cipher TLSv1:DES-CBC3-SHA:168) (Exim 3.31-VA-mm2 #1 (Debian))
	id 19duU8-00084t-00
	for <nfs@lists.sourceforge.net>; Sat, 19 Jul 2003 09:23:01 -0700
To: Philippe Troin <phil@fifi.org>
In-Reply-To: <87n0fb42o5.fsf@ceramic.fifi.org>
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

On Fri, Jul 18, 2003 at 08:26:50PM -0700, Philippe Troin wrote:
> I still see the same messages over and over again.

Just to add a data point, I see the same message periodically on our
diskless network -- all clients are linux 2.4.21 (debian woody), as is
the server (no relevant patches).  However, the IP addresses in the
messages are for the *remote* boxes.

Server (anthem 192.168.99.4) logs:

    Jul 12 17:50:10 anthem rpc.statd[326]: Received erroneous
        SM_UNMON request from anthem for 192.168.99.6
    Jul 12 17:54:37 anthem rpc.statd[326]: Received erroneous
        SM_UNMON request from anthem for 192.168.99.6
    Jul 12 18:07:03 anthem rpc.statd[326]: Received erroneous
        SM_UNMON request from anthem for 192.168.99.6
    Jul 12 18:13:10 anthem rpc.statd[326]: Received erroneous
        SM_UNMON request from anthem for 192.168.99.6

[One] client (manonegra 192.168.99.6) log:

    Jul 18 18:07:33 manonegra rpc.statd[115]: Received
        erroneous SM_UNMON request from manonegra for 192.168.99.4
    Jul 18 18:17:33 manonegra rpc.statd[115]: Received
        erroneous SM_UNMON request from manonegra for 192.168.99.4
    Jul 18 18:35:08 manonegra rpc.statd[115]: Received
        erroneous SM_UNMON request from manonegra for 192.168.99.4
    Jul 18 18:39:22 manonegra rpc.statd[115]: Received
        erroneous SM_UNMON request from manonegra for 192.168.99.4

It goes on forever. There's nothing fishy on the 127.0.0.1 lines in the
hosts file or in DNS. The logs go back for a year now.

If there's one thing special, it's that this server also runs an
iptables firewall that does masquerading and supports connection
tracking. Could it be mangling the lock packets? I recall seeing
something similar a long time ago..

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

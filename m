From: Ryan Richter <ryan@tau.solarneutrino.net>
Subject: Re: lockd: couldn't create RPC handle for (host)
Date: Sat, 17 Dec 2005 00:59:08 -0500
Message-ID: <20051217055907.GC20539@tau.solarneutrino.net>
References: <20051216205536.GA20497@tau.solarneutrino.net> <1134776945.7952.4.camel@lade.trondhjem.org> <20051216235841.GA20539@tau.solarneutrino.net> <1134797577.20929.2.camel@lade.trondhjem.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: nfs@lists.sourceforge.net, linux-kernel@vger.kernel.org,
	ryan@tau.solarneutrino.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91] helo=mail.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1EnV68-0005YB-DZ
	for nfs@lists.sourceforge.net; Fri, 16 Dec 2005 21:59:12 -0800
Received: from solarneutrino.net ([66.199.224.43] helo=tau.solarneutrino.net)
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44)
	id 1EnV67-0008DL-6f
	for nfs@lists.sourceforge.net; Fri, 16 Dec 2005 21:59:12 -0800
To: Trond Myklebust <trond.myklebust@fys.uio.no>
In-Reply-To: <1134797577.20929.2.camel@lade.trondhjem.org>
Sender: nfs-admin@lists.sourceforge.net
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

On Sat, Dec 17, 2005 at 12:32:57AM -0500, Trond Myklebust wrote:
> On Fri, 2005-12-16 at 18:58 -0500, Ryan Richter wrote:
> > On Fri, Dec 16, 2005 at 06:49:05PM -0500, Trond Myklebust wrote:
> > > On Fri, 2005-12-16 at 15:55 -0500, Ryan Richter wrote:
> > > > Hi, nfs locking stopped working on my file server running 2.6.15-rc5
> > > > today.  All clients that try locking operations hang, and I get the
> > > > message from the server:
> > > > 
> > > > lockd: couldn't create RPC handle for w.x.y.z
> > > 
> > > Points either to a client which is not responding to callbacks, or an
> > > OOM situation on the server.
> > > 
> > > Does 'rpcinfo -u w.x.y.z 100021' work from the server?
> > 
> > No.
> > 
> > $ rpcinfo -u jacquere 100021
> > rpcinfo: RPC: Timed out
> > program 100021 version 0 is not available
> > zsh: exit 1     rpcinfo -u jacquere 100021
> > 
> > So I see now lockd is not present on the client. But...
> > 
> > $ rpcinfo -p jacquere
> >    program vers proto   port
> >     100000    2   tcp    111  portmapper
> >     100000    2   udp    111  portmapper
> >     100021    1   udp  32768  nlockmgr
> >     100021    3   udp  32768  nlockmgr
> >     100021    4   udp  32768  nlockmgr
> >     100024    1   udp    867  status
> >     100024    1   tcp    870  status
> > 
> > So what does that mean?
> 
> Looks to me as if port 111 is pingable (since you can talk to the
> portmapper), but port 32768 is not. Are you using port filtering or
> firewalling anywhere (on the client, server, or switches)?

There's no filtering between the two.  I get this on the machine itself:
$ rpcinfo -u localhost 100021
rpcinfo: RPC: Timed out
program 100021 version 0 is not available
zsh: exit 1     rpcinfo -u localhost 100021

There's no lockd process running on this client machine anymore.

On the server:

$ rpcinfo -u localhost 100021               
program 100021 version 1 ready and waiting
rpcinfo: RPC: Program/version mismatch; low version = 1, high version =4
program 100021 version 2 is not available
program 100021 version 3 ready and waiting
program 100021 version 4 ready and waiting
zsh: exit 1     rpcinfo -u localhost 100021

Also neither machine is anywhere close to OOM.

-ryan


-------------------------------------------------------
This SF.net email is sponsored by: Splunk Inc. Do you grep through log files
for problems?  Stop!  Download the new AJAX search engine that makes
searching your log files as easy as surfing the  web.  DOWNLOAD SPLUNK!
http://ads.osdn.com/?ad_id=7637&alloc_id=16865&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs

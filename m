From: Ryan Richter <ryan@tau.solarneutrino.net>
Subject: Re: lockd: couldn't create RPC handle for (host)
Date: Sat, 17 Dec 2005 02:02:22 -0500
Message-ID: <20051217070222.GD20539@tau.solarneutrino.net>
References: <20051216205536.GA20497@tau.solarneutrino.net> <1134776945.7952.4.camel@lade.trondhjem.org> <20051216235841.GA20539@tau.solarneutrino.net> <1134797577.20929.2.camel@lade.trondhjem.org> <20051217055907.GC20539@tau.solarneutrino.net> <1134801822.7946.4.camel@lade.trondhjem.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: nfs@lists.sourceforge.net, linux-kernel@vger.kernel.org,
	ryan@tau.solarneutrino.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92] helo=mail.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1EnW5K-0000ah-5a
	for nfs@lists.sourceforge.net; Fri, 16 Dec 2005 23:02:26 -0800
Received: from solarneutrino.net ([66.199.224.43] helo=tau.solarneutrino.net)
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44)
	id 1EnW5I-0004M4-RW
	for nfs@lists.sourceforge.net; Fri, 16 Dec 2005 23:02:26 -0800
To: Trond Myklebust <trond.myklebust@fys.uio.no>
In-Reply-To: <1134801822.7946.4.camel@lade.trondhjem.org>
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

On Sat, Dec 17, 2005 at 01:43:42AM -0500, Trond Myklebust wrote:
> On Sat, 2005-12-17 at 00:59 -0500, Ryan Richter wrote:
> 
> > There's no filtering between the two.  I get this on the machine itself:
> > $ rpcinfo -u localhost 100021
> > rpcinfo: RPC: Timed out
> > program 100021 version 0 is not available
> > zsh: exit 1     rpcinfo -u localhost 100021
> > 
> > There's no lockd process running on this client machine anymore.
> 
> ...yet the client still has the partition mounted, and isn't using the
> -onolock option? That sounds weird.

There are lots of nfs mounts, the root is ro nolock, but the trouble is
with the home directories which are rw lock.  Everything is still
mounted, I can ssh in fine etc.  The problem is with people using kde -
it tries to lock some file in the home directory during the login
process and hangs.

> Is the client also running 2.6.15-rc5?

No, 2.6.14.2.

-ryan


-------------------------------------------------------
This SF.net email is sponsored by: Splunk Inc. Do you grep through log files
for problems?  Stop!  Download the new AJAX search engine that makes
searching your log files as easy as surfing the  web.  DOWNLOAD SPLUNK!
http://ads.osdn.com/?ad_id=7637&alloc_id=16865&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs

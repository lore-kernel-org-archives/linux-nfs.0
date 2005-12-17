From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: lockd: couldn't create RPC handle for (host)
Date: Sat, 17 Dec 2005 14:28:19 -0500
Message-ID: <1134847699.7950.25.camel@lade.trondhjem.org>
References: <20051216205536.GA20497@tau.solarneutrino.net>
	 <1134776945.7952.4.camel@lade.trondhjem.org>
	 <20051216235841.GA20539@tau.solarneutrino.net>
	 <1134797577.20929.2.camel@lade.trondhjem.org>
	 <20051217055907.GC20539@tau.solarneutrino.net>
	 <1134801822.7946.4.camel@lade.trondhjem.org>
	 <20051217070222.GD20539@tau.solarneutrino.net>
Mime-Version: 1.0
Content-Type: text/plain
Cc: nfs@lists.sourceforge.net, linux-kernel@vger.kernel.org
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92] helo=mail.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1EnhjR-0003Vw-6K
	for nfs@lists.sourceforge.net; Sat, 17 Dec 2005 11:28:37 -0800
Received: from pat.uio.no ([129.240.130.16] ident=7411)
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44)
	id 1EnhjP-0005gr-Kl
	for nfs@lists.sourceforge.net; Sat, 17 Dec 2005 11:28:37 -0800
To: Ryan Richter <ryan@tau.solarneutrino.net>
In-Reply-To: <20051217070222.GD20539@tau.solarneutrino.net>
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

On Sat, 2005-12-17 at 02:02 -0500, Ryan Richter wrote:
> > > There's no filtering between the two.  I get this on the machine itself:
> > > $ rpcinfo -u localhost 100021
> > > rpcinfo: RPC: Timed out
> > > program 100021 version 0 is not available
> > > zsh: exit 1     rpcinfo -u localhost 100021
> > > 
> > > There's no lockd process running on this client machine anymore.
> > 
> > ...yet the client still has the partition mounted, and isn't using the
> > -onolock option? That sounds weird.
> 
> There are lots of nfs mounts, the root is ro nolock, but the trouble is
> with the home directories which are rw lock.  Everything is still
> mounted, I can ssh in fine etc.  The problem is with people using kde -
> it tries to lock some file in the home directory during the login
> process and hangs.

So what do you mean when you say that there is "no lockd process
running" on the client?

Is it not appearing in the output of 'ps -ef' either?

Is anything at all listening on port 32768 on 'jacquere'? (check using
'netstat -ap | grep 32768').

Could anything be playing around with the 'pmap_set' utility so as to
corrupt portmap?

Are you perhaps setting /proc/sys/fs/nfs/nlm_udpport and/or the kernel
parameter nfs.nlm_udpport? If so, to what?

Cheers,
  Trond



-------------------------------------------------------
This SF.net email is sponsored by: Splunk Inc. Do you grep through log files
for problems?  Stop!  Download the new AJAX search engine that makes
searching your log files as easy as surfing the  web.  DOWNLOAD SPLUNK!
http://ads.osdn.com/?ad_id=7637&alloc_id=16865&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs

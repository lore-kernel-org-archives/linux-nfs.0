From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: lockd: couldn't create RPC handle for (host)
Date: Sun, 18 Dec 2005 03:33:56 -0500
Message-ID: <1134894836.7931.17.camel@lade.trondhjem.org>
References: <20051216205536.GA20497@tau.solarneutrino.net>
	 <1134776945.7952.4.camel@lade.trondhjem.org>
	 <20051216235841.GA20539@tau.solarneutrino.net>
	 <1134797577.20929.2.camel@lade.trondhjem.org>
	 <20051217055907.GC20539@tau.solarneutrino.net>
	 <1134801822.7946.4.camel@lade.trondhjem.org>
	 <20051217070222.GD20539@tau.solarneutrino.net>
	 <1134847699.7950.25.camel@lade.trondhjem.org>
	 <20051217194553.GE20539@tau.solarneutrino.net>
Mime-Version: 1.0
Content-Type: text/plain
Cc: nfs@lists.sourceforge.net, linux-kernel@vger.kernel.org
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91] helo=mail.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1Enu0a-0005zi-2A
	for nfs@lists.sourceforge.net; Sun, 18 Dec 2005 00:35:08 -0800
Received: from pat.uio.no ([129.240.130.16] ident=7411)
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44)
	id 1Enu0Y-0004cp-I6
	for nfs@lists.sourceforge.net; Sun, 18 Dec 2005 00:35:08 -0800
To: Ryan Richter <ryan@tau.solarneutrino.net>
In-Reply-To: <20051217194553.GE20539@tau.solarneutrino.net>
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

On Sat, 2005-12-17 at 14:45 -0500, Ryan Richter wrote:
> > So what do you mean when you say that there is "no lockd process
> > running" on the client?
> > 
> > Is it not appearing in the output of 'ps -ef' either?
> 
> Nope.
> 
> $ ps -ef|grep lock
> root        77     5  0 Nov20 ?        00:00:00 [kblockd/0]
> foo       6811  6800  0 14:29 pts/0    00:00:00 grep -E lock

Any Oopses? (use 'dmesg')

Could you also check dmesg for any entries of the form

'lockd: new process, skipping host shutdown'
or
'lockd_up: makesock failed, error='

> > Is anything at all listening on port 32768 on 'jacquere'? (check using
> > 'netstat -ap | grep 32768').
> 
> Er... sort of?
> 
> # netstat -ap | grep 32768
> udp    11144      0 *:32768                 *:*                                -                   
> I'm not sure what that means...  lsof|grep 32768 returns nothing.

That could be a kernel process. The RPC client has no reason to set up a
full file descriptor for the socket.

Could you please finally double-check that the entries in /proc/mounts
for your NFS mounts do contain the 'lock' mount option.

Finally, please do

echo 1 > /proc/sys/sunrpc/rpc_lockd
then unmount one of your NFS partitions, and then mount it again.


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

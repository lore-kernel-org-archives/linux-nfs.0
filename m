From: Matt C <wago@phlinux.com>
Subject: RE: 'random' diskless clients hangs
Date: Mon, 8 Sep 2003 22:48:26 -0700 (PDT)
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <Pine.LNX.4.44.0309082136570.1153-100000@fubar.phlinux.com>
References: <NEBBIHNAFKJAFOHBHGCOIEKLEFAA.nfsmailinglist@heessels.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list1.sourceforge.net with esmtp
	(Cipher TLSv1:DES-CBC3-SHA:168) (Exim 3.31-VA-mm2 #1 (Debian))
	id 19wbN4-00052S-00
	for <nfs@lists.sourceforge.net>; Mon, 08 Sep 2003 22:48:58 -0700
Received: from fubar.phlinux.com ([216.254.54.154])
	by sc8-sf-mx1.sourceforge.net with esmtp (Exim 4.22)
	id 19wbN3-0004P2-Fd
	for nfs@lists.sourceforge.net; Mon, 08 Sep 2003 22:48:57 -0700
To: nfsmailinglist@heessels.com
In-Reply-To: <NEBBIHNAFKJAFOHBHGCOIEKLEFAA.nfsmailinglist@heessels.com>
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

We can't have you give up on NFS, now can we? :)

1. check out the output of 'netstat -sw' on both the client and server. 
Look for the 'packet reassemblies failed'. If it's incrementing at any 
considerable rate, you're dropping packets somewhere in transit. This 
generally indicates network issues, so I'd look into that.

2. try a network card with a different chipset. While I've had good luck 
with the intel cards, it doesn't hurt to try a 3com instead. If nothing 
else, if changing the card _type_ makes a difference in your problems, it 
helps us narrow down the problem.

3. enable the NMI watchdog on the clients. this will help catch some 
deadlock conditions, and may give us an OOPS instead of a lockup. To 
enable this, you add 'nmi_watchdog=1' to your kernel commandline. Since 
you're nfsroot booting, you'd probably add this to the append= line in 
your /tftpboot/pxelinux.cfg/ config file.

4. try and older kernel on the client to see if older kernels are stable. 
I'd recommend 2.4.18, since it has worked well for us in the past. It 
certainly has it's bugs, but it's largely stable.

5. enable remote syslog, and enable nfs/rpc debugging on the clients by 
echoing 32767 into /proc/sys/sunrpc/{nfs|rpc}_debug. this will give you 
better information about what NFS traffic is leading up to your lockup.

Hope this stuff helps you some. It's what I'd be doing to troubleshoot 
issues like yours.

-matt

On Mon, 8 Sep 2003 nfsmailinglist@heessels.com wrote:

> Help!! We're closing to giving up on NFS.
> 
> We have tried multiple NICS and drivers on both server and client (eepro100,
> e100, e1000).
> We have tries both UDP and TCP.
> We have tried multiple versions of nfs-utils.
> We have tried multiple versions of the kernel.
> We have tried multiple clients.
> We have tried multiple switches.
> 
> Clients keep crashing unless we use rsize&wsize<=2048, but the load on
> server and clients then get very high.
> 
> 
> -----Original Message-----
> From: nfs-admin@lists.sourceforge.net
> [mailto:nfs-admin@lists.sourceforge.net]On Behalf Of Bogdan Costescu
> Sent: zaterdag 6 september 2003 20:27
> To: nfsmailinglist@heessels.com
> Cc: nfs@lists.sourceforge.net
> Subject: RE: [NFS] 'random' diskless clients hangs
> 
> 
> On Sat, 6 Sep 2003 nfsmailinglist@heessels.com wrote:
> 
> > Driver is the default from kernel linux-2.4.20-18.7:
> > CONFIG_EEPRO100=y
> 
> Could you also try using the e100 driver ? eepro100 seems to be
> unmaintained lately while the guys at Intel actively support e100.
> 
> -
> 
> Bogdan Costescu
> 
> IWR - Interdisziplinaeres Zentrum fuer Wissenschaftliches Rechnen
> Universitaet Heidelberg, INF 368, D-69120 Heidelberg, GERMANY
> Telephone: +49 6221 54 8869, Telefax: +49 6221 54 8868
> E-mail: Bogdan.Costescu@IWR.Uni-Heidelberg.De
> 
> 
> 
> -------------------------------------------------------
> This sf.net email is sponsored by:ThinkGeek
> Welcome to geek heaven.
> http://thinkgeek.com/sf
> _______________________________________________
> NFS maillist  -  NFS@lists.sourceforge.net
> https://lists.sourceforge.net/lists/listinfo/nfs
> 
> 
> 
> 
> -------------------------------------------------------
> This sf.net email is sponsored by:ThinkGeek
> Welcome to geek heaven.
> http://thinkgeek.com/sf
> _______________________________________________
> NFS maillist  -  NFS@lists.sourceforge.net
> https://lists.sourceforge.net/lists/listinfo/nfs
> 




-------------------------------------------------------
This sf.net email is sponsored by:ThinkGeek
Welcome to geek heaven.
http://thinkgeek.com/sf
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs

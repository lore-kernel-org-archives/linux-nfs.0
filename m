From: "Ara.T.Howard" <Ara.T.Howard@noaa.gov>
Subject: Re: Debian Bug#203077: Locks not released on NFS client reboot
Date: Fri, 14 Jan 2005 07:53:53 -0700 (MST)
Message-ID: <Pine.LNX.4.60.0501140750370.11608@harp.ngdc.noaa.gov>
References: <Pine.OSF.4.56.0307271137050.10355@grover.WPI.EDU>
 <20030727163124.GC19877@perlsupport.com>  <16164.29864.268358.781865@gargle.gargle.HOWL>
  <Pine.LNX.4.60.0501131844130.6332@harp.ngdc.noaa.gov>
 <1105671720.20314.8.camel@lade.trondhjem.org>
Reply-To: "Ara.T.Howard" <Ara.T.Howard@noaa.gov>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII; format=flowed
Cc: Neil Brown <neilb@cse.unsw.edu.au>,
	Chip Salzenberg <chip@pobox.com>, nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.12] helo=sc8-sf-mx2.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1CpSpy-0003Lr-LF
	for nfs@lists.sourceforge.net; Fri, 14 Jan 2005 06:54:06 -0800
Received: from harp.ngdc.noaa.gov ([140.172.187.26])
	by sc8-sf-mx2.sourceforge.net with esmtp (TLSv1:AES256-SHA:256)
	(Exim 4.41)
	id 1CpSpy-00042l-8T
	for nfs@lists.sourceforge.net; Fri, 14 Jan 2005 06:54:06 -0800
To: Trond Myklebust <trond.myklebust@fys.uio.no>
In-Reply-To: <1105671720.20314.8.camel@lade.trondhjem.org>
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

On Thu, 13 Jan 2005, Trond Myklebust wrote:

> to den 13.01.2005 Klokka 18:51 (-0700) skreiv Ara.T.Howard:
>
>>    server:
>>
>>      mussel:~ > rpcinfo -u bligh status
>>      rpcinfo: RPC: Port mapper failure - RPC: Unable to receive
>>      program 100024 is not available
>
> If the portmapper on the server is not responding to the client (as the
> above error message appears to indicate) then that would explain your
> problem.

here's the thing - nothing has changed execpt a kernel upgrade on the client -
it rebooted to a new kernel and now the locks are stale.  client is latest
enterprise and server is the next latest enterprise since it has not (yet)
been rebooted.  i'm waiting for our sysads to get here to work on it... i'd
reboot now except i'm afraid i'll lose any debugging state...

-a
-- 
===============================================================================
| EMAIL   :: Ara [dot] T [dot] Howard [at] noaa [dot] gov
| PHONE   :: 303.497.6469
| When you do something, you should burn yourself completely, like a good
| bonfire, leaving no trace of yourself.  --Shunryu Suzuki
===============================================================================


-------------------------------------------------------
The SF.Net email is sponsored by: Beat the post-holiday blues
Get a FREE limited edition SourceForge.net t-shirt from ThinkGeek.
It's fun and FREE -- well, almost....http://www.thinkgeek.com/sfshirt
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs

From: "Ara.T.Howard" <Ara.T.Howard@noaa.gov>
Subject: Re: Debian Bug#203077: Locks not released on NFS client reboot
Date: Thu, 13 Jan 2005 18:51:16 -0700 (MST)
Message-ID: <Pine.LNX.4.60.0501131844130.6332@harp.ngdc.noaa.gov>
References: <Pine.OSF.4.56.0307271137050.10355@grover.WPI.EDU>
 <20030727163124.GC19877@perlsupport.com> <16164.29864.268358.781865@gargle.gargle.HOWL>
Reply-To: "Ara.T.Howard" <Ara.T.Howard@noaa.gov>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII; format=flowed
Cc: Chip Salzenberg <chip@pobox.com>, nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.12] helo=sc8-sf-mx2.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1CpGcX-0002rj-1n
	for nfs@lists.sourceforge.net; Thu, 13 Jan 2005 17:51:25 -0800
Received: from harp.ngdc.noaa.gov ([140.172.187.26])
	by sc8-sf-mx2.sourceforge.net with esmtp (TLSv1:AES256-SHA:256)
	(Exim 4.41)
	id 1CpGcV-0000tn-I6
	for nfs@lists.sourceforge.net; Thu, 13 Jan 2005 17:51:24 -0800
To: Neil Brown <neilb@cse.unsw.edu.au>
In-Reply-To: <16164.29864.268358.781865@gargle.gargle.HOWL>
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

On Mon, 28 Jul 2003, Neil Brown wrote:

> On Sunday July 27, chip@pobox.com wrote:
>> I confess I don't quite understand this bug report.  Is this person
>> asking for something that NFS can't do, or is there perhaps some error
>> in configuration ... ?
>>
>> Please advise.
>

  SNIP

>
> Anyway, I suggest that the person having the problem tries:
>
>    rpcinfo -u SERVERNAME status
> from the client, and
>
>    rpcinfo -u CLIENTNAME status
> from the server
> and checks that both works.  If either doesn't I suspect that is the
> problem. If they both work.... I don't know.

  SNIP


i am seeing problems here on my system (which has rebooted and now has stale
locks on server)

   client:

     bligh:~ > rpcinfo -u mussel status
     program 100024 version 1 ready and waiting

   server:

     mussel:~ > rpcinfo -u bligh status
     rpcinfo: RPC: Port mapper failure - RPC: Unable to receive
     program 100024 is not available

the client rebooted into a new kernel (latest enterprise) and the server has
not.  could this cause this problem?  if not what other info should i be
looking for.

not sure if this is helpful but:

   client:

     bligh:~ > rpcinfo -p
        program vers proto   port
         100000    2   tcp    111  portmapper
         100000    2   udp    111  portmapper
         100024    1   udp  32768  status
         100024    1   tcp  32768  status
         100021    1   udp  32769  nlockmgr
         100021    3   udp  32769  nlockmgr
         100021    4   udp  32769  nlockmgr
         100021    1   tcp  32769  nlockmgr
         100021    3   tcp  32769  nlockmgr
         100021    4   tcp  32769  nlockmgr


   server:

     mussel:~ > rpcinfo -p
        program vers proto   port
         100000    2   tcp    111  portmapper
         100000    2   udp    111  portmapper
         100024    1   udp  32768  status
         100024    1   tcp  32768  status
         100011    1   udp    768  rquotad
         100011    2   udp    768  rquotad
         100011    1   tcp    771  rquotad
         100011    2   tcp    771  rquotad
         100003    2   udp   2049  nfs
         100003    3   udp   2049  nfs
         100003    2   tcp   2049  nfs
         100003    3   tcp   2049  nfs
         100021    1   udp  33551  nlockmgr
         100021    3   udp  33551  nlockmgr
         100021    4   udp  33551  nlockmgr
         100021    1   tcp  37939  nlockmgr
         100021    3   tcp  37939  nlockmgr
         100021    4   tcp  37939  nlockmgr
         100005    1   udp    784  mountd
         100005    1   tcp    787  mountd
         100005    2   udp    784  mountd
         100005    2   tcp    787  mountd
         100005    3   udp    784  mountd
         100005    3   tcp    787  mountd


thanks in advance for any help.

kind regards.

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

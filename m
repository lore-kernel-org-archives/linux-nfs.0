From: "Ara.T.Howard" <Ara.T.Howard@noaa.gov>
Subject: Re: Debian Bug#203077: Locks not released on NFS client reboot
Date: Fri, 21 Jan 2005 11:32:07 -0700 (MST)
Message-ID: <Pine.LNX.4.60.0501211118380.15036@harp.ngdc.noaa.gov>
References: <Pine.OSF.4.56.0307271137050.10355@grover.WPI.EDU>
 <20030727163124.GC19877@perlsupport.com>  <16164.29864.268358.781865@gargle.gargle.HOWL>
  <Pine.LNX.4.60.0501131844130.6332@harp.ngdc.noaa.gov>
 <16871.11926.507904.373575@cse.unsw.edu.au>  <Pine.LNX.4.60.0501201709220.5142@harp.ngdc.noaa.gov>
 <1106268738.30991.11.camel@lade.trondhjem.org>
Reply-To: "Ara.T.Howard" <Ara.T.Howard@noaa.gov>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII; format=flowed
Cc: Neil Brown <neilb@cse.unsw.edu.au>,
	Chip Salzenberg <chip@pobox.com>, nfs@lists.sourceforge.net,
	Mark O Sleeper <Mark.O.Sleeper@noaa.gov>, thomas.r.carey@noaa.gov
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.12] helo=sc8-sf-mx2.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1Cs3a4-0004bD-OU
	for nfs@lists.sourceforge.net; Fri, 21 Jan 2005 10:32:24 -0800
Received: from harp.ngdc.noaa.gov ([140.172.178.33])
	by sc8-sf-mx2.sourceforge.net with esmtp (TLSv1:AES256-SHA:256)
	(Exim 4.41)
	id 1Cs3a1-0002W9-7M
	for nfs@lists.sourceforge.net; Fri, 21 Jan 2005 10:32:24 -0800
To: Trond Myklebust <trond.myklebust@fys.uio.no>
In-Reply-To: <1106268738.30991.11.camel@lade.trondhjem.org>
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

On Thu, 20 Jan 2005, Trond Myklebust wrote:

> to den 20.01.2005 Klokka 17:24 (-0700) skreiv Ara.T.Howard:
>
>>    server iptables:
>>
>>      *filter
>>      :INPUT ACCEPT [0:0]
>>      :FORWARD ACCEPT [0:0]
>>      :OUTPUT ACCEPT [0:0]
>>      -N NFS
>>      -N ICMP
>>      -A INPUT -i lo -j ACCEPT
>>      -A INPUT -p icmp --icmp-type any -j ICMP
>>      -A INPUT -m state --state ESTABLISHED,RELATED -j ACCEPT
>>      -A INPUT -m state --state NEW -p tcp -m tcp --dport 22 -j SSH
>>      -A INPUT -m state --state NEW -p udp -m udp -j NFS
>>      -A INPUT -m state --state NEW -p tcp -m tcp --dport 2049 -j NFS
>>      -A INPUT -m state --state NEW -p tcp -m tcp --dport 111 -j NFS
>>      -A INPUT -m state --state NEW,INVALID -j REJECT --reject-with icmp-host-prohibited
>>      -A INPUT -j REJECT --reject-with icmp-host-prohibited
>>      -A ICMP -s 0/0 -j ACCEPT
>>      -A ICMP -j REJECT --reject-with icmp-host-prohibited
>>      -A NFS -s 10.1.0.0/16 -j ACCEPT
>>      -A NFS -j REJECT --reject-with icmp-host-prohibited
>>      -A SSH -s 10.1.0.0/16 -j ACCEPT
>>      -A SSH -j REJECT --reject-with icmp-host-prohibited
>>      COMMIT
>
> Where is the rule to accept incoming rpc.statd connections?
>
> Cheers,
>  Trond

sorry, we edited out the critical info.

on the client we have

   [root@bligh root]# rpcinfo -p
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

   [root@bligh root]# grep NFS /etc/sysconfig/iptables
   -N NFS
   -A INPUT -p tcp --dport 111 -j NFS
   -A INPUT -p udp --dport 111 -j NFS
   -A INPUT -p tcp --dport 32768:32769 -j NFS
   -A INPUT -p udp --dport 32768:32769 -j NFS
   -A NFS -s 10.1.186.70/32 -j ACCEPT
   -A NFS -j REJECT --reject-with icmp-host-prohibited

this did not work.  just to be safe we added

   on the server - where ip is the client's ip

     -A INPUT -s 10.1.186.71/32 -j ACCEPT

   on the client, where ip is the server's ip

     -A INPUT -s 10.1.186.54/32 -j ACCEPT

to the top of our ruleset before ANY denys.  still no go.  on shutdown/reboot
of the client there are no error message whatsoever.  however, we are seeing
lots of these in /var/log/messages

   ...
   ...
   ...
     Jan 21 10:55:50 moby rpc.statd[1985]: Received erroneous SM_UNMON request from moby.ngdc.noaa.gov for 10.1.186.62
     Jan 21 10:55:50 moby rpc.statd[1985]: Received erroneous SM_UNMON request from moby.ngdc.noaa.gov for 10.1.186.67
   ...
   ...
   ...

where the ips are those of various clients that are successfully performing
locking.  what is this about?

as i said before, both the server and all clients are multihomed with nfs
running only on the backdoor.  the frontdoor/backdoor have names like name,
name.b respectively.  these names are all in dns.  is there any chance this
could be related to lock recovery failure?

our sysad has suggested starting a tcpdump in the nfslock init.d script to see
what's happening - any other suggestions?

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
This SF.Net email is sponsored by: IntelliVIEW -- Interactive Reporting
Tool for open source databases. Create drag-&-drop reports. Save time
by over 75%! Publish reports on the web. Export to DOC, XLS, RTF, etc.
Download a FREE copy at http://www.intelliview.com/go/osdn_nl
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs

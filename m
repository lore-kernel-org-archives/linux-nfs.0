From: "Ara.T.Howard" <Ara.T.Howard@noaa.gov>
Subject: Re: Debian Bug#203077: Locks not released on NFS client reboot
 (fwd)
Date: Fri, 14 Jan 2005 07:56:35 -0700 (MST)
Message-ID: <Pine.LNX.4.60.0501140755320.11608@harp.ngdc.noaa.gov>
Reply-To: "Ara.T.Howard" <Ara.T.Howard@noaa.gov>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII; format=flowed
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.12] helo=sc8-sf-mx2.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1CpSsP-0003RC-1F
	for nfs@lists.sourceforge.net; Fri, 14 Jan 2005 06:56:37 -0800
Received: from harp.ngdc.noaa.gov ([140.172.187.26])
	by sc8-sf-mx2.sourceforge.net with esmtp (TLSv1:AES256-SHA:256)
	(Exim 4.41)
	id 1CpSsO-0004J6-Dh
	for nfs@lists.sourceforge.net; Fri, 14 Jan 2005 06:56:36 -0800
Received: from harp.ngdc.noaa.gov (harp.ngdc.noaa.gov [127.0.0.1])
	by harp.ngdc.noaa.gov (8.12.11/8.12.11) with ESMTP id j0EEuaOM018640
	for <nfs@lists.sourceforge.net>; Fri, 14 Jan 2005 07:56:36 -0700
Received: from localhost (ahoward@localhost)
	by harp.ngdc.noaa.gov (8.12.11/8.12.11/Submit) with ESMTP id j0EEuZqK018636
	for <nfs@lists.sourceforge.net>; Fri, 14 Jan 2005 07:56:36 -0700
To: nfs@lists.sourceforge.net
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


from one of our sysads

-a
-- 
===============================================================================
| EMAIL   :: Ara [dot] T [dot] Howard [at] noaa [dot] gov
| PHONE   :: 303.497.6469
| When you do something, you should burn yourself completely, like a good
| bonfire, leaving no trace of yourself.  --Shunryu Suzuki
===============================================================================

---------- Forwarded message ----------
Date: Fri, 14 Jan 2005 00:51:58 -0700
From: Thomas R Carey <Thomas.R.Carey@noaa.gov>
To: Ara.T.Howard <Ara.T.Howard@noaa.gov>
Cc: thomas.r.carey@noaa.gov, Mark O Sleeper <Mark.O.Sleeper@noaa.gov>
Subject: Re: [NFS] Debian Bug#203077: Locks not released on NFS client reboot
     (fwd)

Guys,

Rpc traffic does flow from bligh to mussel.

>From bligh:

[root@bligh root]# rpcinfo -u mussel status
program 100024 version 1 ready and waiting

This is allowed by the following firewall rules:
-N NFS
-A INPUT -m state --state NEW -p udp -m udp -j NFS
-A INPUT -m state --state NEW -p tcp -m tcp --dport 2049 -j NFS
-A INPUT -m state --state NEW -p tcp -m tcp --dport 111 -j NFS
-A NFS -s 10.1.0.0/16 -j ACCEPT
-A NFS -s 192.149.148.0/24 -j ACCEPT
-A NFS -s 140.172.166.0/24 -j ACCEPT
-A NFS -s 140.172.172.0/22 -j ACCEPT
-A NFS -s 140.172.176.0/21 -j ACCEPT
-A NFS -s 140.172.184.0/22 -j ACCEPT
-A NFS -j REJECT --reject-with icmp-host-prohibited

I would expect all nfs related traffic from bligh to mussel to be accepted. Why 
does mussel need to initiate any traffic to bligh? We have never allowed 
inbound rpc (port 111) connections to clients. Does the nfs protocol require 
it?

I have begun logging any attempts to connect to bligh port 111 tcp or udp on 
any interface. While checking the logs, I noticed the following error:

Jan 14 00:40:35 bligh rpc.statd[1054]: Received erroneous SM_UNMON request from 
bligh.ngdc.noaa.gov for 10.1.186.70

There are many of these. In the current messages file which began Jan 9 4:02 
AM, there are 93 of these messages. The first one is:

Jan 13 16:30:01 bligh rpc.statd[1054]: Received erroneous SM_UNMON request from 
bligh.ngdc.noaa.gov for 10.1.186.70

Anybody have any ideas? Look at the time. Was anything done immediately before 
these messages began?

-Tom

PS - As of this email, there is one port 111 hit on bligh. This hit was 
triggered by me. It will be interesting to see if any other attempts are made. 
Please do not force rpc traffic to bligh. It will complicate the logging. Lets 
let the logging run a while and see what kind of traffic is naturally 
generated.

Ara.T.Howard wrote:

> 
> 
> from the nfs list
> 
> ---------- Forwarded message ----------
> Date: Mon, 28 Jul 2003 10:56:08 +1000
> From: Neil Brown <neilb@cse.unsw.edu.au>
> To: Chip Salzenberg <chip@pobox.com>
> Cc: nfs@lists.sourceforge.net
> Subject: Re: [NFS] Debian Bug#203077: Locks not released on NFS client 
> reboot
> 
> <SNIP>
> 
> Looking at the tcp_wrapper stuff used by statd, it looks rather bogus(*),
> though I think it is more likely to give away access that it shouldn't
> rather than restrict access that it should grant.
> 
> Anyway, I suggest that the person having the problem tries:
> 
> rpcinfo -u SERVERNAME status
> from the client, and
> 
> rpcinfo -u CLIENTNAME status
> from the server
> and checks that both works. If either doesn't I suspect that is the
> problem. If they both work.... I don't know.
> 
> </SNIP>
> 
> 
> so i did this and
> 
> bligh:~ > ssh mussel rpcinfo -u bligh status
> program 100024 is not available
> rpcinfo: RPC: Port mapper failure - RPC: Unable to receive
> 
> 
> mussel:~ > rpcinfo -u bligh status
> program 100024 is not available
> rpcinfo: RPC: Port mapper failure - RPC: Unable to receive
> 
> seems this is the problem. what exactly does it mean tough? i remember we 
> had
> issues with stat.d and init scripts...
> 
> -a



-------------------------------------------------------
The SF.Net email is sponsored by: Beat the post-holiday blues
Get a FREE limited edition SourceForge.net t-shirt from ThinkGeek.
It's fun and FREE -- well, almost....http://www.thinkgeek.com/sfshirt
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs

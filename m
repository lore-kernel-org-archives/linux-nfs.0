From: Steve Dickson <SteveD@redhat.com>
Subject: Re: NFS server not responding
Date: Thu, 04 Dec 2003 12:17:05 -0500
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <3FCF6C11.5010503@RedHat.com>
References: <Pine.LNX.4.44.0311281257130.22389-100000@kenzo.iwr.uni-heidelberg.de>	<shsptfch1om.fsf@charged.uio.no>	<1070375865.20333.74.camel@wibbit.firebox.com> <shsn0ab5izh.fsf@guts.uio.no>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.12] helo=sc8-sf-mx2.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.24)
	id 1ARx5R-0002CN-PG
	for nfs@lists.sourceforge.net; Thu, 04 Dec 2003 09:16:21 -0800
Received: from mx1.redhat.com ([66.187.233.31])
	by sc8-sf-mx2.sourceforge.net with esmtp (Exim 4.24)
	id 1ARx5R-0002L0-9l
	for nfs@lists.sourceforge.net; Thu, 04 Dec 2003 09:16:21 -0800
Received: from int-mx1.corp.redhat.com (int-mx1.corp.redhat.com [172.16.52.254])
	by mx1.redhat.com (8.11.6/8.11.6) with ESMTP id hB4HGE213506
	for <nfs@lists.sourceforge.net>; Thu, 4 Dec 2003 12:16:14 -0500
Received: from lacrosse.corp.redhat.com (lacrosse.corp.redhat.com [172.16.52.154])
	by int-mx1.corp.redhat.com (8.11.6/8.11.6) with ESMTP id hB4HGE230931
	for <nfs@lists.sourceforge.net>; Thu, 4 Dec 2003 12:16:14 -0500
Received: from RedHat.com (dickson.boston.redhat.com [172.16.65.20])
	by lacrosse.corp.redhat.com (8.11.6/8.11.6) with ESMTP id hB4HGE310465
	for <nfs@lists.sourceforge.net>; Thu, 4 Dec 2003 12:16:14 -0500
To: nfs@lists.sourceforge.net
In-Reply-To: <shsn0ab5izh.fsf@guts.uio.no>
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

Trond Myklebust wrote:

>Nobody on this list is directly responsible for the Fedore Core 1
>kernel, ......
>  
>
This not completely accurate.... I am responsible for FC1...
And it is my goal to keep FC1 (and beyond) as stable as possible...

>I have no problems on *any* of the machines in the test-rigs I have at
>my disposition when using a standard 2.4.23 kernel.  For the record,
>those few that I have used with the Fedora kernel have been fine too
>(though I haven't made any detailed tests of that)
>  
>
I not seen this either... FC1 does have the latest retrans improvements
    # 03/10/11  trond.myklebust@fys.uio.no  1.1148.17.3
    # UDP round trip timer fix. ...

    # 03/10/11  trond.myklebust@fys.uio.no  1.1148.17.2
    # A request cannot be used as part of the RTO estimation ...

    # 03/07/08  trond.myklebust@fys.uio.no  1.1003.1.58
    # Back out some congestion control changes that were causing trouble...

With the only difference being FC1 has a longer RTO_MIN
-#define RPC_RTO_MIN (HZ/30)
+#define RPC_RTO_MIN (HZ/10)

And these patches did show a noticeable improvement in bring down the
number of retrans at least in my testing (w/out being overly verbose)

>So now, what have you tried in order to diagnose this problem?
>  
>
ifconfig will show if the driver is dropping frames. netstat -s will show
if there are udp fragmentation issues and ethereal is good at showing
whether the ip stack or network are dropping the packets....

SteveD.




-------------------------------------------------------
This SF.net email is sponsored by: SF.net Giveback Program.
Does SourceForge.net help you be more productive?  Does it
help you create better code?  SHARE THE LOVE, and help us help
YOU!  Click Here: http://sourceforge.net/donate/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs

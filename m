From: Steve Dickson <SteveD@redhat.com>
Subject: Re: NFS server not responding
Date: Thu, 04 Dec 2003 14:11:37 -0500
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <3FCF86E9.2030300@RedHat.com>
References: <Pine.LNX.4.44.0311281257130.22389-100000@kenzo.iwr.uni-heidelberg.de>	<shsptfch1om.fsf@charged.uio.no> <3FCF70D9.1010808@RedHat.com> <shsr7zk5sw4.fsf@guts.uio.no>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------070407040104060909060006"
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.24)
	id 1ARysC-0004j7-JU
	for nfs@lists.sourceforge.net; Thu, 04 Dec 2003 11:10:48 -0800
Received: from mx1.redhat.com ([66.187.233.31])
	by sc8-sf-mx1.sourceforge.net with esmtp (Exim 4.24)
	id 1ARysC-0004em-3u
	for nfs@lists.sourceforge.net; Thu, 04 Dec 2003 11:10:48 -0800
Received: from int-mx1.corp.redhat.com (int-mx1.corp.redhat.com [172.16.52.254])
	by mx1.redhat.com (8.11.6/8.11.6) with ESMTP id hB4JAl218650
	for <nfs@lists.sourceforge.net>; Thu, 4 Dec 2003 14:10:47 -0500
Received: from lacrosse.corp.redhat.com (lacrosse.corp.redhat.com [172.16.52.154])
	by int-mx1.corp.redhat.com (8.11.6/8.11.6) with ESMTP id hB4JAk206144
	for <nfs@lists.sourceforge.net>; Thu, 4 Dec 2003 14:10:46 -0500
Received: from RedHat.com (dickson.boston.redhat.com [172.16.65.20])
	by lacrosse.corp.redhat.com (8.11.6/8.11.6) with ESMTP id hB4JAk325567
	for <nfs@lists.sourceforge.net>; Thu, 4 Dec 2003 14:10:46 -0500
To: nfs@lists.sourceforge.net
In-Reply-To: <shsr7zk5sw4.fsf@guts.uio.no>
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

This is a multi-part message in MIME format.
--------------070407040104060909060006
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit

Trond Myklebust wrote:

>>>>>>" " == Steve Dickson <SteveD@redhat.com> writes:
>>>>>>            
>>>>>>
>
>     >     linux-2.4.20-nfs-ia64-EIO.patch - increase RPC_RTO_MIN to
>     >     HZ/30
>
>Err.. That's a decrease...
>  
>
Well... it was in increase at the time I posted the patch.
If remember correctly... there was actually some discussion
that 1/30th of a second was a bit too long...

>You are setting the minimum timeout value at 1/30th of a second
>instead of 1/10th of a second.
>  
>
Right... I did miss this "minor" detail when I did the port....

>This might indeed explain why people are seeing an increase in resends
>and 'server not responding' messages.
>  
>
Most definitely... Here is the patch that should take care of the problem...

SteveD.


--------------070407040104060909060006
Content-Type: text/plain;
 name="linux-2.4.33-nfs-rtomin.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="linux-2.4.33-nfs-rtomin.patch"

--- linux-2.4.22/net/sunrpc/timer.c.org	2003-12-04 10:47:01.000000000 -0500
+++ linux-2.4.22/net/sunrpc/timer.c	2003-12-04 13:46:01.000000000 -0500
@@ -8,7 +8,7 @@
 
 #define RPC_RTO_MAX (60*HZ)
 #define RPC_RTO_INIT (HZ/5)
-#define RPC_RTO_MIN (HZ/30)
+#define RPC_RTO_MIN (HZ/10)
 
 void
 rpc_init_rtt(struct rpc_rtt *rt, long timeo)

--------------070407040104060909060006--



-------------------------------------------------------
This SF.net email is sponsored by: SF.net Giveback Program.
Does SourceForge.net help you be more productive?  Does it
help you create better code?  SHARE THE LOVE, and help us help
YOU!  Click Here: http://sourceforge.net/donate/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs

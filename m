From: Jeff Layton <jlayton@poochiereds.net>
Subject: Re: NFS:RPC timed out
Date: Mon, 3 Sep 2007 09:48:54 -0400
Message-ID: <20070903094854.69063958.jlayton@poochiereds.net>
References: <OFF770B138.A6668C02-ON48257348.0021C294-48257348.00224EEA@alps.com.hk>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net
To: xiao.liang@cn.alps.com
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1ISCIZ-0000HC-VG
	for nfs@lists.sourceforge.net; Mon, 03 Sep 2007 06:49:04 -0700
Received: from cdptpa-omtalb.mail.rr.com ([75.180.132.120])
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1ISCIc-0001UB-Eo
	for nfs@lists.sourceforge.net; Mon, 03 Sep 2007 06:49:08 -0700
In-Reply-To: <OFF770B138.A6668C02-ON48257348.0021C294-48257348.00224EEA@alps.com.hk>
List-Id: "Discussion of NFS under Linux development, interoperability,
	and testing." <nfs.lists.sourceforge.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=nfs>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
Sender: nfs-bounces@lists.sourceforge.net
Errors-To: nfs-bounces@lists.sourceforge.net

On Fri, 31 Aug 2007 14:14:56 +0800
xiao.liang@cn.alps.com wrote:

> Hi,
>  
> 
> 
> I use kernel 2.4.20,busybox 1.3.1,the NFS server is V4.When I try to mount 
> use 
> 
> mount -t nfs 10.25.16.130:/opt/Qtopia /opt/Qtopia 
> 

If this server is nfsv4 only, then this is not going to work. Under linux
to mount with nfsv4 you need to specify '-t nfs4'. But that won't help you
either since this is a 2.4 kernel and 2.4 doesn't have support for nfsv4.

> Got error ,mount: RPC time out 
> 
> When I use ethreal on both the server and client side , found that the 
> server have sent SYN,ACK back to client with the TCP connection, but the 
> client just do not respond. I use portmap and also inetd. The tcpdump log 
> is look like this: 
> 
> 10.25.16.160.794 > 10.25.16.130.sunrpc: S, cksum 0x5740 (correct), 
> 31406388 
> 
> 10.25.16.130.sunrpc > 10.25.16.160.794: S, cksum 0x79e6 (correct), 
> 2533961748:2 
> 10.25.16.130.sunrpc > 10.25.16.160.794: S, cksum 0x79e6 (correct), 
> 2533961748:2 
> 60) 10.25.16.160.794 > 10.25.16.130.sunrpc: S, cksum 0x5614 (correct), 
> 31406388 
> 10.25.16.130.sunrpc > 10.25.16.160.794: S, cksum 0x76ff (correct), 
> 2533961748:2 
> 10.25.16.130.sunrpc > 10.25.16.160.794: S, cksum 0x76ff (correct), 
> 2533961748:2 
> 10.25.16.130.sunrpc > 10.25.16.160.794: S, cksum 0x76f8 (correct), 
> 2533961748:2 
> 10.25.16.130.sunrpc > 10.25.16.160.794: S, cksum 0x76f8 (correct), 
> 2533961748:2 
> 
> 
> 60) 10.25.16.160.794 > 10.25.16.130.sunrpc: S, cksum 0x53bc (correct), 
> 31406388 
> 10.25.16.130.sunrpc > 10.25.16.160.794: S, cksum 0x7123 (correct), 
> 2533961748:2 
> 10.25.16.130.sunrpc > 10.25.16.160.794: S, cksum 0x7123 (correct), 
> 2533961748:2 
> 10.25.16.130.sunrpc > 10.25.16.160.794: S, cksum 0x711c (correct), 
> 2533961748:2 
> 10.25.16.130.sunrpc > 10.25.16.160.794: S, cksum 0x711c (correct), 
> 2533961748:2 
> 
> 
> 10.25.16.130.sunrpc > 10.25.16.160.794: S, cksum 0x6563 (correct), 
> 2533961748:2 
> 60) 10.25.16.160.794 > 10.25.16.130.sunrpc: S, cksum 0x4f0c (correct), 
> 31406388 
> 10.25.16.130.sunrpc > 10.25.16.160.794: S, cksum 0x6561 (correct), 
> 2533961748:2 
> 10.25.16.130.sunrpc > 10.25.16.160.794: S, cksum 0x6563 (correct), 
> 2533961748: 
> 
> 
> If it is the portmap and inetd's problem? 
> 
> 
> 
> 
> etc/service 
> sunrpc 111/tcp portmap 
> sunrpc 111/udp portmap 
> 
> /etc/inetd.conf 
> #rstatd/1-3 dgram rpc/udp wait root /usr/sbin/tcpd rpc.rstatd 
> #rusersd/2-3 dgram rpc/udp wait root /usr/sbin/tcpd rpc.rusersd 
> 
> Client use a random tcp port number to connect with server:111, then who 
> will look after the SYN,ACK packet sent back by server, the inetd? Should 
> I add a line in inetd.conf like "794    stream  tcp   nowait root portmap" 
> , but it is a ramdom port number?! Or should there be a tcpd or sth run on 
> my board????
> 
> Ask for help!!!!!
> 
> ps 
> 
> /usr/sbin/inetd 
> /sbin/portmap 
> 
> 


-- 
Jeff Layton <jlayton@poochiereds.net>

-------------------------------------------------------------------------
This SF.net email is sponsored by: Splunk Inc.
Still grepping through log files to find problems?  Stop.
Now Search log events and configuration files using AJAX and a browser.
Download your FREE copy of Splunk now >>  http://get.splunk.com/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs

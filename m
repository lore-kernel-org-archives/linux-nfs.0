From: "Talpey, Thomas" <Thomas.Talpey@netapp.com>
Subject: Re: Need more threads?
Date: Thu, 01 Nov 2007 10:55:09 -0400
Message-ID: <EXNANE01YewQ1N8Pik30000086b@exnane01.hq.netapp.com>
References: <200711011800.08010.huangxiong@uit.com.cn>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net
To: Huang Xiong <huangxiong@uit.com.cn>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1InbSW-0000xR-VV
	for nfs@lists.sourceforge.net; Thu, 01 Nov 2007 07:55:49 -0700
Received: from mx2.netapp.com ([216.240.18.37])
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1InbSa-0005l4-FL
	for nfs@lists.sourceforge.net; Thu, 01 Nov 2007 07:55:54 -0700
In-Reply-To: <200711011800.08010.huangxiong@uit.com.cn>
References: <200711011800.08010.huangxiong@uit.com.cn>
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

To clarify - you're intentionally running with only one nfsd thread,
but you want to know if you need more? The answer is you almost
always need multiple nfsd threads, but if you describe your "special
situation" maybe we can offer more advice.

The "th" line gives you statistics on the relative use of multiple nfsd
threads. It's a histogram of the number of running nfsd's versus the
available pool. However, since your pool is only one thread (the first
number on the line), the histogram itself isn't very useful. What
information are you looking for?

Tom.

At 06:00 AM 11/1/2007, Huang Xiong wrote:
>Hello all,
>
>I have to only open one nfsd thread in this special situation.
>
>I do not understand the "th" line very clearly, and I find various comments in 
>the net . Please help me see the below two NFS server, do them need more 
>threads? and would you evaluate it for me?
>
>Thanks in advance.
>Phillip  
>
>--------------------------------------------------------
>[root@node1 ~]# cat /proc/net/rpc/nfsd
>rc 0 0 317
>fh 0 0 0 0 0
>io 0 0
>th 1 17 130.092 54.005 52.006 0.000 5.599 78.743 89.426 197.553 0.000 11.259
>ra 2 0 0 0 0 0 0 0 0 0 0 0
>net 317 83 230 81
>rpc 317 0 0 0 0
>proc2 18 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0
>proc3 22 5 113 0 1 1 0 0 0 0 0 0 0 0 0 0 0 0 0 87 110 0 0
>proc4 2 0 0
>
>
>[root@node2 ~]# cat /proc/net/rpc/nfsd
>rc 0 0 550
>fh 0 0 0 0 0
>io 0 0
>th 1 137 80.840 5.479 0.000 0.000 0.000 0.000 0.000 0.000 0.000 50.640
>ra 2 0 0 0 0 0 0 0 0 0 0 0
>net 550 216 330 113
>rpc 550 0 0 0 0
>proc2 18 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0
>proc3 22 3 181 0 1 1 0 0 0 0 0 0 0 0 0 0 0 0 0 186 178 0 0
>
>
>
>-------------------------------------------------------------------------
>This SF.net email is sponsored by: Splunk Inc.
>Still grepping through log files to find problems?  Stop.
>Now Search log events and configuration files using AJAX and a browser.
>Download your FREE copy of Splunk now >> http://get.splunk.com/
>_______________________________________________
>NFS maillist  -  NFS@lists.sourceforge.net
>https://lists.sourceforge.net/lists/listinfo/nfs

-------------------------------------------------------------------------
This SF.net email is sponsored by: Splunk Inc.
Still grepping through log files to find problems?  Stop.
Now Search log events and configuration files using AJAX and a browser.
Download your FREE copy of Splunk now >> http://get.splunk.com/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs

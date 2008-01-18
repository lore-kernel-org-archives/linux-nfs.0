From: Chuck Lever <chuck.lever@oracle.com>
Subject: Re: Understanding iostat-ms output
Date: Fri, 18 Jan 2008 11:34:25 -0500
Message-ID: <0D40CC74-A3E1-472C-ACC2-3827E51B469D@oracle.com>
References: <2a29d0a3c209d9488b0a3e8263c53e38@swip.net>
Mime-Version: 1.0 (Apple Message framework v753)
Content-Type: text/plain; charset=US-ASCII; delsp=yes; format=flowed
Cc: "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
To: "Fredrik Lindgren" <fli-FpffG6+3qsA@public.gmane.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from rgminet01.oracle.com ([148.87.113.118]:32158 "EHLO
	rgminet01.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1761237AbYARQgU (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 18 Jan 2008 11:36:20 -0500
In-Reply-To: <2a29d0a3c209d9488b0a3e8263c53e38-FpffG6+3qsA@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Jan 18, 2008, at 4:37 AM, Fredrik Lindgren wrote:
> I have been messing around with the excellent "iostat-ms" tool in
> an effort to understand what is going on with our machines that are
> showing lots of IOwait.
>
> Below are two 15 second samples, the first one is taken during peak
> and the second one during the night. The obvious difference is in the
> "exe" field. Please excuse my ignorance, but what does this field  
> mean?
> Where is this additional time spent? On the filer or in the NFS stack
> on the host?

RTT is the time from when the kernel RPC client sends the RPC request  
to the time it receives the reply; RTT includes network transit time  
and server execution time.

"exe" is the time from when the NFS client dispatches the RPC request  
to the kernel RPC client to the time the RPC request is complete;  
"exe" includes RTT, and RPC client queuing and processing time.

So, even though the server turns your requests around in under  
20msec, the RPC client is taking almost a quarter second, on average,  
to process an RPC request.

The RPC client, by default, can process up to 16 requests  
concurrently.  Once this limit is exceeded, the RPC client queues  
requests coming from the NFS client in a backlog queue.  Average  
execution time "exe" goes up if the requests have to wait in the  
backlog queue.

Since your retransmit rate is zero, I'll assume you are using TCP.   
Try increasing the default slot table size of the RPC client:

   sudo sysctl -w sunrpc.tcp_slot_table_entries=64

then remounting your NFS file systems.

> stbnas1:/foo mounted on /misc/foo:
>
>    op/s         rpc bklog
> 2364.60            0.96
> read:             ops/s            Kb/s           Kb/op          
> retrans         avg RTT (ms)    avg exe (ms)
>                  43.267         659.624          15.246        0  
> (0.0%)          17.066         293.880
> write:            ops/s            Kb/s           Kb/op          
> retrans         avg RTT (ms)    avg exe (ms)
>                  16.133          60.314           3.738        0  
> (0.0%)           3.868         255.074
>
> stbnas1:/foo mounted on /misc/foo:
>
>    op/s         rpc bklog
> 1446.07            0.26
> read:             ops/s            Kb/s           Kb/op          
> retrans         avg RTT (ms)    avg exe (ms)
>                 105.200         189.155           1.798        0  
> (0.0%)           8.264           8.702
> write:            ops/s            Kb/s           Kb/op          
> retrans         avg RTT (ms)    avg exe (ms)
>                 105.067         297.774           2.834        0  
> (0.0%)           1.048           1.310
>
>
> Regards,
>   Fredrik Lindgren
>
>
>
>
> -
> To unsubscribe from this list: send the line "unsubscribe linux- 
> nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

--
Chuck Lever
chuck[dot]lever[at]oracle[dot]com




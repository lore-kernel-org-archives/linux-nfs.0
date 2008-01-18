From: Chuck Lever <Chuck.Lever@oracle.com>
Subject: Re: Understanding iostat-ms output
Date: Fri, 18 Jan 2008 12:37:35 -0500
Message-ID: <6FBCD100-A02A-4CA5-8329-A801846B14BC@oracle.com>
References: <2a29d0a3c209d9488b0a3e8263c53e38@swip.net> <1200675753.7781.32.camel@heimdal.trondhjem.org>
Mime-Version: 1.0 (Apple Message framework v753)
Content-Type: text/plain; charset=US-ASCII; delsp=yes; format=flowed
To: "linux-nfs@vger.kernel.org list" <linux-nfs@vger.kernel.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from agminet01.oracle.com ([141.146.126.228]:24128 "EHLO
	agminet01.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1764472AbYARRhk (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 18 Jan 2008 12:37:40 -0500
Received: from agmgw1.us.oracle.com (agmgw1.us.oracle.com [152.68.180.212])
	by agminet01.oracle.com (Switch-3.2.4/Switch-3.1.7) with ESMTP id m0IHbcCh031741
	for <linux-nfs@vger.kernel.org>; Fri, 18 Jan 2008 11:37:38 -0600
Received: from acsmt358.oracle.com (acsmt358.oracle.com [141.146.40.158])
	by agmgw1.us.oracle.com (Switch-3.2.0/Switch-3.2.0) with ESMTP id m0IHPppZ024558
	for <linux-nfs@vger.kernel.org>; Fri, 18 Jan 2008 10:37:37 -0700
In-Reply-To: <1200675753.7781.32.camel-rJ7iovZKK19ZJLDQqaL3InhyD016LWXt@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Jan 18, 2008, at 12:02 PM, Trond Myklebust wrote:
> On Fri, 2008-01-18 at 10:37 +0100, Fredrik Lindgren wrote:
>> Hello,
>>
>> I have been messing around with the excellent "iostat-ms" tool in
>> an effort to understand what is going on with our machines that are
>> showing lots of IOwait.
>>
>> Below are two 15 second samples, the first one is taken during peak
>> and the second one during the night. The obvious difference is in the
>> "exe" field. Please excuse my ignorance, but what does this field  
>> mean?
>> Where is this additional time spent? On the filer or in the NFS stack
>> on the host?
>>
>> stbnas1:/foo mounted on /misc/foo:
>>
>>    op/s         rpc bklog
>> 2364.60            0.96
>> read:             ops/s            Kb/s           Kb/op          
>> retrans         avg RTT (ms)    avg exe (ms)
>>                  43.267         659.624          15.246        0  
>> (0.0%)          17.066         293.880
>> write:            ops/s            Kb/s           Kb/op          
>> retrans         avg RTT (ms)    avg exe (ms)
>>                  16.133          60.314           3.738        0  
>> (0.0%)           3.868         255.074
>>
>> stbnas1:/foo mounted on /misc/foo:
>>
>>    op/s         rpc bklog
>> 1446.07            0.26
>> read:             ops/s            Kb/s           Kb/op          
>> retrans         avg RTT (ms)    avg exe (ms)
>>                 105.200         189.155           1.798        0  
>> (0.0%)           8.264           8.702
>> write:            ops/s            Kb/s           Kb/op          
>> retrans         avg RTT (ms)    avg exe (ms)
>>                 105.067         297.774           2.834        0  
>> (0.0%)           1.048           1.310
>
> AFAICS the RTT (i.e. round trip time) is being reported as being of  
> the
> order of milliseconds in both cases, so the filer would not appear  
> to be
> responsible. The discrepancy has to be on the client side.
>
> It would be interesting to see the 'rpc bklog' parameter in order to
> confirm if the requests are being held up in the backlog queue.
> Unfortunately, there appears to be a bug in iostat-ms: it appears  
> to be
> reading the 'number of requests in flight' where it should be reading
> the 'length of backlog queue' parameter.
> See if the attached patch doesn't help... (it also fixes a minor issue
> of storing unsigned long long counters in the wrong type)


I've applied Trond's patch, and patches from NetApp to support RDMA  
statistics to these two scripts, and posted fresh versions here:

   http://oss.oracle.com/~cel/linux-2.6/2.6.24/

--
Chuck Lever
chuck[dot]lever[at]oracle[dot]com




From: Greg Banks <gnb-cP1dWloDopni96+mSzHFpQC/G2K4zDHf@public.gmane.org>
Subject: Re: high latency NFS
Date: Mon, 04 Aug 2008 18:04:34 +1000
Message-ID: <4896B812.7000006@melbourne.sgi.com>
References: <200807241311.31457.shuey@purdue.edu> <20080730192110.GA17061@fieldses.org>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------090704070209060801010407"
Cc: Michael Shuey <shuey-olO2ZdjDehc3uPMLIKxrzw@public.gmane.org>, linux-kernel@vger.kernel.org,
	linux-nfs@vger.kernel.org, rees@citi.umich.edu, aglo@citi.umich.edu
To: "J. Bruce Fields" <bfields@fieldses.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from relay1.sgi.com ([192.48.171.29]:48690 "EHLO relay.sgi.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1752045AbYHDILr (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 4 Aug 2008 04:11:47 -0400
In-Reply-To: <20080730192110.GA17061@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

This is a multi-part message in MIME format.
--------------090704070209060801010407
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit

J. Bruce Fields wrote:
> You might get more responses from the linux-nfs list (cc'd).
>
> --b.
>
> On Thu, Jul 24, 2008 at 01:11:31PM -0400, Michael Shuey wrote:
>   
>>
>> iozone is reading/writing a file twice the size of memory on the client with 
>> a 32k block size.  I've tried raising this as high as 16 MB, but I still 
>> see around 6 MB/sec reads.
>>     
That won't make a skerrick of difference with wsize=32K.
>> I'm using a 2.6.9 derivative (yes, I'm a RHEL4 fan).  Testing with a stock 
>> 2.6, client and server, is the next order of business.
>>
>> NFS mount is tcp, version 3.  rsize/wsize are 32k.
Try wsize=rsize=1M.
>>   Both client and server 
>> have had tcp_rmem, tcp_wmem, wmem_max, rmem_max, wmem_default, and 
>> rmem_default tuned - tuning values are 12500000 for defaults (and minimum 
>> window sizes), 25000000 for the maximums.  Inefficient, yes, but I'm not 
>> concerned with memory efficiency at the moment.
>>     
You're aware that the server screws these up again, at least for
writes?  There was a long sequence of threads on linux-nfs about this
recently, starting with

http://marc.info/?l=linux-nfs&m=121312415114958&w=2

which is Dean Hildebrand posting a patch to make the knfsd behaviour
tunable.  ToT still looks broken.  I've been using the attached patch (I
believe a similar one was posted later in the thread by Olga
Kornievskaia)  for low-latency high-bandwidth 10ge performance work,
where it doesn't help but doesn't hurt either.  It should help for your
high-latency high-bandwidth case.  Keep your tunings though, one of 
them will be affecting the TCP window scale negotiated at connect time.
>> Both client and server kernels have been modified to provide 
>> larger-than-normal RPC slot tables.  I allow a max of 1024, but I've found 
>> that actually enabling more than 490 entries in /proc causes mount to 
>> complain it can't allocate memory and die.  That was somewhat suprising, 
>> given I had 122 GB of free memory at the time...
>>     
That number is used to size a physically contiguous kmalloc()ed array of
slots.  With a large wsize you don't need such large slot table sizes or
large numbers of nfsds to fill the pipe.

And yes, the default number of nfsds is utterly inadequate.
>> I've also applied a couple patches to allow the NFS readahead to be a 
>> tunable number of RPC slots. 
There's a patch in SLES to do that, which I'd very much like to see that
in kernel.org (Neil?).  The default NFS readahead multiplier value is
pessimal and guarantees worst-case alignment of READ rpcs during
streaming reads, so we tune it from 15 to 16.

-- 
Greg Banks, P.Engineer, SGI Australian Software Group.
The cake is *not* a lie.
I don't speak for SGI.


--------------090704070209060801010407
Content-Type: text/plain;
 name="knfsd-tcp-receive-buffer-scaling"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="knfsd-tcp-receive-buffer-scaling"

Index: linux-2.6.16/net/sunrpc/svcsock.c
===================================================================
--- linux-2.6.16.orig/net/sunrpc/svcsock.c	2008-06-16 15:39:01.774672997 +1000
+++ linux-2.6.16/net/sunrpc/svcsock.c	2008-06-16 15:45:06.203421620 +1000
@@ -1157,13 +1159,13 @@ svc_tcp_recvfrom(struct svc_rqst *rqstp)
 		 * particular pool, which provides an upper bound
 		 * on the number of threads which will access the socket.
 		 *
-		 * rcvbuf just needs to be able to hold a few requests.
-		 * Normally they will be removed from the queue 
-		 * as soon a a complete request arrives.
+		 * rcvbuf needs the same room as sndbuf, to allow
+		 * workloads comprising mostly WRITE calls to flow
+		 * at a reasonable fraction of line speed.
 		 */
 		svc_sock_setbufsize(svsk->sk_sock,
 				    (serv->sv_nrthreads+3) * serv->sv_bufsz,
-				    3 * serv->sv_bufsz);
+				    (serv->sv_nrthreads+3) * serv->sv_bufsz);
 
 	svc_sock_clear_data_ready(svsk);
 

--------------090704070209060801010407--

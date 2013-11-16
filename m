Return-Path: linux-nfs-owner@vger.kernel.org
Received: from qmta12.westchester.pa.mail.comcast.net ([76.96.59.227]:49518
	"EHLO qmta12.westchester.pa.mail.comcast.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753701Ab3KPAgx (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 15 Nov 2013 19:36:53 -0500
Message-ID: <5286BC6D.2000109@talpey.com>
Date: Fri, 15 Nov 2013 19:29:33 -0500
From: Tom Talpey <tom@talpey.com>
MIME-Version: 1.0
To: "Myklebust, Trond" <Trond.Myklebust@netapp.com>,
        Charles Edward Lever <chuck.lever@oracle.com>
CC: Klemens Senn <klemens.senn@ims.co.at>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Subject: Re: NFS over RDMA stops working for data larger than 812 Bytes
References: <24663A6D-A54A-441B-880E-BB7FD6BBB3F2@oracle.com> <4673A7C9-3424-48F4-B64C-976EFE16017C@netapp.com> <F3A43D4C-2A30-44AC-ABDA-E66F5F4AA719@oracle.com> <D70711CB-4951-4419-9FB3-EE438248EF47@netapp.com>
In-Reply-To: <D70711CB-4951-4419-9FB3-EE438248EF47@netapp.com>
Content-Type: text/plain; charset=windows-1252; format=flowed
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 11/15/2013 5:53 PM, Myklebust, Trond wrote:
>
> On Nov 15, 2013, at 17:31, Chuck Lever <chuck.lever@oracle.com> wrote:
>
>>
>> On Nov 15, 2013, at 5:29 PM, "Myklebust, Trond" <Trond.Myklebust@netapp.com> wrote:
>>
>>>
>>> On Nov 15, 2013, at 16:39, Chuck Lever <chuck.lever@oracle.com> wrote:
>>>
>>>> Hi Trond-
>>>>
>>>> Klemens Senn <klemens.senn@ims.co.at> says:
>>>>> Hi,
>>>>>
>>>>> I started setting up NFS over RDMA on a OpenSUSE 12.3 machine using the
>>>>> 3.7.10-1.16-default kernel.
>>>>> Mounting the NFS share works and getting a file with 812 Bytes succeeds.
>>>>> Reading 813 Bytes raises a Input/output error.
>>>>>
>>>>> The export on the server side is done with
>>>>> /data
>>>>> 172.16.100.0/24(rw,wdelay,crossmnt,insecure,no_root_squash,no_subtree_check,fsid=0,mountpoint)
>>>>>
>>>>> Following command is used for mounting the NFSv4 share:
>>>>> mount -t nfs -o port=20049,rdma,vers=4.0,timeo=900 172.16.100.2:/ /mnt/
>>>>>
>>>>> Testing the client side with older kernels stated that the mount is
>>>>> working properly with the 3.4.67 kernel. I continued testing with the
>>>>> 3.10.17 kernel and enabled the debug level and noticed the message
>>>>> "server cheating in read reply: count 813 > recvd 0"
>>>>>
>>>>> Here is the syslog output:
>>>>> NFS: read(//813_bytes, 262144@0)
>>>>> NFS: nfs_readpage (ffffea001db1e898 4096@0)
>>>>> NFS:     0 initiated read call (req 0:33/70, 813 bytes @ offset 0)
>>>>> RPC:       new task initialized, procpid 9881
>>>>> RPC:       allocated task ffff88105dacabf8
>>>>> RPC:  1631 __rpc_execute flags=0x1
>>>>> <-- nfs4_setup_sequence status=0
>>>>> RPC:  1631 call_start nfs4 proc READ (async)
>>>>> RPC:  1631 call_reserve (status 0)
>>>>> RPC:  1631 reserved req ffff88085e641c00 xid 3f6a89a6
>>>>> RPC:  1631 call_reserveresult (status 0)
>>>>> RPC:  1631 call_refresh (status 0)
>>>>> RPC:  1631 refreshing UNIX cred ffff88087c2108c0
>>>>> RPC:  1631 call_refreshresult (status 0)
>>>>> RPC:  1631 call_allocate (status 0)
>>>>> RPC:       xprt_rdma_allocate: size 684, request 0xffff88084a342000
>>>>> RPC:  1631 call_bind (status 0)
>>>>> RPC:  1631 call_connect xprt ffff88085f297000 is connected
>>>>> RPC:  1631 call_transmit (status 0)
>>>>> RPC:  1631 xprt_prepare_transmit
>>>>> RPC:  1631 xprt_cwnd_limited cong = 0 cwnd = 4096
>>>>> RPC:  1631 rpc_xdr_encode (status 0)
>>>>> RPC:  1631 marshaling UNIX cred ffff88087c2108c0
>>>>> RPC:  1631 using AUTH_UNIX cred ffff88087c2108c0 to wrap rpc data
>>>>> RPC:  1631 xprt_transmit(144)
>>>>> RPC:       rpcrdma_inline_pullup: pad 0 destp 0xffff88084a3437f0 len 144
>>>>> hdrlen 144
>>>>> RPC:       rpcrdma_register_frmr_external: Using frmr ffff88084b612d10
>>>>> to map 1 segments
>>>>> RPC:       rpcrdma_create_chunks: write chunk elem
>>>>> 813@0x87bf95000:0x8a905 (more)
>>>>> RPC:       rpcrdma_register_frmr_external: Using frmr ffff88084b612d38
>>>>> to map 1 segments
>>>>> RPC:       rpcrdma_create_chunks: write chunk elem
>>>>> 152@0x84a343974:0x8aa01 (last)
>>>>> RPC:       rpcrdma_marshal_req: write chunk: hdrlen 68 rpclen 144 padlen
>>>>> 0 headerp 0xffff88084a343100 base 0xffff88084a343760 lkey 0x8000
>>>>> RPC:       rpcrdma_event_process: event rep ffff88084b612d10 status 0
>>>>> opcode 8 length 4294936584
>>>>> RPC:       rpcrdma_event_process: event rep ffff88084b612d38 status 0
>>>>> opcode 8 length 4294936584
>>>>> RPC:  1631 xmit complete
>>>>> RPC:  1631 sleep_on(queue "xprt_pending" time 4296115067)
>>>>> RPC:  1631 added to queue ffff88085f297258 "xprt_pending"
>>>>> RPC:  1631 setting alarm for 90000 ms
>>>>> RPC:       wake_up_first(ffff88085f297190 "xprt_sending")
>>>>> RPC:       rpcrdma_event_process: event rep ffff88085e8bf000 status 0
>>>>> opcode 80 length 128
>>>>> RPC:       rpcrdma_reply_handler: reply 0xffff88085e8bf000 completes
>>>>> request 0xffff88084a342000
>>>>>                 RPC request 0xffff88085e641c00 xid 0xa6896a3f
>>>>> RPC:       rpcrdma_count_chunks: chunk 813@0x87bf95000:0x8a905
>>>>> RPC:       rpcrdma_count_chunks: chunk 3@0x84a343974:0x8aa01
>>>>> RPC:       rpcrdma_inline_fixup: srcp 0xffff88085e8bf0a4 len 60 hdrlen 60
>>>>> RPC:       rpcrdma_reply_handler: xprt_complete_rqst(0xffff88085f297000,
>>>>> 0xffff88085e641c00, 876)
>>>>> RPC:  1631 xid 3f6a89a6 complete (876 bytes received)
>>>>> RPC:  1631 __rpc_wake_up_task (now 4296115067)
>>>>> RPC:  1631 disabling timer
>>>>> RPC:  1631 removed from queue ffff88085f297258 "xprt_pending"
>>>>> RPC:       __rpc_wake_up_task done
>>>>> RPC:  1631 __rpc_execute flags=0x801
>>>>> RPC:  1631 call_status (status 876)
>>>>> RPC:  1631 call_decode (status 876)
>>>>> RPC:  1631 validating UNIX cred ffff88087c2108c0
>>>>> RPC:  1631 using AUTH_UNIX cred ffff88087c2108c0 to unwrap rpc data
>>>>> NFS: server cheating in read reply: count 813 > recvd 0
>>>>> RPC:  1631 call_decode result 0
>>>>> NFS: nfs_readpage_result:  1631, (status 0)
>>>>> --> nfs4_read_done
>>>>>
>>>>> Adding other debug prints to the kernel module told me that
>>>>> buf->page_len is set to 0 in xdr_align_pages (in file net/sunrpc/xdr.c).
>>>>> Comparing this piece of code with older kernel versions showed that the
>>>>> comparison with buf->page_len was introduces in kernel 3.7.
>>>>> By disabling this check the file transfer seems to work.
>>>>>
>>>>> Here is the patch for kernel 3.10.17:
>>>>>
>>>>> --- net/sunrpc/xdr.c	2013-10-18 19:44:19.000000000 +0200
>>>>> +++ net/sunrpc/xdr_new.c	2013-11-08 14:06:00.241217773 +0100
>>>>> @@ -747,7 +747,7 @@
>>>>> 		nwords = xdr->nwords;
>>>>> 		len = nwords << 2;
>>>>> 	}
>>>>> -	if (buf->page_len <= len)
>>>>> +	if (buf->page_len && buf->page_len <= len)
>>>>> 		len = buf->page_len;
>>>>> 	else if (nwords < xdr->nwords) {
>>>>> 		/* Truncate page data and move it into the tail */
>>>>>
>>>>>
>>>>> Can you please tell me which entity sets (or does not set) the total
>>>>> length (buf->page_len) after receiving the data from the RDMA_SEND
>>>>> operation from the server?
>>>>>
>>>>> Please advise
>>>>>
>>>>> Klemens
>>>>
>>>> Comparing xdr_align_pages() before commit a11a2bf4 and afterwords, it appears that it no longer handles cases where buf->page_len == 0 the same way it used to.  xdr_align_pages() would never return zero unless xdr->nwords was zero.
>>>
>>> Why would the buf->page_len == 0 in a READ call? Has RDMA been relying on some kind of undocumented behaviour?
>>
>> See rpcrdma_inline_fixup().
>
> I see it, but I don’t get it. What is it trying to do?
>
> Firstly, why is it playing with rqst->rq_rcv_buf instead of using rq_private_buf? Secondly, why is it mucking with the page buffer length?
>

Speaking from memory, that routine was there originally to deliver
the RDMA data into the iov list expected by the upper layer via
RPC. When receiving via TCP, there were data copies that put it
into the receive buffers, and the code tried to avoid a similar
data copy - which would negate a big benefit of RDMA.

That code was first written for the 2.4 kernel, and it appears to
be working correctly today, except for the assertion stopping it.
Has rq_private_buf been there since then?

Tom.

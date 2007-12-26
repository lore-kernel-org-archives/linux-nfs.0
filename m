From: Gianluca Alberici <gianluca-I6s3FmifXcAEdjjp4vwUeA@public.gmane.org>
Subject: Re: NFS EINVAL on open(... | O_TRUNC) on 2.6.23.9
Date: Wed, 26 Dec 2007 12:14:42 +0100
Message-ID: <477237A2.3040907@abinetworks.biz>
References: <476CEC5E.9070002@abinetworks.biz>	<838DE9A2-59B2-49FA-B3E8-89B26368B1CF@bluecamel.eml.cc>	<476E47F5.4090807@abinetworks.biz> <20071225140431.9264970a.akpm@linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII; format=flowed
Cc: Scott <linux-kernel-ZTkj/XXJm+4Yk/GtTgyLaw@public.gmane.org>,
	linux-kernel@vger.kernel.org, linux-nfs@vger.kernel.org
To: Andrew Morton <akpm@linux-foundation.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from ns4.abinetworks.biz ([216.218.212.66]:37953 "EHLO
	ns4.abinetworks.biz" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755185AbXLZLWB (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 26 Dec 2007 06:22:01 -0500
In-Reply-To: <20071225140431.9264970a.akpm@linux-foundation.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hello all,

I've seen that Trond and the other guys at Netapp are working hard on 
the NFS support and there are dozens of patches in latest
2.6.24rcX s kernels regarding both RPC and NFS.
I can only hope, as Andrew Morton said, that the policy of new NFS impl 
was 'dont break'.
In the end those buggy, dreaded, old fashioned NFSs have done their job 
excellently for over 15 years and will be around for
another 5 IMHO.

Anyways, id really would be so thankful if somebody from the NFS team 
was givin us a clue about the whole thing.

TIA

Gianluca

Andrew Morton wrote:

>On Sun, 23 Dec 2007 12:35:17 +0100 Gianluca Alberici <gianluca-I6s3FmifXcAEdjjp4vwUeA@public.gmane.org> wrote:
>
>  
>
>>Hello,
>>
>>I can do better. I have investigated a bit the problem:
>>
>>1) The problem arises only with the userspace nfsd (Universal nfsd 2.2). 
>>I have realized that the latest patches introduced in 2.6.22 have 
>>changed a lot of things into NFS.
>>
>>2) The following code has been debugged with sunrpc.rpc_debug and 
>>sunrpc.nfs_debug
>>
>>#include <sys/types.h>
>>#include <sys/stat.h>
>>#include <fcntl.h>
>>#include <errno.h>
>>#include <stdio.h>
>>
>>int main(int argc, char *argv[]) {
>>        int fp;
>>        if ((fp=open("/mnt/tmp/test",O_WRONLY | O_CREAT | O_TRUNC, S_IRWXU )) == -1) printf("ERR: %d\n",errno);
>>        else {
>>                write(fp, argv[1], strlen(argv[1]));
>>                printf("OK\n");
>>                close(fp);
>>        };
>>}
>>
>>
>>2b) The output
>>
>>[...]
>>
>><8>NFS call  setattr
>><8>RPC:       new task initialized, procpid 18656
>><8>RPC:       allocated task f7bec500
>><8>RPC:     0 looking up UNIX cred
>><8>RPC:   740 __rpc_execute flags=0x480
>><8>RPC:   740 call_start nfs2 proc 2 (sync)
>><8>RPC:   740 call_reserve (status 0)
>><8>RPC:   740 reserved req f1416000 xid 643f3c42
>><8>RPC:   740 call_reserveresult (status 0)
>><8>RPC:   740 call_allocate (status 0)
>><8>RPC:   740 allocated buffer of size 528 at e627b800
>><8>RPC:   740 call_bind (status 0)
>><8>RPC:   740 call_connect xprt f70d4000 is connected
>><8>RPC:   740 call_transmit (status 0)
>><8>RPC:   740 xprt_prepare_transmit
>><8>RPC:   740 xprt_cwnd_limited cong = 0 cwnd = 512
>><8>RPC:   740 call_encode (status 0)
>><8>RPC:   740 marshaling UNIX cred f4efcb40
>><8>RPC:   740 using AUTH_UNIX cred f4efcb40 to wrap rpc data
>><8>RPC:   740 xprt_transmit(148)
>><8>RPC:       xs_udp_data_ready...
>><8>RPC:       cong 256, cwnd was 512, now 512
>><8>RPC:   740 xid 643f3c42 complete (28 bytes received)
>><8>RPC:       xs_udp_send_request(148) = 148
>><8>RPC:   740 xmit complete
>><8>RPC:       wake_up_next(f70d4114 "xprt_resend")
>><8>RPC:       wake_up_next(f70d40e4 "xprt_sending")
>><8>RPC:   740 call_status (status 28)
>><8>RPC:   740 call_decode (status 28)
>><8>RPC:   740 validating UNIX cred f4efcb40
>><8>RPC:   740 using AUTH_UNIX cred f4efcb40 to unwrap rpc data
>><8>RPC:   740 call_decode result -22
>><8>RPC:   740 return 0, status -22
>><8>RPC:   740 release task
>><8>RPC:       freeing buffer of size 528 at e627b800
>><8>RPC:   740 release request f1416000
>><8>RPC:       wake_up_next(f70d4174 "xprt_backlog")
>><8>RPC:   740 releasing UNIX cred f4efcb40
>><8>RPC:       rpc_release_client(f6f1f880)
>><8>NFS reply setattr: -22
>>
>>[...]
>>
>>3) It turns out the following:
>>
>>- setattr returns EINVAL due to...
>>- RPC call_decode returns status 22
>>
>>4) In conclusion in my understanding:
>>
>>- At present linux nfs filesystem support is not anymore compatible with 
>>old userspace servers like universal nfsd and crypto filesystems as cfsd 
>>(which is an nfs server pretty old fashioned).
>>- This problem makes UNFSD and CFSD unusable on 2.6.22 and up (this 
>>doesnt sound good to me)
>>
>>The question are:
>>
>>- Is this wanted or is a bug ?
>>- Can this be solved with some backwards compat stuff into the kernel or 
>>all the old packages as UNFSD have to be
>>bugfixed/upgraded
>>- I have found other strange behaviors of the new NFS filesystem support 
>>that i am investigating. All are bound to the user of
>>old userspace servers onto the new NFS (since 2.6.22). What to do ?
>>
>>    
>>
>
>I'm not sure what the NFS client's policy is regarding support for
>userspace servers.  But I'd certainly hope that it is "don't break them".
>
>Which would make this an NFS client regression.
>--
>To unsubscribe from this list: send the line "unsubscribe linux-kernel" in
>the body of a message to majordomo@vger.kernel.org
>More majordomo info at  http://vger.kernel.org/majordomo-info.html
>Please read the FAQ at  http://www.tux.org/lkml/
>  
>


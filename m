From: Chuck Lever <chuck.lever@oracle.com>
Subject: Re: NFS EINVAL on open(... | O_TRUNC) on 2.6.23.9
Date: Wed, 26 Dec 2007 09:24:22 -0500
Message-ID: <199BEBA7-E46E-4B1F-9D36-91BB43331B75@oracle.com>
References: <476CEC5E.9070002@abinetworks.biz> <838DE9A2-59B2-49FA-B3E8-89B26368B1CF@bluecamel.eml.cc> <476E47F5.4090807@abinetworks.biz> <20071225140431.9264970a.akpm@linux-foundation.org>
Mime-Version: 1.0 (Apple Message framework v753)
Content-Type: text/plain; charset=US-ASCII; delsp=yes; format=flowed
Cc: Scott <linux-kernel-ZTkj/XXJm+4Yk/GtTgyLaw@public.gmane.org>,
	linux-kernel@vger.kernel.org, linux-nfs@vger.kernel.org
To: Andrew Morton <akpm@linux-foundation.org>,
	Gianluca Alberici <gianluca-I6s3FmifXcAEdjjp4vwUeA@public.gmane.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from rgminet01.oracle.com ([148.87.113.118]:35630 "EHLO
	rgminet01.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751079AbXLZOZd (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 26 Dec 2007 09:25:33 -0500
In-Reply-To: <20071225140431.9264970a.akpm@linux-foundation.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Dec 25, 2007, at 5:04 PM, Andrew Morton wrote:
> On Sun, 23 Dec 2007 12:35:17 +0100 Gianluca Alberici  
> <gianluca-I6s3FmifXcAEdjjp4vwUeA@public.gmane.org> wrote:
>
>> Hello,
>>
>> I can do better. I have investigated a bit the problem:
>>
>> 1) The problem arises only with the userspace nfsd (Universal nfsd  
>> 2.2).
>> I have realized that the latest patches introduced in 2.6.22 have
>> changed a lot of things into NFS.
>>
>> 2) The following code has been debugged with sunrpc.rpc_debug and
>> sunrpc.nfs_debug
>>
>> #include <sys/types.h>
>> #include <sys/stat.h>
>> #include <fcntl.h>
>> #include <errno.h>
>> #include <stdio.h>
>>
>> int main(int argc, char *argv[]) {
>>         int fp;
>>         if ((fp=open("/mnt/tmp/test",O_WRONLY | O_CREAT | O_TRUNC,  
>> S_IRWXU )) == -1) printf("ERR: %d\n",errno);
>>         else {
>>                 write(fp, argv[1], strlen(argv[1]));
>>                 printf("OK\n");
>>                 close(fp);
>>         };
>> }
>>
>>
>> 2b) The output
>>
>> [...]
>>
>> <8>NFS call  setattr
>> <8>RPC:       new task initialized, procpid 18656
>> <8>RPC:       allocated task f7bec500
>> <8>RPC:     0 looking up UNIX cred
>> <8>RPC:   740 __rpc_execute flags=0x480
>> <8>RPC:   740 call_start nfs2 proc 2 (sync)
>> <8>RPC:   740 call_reserve (status 0)
>> <8>RPC:   740 reserved req f1416000 xid 643f3c42
>> <8>RPC:   740 call_reserveresult (status 0)
>> <8>RPC:   740 call_allocate (status 0)
>> <8>RPC:   740 allocated buffer of size 528 at e627b800
>> <8>RPC:   740 call_bind (status 0)
>> <8>RPC:   740 call_connect xprt f70d4000 is connected
>> <8>RPC:   740 call_transmit (status 0)
>> <8>RPC:   740 xprt_prepare_transmit
>> <8>RPC:   740 xprt_cwnd_limited cong = 0 cwnd = 512
>> <8>RPC:   740 call_encode (status 0)
>> <8>RPC:   740 marshaling UNIX cred f4efcb40
>> <8>RPC:   740 using AUTH_UNIX cred f4efcb40 to wrap rpc data
>> <8>RPC:   740 xprt_transmit(148)
>> <8>RPC:       xs_udp_data_ready...
>> <8>RPC:       cong 256, cwnd was 512, now 512
>> <8>RPC:   740 xid 643f3c42 complete (28 bytes received)
>> <8>RPC:       xs_udp_send_request(148) = 148
>> <8>RPC:   740 xmit complete
>> <8>RPC:       wake_up_next(f70d4114 "xprt_resend")
>> <8>RPC:       wake_up_next(f70d40e4 "xprt_sending")
>> <8>RPC:   740 call_status (status 28)
>> <8>RPC:   740 call_decode (status 28)
>> <8>RPC:   740 validating UNIX cred f4efcb40
>> <8>RPC:   740 using AUTH_UNIX cred f4efcb40 to unwrap rpc data
>> <8>RPC:   740 call_decode result -22
>> <8>RPC:   740 return 0, status -22
>> <8>RPC:   740 release task
>> <8>RPC:       freeing buffer of size 528 at e627b800
>> <8>RPC:   740 release request f1416000
>> <8>RPC:       wake_up_next(f70d4174 "xprt_backlog")
>> <8>RPC:   740 releasing UNIX cred f4efcb40
>> <8>RPC:       rpc_release_client(f6f1f880)
>> <8>NFS reply setattr: -22
>>
>> [...]
>>
>> 3) It turns out the following:
>>
>> - setattr returns EINVAL due to...
>> - RPC call_decode returns status 22
>>
>> 4) In conclusion in my understanding:
>>
>> - At present linux nfs filesystem support is not anymore  
>> compatible with
>> old userspace servers like universal nfsd and crypto filesystems  
>> as cfsd
>> (which is an nfs server pretty old fashioned).

Linux NFS client issues with servers that are old or not widely used  
should be reported to linux-nfs@vger.kernel.org (thanks for  
forwarding this, Andrew).

User space servers are usually not tested with NFS client changes,  
since their use is infrequent compared with Solaris, NetApp filers,  
and the Linux knfsd (and several others).  We have to draw the line  
somewhere to make NFS client development a manageable process.

>> - This problem makes UNFSD and CFSD unusable on 2.6.22 and up (this
>> doesnt sound good to me)

It's likely the NFS client team is not aware of problems with these  
servers simply because none of us run them, and nothing has been  
reported so far.

>> The question are:
>>
>> - Is this wanted or is a bug ?

An EINVAL return is fairly generic, but since it is coming from the  
reply path on the client, that probably indicates that decoding the  
reply failed somehow.  That could be a client problem, or the server  
reply was incorrect or corrupt.

More specific information about the problem is needed.  Could we see  
a wire trace?  A raw tcpdump or tethereal dump captured during the  
problematic interaction would be helpful.  Maybe even an strace of  
the failing application would tell us what the arguments for the  
setattr() call are.  And what are your mount options, especially  
which NFS version? (cat /proc/mounts)

Have you tried a 'git bisect' or something similar to track down  
exactly when client behavior changed?

>> - Can this be solved with some backwards compat stuff into the  
>> kernel or
>> all the old packages as UNFSD have to be
>> bugfixed/upgraded

If NFS servers don't conform to the NFS protocol specification, then  
it's unlikely that the NFS client will be changed to fix such  
issues.  Ie: server bugs need to be fixed on the server.  That is  
sometimes difficult if the server is not maintained, for instance.

>> - I have found other strange behaviors of the new NFS filesystem  
>> support
>> that i am investigating. All are bound to the user of
>> old userspace servers onto the new NFS (since 2.6.22). What to do ?

Report the problems on the linux-nfs@vger.kernel.org mailing list, or
document them in the official bug databases (either the Linux kernel  
bugzilla or the NFSv4 bug tracker at http://bugzilla.linux-nfs.org/

> I'm not sure what the NFS client's policy is regarding support for
> userspace servers.  But I'd certainly hope that it is "don't break  
> them".

The general policy is that if a server behaves in ways that don't  
conform to the NFS spec, then the Linux NFS client probably won't  
work with it.  If the client works with a broken server today, there  
is no guarantee that it will continue to work.

> Which would make this an NFS client regression.

--
Chuck Lever
chuck[dot]lever[at]oracle[dot]com

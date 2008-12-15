From: Harry Edmon <harry-qmPYOCrcNLLyFCzt5hm0YvZ8FUJU4vz8@public.gmane.org>
Subject: Re: High load in 2.6.27, NFS / rpcauth_lookup_credcache()?
Date: Mon, 15 Dec 2008 15:44:58 -0800
Message-ID: <4946EBFA.60700@atmos.washington.edu>
References: <20081022091207.GA12996@squirrel.roonstrasse.net>	 <20081023123628.GA18549@squirrel.roonstrasse.net> <1224773745.7625.4.camel@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Cc: Max Kellermann <max-hDT0AjmEH7RAfugRpC6u6w@public.gmane.org>, linux-kernel@vger.kernel.org,
	linux-nfs@vger.kernel.org
To: Trond Myklebust <trond.myklebust@fys.uio.no>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from dew2.atmos.washington.edu ([128.95.89.42]:37240 "EHLO
	dew2.atmos.washington.edu" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752340AbYLOX5V (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 15 Dec 2008 18:57:21 -0500
In-Reply-To: <1224773745.7625.4.camel@localhost>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Trond Myklebust wrote:
> On Thu, 2008-10-23 at 14:36 +0200, Max Kellermann wrote:
>   
>> On 2008/10/22 11:12, Max Kellermann <max-hDT0AjmEH7RAfugRpC6u6w@public.gmane.org> wrote:
>>     
>>> after I was able to fix http://lkml.org/lkml/2008/10/17/147, the
>>> server which was already upgraded to 2.6.27.2 still gets very high
>>> load.  It is a web server with NFS file storage (NetApp), and while
>>> the others in the cluster (kernel 2.6.25) have a load of 1-3, 2.6.27.2
>>> gets 30-50.
>>>
>>> I did an oprofile, with the following results (server just started,
>>> load "only" 5-10):
>>>
>>> 87593    56.1116  (no location information)   vmlinux
>>> vmlinux                  rpcauth_lookup_credcache
>>> 16037    10.2732  auth_generic.c:0            vmlinux
>>> vmlinux                  generic_match
>>> 6460      4.1382  (no location information)   php4
>>> php4                     (no symbols)
>>> 2478      1.5874  (no location information)   libc-2.7.so
>>> libc-2.7.so              (no symbols)
>>> [...]
>>>
>>> We havn't configured any special authentication method.  It is a NFSv3
>>> over UDP mount, but the kernel has NFSv4 and therefore KRB5 enabled.
>>>
>>> Any ideas why rpcauth_lookup_credcache() goes overboard with CPU
>>> usage?
>>>       
>> I have bisected the problem: 98a8e323 is the result ("SUNRPC: Add a
>> helper rpcauth_lookup_generic_cred()").  5c691044 is ok.
>>
>> See the attached oprofile annotation data for both commits.  I guess
>> that the function rpcauth_lookup_credcache() is waiting for a spinlock
>> too often and too long.  Trond, any idea?
>>     
>
> Can you add a '-v' to the rpc.gssd daemon startup line? I'd like to see
> how often you are creating new gss contexts.
>
>   
>> Harry: added you to Cc because your problem sounds similar.
>>     
>
> Harry's problem is should be unrelated. afaik, he is seeing a problem
> with userland RPC code, not kernel rpc code.
>
> Trond
>
>   
I am finally getting some time to look at my problem that I originally 
reported in October (SUNRPC problem with 2.6.26 and beyond), and I am 
seeing the same behavior as Max Kellermann when my machine slows as I 
described earlier.  The system in question is currently running 
2.6.27.7.  Here is what I see when it is misbehaving:

samples  %        image name               app name                 
symbol name
11380517 57.4191  sunrpc.ko                sunrpc                   
rpcauth_lookup_credcache
3263657  16.4664  sunrpc.ko                sunrpc                   
generic_match
1081287   5.4555  vmlinux                  vmlinux                  
copy_user_generic_string
499407    2.5197  vmlinux                  vmlinux                  
__posix_lock_file
[...]

And here is what I see when I stop the programs that are chewing up all 
the system time, and then starting them up again:

samples  %        image name               app name                 
symbol name
6372650  21.7978  vmlinux                  vmlinux                  
copy_user_generic_string
5401386  18.4755  sunrpc.ko                sunrpc                   
rpcauth_lookup_credcache
3018753  10.3257  vmlinux                  vmlinux                  
__posix_lock_file
1050095   3.5919  sunrpc.ko                sunrpc                   
generic_match


and I am not using Kerberos with NFSv4 (i.e. no rpc.gssd).  Did you ever 
find a solution for this problem with rpcauth_lookup_credcache?

-- 

 Dr. Harry Edmon			E-MAIL: harry-qmPYOCrcNLLyFCzt5hm0YvZ8FUJU4vz8@public.gmane.org
 206-543-0547				harry-B93hV6UPU7Z2icitjWtXSw@public.gmane.org
 Dept of Atmospheric Sciences		FAX:	206-543-0308
 University of Washington, Box 351640, Seattle, WA 98195-1640


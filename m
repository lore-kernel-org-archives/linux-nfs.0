From: Chuck Lever <chuck.lever@oracle.com>
Subject: Re: location of headers under /usr/include/tirpc
Date: Fri, 15 Feb 2008 14:10:24 -0500
Message-ID: <36F20964-D10B-4229-A230-58A2F9ACEC1D@oracle.com>
References: <5761C623-763A-4B2C-8536-96B1989C162F@oracle.com> <47B5CFEE.2020502@RedHat.com>
Mime-Version: 1.0 (Apple Message framework v753)
Content-Type: text/plain; charset=US-ASCII; delsp=yes; format=flowed
Cc: NFS list <linux-nfs@vger.kernel.org>
To: Steve Dickson <SteveD@redhat.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from rgminet01.oracle.com ([148.87.113.118]:52125 "EHLO
	rgminet01.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754157AbYBOTMo (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 15 Feb 2008 14:12:44 -0500
In-Reply-To: <47B5CFEE.2020502-AfCzQyP5zfLQT0dZR+AlfA@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Feb 15, 2008, at 12:46 PM, Steve Dickson wrote:
> Chuck Lever wrote:
>> Hi Steve-
>>
>> I think libtirpc-devel installs the tirpc headers in the wrong place.
>> The #include directives in the headers themselves expect them to  
>> appear
>> under /usr/include, not under /usr/include/tirpc, so my builds  
>> fail when
>> trying to include these headers.
>>
>> For example, /usr/include/tirpc/rpc/rpcb_clnt.h does a "#include
>> <rpc/rpcb_prot.h>" -- and the build chokes because that header is
>> actually in /usr/include/tirpc/rpc/rpcb_prot.h.
>>
>> Now, I can probably fix this temporarily by adding "-I
>> /usr/include/tirpc" to my build.  However:
>>
>> 1.  On Solaris, these all appear under /usr/include, there is no
>> /usr/include/tirpc.
>>
>> 2.  libtirpc-devel installs a bunch of files that already exist,  
>> such as
>> /usr/include/rpc/auth.h, in /usr/include/tirpc/rpc/auth.h.
>>
>> It would be cleaner to have one place for nfs-utils to look for these
>> headers, so I don't want to permanently add "-I /usr/include/ 
>> tirpc" or
>> autoconf magic to find the right path unless we decide
>> /usr/include/tirpc is the final location for these files.
>>
>> So I think applications in general will expect to find these under
>> /usr/include, not under /usr/include/tirpc.
>>
>> Comments?
> Its not clear what we can do. We just can't replace the file
> under /usr/include with the tirpc since that would break other
> RPC applications.

Fortunately it may not be all that bad.  The file I looked at that  
appeared in both places (/usr/include/rpc/auth.h and /usr/include/ 
tirpc/rpc/auth.h) was exactly the same.  I'll bet most or all of the  
duplicate files are the same, since they come from the same origin  
(Sun) and perform the same duty.

The duplicates appear to come from glibc-headers-2.6-4... wouldn't be  
hard to add a dependency in libtirpc-devel on glibc-headers-2.6.4 to  
ensure these get installed first.

> So what I think needs to happens, is I need to create
> a libtirpc.pc file that will live in /usr/lib/pkgconfig/  so you
> can used things like
>     pkg-config --libs libtirpc and pkg-config --cflags libgssglue
>
> similar to how the librpcsecgss.pc and libgssglue.pc work

--
Chuck Lever
chuck[dot]lever[at]oracle[dot]com

From: Greg Banks <gnb-cP1dWloDopni96+mSzHFpQC/G2K4zDHf@public.gmane.org>
Subject: Re: [PATCH 1/5] NFS: Update help text for CONFIG_NFS_FS
Date: Tue, 05 Feb 2008 11:40:25 +1100
Message-ID: <47A7B079.8010903@melbourne.sgi.com>
References: <20080205000421.18602.44285.stgit@manray.1015granger.net> <1202170682.28484.55.camel@heimdal.trondhjem.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: Chuck Lever <chuck.lever@oracle.com>, bfields@citi.umich.edu,
	linux-nfs@vger.kernel.org
To: Trond Myklebust <trond.myklebust@fys.uio.no>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from netops-testserver-3-out.sgi.com ([192.48.171.28]:59078 "EHLO
	relay.sgi.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1755831AbYBEAdz (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 4 Feb 2008 19:33:55 -0500
In-Reply-To: <1202170682.28484.55.camel-rJ7iovZKK19ZJLDQqaL3InhyD016LWXt@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Trond Myklebust wrote:
> On Mon, 2008-02-04 at 19:04 -0500, Chuck Lever wrote:
>   
>> Refresh the help text for Kconfig items related to the NFS client.  Remove
>> obsolete URLs, and make the language consistent among the options.
>>
>>  
>>  config NFS_DIRECTIO
>>  	bool "Allow direct I/O on NFS files"
>>  	depends on NFS_FS
>> +	default N
>>     
>
> Why? Isn't O_DIRECT pretty much a standard feature that is enabled in
> most distros at this time?
> IMO we should rather be aiming to phase out NFS_DIRECTIO.
>   
Agreed.

>   
>>  	help
>> -	  This option enables applications to perform uncached I/O on files
>> -	  in NFS file systems using the O_DIRECT open() flag.  When O_DIRECT
>> -	  is set for a file, its data is not cached in the system's page
>> -	  cache.  Data is moved to and from user-level application buffers
>> -	  directly.  Unlike local disk-based file systems, NFS O_DIRECT has
>> -	  no alignment restrictions.
>> +	  This option enables support for uncached I/O on files accessed
>> +	  via an NFS mount point.  Applications request direct I/O by
>> +	  setting the O_DIRECT flag when opening a file.
>> +
>> +	  When direct I/O is requested, the NFS client moves data to and
>> +	  from user-level application buffers directly to NFS servers.
>> +	  Direct I/O on NFS files does not suffer from any I/O or buffer
>> +	  alignment restrictions, as does direct I/O on files that reside
>> +	  in local file systems.
>>     
It might be an idea to mention that direct IO does *not* bypass the
server's page cache, an unobvious semantic which escapes many people.

>> +
>> +	  For details, see the open(2) man page.
>>     
FYI, I recently posted an update to the O_DIRECT documentation in open(2).
http://marc.info/?l=linux-man&m=120107005026531&w=2


-- 
Greg Banks, R&D Software Engineer, SGI Australian Software Group.
The cake is *not* a lie.
I don't speak for SGI.


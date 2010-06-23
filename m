From: Chuck Lever <chuck.lever@oracle.com>
Subject: Re: Connectathon locking test fails over NFSv3 with EBUSY
Date: Wed, 23 Jun 2010 15:55:58 -0400
Message-ID: <4C2266CE.5050707@oracle.com>
References: <4C2108E7.6040909@oracle.com>	 <1277234232.3204.40.camel@heimdal.trondhjem.org>	 <4C224991.1040809@oracle.com>	 <BF3BB6D12298F54B89C8DCC1E4073D80017545B4@CORPUSMX50A.corp.emc.com>	 <4C225DAC.2090203@oracle.com> <1277321217.4991.64.camel@heimdal.trondhjem.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Cc: Staubach_Peter@emc.com, linux-nfs@vger.kernel.org
To: Trond Myklebust <Trond.Myklebust@netapp.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from rcsinet10.oracle.com ([148.87.113.121]:17982 "EHLO
	rcsinet10.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753707Ab0FWT4O (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 23 Jun 2010 15:56:14 -0400
In-Reply-To: <1277321217.4991.64.camel-rJ7iovZKK19ZJLDQqaL3InhyD016LWXt@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 06/23/10 03:26 PM, Trond Myklebust wrote:
> On Wed, 2010-06-23 at 15:17 -0400, Chuck Lever wrote:
>> On 06/23/10 02:06 PM, Staubach_Peter@emc.com wrote:
>>> Perhaps the oprofile support is retaining an additional reference to the in-core
>>> inode which is causing the .nfsXXXX files to get created and is also delaying their
>>> removal?
>>
>> The files do not appear in oprofiled's fd list (in /proc).  Killing the
>> oprofiled process after the test finishes does make those files go away.
>>    Just shutting down the profiler leaves oprofiled, so additionally
>> killing the daemon appears to be necessary to finish the silly removal
>> process.
>>
>> These files are all executables (part of the connectathon suite), but I
>> don't have the "profile user space binaries" checkbox selected.
>
> OK. That makes more sense... Do these files perhaps appear in
> the /proc/<pid>/maps and/or /proc/<pid>/smaps pseudofile for oprofiled?

I don't see anything suspicious in those files.

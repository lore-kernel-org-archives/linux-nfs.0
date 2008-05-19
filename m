From: Chuck Lever <chuck.lever@oracle.com>
Subject: Re: [PATCH 1/8] NFS: Update help text for CONFIG_NFS_FS
Date: Mon, 19 May 2008 13:21:19 -0400
Message-ID: <64E73AAD-3E2E-4C57-B51F-6D060B6890E8@oracle.com>
References: <20080518021241.8366.12464.stgit@ellison.1015granger.net> <20080518021614.8366.39102.stgit@ellison.1015granger.net> <RTPCLUEXC1-PRDXzzAg00000113@RTPMVEXC1-PRD.hq.netapp.com>
Mime-Version: 1.0 (Apple Message framework v919.2)
Content-Type: text/plain; charset=US-ASCII; format=flowed; delsp=yes
Cc: linux-nfs@vger.kernel.org
To: "Talpey, Thomas" <Thomas.Talpey@netapp.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from rgminet01.oracle.com ([148.87.113.118]:62596 "EHLO
	rgminet01.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754594AbYESRVs (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 19 May 2008 13:21:48 -0400
In-Reply-To: <RTPCLUEXC1-PRDXzzAg00000113-rtwIt2gI0FxT+ZUat5FNkAK/GNPrWCqfQQ4Iyu8u01E@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On May 19, 2008, at 1:09 PM, Talpey, Thomas wrote:
> At 10:16 PM 5/17/2008, Chuck Lever wrote:
>> Clean up: refresh the help text for Kconfig items related to the NFS
>> client.  Remove obsolete URLs, and make the language consistent among
>> the options.
>
> I like the patch for no other reason than (finally) getting rid
> of the CODA nasty-gram:
>
>> -	  A superior but less widely used alternative to NFS is provided by
>> -	  the Coda file system; see "Coda file system support" below.
>
> But I do have a comment - I think calling it "Sun's" protocol is  
> unnecessary.
> It's an IETF standard, and widely implemented.

I think that's why this patch was originally rejected.  Trond didn't  
like the fact that I said IETF standard, but I don't recall the exact  
details.

>> +	  Choose Y here if you want to access files residing on other
>> +	  computers using Sun's Network File System protocol.  To compile
>> +	  this file system support as a module, choose M here: the module
>> +	  will be called nfs.
>
>
>> config NFS_V3
>> -	bool "Provide NFSv3 client support"
>> +	bool "NFS client support for NFS version 3"
>
> The new option says NFS twice.

Yes, but I think it makes the description more precise.  It could say  
"NFS client support for version 3" or "Client support for NFS version  
3".  I think both of those choices are ambiguous in one way or another.

>> config NFS_V4
>> -	bool "Provide NFSv4 client support (EXPERIMENTAL)"
>> +	bool "NFS client support for NFS version 4 (EXPERIMENTAL)"
>> 	depends on NFS_FS && EXPERIMENTAL
>
> Is it necessary to say "(EXPERIMENTAL)"? There are many other kernel
> options that don't, but in fact are dependent.

It's usually good to mark these as experimental, and it has been  
convention for a long while, but I don't see a requirement for it.

--
Chuck Lever
chuck[dot]lever[at]oracle[dot]com

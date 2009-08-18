From: Chuck Lever <chuck.lever@oracle.com>
Subject: Re: nfs MNT include cleanup
Date: Tue, 18 Aug 2009 09:19:04 -0400
Message-ID: <2CFAE1D9-D544-4CF1-9F19-E2D0401BD149@oracle.com>
References: <20090811104418.GA6175@stro.at> <C7D2AC7D-48B2-4206-A6B1-3780FE7D51CE@oracle.com> <20090818103653.GB3954@stro.at> <86201444-2DDC-47B0-A92E-81CB19224CCB@oracle.com> <20090818124406.GD13440@baikonur.stro.at>
Mime-Version: 1.0 (Apple Message framework v936)
Content-Type: text/plain; charset=US-ASCII; format=flowed; delsp=yes
Cc: linux-nfs@vger.kernel.org,
	Trond Myklebust <Trond.Myklebust@netapp.com>, klibc@zytor.com
To: maximilian attems <max-U9r9yeDMy7A@public.gmane.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from acsinet11.oracle.com ([141.146.126.233]:35676 "EHLO
	acsinet11.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750934AbZHRNTL (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 18 Aug 2009 09:19:11 -0400
In-Reply-To: <20090818124406.GD13440-P4at2qFsAtP5lb2fJPEjcQ@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Aug 18, 2009, at 8:44 AM, maximilian attems wrote:
> On Tue, Aug 18, 2009 at 08:45:49AM -0400, Chuck Lever wrote:
>>
>> However, the kernel has its own NFS mount client (the piece that
>> handles rpcbind query and obtaining the root file handle), and you  
>> can
>> pass a C string of mount options to the kernel with mount(2).   
>> Perhaps
>> in the long term, you might consider replacing the specialized code  
>> in
>> klibc with simply passing the server, export path, and mount options
>> right to the kernel and let it do the work.  This should work with  
>> any
>> kernel later than 2.6.23.
>>
>> I'm happy to help with any questions.
>
> sounds good indeed.
> a quick one: can it do nfs v4 mounts?

Yes, in fact.  Set the file system type to "nfs4" instead of "nfs"  
when invoking mount(2).

--
Chuck Lever
chuck[dot]lever[at]oracle[dot]com

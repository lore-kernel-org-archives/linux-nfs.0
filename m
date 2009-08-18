From: "H. Peter Anvin" <hpa@zytor.com>
Subject: Re: [klibc] nfs MNT include cleanup
Date: Tue, 18 Aug 2009 09:04:45 -0700
Message-ID: <4A8AD11D.4000809@zytor.com>
References: <20090811104418.GA6175@stro.at>	<C7D2AC7D-48B2-4206-A6B1-3780FE7D51CE@oracle.com>	<20090818103653.GB3954@stro.at>	<86201444-2DDC-47B0-A92E-81CB19224CCB@oracle.com> <20090818124406.GD13440@baikonur.stro.at>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Chuck Lever <chuck.lever@oracle.com>, linux-nfs@vger.kernel.org,
	klibc@zytor.com, Trond Myklebust <Trond.Myklebust@netapp.com>
To: maximilian attems <max-U9r9yeDMy7A@public.gmane.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from terminus.zytor.com ([198.137.202.10]:40599 "EHLO
	terminus.zytor.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755145AbZHRQFn (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 18 Aug 2009 12:05:43 -0400
In-Reply-To: <20090818124406.GD13440-P4at2qFsAtP5lb2fJPEjcQ@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 08/18/2009 05:44 AM, maximilian attems wrote:
> On Tue, Aug 18, 2009 at 08:45:49AM -0400, Chuck Lever wrote:
>> However, the kernel has its own NFS mount client (the piece that  
>> handles rpcbind query and obtaining the root file handle), and you can  
>> pass a C string of mount options to the kernel with mount(2).  Perhaps  
>> in the long term, you might consider replacing the specialized code in  
>> klibc with simply passing the server, export path, and mount options  
>> right to the kernel and let it do the work.  This should work with any  
>> kernel later than 2.6.23.
>>
>> I'm happy to help with any questions.
> 
> sounds good indeed.
> a quick one: can it do nfs v4 mounts?
> 

I believe that was the reason for the change in the first place, and
yes, klibc should *absolutely* use it.

	-hpa (who once again apologizes for lack of time...)

-- 
H. Peter Anvin, Intel Open Source Technology Center
I work for Intel.  I don't speak on their behalf.


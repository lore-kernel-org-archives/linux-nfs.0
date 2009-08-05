From: Helge Deller <deller@gmx.de>
Subject: Re: nfs: __setup_str_nfs_root_setup causes a section type conflict
Date: Wed, 05 Aug 2009 21:47:58 +0200
Message-ID: <4A79E1EE.9070107@gmx.de>
References: <200907311446.33486.elendil@planet.nl>	 <200908032121.10635.elendil@planet.nl>	 <1249328851.18161.32.camel@heimdal.trondhjem.org>	 <200908032257.51739.elendil@planet.nl>	 <1249333643.18161.36.camel@heimdal.trondhjem.org>	 <20090803215237.GA956@merkur.ravnborg.org> <1249337493.18161.52.camel@heimdal.trondhjem.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Cc: Sam Ravnborg <sam-uyr5N9Q2VtJg9hUCZPvPmw@public.gmane.org>, Frans Pop <elendil-EIBgga6/0yRmR6Xm/wNWPw@public.gmane.org>,
	linux-kernel@vger.kernel.org, linux-nfs@vger.kernel.org,
	parisc-linux-T/XaZq8tFt7U4lJK3ijXoz+iFHGzDt/a@public.gmane.org
To: Trond Myklebust <trond.myklebust@fys.uio.no>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail.gmx.net ([213.165.64.20]:57597 "HELO mail.gmx.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with SMTP
	id S1750921AbZHETsA (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 5 Aug 2009 15:48:00 -0400
In-Reply-To: <1249337493.18161.52.camel-rJ7iovZKK19ZJLDQqaL3InhyD016LWXt@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 08/04/2009 12:11 AM, Trond Myklebust wrote:
> On Mon, 2009-08-03 at 23:52 +0200, Sam Ravnborg wrote:
>> On Mon, Aug 03, 2009 at 05:07:23PM -0400, Trond Myklebust wrote:
>>> On Mon, 2009-08-03 at 22:57 +0200, Frans Pop wrote:
>>>> $ make init/do_mounts.o
>>>>    CHK     include/linux/version.h
>>>>    CHK     include/linux/utsrelease.h
>>>>    SYMLINK include/asm ->  include/asm-parisc
>>>>    CALL    scripts/checksyscalls.sh
>>>>    CC      init/do_mounts.o
>>>>
>>>> while:
>>>>
>>>> $ make fs/nfs/nfsroot.o
>>>>    CHK     include/linux/version.h
>>>>    CHK     include/linux/utsrelease.h
>>>>    SYMLINK include/asm ->  include/asm-parisc
>>>>    CALL    scripts/checksyscalls.sh
>>>>    CC      fs/nfs/nfsroot.o
>>>> fs/nfs/nfsroot.c:403: error: __setup_str_nfs_root_setup causes a section type
>>>> conflict
>>> To me that looks like some kind of compiler bug.
>> unspecified behaviour is a better name for it.
>>
>> We have two variables we have forced a section on.
>> One variable is marked RO by the compiler while the other is not.
>> This results in a section type conflict because all
>> symbols needs to have the same falgs.
>>
>> We usually triggers this with powerpc builds (64 bit IIRC),
>> and now with parisc too.
>>
>> The only way to fix it is to move one of the offending
>> variables to __initdata.
>> There is two variales to consider - the compiler only
>> mention one of them.

Yes.
It seems this was already once described on the parisc mailing list:
http://article.gmane.org/gmane.linux.ports.parisc/1816

Helge


>>
>> Trying to declare the variables const etc usually has
>> no good effect.
>
> So why would it be happening in the NFSroot case, but not in
> do_mounts.c? They're both using the standard __setup() macro with a
> constant string, and an __init function argument.
>
> Futhermore, when grepping for '__initconst', it seems that the
> combination with 'static const' is the norm rather than the exception.


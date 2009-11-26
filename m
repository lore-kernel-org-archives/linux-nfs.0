From: Helge Deller <deller@gmx.de>
Subject: Re: [PATCH 1/5] parsic: remove unused nfsd #includes
Date: Thu, 26 Nov 2009 22:47:53 +0100
Message-ID: <4B0EF789.8060805@gmx.de>
References: <4B0C1EB7.50508@panasas.com> <4B0C1F1A.8070605@panasas.com> <4B0E94D4.5090800@panasas.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Cc: "J. Bruce Fields" <bfields@citi.umich.edu>,
	linux-parisc <linux-parisc@vger.kernel.org>,
	Grant Grundler <grundler@parisc-linux.org>,
	Kyle McMartin <kyle@mcmartin.ca>,
	"James E.J. Bottomley" <jejb@parisc-linux.org>,
	Linux Kernel <linux-kernel@vger.kernel.org>,
	sparclinux <sparclinux@vger.kernel.org>,
	linux-s390 <linux-s390@vger.kernel.org>,
	NFS list <linux-nfs@vger.kernel.org>,
	pNFS Mailing List <pnfs@linux-nfs.org>,
	Andrew Morton <akpm@linux-foundation.org>
To: Boaz Harrosh <bharrosh@panasas.com>
Return-path: <linux-parisc-owner@vger.kernel.org>
In-Reply-To: <4B0E94D4.5090800@panasas.com>
Sender: linux-parisc-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 11/26/2009 03:46 PM, Boaz Harrosh wrote:
> On 11/24/2009 11:27 PM, Grant Grundler wrote:
>> On Tue, Nov 24, 2009 at 07:58:15PM +0200, Boaz Harrosh wrote:
>>> Some arch files had unneeded #includes directives from linux/nfsd/*.
>>> Some vfs files had unneeded #includes directives from linux/nfsd/*.
>> ...
>>> patches:
>>> [PATCH 1/5] parsic: remove unused nfsd #includes
>>> 	Some kind soul, please compile with this patch? compile
>>> 	is all that's needed.
>>
>> Boaz,
>> linux-2.6 compiles for parisc with this patch. Please add:
>>      Tested-by: Grant Grundler<grundler@parisc-linux.org>
>>
>> thanks,
>> grant
>>
>
> CCing registered parsic maintainers. Could we please get an ACK on
> this patch, and cary this through the nfsd tree?

Sure.

Acked-by: Helge Deller <deller@gmx.de>

Helge


>
> Thanks
> Boaz
>
> On 11/24/2009 07:59 PM, Boaz Harrosh wrote:
>>
>> Some unused includes removed.
>>
>> This patch is in an effort to cleanup nfsd headers and move
>> private definitions to source directory.
>>
>> Signed-off-by: Boaz Harrosh<bharrosh@panasas.com>
>> ---
>>   arch/parisc/kernel/sys_parisc32.c |    6 ------
>>   1 files changed, 0 insertions(+), 6 deletions(-)
>>
>> diff --git a/arch/parisc/kernel/sys_parisc32.c b/arch/parisc/kernel/sys_parisc32.c
>> index 561388b..4a8ca63 100644
>> --- a/arch/parisc/kernel/sys_parisc32.c
>> +++ b/arch/parisc/kernel/sys_parisc32.c
>> @@ -26,13 +26,7 @@
>>   #include<linux/shm.h>
>>   #include<linux/slab.h>
>>   #include<linux/uio.h>
>> -#include<linux/nfs_fs.h>
>>   #include<linux/ncp_fs.h>
>> -#include<linux/sunrpc/svc.h>
>> -#include<linux/nfsd/nfsd.h>
>> -#include<linux/nfsd/cache.h>
>> -#include<linux/nfsd/xdr.h>
>> -#include<linux/nfsd/syscall.h>
>>   #include<linux/poll.h>
>>   #include<linux/personality.h>
>>   #include<linux/stat.h>
>
> --
> To unsubscribe from this list: send the line "unsubscribe linux-kernel" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> Please read the FAQ at  http://www.tux.org/lkml/


From: Holger Kiehl <Holger.Kiehl@dwd.de>
Subject: Re: NFS write OOPS with 2.6.29.2
Date: Sat, 9 May 2009 19:16:49 +0000 (GMT)
Message-ID: <Pine.LNX.4.64.0905091913010.3181@praktifix.dwd.de>
References: <Pine.LNX.4.64.0905031552340.1774@praktifix.dwd.de>
 <20090504231426.2e5a51b0.akpm@linux-foundation.org>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII; format=flowed
Cc: Andrew Morton <akpm@linux-foundation.org>
To: linux-kernel <linux-kernel@vger.kernel.org>,
	linux-nfs@vger.kernel.org
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1753174AbZEITRJ@vger.kernel.org>
In-Reply-To: <20090504231426.2e5a51b0.akpm@linux-foundation.org>
Sender: linux-kernel-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, 4 May 2009, Andrew Morton wrote:

>
> (cc linux-nfs)
>
> On Sun, 3 May 2009 16:03:38 +0000 (GMT) Holger Kiehl <Holger.Kiehl@dwd.de> wrote:
>
>> Hello
>>
>> With plain kernel 2.6.29.2 I get the following OOPS (several of them) when
>> writing lots of small files on the client system:
>>
>>     May  3 18:48:34 obelix kernel: ------------[ cut here ]------------
>>     May  3 18:48:34 obelix kernel: kernel BUG at fs/nfs/write.c:252!
>
> I think this is a well-know bug, and fixes should be available in 2.6.29.3?
>
Thanks for this information. I just tried 2.6.29.3 and it still oopses.
Are there any patches I can try?

Thanks,
Holger

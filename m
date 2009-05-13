From: Suresh Jayaraman <sjayaraman@suse.de>
Subject: Re: NFS write OOPS with 2.6.29.2
Date: Wed, 13 May 2009 16:20:02 +0530
Message-ID: <4A0AA5DA.6090705@suse.de>
References: <Pine.LNX.4.64.0905031552340.1774@praktifix.dwd.de>	 <20090504231426.2e5a51b0.akpm@linux-foundation.org>	 <Pine.LNX.4.64.0905091913010.3181@praktifix.dwd.de>	 <1241929074.5149.1.camel@heimdal.trondhjem.org>	 <Pine.LNX.4.64.0905110919490.27423@praktifix.dwd.de>	 <1242044201.6691.4.camel@heimdal.trondhjem.org>	 <Pine.LNX.4.64.0905111240190.27423@praktifix.dwd.de> <1242046675.6691.6.camel@heimdal.trondhjem.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Holger Kiehl <Holger.Kiehl-ra7Ruw+Xvfw@public.gmane.org>,
	linux-kernel <linux-kernel@vger.kernel.org>,
	linux-nfs@vger.kernel.org,
	Andrew Morton <akpm@linux-foundation.org>
To: Trond Myklebust <trond.myklebust@fys.uio.no>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from victor.provo.novell.com ([137.65.250.26]:56071 "EHLO
	victor.provo.novell.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754566AbZEMKuS (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 13 May 2009 06:50:18 -0400
In-Reply-To: <1242046675.6691.6.camel-rJ7iovZKK19ZJLDQqaL3InhyD016LWXt@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Trond Myklebust wrote:
> On Mon, 2009-05-11 at 12:45 +0000, Holger Kiehl wrote:
>> On Mon, 11 May 2009, Trond Myklebust wrote:
>>>
>> Thanks! Now it works. One more problem I have is with splice(). My
>> application reports the following error:
>>
>>     splice() error : Invalid argument
>>
>> When it is called as follows:
>>
>>      if ((bytes_written = splice(fd_pipe[0], NULL, to_fd,
>>                                  NULL, bytes_read,
>>                                  SPLICE_F_MOVE | SPLICE_F_MORE)) == -1)
>>
>> Or may I not use splice() over NFS?
> 
> The read part is there, but the write part is still missing (just an
> oversight - implementing it is pretty trivial). I'm planning on fixing
> that for 2.6.31.
> 

Did my latest respun look OK?

http://lkml.org/lkml/2009/4/22/70


Thanks,

-- 
Suresh Jayaraman

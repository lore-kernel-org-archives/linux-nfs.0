Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-bk0-f46.google.com ([209.85.214.46]:40578 "EHLO
	mail-bk0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754155Ab2FKOMo (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 11 Jun 2012 10:12:44 -0400
Received: by bkcji2 with SMTP id ji2so3566107bkc.19
        for <linux-nfs@vger.kernel.org>; Mon, 11 Jun 2012 07:12:43 -0700 (PDT)
Message-ID: <4FD5FCD7.90704@tonian.com>
Date: Mon, 11 Jun 2012 17:12:39 +0300
From: Benny Halevy <bhalevy@tonian.com>
MIME-Version: 1.0
To: Johannes Schild <JSchild@gmx.de>
CC: Jim Rees <rees@umich.edu>, bharrosh@panasas.com, linux-nfs@vger.kernel.org
Subject: Re: Block-Layout
References: <20120605090323.251620@gmx.net> <4FCDD45C.2080400@panasas.com> <20120605110437.GA28423@umich.edu> <20120606074912.298170@gmx.net>
In-Reply-To: <20120606074912.298170@gmx.net>
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Sorry for the late response.
Unfortunately, I don't think the reference server implementation could ever work
reliably for writes. The gist of it is that it uses fallocate() to allocate new blocks
and these are marked unintialized.  Since LAYOUTCOMMIT is not handled by the file system
they are never marked as initialized and therefore they are read as containing zero
by the MDS.  So, for read-only, you can try pnfs-all-3.3.

Benny

On 2012-06-06 10:49, Johannes Schild wrote:
> So lets ask Benny ;)
> 
> Can you give me a hint about the most usable block-layout code?
> 
> 
> Best Regards
> 
> Johannes
> 
> 
> -------- Original-Nachricht --------
>> Datum: Tue, 5 Jun 2012 07:04:37 -0400
>> Von: Jim Rees <rees@umich.edu>
>> An: Boaz Harrosh <bharrosh@panasas.com>
>> CC: Johannes Schild <JSchild@gmx.de>, linux-nfs@vger.kernel.org
>> Betreff: Re: Block-Layout
> 
>> Boaz Harrosh wrote:
>>
>>   On 06/05/2012 12:03 PM, Johannes Schild wrote:
>>   
>>   > Hi Guys,
>>   > 
>>   > after i got the Object-Layout to work (Thanks to Boaz :D)
>>   > My next goal to achieve is the Block-Layout.
>>   > I know its deprecated, Boaz told me too, but i need it for my paper.
>>   > Could someone tell me which was the last working kernel and sources
>> which works?
>>   > 
>>   
>>   
>>   You mean the Server right? The client is very much alive.
>>   
>>   I'm not sure what was the last spnfsd-blocks that worked? Jim?
>>
>> I don't know.  I would ask Benny.
>> --
>> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
>> the body of a message to majordomo@vger.kernel.org
>> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> 

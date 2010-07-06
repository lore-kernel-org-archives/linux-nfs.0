Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from daytona.panasas.com ([67.152.220.89]:41877 "EHLO
	daytona.int.panasas.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1751088Ab0GFNgA (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 6 Jul 2010 09:36:00 -0400
Message-ID: <4C33313C.5070708@panasas.com>
Date: Tue, 06 Jul 2010 16:35:56 +0300
From: Benny Halevy <bhalevy@panasas.com>
To: Daniel.Muntz@emc.com
CC: andros@netapp.com, sjoshi@bluearc.com, linux-nfs@vger.kernel.org
Subject: Re: 4.1 client - LAYOUTCOMMIT & close
References: <A062FCC8662DA848949F7C3046B9BEAE01F3A6ED@us-email.terastack.bluearc.com> <A062FCC8662DA848949F7C3046B9BEAE01F3A6EE@us-email.terastack.bluearc.com> <6206CE0E-0A32-46A7-B648-3FCC12ED1961@netapp.com> <B9A709F368FAAF4DB4B33870F72A141DFB88F3@CORPUSMX30A.corp.emc.com>
In-Reply-To: <B9A709F368FAAF4DB4B33870F72A141DFB88F3@CORPUSMX30A.corp.emc.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Jul. 03, 2010, 0:46 +0300, <Daniel.Muntz@emc.com> wrote:
> By "extremely lame server" I assume you mean any pNFS server that
> doesn't have a cluster FS on the back end.  So while this might work
> well for NetApp (as long as NetApp never ships a non-clustered pNFS), it
> might break others, or at least severely impact their performance.  For
> example, will the Solaris pNFS server work correctly without
> LAYOUTCOMMIT?  IMHO, the client MUST issue the appropriate LAYOUTCOMMIT,
> but the server is free to handle it as a no-op if the server
> implementation does not need to utilize the payload.

I completely agree.

Only with Dave Noveck suggestion of adding a "LAYOUT_{DATA,FILE}_SYNC4"
stable_how4 values (or maybe a LAYOUT_SYNC4=4 or higher power of 2 flag)
to be returned by a DS on WRITE, the DS can say that it ensures metadata
synchronization with the MDS in a cluster coherent way and the client can relax
and avoid sending LAYOUTCOMMIT to the MDS.

Otherwise, the linux implementation can potentially support a mount option
telling the client to not send a LAYOUTCOMMIT to the MDS as an optimization
if the admin is sure that the server doesn't require it.

Benny


> 
>   -Dan
> 
>> -----Original Message-----
>> From: linux-nfs-owner@vger.kernel.org 
>> [mailto:linux-nfs-owner@vger.kernel.org] On Behalf Of Andy Adamson
>> Sent: Friday, July 02, 2010 8:41 AM
>> To: Sandeep Joshi
>> Cc: linux-nfs@vger.kernel.org; bhalevy@panasas.com
>> Subject: Re: 4.1 client - LAYOUTCOMMIT & close
>>
>>
>> On Jul 1, 2010, at 8:07 PM, Sandeep Joshi wrote:
>>
>> Hi Sandeep
>>
>>>
>>> In certain cases, I don't see layoutcommit on a file at all even  
>>> after doing many writes.
>>
>> FYI:
>>
>> You should not be paying attention to layoutcommits  - they have no  
>> value for the file layout type.
>>
>>  From RFC 5661:
>>
>> "The LAYOUTCOMMIT operation commits chages in the layout represented  
>> by the current filehandle, client ID (derived from the session ID in  
>> the preceding SEQUENCE operation), byte-range, and stateid."
>>
>> For the block layout type, this sentence has meaning in that 
>> there is  
>> a layoutupdate4 payload that enumerates the blocks that have changed  
>> state from being 'handed out' to being 'written'.
>>
>> The file layout type has no layoutupdate4 payload, and the 
>> layout does  
>> not change due to writes, and thus the LAYOUTCOMMIT call is useless.
>>
>> The only field in the LAYOUTCOMMIT4args that might possibly 
>> be useful  
>> is the loca_last_write_offset which tells the server what the client  
>> thinks is the EOF of the file after WRITE. It is an extremely lame  
>> server (file layout type server) that depends upon clients for this  
>> info.
>>
>>>
>>>
>>>
>>> Client side operations:
>>>
>>> open
>>> write(s)
>>> close
>>>
>>>
>>> On server side (observed operations):
>>>
>>> open
>>> layoutget's
>>> close
>>>
>>>
>>> But, I do not see laycommit at all. In terms data written 
>> by client  
>>> it is about 4-5MB.
>>>
>>> When does client issue laycommit?
>>
>> The latest linux client sends a layout commit when the VFS does a  
>> super_operations.write_inode call which happens when the metadata of  
>> an inode needs updating. We are seriously considering removing the  
>> layoutcommit call from the file layout client.
>>
>> -->Andy
>>
>>>
>>>
>>> regards,
>>>
>>> Sandeep
>>>
>>> --
>>> To unsubscribe from this list: send the line "unsubscribe 
>> linux-nfs"  
>>> in
>>> the body of a message to majordomo@vger.kernel.org
>>> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>>
>> --
>> To unsubscribe from this list: send the line "unsubscribe 
>> linux-nfs" in
>> the body of a message to majordomo@vger.kernel.org
>> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>>
>>

From: Andy Adamson <andros@netapp.com>
Subject: Re: 4.1 client - LAYOUTCOMMIT &amp; close
Date: Tue, 6 Jul 2010 09:12:16 -0400
Message-ID: <EEBF0A56-92A7-4045-B483-C77A2CEFC086@netapp.com>
References: <A062FCC8662DA848949F7C3046B9BEAE01F3A6ED@us-email.terastack.bluearc.com> <A062FCC8662DA848949F7C3046B9BEAE01F3A6EE@us-email.terastack.bluearc.com> <6206CE0E-0A32-46A7-B648-3FCC12ED1961@netapp.com> <loom.20100702T190300-538@post.gmane.org>
Mime-Version: 1.0 (Apple Message framework v936)
Content-Type: text/plain; charset=US-ASCII; format=flowed; delsp=yes
Cc: linux-nfs@vger.kernel.org
To: Suchit Kaura <skaura-Pe6u2o1+k2hBDgjK7y7TUQ@public.gmane.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:14632 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753470Ab0GFNMd (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 6 Jul 2010 09:12:33 -0400
In-Reply-To: <loom.20100702T190300-538-eS7Uydv5nfjZ+VzJOa5vwg@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


On Jul 2, 2010, at 1:08 PM, Suchit Kaura wrote:

>> We are seriously considering removing the
>> layoutcommit call from the file layout client.
>> From the RFC5661:
> For block/volume-based layouts, LAYOUTCOMMIT may require updating the
>   block list that comprises the file and committing this layout to
>   stable storage.  For file-based layouts, synchronization of
>   attributes between the metadata and storage devices, primarily the
>   size attribute, is required.
>
>   The control protocol is free to synchronize the attributes before it
>   receives a LAYOUTCOMMIT; however, upon successful completion of a
>   LAYOUTCOMMIT, state that exists on the metadata server that  
> describes
>   the file MUST be synchronized with the state that exists on the
>   storage devices that comprise that file as of the client's last sent
>   operation.  Thus, a client that queries the size of a file between a
>   WRITE to a storage device and the LAYOUTCOMMIT might observe a size
>   that does not reflect the actual data written.
>
> I understand and agree with the option that control protocol will  
> update the
> information on the MDFS for file layout type but does the text above  
> not mark
> layout commit as a consistency boundary even with servers supporting
> filelayouts?


For the file layout type, the COMMIT operation does this already, and  
the LAYOUTCOMMIT is not needed. My reading of the above text is that  
if a LAYOUTCOMMIT is sent and successfully completed then the 'MUST be  
synchronized with the state ..... " text applies. But why would the  
file layout type want two synchronization points (LAYOUTCOMMIT and  
COMMIT)? So, why send a LAYOUTCOMMIT for the file layout type?

> or are we saying that every write or DFS must be synchronized with
> MDFS thru control protocol for file layout servers?

Nope, only on COMMIT.

-->Andy

>
> Regards,
> Suchit
>
> Andy Adamson <andros@...> writes:
>
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
>> From RFC 5661:
>>
>> "The LAYOUTCOMMIT operation commits chages in the layout represented
>> by the current filehandle, client ID (derived from the session ID in
>> the preceding SEQUENCE operation), byte-range, and stateid."
>>
>> For the block layout type, this sentence has meaning in that there is
>> a layoutupdate4 payload that enumerates the blocks that have changed
>> state from being 'handed out' to being 'written'.
>>
>> The file layout type has no layoutupdate4 payload, and the layout  
>> does
>> not change due to writes, and thus the LAYOUTCOMMIT call is useless.
>>
>> The only field in the LAYOUTCOMMIT4args that might possibly be useful
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
>>> But, I do not see laycommit at all. In terms data written by client
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
>>> To unsubscribe from this list: send the line "unsubscribe linux-nfs"
>>> in
>>> the body of a message to majordomo@...
>>> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>>
>> --
>> To unsubscribe from this list: send the line "unsubscribe linux- 
>> nfs" in
>> the body of a message to majordomo@...
>> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>>
>>
>
>
>
>
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs"  
> in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html


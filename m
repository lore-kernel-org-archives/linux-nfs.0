Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-px0-f174.google.com ([209.85.212.174]:44353 "EHLO
	mail-px0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753099Ab0GGRpY (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 7 Jul 2010 13:45:24 -0400
Received: by pxi14 with SMTP id 14so2768887pxi.19
        for <linux-nfs@vger.kernel.org>; Wed, 07 Jul 2010 10:45:24 -0700 (PDT)
Message-ID: <4C34BD52.7050606@gmail.com>
Date: Wed, 07 Jul 2010 10:45:54 -0700
From: Dean Hildebrand <seattleplus@gmail.com>
To: Trond Myklebust <Trond.Myklebust@netapp.com>
CC: Benny Halevy <bhalevy@panasas.com>, andros@netapp.com,
        linux-nfs@vger.kernel.org, Garth Gibson <garth@panasas.com>,
        Brent Welch <welch@panasas.com>, NFSv4 <nfsv4@ietf.org>
Subject: Re: [nfsv4] 4.1 client - LAYOUTCOMMIT & close
References: <A062FCC8662DA848949F7C3046B9BEAE01F3A6ED@us-email.terastack.bluearc.com>	<A062FCC8662DA848949F7C3046B9BEAE01F3A6EE@us-email.terastack.bluearc.com>	<6206CE0E-0A32-46A7-B648-3FCC12ED1961@netapp.com>	<B9A709F368FAAF4DB4B33870F72A141DFB88F3@CORPUSMX30A.corp.emc.com>	<0E2B1FE3-3B42-4BF2-BECE-A611DADF3983@netapp.com>	<B9A709F368FAAF4DB4B33870F72A141D01017F94@CORPUSMX30A.corp.emc.com>	<1278448834.16176.5.camel@heimdal.trondhjem.org>	<4C346D80.8010405@panasas.com>	<1278507985.2804.30.camel@heimdal.trondhjem.org>	<1278508696.2804.35.camel@heimdal.trondhjem.org>	<4C348679.6010507@panasas.com> <1278511416.2804.52.camel@heimdal.trondhjem.org>
In-Reply-To: <1278511416.2804.52.camel@heimdal.trondhjem.org>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0



On 7/7/2010 7:03 AM, Trond Myklebust wrote:
> On Wed, 2010-07-07 at 16:51 +0300, Benny Halevy wrote:
>    
>> On Jul. 07, 2010, 16:18 +0300, Trond Myklebust<Trond.Myklebust@netapp.com>  wrote:
>>      
>>> On Wed, 2010-07-07 at 09:06 -0400, Trond Myklebust wrote:
>>>        
>>>> On Wed, 2010-07-07 at 15:05 +0300, Benny Halevy wrote:
>>>>          
>>>>> On Jul. 06, 2010, 23:40 +0300, Trond Myklebust<trond.myklebust@fys.uio.no>  wrote:
>>>>>            
>>>>>> On Tue, 2010-07-06 at 15:20 -0400, Daniel.Muntz@emc.com wrote:
>>>>>>              
>>>>>>> The COMMIT to the DS, ttbomk, commits data on the DS.  I see it as
>>>>>>> orthogonal to updating the metadata on the MDS (but perhaps I'm wrong).
>>>>>>> As sjoshi@bluearc mentioned, the LAYOUTCOMMIT provides a synchronization
>>>>>>> point, so even if the non-clustered server does not want to update
>>>>>>> metadata on every DS I/O, the LAYOUTCOMMIT could also be a trigger to
>>>>>>> execute whatever synchronization mechanism the implementer wishes to put
>>>>>>> in the control protocol.
>>>>>>>                
>>>>>> As far as I'm aware, there are no exceptions in RFC5661 that would allow
>>>>>> pNFS servers to break the rule that any visible change to the data must
>>>>>> be atomically accompanied with a change attribute update.
>>>>>>
>>>>>>              
>>>>> Trond, I'm not sure how this rule you mentioned is specified.
>>>>>
>>>>> See more in section 12.5.4 and 12.5.4.1. LAYOUTCOMMIT and change/time_modify
>>>>> in particular:
>>>>>
>>>>>     For some layout protocols, the storage device is able to notify the
>>>>>     metadata server of the occurrence of an I/O; as a result, the change
>>>>>     and time_modify attributes may be updated at the metadata server.
>>>>>     For a metadata server that is capable of monitoring updates to the
>>>>>     change and time_modify attributes, LAYOUTCOMMIT processing is not
>>>>>     required to update the change attribute.  In this case, the metadata
>>>>>     server must ensure that no further update to the data has occurred
>>>>>     since the last update of the attributes; file-based protocols may
>>>>>     have enough information to make this determination or may update the
>>>>>     change attribute upon each file modification.  This also applies for
>>>>>     the time_modify attribute.  If the server implementation is able to
>>>>>     determine that the file has not been modified since the last
>>>>>     time_modify update, the server need not update time_modify at
>>>>>     LAYOUTCOMMIT.  At LAYOUTCOMMIT completion, the updated attributes
>>>>>     should be visible if that file was modified since the latest previous
>>>>>     LAYOUTCOMMIT or LAYOUTGET
>>>>>            
>>>> I know. However the above paragraph does not state that the server
>>>> should make those changes visible to clients other than the one that is
>>>> writing.
>>>>
>>>> Section 18.32.4 states that writes will cause the time_modified and
>>>> change attributes to be updated (if and only if the file data is
>>>> modified). Several other sections rely on this behaviour, including
>>>> section 10.3.1, section 11.7.2.2, and section 11.7.7.
>>>>
>>>> The only 'special behaviour' that I see allowed for pNFS is in section
>>>> 13.10, which states that clients can't expect to see changes
>>>> immediately, but that they must be able to expect close-to-open
>>>> semantics to work. Again, if this is to be the case, then the server
>>>> _must_ be able to deal with the case where client 1 dies before it can
>>>> issue the LAYOUTCOMMIT.
>>>>          
>> Agreed.
>>
>>      
>>>>
>>>>          
>>>>>> As I see it, if your server allows one client to read data that may have
>>>>>> been modified by another client that holds a WRITE layout for that range
>>>>>> then (since that is a visible data change) it should provide a change
>>>>>> attribute update irrespective of whether or not a LAYOUTCOMMIT has been
>>>>>> sent.
>>>>>>              
>>>>> the requirement for the server in WRITE's implementation section
>>>>> is quite weak: "It is assumed that the act of writing data to a file will
>>>>> cause the time_modified and change attributes of the file to be updated."
>>>>>
>>>>> The difference here is that for pNFS the written data is not guaranteed
>>>>> to be visible until LAYOUTCOMMIT.  In a broader sense, assuming the clients
>>>>> are caching dirty data and use a write-behind cache, application-written data
>>>>> may be visible to other processes on the same host but not to others until
>>>>> fsync() or close() - open-to-close semantics are the only thing the client
>>>>> guarantees, right?  Issuing LAYOUTCOMMIT on fsync() and close() ensure the
>>>>> data is committed to stable storage and is visible to all other clients in
>>>>> the cluster.
>>>>>            
>>>> See above. I'm not disputing your statement that 'the written data is
>>>> not guaranteed to be visible until LAYOUTCOMMIT'. I am disputing an
>>>> assumption that 'the written data may be visible without an accompanying
>>>> change attribute update'.
>>>>          
>>>
>>> In other words, I'd expect the following scenario to give the same
>>> results in NFSv4.1 w/pNFS as it does in NFSv4:
>>>        
>> That's a strong requirement that may limit the scalability of the server.
>>
>> The spirit of the pNFS operations, at least from Panasas perspective was that
>> the data is transient until LAYOUTCOMMIT, meaning it may or may not be visible
>> to clients other than the one who wrote it, and its associated metadata MUST
>> be updated and describe the new data only on LAYOUTCOMMIT and until then it's
>> undefined, i.e. it's up to the server implementation whether to update it or not.
>>
>> Without locking, what do the stronger semantics buy you?
>> Even if a client verified the change_attribute new data may become visible
>> at any time after the GETATTR if the file/byte range aren't locked.
>>      
> There is no locking needed in the scenario below: it is ordinary
> close-to-open semantics.
>
> The point is that if you remove the one and only way that clients have
> to determine whether or not their data caches are valid, then they can
> no longer cache data at all, and server scalability will be shot to
> smithereens anyway.
>    

It would seem that when the change_attr is changed depends on the server 
implementation.  If the
server implementation promises NOT to modify the file in place on a 
write, then it can postpone
updating the change_attr until LAYOUTCOMMIT (at which time the actual 
file data is updated).  If
not, meaning that if client 1 can see the write by client 2 in the 
example below, then the change_attr
should be updated on every write (I would guess it would only be updated 
when some server actually
requested it)
Dean
> Trond
>
>    
>> Benny
>>
>>      
>>> Client 1			Client 2
>>> ========			========
>>>
>>> OPEN foo
>>> READ
>>> CLOSE
>>> 				OPEN
>>> 				LAYOUTGET ...
>>> 				WRITE via DS
>>> 				<dies>...
>>> OPEN foo
>>> verify change_attr
>>> READ if above WRITE is visible
>>> CLOSE
>>>
>>> Trond
>>> _______________________________________________
>>> nfsv4 mailing list
>>> nfsv4@ietf.org
>>> https://www.ietf.org/mailman/listinfo/nfsv4
>>>        
>
> _______________________________________________
> nfsv4 mailing list
> nfsv4@ietf.org
> https://www.ietf.org/mailman/listinfo/nfsv4
>    

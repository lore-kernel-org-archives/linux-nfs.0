From: wengang wang <wen.gang.wang@oracle.com>
Subject: Re: [PATCH 1/1] nfsd(v2/v3): fix the failure of creation from HPUX
 client
Date: Wed, 24 Dec 2008 17:43:06 +0800
Message-ID: <4952042A.4080800@oracle.com>
References: <200812240537.mBO5blpr005502@acsinet13.oracle.com> <4951E169.40809@suse.de> <4951EF80.1050209@oracle.com> <4951FE14.9010504@suse.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Cc: linux-nfs@vger.kernel.org
To: Suresh Jayaraman <sjayaraman@suse.de>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from acsinet12.oracle.com ([141.146.126.234]:19353 "EHLO
	acsinet12.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751549AbYLXJoP (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 24 Dec 2008 04:44:15 -0500
In-Reply-To: <4951FE14.9010504@suse.de>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Suresh Jayaraman wrote:
> wengang wang wrote:
>   
>> Suresh Jayaraman wrote:
>>     
>>> wengang wang wrote:
>>>  
>>>       
>>>> sometimes HPUX nfs client sends a create request to linux nfs
>>>> server(v2/v3).
>>>> the dump of the request is like:
>>>>     obj_attributes
>>>>         mode: value follows
>>>>             set_it: value follows (1)
>>>>             mode: 00
>>>>         uid: no value
>>>>             set_it: no value (0)
>>>>         gid: value follows
>>>>             set_it: value follows (1)
>>>>             gid: 8030
>>>>         size: value follows
>>>>             set_it: value follows (1)
>>>>             size: 0
>>>>         atime: don't change
>>>>             set_it: don't change (0)
>>>>         mtime: don't change
>>>>             set_it: don't change (0)
>>>>
>>>> note that mode is 00(havs no rwx privilege even for the owner) and it
>>>> requires
>>>> to set size to 0.
>>>>     
>>>>         
>>> What's the Create Mode in this case? EXCLUSIVE or UNCHECKED?
>>>   
>>>       
>> it's UNCHECKED.
>>     
>>> What's the error the server is returning without this patch -
>>> ERR_NOTSUPP?
>>>
>>>   
>>>       
>> permission deny, that is NFS3ERR_ACCES.
>>     
>>> I tested this on 2.6.27.7 with a small program which does this:
>>>         fd = open("file", O_CREAT, 0000);
>>>
>>> The file creation succeeded with file size set to 0 and the subsequent
>>> chmod too.
>>>
>>>   
>>>       
>> tcpdump available for your test?
>> just after the creation, is the file mode 0000?
>>     
>
> Here are the relevant packets (both server and client are running 2.6.27.7)
>
>
>   
<snip>
> Network File System, CREATE Call DH:0x83dc449c/myfile Mode:UNCHECKED
>     [Program Version: 3]
>     [V3 Procedure: CREATE (8)]
>     where
>         dir
>         Name: myfile
>     Create Mode: UNCHECKED (0)
>     obj_attributes
>         mode: value follows
>             set_it: value follows (1)
>             mode: 00
>                 0... .... .... = not SUID
>                 .0.. .... .... = not SGID
>                 ..0. .... .... = not save swapped text
>                 ...0 .... .... = no Read permission for owner
>                 .... 0... .... = no Write permission for owner
>                 .... .0.. .... = no Execute permission for owner
>                 .... ..0. .... = no Read permission for group
>                 .... ...0 .... = no Write permission for group
>                 .... .... 0... = no Execute permission for group
>                 .... .... .0.. = no Read permission for others
>                 .... .... ..0. = no Write permission for others
>                 .... .... ...0 = no Execute permission for others
>         uid: no value
>         gid: no value
>         size: no value
>   
Here is the difference, hpux request to set size to 0.

        size: value follows
            set_it: value follows (1)
            size: 0

changing size(no matter the new size is equal to old size or not) needs 
WRITE privilege.
For specific file systems that does permission check, such as gfs, they 
fails at permission
check (in the gfs case, generic_permission()). the patch I posted is 
based on "setting size
to it's original size is unnecessary".

Actually, I think the nfsd_create() should an "atomic" operation like 
create_with_attr(),
in which, we don't do permission check, instead of create() and then 
setattr().
but seems this needs lots of work. so I would like to take the above 
trick before the
create_with_attr() is out.

thanks,
wengang.

From: Dan Brunner <daniel.brunner@duni.com>
Subject: Re: nfs over tcp in linux kernel version 2.4.18
Date: Tue, 20 May 2003 14:30:29 -0500
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <8421832D-8AF9-11D7-93AF-00306589E6DA@duni.com>
References: <0D122719B1756A43AD405320EE3D8EFA01278C90@moneyb.alexa.com>
Mime-Version: 1.0 (Apple Message framework v552)
Content-Type: text/plain; charset=US-ASCII; format=flowed
Cc: davidmyer800@yahoo.com, nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from [65.168.147.194] (helo=mkeweb01.duni.com)
	by sc8-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 19ICrr-0002PG-00
	for <nfs@lists.sourceforge.net>; Tue, 20 May 2003 12:33:47 -0700
To: guolin@alexa.com
In-Reply-To: <0D122719B1756A43AD405320EE3D8EFA01278C90@moneyb.alexa.com>
Errors-To: nfs-admin@lists.sourceforge.net
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
List-Id: Discussion of NFS under Linux development,
	interoperability,
	and testing. <nfs.lists.sourceforge.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=nfs>

Guolin,

That DOES sound like a pain in the a$$!!!!!!!

And yes your right, not everyone has the same success...

Good Luck!!


Dan


On Tuesday, May 20, 2003, at 02:19  PM, guolin@alexa.com wrote:

> Dan,
>
>  try your luck.
>
>  BTW, let you know that I have to take the pain to reboot 400 Linux 
> boxes to
> get rid of "nfs over tcp" in our production environment.
>
>  --Guolin Cheng
>
> -----Original Message-----
> From: Dan Brunner [mailto:daniel.brunner@duni.com]
> Sent: Tuesday, May 20, 2003 12:14 PM
> To: Guolin Cheng
> Cc: davidmyer800@yahoo.com; nfs@lists.sourceforge.net
> Subject: Re: [NFS] nfs over tcp in linux kernel version 2.4.18
>
>
> Guolin,
>
> I can't seem to agree with this...
>
> Maybe I don't have that many connections (17), but I've been running
> NFS over TCP since 2.4.18. And I haven't had once MAJOR crash yet!! My
> clients however, are all Mac OS X clients. 10.0.4-10.2.6.
>
> Maybe that has something to do with it....
>
>
> And we don't get a lot of hangs either....
>
>
> later
>
>
> Dan
>
>
> On Tuesday, May 20, 2003, at 01:41  PM, guolin@alexa.com wrote:
>
>> David,
>>
>>  "nfs over tcp" is terribly unstable until now, I use version 2.4.20,
>> and
>> find that over 30 simultaneous nfs connection can kill an "nfs over
>> tcp"
>> Linux nfs server easily. let clients' processes hangs there forever.
>> But
>> this didn't happen for Linux nfs server enabling only "nfs over udp".
>>
>>  So the best choice now is totally disregard Linux "nfs over tcp" in
>> production environment. just try it in research environment.
>>
>>  Thanks.
>>  --Guolin Cheng
>>
>>
>> -----Original Message-----
>> From: David Myer [mailto:davidmyer800@yahoo.com]
>> Sent: Tuesday, May 20, 2003 11:03 AM
>> To: nfs@lists.sourceforge.net
>> Subject: [NFS] nfs over tcp in linux kernel version 2.4.18
>>
>>
>> Hi,
>>
>> Can anyone advise me if nfs server over tcp is
>> supported in 2.4.18 kernel version ? How to
>> setup/enable on both server/client side ? Tried to
>> looked at FAQ but information did not seem be there.
>>
>> Do I need to apply any patches ?
>>
>> Thanks
>> David
>>
>> __________________________________
>> Do you Yahoo!?
>> The New Yahoo! Search - Faster. Easier. Bingo.
>> http://search.yahoo.com
>>
>>
>> -------------------------------------------------------
>> This SF.net email is sponsored by: ObjectStore.
>> If flattening out C++ or Java code to make your application fit in a
>> relational database is painful, don't do it! Check out ObjectStore.
>> Now part of Progress Software. http://www.objectstore.net/sourceforge
>> _______________________________________________
>> NFS maillist  -  NFS@lists.sourceforge.net
>> https://lists.sourceforge.net/lists/listinfo/nfs
>>
>>
>> -------------------------------------------------------
>> This SF.net email is sponsored by: ObjectStore.
>> If flattening out C++ or Java code to make your application fit in a
>> relational database is painful, don't do it! Check out ObjectStore.
>> Now part of Progress Software. http://www.objectstore.net/sourceforge
>> _______________________________________________
>> NFS maillist  -  NFS@lists.sourceforge.net
>> https://lists.sourceforge.net/lists/listinfo/nfs



-------------------------------------------------------
This SF.net email is sponsored by: ObjectStore.
If flattening out C++ or Java code to make your application fit in a
relational database is painful, don't do it! Check out ObjectStore.
Now part of Progress Software. http://www.objectstore.net/sourceforge
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs

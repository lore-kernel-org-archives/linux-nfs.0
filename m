From: Peter Staubach <staubach@redhat.com>
Subject: Re: Re: [PATCH] Smooth out NFS client writeback
Date: Wed, 29 Jun 2005 11:07:48 -0400
Message-ID: <42C2B944.6090803@redhat.com>
References: <482A3FA0050D21419C269D13989C611307CF4CE6@lavender-fe.eng.netapp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Cc: Shantanu Goel <sgoel01@yahoo.com>,
	Trond Myklebust <trond.myklebust@fys.uio.no>,
	nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1DneE1-0003Sa-4S
	for nfs@lists.sourceforge.net; Wed, 29 Jun 2005 08:11:41 -0700
Received: from mx1.redhat.com ([66.187.233.31])
	by sc8-sf-mx1.sourceforge.net with esmtp (TLSv1:AES256-SHA:256)
	(Exim 4.41)
	id 1DneDz-0004ku-KH
	for nfs@lists.sourceforge.net; Wed, 29 Jun 2005 08:11:41 -0700
To: "Lever, Charles" <Charles.Lever@netapp.com>
In-Reply-To: <482A3FA0050D21419C269D13989C611307CF4CE6@lavender-fe.eng.netapp.com>
Sender: nfs-admin@lists.sourceforge.net
Errors-To: nfs-admin@lists.sourceforge.net
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Id: Discussion of NFS under Linux development,
	interoperability,
	and testing. <nfs.lists.sourceforge.net>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=nfs>

Lever, Charles wrote:

>hi peter-
>
>  
>
>>On Solaris, at least with UFS as the underlying file system, 
>>the COMMIT
>>operations are processed by looking through the entire cached 
>>page list
>>or by doing page lookup operations on each individual page.  
>>If the entire
>>file is specified, ie. len = 0, then the page list is walked. 
>> If a range
>>is specified, then just the pages within the range are looked up.
>>
>>Specifying the range can result in significantly less CPU 
>>overhead on the
>>server.  This is why the NFSv3 COMMIT operation has a range 
>>which can be specified...  :-)
>>    
>>
>
>a server CPU inefficiency hardly qualifies as a client bug.  in the most
>common cases where the client is creating and writing to a file, then
>closing with a COMMIT(0,0) request, the server should be changed to
>behave in a more efficient manner.
>
>in other words, i think the client should optimize the number of
>requests on the wire, and the server should optimize for using its CPU
>and disks most efficiently.  i haven't looked closely at shantanu's
>patch, but i'm a little leary of the change if it means more wire
>operations are generated than before.
>  
>

I wouldn't claim that this is a client side bug either.  I would claim that
it is an opportunity, for very little cost, to help a server to perform
better and this makes the client, and NFS in general, look better.

I don't think that there will be more over the wire operations generated
when using the range versus always specifying the entire file.  Typically,
COMMITs are done for a range of the file or for the entire file at close.
The client typically needs to know what data is marked as needing to be
committed anyway, so it isn't very hard to figure out what the range that
needs to be committed is at the same time.  I would claim that a client,
which simply issues a blanket COMMIT(0,0), without already having gathered
up the buffers/pages/whatever that need committing, is broken.  It will be
unsafe because it will be subject to races like more data getting written
with UNSTABLE while the COMMIT is happening.  This new data may or may not
have been committed by the COMMIT.

Bottom line for me -- if the client can do something to help the server to
help the client and it is an overall win, then I think that it should do 
so...

    Thanx...

       ps


-------------------------------------------------------
SF.Net email is sponsored by: Discover Easy Linux Migration Strategies
from IBM. Find simple to follow Roadmaps, straightforward articles,
informative Webcasts and more! Get everything you need to get up to
speed, fast. http://ads.osdn.com/?ad_id=7477&alloc_id=16492&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs

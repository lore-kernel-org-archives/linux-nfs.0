From: Peter Staubach <staubach@redhat.com>
Subject: Re: mtime not updated in client cache?
Date: Fri, 09 Dec 2005 16:05:29 -0500
Message-ID: <4399F199.60500@redhat.com>
References: <EXCHG2003JY4kJSFsxf000003dd@EXCHG2003.microtech-ks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Cc: "'Lever, Charles'" <Charles.Lever@netapp.com>,
	nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91] helo=mail.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1EkpR1-0000PX-Ef
	for nfs@lists.sourceforge.net; Fri, 09 Dec 2005 13:05:43 -0800
Received: from mx1.redhat.com ([66.187.233.31])
	by mail.sourceforge.net with esmtp (Exim 4.44)
	id 1EkpR0-0003NE-2K
	for nfs@lists.sourceforge.net; Fri, 09 Dec 2005 13:05:43 -0800
To: Roger Heflin <rheflin@atipa.com>
In-Reply-To: <EXCHG2003JY4kJSFsxf000003dd@EXCHG2003.microtech-ks.com>
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

Roger Heflin wrote:

> 
>
>  
>
>>-----Original Message-----
>>From: nfs-admin@lists.sourceforge.net 
>>[mailto:nfs-admin@lists.sourceforge.net] On Behalf Of Peter Staubach
>>Sent: Friday, December 09, 2005 1:20 PM
>>To: Lever, Charles
>>Cc: nfs@lists.sourceforge.net
>>Subject: Re: [NFS] mtime not updated in client cache?
>>
>>Lever, Charles wrote:
>>
>>    
>>
>>>risks understood.
>>>
>>>however, how is this different from ext3?  a close() on an ext3 file 
>>>doesn't even attempt to schedule a flush of the data to 
>>>      
>>>
>>disk.  if the 
>>    
>>
>>>system crashes or the disk dies or the file system fills up, 
>>>      
>>>
>>the data 
>>    
>>
>>>is lost, just like in the NFS case.
>>> 
>>>
>>>      
>>>
>>I think that the difference is that a system crash also 
>>terminates the application and there is just more visibility 
>>into what happened.
>>    
>>
>
>On a local machine, the application can complete successfully, 
>and the data won't be written out for up to 30 seconds, and this
>can be higher on machines that have huge amounts of ram, and can
>hold a lot more in its write cache, so data can be
>lost even after the program completes properly if the machine crashes
>before the writes are finished.
>
>If you get a hard scsi/disk error when writing data from local cache, there
>is not a process to return that error to the program that generated
>the data assuming that the program is even still running.
>

Right.  But the difference is that these things are visible on the system.
The user can know that there may be a problem.  If such a thing happens on
the NFS server, without the client's knowledge, then there is no way of
telling why the data is not there, just that it is not.

    Thanx...

       ps


-------------------------------------------------------
This SF.net email is sponsored by: Splunk Inc. Do you grep through log files
for problems?  Stop!  Download the new AJAX search engine that makes
searching your log files as easy as surfing the  web.  DOWNLOAD SPLUNK!
http://ads.osdn.com/?ad_id=7637&alloc_id=16865&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs

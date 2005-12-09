From: Peter Staubach <staubach@redhat.com>
Subject: Re: mtime not updated in client cache?
Date: Fri, 09 Dec 2005 14:20:28 -0500
Message-ID: <4399D8FC.1020400@redhat.com>
References: <044B81DE141D7443BCE91E8F44B3C1E201332866@exsvl02.hq.netapp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92] helo=mail.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1EknnD-0008U3-CM
	for nfs@lists.sourceforge.net; Fri, 09 Dec 2005 11:20:31 -0800
Received: from mx1.redhat.com ([66.187.233.31])
	by mail.sourceforge.net with esmtp (Exim 4.44)
	id 1EknnB-0008Nn-Oc
	for nfs@lists.sourceforge.net; Fri, 09 Dec 2005 11:20:31 -0800
To: "Lever, Charles" <Charles.Lever@netapp.com>
In-Reply-To: <044B81DE141D7443BCE91E8F44B3C1E201332866@exsvl02.hq.netapp.com>
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

>
>risks understood.
>
>however, how is this different from ext3?  a close() on an ext3 file
>doesn't even attempt to schedule a flush of the data to disk.  if the
>system crashes or the disk dies or the file system fills up, the data is
>lost, just like in the NFS case.
>  
>

I think that the difference is that a system crash also terminates the
application and there is just more visibility into what happened.

>in addition, mapped dirty data is never flushed on close() on NFS.  what
>happens if a server failure pins dirty mapped pages in the client's
>memory?
>
>  
>

Actually, I think that part of close-to-open processing should be write
out dirty pages on munmap.

>if an application really wants the guarantee that the data is
>permanently stored or have the opportunity to recover if an error
>occurs, it will use O_SYNC or msync() or fflush() before closing the
>file.
>
>  
>

True.  An intermediate position has been to pay attention to system call
return values, including that from close(2), and pass them along to the
user to figure out what to do.

>to make a more philosophical argument, UNIX has always compromised data
>integrity for performance in the common case.  for example, why aren't
>there more file systems around that provide ACID semantics?  because in
>99.9% of cases, ACID semantics are simply not required, and just slow
>everything else down.
>
>i think this is reasonable behavior to enable with either a mount option
>or a sysctl.  we have "nocto," after all.
>
>  
>

I think that "nocto" was invented to be able to optimize situations where it
was known that a specific client was the _only_ client accessing those 
files.
Thus, close-to-open consistency was not required.

I've wondered about the real performance advantage though.  I've never
seen it measured in a believeable way.

>i'm not trying to start an argument.  just wondering aloud.
>  
>

I am happy to have the discussion, but it feels to me like a very dangerous
area to venture into.  Several times, I thought about trying to do this,
but each time stopped because I wasn't comfortable with the possibility
of silent data loss.

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

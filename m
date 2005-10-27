From: Peter Staubach <staubach@redhat.com>
Subject: Re: Data coherency trouble	with	multiple	clients,	on2.6.14-rc5
Date: Thu, 27 Oct 2005 08:25:29 -0400
Message-ID: <4360C739.5010403@redhat.com>
References: <044B81DE141D7443BCE91E8F44B3C1E288E5A5@exsvl02.hq.netapp.com>	 <1130345451.8852.7.camel@lade.trondhjem.org> <435FCECF.2090800@redhat.com>	 <1130353693.8859.21.camel@lade.trondhjem.org> <435FDEA9.5060706@redhat.com>	 <1130360742.8859.56.camel@lade.trondhjem.org> <435FF3B1.5030200@redhat.com> <1130363854.8956.23.camel@lade.trondhjem.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Cc: "Lever, Charles" <Charles.Lever@netapp.com>,
	Charles Duffy <ccd@mailcall.com.au>, nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91] helo=mail.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1EV6pF-0005it-1d
	for nfs@lists.sourceforge.net; Thu, 27 Oct 2005 05:25:45 -0700
Received: from mx1.redhat.com ([66.187.233.31])
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44)
	id 1EV6pD-0004fy-QG
	for nfs@lists.sourceforge.net; Thu, 27 Oct 2005 05:25:44 -0700
To: Trond Myklebust <trond.myklebust@fys.uio.no>
In-Reply-To: <1130363854.8956.23.camel@lade.trondhjem.org>
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

Trond Myklebust wrote:

>on den 26.10.2005 klokka 17:22 (-0400) skreiv Peter Staubach:
>
>  
>
>>I would say that it is better to be safe and then fast.  Some cache
>>invalidations for false positives are better than missing some which
>>were required.
>>    
>>
>
>That really does depend on the application. For many setups caching is
>vital to ensure scalability on the server side. For instance, someone
>running an HPC cluster for an animation studio may be willing to
>tolerate the odd caching error if that means running more clients per
>server.
>  
>

True, although there are other mechanisms such as nocto and increasing the
attribute cache timeouts to reduce the over the wire traffic.  I would
suspect that those folks would not knowingly agree to a system which allowed
known cache inconsistencies, unless they themselves had configured the
system to do so.


>  
>
>>>NFSv2 and NFSv4 don't even have support for WCC, so your detection
>>>scheme ends up being very dependent on one particular version of NFS.
>>>
>>> 
>>>
>>>      
>>>
>>Actually NFSv4 does have an attribute that the client can use, doesn't it?
>>Something like change_attr or some such?
>>    
>>
>
>The NFSv4 change attribute may be returned atomically for some
>operations (mainly those that modify a directory, such as CREATE,
>OPEN,...).
>Unfortunately it is not returned atomically for the case of the WRITE
>operation.
>
>  
>

Unfortunate.  I guess that we could hope for delegations with callback
support to provide the stronger consistency in certain situations and
configurations.

>>The write reordering issue only exists for multiple concurrent operations
>>such as WRITE operations.  I will agree, that if the wcc_data for WRITE
>>operations is used, then many false positives will probably occur.  However,
>>useful and valid cache validations can be done using GETATTR or other
>>operations such as ACCESS or LOOKUP, even while a file is open for writing.
>>    
>>
>
>Agreed, and I am willing to relax the current restrictions for those
>cases (in fact I happen to be testing the patch for that today).
>That will not, however, suffice to ensure that the cache on any given
>NFS client will never return stale data when you set the "noac" mount
>flag.
>
>  
>

Very true.  There is no guarantee that the NFS client, except perhaps for
NFSv4, will be completely consistent.  It can probably be made "close
enough" for many applications, but never totally consistent.  There is
always that window in between looking to see if the file has changed and
then using the cached information.

>>>Basically, what I'm saying is that as long as we cannot implement the
>>>above ideal, we should not be issuing promises to application developers
>>>that they can rely on it. O_DIRECT was specifically developed in order
>>>to give database implementers a reliable uncached I/O interface, and so
>>>that is what we should direct them towards.
>>>The worst thing to do when someone asks IMHO is to reply that "we can
>>>almost but not quite fix noac".
>>>
>>>      
>>>
>>O_DIRECT is pretty much only useful to the database folks because of the
>>lack of readahead and write behind which kills performance.  They can
>>utilize O_DIRECT because they use multiple contexts or AIO to issue the
>>i/o requests.
>>    
>>
>
>So who else out there really needs the ability to have multiple readers
>and writers per file without using locking?
>I'm not asking rhetorically... I actually do need to knock up a
>presentation on this particular topic over the course of the next week.
>
>  
>

The case of read-ahead and write-behind are the most common cases that I
can think of.  It is the write-behind case which causes the most potential
"false positive" cases in NFS implementations that I have seen.

These are, of course, not visible to the application.

I guess that there is always things like log files, with append mode
writes, but I don't think that anyone has really figured out to make
append mode work right yet.

>>The application developers are already aware of the loose cache consistency
>>that NFS offers.  This is not a reason to loosen it further though.  We
>>can and should do the best job that we can.  We have to make some 
>>assumptions
>>about how well NFS servers implement the correct semantics.  If an NFS
>>server is truly broken, then let's get that NFS server fixed.  Avoiding
>>useful semantics because some servers in the market may not get them
>>right seems self defeating to me and just futhers the myth that NFS is
>>not useful as a distributed file system.
>>    
>>
>
>I am not opposed to strengthening the NFS cache consistency. I just want
>to ensure that we have clearly articulated rules that developers can
>rely upon.
>
>See my recent proposal for NFSv4 "byte range delegations" at the IETF
>RFC website. If people want NFS to have full posix cache semantics, then
>we can certainly add that capability. ;-)
>

I'll have to take a closer look.  Is this a performance thing over the
normal whole file delegations?

    Thanx...

       ps


-------------------------------------------------------
This SF.Net email is sponsored by the JBoss Inc.
Get Certified Today * Register for a JBoss Training Course
Free Certification Exam for All Training Attendees Through End of 2005
Visit http://www.jboss.com/services/certification for more information
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs

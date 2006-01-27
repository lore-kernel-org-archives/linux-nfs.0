From: Peter Staubach <staubach@redhat.com>
Subject: Re: NFS dentry caching mechanism
Date: Fri, 27 Jan 2006 13:20:54 -0500
Message-ID: <43DA6486.9090403@redhat.com>
References: <OFE1F20AE4.839B09EC-ON87257102.007A50EE-88257102.007C7D01@us.ibm.com>	 <1138317247.8770.39.camel@lade.trondhjem.org> <43DA2240.2090900@redhat.com>	 <1138369456.8712.14.camel@lade.trondhjem.org> <43DA24D3.3090400@redhat.com>	 <1138371965.8712.30.camel@lade.trondhjem.org> <43DA3180.7010807@redhat.com>	 <1138374819.8712.53.camel@lade.trondhjem.org> <43DA3E0D.70007@redhat.com> <1138381997.8708.21.camel@lade.trondhjem.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Cc: uketinen@us.ibm.com, nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92] helo=mail.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1F2YDd-00018T-Sp
	for nfs@lists.sourceforge.net; Fri, 27 Jan 2006 10:21:09 -0800
Received: from mx1.redhat.com ([66.187.233.31])
	by mail.sourceforge.net with esmtp (Exim 4.44)
	id 1F2YDZ-0005vi-58
	for nfs@lists.sourceforge.net; Fri, 27 Jan 2006 10:21:06 -0800
To: Trond Myklebust <trond.myklebust@fys.uio.no>
In-Reply-To: <1138381997.8708.21.camel@lade.trondhjem.org>
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

>
>Note that the strong cache validation your describe also relies heavily
>on the mtime accuracy on the server. A typical exported ext3 or reiserfs
>filesystem will still fail for the distributed make case since it has an
>mtime resolution of 1 second.
>
>  
>

True.  I don't believe that the client is the right place to work around
such a problem with a server though.  We should get the server fixed, or
in this case, any relevant local file systems fixed so that they support
the required semantics.  There are lots of NFS servers in the world which
do not have this issue.

I know that fixing/changing these file systems will be difficult, but
as they are, they don't make for very good NFS server service.

>>>Operations such as RMDIR and unlink() do have a race, but in the case
>>>where you have one client creating a directory and another client
>>>destroying it, there will always be a race unless you have some method
>>>of synchronisation between the processes on the clients.
>>>
>>>There is a potential caching race if you try to open the file, but that
>>>is (as I said previously) quite intentional: it is done for scalability
>>>reasons.
>>>
>>> 
>>>
>>>      
>>>
>>I don't think that I understand this last paragraph.  Does this mean that
>>the consistency was purposefully relaxed in order to increase performance?
>>    
>>
>
>Not performance as such, but scalability. Both the server and network
>suffer in the case where you have nfsroot clients flooding the system
>with GETATTR requests in order to revalidate negative dentries. Consider
>for instance at all the little shared libraries, config files, and other
>junk that a typical GNOME or KDE desktop login involves, and you'll know
>what I mean. The difference between negative dentry caching and not is
>very significant in those cases, and so we were seeing some nasty
>network floods in the early 2.4 series when it was briefly turned off.
>
>I am basically very wary of increasing the number of GETATTR calls:
>we're already seeing a large number of HPC sites complaining about the
>scalability problems those cause on their servers, and asking for a
>reduction in the number of unnecessary revalidations (particularly so
>for 2.6 kernels).
>

I agree completely.  It in the decision making for "unnecessary" where
the issue lie.  It is very easy to go too far and relax the consistency
too much or go too far in the other direction and end up with the extra
over the wire round trips for little or no gain.

    Thanx...

       ps


-------------------------------------------------------
This SF.net email is sponsored by: Splunk Inc. Do you grep through log files
for problems?  Stop!  Download the new AJAX search engine that makes
searching your log files as easy as surfing the  web.  DOWNLOAD SPLUNK!
http://sel.as-us.falkag.net/sel?cmd=lnk&kid=103432&bid=230486&dat=121642
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs

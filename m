From: Peter Staubach <staubach@redhat.com>
Subject: Re: NFS dentry caching mechanism
Date: Fri, 27 Jan 2006 08:49:07 -0500
Message-ID: <43DA24D3.3090400@redhat.com>
References: <OFE1F20AE4.839B09EC-ON87257102.007A50EE-88257102.007C7D01@us.ibm.com>	 <1138317247.8770.39.camel@lade.trondhjem.org> <43DA2240.2090900@redhat.com> <1138369456.8712.14.camel@lade.trondhjem.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Cc: uketinen@us.ibm.com, nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92] helo=mail.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1F2TyX-0003Hw-4B
	for nfs@lists.sourceforge.net; Fri, 27 Jan 2006 05:49:17 -0800
Received: from mx1.redhat.com ([66.187.233.31])
	by mail.sourceforge.net with esmtp (Exim 4.44)
	id 1F2TyV-0001CR-VU
	for nfs@lists.sourceforge.net; Fri, 27 Jan 2006 05:49:17 -0800
To: Trond Myklebust <trond.myklebust@fys.uio.no>
In-Reply-To: <1138369456.8712.14.camel@lade.trondhjem.org>
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

>On Fri, 2006-01-27 at 08:38 -0500, Peter Staubach wrote:
>
>  
>
>>For systems which are based on the ONC+ code (Ie. Solaris), on write-able
>>file systems, the negative cache entries are _always_ validated using a
>>forced over the wire GETATTR operation.  Read-only file systems are
>>treated slightly differently by using the normal attribute cache mechanism
>>to do the validation.  This keeps the client from falling into this trap.
>>
>>It is okay for the client to think that a file exists which may not, because
>>it can detect the difference.  It is not okay for a client to decide that a
>>file does not exist without a strong validation mechanism because there is
>>no way for the application to determine otherwise.
>>    
>>
>
>That makes negative dentries more or less worthless: if you are going to
>force a GETATTR call every time, you might as well do a full lookup.
>
>  
>

Well, the need for the stronger consistency in this case reduces the
performance benefits, but does not eliminate them.  A GETATTR will
always be cheaper than a LOOKUP, especially one that will mostly
likely return ENOENT.

>We revalidate the parent directory (following the standard attribute
>caching rules - no forced GETATTR). If the parent directory has changed,
>we drop the negative dentry, and force a new lookup.
>

And this leads to the unacceptable problem that a correctly written
application may not work because of this cache.

Correctness first, then performance.

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

From: Peter Staubach <staubach@redhat.com>
Subject: Re: NFS dentry caching mechanism
Date: Fri, 27 Jan 2006 09:43:12 -0500
Message-ID: <43DA3180.7010807@redhat.com>
References: <OFE1F20AE4.839B09EC-ON87257102.007A50EE-88257102.007C7D01@us.ibm.com>	 <1138317247.8770.39.camel@lade.trondhjem.org> <43DA2240.2090900@redhat.com>	 <1138369456.8712.14.camel@lade.trondhjem.org> <43DA24D3.3090400@redhat.com> <1138371965.8712.30.camel@lade.trondhjem.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Cc: uketinen@us.ibm.com, nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92] helo=mail.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1F2Uoq-0007i9-4b
	for nfs@lists.sourceforge.net; Fri, 27 Jan 2006 06:43:20 -0800
Received: from mx1.redhat.com ([66.187.233.31])
	by mail.sourceforge.net with esmtp (Exim 4.44)
	id 1F2Uop-00060F-Sl
	for nfs@lists.sourceforge.net; Fri, 27 Jan 2006 06:43:20 -0800
To: Trond Myklebust <trond.myklebust@fys.uio.no>
In-Reply-To: <1138371965.8712.30.camel@lade.trondhjem.org>
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

>On Fri, 2006-01-27 at 08:49 -0500, Peter Staubach wrote:
>  
>
>>Well, the need for the stronger consistency in this case reduces the
>>performance benefits, but does not eliminate them.  A GETATTR will
>>always be cheaper than a LOOKUP, especially one that will mostly
>>likely return ENOENT.
>>    
>>
>
>This is still unacceptable: it leads to whole truckloads of unnecessary
>forced GETATTR calls on something like an nfsroot system, where $PATH
>and $LD_LIBRARY_PATH need to be explored every single time the user
>types in a command.
>You appeared to imply that the read-only filesystem case was treated
>differently on Solaris, but that sucks too: a read-only flag just means
>that _you_ can't modify the filesystem, not that others can't.
>
>  
>

With no negative cache, you get LOOKUP operations which are most likely
all going to fail.  With the negative cache, you can trade these failed
LOOKUP operations for GETATTR operations for a net win in CPU on both
the client and the server and also in network utilization because the
GETATTR requests and responses are smaller than the LOOKUP requests and
responses.  You can also retain the consistency semantics to be as
correct as possible.

Read-only file systems are treated differently because it seems a
fairly safe assumption that a file system which is read-only to a client
is probably changing slowly and thus, the normal attribute caching
mechanism is probably sufficient.

If only we knew that a file system was read-only throughout the entire
path and then we could eliminate all of the consistency checks...  :-)

>Furthermore, in cases such as the one that Usha describes, we don't
>actually _care_ about revalidating a negative dentry and/or looking up a
>new dentry. Do it using intents, and you can probably skip all the crap
>in nfs_lookup_revalidate+nfs_lookup: after all you need in order to send
>a valid RMDIR command is the filehandle of the parent, and a name.
>

Well, yes, this would address this one particular aspect, but does not solve
the more general problem.  Bad things can occur when the kernel tells an
application that a file does not exist, when it truly does.  This is bad
because the application can not discover the difference.  Telling an
application that a file does exist when it does not is not quite so bad
because the application can discover the difference.

This situation could be addressed as described, but I suspect that we just
end up in the next situation and eventually needing to fix the problem for
real.

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

From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: NFS dentry caching mechanism
Date: Fri, 27 Jan 2006 10:13:39 -0500
Message-ID: <1138374819.8712.53.camel@lade.trondhjem.org>
References: <OFE1F20AE4.839B09EC-ON87257102.007A50EE-88257102.007C7D01@us.ibm.com>
	 <1138317247.8770.39.camel@lade.trondhjem.org> <43DA2240.2090900@redhat.com>
	 <1138369456.8712.14.camel@lade.trondhjem.org> <43DA24D3.3090400@redhat.com>
	 <1138371965.8712.30.camel@lade.trondhjem.org> <43DA3180.7010807@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: uketinen@us.ibm.com, nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91] helo=mail.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1F2VIg-00023d-6E
	for nfs@lists.sourceforge.net; Fri, 27 Jan 2006 07:14:10 -0800
Received: from pat.uio.no ([129.240.130.16] ident=7411)
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44)
	id 1F2VIa-00048r-VW
	for nfs@lists.sourceforge.net; Fri, 27 Jan 2006 07:14:07 -0800
To: Peter Staubach <staubach@redhat.com>
In-Reply-To: <43DA3180.7010807@redhat.com>
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

On Fri, 2006-01-27 at 09:43 -0500, Peter Staubach wrote:
> With no negative cache, you get LOOKUP operations which are most likely
> all going to fail.  With the negative cache, you can trade these failed
> LOOKUP operations for GETATTR operations for a net win in CPU on both
> the client and the server and also in network utilization because the
> GETATTR requests and responses are smaller than the LOOKUP requests and
> responses.  You can also retain the consistency semantics to be as
> correct as possible.

On a Linux server, the lookup and getattr have roughly the same overhead
since the server has to set up dentries for them.

> Read-only file systems are treated differently because it seems a
> fairly safe assumption that a file system which is read-only to a client
> is probably changing slowly and thus, the normal attribute caching
> mechanism is probably sufficient.
> 
> If only we knew that a file system was read-only throughout the entire
> path and then we could eliminate all of the consistency checks...  :-)

The v4.1 draft w/ the spec for directory delegations is approaching
final form.

> >Furthermore, in cases such as the one that Usha describes, we don't
> >actually _care_ about revalidating a negative dentry and/or looking up a
> >new dentry. Do it using intents, and you can probably skip all the crap
> >in nfs_lookup_revalidate+nfs_lookup: after all you need in order to send
> >a valid RMDIR command is the filehandle of the parent, and a name.
> >
> 
> Well, yes, this would address this one particular aspect, but does not solve
> the more general problem.  Bad things can occur when the kernel tells an
> application that a file does not exist, when it truly does.  This is bad
> because the application can not discover the difference.  Telling an
> application that a file does exist when it does not is not quite so bad
> because the application can discover the difference.

I'm not sure I understand what you mean here. We have exclusive create
semantics on most operations that need them, so the application can
definitely discover the difference in those cases.

Operations such as RMDIR and unlink() do have a race, but in the case
where you have one client creating a directory and another client
destroying it, there will always be a race unless you have some method
of synchronisation between the processes on the clients.

There is a potential caching race if you try to open the file, but that
is (as I said previously) quite intentional: it is done for scalability
reasons.

> This situation could be addressed as described, but I suspect that we just
> end up in the next situation and eventually needing to fix the problem for
> real.

Note that we already use intents in order to eliminate the need for
negative dentry validation for the case of O_EXCL opens. We could
probably do the same for mkdir(), symlink() and link() (for the case of
the target). That would fix the issue where you do have some method of
synchronisation between the clients.

Cheers,
  Trond



-------------------------------------------------------
This SF.net email is sponsored by: Splunk Inc. Do you grep through log files
for problems?  Stop!  Download the new AJAX search engine that makes
searching your log files as easy as surfing the  web.  DOWNLOAD SPLUNK!
http://sel.as-us.falkag.net/sel?cmd=lnk&kid=103432&bid=230486&dat=121642
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs

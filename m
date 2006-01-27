From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: NFS dentry caching mechanism
Date: Fri, 27 Jan 2006 12:13:17 -0500
Message-ID: <1138381997.8708.21.camel@lade.trondhjem.org>
References: <OFE1F20AE4.839B09EC-ON87257102.007A50EE-88257102.007C7D01@us.ibm.com>
	 <1138317247.8770.39.camel@lade.trondhjem.org> <43DA2240.2090900@redhat.com>
	 <1138369456.8712.14.camel@lade.trondhjem.org> <43DA24D3.3090400@redhat.com>
	 <1138371965.8712.30.camel@lade.trondhjem.org> <43DA3180.7010807@redhat.com>
	 <1138374819.8712.53.camel@lade.trondhjem.org> <43DA3E0D.70007@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: uketinen@us.ibm.com, nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91] helo=mail.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1F2XAH-0003tG-Er
	for nfs@lists.sourceforge.net; Fri, 27 Jan 2006 09:13:37 -0800
Received: from pat.uio.no ([129.240.130.16] ident=7411)
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44)
	id 1F2XAG-0004oI-Ok
	for nfs@lists.sourceforge.net; Fri, 27 Jan 2006 09:13:37 -0800
To: Peter Staubach <staubach@redhat.com>
In-Reply-To: <43DA3E0D.70007@redhat.com>
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

On Fri, 2006-01-27 at 10:36 -0500, Peter Staubach wrote:

> The situation that I usually think of can be something like a software
> development environment which uses a distributed make scheme to use
> multiple machines to build.  All machines in the environment use NFS to
> mount the source and build target spaces.
> 
> First, the master decides that it needs to build foo.o from foo.c.  It
> looks for the existence of foo.o, but it does not exist yet.  The NFS
> client on the master then creates a negative entry for foo.o.  The master
> then farms out a compile on one of the slave build servers.  This system
> compiles foo.c into foo.o and informs the master that the compile is done.
> The build process on the master then attempts to use foo.o, but because of
> the negative cache entry, is told that the file still does not exist.
> Oops.
> 
> With close-to-open consistency and no negative caching, this should work
> as expected.  With negative caching and strong cache validation on the
> negative entries, this should also work as expected.  With negative caching
> and the relaxed cache validation, then this probably won't work because the
> compile will probably be faster then the timeout value which controls the
> negative entries.

Note that the strong cache validation your describe also relies heavily
on the mtime accuracy on the server. A typical exported ext3 or reiserfs
filesystem will still fail for the distributed make case since it has an
mtime resolution of 1 second.

> >Operations such as RMDIR and unlink() do have a race, but in the case
> >where you have one client creating a directory and another client
> >destroying it, there will always be a race unless you have some method
> >of synchronisation between the processes on the clients.
> >
> >There is a potential caching race if you try to open the file, but that
> >is (as I said previously) quite intentional: it is done for scalability
> >reasons.
> >
> >  
> >
> 
> I don't think that I understand this last paragraph.  Does this mean that
> the consistency was purposefully relaxed in order to increase performance?

Not performance as such, but scalability. Both the server and network
suffer in the case where you have nfsroot clients flooding the system
with GETATTR requests in order to revalidate negative dentries. Consider
for instance at all the little shared libraries, config files, and other
junk that a typical GNOME or KDE desktop login involves, and you'll know
what I mean. The difference between negative dentry caching and not is
very significant in those cases, and so we were seeing some nasty
network floods in the early 2.4 series when it was briefly turned off.

I am basically very wary of increasing the number of GETATTR calls:
we're already seeing a large number of HPC sites complaining about the
scalability problems those cause on their servers, and asking for a
reduction in the number of unnecessary revalidations (particularly so
for 2.6 kernels).

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

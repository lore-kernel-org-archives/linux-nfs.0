From: Greg Banks <gnb@melbourne.sgi.com>
Subject: Re: NFS FAQ review
Date: Tue, 19 Oct 2004 15:58:12 +1000
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <1098165492.13820.760.camel@hole.melbourne.sgi.com>
References: <20041018210353.GG19460@fieldses.org>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Linux NFS Mailing List <nfs@lists.sourceforge.net>,
	"Lever, Charles" <Charles.Lever@netapp.com>
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1CJmjX-000203-IQ
	for nfs@lists.sourceforge.net; Mon, 18 Oct 2004 22:40:31 -0700
Received: from omx2-ext.sgi.com ([192.48.171.19] helo=omx2.sgi.com)
	by sc8-sf-mx1.sourceforge.net with esmtp (Exim 4.41)
	id 1CJmjX-0005Ix-3j
	for nfs@lists.sourceforge.net; Mon, 18 Oct 2004 22:40:31 -0700
To: "J. Bruce Fields" <bfields@fieldses.org>
In-Reply-To: <20041018210353.GG19460@fieldses.org>
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

G'day,

On Tue, 2004-10-19 at 07:03, J. Bruce Fields wrote:
> > -----Original Message-----
> > From: Lever, Charles 
> > Sent: Monday, October 18, 2004 4:50 PM
> > To: nfs@lists.sourceforge.net
> > Subject: NFS FAQ review
> > 
> > 
> > please see:
> > 
> >   http://nfs.sourceforge.net/new.php
> > 
> > changes include:
> > 
> >   o  removal of most references to 2.2 and 2.5
> >   o  new introduction
> >   o  cleanup of "quick" sections
> >   o  update of NFSv4-related items
> >   o  various minor fixes
> > 
> > comments, please.  i'd like to roll this in to index.php 
> > sometime this week.
> > 

Nice job.  I took the opportunity to go through the whole doc
and offer some comments.

> Quick Server Setup Guide:

> 3. Use /etc/init.d/nfs start to start the NFS server.

On some distros, you want /etc/init.d/nfsserver and .../nfs
is used on the client side.

> Quick Client Setup Guide
> 5. Start the NFS locking service with /etc/init.d/nfslock start.

This isn't necessary with modern kernels, which start the lockd
kernel thread automatically on the first NFS mount.

> A1
> NFS Version 2 requires that a server must save all the data in a write
> operation to disk before it replies to a client [...]

Another reason this is slow on some machines is that the page size
is larger than 8K so the server has to wait to read in data from
the file to fill the remainder of the page before it can overwrite
other data.

> B1
> Are you using enough NFS daemons for your UDP mounts? Look at the
> network traffic with netstat -s -t; if the number of packet receive
> errors increases during heavy NFS usage, increase the total number of
> nfsd's.

?!??  Why would you look at TCP stats to diagnose UDP performance
problems?  Why would packet receive errors be indicative of not
enough nfsds?  Perhaps you could just copy in some of Neil's
explanation of the "th" line in /proc/net/rpc/nfsd

http://marc.theaimsgroup.com/?l=linux-nfs&m=102824853219024&w=2

> B2
> Finally, note that the maximum transfer size permitted by the Linux
> server (NFSSVC_MAXBLKSIZE) is set to 32 KB when applying all patches
> involved with the implementation of NFS over TCP in the 2.4 kernels.
> Later 2.4 kernels have TCP server support already integrated, but keep
> the transfer size support limited to 8KB.

Even later 2.4 kernels have a transfer size which is twice the
server's page size, up to a maximum of 32KB.


> B5. Why does default NFS Version 2 performance seem equivalent to NFS
> Version 3 performance in 2.4 kernels?

The other reason (when the server is a 4K page machine like an i386)
is the transfer size is limited to 8KB.  With a 2.6 kernel, transfer
sizes up to 32KB allow Version 3 to make more efficient use of the
network.


> B9. I use the "sync" or "noac" mount options. I've increased my wsize,
> but write throughput is lower than I expect. Why is this?  
        
Another possible factor arises when the server's page size is larger
than the client's.  The Linux client aligns reads and writes to it's
own page size, which may be unaligned on the server.  Depending on
the server OS and filesystem, this could result in a number of
performance limiting problems.

> D2
> These files are the result of a 'sillydelete' operation. One
> process on the client is trying to delete the file while another has
> it open.

Or the same process.

> D3. 
> It refers to a mount request by a Solaris system that is trying to
> get ACL information - which linux obviously does not have.

There are patches to do that and some distros ship with them,
SUSE in particular.

> E1
> However, older SunOS and Tru64 clients take advantage of the NFS
> specification by making all NFS file lock requests with the
> credentials of the daemon

We've seen this with HP-UX clients too.

        
Greg.
-- 
Greg Banks, R&D Software Engineer, SGI Australian Software Group.
I don't speak for SGI.




-------------------------------------------------------
This SF.net email is sponsored by: IT Product Guide on ITManagersJournal
Use IT products in your business? Tell us what you think of them. Give us
Your Opinions, Get Free ThinkGeek Gift Certificates! Click to find out more
http://productguide.itmanagersjournal.com/guidepromo.tmpl
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs

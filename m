From: =?iso-8859-1?Q?Peter_=C5strand?= <astrand@lysator.liu.se>
Subject: Re: NFSv4 and client caching to local disk?
Date: Mon, 31 Mar 2003 21:44:06 +0200 (CEST)
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <Pine.LNX.4.44.0303312137340.22073-100000@sofie.lambo.student.liu.se>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=iso-8859-1
Cc: James Pearson <james-p@moving-picture.com>
Return-path: <nfs-admin@lists.sourceforge.net>
To: nfs@sourceforge.net
Errors-To: nfs-admin@lists.sourceforge.net
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
List-Id: Discussion of NFS under Linux development,
	interoperability,
	and testing. <nfs.lists.sourceforge.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=nfs>


> I'm trying to find out more about 'cachefs' type file systems that can
> cache NFS data to a client's local disk - I've come across a couple of
> references that seem to indicate that this may be possible with NFSv4.

I recently found out about http://infradead.org/cgi-bin/cvsweb.cgi/afs/, 
which includes a "cachefs" filesystem. It's written by David Howells 
<dhowells@warthog.cambridge.redhat.com>, and was announced as:

"I'm writing a cache filesystem for primarily for caching AFS pages, but
that also can be used for caching other network FS pages (such as NFSv4,
which Jeff Garzik and Trond Myklebust are interested in, I think)."

"Look in the afs/fs/cachefs/ and afs/include/linux/ directories. It's not
complete yet, but does allow me to do some of the functions required, such
as fully journalled block allocation and index creation and entry
allocation."

I haven't tried it, though. 

-- 
/Peter Åstrand <astrand@lysator.liu.se>




-------------------------------------------------------
This SF.net email is sponsored by: ValueWeb: 
Dedicated Hosting for just $79/mo with 500 GB of bandwidth! 
No other company gives more support or power for your dedicated server
http://click.atdmt.com/AFF/go/sdnxxaff00300020aff/direct/01/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs

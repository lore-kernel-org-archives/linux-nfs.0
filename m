From: Frank van Maarseveen <frankvm@xs4all.nl>
Subject: Re: executable but not readable
Date: Sat, 27 Mar 2004 13:17:31 +0100
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <20040327121731.GA27152@janus>
References: <40631E32.1020707@gsi.de> <1080239856.2584.18.camel@lade.trondhjem.org> <40640A7E.5040601@gsi.de> <1080328671.2480.23.camel@lade.trondhjem.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1B7Cla-0003Uh-Dx
	for nfs@lists.sourceforge.net; Sat, 27 Mar 2004 04:18:22 -0800
Received: from frankvm.xs4all.nl ([80.126.170.174] helo=janus.localdomain)
	by sc8-sf-mx1.sourceforge.net with esmtp (Exim 4.30)
	id 1B7ClZ-0007Ah-BP
	for nfs@lists.sourceforge.net; Sat, 27 Mar 2004 04:18:21 -0800
To: nfs@lists.sourceforge.net
In-Reply-To: <1080328671.2480.23.camel@lade.trondhjem.org>
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

On Fri, Mar 26, 2004 at 02:17:51PM -0500, Trond Myklebust wrote:
> 
> In NFSv3, the ACCESS call should then be used to decide whether or not
> the client is allowed to open the file for execution (and for reading if
> that is required). Unfortunately ACCESS is not implemented in the stock
> Linux 2.4.x kernel.

So the kernel does its own permission checking on the client side
for executables _knowing_ that it is going to execute the file but
unfortunately the interpreter has to open the file by itself and that
fails.

But from a different perspective:

Being able to create a (non-setuid) executable which cannot be read
for security reasons looks very weak to me unless of course it is not
possible to let it dump core, strace (ptrace) it, open /proc/... files
etc. But is that all actually the case in 2.6?


-- 
Frank


-------------------------------------------------------
This SF.Net email is sponsored by: IBM Linux Tutorials
Free Linux tutorial presented by Daniel Robbins, President and CEO of
GenToo technologies. Learn everything from fundamentals to system
administration.http://ads.osdn.com/?ad_id=1470&alloc_id=3638&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs

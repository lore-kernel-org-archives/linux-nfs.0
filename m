From: Daniel Forrest <forrest@lmcg.wisc.edu>
Subject: Re: reliable reading
Date: Mon, 28 Jun 2004 15:37:05 -0500
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <20040628153705.A21020@rda07.lmcg.wisc.edu>
References: <Pine.LNX.4.60.0406280901350.3356@harp.ngdc.noaa.gov>
Reply-To: Daniel Forrest <forrest@lmcg.wisc.edu>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-list1-b.sourceforge.net ([10.3.1.7] helo=sc8-sf-list1.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1Bf2sQ-0007rp-MC
	for nfs@lists.sourceforge.net; Mon, 28 Jun 2004 13:37:18 -0700
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list1.sourceforge.net with esmtp (Exim 4.30)
	id 1Bf2sQ-0005It-ES
	for nfs@lists.sourceforge.net; Mon, 28 Jun 2004 13:37:18 -0700
Received: from mail.lmcg.wisc.edu ([144.92.101.145])
	by sc8-sf-mx1.sourceforge.net with esmtp (Exim 4.34)
	id 1Bf2sQ-0004Im-1X
	for nfs@lists.sourceforge.net; Mon, 28 Jun 2004 13:37:18 -0700
To: "Ara.T.Howard" <Ara.T.Howard@noaa.gov>
In-Reply-To: <Pine.LNX.4.60.0406280901350.3356@harp.ngdc.noaa.gov>; from Ara.T.Howard@noaa.gov on Mon, Jun 28, 2004 at 09:13:29AM -0600
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

On Mon, Jun 28, 2004 at 09:13:29AM -0600, Ara.T.Howard wrote:
> 
>    - what is the 'safest' way read the most recent contents of an
>      nfs mounted file accounting for attribute caching?
> 
>    - same question but for writing

We have a queueing system that does the same types of operations (over
45 machines all reading and writing files from the same NFS mounted
filesystems).  We use the following technique:

    fd = open ("file", O_RDWR);
    lockf (fd, F_TLOCK, 0);
    fchmod (fd, 0644);
    size = lseek (fd, 0, SEEK_END);

The "open" is required to get a file handle for the "lockf" operation.

The "lockf" clears the NFS client cache.

You would hope at this point that things would be okay, but it turns
out that the file size is still the file size that was cached at the
time the file was "open"ed.  So...

The "fchmod" operation is basically a no-op (we happen to know the
file already has these permissions), but it forces a round-trip
request to the server which updates the actual file size.

The "lseek" gives the actual file size to the program.

I don't remember if "fstat" could be used in place of the "lseek" as
we are usually appending to the end of the file so the "lseek" is
being called anyway.  In the case when we are copying the file we use
the same algorithm and then "lseek (fd, 0, SEEK_SET)" before reading.

While the "open"/"lockf" itself seems to work almost all of the time,
we had rare occasions when we lost lines from the end of the file
before we added the "fchmod" before the "lseek".  Also, there are
probably other operations besides "fchmod" that will update the actual
file size, but I don't recall which ones they are.

I hope this helps.

-- 
Daniel K. Forrest	Laboratory for Molecular and
forrest@lmcg.wisc.edu	Computational Genomics
			University of Wisconsin, Madison


-------------------------------------------------------
This SF.Net email sponsored by Black Hat Briefings & Training.
Attend Black Hat Briefings & Training, Las Vegas July 24-29 - 
digital self defense, top technical experts, no vendor pitches, 
unmatched networking opportunities. Visit www.blackhat.com
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs

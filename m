From: "Jose R. Santos" <jrsantos@austin.ibm.com>
Subject: Re: BKL removal from find_exported_dentry()
Date: Tue, 16 Mar 2004 10:30:08 -0600
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <20040316163008.GS4972@rx8.ibm.com>
References: <20040309135451.GC30766@rx8.ibm.com> <20040311211020.GA1296@rx8.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.12] helo=sc8-sf-mx2.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1B3HQl-0001fE-No
	for nfs@lists.sourceforge.net; Tue, 16 Mar 2004 08:28:39 -0800
Received: from e32.co.us.ibm.com ([32.97.110.130])
	by sc8-sf-mx2.sourceforge.net with esmtp (TLSv1:DES-CBC3-SHA:168)
	(Exim 4.30)
	id 1B3HQg-0000nc-6O
	for nfs@lists.sourceforge.net; Tue, 16 Mar 2004 08:28:34 -0800
To: nfs@lists.sourceforge.net, neilb@cse.unsw.edu.au
In-Reply-To: <20040311211020.GA1296@rx8.ibm.com> (from jrsantos@austin.ibm.com on Thu, Mar 11, 2004 at 15:10:20 -0600)
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

On 03/11/04 15:10:20, Jose R. Santos wrote:
> Looking at the code it seems there is a possibility of racing if directories
> get rename or remove, but BKL doesn't seem to protect against these races, it
> may slow down thing a bit to avoid them though.

After looking at this even further, I'm starting to get the impression that the
BKL is there in order to protect against filesystems that behave badly.  I guess
this is the price for code portability across many filesystems.

Could a better choice to fix this issue be to implementing the get_dentry() for 
each filesystem and making sure that it almost always returns a connected dentry?
Filesystems that don't implement it would just use the generic op. 

I also have concerns about seeing this on busy SMP machines with relative small 
amounts of memory and several NFS exports with very deep directories.

> I'm attaching a patch that removes BKL from find_exported_dentry().  I see a 
> huge improvement on SpecSFS benchmark and haven't seen any failure up to date.

While reduces the time spent on find_exported_dentry() from 75% to less than 1%,
it seems that this may not be a very popular approach.  Guess I should have done 
my homework about the BKL removal subject before posting. :)

I am really interested in knowing if the BKL is there to protect against bad 
filesystem or if its there for other reasons.

Thanks

-JRS




-------------------------------------------------------
This SF.Net email is sponsored by: IBM Linux Tutorials
Free Linux tutorial presented by Daniel Robbins, President and CEO of
GenToo technologies. Learn everything from fundamentals to system
administration.http://ads.osdn.com/?ad_id=1470&alloc_id=3638&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs

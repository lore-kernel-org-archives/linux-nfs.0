From: Neil Brown <neilb@cse.unsw.edu.au>
Subject: Re: BKL removal from find_exported_dentry()
Date: Wed, 17 Mar 2004 09:58:37 +1100
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <16471.34461.450575.488029@notabene.cse.unsw.edu.au>
References: <20040309135451.GC30766@rx8.ibm.com>
	<20040311211020.GA1296@rx8.ibm.com>
	<20040316163008.GS4972@rx8.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1B3NXD-0002oL-2g
	for nfs@lists.sourceforge.net; Tue, 16 Mar 2004 14:59:43 -0800
Received: from note.orchestra.cse.unsw.edu.au ([129.94.242.24] ident=root)
	by sc8-sf-mx1.sourceforge.net with smtp (Exim 4.30)
	id 1B3NXB-0004Kq-0i
	for nfs@lists.sourceforge.net; Tue, 16 Mar 2004 14:59:41 -0800
Received: From notabene ([129.94.211.194] == dulcimer.orchestra.cse.unsw.EDU.AU)
	(for <jrsantos@austin.ibm.com>) (for <nfs@lists.sourceforge.net>) By
	note With Smtp ; Wed, 17 Mar 2004 09:58:39 +1100
To: "Jose R. Santos" <jrsantos@austin.ibm.com>
In-Reply-To: message from Jose R. Santos on Tuesday March 16
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

On Tuesday March 16, jrsantos@austin.ibm.com wrote:
> After looking at this even further, I'm starting to get the impression that the
> BKL is there in order to protect against filesystems that behave badly.  I guess
> this is the price for code portability across many filesystems.
...
> 
> > I'm attaching a patch that removes BKL from find_exported_dentry().  I see a 
> > huge improvement on SpecSFS benchmark and haven't seen any failure up to date.
> 
> While reduces the time spent on find_exported_dentry() from 75% to less than 1%,
> it seems that this may not be a very popular approach.  Guess I should have done 
> my homework about the BKL removal subject before posting. :)
> 
> I am really interested in knowing if the BKL is there to protect against bad 
> filesystem or if its there for other reasons.

It is a long time now since I wrote that code.
I went through several iterations, and at some stages the BKL was
definitely needed.
My vague memory is that towards the end, the BKL was needed to protect
against d_move, and particularly to protect accessed to d_parent.
However even when this code was submitted to linus, dparent_lock was
in place for that, and now it has been replaced by  ->d_lock.
So that is certainly no longer a justification for BKL.

I've stared at the code for a while and cannot see any justification
for leaving the BKL there.

I don't think the idea of protecting badly behaved filesystems is
valid.  All the interfaces that we use into filesystems should
definitely be SMP-safe.

So: yes, send the patch to Andrew, tell him that I approve, but maybe
suggest it stay out of main-line for a little while just-in-case.

Thanks,
NeilBrown


-------------------------------------------------------
This SF.Net email is sponsored by: IBM Linux Tutorials
Free Linux tutorial presented by Daniel Robbins, President and CEO of
GenToo technologies. Learn everything from fundamentals to system
administration.http://ads.osdn.com/?ad_id=1470&alloc_id=3638&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs

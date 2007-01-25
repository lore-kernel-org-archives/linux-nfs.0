From: Marvin Humphrey <marvin@rectangular.com>
Subject: Re: Lucene, delete-on-last-close, and flock emulation
Date: Thu, 25 Jan 2007 11:36:41 -0800
Message-ID: <9DE715C1-E01B-4FE1-858E-AE9409BD1F84@rectangular.com>
References: <873E10FD-9682-46D8-9A5D-D6AD6C60060C@rectangular.com>
	<1169694418.8355.5.camel@lade.trondhjem.org>
Mime-Version: 1.0 (Apple Message framework v752.2)
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net
To: Trond Myklebust <trond.myklebust@fys.uio.no>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1HAAP4-00032q-4V
	for nfs@lists.sourceforge.net; Thu, 25 Jan 2007 11:37:01 -0800
Received: from www.rectangular.com ([68.116.38.223] helo=rectangular.com)
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1HAAP0-0002EQ-1Q
	for nfs@lists.sourceforge.net; Thu, 25 Jan 2007 11:36:57 -0800
In-Reply-To: <1169694418.8355.5.camel@lade.trondhjem.org>
List-Id: "Discussion of NFS under Linux development, interoperability,
	and testing." <nfs.lists.sourceforge.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=nfs>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
Sender: nfs-bounces@lists.sourceforge.net
Errors-To: nfs-bounces@lists.sourceforge.net

On Jan 24, 2007, at 7:06 PM, Trond Myklebust wrote:
> You could easily fix this by having the reader create a hard link  
> to the
> index file. e.g.
>
> ln foo foo-client.my.org-$$
> open("foo-client.my.org-$$");
> ....
> read()
> ...
> close()
> rm foo-client.my.org-$$

Interesting approach.  Lucene is written in Java, and to my  
knowledge, Java doesn't provide support for hard linking on principle  
because it's system specific -- so hard linking wasn't on the radar  
screen.  It would actually be easier to implement this in my Perl/C  
port because there's link() from either Perl or <unistd.h>.

The first drawback is that this scheme requires that read apps have  
write permissions on the NFS volume.  A dot-lock read-locking scheme  
I proposed received this response on the KinoSearch list:

     We do not enable NFS writes, only reads (which is why
     Slashdot is able to reliably use NFS for its heavy
     load :-).  So I don't think that will work, if I
     understand you correctly.

The second is that it might get pretty messy.  Reading apps may stay  
open for days at a time, but it would be pretty dicy for library code  
to require mandatory periodic timestamp updates -- so it's hard to  
devise a sensible strategy for culling orphaned links.  And Lucene  
indexes are directories with tens, often hundreds of files in them.   
So if you have a lot of clients, we're talking about a large number  
of links.

On the upside, delete-on-last-close uses reference-counting, and hard  
linking is basically a reference-counting technique.  So in spirit,  
hard linking is exactly the right approach -- better than read  
locking, and much more in line with Lucene's current design.

> Why do read locking at all?

It's only one out of 6 or 7 approaches we've considered so far, none  
of which are satisfactory.  If we can avoid it, great!

Marvin Humphrey
Rectangular Research
http://www.rectangular.com/



-------------------------------------------------------------------------
Take Surveys. Earn Cash. Influence the Future of IT
Join SourceForge.net's Techsay panel and you'll get the chance to share your
opinions on IT & business topics through brief surveys - and earn cash
http://www.techsay.com/default.php?page=join.php&p=sourceforge&CID=DEVDEV
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs

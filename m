From: Dave Ingram <davei@wolfram.com>
Subject: Re: recursive NFS export of mounted ISO images
Date: Wed, 23 Oct 2002 15:16:55 -0500 (CDT)
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <Pine.LNX.4.44.0210231512570.31286-100000@wopr.wolfram.com>
References: <1035403629.31676.34.camel@opus>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from wri-dns0.wolfram.com ([140.177.205.10] helo=wolfram.com)
	by usw-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 184RxF-00053D-00
	for <nfs@lists.sourceforge.net>; Wed, 23 Oct 2002 13:18:13 -0700
To: seth vidal <skvidal@phy.duke.edu>
In-Reply-To: <1035403629.31676.34.camel@opus>
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

On 23 Oct 2002, seth vidal wrote:

> You might be able to work some dark magic with autofs over the nfs
> exported locations.
> 
> look into how autofs functions - I think it might just be possible if
> you're not afraid of some painful thinking.

	:) I wrestled with this on the 2nd night of trying to come up with 
a solution.

	While this may simplify the client's transaction, the server now 
has to automatically:

1. Create an auto.XXX autofs config file for every ISO mounted directory
2. Update /etc/auto.master
3. the autofs daemon gets reloaded for each new addition/subtraction

	All of this needs to be done by root as well. Of course, a 
specialized SUID wrapper can be constructed to do this, but it's still a 
bit of a boondoggle. It's fair to say, however, that almost any solution 
currently will have to be a bit of a hack.

	But it's hard to believe that there aren't other people with a 
genuine need for something like this sort of dynamic recursive 
distribution.

	Thanks very much for the fast response!

Dave

-- 
Dave Ingram
Tools and Automation Engineer
Wolfram Research
217-398-0700 x776



-------------------------------------------------------
This sf.net email is sponsored by: Influence the future 
of Java(TM) technology. Join the Java Community 
Process(SM) (JCP(SM)) program now. 
http://ads.sourceforge.net/cgi-bin/redirect.pl?sunm0002en

_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs

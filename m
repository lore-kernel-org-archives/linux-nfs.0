From: Trent Piepho <xyzzy@speakeasy.org>
Subject: Re: network storage solutions
Date: Thu, 15 May 2003 15:01:52 -0700 (PDT)
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <Pine.LNX.4.04.10305151449470.7166-100000@12-207-199-254.client.attbi.com>
References: <1053024984.5960.28.camel@squash.scalableinformatics.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Beowulf <beowulf@beowulf.org>, nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from 12-207-199-254.client.attbi.com ([12.207.199.254] ident=root)
	by sc8-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 19GQnW-0000PN-00
	for <nfs@lists.sourceforge.net>; Thu, 15 May 2003 15:01:58 -0700
In-Reply-To: <1053024984.5960.28.camel@squash.scalableinformatics.com>
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

On 15 May 2003, Joe Landman wrote:
> > However, if I read Chuck's paper correctly, with soft mount
> > you can get a soft time-out that can interrupt an operation
> > but the client will continue then with corrupted data. Am I
> > understanding this correctly? Therefore, the clients may be
> > up, but now the data is corrupt and the appliation doesn't
> > know it.
> 
> I would like to know that as well.  I would like to believe it will not
> continue with corrupt data, but return an error code/condition which
> should be handled.

That was my experience.  We had a problem with soft NFS timing out during huge
IO loads to large raid arrays.  With a large server side cache getting
flushed, some NFS requests could take several tens of seconds before the
server got around to processing them.  The soft NFS timeout limit turned out
to be quite small.  When this happens, there was both a message to syslog from
the kernel about nfs timeout exceeded, and the application returned an error
(read:  I/O error or something of that nature).  I can see how a poorly coded
(though not uncommon) program that doesn't check the return value of read and
write calls would not detect the failure.  I raised the timeout to a more
reasonable value, and no problems since.



-------------------------------------------------------
Enterprise Linux Forum Conference & Expo, June 4-6, 2003, Santa Clara
The only event dedicated to issues related to Linux enterprise solutions
www.enterpriselinuxforum.com

_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs

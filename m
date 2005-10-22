From: raven@themaw.net
Subject: Re: How to find what to make "df -jk" hang (redhat)
Date: Sat, 22 Oct 2005 23:55:42 +0800 (WST)
Message-ID: <Pine.LNX.4.63.0510222354090.17429@donald.themaw.net>
References: <20051022154528.24385.qmail@web52411.mail.yahoo.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91] helo=mail.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1ETM17-0005Xl-K3
	for nfs@lists.sourceforge.net; Sat, 22 Oct 2005 09:14:45 -0700
Received: from wombat.indigo.net.au ([202.0.185.19])
	by mail.sourceforge.net with esmtps (TLSv1:DES-CBC3-SHA:168)
	(Exim 4.44)
	id 1ETM16-0006Eq-SH
	for nfs@lists.sourceforge.net; Sat, 22 Oct 2005 09:14:45 -0700
To: Jun Zhang <nugulus@yahoo.com>
In-Reply-To: <20051022154528.24385.qmail@web52411.mail.yahoo.com>
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

On Sat, 22 Oct 2005, Jun Zhang wrote:

> Ian,
>    What do I look for? Those two file have quite the
> same contents. Ain't what listed there are mounted
> items?

But something is hanging so you should be able to work out which one it is 
by identifing how far df got.

> 
> Jun Zhang
> 
> --- Ian Kent <raven@themaw.net> wrote:
> 
> > On Fri, 21 Oct 2005, Jun Zhang wrote:
> > 
> > >  
> > > Many a time when I type df -k, the prompt will not
> > come back. Went to another session, I found the df
> > process is not killable. I then checked each piece
> > in /etc/fstab, each piece is fine (mounted and
> > accessible).
> > > Can somebosy give a clue?
> > 
> > Not fstab.
> > 
> > Try working out what is blocked by looking at
> > /etc/mtab or /proc/mounts.
> > 
> > Ian
> > 
> > 
> > 
> >
> -------------------------------------------------------
> > This SF.Net email is sponsored by:
> > Power Architecture Resource Center: Free content,
> > downloads, discussions,
> > and more.
> > http://solutions.newsforge.com/ibmarch.tmpl
> > _______________________________________________
> > NFS maillist  -  NFS@lists.sourceforge.net
> > https://lists.sourceforge.net/lists/listinfo/nfs
> > 
> 
> 
> 
> 	
> 		
> __________________________________ 
> Yahoo! Mail - PC Magazine Editors' Choice 2005 
> http://mail.yahoo.com
> 



-------------------------------------------------------
This SF.Net email is sponsored by the JBoss Inc.
Get Certified Today * Register for a JBoss Training Course
Free Certification Exam for All Training Attendees Through End of 2005
Visit http://www.jboss.com/services/certification for more information
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs

From: Frank Cusack <fcusack@fcusack.com>
Subject: Re: [autofs] Re: VFS: Busy inodes after unmount on 2 way SMP
Date: Thu, 18 Sep 2003 19:57:49 -0700
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <20030918195749.A2273@google.com>
References: <Pine.LNX.4.44.0309151941550.18622-100000@moisil.badula.org> <Pine.LNX.4.44.0309151828050.1920-100000@fubar.phlinux.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list1.sourceforge.net with esmtp
	(Cipher TLSv1:DES-CBC3-SHA:168) (Exim 3.31-VA-mm2 #1 (Debian))
	id 1A0BUR-0005zg-00
	for <nfs@lists.sourceforge.net>; Thu, 18 Sep 2003 19:59:23 -0700
Received: from 216-239-45-4.google.com ([216.239.45.4])
	by sc8-sf-mx1.sourceforge.net with esmtp (Exim 4.22)
	id 1A0BUQ-0005mR-TK
	for nfs@lists.sourceforge.net; Thu, 18 Sep 2003 19:59:22 -0700
To: "H. Peter Anvin" <hpa@zytor.com>, autofs@linux.kernel.org,
   nfs@lists.sourceforge.net
In-Reply-To: <Pine.LNX.4.44.0309151828050.1920-100000@fubar.phlinux.com>; from wago@phlinux.com on Mon, Sep 15, 2003 at 06:34:33PM -0700
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

On Mon, Sep 15, 2003 at 06:34:33PM -0700, Matt C wrote:
> On Mon, 15 Sep 2003, Ion Badulescu wrote:
> > On Mon, 15 Sep 2003, H. Peter Anvin wrote:
> > > Arun Sharma wrote:
> > > >>
> > > >> Oh yeah, easily. Kill the automounter while some things are mounted,
> > > >> unmount everything by hand but do not rmdir the mountpoints. When you
> > > >> unmount the autofs filesystem itself, you will get the self destruct
> > > >> message.
> > > > 
> > > > Thanks. This reproduces the problem I'm chasing very well. I think this
> > > > is clearly an unacceptable kernel bug.
> > > > 
> > > Indeed.  This is on autofs 3?
> > 
> > Both 3 and 4, at least as far as the "self-destruct" message goes.
>
> Don't know if it helps, but we also run a few hundred autofs4 clients, 
> with a mix of 2.4.21 and 2.4.18. The 2.4.21 machines are seeing quite a 
> few of these messages, but not on the 2.4.18 machines. We haven't seen any 
> of the oopses described below, though.

Same here, 2.4.22, autofs 3 and 4.  I'll be playing with 2.6.0 next week.

I haven't tried to reproduce it with your method, but I do see the bug;
no oops though.

/fc


-------------------------------------------------------
This sf.net email is sponsored by:ThinkGeek
Welcome to geek heaven.
http://thinkgeek.com/sf
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs

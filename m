From: Matt C <wago@phlinux.com>
Subject: Re: [autofs] Re: VFS: Busy inodes after unmount on 2 way SMP
Date: Mon, 15 Sep 2003 18:34:33 -0700 (PDT)
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <Pine.LNX.4.44.0309151828050.1920-100000@fubar.phlinux.com>
References: <Pine.LNX.4.44.0309151941550.18622-100000@moisil.badula.org>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: "H. Peter Anvin" <hpa@zytor.com>,
	Arun Sharma <arun.sharma@intel.com>, <autofs@linux.kernel.org>,
	<nfs@lists.sourceforge.net>
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list1.sourceforge.net with esmtp
	(Cipher TLSv1:DES-CBC3-SHA:168) (Exim 3.31-VA-mm2 #1 (Debian))
	id 19z4kC-0000dn-00
	for <nfs@lists.sourceforge.net>; Mon, 15 Sep 2003 18:35:04 -0700
Received: from fubar.phlinux.com ([216.254.54.154])
	by sc8-sf-mx1.sourceforge.net with esmtp (Exim 4.22)
	id 19z4kC-00010c-8k
	for nfs@lists.sourceforge.net; Mon, 15 Sep 2003 18:35:04 -0700
To: Ion Badulescu <lists@news.cs.columbia.edu>
In-Reply-To: <Pine.LNX.4.44.0309151941550.18622-100000@moisil.badula.org>
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

Don't know if it helps, but we also run a few hundred autofs4 clients, 
with a mix of 2.4.21 and 2.4.18. The 2.4.21 machines are seeing quite a 
few of these messages, but not on the 2.4.18 machines. We haven't seen any 
of the oopses described below, though.

-matt

On Mon, 15 Sep 2003, Ion Badulescu wrote:

> On Mon, 15 Sep 2003, H. Peter Anvin wrote:
> 
> > Arun Sharma wrote:
> > >>
> > >> Oh yeah, easily. Kill the automounter while some things are mounted,
> > >> unmount everything by hand but do not rmdir the mountpoints. When you
> > >> unmount the autofs filesystem itself, you will get the self destruct
> > >> message.
> > > 
> > > Thanks. This reproduces the problem I'm chasing very well. I think this
> > > is clearly an unacceptable kernel bug.
> > > 
> > Indeed.  This is on autofs 3?
> 
> Both 3 and 4, at least as far as the "self-destruct" message goes.
> 
> Ion
> 
> 



-------------------------------------------------------
This sf.net email is sponsored by:ThinkGeek
Welcome to geek heaven.
http://thinkgeek.com/sf
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs

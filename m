From: Neil Brown <neilb@cse.unsw.edu.au>
Subject: Re: High Availability NFS Proposal
Date: Sun, 15 Sep 2002 20:18:09 +1000
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <15748.24161.22122.754055@notabene.cse.unsw.edu.au>
References: <20020826175418.GB110744@sheplerathome.eng.sun.com>
	<200208261904.g7QJ4Gd01843@localhost.localdomain>
	<20020826220136.GB100566@dhcp-uaus08-128-212.sun.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: James Bottomley <James.Bottomley@steeleye.com>,
    "Bill Rugolsky Jr." <brugolsky@telemetry-investments.com>,
    nfs@lists.sourceforge.net,
    lmb@suse.de
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from tone.orchestra.cse.unsw.edu.au ([129.94.242.28])
	by usw-sf-list1.sourceforge.net with smtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 17qWU8-0002bL-00
	for <nfs@lists.sourceforge.net>; Sun, 15 Sep 2002 03:18:36 -0700
Received: From
	notabene.cse.unsw.edu.au ([129.94.242.45] == bartok.orchestra.cse.unsw.EDU.AU)
	(for <spencer.shepler@sun.com>) (for <James.Bottomley@steeleye.com>)
	(for <brugolsky@telemetry-investments.com>)
	(for <nfs@lists.sourceforge.net>) (for <lmb@suse.de>) By tone With
	Smtp ; Sun, 15 Sep 2002 20:18:15 +1000
To: spencer.shepler@Sun.COM
In-Reply-To: message from Spencer Shepler on Monday August 26
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

On Monday August 26, shepler@eng.sun.com wrote:
> On Mon, James Bottomley wrote:
> > shepler@eng.sun.com said:
> > > How would you propose dealing with NFSv4 where the mount and statd
> > > daemons are not involved with that implementation? 
> > 
> > Distributions are only just starting to use V3.  V4 is so far out as not to 
> > need consideration at this time.
> 
> My comment was meant to draw out a discussion that with NFSv4 the
> user-level hooks will not be available and an in-kernel implementation
> would need to be considered.  If the current in-kernel implementation
> is moving towards user-level, then future v4 work will need to be redone.

 I'm definately considering NFSv4 and I don't buy the argument that it
can all be done from user-space.  I'm working toward what I hope will
be a nice clean interface for kernel and userspace to work together on
a number of related issues.

 The only way to leave it to user-space that I can see would be to
move the bulk of the NFS server into userspace.  If fast web servers
can be done in user-space, why not fast NFS servers?  There would need
to be a direct interface for filehandle lookup, but I suspect it
could be done, and would atleast be an interesting project.  But I
personally am not particularly motivated to try it.  It's largely
working in the kernel and I am happy for it to stay there.

NeilBrown


-------------------------------------------------------
This sf.net email is sponsored by:ThinkGeek
Welcome to geek heaven.
http://thinkgeek.com/sf
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs

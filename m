From: Christoph Hellwig <hch@infradead.org>
Subject: Re: Portmap - was Re: Does mountd/statd really need to listen
	on a privileged port??
Date: Fri, 27 Apr 2007 15:09:31 +0100
Message-ID: <20070427140931.GA9998@infradead.org>
References: <17958.48121.280256.493824@notabene.brown>
	<200704251056.03664.olaf.kirch@oracle.com>
	<46312615.2090307@RedHat.com>
	<200704270820.19718.olaf.kirch@oracle.com>
	<46320251.8050900@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: Neil Brown <neilb@suse.de>, Steve Dickson <SteveD@redhat.com>,
	Christoph Hellwig <hch@infradead.org>,
	Matthias Koenig <mkoenig@novell.com>, nfs@lists.sourceforge.net,
	Javier Fern?ndez-Sanguino Pe?a <jfs@computer.org>,
	Olaf Kirch <olaf.kirch@oracle.com>, anibal@debian.org
To: Peter Staubach <staubach@redhat.com>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1HhR9L-0008Br-DH
	for nfs@lists.sourceforge.net; Fri, 27 Apr 2007 07:10:15 -0700
Received: from pentafluge.infradead.org ([213.146.154.40])
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1HhR9M-0003dS-N1
	for nfs@lists.sourceforge.net; Fri, 27 Apr 2007 07:10:18 -0700
In-Reply-To: <46320251.8050900@redhat.com>
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

On Fri, Apr 27, 2007 at 10:01:53AM -0400, Peter Staubach wrote:
> This version of the library may or may not be MT-safe, but newer
> versions are definitely safe.  Perhaps the Bull people could tell
> us how old the library is?

The README file claims it's a Sun codedrop from 1993 (!)

> >That's where we disagree :-) I think ripping out the glibc
> >code and replacing it will cause a lot of maintenance for
> >the distros.
> >  
> 
> I am curious what basis that you are using for this?  Why will this
> cause either more or less maintenance for distros?

It's the same reason why we tell people to send us incremental
kernel patches.  Replacing a codebase completely is a not calculateable
risk.  It might work out just fine, but usually it doesn't because
something silently breaks.  Updating the existing codebases with
small bugfixes or new features means you have to think about and justify
every little understandable change and there's a much higher chance that
it won't cause problems.  In the end some of them will cause problems
anyway, but at least you can easily track the problem down to a single
change now.

> It seems to me that this would give us some RPC code, which we could
> support, which was newer than the current glibc code, and would have
> more people working on and supporting it.  That all seems like goodness
> to me.  The current situation is that we can't maintain the RPC code
> at all, which is not goodness at all.

I don't think the problem is that we can't maintain it, but rather
that no one stepped up to maintain it so far.

-------------------------------------------------------------------------
This SF.net email is sponsored by DB2 Express
Download DB2 Express C - the FREE version of DB2 express and take
control of your XML. No limits. Just data. Click to get it now.
http://sourceforge.net/powerbar/db2/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs

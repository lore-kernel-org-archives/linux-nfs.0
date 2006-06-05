From: Ian Kent <raven@themaw.net>
Subject: Re: Fusing Debian patches back into nfs-utils
Date: Mon, 5 Jun 2006 12:16:45 +0800 (WST)
Message-ID: <Pine.LNX.4.64.0606051214210.27003@raven.themaw.net>
References: <20060601155929.GA890@uio.no>
	<17539.41286.81087.480257@cse.unsw.edu.au>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net,
	"Steinar H. Gunderson" <sesse@debian.org>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-list2-b.sourceforge.net ([10.3.1.8]
	helo=sc8-sf-list2.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1Fn6XD-0005MU-4e
	for nfs@lists.sourceforge.net; Sun, 04 Jun 2006 21:17:47 -0700
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1Fn6XD-0005iA-6K
	for nfs@lists.sourceforge.net; Sun, 04 Jun 2006 21:17:47 -0700
Received: from wombat.indigo.net.au ([202.0.185.19])
	by mail.sourceforge.net with esmtps (TLSv1:DES-CBC3-SHA:168)
	(Exim 4.44) id 1Fn6X7-0006MV-FP
	for nfs@lists.sourceforge.net; Sun, 04 Jun 2006 21:17:47 -0700
To: Neil Brown <neilb@suse.de>
In-Reply-To: <17539.41286.81087.480257@cse.unsw.edu.au>
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

On Mon, 5 Jun 2006, Neil Brown wrote:

> 
> >  - escape_hashes_in_exports.diff: Makes sure any # signs in the printed-out
> >    exports file are escaped (as with quotes, spaces, etc.), so they won't be
> >    treated as a comment when they're read back in again.
> 
> Hmm... I think the real bug here is that a '#' is treated as starting
> a comment even if it isn't at the start of a word.
> xgetc shouldn't check for '#', xgettok should.
> The kernel doesn't currently escape '#' in /proc/fs/nfs/exports so
> reading pathnames containing '#' from there will still be a problem.
> 
> So I might fix that too..... could that break anything?

Maybe autofs. I read /proc/mounts a lot and I've had some noise regarding 
"#" escaping lately.

I'll check.

Ian


_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs

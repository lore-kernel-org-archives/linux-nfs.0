From: Neil Brown <neilb@cse.unsw.edu.au>
Subject: Re: nfs_statfs: statfs error = 116
Date: Fri, 19 Sep 2003 10:22:32 +1000
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <16234.19528.624551.573433@notabene.cse.unsw.edu.au>
References: <3F698142.6070404@inf.ethz.ch>
	<3F69B7FB.1050505@RedHat.com>
	<1063913183.1553.25.camel@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Steve Dickson <SteveD@redhat.com>,
    nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list1.sourceforge.net with esmtp
	(Cipher TLSv1:DES-CBC3-SHA:168) (Exim 3.31-VA-mm2 #1 (Debian))
	id 1A092y-0003HU-00
	for <nfs@lists.sourceforge.net>; Thu, 18 Sep 2003 17:22:52 -0700
Received: from note.orchestra.cse.unsw.edu.au ([129.94.242.24] ident=root)
	by sc8-sf-mx1.sourceforge.net with smtp (Exim 4.22)
	id 1A092x-0005MY-P3
	for nfs@lists.sourceforge.net; Thu, 18 Sep 2003 17:22:51 -0700
Received: From notabene ([129.94.242.45] == bartok.orchestra.cse.unsw.EDU.AU)
	(for <mschmitt@inf.ethz.ch>) (for <SteveD@redhat.com>)
	(for <nfs@lists.sourceforge.net>) By note With Smtp ;
	Fri, 19 Sep 2003 10:22:38 +1000
To: Marc Schmitt <mschmitt@inf.ethz.ch>
In-Reply-To: message from Marc Schmitt on  September 18
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

On  September 18, mschmitt@inf.ethz.ch wrote:
> 
> A user has found a bug that appears when checking out a big subversion
> repository on the same server over NFS, it will always timeout upon this
> huge amount of file manipulations and the checkout fails. He then
> reproduced the issue with a small script that basicly loops over those
> four commands:
> 
> rename ("old/bla", "new/bla")
> stat("new,bla",..)
> chmod("new/bla")
> rename ("new/bla", "old/bla")
> 
> Before 1000 iterations the script returns: Error setting new/bla to
> read-only! We'll try to narrow this down on the test cluster, too. One
> particularity has been found already: the bug only appears if
> the renaming takes place over directory boundries.

Sounds like you are using the "subtree_check" export flag on that
export (possibly implicitly).  You don't want to.  i.e. add
"no_subtree_check" after reading "man exports"

NeilBrown


-------------------------------------------------------
This sf.net email is sponsored by:ThinkGeek
Welcome to geek heaven.
http://thinkgeek.com/sf
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs

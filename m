From: Marc Schmitt <mschmitt@inf.ethz.ch>
Subject: Re: nfs_statfs: statfs error = 116
Date: 18 Sep 2003 21:26:23 +0200
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <1063913183.1553.25.camel@localhost>
References: <3F698142.6070404@inf.ethz.ch>  <3F69B7FB.1050505@RedHat.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list1.sourceforge.net with esmtp
	(Cipher TLSv1:DES-CBC3-SHA:168) (Exim 3.31-VA-mm2 #1 (Debian))
	id 1A04Us-0003KA-00
	for <nfs@lists.sourceforge.net>; Thu, 18 Sep 2003 12:31:22 -0700
Received: from mxout.hispeed.ch ([62.2.95.247] helo=smtp.hispeed.ch)
	by sc8-sf-mx1.sourceforge.net with esmtp (TLSv1:DES-CBC3-SHA:168)
	(Exim 4.22)
	id 1A04Uf-0000Vr-0Y
	for nfs@lists.sourceforge.net; Thu, 18 Sep 2003 12:31:09 -0700
To: Steve Dickson <SteveD@redhat.com>
In-Reply-To: <3F69B7FB.1050505@RedHat.com>
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

On Thu, 2003-09-18 at 15:49, Steve Dickson wrote:
> Marc Schmitt wrote:
> 
> >
> > My questions are:
> >
> > - Is this a race? 
> 
> It sounds to me like it could be be a server issue under
> a very heavy load...  How many nfsd are you running? Try
> increasing the number to see if that helps....

Thanks, I'm trying that and changed the number of nfsd from 32 to 64 on
the production system.

> > - How can I provide more debugging infos if needed? 
> 
> ethereal traces have more information and are
> generally more useful... imo...

I'll try to get a test setup running with the same software versions,
create a couple hundres of exports and bomb it from one of the our
clusters with bonnie++s. Like that I'll hopefully be able to reproduce
this re-exporting issue.

A user has found a bug that appears when checking out a big subversion
repository on the same server over NFS, it will always timeout upon this
huge amount of file manipulations and the checkout fails. He then
reproduced the issue with a small script that basicly loops over those
four commands:

rename ("old/bla", "new/bla")
stat("new,bla",..)
chmod("new/bla")
rename ("new/bla", "old/bla")

Before 1000 iterations the script returns: Error setting new/bla to
read-only! We'll try to narrow this down on the test cluster, too. One
particularity has been found already: the bug only appears if
the renaming takes place over directory boundries.

Regards,
    Marc




-------------------------------------------------------
This sf.net email is sponsored by:ThinkGeek
Welcome to geek heaven.
http://thinkgeek.com/sf
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs

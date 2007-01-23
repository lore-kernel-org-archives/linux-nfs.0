From: "Paarvai Naai" <opensource3141@gmail.com>
Subject: Re: "mount: File exists" when trying to mount a second krb5
	volume!
Date: Tue, 23 Jan 2007 14:52:28 -0800
Message-ID: <52109fb10701231452i4e83a106hafa1405b966231c6@mail.gmail.com>
References: <20061120194700.135.qmail@web58109.mail.re3.yahoo.com>
	<52109fb10611281950s50b5d618v21c5818f12ad6b74@mail.gmail.com>
	<52109fb10612011034v4f1feb27n59b6251edee6cfc1@mail.gmail.com>
	<1164998608.16282.6.camel@lade.trondhjem.org>
	<52109fb10612011104l67d2f126hb53d82edb6fef64b@mail.gmail.com>
	<1165000607.17881.23.camel@lade.trondhjem.org>
	<52109fb10612011257s37d64003lb83fd0bbf623233f@mail.gmail.com>
	<52109fb10612041055j41596e67racc9c3194fef413@mail.gmail.com>
	<Pine.LNX.4.64.0612051132150.29520@raven.themaw.net>
	<52109fb10612051106y4dfe0844sa5fd2e3e497c6c56@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfsv4@linux-nfs.org, nfs@lists.sourceforge.net
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1H9UVE-0004sG-FV
	for nfs@lists.sourceforge.net; Tue, 23 Jan 2007 14:52:32 -0800
Received: from ug-out-1314.google.com ([66.249.92.170])
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1H9UVE-0001p3-39
	for nfs@lists.sourceforge.net; Tue, 23 Jan 2007 14:52:34 -0800
Received: by ug-out-1314.google.com with SMTP id z38so1338679ugc
	for <nfs@lists.sourceforge.net>; Tue, 23 Jan 2007 14:52:28 -0800 (PST)
To: "Trond Myklebust" <trond.myklebust@fys.uio.no>
In-Reply-To: <52109fb10612051106y4dfe0844sa5fd2e3e497c6c56@mail.gmail.com>
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

Hi all,

Sadly, Trond's patch has *still* not made it to the upstream sources.
For example, Fedora Core 6 has released a kernel package based on
2.6.19.2 and it doesn't appear to have the fix.

I'm confused as to why this fairly serious regression has not been
corrected by either 2.6.19.1 or 2.6.19.2.  What can be done to get
this remedied asap?

Incidentally, the folks at bugzilla.redhat.com are now on top of this
problem for the upcoming RHEL 5, but that doesn't help non-RHEL users
any!

Thanks,
Paarvai


> > > > On 12/1/06, Trond Myklebust <trond.myklebust@fys.uio.no > wrote:
> > > >
> > > > > The procedures for dealing with kernel regressions are already well
> > > > > established. I will be following them as usual.
> > > > >
> > > > > Trond

-------------------------------------------------------------------------
Take Surveys. Earn Cash. Influence the Future of IT
Join SourceForge.net's Techsay panel and you'll get the chance to share your
opinions on IT & business topics through brief surveys - and earn cash
http://www.techsay.com/default.php?page=join.php&p=sourceforge&CID=DEVDEV
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs

From: Ian Kent <raven@themaw.net>
Subject: Re: "mount: File exists" when trying to mount a second krb5
 volume!
Date: Tue, 5 Dec 2006 11:36:47 +0900 (WST)
Message-ID: <Pine.LNX.4.64.0612051132150.29520@raven.themaw.net>
References: <20061120194700.135.qmail@web58109.mail.re3.yahoo.com>
	<1164228193.5694.38.camel@lade.trondhjem.org>
	<52109fb10611221443w356ff6s4eae49ebb0d935ec@mail.gmail.com>
	<1164628684.3178.10.camel@localhost>
	<52109fb10611281950s50b5d618v21c5818f12ad6b74@mail.gmail.com>
	<52109fb10612011034v4f1feb27n59b6251edee6cfc1@mail.gmail.com>
	<1164998608.16282.6.camel@lade.trondhjem.org>
	<52109fb10612011104l67d2f126hb53d82edb6fef64b@mail.gmail.com>
	<1165000607.17881.23.camel@lade.trondhjem.org>
	<52109fb10612011257s37d64003lb83fd0bbf623233f@mail.gmail.com>
	<52109fb10612041055j41596e67racc9c3194fef413@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfsv4@linux-nfs.org, nfs@lists.sourceforge.net,
	Kostas Georgiou <k.georgiou@imperial.ac.uk>,
	Trond Myklebust <trond.myklebust@fys.uio.no>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1GrQAy-0000b2-C8
	for nfs@lists.sourceforge.net; Mon, 04 Dec 2006 18:36:57 -0800
Received: from out3.smtp.messagingengine.com ([66.111.4.27])
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1GrQAy-0002O0-Ik
	for nfs@lists.sourceforge.net; Mon, 04 Dec 2006 18:36:57 -0800
To: Paarvai Naai <opensource3141@gmail.com>
In-Reply-To: <52109fb10612041055j41596e67racc9c3194fef413@mail.gmail.com>
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

On Mon, 4 Dec 2006, Paarvai Naai wrote:

> I have added this bug to bugzilla.redhat.com and requested that they
> push Trond's patch into their source RPMs as soon as possible.  Sorry if
> I'm stepping on anyone toes, but I just felt that I had to proceed since I
> didn't receive a response to my previous question (see below).

Sorry, I meant to say to log a bug.

But, looking at the history in this thread, it appears that a solution 
hasn't been reached.

> 
> Thanks,
> Paarvai
> 
> On 12/1/06, Paarvai Naai <opensource3141@gmail.com> wrote:
> > 
> > On 12/1/06, Trond Myklebust <trond.myklebust@fys.uio.no > wrote:
> > 
> > > The procedures for dealing with kernel regressions are already well
> > > established. I will be following them as usual.
> > >
> > > Trond
> > >
> > >
> > That's good to know.  What is the well-established procedure for Fedora?
> > I really want to make sure it gets in ASAP.  The importance of this
> > (basically that the current bug *nearly completely breaks* krb5 with
> > NFS) needs to be impressed on them.
> > 
> > Thanks,
> > Paarvai
> > 
> > 
> > 
> > 
> 

-------------------------------------------------------------------------
Take Surveys. Earn Cash. Influence the Future of IT
Join SourceForge.net's Techsay panel and you'll get the chance to share your
opinions on IT & business topics through brief surveys - and earn cash
http://www.techsay.com/default.php?page=join.php&p=sourceforge&CID=DEVDEV
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs

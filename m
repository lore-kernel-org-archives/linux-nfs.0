From: "Paarvai Naai" <opensource3141@gmail.com>
Subject: Re: [NFS] "mount: File exists" when trying to mount a second krb5
	volume!
Date: Tue, 5 Dec 2006 11:06:26 -0800
Message-ID: <52109fb10612051106y4dfe0844sa5fd2e3e497c6c56@mail.gmail.com>
References: <20061120194700.135.qmail@web58109.mail.re3.yahoo.com>
	<1164628684.3178.10.camel@localhost>
	<52109fb10611281950s50b5d618v21c5818f12ad6b74@mail.gmail.com>
	<52109fb10612011034v4f1feb27n59b6251edee6cfc1@mail.gmail.com>
	<1164998608.16282.6.camel@lade.trondhjem.org>
	<52109fb10612011104l67d2f126hb53d82edb6fef64b@mail.gmail.com>
	<1165000607.17881.23.camel@lade.trondhjem.org>
	<52109fb10612011257s37d64003lb83fd0bbf623233f@mail.gmail.com>
	<52109fb10612041055j41596e67racc9c3194fef413@mail.gmail.com>
	<Pine.LNX.4.64.0612051132150.29520@raven.themaw.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfsv4@linux-nfs.org, nfs@lists.sourceforge.net,
	Kostas Georgiou <k.georgiou@imperial.ac.uk>
Return-path: <nfsv4-bounces@linux-nfs.org>
To: "Ian Kent" <raven@themaw.net>
In-Reply-To: <Pine.LNX.4.64.0612051132150.29520@raven.themaw.net>
List-Unsubscribe: <http://linux-nfs.org/cgi-bin/mailman/listinfo/nfsv4>,
	<mailto:nfsv4-request@linux-nfs.org?subject=unsubscribe>
List-Archive: <http://linux-nfs.org/pipermail/nfsv4>
List-Post: <mailto:nfsv4@linux-nfs.org>
List-Help: <mailto:nfsv4-request@linux-nfs.org?subject=help>
List-Subscribe: <http://linux-nfs.org/cgi-bin/mailman/listinfo/nfsv4>,
	<mailto:nfsv4-request@linux-nfs.org?subject=subscribe>
Sender: nfsv4-bounces@linux-nfs.org
Errors-To: nfsv4-bounces@linux-nfs.org
List-ID: <nfs.lists.sourceforge.net>

Hi Ian,

Regarding the resolution of the issue, Trond sent out a patch.  Please see:

http://linux-nfs.org/pipermail/nfsv4/2006-November/005315.html

I've verified this patch on my system and Trond had it working as well.
The initial confusion was that the patch did not apply to 2.6.18 and
when I hacked it up it was causing segfaults on umount.  But that's not
really a concern since we can get the patch into 2.6.19 and up.

Thanks,
Paarvai


On 12/4/06, Ian Kent <raven@themaw.net> wrote:
> On Mon, 4 Dec 2006, Paarvai Naai wrote:
>
> > I have added this bug to bugzilla.redhat.com and requested that they
> > push Trond's patch into their source RPMs as soon as possible.  Sorry if
> > I'm stepping on anyone toes, but I just felt that I had to proceed since I
> > didn't receive a response to my previous question (see below).
>
> Sorry, I meant to say to log a bug.
>
> But, looking at the history in this thread, it appears that a solution
> hasn't been reached.
>
> >
> > Thanks,
> > Paarvai
> >
> > On 12/1/06, Paarvai Naai <opensource3141@gmail.com> wrote:
> > >
> > > On 12/1/06, Trond Myklebust <trond.myklebust@fys.uio.no > wrote:
> > >
> > > > The procedures for dealing with kernel regressions are already well
> > > > established. I will be following them as usual.
> > > >
> > > > Trond
> > > >
> > > >
> > > That's good to know.  What is the well-established procedure for Fedora?
> > > I really want to make sure it gets in ASAP.  The importance of this
> > > (basically that the current bug *nearly completely breaks* krb5 with
> > > NFS) needs to be impressed on them.
> > >
> > > Thanks,
> > > Paarvai
> > >
> > >
> > >
> > >
> >
>

From: Jeff Garzik <jeff@garzik.org>
Subject: Re: A new NFSv4 server...
Date: Fri, 04 Jan 2008 11:14:07 -0500
Message-ID: <477E5B4F.6010305@garzik.org>
References: <477CD231.30603@garzik.org>
	<Pine.LNX.4.64.0801031332060.18129@maggie.lkpg.cendio.se>
Mime-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Cc: NFS list <linux-nfs@vger.kernel.org>, nfsv4@linux-nfs.org
To: =?ISO-8859-1?Q?Peter_=C5strand?= <astrand@cendio.se>
Return-path: <nfsv4-bounces@linux-nfs.org>
In-Reply-To: <Pine.LNX.4.64.0801031332060.18129@maggie.lkpg.cendio.se>
List-Unsubscribe: <http://linux-nfs.org/cgi-bin/mailman/listinfo/nfsv4>,
	<mailto:nfsv4-request@linux-nfs.org?subject=unsubscribe>
List-Archive: <http://linux-nfs.org/pipermail/nfsv4>
List-Post: <mailto:nfsv4@linux-nfs.org>
List-Help: <mailto:nfsv4-request@linux-nfs.org?subject=help>
List-Subscribe: <http://linux-nfs.org/cgi-bin/mailman/listinfo/nfsv4>,
	<mailto:nfsv4-request@linux-nfs.org?subject=subscribe>
Sender: nfsv4-bounces@linux-nfs.org
Errors-To: nfsv4-bounces@linux-nfs.org
List-ID: <linux-nfs.vger.kernel.org>

Peter =C5strand wrote:
> Do you know about the n4 project
> (http://cvs.samba.org/cgi-bin/cvsweb/n4/) ? It was abandon many years
> ago, but might have some usefulness. =


Nope, I'll definitely take look.  Already imported it into git using =

git-cvsimport.  :)


>> term goal is to permit modular storage backends.  Thus you could impleme=
nt a
>> simple RAM backend, an sqlite-based backend or a complex distributed sto=
rage
>> backend.
> =

> unfs3 has a basic modular backend system. I wonder if it would be
> possible to merge your server with unfs3, and still have something
> that's readable. If you are interested, take a look at
> http://cvs.lysator.liu.se/viewcvs/viewcvs.cgi/unfs3/?root=3Dunfs3.

I'm always interested in [legally] stealing useful ideas and code, so I =

will definitely take a look.

I was sorta thinking about implementing a couple backends, and seeing =

what API organically appears.  That's sorta how Linux kernel API =

"design" happens, and it tends to produce something useful and compact, =

if not a bit unique :)

I can imagine that some backends may wish that the server handle some =

details of state and locking, while other backends may wish to record =

all that information into a database in stable storage.  So it's =

difficult to forecast how all that will fall out in the end.  unfs3 =

probably has many lessons to teach me...

So far my best resource for NFS technical "folklore" is generally =

google, which turns up a wealth of useful mailing list discussions =

involving neilb, meisler, and others.

	Jeff


P.S.  cvsps, the util git-cvsimport uses, doesn't seem to like the unfs3 =

CVS repository.  Any ideas?

Running cvsps...
connect error: Network is unreachable
cvs rlog: Logging unfs3
cvs rlog: Logging unfs3/Config
cvs rlog: Logging unfs3/Extras
cvs rlog: Logging unfs3/contrib
cvs rlog: Logging unfs3/contrib/nfsotpclient
cvs rlog: Logging unfs3/contrib/nfsotpclient/mountclient
cvs rlog: Logging unfs3/contrib/rpcproxy
cvs rlog: Logging unfs3/doc
Fetching LICENSE   v 1.1
New LICENSE: 1416 bytes
Fetching Makefile.in   v 1.1
Unknown: error

The same command works just fine with 99% of cvs repositories out there, =

pserver, ssh, or whatever.

And a regular CVS checkout works just fine, I am able to check out and =

browse files and look for gems.

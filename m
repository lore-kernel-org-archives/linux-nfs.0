From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: [NFS] "mount: File exists" when trying to mount a second krb5
	volume!
Date: Fri, 01 Dec 2006 14:16:47 -0500
Message-ID: <1165000607.17881.23.camel@lade.trondhjem.org>
References: <20061120194700.135.qmail@web58109.mail.re3.yahoo.com>
	<1164228193.5694.38.camel@lade.trondhjem.org>
	<52109fb10611221443w356ff6s4eae49ebb0d935ec@mail.gmail.com>
	<1164628684.3178.10.camel@localhost>
	<52109fb10611281950s50b5d618v21c5818f12ad6b74@mail.gmail.com>
	<52109fb10612011034v4f1feb27n59b6251edee6cfc1@mail.gmail.com>
	<1164998608.16282.6.camel@lade.trondhjem.org>
	<52109fb10612011104l67d2f126hb53d82edb6fef64b@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfsv4@linux-nfs.org, nfs@lists.sourceforge.net,
	Kostas Georgiou <k.georgiou@imperial.ac.uk>, Ian Kent <raven@themaw.net>
Return-path: <nfsv4-bounces@linux-nfs.org>
To: Paarvai Naai <opensource3141@gmail.com>
In-Reply-To: <52109fb10612011104l67d2f126hb53d82edb6fef64b@mail.gmail.com>
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

On Fri, 2006-12-01 at 11:04 -0800, Paarvai Naai wrote:
> Thank you for your quick response.  I'm not too familiar with the
> term "injury time" and the like.  But regardless, what is the
> purpose of a rc series if we can't get an important bug fix into it.

That depends entirely on the nature of the bug. This one does not
corrupt data, it does not cause an Oops, so we have time to look
carefully at a solution.

> Here's what I propose and I am happy to help facilitate to 
> some degree.  We should definitely get it into 2.6.19.x ASAP
> and obviously into 2.6.20.  And Fedora often adds extra
> patches into their source RPMs.  This is the most important
> for my company.  Even if we don't have it in 2.6.19 vanilla,
> if I had a "certified" patch from you, we can try to take it
> to Fedora and get it into their source RPM.

The procedures for dealing with kernel regressions are already well
established. I will be following them as usual.

Trond

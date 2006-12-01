From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: [NFS] "mount: File exists" when trying to mount a second krb5
	volume!
Date: Fri, 01 Dec 2006 13:43:28 -0500
Message-ID: <1164998608.16282.6.camel@lade.trondhjem.org>
References: <20061120194700.135.qmail@web58109.mail.re3.yahoo.com>
	<1164228193.5694.38.camel@lade.trondhjem.org>
	<52109fb10611221443w356ff6s4eae49ebb0d935ec@mail.gmail.com>
	<1164628684.3178.10.camel@localhost>
	<52109fb10611281950s50b5d618v21c5818f12ad6b74@mail.gmail.com>
	<52109fb10612011034v4f1feb27n59b6251edee6cfc1@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfsv4@linux-nfs.org, nfs@lists.sourceforge.net,
	Kostas Georgiou <k.georgiou@imperial.ac.uk>, Ian Kent <raven@themaw.net>
Return-path: <nfsv4-bounces@linux-nfs.org>
To: Paarvai Naai <opensource3141@gmail.com>
In-Reply-To: <52109fb10612011034v4f1feb27n59b6251edee6cfc1@mail.gmail.com>
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

On Fri, 2006-12-01 at 10:34 -0800, Paarvai Naai wrote:
> Hi all,
> 
> I really do appreciate the high quality technical assistance
> I have gotten to date from this list.  But at the same time,
> I am getting somewhat frustrated with the very spotty
> attention I am getting for a *critical* bug that somehow 
> made it into the upstream kernel sources.  This is directly
> affecting the ability to use krb5 on either NFSv3 or NFSv4.
> 
> First I had to actually dig through the source and find the
> bug.  Then I was offered a patch but when it didn't work 
> there was very little response/assistance to help with my
> investigation into which kernel that patch is compatible with.
> Finally, I have been insisting that we get the fix back into the
> upstream sources and it appears that no one appreciates 
> the importance.

2.6.19 is already out (and by the time this bug was found, the 2.6.19-rc
series was way into injury time).

The patch will go into 2.6.20, then we can look into sending it in as a
stable update to 2.6.19.x. Not before.

Trond

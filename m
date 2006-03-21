From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: [GIT] NFS client update for 2.6.16
Date: Tue, 21 Mar 2006 13:12:47 -0500
Message-ID: <1142964767.7987.65.camel@lade.trondhjem.org>
References: <1142961077.7987.14.camel@lade.trondhjem.org>
	<44203D00.4030507@garzik.org>
Mime-Version: 1.0
Content-Type: text/plain
Cc: nfsv4@linux-nfs.org, Linus Torvalds <torvalds@osdl.org>,
	nfs@lists.sourceforge.net, linux-kernel@vger.kernel.org
Return-path: <nfsv4-bounces@linux-nfs.org>
To: Jeff Garzik <jeff@garzik.org>
In-Reply-To: <44203D00.4030507@garzik.org>
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

On Tue, 2006-03-21 at 12:50 -0500, Jeff Garzik wrote:
> Trond Myklebust wrote:
> > Hi Linus,
> > 
> > Please pull from the repository at
> > 
> >    git pull git://git.linux-nfs.org/pub/linux/nfs-2.6.git
> > 
> > This will update the following files through the appended changesets.
> 
> It would IMO be nice if you would pipe the changelog through 'git 
> shortlog', to better summarize the submission.  And if the cumulative 
> patch isn't over 100k or so, include that in the email for any last 
> minute review.

The cumulative patch in this case is 291k (smaller than usual, but not
insignificant).
In any case, the individual patches and the cumulative patch are
available, as always, from linux-nfs.org. Please see

  http://client.linux-nfs.org/Linux-2.6.x/2.6.16/

> I've attached the simple script I use to generate pull emails for 
> Andrew/Linus...

Thanks.

Cheers,
  Trond

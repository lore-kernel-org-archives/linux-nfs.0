Return-Path: <nfsv4-bounces@linux-nfs.org>
Date: Mon, 9 Jun 2008 12:02:43 -0400
From: Jeff Layton <jlayton@redhat.com>
To: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: rapid clustered nfs server failover and hung clients -- how
	best to close the sockets?
Message-ID: <20080609120243.5958beb4@tleilax.poochiereds.net>
In-Reply-To: <20080609155136.GC25230@fieldses.org>
References: <20080609103137.2474aabd@tleilax.poochiereds.net>
	<20080609155136.GC25230@fieldses.org>
Cc: linux-nfs@vger.kernel.org, lhh@redhat.com, nfsv4@linux-nfs.org,
        nhorman@redhat.com
List-Unsubscribe: <http://linux-nfs.org/cgi-bin/mailman/listinfo/nfsv4>,
	<mailto:nfsv4-request@linux-nfs.org?subject=unsubscribe>
List-Archive: <http://linux-nfs.org/pipermail/nfsv4>
List-Post: <mailto:nfsv4@linux-nfs.org>
List-Help: <mailto:nfsv4-request@linux-nfs.org?subject=help>
List-Subscribe: <http://linux-nfs.org/cgi-bin/mailman/listinfo/nfsv4>,
	<mailto:nfsv4-request@linux-nfs.org?subject=subscribe>
Content-Type: text/plain; charset="us-ascii"
Sender: nfsv4-bounces@linux-nfs.org
Errors-To: nfsv4-bounces@linux-nfs.org
MIME-Version: 1.0
List-ID: <linux-nfs.vger.kernel.org>

On Mon, 9 Jun 2008 11:51:36 -0400
"J. Bruce Fields" <bfields@fieldses.org> wrote:

> On Mon, Jun 09, 2008 at 10:31:37AM -0400, Jeff Layton wrote:
> > I can think of 3 ways to fix this:
> > 
> > 1) Add something like the recently added "unlock_ip" interface that
> > was added for NLM. Maybe a "close_ip" that allows us to close all
> > nfsd sockets connected to a given local IP address. So clustering
> > software could do something like:
> > 
> >     # echo 10.20.30.40 > /proc/fs/nfsd/close_ip
> > 
> > ...and make sure that all of the sockets are closed.
> > 
> > 2) just use the same "unlock_ip" interface and just have it also
> > close sockets in addition to dropping locks.
> > 
> > 3) have an nfsd close all non-listening connections when it gets a
> > certain signal (maybe SIGUSR1 or something). Connections on a
> > sockets that aren't failing over should just get a RST and would
> > reopen their connections.
> > 
> > ...my preference would probably be approach #1.
> 
> What do you see as the advantage of #1 over #2?  Are there cases where
> someone would want to drop locks but not also close connections (or
> vice-versa)?
> 

There's no real advantage that I can see (maybe if they're running a
cluster with no NLM services somehow). Mostly that "unlock_ip" seems to
imply that it deals with locking, and this doesn't. I'd be OK with #2
if it's a reasonable solution. Given what Chuck mentioned, it sounds
like we'll also need to take care to make sure that existing calls
complete and the replies get flushed out too, so this could be more
complicated that I had anticipated.

-- 
Jeff Layton <jlayton@redhat.com>
_______________________________________________
NFSv4 mailing list
NFSv4@linux-nfs.org
http://linux-nfs.org/cgi-bin/mailman/listinfo/nfsv4

Return-Path: <nfsv4-bounces@linux-nfs.org>
Subject: Re: rapid clustered nfs server failover and hung clients -- how
	best to close the sockets?
From: Lon Hohberger <lhh@redhat.com>
To: Jeff Layton <jlayton@redhat.com>
In-Reply-To: <20080609151011.57939639@tleilax.poochiereds.net>
References: <20080609103137.2474aabd@tleilax.poochiereds.net>
	<20080609155136.GC25230@fieldses.org>
	<20080609120243.5958beb4@tleilax.poochiereds.net>
	<20080609172313.GB26920@fieldses.org>
	<20080609151011.57939639@tleilax.poochiereds.net>
Date: Mon, 09 Jun 2008 16:19:46 -0400
Message-Id: <1213042786.27637.2.camel@ayanami.boston.devel.redhat.com>
Cc: linux-nfs@vger.kernel.org, nfsv4@linux-nfs.org, nhorman@redhat.com
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


On Mon, 2008-06-09 at 15:10 -0400, Jeff Layton wrote:
> > It seems to me that in the long run what we'd like is a virtualized NFS
> > service--you should be able to start and stop independent "servers"
> > hosted on a single kernel, and to clients they should look like
> > completely independent servers.
> > 
> > And I guess the question is how little "virtualization" you can get away
> > with and still have the whole thing work.
> 
> Yep. That was Lon's exact question. Could we start nfsd's that just
> work for certain exports? The answer (of course) is currently no.

s/exports/IP addresses/

-- Lon


_______________________________________________
NFSv4 mailing list
NFSv4@linux-nfs.org
http://linux-nfs.org/cgi-bin/mailman/listinfo/nfsv4

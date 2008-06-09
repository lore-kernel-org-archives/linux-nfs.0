Return-Path: <nfsv4-bounces@linux-nfs.org>
Date: Mon, 9 Jun 2008 12:46:26 -0400
From: Jeff Layton <jlayton@redhat.com>
To: "Talpey, Thomas" <Thomas.Talpey@netapp.com>
Subject: Re: rapid clustered nfs server failover and hung clients --    how
	best to	close the sockets?
Message-ID: <20080609124626.20ba40ab@tleilax.poochiereds.net>
In-Reply-To: <RTPCLUEXC1-PRDusMjQ000001d5@RTPMVEXC1-PRD.hq.netapp.com>
References: <20080609103137.2474aabd@tleilax.poochiereds.net>
	<484D4659.9000105@redhat.com>
	<20080609111821.6e06d4f8@tleilax.poochiereds.net>
	<RTPCLUEXC1-PRDOLZCH000001d2@RTPMVEXC1-PRD.hq.netapp.com>
	<20080609120110.1fee7221@tleilax.poochiereds.net>
	<RTPCLUEXC1-PRDF8Eqf000001d4@RTPMVEXC1-PRD.hq.netapp.com>
	<20080609122249.51767b21@tleilax.poochiereds.net>
	<RTPCLUEXC1-PRDusMjQ000001d5@RTPMVEXC1-PRD.hq.netapp.com>
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

On Mon, 09 Jun 2008 12:40:05 -0400
"Talpey, Thomas" <Thomas.Talpey@netapp.com> wrote:

> At 12:22 PM 6/9/2008, Jeff Layton wrote:
> >That might be worth investigating, but sounds like it might cause problems
> >with the services associated with IP addresses that are staying on the
> >victim server.
> 
> Jeff, I think you have many years of job security to look forward to, here. :-)
> 

:-)

> Since you sent this to the NFSv4 list - is there any chance you're thinking
> to not transparently take over IP addresses, but use NFSv4 locations and
> referrals for these "migrations"? Yes, I know some clients may not quite be
> there yet.
> 

An interesting thought. I sent this to the nfsv4 list since I assume
nfsv4 will also be affected by this problem....

I'm not aware of any plans to integrate the new v4 stuff into our
cluster product. It would make a lot of sense though, so perhaps after
it gets some more upstream soak time we'll want to consider it. That
would be an extremely attractive thing with something like GFS on
the backend.

-- 
Jeff Layton <jlayton@redhat.com>
_______________________________________________
NFSv4 mailing list
NFSv4@linux-nfs.org
http://linux-nfs.org/cgi-bin/mailman/listinfo/nfsv4

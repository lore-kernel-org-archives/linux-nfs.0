Return-Path: <nfsv4-bounces@linux-nfs.org>
Date: Mon, 9 Jun 2008 14:03:46 -0400
To: "Talpey, Thomas" <Thomas.Talpey@netapp.com>
Subject: Re: rapid clustered nfs server failover and hung clients -- how
	best to close the sockets?
Message-ID: <20080609180346.GA28584@fieldses.org>
References: <20080609103137.2474aabd@tleilax.poochiereds.net>
	<484D4659.9000105@redhat.com>
	<20080609111821.6e06d4f8@tleilax.poochiereds.net>
	<RTPCLUEXC1-PRDOLZCH000001d2@RTPMVEXC1-PRD.hq.netapp.com>
	<20080609120110.1fee7221@tleilax.poochiereds.net>
	<RTPCLUEXC1-PRDF8Eqf000001d4@RTPMVEXC1-PRD.hq.netapp.com>
	<20080609122249.51767b21@tleilax.poochiereds.net>
	<RTPCLUEXC1-PRDusMjQ000001d5@RTPMVEXC1-PRD.hq.netapp.com>
In-Reply-To: <RTPCLUEXC1-PRDusMjQ000001d5@RTPMVEXC1-PRD.hq.netapp.com>
From: "J. Bruce Fields" <bfields@fieldses.org>
Cc: linux-nfs@vger.kernel.org, lhh@redhat.com, nfsv4@linux-nfs.org,
        nhorman@redhat.com, Jeff Layton <jlayton@redhat.com>
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

On Mon, Jun 09, 2008 at 12:40:05PM -0400, Talpey, Thomas wrote:
> At 12:22 PM 6/9/2008, Jeff Layton wrote:
> >That might be worth investigating, but sounds like it might cause problems
> >with the services associated with IP addresses that are staying on the
> >victim server.
> 
> Jeff, I think you have many years of job security to look forward to, here. :-)
> 
> Since you sent this to the NFSv4 list - is there any chance you're thinking
> to not transparently take over IP addresses, but use NFSv4 locations and
> referrals for these "migrations"?

Yeah, definitely.  We've a got a prototype and some other work in
progress--hopefully there'll be something "real" in the coming months!

There's some overlap with nfsv2/v3, though (not in this case, but in the
need for lock migration, for example).  And people really are using this
floating-ip address stuff now, so anything we can do to make it more
reliable or easier to use is welcome.

--b.

> Yes, I know some clients may not quite be
> there yet.
_______________________________________________
NFSv4 mailing list
NFSv4@linux-nfs.org
http://linux-nfs.org/cgi-bin/mailman/listinfo/nfsv4

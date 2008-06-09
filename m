Return-Path: <nfsv4-bounces@linux-nfs.org>
Date: Mon, 9 Jun 2008 15:01:05 -0400
From: Jeff Layton <jlayton@redhat.com>
To: "Talpey, Thomas" <Thomas.Talpey@netapp.com>
Subject: Re: rapid clustered nfs server failover and hung clients --  how
	best to close the sockets?
Message-ID: <20080609150105.6d1b76f9@tleilax.poochiereds.net>
In-Reply-To: <RTPCLUEXC1-PRDHtMFa000001d7@RTPMVEXC1-PRD.hq.netapp.com>
References: <20080609103137.2474aabd@tleilax.poochiereds.net>
	<484D6510.2010109@gmail.com>
	<20080609132425.5144557b@tleilax.poochiereds.net>
	<RTPCLUEXC1-PRDHtMFa000001d7@RTPMVEXC1-PRD.hq.netapp.com>
Cc: lhh@redhat.com, linux-nfs@vger.kernel.org,
        Wendy Cheng <s.wendy.cheng@gmail.com>, nfsv4@linux-nfs.org,
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

On Mon, 09 Jun 2008 13:51:05 -0400
"Talpey, Thomas" <Thomas.Talpey@netapp.com> wrote:

> At 01:24 PM 6/9/2008, Jeff Layton wrote:
> >
> >"Be sure to wait for X minutes between failovers"
> 
> At least one grace period.
> 

Actually, we have to wait until all of the sockets on the old server
time out. This is difficult to predict and can be quite long.

> >
> >...wouldn't instill me with a lot of confidence. We'd have to have
> >some sort of mechanism to enforce this, and that would be less than
> >ideal.
> >
> >IMO, the ideal thing would be to make sure that the "old" server is
> >ready to pick up the service again as soon as possible after the service
> >leaves it.
> 
> A great goal, but it seems to me you've bundled a lot of other
> incompatible requirements along with it. Having some services
> restart and not others, for example. And mixing transparent IP
> address takeover with stateful recovery such as TCP reconnect
> and NSM/NLM. NSM provides only notification, there's no way for
> either server to know for sure all the clients have completed
> either switch-to or switch-back.
> 

Thanks for the slides -- very interesting.

Yep. NSM is risky, but this is really the same situation as solo NFS
server spontaneously rebooting. The failover we're doing is really just
simulating that (for the case of lockd anyway). The unreliability is just
an unfortunate fact of life with NFSv2/3...

> Of course, you could switch to UDP-only, that would fix the
> TCP issue. But it won't fix NSM/NLM.
> 

Right. Nothing can really fix that so we just have to make do. All of
the NSM/NLM stuff here is really separate from the main problem I'm
interested in at the moment, which is how to deal with the old, stale
sockets that nfsd has open after the local address disappears.

-- 
Jeff Layton <jlayton@redhat.com>
_______________________________________________
NFSv4 mailing list
NFSv4@linux-nfs.org
http://linux-nfs.org/cgi-bin/mailman/listinfo/nfsv4

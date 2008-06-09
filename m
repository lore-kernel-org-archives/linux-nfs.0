Return-Path: <nfsv4-bounces@linux-nfs.org>
Date: Mon, 09 Jun 2008 13:51:05 -0400
To: Jeff Layton <jlayton@redhat.com>
From: "Talpey, Thomas" <Thomas.Talpey@netapp.com>
Subject: Re: rapid clustered nfs server failover and hung clients --
	how best to close the sockets?
In-Reply-To: <20080609132425.5144557b@tleilax.poochiereds.net>
References: <20080609103137.2474aabd@tleilax.poochiereds.net>
	<484D6510.2010109@gmail.com>
	<20080609132425.5144557b@tleilax.poochiereds.net>
Message-ID: <RTPCLUEXC1-PRDHtMFa000001d7@RTPMVEXC1-PRD.hq.netapp.com>
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

At 01:24 PM 6/9/2008, Jeff Layton wrote:
>
>"Be sure to wait for X minutes between failovers"

At least one grace period.

>
>...wouldn't instill me with a lot of confidence. We'd have to have
>some sort of mechanism to enforce this, and that would be less than
>ideal.
>
>IMO, the ideal thing would be to make sure that the "old" server is
>ready to pick up the service again as soon as possible after the service
>leaves it.

A great goal, but it seems to me you've bundled a lot of other
incompatible requirements along with it. Having some services
restart and not others, for example. And mixing transparent IP
address takeover with stateful recovery such as TCP reconnect
and NSM/NLM. NSM provides only notification, there's no way for
either server to know for sure all the clients have completed
either switch-to or switch-back.

Of course, you could switch to UDP-only, that would fix the
TCP issue. But it won't fix NSM/NLM.

Tom.

_______________________________________________
NFSv4 mailing list
NFSv4@linux-nfs.org
http://linux-nfs.org/cgi-bin/mailman/listinfo/nfsv4

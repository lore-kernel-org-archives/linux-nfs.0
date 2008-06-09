Return-Path: <nfsv4-bounces@linux-nfs.org>
Date: Mon, 09 Jun 2008 12:09:48 -0400
To: Jeff Layton <jlayton@redhat.com>
From: "Talpey, Thomas" <Thomas.Talpey@netapp.com>
Subject: Re: rapid clustered nfs server failover and hung clients --
	how best to	close the sockets?
In-Reply-To: <20080609120110.1fee7221@tleilax.poochiereds.net>
References: <20080609103137.2474aabd@tleilax.poochiereds.net>
	<484D4659.9000105@redhat.com>
	<20080609111821.6e06d4f8@tleilax.poochiereds.net>
	<RTPCLUEXC1-PRDOLZCH000001d2@RTPMVEXC1-PRD.hq.netapp.com>
	<20080609120110.1fee7221@tleilax.poochiereds.net>
Message-ID: <RTPCLUEXC1-PRDF8Eqf000001d4@RTPMVEXC1-PRD.hq.netapp.com>
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

At 12:01 PM 6/9/2008, Jeff Layton wrote:
>On Mon, 09 Jun 2008 11:51:51 -0400
>"Talpey, Thomas" <Thomas.Talpey@netapp.com> wrote:
>
>> At 11:18 AM 6/9/2008, Jeff Layton wrote:
>> >No, it's not specific to NFS. It can happen to any "service" that
>> >floats IP addresses between machines, but does not close the sockets
>> >that are connected to those addresses. Most services that fail over
>> >(at least in RH's cluster server) shut down the daemons on failover
>> >too, so tends to mitigate this problem elsewhere.
>> 
>> Why exactly don't you choose to restart the nfsd's (and lockd's) on the
>> victim server?
>
>The victim server might have other nfsd/lockd's running on them. Stopping
>all the nfsd's could bring down lockd, and then you have to deal with lock
>recovery on the stuff that isn't moving to the other server.

But but but... the IP address is the only identification the client can use
to isolate a server. You're telling me that some locks will migrate and
some won't? Good luck with that! The clients are going to be mightily
confused.

>
>> Failing that, for TCP at least would ifdown/ifup accomplish
>> the socket reset?
>> 
>
>I don't think ifdown/ifup closes the sockets, but maybe someone can
>correct me on this...

No, it doesn't close the sockets, but it sends interface-down status to them.
The nfsd's, in theory, should close the sockets in response. But, it's possible
(probable?) that nfsd may ignore this, and do nothing. It's just an idea.

Tom.

_______________________________________________
NFSv4 mailing list
NFSv4@linux-nfs.org
http://linux-nfs.org/cgi-bin/mailman/listinfo/nfsv4

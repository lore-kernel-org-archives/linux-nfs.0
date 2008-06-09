Return-Path: <nfsv4-bounces@linux-nfs.org>
Date: Mon, 09 Jun 2008 15:13:06 -0400
To: Jeff Layton <jlayton@redhat.com>
From: "Talpey, Thomas" <Thomas.Talpey@netapp.com>
Subject: Re: rapid clustered nfs server failover and hung clients --
	how best to close the sockets?
In-Reply-To: <20080609150105.6d1b76f9@tleilax.poochiereds.net>
References: <20080609103137.2474aabd@tleilax.poochiereds.net>
	<484D6510.2010109@gmail.com>
	<20080609132425.5144557b@tleilax.poochiereds.net>
	<RTPCLUEXC1-PRDHtMFa000001d7@RTPMVEXC1-PRD.hq.netapp.com>
	<20080609150105.6d1b76f9@tleilax.poochiereds.net>
Message-ID: <RTPCLUEXC1-PRDFRaqb000001db@RTPMVEXC1-PRD.hq.netapp.com>
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

At 03:01 PM 6/9/2008, Jeff Layton wrote:
>On Mon, 09 Jun 2008 13:51:05 -0400
>"Talpey, Thomas" <Thomas.Talpey@netapp.com> wrote:
>
>> At 01:24 PM 6/9/2008, Jeff Layton wrote:
>> >
>> >"Be sure to wait for X minutes between failovers"
>> 
>> At least one grace period.
>> 
>
>Actually, we have to wait until all of the sockets on the old server
>time out. This is difficult to predict and can be quite long.

I just gave the floor. The ceiling is yours. :-)

Orphaned server TCP sockets, btw, in general last forever without keepalive.
Even with keepalive, they can last many tens of minutes.

Tom.

_______________________________________________
NFSv4 mailing list
NFSv4@linux-nfs.org
http://linux-nfs.org/cgi-bin/mailman/listinfo/nfsv4

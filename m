Return-Path: <nfsv4-bounces@linux-nfs.org>
Date: Mon, 09 Jun 2008 13:59:03 -0400
To: Jeff Layton <jlayton@redhat.com>
From: "Talpey, Thomas" <Thomas.Talpey@netapp.com>
Subject: Re: rapid clustered nfs server failover and hung clients --
	how best to close the sockets?
In-Reply-To: <RTPCLUEXC1-PRDHtMFa000001d7@RTPMVEXC1-PRD.hq.netapp.com>
References: <20080609103137.2474aabd@tleilax.poochiereds.net>
	<484D6510.2010109@gmail.com>
	<20080609132425.5144557b@tleilax.poochiereds.net>
	<RTPCLUEXC1-PRDHtMFa000001d7@RTPMVEXC1-PRD.hq.netapp.com>
Message-ID: <RTPCLUEXC1-PRDukyCK000001d8@RTPMVEXC1-PRD.hq.netapp.com>
Cc: linux-nfs@vger.kernel.org, lhh@redhat.com, nfsv4@linux-nfs.org,
        nhorman@redhat.com, Wendy Cheng <s.wendy.cheng@gmail.com>
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

At 01:51 PM 6/9/2008, Talpey, Thomas wrote:
>and NSM/NLM. NSM provides only notification, there's no way for
>either server to know for sure all the clients have completed
>either switch-to or switch-back.

Just in case it helps to understand why relying on NSM is so risky:

	<http://www.connectathon.org/talks06/talpey-cthon06-nsm.pdf>

Slides 16, 17 and 23, especially.

Tom.

_______________________________________________
NFSv4 mailing list
NFSv4@linux-nfs.org
http://linux-nfs.org/cgi-bin/mailman/listinfo/nfsv4

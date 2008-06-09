Return-Path: <nfsv4-bounces@linux-nfs.org>
Message-ID: <484D6510.2010109@gmail.com>
Date: Mon, 09 Jun 2008 13:14:56 -0400
From: Wendy Cheng <s.wendy.cheng@gmail.com>
To: Jeff Layton <jlayton@redhat.com>
Subject: Re: rapid clustered nfs server failover and hung clients -- how best
	to close the sockets?
References: <20080609103137.2474aabd@tleilax.poochiereds.net>
In-Reply-To: <20080609103137.2474aabd@tleilax.poochiereds.net>
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

Jeff Layton wrote:
> The problem we've run into is that occasionally they fail over to the
> alternate machine and then back very rapidly. 

It is a well known issue in the NFS-TCP failover arena (or more 
specifically, for floating IP applications) that failover from server A 
to server B, then immediately failing back from server B to A would 
*not* work well. IIRC last round of discussing with Red Hat GPS and 
support folks, we concluded that most of the applications/users *can* 
tolerate this restriction.

Maybe another more basic question: "other than QA efforts, are there 
real NFSv2/v3 applications depending on this "feature" ? Or there may 
need tons of efforts for something that will not have much usages when 
it is finally delivered ?

-- Wendy



_______________________________________________
NFSv4 mailing list
NFSv4@linux-nfs.org
http://linux-nfs.org/cgi-bin/mailman/listinfo/nfsv4

Return-Path: <nfsv4-bounces@linux-nfs.org>
Date: Mon, 9 Jun 2008 14:07:32 -0400
From: Neil Horman <nhorman@redhat.com>
To: Wendy Cheng <s.wendy.cheng@gmail.com>
Subject: Re: rapid clustered nfs server failover and hung clients -- how best
	to close the sockets?
Message-ID: <20080609180732.GH20181@hmsendeavour.rdu.redhat.com>
References: <20080609103137.2474aabd@tleilax.poochiereds.net>
	<484D6510.2010109@gmail.com>
In-Reply-To: <484D6510.2010109@gmail.com>
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

On Mon, Jun 09, 2008 at 01:14:56PM -0400, Wendy Cheng wrote:
> Jeff Layton wrote:
> >The problem we've run into is that occasionally they fail over to the
> >alternate machine and then back very rapidly. 
> 
> It is a well known issue in the NFS-TCP failover arena (or more 
> specifically, for floating IP applications) that failover from server A 
> to server B, then immediately failing back from server B to A would
> *not* work well. IIRC last round of discussing with Red Hat GPS and 
> support folks, we concluded that most of the applications/users *can* 
> tolerate this restriction.

I think the big problem here is that this restriction has a window that can be
particularly long lived.  If an application doesn't close its sockets, the time
between a failover event, and the time when it is safe to fail back, is bounded
by the lifetime of the socket on the 'failed' server.  given the right
configuration, this could be indefinite.  Worse, you could fail at just the
wrong time after the sequence number wraps completely, and pickup where you left
off, not knowing you lost 4GB of data in the process.


> 
> Maybe another more basic question: "other than QA efforts, are there 
> real NFSv2/v3 applications depending on this "feature" ? Or there may 
> need tons of efforts for something that will not have much usages when 
> it is finally delivered ?
> 
> -- Wendy
> 
> 
> 

-- 
/***************************************************
 *Neil Horman
 *Software Engineer
 *Red Hat, Inc.
 *nhorman@redhat.com
 *gpg keyid: 1024D / 0x92A74FA1
 *http://pgp.mit.edu
 ***************************************************/
_______________________________________________
NFSv4 mailing list
NFSv4@linux-nfs.org
http://linux-nfs.org/cgi-bin/mailman/listinfo/nfsv4

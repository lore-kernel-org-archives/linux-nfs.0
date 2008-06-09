Return-Path: <nfsv4-bounces@linux-nfs.org>
Date: Mon, 9 Jun 2008 13:24:25 -0400
From: Jeff Layton <jlayton@redhat.com>
To: Wendy Cheng <s.wendy.cheng@gmail.com>
Subject: Re: rapid clustered nfs server failover and hung clients -- how
	best to close the sockets?
Message-ID: <20080609132425.5144557b@tleilax.poochiereds.net>
In-Reply-To: <484D6510.2010109@gmail.com>
References: <20080609103137.2474aabd@tleilax.poochiereds.net>
	<484D6510.2010109@gmail.com>
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

On Mon, 09 Jun 2008 13:14:56 -0400
Wendy Cheng <s.wendy.cheng@gmail.com> wrote:

> Jeff Layton wrote:
> > The problem we've run into is that occasionally they fail over to the
> > alternate machine and then back very rapidly. 
> 
> It is a well known issue in the NFS-TCP failover arena (or more 
> specifically, for floating IP applications) that failover from server A 
> to server B, then immediately failing back from server B to A would 
> *not* work well. IIRC last round of discussing with Red Hat GPS and 
> support folks, we concluded that most of the applications/users *can* 
> tolerate this restriction.
> 
> Maybe another more basic question: "other than QA efforts, are there 
> real NFSv2/v3 applications depending on this "feature" ? Or there may 
> need tons of efforts for something that will not have much usages when 
> it is finally delivered ?
> 

Certainly a valid question...

While rapid failover like this is unusual, it's easily possible for a
sysadmin to do it. Maybe they moved the wrong service, or their downtime
was for something very brief but the service had to be off of the host to
make the change. In that case, a quick failover and back could easily
be something that happens in a real environment.

As to whether it's worth a ton of effort, that's a tough call. People want
HA services to guard against outages. Anything that jeopardizes that is
probably worth fixing. This could be solved with documentation, but a note
like:

"Be sure to wait for X minutes between failovers"

...wouldn't instill me with a lot of confidence. We'd have to have
some sort of mechanism to enforce this, and that would be less than
ideal.

IMO, the ideal thing would be to make sure that the "old" server is
ready to pick up the service again as soon as possible after the service
leaves it.

-- 
Jeff Layton <jlayton@redhat.com>
_______________________________________________
NFSv4 mailing list
NFSv4@linux-nfs.org
http://linux-nfs.org/cgi-bin/mailman/listinfo/nfsv4

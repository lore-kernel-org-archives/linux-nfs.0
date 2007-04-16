From: "Mike Snitzer" <snitzer@gmail.com>
Subject: Re: [NFS] Merge plans for RPC/RDMA? (Was: Re: [PATCH 000 of 14] knfsd: Preparation for IPv6 support in NFS server.)
Date: Mon, 16 Apr 2007 10:48:49 -0400
Message-ID: <170fa0d20704160748m60503365q5be2beba591a9f@mail.gmail.com>
References: <170fa0d20704131347u4a28b5d1h1959227980449fbf@mail.gmail.com>
	 <1176502465.6394.26.camel@heimdal.trondhjem.org>
	 <170fa0d20704142040w204a715bgf5ce772e67126bbd@mail.gmail.com>
	 <Pine.LNX.4.64.0704161002200.7869@jlentini-linux.nane.netapp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Cc: "Trond Myklebust" <trond.myklebust@fys.uio.no>,
	chuck.lever@oracle.com, NeilBrown <neilb@suse.de>,
	"Andrew Morton" <akpm@osdl.org>,
	"Roland Dreier" <rdreier@cisco.com>, nfs@lists.sourceforge.net,
	linux-kernel@vger.kernel.org,
	"Tom Tucker" <tom@opengridcomputing.com>, Thomas.Talpey@netapp.com,
	"Or Gerlitz" <ogerlitz@voltaire.com>
To: "James Lentini" <jlentini@netapp.com>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1752795AbXDPOsw@vger.kernel.org>
In-Reply-To: <Pine.LNX.4.64.0704161002200.7869@jlentini-linux.nane.netapp.com>
Sender: linux-kernel-owner@vger.kernel.org
List-ID: <nfs.lists.sourceforge.net>

On 4/16/07, James Lentini <jlentini@netapp.com> wrote:
>
>
> On Sat, 14 Apr 2007, Mike Snitzer wrote:
>
> > I'm interested in understanding why the reluctance to push for a merge
> > now (let alone some months ago) given the various successes that have
> > been seen with the NFS/RDMA effort (Sandia, SC '06, as Chuck noted:
> > good performance at various test sites).  If the code is holding up
> > well why the delay in review and merging?  And rather than wait for
> > the remaining transport switch patches; why not look to merge all of
> > NFS/RDMA (client) work at the same time?
>
> There is no reluctance to submit the NFS-RDMA code for review. There
> have been several upstream changes to the NFS server recently. We
> (NetApp and Tom Tucker at OGC) are working on a new patchset for
> NFS-RDMA that is compatible with these changes. We are testing the
> code now.
>
> We will post the patches for review when we finish updating them.

Thanks for the clarification.  It was unfair of me to imply any amount
of "reluctance" to submit the NFS/RDMA code for review.  I was just
trying to gauge the "real soon now" type posts we've seen over the
past few months.  If anything I'd imagine the latest NFS churn has
given you additional incentive to merge.

Thanks for your continued hard work; NFS/RDMA looks to be a huge
improvement for modern NFS deployments.

regards,
Mike

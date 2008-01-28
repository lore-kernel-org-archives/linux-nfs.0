From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: nfs server patches for 2.6.25
Date: Sun, 27 Jan 2008 22:15:02 -0500
Message-ID: <20080128031502.GB22503@fieldses.org>
References: <20080125231521.GG25141@fieldses.org>
	<1201466543.5006.21.camel@odie.local>
	<20080127221017.GC597@fieldses.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: linux-nfs@vger.kernel.org, nfsv4@linux-nfs.org,
	linux-kernel@vger.kernel.org, Tom Tucker <tom@opengridcomputing.com>
To: Simon Holm =?utf-8?Q?Th=C3=B8gersen?= <odie@cs.aau.dk>
Return-path: <nfsv4-bounces@linux-nfs.org>
In-Reply-To: <20080127221017.GC597@fieldses.org>
List-Unsubscribe: <http://linux-nfs.org/cgi-bin/mailman/listinfo/nfsv4>,
	<mailto:nfsv4-request@linux-nfs.org?subject=unsubscribe>
List-Archive: <http://linux-nfs.org/pipermail/nfsv4>
List-Post: <mailto:nfsv4@linux-nfs.org>
List-Help: <mailto:nfsv4-request@linux-nfs.org?subject=help>
List-Subscribe: <http://linux-nfs.org/cgi-bin/mailman/listinfo/nfsv4>,
	<mailto:nfsv4-request@linux-nfs.org?subject=subscribe>
Sender: nfsv4-bounces@linux-nfs.org
Errors-To: nfsv4-bounces@linux-nfs.org
List-ID: <linux-nfs.vger.kernel.org>

On Sun, Jan 27, 2008 at 05:10:17PM -0500, bfields wrote:
> OK.  I've got a machine running
> 
> 	for c in $(git rev-list origin..linux-nfs/nfs-server-stable^); do
> 		git checkout $c
> 		make -s -j4
> 	done
> 
> now just to make sure....  Thanks again!

Pfft, that should have been:

	for c in $(git rev-list --reverse origin..linux-nfs/nfs-server-stable^); do
		git checkout $c
		make -s -j4
	done

The results are a lot easier to understand if you do the compiles
in chronological order!

Anyway, that found one more compile failure, now fixed.  Hopefully
that's the last.  (Probably I did an incomplete job of reordering one of
the patches the other week....)

--b.

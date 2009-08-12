Return-Path: <nfsv4-bounces@linux-nfs.org>
Date: Tue, 11 Aug 2009 22:43:41 -0400
To: Trond Myklebust <Trond.Myklebust@netapp.com>
Subject: Re: [PATCH 0/3] Fix the Linux rpc-over-tcp server performance
Message-ID: <20090812024341.GA3227@fieldses.org>
References: <20090518214756.786.28129.stgit@heimdal.trondhjem.org>
In-Reply-To: <20090518214756.786.28129.stgit@heimdal.trondhjem.org>
From: "J. Bruce Fields" <bfields@fieldses.org>
Cc: linux-nfs@vger.kernel.org, nfsv4@linux-nfs.org,
        Jeff Moyer <jmoyer@redhat.com>
List-Unsubscribe: <http://linux-nfs.org/cgi-bin/mailman/options/nfsv4>,
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

On Mon, May 18, 2009 at 05:47:56PM -0400, Trond Myklebust wrote:
> I squashed the previous set of 4 incremental patches into 3. Otherwise
> there should be no differences w.r.t. the set that Jeff tested.

Apologies for the long delay.... Unfortunately, I can't reproduce any of
this at all: I reliably get about 112MB/s regardless of what combination
of these patches I apply (including none).  This is over gigabit
ethernet to a server exporting a filesystem on raid 0 over 3 sata disks
which iozone locally reports getting just over 200MB/s reads from.

Any suggestions?

--b.
_______________________________________________
NFSv4 mailing list
NFSv4@linux-nfs.org
http://linux-nfs.org/cgi-bin/mailman/listinfo/nfsv4

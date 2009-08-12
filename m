From: Trond Myklebust <Trond.Myklebust@netapp.com>
Subject: Re: [PATCH 0/3] Fix the Linux rpc-over-tcp server performance
Date: Wed, 12 Aug 2009 18:40:01 -0400
Message-ID: <1250116801.5973.49.camel@heimdal.trondhjem.org>
References: <20090518214756.786.28129.stgit@heimdal.trondhjem.org>
	<20090812024341.GA3227@fieldses.org>
	<x49ab25w4ja.fsf@segfault.boston.devel.redhat.com>
	<20090812142041.GA12753@fieldses.org>
	<x491vnhvucq.fsf@segfault.boston.devel.redhat.com>
	<20090812223258.GE17782@fieldses.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: Jeff Moyer <jmoyer@redhat.com>, nfsv4@linux-nfs.org,
	linux-nfs@vger.kernel.org
To: "J. Bruce Fields" <bfields@fieldses.org>
Return-path: <nfsv4-bounces@linux-nfs.org>
In-Reply-To: <20090812223258.GE17782@fieldses.org>
List-Unsubscribe: <http://linux-nfs.org/cgi-bin/mailman/options/nfsv4>,
	<mailto:nfsv4-request@linux-nfs.org?subject=unsubscribe>
List-Archive: <http://linux-nfs.org/pipermail/nfsv4>
List-Post: <mailto:nfsv4@linux-nfs.org>
List-Help: <mailto:nfsv4-request@linux-nfs.org?subject=help>
List-Subscribe: <http://linux-nfs.org/cgi-bin/mailman/listinfo/nfsv4>,
	<mailto:nfsv4-request@linux-nfs.org?subject=subscribe>
Sender: nfsv4-bounces@linux-nfs.org
Errors-To: nfsv4-bounces@linux-nfs.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, 2009-08-12 at 18:32 -0400, J. Bruce Fields wrote:
> For each test, I'm booting both client and server to the given kernel,
> running
> 
> 	mount server:/exports/ /mnt/
> 	iozone -s 2000000 -r 64 -f /mnt/testfile -w -i1
> 	umount /mnt/
> 
> five times, then taking the average of the "read" columns.  (I could
> stick to one client--not sure which you were using.  Installing new
> kernels on both is just what my existing test scripts happened to do by
> default.)
> 
> 2.6.30-rc1:				114113
> 2.6.30-rc1 + revert autotuning:		114159
> 2.6.30-rc1 + patch 1:			114168
> 2.6.30-rc1 + patch 1 & 2:		114136
> 2.6.30-rc1 + patch 1, 2, & 3:		114149

My tests were made using hammerfest as the server: it would see fairly
long stalls when it was running basic 2.6.30-rc1 w/ autotuning. Feel
free to co-opt it for your testing...

-- 
Trond Myklebust
Linux NFS client maintainer

NetApp
Trond.Myklebust@netapp.com
www.netapp.com

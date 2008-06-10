From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: [PATCH 4/5] knfsd: convert knfsd to kthread API
Date: Tue, 10 Jun 2008 12:25:26 -0400
Message-ID: <20080610162526.GE20184@fieldses.org>
References: <1213101639-26423-1-git-send-email-jlayton@redhat.com>
	<1213101639-26423-2-git-send-email-jlayton@redhat.com>
	<1213101639-26423-3-git-send-email-jlayton@redhat.com>
	<1213101639-26423-4-git-send-email-jlayton@redhat.com>
	<1213101639-26423-5-git-send-email-jlayton@redhat.com>
	<20080610162426.GD20184@fieldses.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: linux-nfs@vger.kernel.org, nfsv4@linux-nfs.org, gnb@melbourne.sgi.com
To: Jeff Layton <jlayton@redhat.com>
Return-path: <nfsv4-bounces@linux-nfs.org>
In-Reply-To: <20080610162426.GD20184@fieldses.org>
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

On Tue, Jun 10, 2008 at 12:24:26PM -0400, bfields wrote:
> On Tue, Jun 10, 2008 at 08:40:38AM -0400, Jeff Layton wrote:
> In fact, I don't think you really need to take a reference till there's
> a chance the new thread will decrement the reference--and since the
> first thing the new thread does is take the mutex (which we're also
> holding here), you could wait till after the succesful kthread_create()
> to take the reference.  But maybe that's more fragile.  So I'd just
> move the module_get to right before the kthread_create().

Anyway, that's very minor, and this all seems OK otherwise, so I might
make this one small modification and just apply if there's no further
comments.

--b.

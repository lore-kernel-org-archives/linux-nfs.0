From: Wendy Cheng <wcheng@redhat.com>
Subject: Re: [RFC] NLM lock failover admin interface
Date: Mon, 12 Jun 2006 02:11:04 -0400
Message-ID: <1150092664.26180.19.camel@localhost.localdomain>
References: <1150089943.26019.18.camel@localhost.localdomain>
Reply-To: linux clustering <linux-cluster@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: nfs@lists.sourceforge.net
Return-path: <linux-cluster-bounces@redhat.com>
To: linux clustering <linux-cluster@redhat.com>
In-Reply-To: <1150089943.26019.18.camel@localhost.localdomain>
List-Unsubscribe: <https://www.redhat.com/mailman/listinfo/linux-cluster>,
	<mailto:linux-cluster-request@redhat.com?subject=unsubscribe>
List-Archive: <https://www.redhat.com/archives/linux-cluster>
List-Post: <mailto:linux-cluster@redhat.com>
List-Help: <mailto:linux-cluster-request@redhat.com?subject=help>
List-Subscribe: <https://www.redhat.com/mailman/listinfo/linux-cluster>,
	<mailto:linux-cluster-request@redhat.com?subject=subscribe>
Sender: linux-cluster-bounces@redhat.com
Errors-To: linux-cluster-bounces@redhat.com
List-ID: <nfs.lists.sourceforge.net>

On Mon, 2006-06-12 at 01:25 -0400, Wendy Cheng wrote:
> NFS v2/v3 active-active NLM lock failover has been an issue with our
> cluster suite. With current implementation, it (cluster suite) is trying
> to carry the workaround as much as it can with user mode scripts where,
> upon failover, on taken-over server, it:
> 
> 1. Tear down virtual IP.
> 2. Unexport the subject NFS export.
> 3. Signal lockd to drop the locks.
> 4. Un-mount filesystem if needed.
> 
> There are many other issues (such as /var/lib/nfs/statd/sm file, etc)
> but this particular post is to further refine step 3 to avoid the 50
> second global (default) grace period for all NFS exports; i.e., we would
> like to be able to selectively drop locks (only) associated with the
> requested exports without disrupting other NFS services. 
> 
> We've done some prototype (coding) works but would like to search for
> community consensus on the admin interface if possible. 

While ping-pong the emails with our base kernel folks to choose
between /proc, or exportfs, or nfsctl (internally within the company -
mostly with steved and staubach), Peter suggested to try out multiple
lockd(s) to handle different NFS exports. In that case, we may require
to change a big portion of lockd kernel code. I prefer not going that
far since lockd failover is our cluster suite's immediate issue.
However, if this approach can get everyone's vote, we'll comply.

-- Wendy

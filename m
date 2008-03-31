From: Trond Myklebust <Trond.Myklebust@netapp.com>
Subject: Re: [PATCH] NFS: initialize flags field in nfs_open_context
Date: Mon, 31 Mar 2008 18:12:13 -0400
Message-ID: <1207001533.15341.4.camel@heimdal.trondhjem.org>
References: <1206990118-28183-1-git-send-email-jlayton@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: linux-nfs@vger.kernel.org, nfsv4@linux-nfs.org
To: Jeff Layton <jlayton@redhat.com>
Return-path: <nfsv4-bounces@linux-nfs.org>
In-Reply-To: <1206990118-28183-1-git-send-email-jlayton@redhat.com>
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


On Mon, 2008-03-31 at 15:01 -0400, Jeff Layton wrote:
> The nfs_open_context struct had a "flags" field added recently, but the
> allocator isn't initializing it. It also looks like the allocator isn't
> initializing the mode or list either, but they seem to be overwritten
> by the caller, so that's less of an issue.
> 
> Signed-off-by: Jeff Layton <jlayton@redhat.com>

Thanks Jeff!

-- 
Trond Myklebust
Linux NFS client maintainer

NetApp
Trond.Myklebust@netapp.com
www.netapp.com

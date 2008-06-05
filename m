From: Greg Banks <gnb@melbourne.sgi.com>
Subject: Re: [PATCH 4/4] sunrpc: remove unneeded field from svc_serv struct
Date: Thu, 05 Jun 2008 11:30:21 +1000
Message-ID: <484741AD.5040705@melbourne.sgi.com>
References: <1212591796-22144-1-git-send-email-jlayton@redhat.com>
	<1212591796-22144-2-git-send-email-jlayton@redhat.com>
	<1212591796-22144-3-git-send-email-jlayton@redhat.com>
	<1212591796-22144-4-git-send-email-jlayton@redhat.com>
	<1212591796-22144-5-git-send-email-jlayton@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: linux-nfs@vger.kernel.org, nfsv4@linux-nfs.org
To: Jeff Layton <jlayton@redhat.com>
Return-path: <nfsv4-bounces@linux-nfs.org>
In-Reply-To: <1212591796-22144-5-git-send-email-jlayton@redhat.com>
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

Jeff Layton wrote:
> Remove the sv_module field from the svc_serv struct since
> svc_set_num_threads doesn't bother with module reference
> counts anymore.
>
> Signed-off-by: Jeff Layton <jlayton@redhat.com>
>   
Acked-by: Greg Banks <gnb@melbourne.sgi.com>

-- 
Greg Banks, P.Engineer, SGI Australian Software Group.
The cake is *not* a lie.
I don't speak for SGI.

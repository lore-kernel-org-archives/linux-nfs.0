From: "Labiaga, Ricardo" <Ricardo.Labiaga@netapp.com>
Subject: RE: [pnfs] [RFC 11/39] nfs41: Backchannel callback service helper routines
Date: Fri, 5 Jun 2009 11:02:33 -0700
Message-ID: <273FE88A07F5D445824060902F7003440612B8B5@SACMVEXC1-PRD.hq.netapp.com>
References: <1244146842.5203.101.camel@heimdal.trondhjem.org>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Cc: <linux-nfs@vger.kernel.org>, <pnfs@linux-nfs.org>
To: "Myklebust, Trond" <Trond.Myklebust@netapp.com>,
	"Benny Halevy" <bhalevy@panasas.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:6077 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754626AbZFESFR convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 5 Jun 2009 14:05:17 -0400
In-Reply-To: <1244146842.5203.101.camel-rJ7iovZKK19ZJLDQqaL3InhyD016LWXt@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

> -----Original Message-----
> From: Myklebust, Trond
> Sent: Thursday, June 04, 2009 1:21 PM
> To: Benny Halevy
> Cc: linux-nfs@vger.kernel.org; pnfs@linux-nfs.org
> Subject: Re: [pnfs] [RFC 11/39] nfs41: Backchannel callback service
helper
> routines
> 
> On Fri, 2009-05-01 at 02:20 +0300, Benny Halevy wrote:
> > From: Ricardo Labiaga <Ricardo.Labiaga@netapp.com>
> >
> > Executes the backchannel task on the RPC state machine using
> > the existing open connection previously established by the client.
> >
> > Signed-off-by: Ricardo Labiaga <ricardo.labiaga@netapp.com>
> >
> > nfs41: Add bc_svc.o to sunrpc Makefile.
> >
> > [nfs41: bc_send() does not need to be exported outside RPC module]
> > [nfs41: xprt_free_bc_request() need not be exported outside RPC
module]
> > Signed-off-by: Ricardo Labiaga <Ricardo.Labiaga@netapp.com>
> > Signed-off-by: Benny Halevy <bhalevy@panasas.com>
> > ---
> >  include/linux/sunrpc/bc_xprt.h |    3 +
> >  net/sunrpc/Makefile            |    2 +-
> >  net/sunrpc/backchannel_rqst.c  |    1 -
> >  net/sunrpc/bc_svc.c            |   80
> ++++++++++++++++++++++++++++++++++++++++
> >  net/sunrpc/xprtsock.c          |    3 +
> >  5 files changed, 87 insertions(+), 2 deletions(-)
> >  create mode 100644 net/sunrpc/bc_svc.c
> >
> > diff --git a/include/linux/sunrpc/bc_xprt.h
> b/include/linux/sunrpc/bc_xprt.h
> > index 1c1746a..3016c00 100644
> > --- a/include/linux/sunrpc/bc_xprt.h
> > +++ b/include/linux/sunrpc/bc_xprt.h
> > @@ -29,12 +29,15 @@ SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF
SUCH
> DAMAGE.
> >
> >  #include <linux/sunrpc/svcsock.h>
> >  #include <linux/sunrpc/xprt.h>
> > +#include <linux/sunrpc/sched.h>
> >
> >  #ifdef CONFIG_NFS_V4_1
> >  struct rpc_rqst *xprt_alloc_bc_request(struct rpc_xprt *xprt);
> >  void xprt_free_bc_request(struct rpc_rqst *req);
> >  int xprt_setup_backchannel(struct rpc_xprt *, unsigned int
min_reqs);
> >  void xprt_destroy_backchannel(struct rpc_xprt *, int max_reqs);
> > +void bc_release_request(struct rpc_task *);
> > +int bc_send(struct rpc_rqst *req);
> >  #else /* CONFIG_NFS_V4_1 */
> >  static inline int xprt_setup_backchannel(struct rpc_xprt *xprt,
> >  					 unsigned int min_reqs)
> > diff --git a/net/sunrpc/Makefile b/net/sunrpc/Makefile
> > index 4a01f96..db73fd2 100644
> > --- a/net/sunrpc/Makefile
> > +++ b/net/sunrpc/Makefile
> > @@ -13,6 +13,6 @@ sunrpc-y := clnt.o xprt.o socklib.o xprtsock.o
sched.o
> \
> >  	    rpcb_clnt.o timer.o xdr.o \
> >  	    sunrpc_syms.o cache.o rpc_pipe.o \
> >  	    svc_xprt.o
> > -sunrpc-$(CONFIG_NFS_V4_1) += backchannel_rqst.o
> > +sunrpc-$(CONFIG_NFS_V4_1) += backchannel_rqst.o bc_svc.o
> >  sunrpc-$(CONFIG_PROC_FS) += stats.o
> >  sunrpc-$(CONFIG_SYSCTL) += sysctl.o
> > diff --git a/net/sunrpc/backchannel_rqst.c
> b/net/sunrpc/backchannel_rqst.c
> > index 7d7708a..92fb3bd 100644
> > --- a/net/sunrpc/backchannel_rqst.c
> > +++ b/net/sunrpc/backchannel_rqst.c
> > @@ -265,6 +265,5 @@ void xprt_free_bc_request(struct rpc_rqst *req)
> >  	list_add(&req->rq_bc_pa_list, &xprt->bc_pa_list);
> >  	spin_unlock_bh(&xprt->bc_pa_lock);
> >  }
> > -EXPORT_SYMBOL(xprt_free_bc_request);
> 
> Err.... That's random... What is there in this patch that suddenly
makes
> the export unnecessary?
> 

Squashing mistake.  We should have never exported the
'xprt_free_bc_request' symbol since it is not needed outside sunrpc.
We'll update patch 0007 to remove the EXPORT_SYMBOL all together.

> >  #endif /* CONFIG_NFS_V4_1 */
> > diff --git a/net/sunrpc/bc_svc.c b/net/sunrpc/bc_svc.c
> > new file mode 100644
> > index 0000000..b13f51d
> > --- /dev/null
> > +++ b/net/sunrpc/bc_svc.c
> > @@ -0,0 +1,80 @@
> >
>
+/**********************************************************************
**
> ******
> > +
> > +(c) 2007 Network Appliance, Inc.  All Rights Reserved.
> 
> More references to historic entities...
> 

We'll update.

- ricardo

> > +
> > +Network Appliance provides this source code under the GPL v2
License.
> > +The GPL v2 license is available at
> > +http://opensource.org/licenses/gpl-license.php.
> > +
> > +THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
> > +"AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT
> > +LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS
FOR
> > +A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE
COPYRIGHT
> OWNER OR
> > +CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL,
SPECIAL,
> > +EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO,
> > +PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR
> > +PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY
OF
> > +LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
(INCLUDING
> > +NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
> > +SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
> > +
> >
>
+***********************************************************************
**
> *****/
> > +
> > +/*
> > + * The NFSv4.1 callback service helper routines.
> > + * They implement the transport level processing required to send
the
> > + * reply over an existing open connection previously established by
the
> client.
> > + */
> > +
> > +#if defined(CONFIG_NFS_V4_1)
> > +
> > +#include <linux/module.h>
> > +
> > +#include <linux/sunrpc/xprt.h>
> > +#include <linux/sunrpc/sched.h>
> > +#include <linux/sunrpc/bc_xprt.h>
> > +
> > +#define RPCDBG_FACILITY	RPCDBG_SVCDSP
> > +
> > +void bc_release_request(struct rpc_task *task)
> > +{
> > +	struct rpc_rqst *req = task->tk_rqstp;
> > +
> > +	dprintk("RPC:       bc_release_request: task= %p\n", task);
> > +
> > +	/*
> > +	 * Release this request only if it's a backchannel
> > +	 * preallocated request
> > +	 */
> > +	if (!bc_prealloc(req))
> > +		return;
> > +	xprt_free_bc_request(req);
> > +}
> > +
> > +/* Empty callback ops */
> > +static const struct rpc_call_ops nfs41_callback_ops = {
> > +};
> > +
> > +
> > +/*
> > + * Send the callback reply
> > + */
> > +int bc_send(struct rpc_rqst *req)
> > +{
> > +	struct rpc_task *task;
> > +	int ret;
> > +
> > +	dprintk("RPC:       bc_send req= %p\n", req);
> > +	task = rpc_run_bc_task(req, &nfs41_callback_ops);
> > +	if (IS_ERR(task))
> > +		ret = PTR_ERR(task);
> > +	else {
> > +		BUG_ON(atomic_read(&task->tk_count) != 1);
> > +		ret = task->tk_status;
> > +		rpc_put_task(task);
> > +	}
> > +	return ret;
> > +	dprintk("RPC:       bc_send ret= %d \n", ret);
> > +}
> > +
> > +#endif /* CONFIG_NFS_V4_1 */
> > diff --git a/net/sunrpc/xprtsock.c b/net/sunrpc/xprtsock.c
> > index 403ebda..5bf9e66 100644
> > --- a/net/sunrpc/xprtsock.c
> > +++ b/net/sunrpc/xprtsock.c
> > @@ -2145,6 +2145,9 @@ static struct rpc_xprt_ops xs_tcp_ops = {
> >  	.buf_free		= rpc_free,
> >  	.send_request		= xs_tcp_send_request,
> >  	.set_retrans_timeout	= xprt_set_retrans_timeout_def,
> > +#if defined(CONFIG_NFS_V4_1)
> > +	.release_request	= bc_release_request,
> > +#endif /* CONFIG_NFS_V4_1 */
> >  	.close			= xs_tcp_shutdown,
> >  	.destroy		= xs_destroy,
> >  	.print_stats		= xs_tcp_print_stats,
> 
> --
> Trond Myklebust
> Linux NFS client maintainer
> 
> NetApp
> Trond.Myklebust@netapp.com
> www.netapp.com
> _______________________________________________
> pNFS mailing list
> pNFS@linux-nfs.org
> http://linux-nfs.org/cgi-bin/mailman/listinfo/pnfs

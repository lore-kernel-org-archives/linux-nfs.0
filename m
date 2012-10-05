Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:27745 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756145Ab2JEOro (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 5 Oct 2012 10:47:44 -0400
Date: Fri, 5 Oct 2012 10:47:37 -0400
From: Jeff Layton <jlayton@redhat.com>
To: "J. Bruce Fields" <bfields@fieldses.org>
Cc: linux-nfs@vger.kernel.org
Subject: Re: [PATCH v2 1/3] nfsd: add a usermodehelper upcall for NFSv4
 client ID tracking
Message-ID: <20121005104737.32fe638d@corrin.poochiereds.net>
In-Reply-To: <20121005143610.GB15134@fieldses.org>
References: <1349268031-16498-1-git-send-email-jlayton@redhat.com>
	<1349268031-16498-2-git-send-email-jlayton@redhat.com>
	<20121005143610.GB15134@fieldses.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, 5 Oct 2012 10:36:10 -0400
"J. Bruce Fields" <bfields@fieldses.org> wrote:

> On Wed, Oct 03, 2012 at 08:40:29AM -0400, Jeff Layton wrote:
> > Add a new client tracker upcall type that uses call_usermodehelper to
> > call out to a program. This seems to be the preferred method of
> > calling out to usermode these days for seldom-called upcalls. It's
> > simple and doesn't require a running daemon, so it should "just work"
> > as long as the binary is installed.
> > 
> > The client tracking exit operation is also changed to check for a
> > NULL pointer before running. The UMH upcall doesn't need to do anything
> > at module teardown time.
> > 
> > Signed-off-by: Jeff Layton <jlayton@redhat.com>
> > ---
> >  fs/nfsd/nfs4recover.c | 139 +++++++++++++++++++++++++++++++++++++++++++++++++-
> >  1 file changed, 138 insertions(+), 1 deletion(-)
> > 
> > diff --git a/fs/nfsd/nfs4recover.c b/fs/nfsd/nfs4recover.c
> > index 43295d4..481cb3e 100644
> > --- a/fs/nfsd/nfs4recover.c
> > +++ b/fs/nfsd/nfs4recover.c
> > @@ -926,6 +926,142 @@ static struct nfsd4_client_tracking_ops nfsd4_cld_tracking_ops = {
> >  	.grace_done	= nfsd4_cld_grace_done,
> >  };
> >  
> > +/* upcall via usermodehelper */
> > +static char cltrack_prog[PATH_MAX] = "/sbin/nfsdcltrack";
> > +module_param_string(cltrack_prog, cltrack_prog, sizeof(cltrack_prog),
> > +			S_IRUGO|S_IWUSR);
> > +MODULE_PARM_DESC(cltrack_prog, "Path to the nfsdcltrack upcall program");
> > +
> > +static int
> > +nfsd4_cltrack_upcall(char *cmd, char *arg)
> > +{
> > +	char *envp[] = { "HOME=/",
> > +			"TERM=linux",
> > +			"PATH=/sbin:/usr/sbin:/bin:/usr/bin",
> 
> Dumb question: why does the upcall program need these environment
> variables?
> 
> --b.
> 

It probably doesn't. I copied this code from the osd_login upcall. I
think it sets those because the osd_login program is a shell script and
some of the stuff it calls expects them. We could probably remove
them here.

BTW, I agree that this code is probably best deferred until 3.8...

> > +			NULL
> > +	};
> > +	char *argv[4];
> > +	int ret;
> > +
> > +	if (unlikely(!cltrack_prog[0])) {
> > +		dprintk("%s: cltrack_prog is disabled\n", __func__);
> > +		return -EACCES;
> > +	}
> > +
> > +	dprintk("%s: cmd: %s\n", __func__, cmd);
> > +	dprintk("%s: arg: %s\n", __func__, arg ? arg : "(null)");
> > +
> > +	argv[0] = (char *)cltrack_prog;
> > +	argv[1] = cmd;
> > +	argv[2] = arg;
> > +	argv[3] = NULL;
> > +
> > +	ret = call_usermodehelper(argv[0], argv, envp, UMH_WAIT_PROC);
> > +	/*
> > +	 * Disable the upcall mechanism if we're getting an ENOENT
> > +	 * error. The admin can re-enable it on the fly by using sysfs
> > +	 * once the problem has been fixed.
> > +	 */
> > +	if (ret == -ENOENT || ret == -EACCES) {
> > +		printk(KERN_ERR "NFSD: %s was not found or isn't executable. "
> > +			"Please reset nfsd.cltrack_prog module parameter "
> > +			"once problem is resolved (%d)!\n",
> > +			cltrack_prog, ret);
> > +		cltrack_prog[0] = '\0';
> > +	}
> > +	dprintk("%s: %s return value: %d\n", __func__, cltrack_prog, ret);
> > +
> > +	return ret;
> > +}
> > +
> > +static char *
> > +bin_to_hex_dup(const unsigned char *src, int srclen)
> > +{
> > +	int i;
> > +	char *buf, *hex;
> > +
> > +	/* +1 for terminating NULL */
> > +	buf = kmalloc((srclen * 2) + 1, GFP_KERNEL);
> > +	if (!buf)
> > +		return buf;
> > +
> > +	hex = buf;
> > +	for (i = 0; i < srclen; i++) {
> > +		sprintf(hex, "%2.2x", *src++);
> > +		hex += 2;
> > +	}
> > +	return buf;
> > +}
> > +
> > +static int
> > +nfsd4_umh_cltrack_init(struct net __attribute__((unused)) *net)
> > +{
> > +	return nfsd4_cltrack_upcall("init", NULL);
> > +}
> > +
> > +static void
> > +nfsd4_umh_cltrack_create(struct nfs4_client *clp)
> > +{
> > +	char *hexid;
> > +
> > +	hexid = bin_to_hex_dup(clp->cl_name.data, clp->cl_name.len);
> > +	if (!hexid) {
> > +		dprintk("%s: can't allocate memory for upcall!\n", __func__);
> > +		return;
> > +	}
> > +	nfsd4_cltrack_upcall("create", hexid);
> > +	kfree(hexid);
> > +}
> > +
> > +static void
> > +nfsd4_umh_cltrack_remove(struct nfs4_client *clp)
> > +{
> > +	char *hexid;
> > +
> > +	hexid = bin_to_hex_dup(clp->cl_name.data, clp->cl_name.len);
> > +	if (!hexid) {
> > +		dprintk("%s: can't allocate memory for upcall!\n", __func__);
> > +		return;
> > +	}
> > +	nfsd4_cltrack_upcall("remove", hexid);
> > +	kfree(hexid);
> > +}
> > +
> > +static int
> > +nfsd4_umh_cltrack_check(struct nfs4_client *clp)
> > +{
> > +	int ret;
> > +	char *hexid;
> > +
> > +	hexid = bin_to_hex_dup(clp->cl_name.data, clp->cl_name.len);
> > +	if (!hexid) {
> > +		dprintk("%s: can't allocate memory for upcall!\n", __func__);
> > +		return -ENOMEM;
> > +	}
> > +	ret = nfsd4_cltrack_upcall("check", hexid);
> > +	kfree(hexid);
> > +	return ret;
> > +}
> > +
> > +static void
> > +nfsd4_umh_cltrack_grace_done(struct net __attribute__((unused)) *net,
> > +				time_t boot_time)
> > +{
> > +	char timestr[22]; /* FIXME: better way to determine max size? */
> > +
> > +	sprintf(timestr, "%ld", boot_time);
> > +	nfsd4_cltrack_upcall("gracedone", timestr);
> > +}
> > +
> > +static struct nfsd4_client_tracking_ops nfsd4_umh_tracking_ops = {
> > +	.init		= nfsd4_umh_cltrack_init,
> > +	.exit		= NULL,
> > +	.create		= nfsd4_umh_cltrack_create,
> > +	.remove		= nfsd4_umh_cltrack_remove,
> > +	.check		= nfsd4_umh_cltrack_check,
> > +	.grace_done	= nfsd4_umh_cltrack_grace_done,
> > +};
> > +
> >  int
> >  nfsd4_client_tracking_init(struct net *net)
> >  {
> > @@ -956,7 +1092,8 @@ void
> >  nfsd4_client_tracking_exit(struct net *net)
> >  {
> >  	if (client_tracking_ops) {
> > -		client_tracking_ops->exit(net);
> > +		if (client_tracking_ops->exit)
> > +			client_tracking_ops->exit(net);
> >  		client_tracking_ops = NULL;
> >  	}
> >  }
> > -- 
> > 1.7.11.4
> > 


-- 
Jeff Layton <jlayton@redhat.com>

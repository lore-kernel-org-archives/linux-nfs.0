From: Eric Paris <eparis@redhat.com>
Subject: Re: [PATCH 2/2] NFS: use new LSM interfaces to explicitly set
	mount options
Date: Wed, 05 Mar 2008 13:58:08 -0500
Message-ID: <1204743488.3216.251.camel@localhost.localdomain>
References: <1204731117.3216.238.camel@localhost.localdomain>
	 <1204741504.3356.14.camel@heimdal.trondhjem.org>
Mime-Version: 1.0
Content-Type: text/plain
Cc: linux-nfs@vger.kernel.org, selinux@tycho.nsa.gov,
	linux-security-module@vger.kernel.org,
	linux-fsdevel@vger.kernel.org, steved@redhat.com,
	jlayton@redhat.com, sds@tycho.nsa.gov, jmorris@namei.org,
	casey@schaufler-ca.com, chuck.lever@oracle.com, hch@infradead.org,
	akpm@linux-foundation.org
To: Trond Myklebust <trond.myklebust@fys.uio.no>
Return-path: <linux-security-module-owner@vger.kernel.org>
In-Reply-To: <1204741504.3356.14.camel@heimdal.trondhjem.org>
Sender: linux-security-module-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


On Wed, 2008-03-05 at 13:25 -0500, Trond Myklebust wrote:
> On Wed, 2008-03-05 at 10:31 -0500, Eric Paris wrote:

> > @@ -1214,6 +1232,32 @@ static int nfs_validate_mount_data(void *options,
> >  		args->namlen		= data->namlen;
> >  		args->bsize		= data->bsize;
> >  		args->auth_flavors[0]	= data->pseudoflavor;
> > +
> > +		/*
> > +		 * The legacy version 6 binary mount data from userspace has a
> > +		 * field used only to transport selinux information into the
> > +		 * the kernel.  To continue to support that functionality we
> > +		 * have a touch of selinux knowledge here in the NFS code. The
> > +		 * userspace code converted context=blah to just blah so we are
> > +		 * converting back to the full string selinux understands.
> > +		 */
> > +		if (data->context[0]){
> > +#ifdef CONFIG_SECURITY_SELINUX
> > +			int rc;
> > +			char *opts_str = kmalloc(sizeof(data->context) + 8, GFP_KERNEL);
> > +			if (!opts_str)
> > +				return -ENOMEM;
> > +			strcpy(opts_str, "context=");
> > +			strcat(opts_str, &data->context[0]);
> 
> Shouldn't this be a strncat? I can't see that we're sanity checking the
> data->context string for \NUL termination anywhere.

No good reason not to make sure since we know the size of the static
context array.  I just assumed NFS was doing checks on the hostname and
the context array the same way to make sure they were both valid.  I'll
send a new patch which uses strncat.

> > +			rc = security_sb_parse_opts_str(opts_str, &args->lsm_opts);
> > +			kfree(opts_str);
> > +			if (rc)
> > +				return rc;
> > +#else
> > +			return -EINVAL;
> 
> Is this really necessary?

If someone used context= with the binary data interface the kernel needs
to tell them that it didn't understand.  It's really no different than
nfs_parse_mount_options() having the out_unknown error case instead of
just ignoring unknown.  If they used the text interface they would fail
on the out_unknown case if !CONFIG_SELINUX.

> > +#endif
> > +		}
> > +
> >  		break;
> >  	default: {
> >  		unsigned int len;


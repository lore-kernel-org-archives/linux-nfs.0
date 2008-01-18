From: Matthew Wilcox <matthew@wil.cx>
Subject: Re: [PATCH 1/3] enhanced ESTALE error handling
Date: Fri, 18 Jan 2008 09:14:44 -0700
Message-ID: <20080118161443.GB20490@parisc-linux.org>
References: <4790C761.1010603@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	linux-nfs@vger.kernel.org,
	Andrew Morton <akpm@linux-foundation.org>,
	Trond Myklebust <trond.myklebust@fys.uio.no>,
	linux-fsdevel <linux-fsdevel@vger.kernel.org>
To: Peter Staubach <staubach@redhat.com>
Return-path: <linux-fsdevel-owner@vger.kernel.org>
In-Reply-To: <4790C761.1010603@redhat.com>
Sender: linux-fsdevel-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, Jan 18, 2008 at 10:36:01AM -0500, Peter Staubach wrote:
> @@ -1025,12 +1027,27 @@ static int fastcall link_path_walk(const
>  	mntget(save.mnt);
>  
>  	result = __link_path_walk(name, nd);
> -	if (result == -ESTALE) {
> +	while (result == -ESTALE) {
> +		/*
> +		 * If no progress was made looking up the pathname,
> +		 * then stop and return ENOENT instead of ESTALE.
> +		 */
> +		if (nd->dentry == save.dentry) {
> +			result = -ENOENT;
> +			break;
> +		}
>  		*nd = save;
>  		dget(nd->dentry);
>  		mntget(nd->mnt);
>  		nd->flags |= LOOKUP_REVAL;
>  		result = __link_path_walk(name, nd);
> +		/*
> +		 * If no progress was made this time, then return
> +		 * ENOENT instead of ESTALE because no recovery
> +		 * is possible to recover the stale file handle.
> +		 */
> +		if (result == -ESTALE && nd->dentry == save.dentry)
> +			result = -ENOENT;
>  	}
>  
>  	dput(save.dentry);

Why do you need both of these tests?  The first one should be enough,
surely?

> @@ -1268,8 +1285,8 @@ int path_lookup_open(int dfd, const char
>   * @create_mode: create intent flags
>   */
>  static int path_lookup_create(int dfd, const char *name,
> -			      unsigned int lookup_flags, struct nameidata *nd,
> -			      int open_flags, int create_mode)
> +		unsigned int lookup_flags, struct nameidata *nd,
> +		int open_flags, int create_mode)

Gratuitous reformatting?

> @@ -1712,7 +1729,10 @@ int open_namei(int dfd, const char *path
>  	int acc_mode, error;
>  	struct path path;
>  	struct dentry *dir;
> -	int count = 0;
> +	int count;
> +
> +top:
> +	count = 0;
>  
>  	acc_mode = ACC_MODE(flag);
>  
> @@ -1739,7 +1759,8 @@ int open_namei(int dfd, const char *path
>  	/*
>  	 * Create - we need to know the parent.
>  	 */
> -	error = path_lookup_create(dfd,pathname,LOOKUP_PARENT,nd,flag,mode);
> +	error = path_lookup_create(dfd, pathname, LOOKUP_PARENT, nd,
> +				flag, mode);
>  	if (error)
>  		return error;
>  
> @@ -1812,10 +1833,17 @@ ok:
>  	return 0;
>  
>  exit_dput:
> +	if (error == -ESTALE)
> +		d_drop(path.dentry);
>  	dput_path(&path, nd);
>  exit:
>  	if (!IS_ERR(nd->intent.open.file))
>  		release_open_intent(nd);
> +	if (error == -ESTALE) {
> +		d_drop(nd->dentry);
> +		path_release(nd);
> +		goto top;
> +	}

I wonder if a tail-call might not work better here.

-- 
Intel are signing my paycheques ... these opinions are still mine
"Bill, look, we understand that you're interested in selling us this
operating system, but compare it to ours.  We can't possibly take such
a retrograde step."

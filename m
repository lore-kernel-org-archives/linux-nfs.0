Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([174.143.236.118]:58362 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752201Ab1GLOUU (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 12 Jul 2011 10:20:20 -0400
Date: Tue, 12 Jul 2011 10:20:19 -0400
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Masatake YAMATO <yamato@redhat.com>
Cc: linux-nfs@vger.kernel.org, steved@redhat.com
Subject: Re: [PATCH v3] closing fd associated with
 /proc/fs/nfsd/export_features
Message-ID: <20110712142019.GE2162@fieldses.org>
References: <20110712.114700.814616059257545652.yamato@redhat.com>
 <20110712104652.GA2162@fieldses.org>
 <20110712.213817.1045173784079879730.yamato@redhat.com>
 <20110712.220109.419121694701200961.yamato@redhat.com>
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20110712.220109.419121694701200961.yamato@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Tue, Jul 12, 2011 at 10:01:09PM +0900, Masatake YAMATO wrote:
> Very sorry for posting again and again.

Whoops, shows how carefully I was reviewing....

> fd shuold be closed even if read is failed.

Looks good to me.

--b.

> 
> Signed-off-by: Masatake YAMATO <yamato@redhat.com>
> 
> diff --git a/support/nfs/exports.c b/support/nfs/exports.c
> index c250383..c96500f 100644
> --- a/support/nfs/exports.c
> +++ b/support/nfs/exports.c
> @@ -784,8 +784,9 @@ struct export_features *get_export_features(void)
>  	fd = open(path, O_RDONLY);
>  	if (fd == -1)
>  		goto good;
> -	fd = read(fd, buf, 50);
> -	if (fd == -1)
> +	c = read(fd, buf, 50);
> +	close(fd);
> +	if (c == -1)
>  		goto err;
>  	c = sscanf(buf, "%x %x", &ef.flags, &ef.secinfo_flags);
>  	if (c != 2)
> 
> > Sorry, my patch has a serious bug.
> > The value returned from read() is stored to fd.
> > So fd should not be passed to close().
> > 
> > I rearranged the code as below.
> > 
> > Signed-off-by: Masatake YAMATO <yamato@redhat.com>
> > 
> > diff --git a/support/nfs/exports.c b/support/nfs/exports.c
> > index c250383..744c01b 100644
> > --- a/support/nfs/exports.c
> > +++ b/support/nfs/exports.c
> > @@ -784,9 +784,10 @@ struct export_features *get_export_features(void)
> >  	fd = open(path, O_RDONLY);
> >  	if (fd == -1)
> >  		goto good;
> > -	fd = read(fd, buf, 50);
> > -	if (fd == -1)
> > +	c = read(fd, buf, 50);
> > +	if (c == -1)
> >  		goto err;
> > +	close(fd);
> >  	c = sscanf(buf, "%x %x", &ef.flags, &ef.secinfo_flags);
> >  	if (c != 2)
> >  		goto err;
> > 
> > 
> >> On Tue, Jul 12, 2011 at 11:47:00AM +0900, Masatake YAMATO wrote:
> >>> A fd associated with /proc/fs/nfsd/export_features opened in get_export_features is 
> >>> not closed.
> >>> 
> >>> 
> >>> Signed-off-by: Masatake YAMATO <yamato@redhat.com>
> >> Acked-by: J. Bruce Fields <bfields@redhat.com>
> >>> 
> >>> diff --git a/support/nfs/exports.c b/support/nfs/exports.c
> >>> index c250383..819a18a 100644
> >>> --- a/support/nfs/exports.c
> >>> +++ b/support/nfs/exports.c
> >>> @@ -787,6 +787,7 @@ struct export_features *get_export_features(void)
> >>>  	fd = read(fd, buf, 50);
> >>>  	if (fd == -1)
> >>>  		goto err;
> >>> +	close(fd);
> >>>  	c = sscanf(buf, "%x %x", &ef.flags, &ef.secinfo_flags);
> >>>  	if (c != 2)
> >>>  		goto err;
> >>> --
> >>> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> >>> the body of a message to majordomo@vger.kernel.org
> >>> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> >> --
> >> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> >> the body of a message to majordomo@vger.kernel.org
> >> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> > --
> > To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> > the body of a message to majordomo@vger.kernel.org
> > More majordomo info at  http://vger.kernel.org/majordomo-info.html

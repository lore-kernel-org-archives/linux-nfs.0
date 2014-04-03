Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:44265 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753090AbaDCRQ1 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 3 Apr 2014 13:16:27 -0400
Date: Thu, 3 Apr 2014 13:16:25 -0400
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Boaz Harrosh <openosd@gmail.com>
Cc: NeilBrown <neilb@suse.de>, NFS <linux-nfs@vger.kernel.org>
Subject: Re: Should exportfs/mountd cope with case-insensitive directory
 names.
Message-ID: <20140403171625.GA5884@fieldses.org>
References: <20140403164652.5d7770ad@notabene.brown>
 <20140403130909.GA24700@fieldses.org>
 <533D8629.10907@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <533D8629.10907@gmail.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, Apr 03, 2014 at 07:02:49PM +0300, Boaz Harrosh wrote:
> On 04/03/2014 04:09 PM, J. Bruce Fields wrote:
> > On Thu, Apr 03, 2014 at 04:46:52PM +1100, NeilBrown wrote:
> >> diff --git a/utils/mountd/cache.c b/utils/mountd/cache.c
> >> index 9a1bb2767ac2..2d91db76b867 100644
> >> --- a/utils/mountd/cache.c
> >> +++ b/utils/mountd/cache.c
> >> @@ -377,6 +377,28 @@ static char *next_mnt(void **v, char *p)
> >>  	return me->mnt_dir;
> >>  }
> >>  
> >> +static int same_path(char *child, char *parent, int len)
> >> +{
> >> +	static char p[PATH_MAX];
> >> +	struct stat sc, sp;
> >> +	if (len <= 0)
> >> +		len = strlen(child);
> >> +	strncpy(p, child, len);
> >> +	p[len] = 0;
> >> +	if (strcmp(p, parent) == 0)
> >> +		return 1;
> >> +
> 
> Addressing Bruce concern, perhaps you would like to
> also  stricmp the names, so to not lstat on all export
> entries.

If we try to guess the filesystem's case rules we'll go mad.

> +	if (stricmp(p, parent) =! 0)
> +		return 0;
> 
> >> +	if (lstat(p, &sc) != 0)
> >> +		return 0;
> >> +	if (lstat(parent, &sp) != 0)
> >> +		return 0;
> >> +	if (sc.st_dev != sp.st_dev)
> >> +		return 0;
> >> +	if (sc.st_ino != sp.st_ino)
> >> +		return 0;
> 
> Hard links on directories any one ? ;-)

In the presence of bind mounts it's definitely possible for two
different paths to reach the same directory.

I don't know if that's actually a problem here....

--b.

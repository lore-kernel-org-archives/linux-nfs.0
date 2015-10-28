Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from e39.co.us.ibm.com ([32.97.110.160]:49306 "EHLO
	e39.co.us.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932762AbbJ1QQ5 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 28 Oct 2015 12:16:57 -0400
Received: from localhost
	by e39.co.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-nfs@vger.kernel.org> from <malahal@us.ibm.com>;
	Wed, 28 Oct 2015 10:16:57 -0600
Received: from b01cxnp23033.gho.pok.ibm.com (b01cxnp23033.gho.pok.ibm.com [9.57.198.28])
	by d01dlp01.pok.ibm.com (Postfix) with ESMTP id 9379C38C8046
	for <linux-nfs@vger.kernel.org>; Wed, 28 Oct 2015 12:16:54 -0400 (EDT)
Received: from d01av05.pok.ibm.com (d01av05.pok.ibm.com [9.56.224.195])
	by b01cxnp23033.gho.pok.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id t9SGGsYL55312508
	for <linux-nfs@vger.kernel.org>; Wed, 28 Oct 2015 16:16:54 GMT
Received: from d01av05.pok.ibm.com (localhost [127.0.0.1])
	by d01av05.pok.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id t9SGFriD017439
	for <linux-nfs@vger.kernel.org>; Wed, 28 Oct 2015 12:15:55 -0400
Date: Wed, 28 Oct 2015 11:16:48 -0500
From: Malahal Naineni <malahal@us.ibm.com>
To: "J. Bruce Fields" <bfields@fieldses.org>
Cc: linux-nfs@vger.kernel.org, steved@redhat.com
Subject: Re: [PATCH] Close etab file's file descriptor on stat error.
Message-ID: <20151028161648.GB2549@us.ibm.com>
References: <1445990490-1941-1-git-send-email-malahal@us.ibm.com>
 <20151028135331.GB20682@fieldses.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20151028135331.GB20682@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

I wondered that myself! gdb (of course, running in foreground) showed
0,1,2 as a pty as expected. file descriptor 3 was some socket! Maybe, I
will debug it to find out what socket that was and what issues a user
could get into!

Regards, Malahal.

J. Bruce Fields [bfields@fieldses.org] wrote:
> On Tue, Oct 27, 2015 at 07:01:30PM -0500, Malahal Naineni wrote:
> > Also, fixed erroneously closing file descriptor 0 at init time.
> 
> Thanks, that's interesting.  Did that extra close(0) have any
> user-visible consequences?
> 
> > 
> > Signed-off-by: Malahal Naineni <malahal@us.ibm.com>
> > ---
> >  utils/mountd/auth.c | 17 ++++++++++++++---
> >  1 file changed, 14 insertions(+), 3 deletions(-)
> > 
> > diff --git a/utils/mountd/auth.c b/utils/mountd/auth.c
> > index 330cab5..894a7a5 100644
> > --- a/utils/mountd/auth.c
> > +++ b/utils/mountd/auth.c
> > @@ -85,7 +85,7 @@ auth_reload()
> >  {
> >  	struct stat		stb;
> >  	static ino_t		last_inode;
> > -	static int		last_fd;
> > +	static int		last_fd = -1;
> >  	static unsigned int	counter;
> >  	int			fd;
> >  
> > @@ -93,11 +93,22 @@ auth_reload()
> >  		xlog(L_FATAL, "couldn't open %s", _PATH_ETAB);
> >  	} else if (fstat(fd, &stb) < 0) {
> >  		xlog(L_FATAL, "couldn't stat %s", _PATH_ETAB);
> > -	} else if (stb.st_ino == last_inode) {
> > +		close(fd);
> > +	} else if (last_fd != -1 && stb.st_ino == last_inode) {
> 
> I think that (last_fd != -1) is actually unnecessary (basically because
> last_inode is initially 0, which isn't a legal inode number), but...
> it's probably clearer this way, OK.
> 
> Patch looks OK to me.--b.
> 
> > +		/* We opened the etab file before, and its inode
> > +		 * number hasn't changed since then.
> > +		 */
> >  		close(fd);
> >  		return counter;
> >  	} else {
> > -		close(last_fd);
> > +		/* Need to process entries from the etab file.  Close
> > +		 * the file descriptor from the previous open (last_fd),
> > +		 * and keep the current file descriptor open to prevent
> > +		 * the file system reusing the current inode number
> > +		 * (last_inode).
> > +		 */
> > +		if (last_fd != -1)
> > +			close(last_fd);
> >  		last_fd = fd;
> >  		last_inode = stb.st_ino;
> >  	}
> > -- 
> > 1.8.3.1
> > 
> > --
> > To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> > the body of a message to majordomo@vger.kernel.org
> > More majordomo info at  http://vger.kernel.org/majordomo-info.html
> 


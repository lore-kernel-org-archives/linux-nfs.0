Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx5-phx2.redhat.com ([209.132.183.37]:47945 "EHLO
	mx5-phx2.redhat.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932414AbbKEAn1 convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 4 Nov 2015 19:43:27 -0500
Date: Wed, 4 Nov 2015 19:43:26 -0500 (EST)
From: Jianhong Yin <jiyin@redhat.com>
To: Steve Dickson <SteveD@redhat.com>
Cc: linux-nfs@vger.kernel.org
Message-ID: <2021932998.2770701.1446684206867.JavaMail.zimbra@redhat.com>
In-Reply-To: <563A7E8B.4060805@RedHat.com>
References: <1446608590-3556-1-git-send-email-jiyin@redhat.com> <563A7E8B.4060805@RedHat.com>
Subject: Re: [PATCH] exportfs: Fix buf size in test_export() dump().
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>



----- 原始邮件 -----
> 发件人: "Steve Dickson" <SteveD@redhat.com>
> 收件人: "stevens.yin" <jiyin@redhat.com>, linux-nfs@vger.kernel.org
> 发送时间: 星期四, 2015年 11 月 05日 上午 5:54:19
> 主题: Re: [PATCH] exportfs: Fix buf size in test_export() dump().
> 
> 
> 
> On 11/03/2015 10:43 PM, stevens.yin wrote:
> > From: Jianhong Yin <jiyin@redhat.com>
> > 
> > The buf[] size in test_export() is not enough for NFS_MAXPATHLEN
> > + prefix/suffix proto string. Fix it and same issue in dump().
> > And just to be on the safe side, %s/sprintf/snprintf/
> Next time please add a proper Signed-off-by line. Since
> I do know the history of this patch I did the Signed-off-by.
Got it, thanks!

> 
> Committed...
> 
> steved.
> 
> > ---
> >  utils/exportfs/exportfs.c | 13 ++++++++-----
> >  1 file changed, 8 insertions(+), 5 deletions(-)
> > 
> > diff --git a/utils/exportfs/exportfs.c b/utils/exportfs/exportfs.c
> > index 8758231..c7a79a6 100644
> > --- a/utils/exportfs/exportfs.c
> > +++ b/utils/exportfs/exportfs.c
> > @@ -499,9 +499,10 @@ unexportfs(char *arg, int verbose)
> >  
> >  static int can_test(void)
> >  {
> > -	char buf[1024];
> > +	char buf[1024] = { 0 };
> >  	int fd;
> >  	int n;
> > +	size_t bufsiz = sizeof(buf);
> >  
> >  	fd = open("/proc/net/rpc/auth.unix.ip/channel", O_WRONLY);
> >  	if (fd < 0)
> > @@ -514,9 +515,9 @@ static int can_test(void)
> >  	 * commit 2f74f972  (sunrpc: prepare NFS for 2038).
> >  	 */
> >  	if (time(NULL) > INT_TO_LONG_THRESHOLD_SECS)
> > -		sprintf(buf, "nfsd 0.0.0.0 %ld -test-client-\n", LONG_MAX);
> > +		snprintf(buf, bufsiz-1, "nfsd 0.0.0.0 %ld -test-client-\n", LONG_MAX);
> >  	else
> > -		sprintf(buf, "nfsd 0.0.0.0 %d -test-client-\n", INT_MAX);
> > +		snprintf(buf, bufsiz-1, "nfsd 0.0.0.0 %d -test-client-\n", INT_MAX);
> >  
> >  	n = write(fd, buf, strlen(buf));
> >  	close(fd);
> > @@ -532,7 +533,8 @@ static int can_test(void)
> >  
> >  static int test_export(char *path, int with_fsid)
> >  {
> > -	char buf[1024];
> > +	/* beside max path, buf size should take protocol str into account */
> > +	char buf[NFS_MAXPATHLEN+1+64] = { 0 };
> >  	char *bp = buf;
> >  	int len = sizeof(buf);
> >  	int fd, n;
> > @@ -758,7 +760,8 @@ dumpopt(char c, char *fmt, ...)
> >  static void
> >  dump(int verbose, int export_format)
> >  {
> > -	char buf[1024];
> > +	/* buf[] size should >= sizeof(struct exportent->e_path) */
> > +	char buf[NFS_MAXPATHLEN+1] = { 0 };
> >  	char *bp;
> >  	int len;
> >  	nfs_export	*exp;
> > 
> 

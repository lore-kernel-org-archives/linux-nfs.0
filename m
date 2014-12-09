Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:37590 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751940AbaLIOmm (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 9 Dec 2014 09:42:42 -0500
Date: Tue, 9 Dec 2014 09:42:41 -0500
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Andy Shevchenko <andriy.shevchenko@linux.intel.com>
Cc: linux-nfs@vger.kernel.org, "David S. Miller" <davem@davemloft.net>
Subject: Re: [PATCH v1] sunrpc/cache: convert to use string_escape_str()
Message-ID: <20141209144241.GB20526@fieldses.org>
References: <1417189828-25688-1-git-send-email-andriy.shevchenko@linux.intel.com>
 <20141208223852.GA20526@fieldses.org>
 <1418117049.17201.51.camel@linux.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <1418117049.17201.51.camel@linux.intel.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, Dec 09, 2014 at 11:24:09AM +0200, Andy Shevchenko wrote:
> On Mon, 2014-12-08 at 17:38 -0500, J. Bruce Fields wrote:
> > On Fri, Nov 28, 2014 at 05:50:28PM +0200, Andy Shevchenko wrote:
> > > There is nice kernel helper to escape a given strings by provided rules. Let's
> > > use it instead of custom approach.
> > 
> > Looks good, but it broke nfsd.
> > 
> > After staring at the patch for a while:
> 
> > > Signed-off-by: Andy Shevchenko <andriy.shevchenko@linux.intel.com>
> > > ---
> > >  net/sunrpc/cache.c | 27 ++++++---------------------
> > >  1 file changed, 6 insertions(+), 21 deletions(-)
> > > 
> > > diff --git a/net/sunrpc/cache.c b/net/sunrpc/cache.c
> > > index 0663621..5cf60a4 100644
> > > --- a/net/sunrpc/cache.c
> > > +++ b/net/sunrpc/cache.c
> > > @@ -20,6 +20,7 @@
> > >  #include <linux/list.h>
> > >  #include <linux/module.h>
> > >  #include <linux/ctype.h>
> > > +#include <linux/string_helpers.h>
> > >  #include <asm/uaccess.h>
> > >  #include <linux/poll.h>
> > >  #include <linux/seq_file.h>
> > > @@ -1067,32 +1068,16 @@ void qword_add(char **bpp, int *lp, char *str)
> > >  {
> > >  	char *bp = *bpp;
> > >  	int len = *lp;
> > > -	char c;
> > > +	int ret;
> > >  
> > >  	if (len < 0) return;
> > >  
> > > -	while ((c=*str++) && len)
> > > -		switch(c) {
> > > -		case ' ':
> > > -		case '\t':
> > > -		case '\n':
> > > -		case '\\':
> > > -			if (len >= 4) {
> > > -				*bp++ = '\\';
> > > -				*bp++ = '0' + ((c & 0300)>>6);
> > > -				*bp++ = '0' + ((c & 0070)>>3);
> > > -				*bp++ = '0' + ((c & 0007)>>0);
> > > -			}
> > > -			len -= 4;
> > > -			break;
> > > -		default:
> > > -			*bp++ = c;
> > > -			len--;
> > > -		}
> > > -	if (c || len <1) len = -1;
> > > +	ret = string_escape_str(str, &bp, len, ESCAPE_OCTAL, "\\ \n\t");
> > > +	if (ret < 0 || ret == len)
> > > +		len = -1;
> > >  	else {
> > >  		*bp++ = ' ';
> > > -		len--;
> > > +		len -= ret - 1;
> > 
> > Looks like that should be ret + 1, not ret - 1.  With that change,
> > things work.
> > 
> > Inclined to actually commit that as:
> > 
> > 	len -= ret;
> > 	*bp++ = ' ';
> > 	len--;
> > 
> > just to make the arithmetic really obvious.
> > 
> > --b.
> 
> Good catch, thanks! It should decrement length indeed. In the form of -=
> it must be + 1. Shall I resubmit patch? If so, can I include your tag
> (Tested-by I suppose) ?

I'll fix it up, thanks.

--b.

Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([173.255.197.46]:54202 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753643AbbBZUkt (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 26 Feb 2015 15:40:49 -0500
Date: Thu, 26 Feb 2015 15:40:46 -0500
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Simo Sorce <simo@redhat.com>
Cc: Dan Carpenter <dan.carpenter@oracle.com>,
        Trond Myklebust <trond.myklebust@primarydata.com>,
        Anna Schumaker <anna.schumaker@netapp.com>,
        "David S. Miller" <davem@davemloft.net>,
        Jeff Layton <jlayton@primarydata.com>,
        Kinglong Mee <kinglongmee@gmail.com>, linux-nfs@vger.kernel.org,
        netdev@vger.kernel.org, "Eric W. Biederman" <ebiederm@xmission.com>,
        Andrew Morton <akpm@linux-foundation.org>,
        Andy Lutomirski <luto@amacapital.net>,
        Wang YanQing <udknight@gmail.com>, linux-kernel@vger.kernel.org,
        kernel-janitors@vger.kernel.org
Subject: Re: [patch v2] sunrpc: integer underflow in rsc_parse()
Message-ID: <20150226204046.GH20495@fieldses.org>
References: <20150224153401.GA12218@mwanda>
 <1424836484.13431.36.camel@willson.usersys.redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <1424836484.13431.36.camel@willson.usersys.redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, Feb 24, 2015 at 10:54:44PM -0500, Simo Sorce wrote:
> On Tue, 2015-02-24 at 18:34 +0300, Dan Carpenter wrote:
> > If we call groups_alloc() with invalid values then it's might lead to
> > memory corruption.  For example, with a negative value then we might not
> > allocate enough for sizeof(struct group_info).
> > 
> > Signed-off-by: Dan Carpenter <dan.carpenter@oracle.com>
> > ---
> > v2:  In v1, I changed groups_alloc().  The other places which call
> > groups_alloc() check the value before calling.  Eric wanted that, either
> > have all the callers check, or all the callers rely on groups_alloc().
> > In the end, Bruce Fields said adding the check here was probably
> > reasonable.
> > 
> > diff --git a/net/sunrpc/auth_gss/svcauth_gss.c b/net/sunrpc/auth_gss/svcauth_gss.c
> > index 224a82f..1095be9 100644
> > --- a/net/sunrpc/auth_gss/svcauth_gss.c
> > +++ b/net/sunrpc/auth_gss/svcauth_gss.c
> > @@ -463,6 +463,8 @@ static int rsc_parse(struct cache_detail *cd,
> >  		/* number of additional gid's */
> >  		if (get_int(&mesg, &N))
> >  			goto out;
> > +		if (N < 0 || N > NGROUPS_MAX)
> > +			goto out;
> >  		status = -ENOMEM;
> >  		rsci.cred.cr_group_info = groups_alloc(N);
> >  		if (rsci.cred.cr_group_info == NULL)
> > --
> > To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> > the body of a message to majordomo@vger.kernel.org
> > More majordomo info at  http://vger.kernel.org/majordomo-info.html
> 
> I touched this code relatively recently, and this check looks correct.
> Feel free to add Reviewed-by: Simo Sorce <simo@redhat.com>

Thanks!  I thought your below-the-line context was useful, so pulled a
version of it into the commit.

--b.

commit 76cb4be993c0
Author: Dan Carpenter <dan.carpenter@oracle.com>
Date:   Tue Feb 24 18:34:01 2015 +0300

    sunrpc: integer underflow in rsc_parse()
    
    If we call groups_alloc() with invalid values then it's might lead to
    memory corruption.  For example, with a negative value then we might not
    allocate enough for sizeof(struct group_info).
    
    (We're doing this in the caller for consistency with other callers of
    groups_alloc().  The other alternative might be to move the check out of
    all the callers into groups_alloc().)
    
    Signed-off-by: Dan Carpenter <dan.carpenter@oracle.com>
    Reviewed-by: Simo Sorce <simo@redhat.com>
    Signed-off-by: J. Bruce Fields <bfields@redhat.com>

diff --git a/net/sunrpc/auth_gss/svcauth_gss.c b/net/sunrpc/auth_gss/svcauth_gss.c
index 224a82f24d3c..1095be9c80ab 100644
--- a/net/sunrpc/auth_gss/svcauth_gss.c
+++ b/net/sunrpc/auth_gss/svcauth_gss.c
@@ -463,6 +463,8 @@ static int rsc_parse(struct cache_detail *cd,
 		/* number of additional gid's */
 		if (get_int(&mesg, &N))
 			goto out;
+		if (N < 0 || N > NGROUPS_MAX)
+			goto out;
 		status = -ENOMEM;
 		rsci.cred.cr_group_info = groups_alloc(N);
 		if (rsci.cred.cr_group_info == NULL)

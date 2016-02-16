Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:43468 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755951AbcBPVU0 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 16 Feb 2016 16:20:26 -0500
Date: Tue, 16 Feb 2016 16:20:25 -0500
From: Scott Mayhew <smayhew@redhat.com>
To: Trond Myklebust <trond.myklebust@primarydata.com>
Cc: Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH] auth_gss: fix panic in gss_pipe_downcall() in fips mode
Message-ID: <20160216212025.GH17439@tonberry.usersys.redhat.com>
References: <1455564521-21927-1-git-send-email-smayhew@redhat.com>
 <CAHQdGtRcC_58yGnb55us9E=rKNw+__HuPN_PFgYsZfukLDSxzQ@mail.gmail.com>
MIME-Version: 1.0
Content-Type: multipart/mixed; boundary="OzxllxdKGCiKxUZM"
In-Reply-To: <CAHQdGtRcC_58yGnb55us9E=rKNw+__HuPN_PFgYsZfukLDSxzQ@mail.gmail.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


--OzxllxdKGCiKxUZM
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

On Mon, 15 Feb 2016, Trond Myklebust wrote:

> Hi Scott,
> 
> On Mon, Feb 15, 2016 at 2:28 PM, Scott Mayhew <smayhew@redhat.com> wrote:
> > md5 is disabled in fips mode, and attempting to import a gss context
> > using md5 while in fips mode will result in crypto_alg_mod_lookup()
> > returning -ENOENT, which will make its way back up to
> > gss_pipe_downcall(), where the BUG() is triggered.  Handling the -ENOENT
> > allows for a more graceful failure.
> >
> > Signed-off-by: Scott Mayhew <smayhew@redhat.com>
> > ---
> >  net/sunrpc/auth_gss/auth_gss.c | 3 +++
> >  1 file changed, 3 insertions(+)
> >
> > diff --git a/net/sunrpc/auth_gss/auth_gss.c b/net/sunrpc/auth_gss/auth_gss.c
> > index 799e65b..c30fc3b 100644
> > --- a/net/sunrpc/auth_gss/auth_gss.c
> > +++ b/net/sunrpc/auth_gss/auth_gss.c
> > @@ -737,6 +737,9 @@ gss_pipe_downcall(struct file *filp, const char __user *src, size_t mlen)
> >                 case -ENOSYS:
> >                         gss_msg->msg.errno = -EAGAIN;
> >                         break;
> > +               case -ENOENT:
> > +                       gss_msg->msg.errno = -EPROTONOSUPPORT;
> > +                       break;
> >                 default:
> >                         printk(KERN_CRIT "%s: bad return from "
> >                                 "gss_fill_context: %zd\n", __func__, err);
> > --
> > 2.4.3
> >
> 
> Well debugged, but I unfortunately do have to ask if this patch is
> sufficient? In addition to -ENOENT, and -ENOMEM, it looks to me as if
> crypto_alg_mod_lookup() can also fail with -EINTR, -ETIMEDOUT, and
> -EAGAIN. Don't we also want to handle those?

You're right, I was focusing on the panic that I could easily reproduce.
I'm still not sure how I could trigger those other conditions.

> 
> In fact, peering into the rats nest that is
> gss_import_sec_context_kerberos(), it looks as if that is just a tiny
> subset of all the errors that we might run into. Perhaps the right
> thing to do here is to get rid of the BUG() (but keep the above
> printk) and just return a generic error?

That sounds fine to me -- updated patch attached.

-Scott

--OzxllxdKGCiKxUZM
Content-Type: text/plain; charset=us-ascii
Content-Disposition: attachment; filename="0001-auth_gss-remove-the-BUG-from-gss_pipe_downcall.patch"


--OzxllxdKGCiKxUZM--

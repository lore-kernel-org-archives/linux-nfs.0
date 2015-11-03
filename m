Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([173.255.197.46]:41717 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754113AbbKCTcf (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 3 Nov 2015 14:32:35 -0500
Date: Tue, 3 Nov 2015 14:32:33 -0500
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Trond Myklebust <trond.myklebust@primarydata.com>
Cc: Kinglong Mee <kinglongmee@gmail.com>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH v2] Sunrpc: Supports hexadecimal number for sysctl files
 of sunrpc debug
Message-ID: <20151103193233.GA1096@fieldses.org>
References: <55F17A7E.50406@gmail.com>
 <20150911212320.GG11677@fieldses.org>
 <55F38130.7020802@gmail.com>
 <55F381CE.4070600@gmail.com>
 <CAHQdGtQ6ydLcZTy5-QB7fSuEhDR+rV3dRe8bROtafWMqYAdmXQ@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <CAHQdGtQ6ydLcZTy5-QB7fSuEhDR+rV3dRe8bROtafWMqYAdmXQ@mail.gmail.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, Nov 03, 2015 at 12:38:19PM -0500, Trond Myklebust wrote:
> On Fri, Sep 11, 2015 at 9:37 PM, Kinglong Mee <kinglongmee@gmail.com> wrote:
> > The sunrpc debug sysctl files only accept decimal number right now.
> > But all the XXXDBUG_XXX macros are defined as hexadecimal.
> > It is not easy to set or check an separate flag.
> >
> > This patch let those files support accepting hexadecimal number,
> > (decimal number is also supported). Also, display it as hexadecimal.
> >
> > v2,
> > Remove duplicate parsing of '0x...', just using simple_strtol(tmpbuf, &s, 0)
> > Fix a bug of isspace() checking after parsing
> >
> > Signed-off-by: Kinglong Mee <kinglongmee@gmail.com>
> > ---
> >  net/sunrpc/sysctl.c | 23 ++++++++++++-----------
> >  1 file changed, 12 insertions(+), 11 deletions(-)
> >
> > diff --git a/net/sunrpc/sysctl.c b/net/sunrpc/sysctl.c
> > index 887f018..c88d9bc 100644
> > --- a/net/sunrpc/sysctl.c
> > +++ b/net/sunrpc/sysctl.c
> > @@ -76,7 +76,7 @@ static int
> >  proc_dodebug(struct ctl_table *table, int write,
> >                                 void __user *buffer, size_t *lenp, loff_t *ppos)
> >  {
> > -       char            tmpbuf[20], c, *s;
> > +       char            tmpbuf[20], c, *s = NULL;
> >         char __user *p;
> >         unsigned int    value;
> >         size_t          left, len;
> > @@ -103,23 +103,24 @@ proc_dodebug(struct ctl_table *table, int write,
> >                         return -EFAULT;
> >                 tmpbuf[left] = '\0';
> >
> > -               for (s = tmpbuf, value = 0; '0' <= *s && *s <= '9'; s++, left--)
> > -                       value = 10 * value + (*s - '0');
> > -               if (*s && !isspace(*s))
> > -                       return -EINVAL;
> > -               while (left && isspace(*s))
> > -                       left--, s++;
> > +               value = simple_strtol(tmpbuf, &s, 0);
> > +               if (s) {
> > +                       left -= (s - tmpbuf);
> > +                       if (left && !isspace(*s))
> > +                               return -EINVAL;
> > +                       while (left && isspace(*s))
> > +                               left--, s++;
> > +               } else
> > +                       left = 0;
> >                 *(unsigned int *) table->data = value;
> >                 /* Display the RPC tasks on writing to rpc_debug */
> >                 if (strcmp(table->procname, "rpc_debug") == 0)
> >                         rpc_show_tasks(&init_net);
> >         } else {
> > -               if (!access_ok(VERIFY_WRITE, buffer, left))
> > -                       return -EFAULT;
> > -               len = sprintf(tmpbuf, "%d", *(unsigned int *) table->data);
> > +               len = sprintf(tmpbuf, "0x%04x", *(unsigned int *) table->data);
> >                 if (len > left)
> >                         len = left;
> > -               if (__copy_to_user(buffer, tmpbuf, len))
> > +               if (copy_to_user(buffer, tmpbuf, len))
> >                         return -EFAULT;
> >                 if ((left -= len) > 0) {
> >                         if (put_user('\n', (char __user *)buffer + len))
> > --
> > 2.5.0
> >
> 
> Bruce, did you take this patch, or is there an expectation that I should do so?

Patch looked OK to me, but I didn't take it, could you?

--b.

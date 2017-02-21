Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:56330 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752760AbdBUSfI (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Tue, 21 Feb 2017 13:35:08 -0500
Date: Tue, 21 Feb 2017 13:35:06 -0500
From: "J. Bruce Fields" <bfields@redhat.com>
To: Andreas Gruenbacher <agruenba@redhat.com>
Cc: Trond Myklebust <trond.myklebust@primarydata.com>,
        Anna Schumaker <schumakeranna@gmail.com>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>,
        Weston Andros Adamson <dros@primarydata.com>,
        Weston Andros Adamson <dros@netapp.com>
Subject: Re: [PATCH 6/6] NFSv4: allow getacl rpc to allocate pages on demand
Message-ID: <20170221183506.GI2355@parsley.fieldses.org>
References: <1487470070-32358-1-git-send-email-bfields@redhat.com>
 <1487470070-32358-7-git-send-email-bfields@redhat.com>
 <CAHc6FU6FGPBXv0tu30wbChwdw3L7C7+aCjVxLrNfDB2N=MWk6w@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <CAHc6FU6FGPBXv0tu30wbChwdw3L7C7+aCjVxLrNfDB2N=MWk6w@mail.gmail.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, Feb 20, 2017 at 11:38:22PM +0100, Andreas Gruenbacher wrote:
> On Sun, Feb 19, 2017 at 3:07 AM, J. Bruce Fields <bfields@redhat.com> wrote:
> > @@ -5079,32 +5080,22 @@ static ssize_t nfs4_do_get_acl(struct inode *inode, void *buf, size_t buflen)
> >                 .rpc_argp = &args,
> >                 .rpc_resp = &res,
> >         };
> > -       unsigned int npages = DIV_ROUND_UP(buflen, PAGE_SIZE) + 1;
> > -       int ret = -ENOMEM, i;
> > -
> > -       if (npages > ARRAY_SIZE(pages))
> > -               return -ERANGE;
> > -
> > -       for (i = 0; i < npages; i++) {
> > -               pages[i] = alloc_page(GFP_KERNEL);
> > -               if (!pages[i])
> > -                       goto out_free;
> > -       }
> > +       int ret, i;
> >
> >         /* for decoding across pages */
> >         res.acl_scratch = alloc_page(GFP_KERNEL);
> >         if (!res.acl_scratch)
> > -               goto out_free;
> > +               return -ENOMEM;
> >
> > -       args.acl_len = npages * PAGE_SIZE;
> > +       args.acl_len = ARRAY_SIZE(pages) << PAGE_SHIFT;
> 
> Define acl_len directly in the args initializer instead of here.

Got it, thanks.  I'll send another revision of the series.

--b.

> 
> > -       dprintk("%s  buf %p buflen %zu npages %d args.acl_len %zu\n",
> > -               __func__, buf, buflen, npages, args.acl_len);
> > +       dprintk("%s  buf %p buflen %zu args.acl_len %zu\n",
> > +               __func__, buf, buflen, args.acl_len);
> >         ret = nfs4_call_sync(NFS_SERVER(inode)->client, NFS_SERVER(inode),
> >                              &msg, &args.seq_args, &res.seq_res, 0);
> >         if (ret == 0)
> >                 ret = res.acl_len;
> > -out_free:
> > +
> >         for (i = 0; i < ARRAY_SIZE(pages) && pages[i]; i++)
> >                 __free_page(pages[i]);
> >         __free_page(res.acl_scratch);
> > --
> > 2.9.3
> >

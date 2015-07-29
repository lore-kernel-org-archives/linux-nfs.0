Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([173.255.197.46]:32985 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752429AbbG2Tlz (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 29 Jul 2015 15:41:55 -0400
Date: Wed, 29 Jul 2015 15:41:55 -0400
From: "J. Bruce Fields" <bfields@fieldses.org>
To: NeilBrown <neilb@suse.com>
Cc: Kinglong Mee <kinglongmee@gmail.com>, Al Viro <viro@zeniv.linux.org.uk>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>,
        linux-fsdevel@vger.kernel.org,
        Trond Myklebust <trond.myklebust@primarydata.com>
Subject: Re: [PATCH 1/9 v8] fs_pin: Initialize value for fs_pin explicitly
Message-ID: <20150729194155.GC21949@fieldses.org>
References: <55B5A012.1030006@gmail.com>
 <55B5A04D.8090905@gmail.com>
 <20150729102519.16f2f70d@noble>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20150729102519.16f2f70d@noble>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, Jul 29, 2015 at 10:25:19AM +1000, NeilBrown wrote:
> On Mon, 27 Jul 2015 11:06:53 +0800 Kinglong Mee <kinglongmee@gmail.com>
> wrote:
> 
> > Without initialized, done in fs_pin at stack space may
> > contains strange value.
> > 
> > v8, same as v3
> > Adds macro for header file
> > 
> > Signed-off-by: Kinglong Mee <kinglongmee@gmail.com>
> 
> Reviewed-by: NeilBrown <neilb@suse.com>
> 
> It would be really good if some of these early patches could be applied
> to the relevant trees so they appear in -next and we only need to keep
> reviewing the more interesting code at the end.

This patch seems a little bikeshed-y.  I'd rather just drop it or save
it for some other day.  It's not necessary to the series.

--b.

> 
> Al, Bruce: any chance of some of these getting into -next ...
> 
> Thanks,
> NeilBrown
> 
> > ---
> >  include/linux/fs_pin.h | 6 ++++++
> >  1 file changed, 6 insertions(+)
> > 
> > diff --git a/include/linux/fs_pin.h b/include/linux/fs_pin.h
> > index 3886b3b..0dde7b7 100644
> > --- a/include/linux/fs_pin.h
> > +++ b/include/linux/fs_pin.h
> > @@ -1,3 +1,6 @@
> > +#ifndef _LINUX_FS_PIN_H
> > +#define _LINUX_FS_PIN_H
> > +
> >  #include <linux/wait.h>
> >  
> >  struct fs_pin {
> > @@ -16,9 +19,12 @@ static inline void init_fs_pin(struct fs_pin *p, void (*kill)(struct fs_pin *))
> >  	INIT_HLIST_NODE(&p->s_list);
> >  	INIT_HLIST_NODE(&p->m_list);
> >  	p->kill = kill;
> > +	p->done = 0;
> >  }
> >  
> >  void pin_remove(struct fs_pin *);
> >  void pin_insert_group(struct fs_pin *, struct vfsmount *, struct hlist_head *);
> >  void pin_insert(struct fs_pin *, struct vfsmount *);
> >  void pin_kill(struct fs_pin *);
> > +
> > +#endif

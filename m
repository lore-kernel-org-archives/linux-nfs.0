Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx12.netapp.com ([216.240.18.77]:39013 "EHLO mx12.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752003AbbAEVbU (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 5 Jan 2015 16:31:20 -0500
Message-ID: <54AB02A6.1060000@Netapp.com>
Date: Mon, 5 Jan 2015 16:31:18 -0500
From: Anna Schumaker <Anna.Schumaker@netapp.com>
MIME-Version: 1.0
To: Trond Myklebust <trond.myklebust@primarydata.com>
CC: Linux NFS Mailing List <linux-nfs@vger.kernel.org>,
        Thomas D Haynes <thomas.haynes@primarydata.com>
Subject: Re: [PATCH v2 20/49] nfs41: close a small race window when adding
 new layout to global list
References: <1419405208-25975-1-git-send-email-loghyr@primarydata.com>	<1419405208-25975-21-git-send-email-loghyr@primarydata.com>	<54AAFB18.7040500@Netapp.com> <CAHQdGtTdb5Uhm=1GR3Oh3DU-HNRN+f6WvRocc4fV6OyurD7t9Q@mail.gmail.com>
In-Reply-To: <CAHQdGtTdb5Uhm=1GR3Oh3DU-HNRN+f6WvRocc4fV6OyurD7t9Q@mail.gmail.com>
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 01/05/2015 04:20 PM, Trond Myklebust wrote:
> 
> On Jan 5, 2015 12:59 PM, "Anna Schumaker" <Anna.Schumaker@netapp.com <mailto:Anna.Schumaker@netapp.com>> wrote:
>>
>> Hi again,
>>
>> On 12/24/2014 02:12 AM, Tom Haynes wrote:
>> > From: Peng Tao <tao.peng@primarydata.com <mailto:tao.peng@primarydata.com>>
>> >
>> > Signed-off-by: Peng Tao <tao.peng@primarydata.com <mailto:tao.peng@primarydata.com>>
>> > Signed-off-by: Tom Haynes <Thomas.Haynes@primarydata.com <mailto:Thomas.Haynes@primarydata.com>>
>> > ---
>> >  fs/nfs/pnfs.c | 8 +++-----
>> >  1 file changed, 3 insertions(+), 5 deletions(-)
>> >
>> > diff --git a/fs/nfs/pnfs.c b/fs/nfs/pnfs.c
>> > index 2d25670..fa00b56 100644
>> > --- a/fs/nfs/pnfs.c
>> > +++ b/fs/nfs/pnfs.c
>> > @@ -1288,7 +1288,6 @@ pnfs_update_layout(struct inode *ino,
>> >       struct nfs_client *clp = server->nfs_client;
>> >       struct pnfs_layout_hdr *lo;
>> >       struct pnfs_layout_segment *lseg = NULL;
>> > -     bool first;
>> >
>> >       if (!pnfs_enabled_sb(NFS_SERVER(ino)))
>> >               goto out;
>> > @@ -1321,16 +1320,15 @@ pnfs_update_layout(struct inode *ino,
>> >       if (pnfs_layoutgets_blocked(lo, 0))
>> >               goto out_unlock;
>> >       atomic_inc(&lo->plh_outstanding);
>> > -
>> > -     first = list_empty(&lo->plh_layouts) ? true : false;
>> >       spin_unlock(&ino->i_lock);
>> >
>> > -     if (first) {
>> > +     if (list_empty(&lo->plh_layouts)) {
>> >               /* The lo must be on the clp list if there is any
>> >                * chance of a CB_LAYOUTRECALL(FILE) coming in.
>> >                */
>> >               spin_lock(&clp->cl_lock);
>> > -             list_add_tail(&lo->plh_layouts, &server->layouts);
>> > +             if (list_empty(&lo->plh_layouts))
>> > +                     list_add_tail(&lo->plh_layouts, &server->layouts);
>> >               spin_unlock(&clp->cl_lock);
>> >       }
>>
>> Do we really need to call list_empty() twice?  Would there be a serious performance drawback if we removed the outer layer if condition and then always call list_empty() under the cl_lock?
> 
> What is the problem with that? It avoids unnecessary contention on a per-server global lock.

I was thinking about the case where the plh_layouts list becomes empty after the outer if.  I took a closer look at the code and that only happens when the layout is being freed, so it shouldn't be an issue.

Anna
> 
> Please keep it,
> 
>>
>> >
>> >
>>
> 


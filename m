Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-pd0-f179.google.com ([209.85.192.179]:32952 "EHLO
	mail-pd0-f179.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753532AbbEKJzK (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 11 May 2015 05:55:10 -0400
Date: Mon, 11 May 2015 18:54:58 +0900 (JST)
Message-Id: <20150511.185458.913750783836948467.konishi.ryusuke@lab.ntt.co.jp>
To: NeilBrown <neilb@suse.de>
Cc: Josef Bacik <jbacik@fb.com>, Chris Mason <clm@fb.com>,
        Jan Kara <jack@suse.cz>, David Sterba <dsterba@suse.cz>,
        linux-fsdevel@vger.kernel.org, linux-nfs@vger.kernel.org,
        linux-nilfs@vger.kernel.org, linux-kernel@vger.kernel.org,
        linux-btrfs@vger.kernel.org
Subject: Re: [PATCH 2/3] NILFS2: support NFSv2 export
From: Ryusuke Konishi <konishi.ryusuke@lab.ntt.co.jp>
In-Reply-To: <20150511170251.4fb69e52@notabene.brown>
References: <20150508001623.31129.25102.stgit@notabene.brown>
	<20150511.013143.706881749197692581.konishi.ryusuke@lab.ntt.co.jp>
	<20150511170251.4fb69e52@notabene.brown>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, 11 May 2015 17:02:51 +1000, NeilBrown wrote:
> On Mon, 11 May 2015 01:31:43 +0900 (JST) Ryusuke Konishi
> <konishi.ryusuke@lab.ntt.co.jp> wrote:
> 
>> On Fri, 08 May 2015 10:16:23 +1000, NeilBrown <neilb@suse.de> wrote:
>> > The "fh_len" passed to ->fh_to_* is not guaranteed to be that same as
>> > that returned by encode_fh - it may be larger.
>> > 
>> > With NFSv2, the filehandle is fixed length, so it may appear longer
>> > than expected and be zero-padded.
>> > 
>> > So we must test that fh_len is at least some value, not exactly equal
>> > to it.
>> > 
>> > Signed-off-by: NeilBrown <neilb@suse.de>
>> > ---
>> >  fs/nilfs2/namei.c |    6 +++---
>> >  1 file changed, 3 insertions(+), 3 deletions(-)
>> > 
>> > diff --git a/fs/nilfs2/namei.c b/fs/nilfs2/namei.c
>> > index 22180836ec22..b65fb79d16fd 100644
>> > --- a/fs/nilfs2/namei.c
>> > +++ b/fs/nilfs2/namei.c
>> > @@ -496,8 +496,8 @@ static struct dentry *nilfs_fh_to_dentry(struct super_block *sb, struct fid *fh,
>> >  {
>> >  	struct nilfs_fid *fid = (struct nilfs_fid *)fh;
>> >  
>> > -	if ((fh_len != NILFS_FID_SIZE_NON_CONNECTABLE &&
>> > -	     fh_len != NILFS_FID_SIZE_CONNECTABLE) ||
>> 
>> > +	if ((fh_len < NILFS_FID_SIZE_NON_CONNECTABLE &&
>> > +	     fh_len < NILFS_FID_SIZE_CONNECTABLE) ||
>> >  	    (fh_type != FILEID_NILFS_WITH_PARENT &&
>> >  	     fh_type != FILEID_NILFS_WITHOUT_PARENT))
>> >  		return NULL;
>> 
>> A bit weird.  "fh_len < NILFS_FID_SIZE_CONNECTABLE" implies "fh_len <
>> NILFS_FID_SIZE_NON_CONNECTABLE".
>> 
>> How about the following fix ?
>> 
>> 	if ((fh_type != FILEID_NILFS_WITH_PARENT ||
>> 	     fh_len < NILFS_FID_SIZE_CONNECTABLE) &&
>> 	    (fh_type != FILEID_NILFS_WITHOUT_PARENT ||
>> 	     fh_len < NILFS_FID_SIZE_NON_CONNECTABLE))
>> 		return NULL;
>> 
> 
> Yes, weird.  The code only uses the early parts of the filehandle, so we
> only need to complain if the fh_len is less than FILEID_NILFS_WITHOUT_PARENT.
> 
> So I'd prefer:
> 
> @@ -496,8 +496,7 @@ static struct dentry *nilfs_fh_to_dentry(struct super_block *sb, struct fid *fh,
>  {
>         struct nilfs_fid *fid = (struct nilfs_fid *)fh;
>  
> -       if ((fh_len != NILFS_FID_SIZE_NON_CONNECTABLE &&
> -            fh_len != NILFS_FID_SIZE_CONNECTABLE) ||
> +       if (fh_len < NILFS_FID_SIZE_NON_CONNECTABLE ||
>             (fh_type != FILEID_NILFS_WITH_PARENT &&
>              fh_type != FILEID_NILFS_WITHOUT_PARENT))
>                 return NULL;
> 
> 
> Would you be OK with that?  If so I'll resend.
> 
> Thanks,
> NeilBrown

Thanks.  This looks OK to me.
I'll apply it if you will resend.

Regards,
Ryusuke Konishi

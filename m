Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:58782 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752011AbdEFHms (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Sat, 6 May 2017 03:42:48 -0400
Date: Sat, 6 May 2017 03:42:45 -0400 (EDT)
From: Jianhong Yin <jiyin@redhat.com>
To: Anna Schumaker <Anna.Schumaker@Netapp.com>
Cc: linux-nfs@vger.kernel.org,
        trond myklebust <trond.myklebust@primarydata.com>,
        bfields@redhat.com, steved@redhat.com
Message-ID: <1886259790.4789958.1494056565081.JavaMail.zimbra@redhat.com>
In-Reply-To: <b100e3a6-c59b-9729-7129-6c7ca163dacf@Netapp.com>
References: <1493980011-24395-1-git-send-email-jiyin@redhat.com> <b100e3a6-c59b-9729-7129-6c7ca163dacf@Netapp.com>
Subject: Re: [PATCH] fs/nfs: fix covscan error: FORWARD_NULL
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


----- 原始邮件 -----
> 发件人: "Anna Schumaker" <Anna.Schumaker@Netapp.com>
> 收件人: "Jianhong.Yin" <jiyin@redhat.com>, linux-nfs@vger.kernel.org
> 抄送: "trond myklebust" <trond.myklebust@primarydata.com>, bfields@redhat.com, steved@redhat.com, "Jianhong.Yin"
> <yin-jianhong@163.com>
> 发送时间: 星期六, 2017年 5 月 06日 上午 1:52:35
> 主题: Re: [PATCH] fs/nfs: fix covscan error: FORWARD_NULL
> 
> Hi Jianhong,
> 
> On 05/05/2017 06:26 AM, Jianhong.Yin wrote:
> > From: "Jianhong.Yin" <yin-jianhong@163.com>
> > 
> > fs/nfs/nfs4xdr.c: encode_attrs()
> > '''
> > Error: FORWARD_NULL (CWE-476): [#def3702]
> > .../fs/nfs/nfs4xdr.c:1085: var_compare_op: Comparing "label" to null
> > implies that "label" might be null.
> > .../fs/nfs/nfs4xdr.c:1129: var_deref_op: Dereferencing null pointer
> > "label".
> >  1127|   	}
> >  1128|   	if (bmval[2] & FATTR4_WORD2_SECURITY_LABEL) {
> >  1129|-> 		*p++ = cpu_to_be32(label->lfs);
> >  1130|   		*p++ = cpu_to_be32(label->pi);
> >  1131|   		*p++ = cpu_to_be32(label->len);
> > 
> > Error: FORWARD_NULL (CWE-476): [#def3703]
> > .../fs/nfs/nfs4xdr.c:1027: var_compare_op: Comparing "umask" to null
> > implies that "umask" might be null.
> > .../fs/nfs/nfs4xdr.c:1136: var_deref_op: Dereferencing null pointer
> > "umask".
> >  1134|   	if (bmval[2] & FATTR4_WORD2_MODE_UMASK) {
> >  1135|   		*p++ = cpu_to_be32(iap->ia_mode & S_IALLUGO);
> >  1136|-> 		*p++ = cpu_to_be32(*umask);
> >  1137|   	}
> > '''
> > 
> > Signed-off-by: Jianhong Yin <yin-jianhong@163.com>
> > ---
> >  fs/nfs/nfs4xdr.c | 5 +++--
> >  1 file changed, 3 insertions(+), 2 deletions(-)
> > 
> > diff --git a/fs/nfs/nfs4xdr.c b/fs/nfs/nfs4xdr.c
> > index 80ce289..a86ed66 100644
> > --- a/fs/nfs/nfs4xdr.c
> > +++ b/fs/nfs/nfs4xdr.c
> > @@ -1124,7 +1124,7 @@ static void encode_attrs(struct xdr_stream *xdr,
> > const struct iattr *iap,
> >  		} else
> >  			*p++ = cpu_to_be32(NFS4_SET_TO_SERVER_TIME);
> >  	}
> > -	if (bmval[2] & FATTR4_WORD2_SECURITY_LABEL) {
> > +	if (label && bmval[2] & FATTR4_WORD2_SECURITY_LABEL) {
> 
> As far as I can tell, the FATTR4_WORD2_SECURITY_LABEL flag is only set if
> label exists, and the same goes for the FATTR4_WORD2_MODE_UMASK flag below.
> This means that it's not possible to have a null pointer dereference in
> these sections of code.  Is there a way to mark this as a false positive in
> your covscan tool?

Hi Anna

 Yes, you are right. this patch is unnecessary. just let code *looks* more safe.

 "covscan" means the coverity scan(a "Static Analysis" tool).
   lots of it's warning/error need to be marked as false positive.
 thank you for correcting me

Jianhong

> 
> Thanks,
> Anna
> 
> >  		*p++ = cpu_to_be32(label->lfs);
> >  		*p++ = cpu_to_be32(label->pi);
> >  		*p++ = cpu_to_be32(label->len);
> > @@ -1132,7 +1132,8 @@ static void encode_attrs(struct xdr_stream *xdr,
> > const struct iattr *iap,
> >  	}
> >  	if (bmval[2] & FATTR4_WORD2_MODE_UMASK) {
> >  		*p++ = cpu_to_be32(iap->ia_mode & S_IALLUGO);
> > -		*p++ = cpu_to_be32(*umask);
> > +		if (umask != NULL)
> > +			*p++ = cpu_to_be32(*umask);
> >  	}
> >  
> >  /* out: */
> > 
> 

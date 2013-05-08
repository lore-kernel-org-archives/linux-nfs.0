Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:35921 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756904Ab3EHRcs (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 8 May 2013 13:32:48 -0400
Message-ID: <518A8C3D.9000407@RedHat.com>
Date: Wed, 08 May 2013 13:32:45 -0400
From: Steve Dickson <SteveD@redhat.com>
MIME-Version: 1.0
To: "Myklebust, Trond" <Trond.Myklebust@netapp.com>
CC: "J. Bruce Fields" <bfields@redhat.com>,
        "David P. Quigley" <dpquigl@tycho.nsa.gov>,
        Linux NFS list <linux-nfs@vger.kernel.org>,
        Linux FS devel list <linux-fsdevel@vger.kernel.org>,
        Linux Security List <linux-security-module@vger.kernel.org>,
        SELinux List <selinux@tycho.nsa.gov>
Subject: Re: [PATCH 09/17] NFSv4: Introduce new label structure
References: <1367240239-19326-1-git-send-email-SteveD@redhat.com>  <1367240239-19326-10-git-send-email-SteveD@redhat.com> <1367434764.4189.33.camel@leira.trondhjem.org>
In-Reply-To: <1367434764.4189.33.camel@leira.trondhjem.org>
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 01/05/13 14:59, Myklebust, Trond wrote:
>> diff --git a/include/linux/nfs_xdr.h b/include/linux/nfs_xdr.h
>> > index 9f2dba3..4d2fdf6 100644
>> > --- a/include/linux/nfs_xdr.h
>> > +++ b/include/linux/nfs_xdr.h
>> > @@ -351,6 +351,7 @@ struct nfs_openargs {
>> >  	const u32 *		bitmask;
>> >  	const u32 *		open_bitmap;
>> >  	__u32			claim;
>> > +	const struct nfs4_label *label;
>> >  };
>> >  
>> >  struct nfs_openres {
>> > @@ -360,6 +361,7 @@ struct nfs_openres {
>> >  	struct nfs4_change_info	cinfo;
>> >  	__u32                   rflags;
>> >  	struct nfs_fattr *      f_attr;
>> > +	struct nfs4_label	*f_label;
>> >  	struct nfs_seqid *	seqid;
>> >  	const struct nfs_server *server;
>> >  	fmode_t			delegation_type;
>> > @@ -404,6 +406,7 @@ struct nfs_closeres {
>> >  	struct nfs4_sequence_res	seq_res;
>> >  	nfs4_stateid            stateid;
>> >  	struct nfs_fattr *	fattr;
>> > +	struct nfs4_label	*label;
>> >  	struct nfs_seqid *	seqid;
>> >  	const struct nfs_server *server;
>> >  };
>> > @@ -477,6 +480,7 @@ struct nfs4_delegreturnargs {
>> >  struct nfs4_delegreturnres {
>> >  	struct nfs4_sequence_res	seq_res;
>> >  	struct nfs_fattr * fattr;
>> > +	struct nfs4_label	*label;
>> >  	const struct nfs_server *server;
>> >  };
>> >  
>> > @@ -497,6 +501,7 @@ struct nfs_readargs {
>> >  struct nfs_readres {
>> >  	struct nfs4_sequence_res	seq_res;
>> >  	struct nfs_fattr *	fattr;
>> > +	struct nfs4_label	*label;
> Why do we need to check labels on close, delegreturn, read, remove,
> rename, etc? 
All of these have GETATTR in the compound they send out. So I'm
assuming to keep consistence, the label bit needs to be set 
on all *most* of the GEATTRs. Ones that actually nfs_refresh_inode()
the inode.

> Do any of those operations cause our cached labels to change?
Not the label but the inode. The bit is set in ACCESS, LOOKUP, 
LINK, OPEN, CREAT, SETATTR which all clearly update the inode.

So I guess my question is if the bit is not set in any of these 
ops how do we know if the label has changed? Should label changes
be synchronized with inode updates? 

steved.





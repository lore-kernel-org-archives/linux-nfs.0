Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:42248 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1760819Ab3EBSbc (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 2 May 2013 14:31:32 -0400
Message-ID: <5182B100.2080900@RedHat.com>
Date: Thu, 02 May 2013 14:31:28 -0400
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
> rename, etc? Do any of those operations cause our cached labels to
> change?
I was not around then this decision was made... Maybe some of the 
security people can address that.... 

What operation do you think they are needed for?

steved.
 

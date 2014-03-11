Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-qc0-f172.google.com ([209.85.216.172]:44578 "EHLO
	mail-qc0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753588AbaCKWAl convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 11 Mar 2014 18:00:41 -0400
Received: by mail-qc0-f172.google.com with SMTP id i8so10329991qcq.17
        for <linux-nfs@vger.kernel.org>; Tue, 11 Mar 2014 15:00:41 -0700 (PDT)
Content-Type: text/plain; charset=windows-1252
Mime-Version: 1.0 (Mac OS X Mail 7.2 \(1874\))
Subject: Re: [PATCH] nfs: Don't assume we have a security structure
From: Trond Myklebust <trond.myklebust@primarydata.com>
In-Reply-To: <29D9CA49-A493-471B-932B-959AFF96C729@primarydata.com>
Date: Tue, 11 Mar 2014 18:00:38 -0400
Cc: David Quigley <dpquigl@davequigley.com>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>,
        James Morris <james.l.morris@oracle.com>,
        Eric Paris <eparis@redhat.com>
Message-Id: <EEEA2B4E-BE0F-40C0-91C3-98E2E7E8BB35@primarydata.com>
References: <1394572274-16474-1-git-send-email-Anna.Schumaker@netapp.com> <29D9CA49-A493-471B-932B-959AFF96C729@primarydata.com>
To: Schumaker Anna <Anna.Schumaker@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


On Mar 11, 2014, at 17:27, Trond Myklebust <trond.myklebust@primarydata.com> wrote:

> 
> On Mar 11, 2014, at 17:11, Anna Schumaker <Anna.Schumaker@netapp.com> wrote:
> 
>> If the i_security field isn't set then security_dentry_init_security()
>> won't initialize some of the values used by the security label.  This
>> causes my client to hit a BUG_ON() while encoding a label of size
>> -2128927414.
>> 
>> I hit this bug while testing on a client without SELinux installed.
>> 
>> Signed-off-by: Anna Schumaker <anna.schumaker@netapp.com>
>> ---
>> fs/nfs/nfs4proc.c | 3 +++
>> 1 file changed, 3 insertions(+)
>> 
>> diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
>> index b8cd560..994ccc2 100644
>> --- a/fs/nfs/nfs4proc.c
>> +++ b/fs/nfs/nfs4proc.c
>> @@ -105,6 +105,9 @@ nfs4_label_init_security(struct inode *dir, struct dentry *dentry,
>> 	if (nfs_server_capable(dir, NFS_CAP_SECURITY_LABEL) == 0)
>> 		return NULL;
>> 
>> +	if (!dir->i_security)
>> +		return NULL;
>> +
>> 	err = security_dentry_init_security(dentry, sattr->ia_mode,
>> 				&dentry->d_name, (void **)&label->label, &label->len);
>> 	if (err == 0)
> 
> Hi Anna,
> 
> This looks like a check that needs to be done by selinux_dentry_init_security() itself. The dir->i_security field is not something that NFS knows about.
> David, what needs to happen there when dentry->d_parent->i_security (a.k.a. dsec) is NULL?
> 

Oh, wait. I missed the bit about ‘without SELinux installed’. So the problem here is that you have a NFS client that does not have SELinux set up, but running against a server that is advertising NFSv4.2 with labeled NFS. Is that correct?

It looks to me as if cap_dentry_init_security() will indeed trigger this behaviour since it returns ‘0’ without doing anything to the label. As far as I can see, the right thing to do there is to return -EOPNOTSUPP, no?

_________________________________
Trond Myklebust
Linux NFS client maintainer, PrimaryData
trond.myklebust@primarydata.com


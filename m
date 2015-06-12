Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx141.netapp.com ([216.240.21.12]:13324 "EHLO mx141.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752623AbbFLS4h (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 12 Jun 2015 14:56:37 -0400
Subject: Re: [PATCH 1/1] Recover from stateid-type error on SETATTR
To: Trond Myklebust <trond.myklebust@primarydata.com>,
        Olga Kornievskaia <kolga@netapp.com>
References: <1434133855-86259-1-git-send-email-kolga@netapp.com>
 <CAHQdGtTSzfHL8WaMXRN+vVmUuTQ6a8w71zFpkutTkaVgAG_TYQ@mail.gmail.com>
CC: Linux NFS Mailing List <linux-nfs@vger.kernel.org>
From: Anna Schumaker <Anna.Schumaker@netapp.com>
Message-ID: <557B2B62.8040700@Netapp.com>
Date: Fri, 12 Jun 2015 14:56:34 -0400
MIME-Version: 1.0
In-Reply-To: <CAHQdGtTSzfHL8WaMXRN+vVmUuTQ6a8w71zFpkutTkaVgAG_TYQ@mail.gmail.com>
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hey Trond,

On 06/12/2015 02:37 PM, Trond Myklebust wrote:
> Hi Olga,
> 
> On Fri, Jun 12, 2015 at 2:30 PM, Olga Kornievskaia <kolga@netapp.com> wrote:
>> Client can receives stateid-type error (eg., BAD_STATEID) on SETATTR when
>> delegation stateid was used. When no open state exists, in case of application
>> calling truncate() on the file, client has no state to recover and fails with
>> EIO.
>>
>> Instead, upon such error, return the bad delegation and then resend the
>> SETATTR with a zero stateid.
>>
>> Signed-off: Olga Kornievskaia <kolga@netapp.com>
>> ---
>>  fs/nfs/delegation.h | 6 ++++++
>>  fs/nfs/nfs4proc.c   | 7 ++++++-
>>  2 files changed, 12 insertions(+), 1 deletion(-)
>>
>> diff --git a/fs/nfs/delegation.h b/fs/nfs/delegation.h
>> index e3c20a3..e37165f 100644
>> --- a/fs/nfs/delegation.h
>> +++ b/fs/nfs/delegation.h
>> @@ -62,6 +62,12 @@ void nfs_mark_delegation_referenced(struct nfs_delegation *delegation);
>>  int nfs4_have_delegation(struct inode *inode, fmode_t flags);
>>  int nfs4_check_delegation(struct inode *inode, fmode_t flags);
>>
>> +static inline int nfs4_have_any_delegation(struct inode *inode)
>> +{
>> +       struct nfs_inode *nfsi = NFS_I(inode);
>> +       return rcu_access_pointer(nfsi->delegation) ? 1 : 0;
>> +}
> 
> What would this do that isn't already covered by
> nfs4_have_delegation(inode, FMODE_READ)?

It looks like _nfs4_do_settattr() can select between FMODE_READ and FMODE_WRITE, so wouldn't we otherwise need to call nfs4_have_delegation() twice?  Or am I missing something?

Anna

> 
> Cheers
>   Trond
> 


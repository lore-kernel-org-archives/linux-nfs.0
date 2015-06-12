Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-vn0-f45.google.com ([209.85.216.45]:38536 "EHLO
	mail-vn0-f45.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750856AbbFLUCx convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 12 Jun 2015 16:02:53 -0400
Received: by vnbf1 with SMTP id f1so611441vnb.5
        for <linux-nfs@vger.kernel.org>; Fri, 12 Jun 2015 13:02:52 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <AD67FFD6-69C1-4512-A967-3933731D9629@netapp.com>
References: <1434133855-86259-1-git-send-email-kolga@netapp.com>
	<CAHQdGtTSzfHL8WaMXRN+vVmUuTQ6a8w71zFpkutTkaVgAG_TYQ@mail.gmail.com>
	<AD67FFD6-69C1-4512-A967-3933731D9629@netapp.com>
Date: Fri, 12 Jun 2015 16:02:52 -0400
Message-ID: <CAHQdGtTcQoxxoBmcHp5T047Zx1tU+xGNAS+ZZXOX73151ae1Fw@mail.gmail.com>
Subject: Re: [PATCH 1/1] Recover from stateid-type error on SETATTR
From: Trond Myklebust <trond.myklebust@primarydata.com>
To: "Kornievskaia, Olga" <Olga.Kornievskaia@netapp.com>
Cc: "Schumaker, Anna" <Anna.Schumaker@netapp.com>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, Jun 12, 2015 at 2:48 PM, Kornievskaia, Olga
<Olga.Kornievskaia@netapp.com> wrote:
>
>> On Jun 12, 2015, at 2:37 PM, Trond Myklebust <trond.myklebust@primarydata.com> wrote:
>>
>> Hi Olga,
>>
>> On Fri, Jun 12, 2015 at 2:30 PM, Olga Kornievskaia <kolga@netapp.com> wrote:
>>> Client can receives stateid-type error (eg., BAD_STATEID) on SETATTR when
>>> delegation stateid was used. When no open state exists, in case of application
>>> calling truncate() on the file, client has no state to recover and fails with
>>> EIO.
>>>
>>> Instead, upon such error, return the bad delegation and then resend the
>>> SETATTR with a zero stateid.
>>>
>>> Signed-off: Olga Kornievskaia <kolga@netapp.com>
>>> ---
>>> fs/nfs/delegation.h | 6 ++++++
>>> fs/nfs/nfs4proc.c   | 7 ++++++-
>>> 2 files changed, 12 insertions(+), 1 deletion(-)
>>>
>>> diff --git a/fs/nfs/delegation.h b/fs/nfs/delegation.h
>>> index e3c20a3..e37165f 100644
>>> --- a/fs/nfs/delegation.h
>>> +++ b/fs/nfs/delegation.h
>>> @@ -62,6 +62,12 @@ void nfs_mark_delegation_referenced(struct nfs_delegation *delegation);
>>> int nfs4_have_delegation(struct inode *inode, fmode_t flags);
>>> int nfs4_check_delegation(struct inode *inode, fmode_t flags);
>>>
>>> +static inline int nfs4_have_any_delegation(struct inode *inode)
>>> +{
>>> +       struct nfs_inode *nfsi = NFS_I(inode);
>>> +       return rcu_access_pointer(nfsi->delegation) ? 1 : 0;
>>> +}
>>
>> What would this do that isn't already covered by
>> nfs4_have_delegation(inode, FMODE_READ)?
>
> We need to return delegation regardless of whether it’s read or write.

Yes, and the test for nfs4_have_delegation(inode, FMODE_READ) is
intentionally satisfied when you hold a write delegation, because it
guarantees a superset of the caching guarantees that a read delegation
would offer.

Cheers
  Trond

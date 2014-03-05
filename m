Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-ig0-f172.google.com ([209.85.213.172]:43376 "EHLO
	mail-ig0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753953AbaCENEp convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 5 Mar 2014 08:04:45 -0500
Received: by mail-ig0-f172.google.com with SMTP id uq10so7659735igb.5
        for <linux-nfs@vger.kernel.org>; Wed, 05 Mar 2014 05:04:45 -0800 (PST)
Content-Type: text/plain; charset=US-ASCII
Mime-Version: 1.0 (Mac OS X Mail 7.2 \(1874\))
Subject: Re: [PATCH 3/4] NFSv4 _nfs4_do_setattr use zero stateid on lost lock
From: Trond Myklebust <trond.myklebust@primarydata.com>
In-Reply-To: <CAHVgHyWmRrBTmL-h4mrozPqw-gumqBRRy2TQrfC-yvQVuoE+Jw@mail.gmail.com>
Date: Wed, 5 Mar 2014 08:04:43 -0500
Cc: NFS list <linux-nfs@vger.kernel.org>
Message-Id: <F9D3FE3B-2755-4F4D-B83A-21C744488F7D@primarydata.com>
References: <1393954269-3974-1-git-send-email-andros@netapp.com> <1393954269-3974-4-git-send-email-andros@netapp.com> <1393958535.7035.1.camel@leira.trondhjem.org> <CAHVgHyWmRrBTmL-h4mrozPqw-gumqBRRy2TQrfC-yvQVuoE+Jw@mail.gmail.com>
To: Adamson William Andros <androsadamson@gmail.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


On Mar 5, 2014, at 3:51, Andy Adamson <androsadamson@gmail.com> wrote:

> On Tue, Mar 4, 2014 at 1:42 PM, Trond Myklebust
> <trond.myklebust@primarydata.com> wrote:
>> On Tue, 2014-03-04 at 12:31 -0500, andros@netapp.com wrote:
>>> From: Andy Adamson <andros@netapp.com>
>>> 
>>> Use the zero stateid if nfs4_select_rw_stateid indicates a lost lock (-EIO)
>>> 
>>> Signed-off-by: Andy Adamson <andros@netapp.com>
>>> ---
>>> fs/nfs/nfs4proc.c | 18 +++++++++++-------
>>> 1 file changed, 11 insertions(+), 7 deletions(-)
>>> 
>>> diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
>>> index de8e7f5..efe940c 100644
>>> --- a/fs/nfs/nfs4proc.c
>>> +++ b/fs/nfs/nfs4proc.c
>>> @@ -2458,18 +2458,22 @@ static int _nfs4_do_setattr(struct inode *inode, struct rpc_cred *cred,
>>>      truncate = (sattr->ia_valid & ATTR_SIZE) ? true : false;
>>>      fmode = truncate ? FMODE_WRITE : FMODE_READ;
>>> 
>>> -     if (nfs4_copy_delegation_stateid(&arg.stateid, inode, fmode)) {
>>> -             /* Use that stateid */
>>> -     } else if (truncate && state != NULL && nfs4_valid_open_stateid(state)) {
>>> +     if (nfs4_copy_delegation_stateid(&arg.stateid, inode, fmode))
>>> +             /* Use delegation stateid */
>>> +             goto do_call;
>>> +     if (truncate && state != NULL && nfs4_valid_open_stateid(state)) {
>>>              struct nfs_lockowner lockowner = {
>>>                      .l_owner = current->files,
>>>                      .l_pid = current->tgid,
>>>              };
>>> -             nfs4_select_rw_stateid(&arg.stateid, state, FMODE_WRITE,
>>> -                             &lockowner);
>>> -     } else
>>> -             nfs4_stateid_copy(&arg.stateid, &zero_stateid);
>>> +             /* Use zero stateid if lock is lost (-EIO fall through) */
>>> +             if (nfs4_select_rw_stateid(&arg.stateid, state, FMODE_WRITE,
>>> +                                             &lockowner) != -EIO)
>> 
>> Shouldn't we fail with EBADF instead?
> 
> Hmm. -EIO means lost lock, but not lost file, which is why I say we
> send it with a zero stateid.

If the application has lost the lock that was protecting the data, then why should we think it is safe to allow it to proceed to modify the file by truncating it?
_________________________________
Trond Myklebust
Linux NFS client maintainer, PrimaryData
trond.myklebust@primarydata.com


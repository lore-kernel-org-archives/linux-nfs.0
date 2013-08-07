Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:21420 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756335Ab3HGQbR (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 7 Aug 2013 12:31:17 -0400
Message-ID: <5202764C.2000709@redhat.com>
Date: Wed, 07 Aug 2013 09:31:08 -0700
From: Anand Avati <avati@redhat.com>
MIME-Version: 1.0
To: Miklos Szeredi <miklos@szeredi.hu>
CC: Ric Wheeler <rwheeler@redhat.com>, Al Viro <viro@zeniv.linux.org.uk>,
        Brian Foster <bfoster@redhat.com>, David Howells <dhowells@redhat.com>,
        Eric Paris <eparis@redhat.com>,
        Linux-Fsdevel <linux-fsdevel@vger.kernel.org>,
        Kernel Mailing List <linux-kernel@vger.kernel.org>,
        Linux NFS list <linux-nfs@vger.kernel.org>,
        Trond Myklebust <Trond.Myklebust@netapp.com>,
        Steven Whitehouse <swhiteho@redhat.com>,
        "mszeredi@suse.cz" <mszeredi@suse.cz>
Subject: Re: [PATCH 4/4] fuse: drop dentry on failed revalidate
References: <1375799403-28544-1-git-send-email-miklos@szeredi.hu> <1375799403-28544-5-git-send-email-miklos@szeredi.hu> <52015739.4050702@redhat.com> <CAJfpegsD8cgnW59crKABjTE1E5aNpmyO=91ubtNxxp=LnwjgDg@mail.gmail.com>
In-Reply-To: <CAJfpegsD8cgnW59crKABjTE1E5aNpmyO=91ubtNxxp=LnwjgDg@mail.gmail.com>
Content-Type: text/plain; charset=UTF-8; format=flowed
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 8/7/13 8:44 AM, Miklos Szeredi wrote:
> On Tue, Aug 6, 2013 at 10:06 PM, Anand Avati <avati@redhat.com> wrote:
>> On 8/6/13 7:30 AM, Miklos Szeredi wrote:
>>>
>>> From: Anand Avati <avati@redhat.com>
>>>
>>> Drop a subtree when we find that it has moved or been delated.  This can
>>> be
>>> done as long as there are no submounts under this location.
>>>
>>> If the directory was moved and we come across the same directory in a
>>> future lookup it will be reconnected by d_materialise_unique().
>>>
>>> Signed-off-by: Anand Avati <avati@redhat.com>
>>> Signed-off-by: Miklos Szeredi <mszeredi@suse.cz>
>>> ---
>>>    fs/fuse/dir.c | 7 ++++++-
>>>    1 file changed, 6 insertions(+), 1 deletion(-)
>>>
>>> diff --git a/fs/fuse/dir.c b/fs/fuse/dir.c
>>> index 131d14b..4ba5893 100644
>>> --- a/fs/fuse/dir.c
>>> +++ b/fs/fuse/dir.c
>>> @@ -226,8 +226,13 @@ static int fuse_dentry_revalidate(struct dentry
>>> *entry, unsigned int flags)
>>>                  if (!err) {
>>>                          struct fuse_inode *fi = get_fuse_inode(inode);
>>>                          if (outarg.nodeid != get_node_id(inode)) {
>>> +                               int ret = 0;
>>> +
>>> +                               if (check_submounts_and_drop(entry) != 0)
>>> +                                       ret = 1;
>>> +
>>>                                  fuse_queue_forget(fc, forget,
>>> outarg.nodeid, 1);
>>> -                               return 0;
>>> +                               return ret;
>>
>>
>> If outarg.nodeid != get_node_id(inode), then we have to return 0 no matter
>> what (whether we successfully dropped the entry or not), no?
>
> If we return 0 in that case (we failed to invalidate the dentry), then
> the VFS will call d_invalidate() which will fail.  The result is the
> same...
>
>> Or are you
>> trying to forcefully keep the path to reach the submount alive? If so, we
>> still fail in inode_permission() .. -> getattr() of the dir inode, no?
>
> Yes.  But the path to the mountpoint should still be reachable (for
> the purpose of unmounting for example).  I'm including an interesting
> discussion between Al and Linus about this (mailing lists weren't
> CC-d, but I don't think they'd mind).


Thanks for attaching the thread. Was very educative! I still do not 
quite understand - will umount() still work when 
inode_permission()[->getattr()] on the ancestors fail (with ESTALE 
etc.)? Wouldn't path resolution itself abort and fail and therefore 
do_umount() never called? I understand that the path to the mountpoint 
being reachable through the dentry chain is a necessity for umounting, 
but is just that really sufficient?

Avati

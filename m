Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-qa0-f54.google.com ([209.85.216.54]:45666 "EHLO
	mail-qa0-f54.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752395AbaCLNTJ (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 12 Mar 2014 09:19:09 -0400
Received: by mail-qa0-f54.google.com with SMTP id w8so9979678qac.13
        for <linux-nfs@vger.kernel.org>; Wed, 12 Mar 2014 06:19:08 -0700 (PDT)
Message-ID: <53205ECA.3080006@gmail.com>
Date: Wed, 12 Mar 2014 09:19:06 -0400
From: Anna Schumaker <schumaker.anna@gmail.com>
MIME-Version: 1.0
To: Jeff Layton <jlayton@redhat.com>,
        Trond Myklebust <trond.myklebust@primarydata.com>
CC: Eric Paris <eparis@redhat.com>, Schumaker Anna <Anna.Schumaker@netapp.com>,
        David Quigley <dpquigl@davequigley.com>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>,
        James Morris <james.l.morris@oracle.com>
Subject: Re: [PATCH] nfs: Don't assume we have a security structure
References: <1394572274-16474-1-git-send-email-Anna.Schumaker@netapp.com>	<29D9CA49-A493-471B-932B-959AFF96C729@primarydata.com>	<EEEA2B4E-BE0F-40C0-91C3-98E2E7E8BB35@primarydata.com>	<1394584698.10287.0.camel@localhost>	<20140311210611.0e82e3cf@ipyr.poochiereds.net>	<BA64BE59-8F58-456B-8E98-3F44A4CEC909@primarydata.com> <20140312062207.6b2ee85e@tlielax.poochiereds.net>
In-Reply-To: <20140312062207.6b2ee85e@tlielax.poochiereds.net>
Content-Type: text/plain; charset=windows-1252
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

I just tried Jeff's patch and it does fix my problem.  I wish I had remembered it earlier in the day yesterday!

On 03/12/2014 06:22 AM, Jeff Layton wrote:
> On Wed, 12 Mar 2014 05:21:13 -0400
> Trond Myklebust <trond.myklebust@primarydata.com> wrote:
>
>> On Mar 11, 2014, at 21:06, Jeffrey Layton <jlayton@redhat.com> wrote:
>>
>>> On Tue, 11 Mar 2014 20:38:18 -0400
>>> Eric Paris <eparis@redhat.com> wrote:
>>>
>>>> On Tue, 2014-03-11 at 18:00 -0400, Trond Myklebust wrote:
>>>>> On Mar 11, 2014, at 17:27, Trond Myklebust
>>>>> <trond.myklebust@primarydata.com> wrote:
>>>>>
>>>>>> On Mar 11, 2014, at 17:11, Anna Schumaker
>>>>>> <Anna.Schumaker@netapp.com> wrote:
>>>>>>
>>>>>>> If the i_security field isn't set then
>>>>>>> security_dentry_init_security() won't initialize some of the
>>>>>>> values used by the security label.  This causes my client to hit
>>>>>>> a BUG_ON() while encoding a label of size -2128927414.
>>>>>>>
>>>>>>> I hit this bug while testing on a client without SELinux
>>>>>>> installed.
>>>>>>>
>>>>>>> Signed-off-by: Anna Schumaker <anna.schumaker@netapp.com>
>>>>>>> ---
>>>>>>> fs/nfs/nfs4proc.c | 3 +++
>>>>>>> 1 file changed, 3 insertions(+)
>>>>>>>
>>>>>>> diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
>>>>>>> index b8cd560..994ccc2 100644
>>>>>>> --- a/fs/nfs/nfs4proc.c
>>>>>>> +++ b/fs/nfs/nfs4proc.c
>>>>>>> @@ -105,6 +105,9 @@ nfs4_label_init_security(struct inode *dir,
>>>>>>> struct dentry *dentry, if (nfs_server_capable(dir,
>>>>>>> NFS_CAP_SECURITY_LABEL) == 0) return NULL;
>>>>>>>
>>>>>>> +	if (!dir->i_security)
>>>>>>> +		return NULL;
>>>>>>> +
>>>>>>> 	err = security_dentry_init_security(dentry,
>>>>>>> sattr->ia_mode, &dentry->d_name, (void **)&label->label,
>>>>>>> &label->len); if (err == 0)
>>>>>> Hi Anna,
>>>>>>
>>>>>> This looks like a check that needs to be done by
>>>>>> selinux_dentry_init_security() itself. The dir->i_security field
>>>>>> is not something that NFS knows about. David, what needs to
>>>>>> happen there when dentry->d_parent->i_security (a.k.a. dsec) is
>>>>>> NULL?
>>>>>>
>>>>> Oh, wait. I missed the bit about ‘without SELinux installed’. So
>>>>> the problem here is that you have a NFS client that does not have
>>>>> SELinux set up, but running against a server that is advertising
>>>>> NFSv4.2 with labeled NFS. Is that correct?
>>>>>
>>>>> It looks to me as if cap_dentry_init_security() will indeed trigger
>>>>> this behaviour since it returns ‘0’ without doing anything to the
>>>>> label. As far as I can see, the right thing to do there is to
>>>>> return -EOPNOTSUPP, no?
>>>> I feel like Jeff Layton was looking at the same thing, and came to the
>>>> same conclusion...
>>>>
>>>> Jeff?
>>>>
>>> I posted a patch for this last week and James has merged it:
>>>
>>>    [PATCH] security: have cap_dentry_init_security return error
>>>
>>> I didn't note it in the patch description but it fixes 4.2 when SELinux
>>> is compiled in but disabled.
>> Thanks! Then I expect no further action is needed on our part, and that the fix will come through the security tree?
>>
> FWIW, this is the bug that was causing the NFS server to spew messages
> like this to the ring buffer when Anna was testing against my server at
> Connectathon:
>
>     [  243.479524] SELinux:  Context \xffffffdf is not valid (left unmapped).
>
> We may want to do a follow-on patch to clean up the struct nfs4_label
> initializers since they're not really needed. But that should probably
> wait until James merges this up to Linus.
>


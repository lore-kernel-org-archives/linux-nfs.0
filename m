Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:28978 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932066Ab1JRPRY (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 18 Oct 2011 11:17:24 -0400
Message-ID: <4E9D9880.3010300@RedHat.com>
Date: Tue, 18 Oct 2011 11:17:20 -0400
From: Steve Dickson <SteveD@redhat.com>
MIME-Version: 1.0
To: Hamo <hamo.by@gmail.com>
CC: Chuck Lever <chuck.lever@oracle.com>,
        Trond Myklebust <Trond.Myklebust@netapp.com>,
        linux-nfs@vger.kernel.org, linux-fsdevel@vger.kernel.org,
        linux-kernel@vger.kernel.org
Subject: Re: [PATCH] nfs-utils: mount: really return from errno test
References: <CAO_0yfPgXJJSZNDYXHBSt45J0WQsh5EQVUs0nBN4wb+NoT6hAQ@mail.gmail.com> <40D1A40C-BE0C-4AE0-857D-05531615748E@oracle.com> <4E971329.3000007@RedHat.com> <4E9718E3.8040805@RedHat.com> <D7792A21-C227-4A3B-9FBA-E08BF224620C@oracle.com> <4E973600.1090806@RedHat.com> <CAO_0yfPyAtoWgEsMuy_78a_wVas3U07F_XmqaU5eXJ8GL2sVSA@mail.gmail.com>
In-Reply-To: <CAO_0yfPyAtoWgEsMuy_78a_wVas3U07F_XmqaU5eXJ8GL2sVSA@mail.gmail.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>



On 10/15/2011 09:12 AM, Hamo wrote:
> [Copy from RedHat Bugzilla]
> 
> The real problem is here:
> 
> [root@dell-pe2950-01 ~]# mount -t nfs -v rhel6-nfs:/export/home /mnt/testdir
> mount.nfs: timeout set for Fri Oct 14 05:42:43 2011
> mount.nfs: trying text-based options
> 'vers=4,addr=fec0:0:a10:4000:221:5eff:fe95:20f4,clientaddr=fec0:0:a10:4000:213:72ff:fe62:469b'
> rhel6-nfs:/export/home on /mnt/testdir type nfs (rw)
> 
> 
> [root@dell-pe2950-01 ~]# mount -t nfs -v rhel6-nfs:/export/home /mnt/testdir
> mount.nfs: timeout set for Fri Oct 14 05:42:52 2011
> mount.nfs: trying text-based options
> 'vers=4,addr=fec0:0:a10:4000:221:5eff:fe95:20f4,clientaddr=fec0:0:a10:4000:213:72ff:fe62:469b'
> mount.nfs: mount(2): Device or resource busy
> ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
> mount.nfs: trying text-based options
> 'vers=4,addr=10.16.64.25,clientaddr=10.16.64.133'
> rhel6-nfs:/export/home on /mnt/testdir type nfs (rw)
> 
> mount has already found that this server has been mounted but also fallback to
> mount it using IPv4. This patch fix this problem.
Ah... I see... thanks...

steved.

> 
> 
> On Fri, Oct 14, 2011 at 3:03 AM, Steve Dickson <SteveD@redhat.com> wrote:
>>
>>
>> On 10/13/2011 01:54 PM, Chuck Lever wrote:
>>>
>>> On Oct 13, 2011, at 12:59 PM, Steve Dickson wrote:
>>>
>>>> Looking further into this issue, I noticed all the following
>>>> mounts were successful.
>>>>
>>>> # mount -o v3 localhost:/home /mnt/home
>>>> # mount -o v4 localhost:/home /mnt/home
>>>
>>> Does this actually change the NFS version in use for /mnt/home, or does the client recognize that this is the same server and export as an existing mount point, and share the cache and mount options?
>> Using wireshark, I verified that the version does indeed change...
>>
>>>
>>> If the mount options are the same, this is equivalent to
>>>
>>> # mount -o v3 localhost:/home /mnt/home
>>> # mount -o v3 localhost:/home /mnt/home
>> In this case the second mount does fail with EBUSY..
>>
>> steved.

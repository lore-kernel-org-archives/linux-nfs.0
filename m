Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-vc0-f174.google.com ([209.85.220.174]:39452 "EHLO
	mail-vc0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755035AbaIPT2g (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 16 Sep 2014 15:28:36 -0400
Received: by mail-vc0-f174.google.com with SMTP id hy10so359026vcb.5
        for <linux-nfs@vger.kernel.org>; Tue, 16 Sep 2014 12:28:35 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <CADnza45-ytG-0GcfS3Q0SczekP9M+F9z5EJA0dMsbhD3V=d2Gg@mail.gmail.com>
References: <53D7EA62.3070204@RedHat.com>
	<CAHQdGtQ2DU4GnMXy=n9JQzUhGkEC=+UEM8NVm=MviBt0+RJzBA@mail.gmail.com>
	<53D806C1.9030206@RedHat.com>
	<CAHQdGtRkbjKXvzBSQvEyrnOvmiWSrwHMe+9eiEvvDz5Pm6WGNA@mail.gmail.com>
	<CADnza45-ytG-0GcfS3Q0SczekP9M+F9z5EJA0dMsbhD3V=d2Gg@mail.gmail.com>
Date: Tue, 16 Sep 2014 15:28:35 -0400
Message-ID: <CAHQdGtToAxvW2CWibgPyRA9phHw+sVmyO0kCCS-41DWs2OcTbg@mail.gmail.com>
Subject: Re: nfs4_state_manager() vs. nfs_server_remove_lists()
From: Trond Myklebust <trond.myklebust@primarydata.com>
To: Fred Isaman <iisaman@netapp.com>
Cc: Steve Dickson <SteveD@redhat.com>,
        Linux NFS Mailing list <linux-nfs@vger.kernel.org>,
        Andy Adamson <andros@netapp.com>
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, Sep 16, 2014 at 2:51 PM, Fred Isaman <iisaman@netapp.com> wrote:
> Was a patch ever submitted for this?  I'm seeing something similar but can't
> find the fix upstream.

As far as I can tell, the answer is no. If you are seeing the bug,
then could you please post the discussed fix?

Cheers
  TRond

>
> Fred
>
> On Tue, Jul 29, 2014 at 5:58 PM, Trond Myklebust
> <trond.myklebust@primarydata.com> wrote:
>>
>> On Tue, Jul 29, 2014 at 4:40 PM, Steve Dickson <SteveD@redhat.com> wrote:
>> > On 29/07/14 15:52, Trond Myklebust wrote:
>> >> Let's just move up the test for "pos->rpc_ops != new->rpc_ops",
>> >> "pos->cl_minorversion != new->cl_minorversion" and "pos->cl_proto !=
>> >> new->cl_proto" so that they all happen before we try to test the value
>> >> of cl_cons_state.
>> >> As far as I can tell, all those values are guaranteed to be set as
>> >> part of the struct nfs_client allocators, before we ever put the
>> >> result on the cl_share_link list.
>> >
>> > The check for
>> >    if (pos->cl_cons_state > NFS_CS_READY)
>> >
>> > then right after that check is:
>> >
>> >    if (pos->cl_cons_state != NFS_CS_READY)
>> >          continue;
>> >
>> > confuses me... Is the second check even needed?
>> >
>> > steved.
>>
>> Yes. The result of the lease_recovery could be that the nfs_client is
>> left in a state of error if, say, we get a NFS4ERR_CLID_INUSE beastie.
>>
>> Cheers
>>   Trond
>>
>> --
>> Trond Myklebust
>>
>> Linux NFS client maintainer, PrimaryData
>>
>> trond.myklebust@primarydata.com
>> --
>> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
>> the body of a message to majordomo@vger.kernel.org
>> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>
>



-- 
Trond Myklebust

Linux NFS client maintainer, PrimaryData

trond.myklebust@primarydata.com

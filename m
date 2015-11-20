Return-Path: <trond.myklebust@primarydata.com>
MIME-Version: 1.0
In-Reply-To: <alpine.OSX.2.19.9992.1511201147450.34561@planck.local>
References: <da06a514114528e639923b8ef26c0e815e91554f.1448031050.git.bcodding@redhat.com>
	<CAHQdGtTTqDtg==fK_2t7dOOh_54tDf84Hov2+D6Ciy=YvhzyoQ@mail.gmail.com>
	<alpine.OSX.2.19.9992.1511201147450.34561@planck.local>
Date: Fri, 20 Nov 2015 11:57:50 -0500
Message-ID: <CAHQdGtTZitKGWXszk8W60-DkKAghdU6UrPbJ42MSdn08difj5Q@mail.gmail.com>
Subject: Re: [PATCH] nfs4: start callback_ident at idr 1
From: Trond Myklebust <trond.myklebust@primarydata.com>
To: Benjamin Coddington <bcodding@redhat.com>
Cc: Anna Schumaker <anna.schumaker@netapp.com>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Content-Type: text/plain; charset=UTF-8
List-ID: <linux-nfs.vger.kernel.org>

On Fri, Nov 20, 2015 at 11:56 AM, Benjamin Coddington
<bcodding@redhat.com> wrote:
> On Fri, 20 Nov 2015, Trond Myklebust wrote:
>
>> Hi Ben,
>>
>> On Fri, Nov 20, 2015 at 9:56 AM, Benjamin Coddington
>> <bcodding@redhat.com> wrote:
>> >
>> > If clp->cl_cb_ident is zero, then nfs_cb_idr_remove_locked() skips removing
>> > it when the nfs_client is freed.  A decoding or server bug can then find
>> > and try to put that first nfs_client which would lead to a crash.
>>
>> Thanks for fixing!
>> Have you ever seen such a crash in the wild? IOW: is this something we
>> should consider for stable?
>
> Yes, there's a server that sometimes sends truncated cb_compounds, and this
> bug is hit if we continue decoding 0's past the end of received data since
> cb_ident ends up being 0.  Both fixes I sent today are trying to handle that
> particular behavior.
>

OK. I'll mark both for stable inclusion then.

Thanks!

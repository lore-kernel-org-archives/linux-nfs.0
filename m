Return-Path: trond.myklebust@primarydata.com
MIME-Version: 1.0
In-Reply-To: <alpine.LRH.2.11.1411111017190.20279@sh-el6.eng.rdu2.redhat.com>
References: <alpine.LRH.2.11.1411110930190.20279@sh-el6.eng.rdu2.redhat.com>
	<CAHQdGtQSSeOWs9pzZoXzR_+2F69-EJQB5BOEkB7q9BVE-d=RFA@mail.gmail.com>
	<alpine.LRH.2.11.1411111017190.20279@sh-el6.eng.rdu2.redhat.com>
Date: Tue, 11 Nov 2014 10:24:29 -0500
Message-ID: <CAHQdGtR3N_2nvjpLH8t4Q8rq+P0CUebVbueXnkLVuc2JJxuo-w@mail.gmail.com>
Subject: Re: mount default minor version behavior
From: Trond Myklebust <trond.myklebust@primarydata.com>
To: Benjamin Coddington <bcodding@redhat.com>
Cc: Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Content-Type: text/plain; charset=UTF-8
List-ID: <linux-nfs.vger.kernel.org>

On Tue, Nov 11, 2014 at 10:20 AM, Benjamin Coddington
<bcodding@redhat.com> wrote:
>
>
> On Tue, 11 Nov 2014, Trond Myklebust wrote:
>
>> Hi Ben,
>>
>> On Tue, Nov 11, 2014 at 9:39 AM, Benjamin Coddington
>> <bcodding@redhat.com> wrote:
>> > I will update mount.nfs so the default version is 4.1.  I have two quick
>> > questions on desired behavior:
>> >
>> >  o  Should mounts that do not specify a minor version be upgraded to the
>> > default minor version?
>> >
>> > For example, should 'mount -overs=4' turn into 'mount -overs4.1', if the
>> > current default is 4.1?
>> >
>> >
>> >  o If 'yes' to the above, should mount auto-retry decrementing minor
>> > versions if EPROTONOSUPPORT?
>> >
>> > For example, 'mount -overs=4' with a default of 4.2 would attempt: 4.2,
>> > then 4.1, then 4.0.
>> >
>>
>> One thing you should note when doing this: the current parser for
>> /etc/nfsmount.conf does not support minor versions. I think it needs
>> to, so that we can continue to use it to set defaults.
>>
>> ...and to answer your questions above, I think that we should be able
>> to specify a 'default nfsv4 minor version' in /etc/nfsmount.conf, and
>> then negotiate down from there.
>> IOW: extend the 'Defaultvers' and 'Nfsvers' options to support 4.0,
>> 4.1, 4.2,....
>
> Ah, good idea to make it configurable.
>
>> The result should be that If I do 'mount -t nfs' with no '-overs'
>> option, then we start at 4.1 (if that is the default in
>> /etc/nfsmount.conf) and then try 4.0, 3, 2 in that order.
>> If I do 'mount -t nfs -overs=4', then again consult /etc/nfsmount.conf;
>> - if there is a default matching a v4 minor version, then start at
>> that and negotiate down (but stop at 4.0).
>
> Yep, those closely match the current behavior and that's what my first
> pass looks like.
>
>> - if there is no default in /etc/nfsmount.conf, then perhaps assume a
>> default of 0(????)
>
> That's the question, and I think it will be a very common case.  Do we
> want to have an idea of a "best" minor version, and use that if no minor
> version is specified?

My hunch would be that if nothing is specified in /etc/nfsmount.conf,
then we should stick to the current default (i.e. 4==4.0) so that we
do not break existing setups.

Cheers
  Trond
-- 
Trond Myklebust

Linux NFS client maintainer, PrimaryData

trond.myklebust@primarydata.com

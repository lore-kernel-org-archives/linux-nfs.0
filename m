Return-Path: Anna.Schumaker@netapp.com
Message-ID: <54622ADF.4080807@Netapp.com>
Date: Tue, 11 Nov 2014 10:27:27 -0500
From: Anna Schumaker <Anna.Schumaker@netapp.com>
MIME-Version: 1.0
To: Benjamin Coddington <bcodding@redhat.com>,
        Trond Myklebust
	<trond.myklebust@primarydata.com>
CC: Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Subject: Re: mount default minor version behavior
References: <alpine.LRH.2.11.1411110930190.20279@sh-el6.eng.rdu2.redhat.com> <CAHQdGtQSSeOWs9pzZoXzR_+2F69-EJQB5BOEkB7q9BVE-d=RFA@mail.gmail.com> <alpine.LRH.2.11.1411111017190.20279@sh-el6.eng.rdu2.redhat.com>
In-Reply-To: <alpine.LRH.2.11.1411111017190.20279@sh-el6.eng.rdu2.redhat.com>
Content-Type: text/plain; charset="utf-8"
List-ID: <linux-nfs.vger.kernel.org>

Hi Ben,

On 11/11/2014 10:20 AM, Benjamin Coddington wrote:
>
> On Tue, 11 Nov 2014, Trond Myklebust wrote:
>
>> Hi Ben,
>>
>> On Tue, Nov 11, 2014 at 9:39 AM, Benjamin Coddington
>> <bcodding@redhat.com> wrote:
>>> I will update mount.nfs so the default version is 4.1.  I have two quick
>>> questions on desired behavior:
>>>
>>>  o  Should mounts that do not specify a minor version be upgraded to the
>>> default minor version?
>>>
>>> For example, should 'mount -overs=4' turn into 'mount -overs4.1', if the
>>> current default is 4.1?
>>>
>>>
>>>  o If 'yes' to the above, should mount auto-retry decrementing minor
>>> versions if EPROTONOSUPPORT?
>>>
>>> For example, 'mount -overs=4' with a default of 4.2 would attempt: 4.2,
>>> then 4.1, then 4.0.
>>>
>> One thing you should note when doing this: the current parser for
>> /etc/nfsmount.conf does not support minor versions. I think it needs
>> to, so that we can continue to use it to set defaults.
>>
>> ...and to answer your questions above, I think that we should be able
>> to specify a 'default nfsv4 minor version' in /etc/nfsmount.conf, and
>> then negotiate down from there.
>> IOW: extend the 'Defaultvers' and 'Nfsvers' options to support 4.0,
>> 4.1, 4.2,....
> Ah, good idea to make it configurable.
>
>> The result should be that If I do 'mount -t nfs' with no '-overs'
>> option, then we start at 4.1 (if that is the default in
>> /etc/nfsmount.conf) and then try 4.0, 3, 2 in that order.
>> If I do 'mount -t nfs -overs=4', then again consult /etc/nfsmount.conf;
>> - if there is a default matching a v4 minor version, then start at
>> that and negotiate down (but stop at 4.0).
> Yep, those closely match the current behavior and that's what my first
> pass looks like.
>
>> - if there is no default in /etc/nfsmount.conf, then perhaps assume a
>> default of 0(????)
> That's the question, and I think it will be a very common case.  Do we
> want to have an idea of a "best" minor version, and use that if no minor
> version is specified?

I don't think so.  Right now users know that if they don't use a minor version then they'll be getting a v4.0 mount.  I think we should keep this behavior so we don't accidentally break people's configuration.

Anna

>
> Ben
>
>> Cheers
>>   Trond
>>
>>
>> --
>> Trond Myklebust
>>
>> Linux NFS client maintainer, PrimaryData
>>
>> trond.myklebust@primarydata.com
>>
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

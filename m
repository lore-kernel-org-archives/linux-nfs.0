Return-Path: trond.myklebust@primarydata.com
MIME-Version: 1.0
In-Reply-To: <5462608B.1090607@RedHat.com>
References: <alpine.LRH.2.11.1411110930190.20279@sh-el6.eng.rdu2.redhat.com>
	<CAHQdGtQSSeOWs9pzZoXzR_+2F69-EJQB5BOEkB7q9BVE-d=RFA@mail.gmail.com>
	<5462608B.1090607@RedHat.com>
Date: Tue, 11 Nov 2014 15:43:05 -0500
Message-ID: <CAHQdGtQtQaGYsnaf+rVpNfkSRK97AEMU=2-Yx+GtwGXgNHcf1w@mail.gmail.com>
Subject: Re: mount default minor version behavior
From: Trond Myklebust <trond.myklebust@primarydata.com>
To: Steve Dickson <SteveD@redhat.com>
Cc: Benjamin Coddington <bcodding@redhat.com>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Content-Type: text/plain; charset=UTF-8
List-ID: <linux-nfs.vger.kernel.org>

On Tue, Nov 11, 2014 at 2:16 PM, Steve Dickson <SteveD@redhat.com> wrote:
>
>
> On 11/11/2014 10:01 AM, Trond Myklebust wrote:
>> One thing you should note when doing this: the current parser for
>> /etc/nfsmount.conf does not support minor versions. I think it needs
>> to, so that we can continue to use it to set defaults.
> Well setting Nfsvers=4.1 will give you a v4.1 mounts (assuming
> the server supports v4.1. but setting Defaultvers=4.1 does
> give you a v4.0 mount, which will need to be fixed.
>
>>
>> ...and to answer your questions above, I think that we should be able
>> to specify a 'default nfsv4 minor version' in /etc/nfsmount.conf, and
>> then negotiate down from there.
>> IOW: extend the 'Defaultvers' and 'Nfsvers' options to support 4.0,
>> 4.1, 4.2,....
> Well Defaultvers is a negotiation with the server, Nfsvers is not.
> So when Nfsvers set set there is no  negotiation, they get what is
> set to (aka 3, 4, 4.0, 4.1, just like the command line).
>
> With  Defaultvers its a negotiation so set it to highest
> version and let it go... I'm not sure we need another
> variable to complicate things...
>
>>
>> The result should be that If I do 'mount -t nfs' with no '-overs'
>> option, then we start at 4.1 (if that is the default in
>> /etc/nfsmount.conf) and then try 4.0, 3, 2 in that order.
>> If I do 'mount -t nfs -overs=4', then again consult /etc/nfsmount.conf;
>> - if there is a default matching a v4 minor version, then start at
>> that and negotiate down (but stop at 4.0).
> Again, I'm thinking this type of  complexity is not needed (especially
> from a testing matrix point of view).
>
> besides, if someone is specifying a version on the command line, is most likely
> they are not going to be using /etc/nfsmount.conf as all...
>
>> - if there is no default in /etc/nfsmount.conf, then perhaps assume a
>> default of 0(????)
> I'm thinking why not default to the better minor version?? 4.1 => 4.0 => 3

So at which minor version do you start? 4.10, 4.100?...
We don't want to have to recompile mount every time we add a new minor
version in order to bump the maximum number, which is why I think we
want to use /etc/nfsmount.conf and Defaultvers to define that (and
assume '0' if undefined).


-- 
Trond Myklebust

Linux NFS client maintainer, PrimaryData

trond.myklebust@primarydata.com

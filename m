Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:57186 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S932441AbcLHAim (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Wed, 7 Dec 2016 19:38:42 -0500
Subject: Re: [PATCH 03/15] Add /etc/nfs.conf support to rpc.nfsd
To: NeilBrown <neilb@suse.com>, "J. Bruce Fields" <bfields@redhat.com>
References: <148065078775.28046.5506130555300891075.stgit@noble>
 <148065110833.28046.2561331715736018574.stgit@noble>
 <8e72acac-42de-bf02-9069-60e7b6a12c04@RedHat.com>
 <87r35k4rcr.fsf@notabene.neil.brown.name>
 <35ca5ad2-39db-a46b-13b2-a2e5128793a0@RedHat.com>
 <20161207180843.GA20626@parsley.fieldses.org>
 <877f7bs55d.fsf@notabene.neil.brown.name>
Cc: linux-nfs@vger.kernel.org
From: Steve Dickson <SteveD@redhat.com>
Message-ID: <aaadbd73-5528-4069-d3bb-a6d99fa19a0a@RedHat.com>
Date: Wed, 7 Dec 2016 19:38:41 -0500
MIME-Version: 1.0
In-Reply-To: <877f7bs55d.fsf@notabene.neil.brown.name>
Content-Type: text/plain; charset=windows-1252
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>



On 12/07/2016 06:14 PM, NeilBrown wrote:
>> If you do that then I'd allow a minimum too.
> Why?  I'm trying to understand why you would ever want to turn disable a
> particular minor version.  I could equally well ask myself "why specify
> a maximum"...
I think I agree with this... Why put limits on what version
people can use.

> 
> Benny's patch only suggests that it removes the need for
> CONFIG_NFSD_V4_1, but why was that needed?
> Maybe it is just to disable buggy code if some version is found to have
> an inconvenient bug?  The client, by default, tries 4.2, then 4.1, then
> 4.0.  Older clients might start elsewhere.  So just disabling unreliable
> versions individually does seem to make sense.
> 
> I note that Benny's original patch disabled v4.1 by default, and
> required it to be explicitly enabled.  The current kernel enables all by
> default, and requires them be explicitly disabled is required.
I think it was to protect distros from enabling code 
they were not going to test. I remember it was a while until
RHEL6 enable the v4.1 code because we were not willing to
support it. 

> My current nfs.conf code will disabled unwanted minor versions, but not
> enable any that are already disabled ... I guess I could fix that.
I think disabling minor version for nfs.conf is perfect! 

But the only issue I see... how does one distribute that
configuration over thousands of servers/vms... that is
something we have never been good at... IMHO.
 
> 
> .... it is a shame that we can only enable/disable minor versions
> when there are no nfsd threads running.  The justification for
> failing if nfsd is active is fairly lame, and only applies
> to major versions.  If minor versions could be changed at any time,
> then it could be a simple function of rpc.nfsd, and the config
> file would never need to enable things, only disable them.
As you know rpc.nfsd is a hit and run command... It 
sets things up and then exits. I just don't see why there
would be a need to change the support of minor versions
on the fly? What about existing mounts?? Or maybe I'm
misunderstanding... 
 
> 
> Is there any other reason to disable minor versions, other than to avoid
> buggy code (either in server or client)??
There seems to be a history in Linux to be able to configure
exactly what you what in or out... Which is not a bad thing, IMHO. 
 
> 
> 
> Actually.... I have a related question that I keep meaning to ask, but
> haven't.
> 
> What are the circumstances where NFSv3 should be preferred over NFSv4
> (assuming up-to-date kernels on server and client)?
Good Question... This is worthy of a another thread! : -) 

> 
> I can think of:
>  - NFSv3 is safer if you might need to support loop-back mounts
>    as I don't think NFSv4 state management can reliably make forward
>    progress against memory pressure.  In particular, creating the
>    state-manager thread can deadlock waiting for an NFS write.
Agreed... v3 loopback make more sense that v4 mounts but 
what is the sense of doing NFS lookback mount in the
first place? Why not just do bind mount and be done with it! 

> 
>  - If you want fast-failover from one server to another,
>    NFSv3 is probably faster as it only imposes the grace-time on
>    lock requests.  NFSv4 imposes it on OPEN and so READ/WRITE
>    as well.
v3 will always be faster... IMHO... The less data to move will
always win the race. 

> 
>  - NFSv3 is preferred if (for some weird reason) you need
>    to use UDP.
Do you known anybody that is this position? As you know I'm
beating the path to turn off UDP support for all NFS daemons.

> 
> Are there any others?  Are there any similar reasons to prefer a smaller
> NFSv4 minor version over a larger one?
I'm thinking no... to the last question... v4.0 was the beginning,
v4.1 was better (recent server only support 4.1), and 4.2 has
features that will seriously improve performance...  
In theory :-) 

steved.  

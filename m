Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-gy0-f174.google.com ([209.85.160.174]:63115 "EHLO
	mail-gy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S934883Ab0KQQ0M convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 17 Nov 2010 11:26:12 -0500
Received: by gyh4 with SMTP id 4so1185710gyh.19
        for <linux-nfs@vger.kernel.org>; Wed, 17 Nov 2010 08:26:12 -0800 (PST)
In-Reply-To: <013E9F9C-F4F8-47E6-939D-1B0D893B6988@oracle.com>
References: <1C8B051A-5DC1-4871-B9B9-96E571036A9B@oracle.com>
	<4CE2AA3B.6070302@openoffice.nl>
	<4CE2DF2D.9070603@blub.net>
	<20101116201753.GB4482@merit.edu>
	<577C5BE5-DB69-48E2-9E99-26ACE90C96BF@oracle.com>
	<20101116205436.GA4595@merit.edu>
	<44C0977F-DBD6-4F87-B3A5-B2B66C784312@oracle.com>
	<4CE3F249.8050301@RedHat.com>
	<C2312B32-B190-41C4-A4C8-C29231DBA305@oracle.com>
	<AANLkTinJyFHom5JQg5s+yX+6NRBw01S6a9gbwtk5WaLB@mail.gmail.com>
	<013E9F9C-F4F8-47E6-939D-1B0D893B6988@oracle.com>
Date: Wed, 17 Nov 2010 11:26:11 -0500
Message-ID: <AANLkTi=CgbEAewXEtErN5KxmNyWCL8-Jqc69v67cgZ2J@mail.gmail.com>
Subject: Re: Strange rpc.svcgssd behavior
From: Kevin Coffman <kwc@citi.umich.edu>
To: Chuck Lever <chuck.lever@oracle.com>
Cc: Steve Dickson <SteveD@redhat.com>, Jim Rees <rees@umich.edu>,
        Valentijn Sessink <valentyn@blub.net>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Wed, Nov 17, 2010 at 11:05 AM, Chuck Lever <chuck.lever@oracle.com> wrote:
>
> On Nov 17, 2010, at 10:54 AM, Kevin Coffman wrote:
>
>> On Wed, Nov 17, 2010 at 10:30 AM, Chuck Lever <chuck.lever@oracle.com> wrote:
>>> Hey-
>>>
>>> On Nov 17, 2010, at 10:18 AM, Steve Dickson wrote:
>>>
>>>> Sorry for the delayed response... I had my
>>>> head down for last couple of days...
>>>>
>>>> On 11/16/2010 04:42 PM, Chuck Lever wrote:
>>>>>
>>>>> On Nov 16, 2010, at 3:54 PM, Jim Rees wrote:
>>>>>
>>>>>> Chuck Lever wrote:
>>>>>>
>>>>>> Before we go too far down the NM path of no return, I was under the
>>>>>> impression that some applications require the host's name on the localhost
>>>>>> entries in /etc/hosts.  That's why NM puts it there.
>>>>>>
>>>>>> There's nothing invalid about having a hostname on the localhost entries
>>>>>> in /etc/hosts, is there?
>>>>>>
>>>>>> So I wonder if removing NM is really the solution here.
>>>>>>
>>>>>> No, it's not.  I just like to complain about NM.
>>>>>>
>>>>>> The original problem was that rpc.svcgssd couldn't figure out the correct
>>>>>> kerberos realm.  The fix in this particular case, I think, is to set the
>>>>>> realm explicitly in /etc/idmapd.conf.
>>>>>
>>>>> It's having trouble determining the NFS server's hostname.  It needs to find the right nfs/your.host key in /etc/krb5.keytab.
>>>>>
>>>>> I don't know if realm self-discovery is an issue too.
>>>> I think the problem is a reverse lookup is done on hostname that
>>>> is found in the /etc/krb5.keytab. Instead of the FQDN being
>>>> returned, localhost is returned because the FQDN was added to
>>>> the localhost line in /etc/hosts.
>>>>
>>>> Actually I didn't realize it was NM doing that... I thought
>>>> it was the installer...
>>>
>>> No matter who does it, I think there are applications
>>> (gdm?  rusty recollection) that require this network configuration
>>> in /etc/hosts, so our best bet IMO is to fix rpc.svcgssd, or more
>>> likely the gss library it depends on, to get it right in this situation.
>>> If we all agree this is a bug (and sounds like we do) then I can
>>> create a bug report on bugzilla.linux-nfs.org, as a starting point.
>>
>> Hi Chuck and Steve,
>> This issue affects gss authentication in sshd as well.  I believe this
>> is all the way down in the Kerberos code, which has been this way for
>> years.  I'm not sure what needs to be changed to "get it right".
>
> I was afraid of that.  Do you know if this has this ever been brought
> up with the upstream Kerberos maintainers?

Not that I am aware of.  Like Valentin, I believe it to be a
NetworkManager bug.  (The Kerberos code works fine on all other Unix
platforms.)

K.C.

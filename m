Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx11.netapp.com ([216.240.18.76]:17058 "EHLO mx11.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755010Ab3HAODn convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 1 Aug 2013 10:03:43 -0400
From: "Adamson, Dros" <Weston.Adamson@netapp.com>
To: "J. Bruce Fields" <bfields@fieldses.org>
CC: linux-nfs list <linux-nfs@vger.kernel.org>
Subject: Re: SP4_MACH_CRED
Date: Thu, 1 Aug 2013 14:03:29 +0000
Message-ID: <0E0FF4CB-4388-417B-9D1C-24940472D844@netapp.com>
References: <A0A1021A-64E6-4E0C-89A5-9F719C8E1AFC@netapp.com>
 <20130731213904.GB2668@fieldses.org>
 <75E5568D-320C-45A1-B7E6-23CE73217BAF@netapp.com>
 <20130731234800.GC2668@fieldses.org>
In-Reply-To: <20130731234800.GC2668@fieldses.org>
Content-Type: text/plain; charset="Windows-1252"
MIME-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


On Jul 31, 2013, at 7:48 PM, J. Bruce Fields <bfields@fieldses.org> wrote:

> On Wed, Jul 31, 2013 at 10:22:22PM +0000, Adamson, Dros wrote:
>> 
>> On Jul 31, 2013, at 5:39 PM, "J. Bruce Fields" <bfields@fieldses.org>
>> wrote:
>> 
>>> This should probably be cc'd to the mailing list.
>> 
>> Agreed!
>> 
>>> 
>>> On Wed, Jul 31, 2013 at 09:25:29PM +0000, Adamson, Dros wrote:
>>>> I have a pretty functional client-side SP4_MACH_CRED implementation
>>>> and I'm trying to implement the server side so I can fully test the
>>>> client code. I was testing against another server, but that didn't
>>>> implement any useful set of operations other than the required ones.
>>> 
>>> The latest Linux server implements SP4_MACH_CRED but only for the
>>> required operations.  (But that hasn't really been tested--any testing
>>> even to make sure that basic stuff works would be welcomed.)
>>> 
>> 
>> Right, I'm happy to report that the initial implementation of the required operations seems to work with (at least) one small patch I'll send your way soon.
>> 
>>>> I'm currently trying to figure out the best way to set nfsd's current cred to that of the user really doing the operation.
>>>> 
>>>> i.e.:
>>>> 
>>>> - WRITE, CLOSE, LOCKT, LOCKU are supported by SP4_MACH_CRED.
>>> 
>>> "are supported by" means they're included in the spo_must_allow list
>>> returned by the server?
>>> 
>> 
>> Yes, what I meant was "the client thinks it can use the machine cred for these ops".
>> 
>>>> - OPEN calls use the user cred
>>>> - When cred expires, SP4_MACH_CRED kicks in and cached WRITE calls are sent out using the machine cred.
>>>> - nfsd handles request with the machine cred as the current cred
>>>> 
>>>> Currently, these writes fail in nfsd_permission (after I made a few other
>>>> changes) because the current cred (the machine cred of the client) maps to
>>>> a UID that is not the owner of the file (even though the io was done as the
>>>> user).
>>>> 
>>>> I think what we need is a way to look up the cred associated with the state owner of the current operation's stateid and use that as the current credential when the machine cred is in use.
>>> 
>>> Is there a rule that says a stateowner or stateid can only be used with
>>> one credential?  If not, I'm not sure what you mean by "the cred
>>> associated with the state owner of the current operation's stateid".
>>> 
>>> Maybe we could just pick "a cred" instead of "the cred"?  So stash the
>>> last cred used with a given stateid in the stateid, and use that in this
>>> case?
>> 
>> Yeah... I was a bit confused.  This sounds like a good approach. Thanks!
>> 
>>> 
>>>> Does that make sense to you? Is there something like this already? If
>>>> not, any pointers on what you'd like to see?
>>> 
>>> As a user I'd normally expect that once my credentials have expired, the
>>> client will no longer be able to write to my files.
>> 
>> That's true with unbuffered writes, but what about buffered writes that are already considered written by the application?
> 
> Well, the server can't distinguish between these two, all it can do is
> say that once you've allowed the client to open a file as you, it's
> going to continue allowing the client to access the file without needing
> your credentials.
> 

Right! And using state protection here extends the trust to the client machine so it's not just allowing continued access without needing user credentials.

>> The problem I'm trying to solve initially with SP4_MACH_CRED is when there are a bunch of buffered writes and the user's credentials expire. Any client side operations initiated after the credentials expire will fail (as expected), but operations that have already been seen as successful still need to be flushed.
>> 
>> Andy is addressing this in a different way by falling back to unbuffered writes and flushing all data right before a cred expires, but this method is better when available - and it's Trond requested.
> 
> I understand the problem it solves, but it is a bit of a change to the
> security model and I just wonder what the right thing is to do by
> default.

So you think the default behavior should be that buffered writes just hang around forever in the client's buffer cache when a user cred expires?  That seems really wrong to me.

If this isn't something you want, I'm not sure that we want any SP4_MACH_CRED support other than the required operations, which is kind of a moot point since we now use krb5i for state manager operations by default (whether in SP4_MACH_CRED or SP4_NONE).

The other case we are aiming for with the client is to be able to use the machine cred in recovery when the user's creds expire so that flushing of buffers can happen once recovery is complete. Of course, if you don't want to see the flushing changes, this is useless.

So… Is SP4_MACH_CRED support even worth the effort?

-dros

> 
> --b.
> 
>> 
>>> 
>>> This violates that assumption, so I wonder if it needs to be
>>> configurable, and even off by default.
>>> 
>> 
>> This will fix potential data corruption in a corner case of the way things currently work and doesn't change expected behavior from a user's perspective. 
>> 
>> -dros
>> 
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html


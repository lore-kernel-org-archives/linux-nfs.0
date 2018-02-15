Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-vk0-f52.google.com ([209.85.213.52]:33124 "EHLO
        mail-vk0-f52.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1164322AbeBOWS5 (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Thu, 15 Feb 2018 17:18:57 -0500
Received: by mail-vk0-f52.google.com with SMTP id w201so799658vkw.0
        for <linux-nfs@vger.kernel.org>; Thu, 15 Feb 2018 14:18:57 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20180202214545.GB7229@parsley.fieldses.org>
References: <20171024174752.74910-1-kolga@netapp.com> <20171024174752.74910-8-kolga@netapp.com>
 <20180126215942.GC7770@fieldses.org> <CAN-5tyGBBfh0i9QmyHTHp-SWa6ncMCz4ZQdZcAuyWKhxtQ9xLA@mail.gmail.com>
 <20180202214545.GB7229@parsley.fieldses.org>
From: Olga Kornievskaia <aglo@umich.edu>
Date: Thu, 15 Feb 2018 17:18:55 -0500
Message-ID: <CAN-5tyHOa6SM1Gv+dv=pfQaQ--YTjfkyA6V57wgGic5qEK+jvg@mail.gmail.com>
Subject: Re: [PATCH v6 07/10] NFSD create new stateid for async copy
To: "J. Bruce Fields" <bfields@redhat.com>
Cc: "J. Bruce Fields" <bfields@fieldses.org>,
        Olga Kornievskaia <kolga@netapp.com>,
        linux-nfs <linux-nfs@vger.kernel.org>
Content-Type: text/plain; charset="UTF-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, Feb 2, 2018 at 4:45 PM, J. Bruce Fields <bfields@redhat.com> wrote:
> On Fri, Feb 02, 2018 at 03:45:28PM -0500, Olga Kornievskaia wrote:
>> On Fri, Jan 26, 2018 at 4:59 PM, J. Bruce Fields <bfields@fieldses.org> wrote:
>> > What is supposed to happen, by the way, if a close arrives for a stateid
>> > with a copy in progress?  Do we cancel the copy before returning from
>> > the close, or do we fail the close?  (Same question for unlock and
>> > delegation return, I guess.)
>>
>> Good questions. I think a normal client shouldn't send CLOSE/UNLOCK
>> while there is an on-going copy. I could see how a DELEGRETURN could
>> be coming in the middle of the copy (because the client received a
>> CB_RECALL).
>>
>> For an easy solution my proposal is to do the following. Upon
>> receiving close, unlock, delegreturn, if the copy list is non-empty,
>> then we send an ERR_DELAY back until the copy is done.
>>
>> Another proposal is to kill the copy thread but that seems too drastic
>> (specially in the case of a delegreturn). Right now when the copy
>> thread is killed, it does not send a reply back to the client (as it
>> assumes the client sent the OFFLOAD_CANCEL and doesn't need a reply).
>> I could change that to send a reply back. In case the copy used a
>> delegation stateid, then the next copy would choose a different
>> stateid. This could be done for the delegation stateid and ERR_DELAY
>> for the close/unlock.
>>
>> Is either one acceptable and if so which one sounds better to you?
>
> If we're confident this is something that only a misbehaving client
> would do, then I'm OK with choosing whatever's simplest.  I guess we
> should double-check with the spec to make sure this case hasn't already
> been covered there.  Returning an error on the conflicting operation
> sounds good to me.
>
> Is it really OK to do a COPY with a delegation stateid?  That sounds
> messy if the delegation is revoked partway through the copy.

Yes, according to the spec, it is ok to use any of the stateids.

RFC 7862 15.2.3
The ca_dst_stateid MUST refer to a stateid that is valid for a WRITE
   operation and follows the rules for stateids in Sections 8.2.5 and
   18.32.3 of [RFC5661].... while for an intra-server copy
ca_src_stateid MUST refer
   to a stateid that is valid for a READ operation and follows the rules
   for stateids in Sections 8.2.5 and 18.22.3 of [RFC5661].

8.2.5 is the section that says in the decreasing priority to choose
delegation stateid, locking stateid, open stateid.

Trying to deal with the delegation stateid seems to be rather complex.
Here's what I could do (which I mentioned before already):
1. possibly change the client to never use a delegation stateid.
2. for CLOSE/UNLOCK send back ERR_DELAY if copy list is not empty.
3. for DELEGRETURN (or when the server initiates CB_RECALL?) kill any
on-going copies. Change the nfsd copy to send a reply if it was killed
with a signal. What I'm not sure if when it's killed I get any partial
bytes from the VFS, I don't think so. I think in that case, the only
thing that I might reply with is a 0bytes copy. And whatever client
that did sent a copy with a delegation stateid would deal with
restarting it with a different stateid.

Having said all that, I'd like to ask why do you think handling
CLOSE/LOCKU/DELEGRETURN should be any different for async copy vs what
is currently there for the synchronous copy. Right now if the server
receives those operations it does nothing to the on-going synchronous
copy.

As you noted, the async copy takes a reference on the parent stateid
so the state won't go away while the async copy is going on. Why not
keep async copy same as the synchronous one?

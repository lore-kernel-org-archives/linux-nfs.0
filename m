Return-Path: linux-nfs-owner@vger.kernel.org
Received: from userp1040.oracle.com ([156.151.31.81]:35008 "EHLO
	userp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757952Ab3KHS2Y convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 8 Nov 2013 13:28:24 -0500
MIME-Version: 1.0
Message-ID: <A016BF31-6C9B-45BF-83AB-E240810D9CA8@oracle.com>
Date: Fri, 8 Nov 2013 09:58:04 -0800 (PST)
From: Chuck Lever <chuck.lever@oracle.com>
To: "J. Bruce Fields" <bfields@fieldses.org>
Cc: Jeff Layton <jlayton@redhat.com>, Steve Dickson <SteveD@redhat.com>,
        Trond Myklebust <Trond.Myklebust@netapp.com>,
        Linux NFS Mailing list <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH] Adding the nfs4_use_min_auth module parameter
References: <1383851364-8370-1-git-send-email-steved@redhat.com>
 <A8E8F2C4-8CB7-434E-8520-B2B53F0582D9@oracle.com> <527C07B4.800@RedHat.com>
 <44CA89EA-8B5E-4B83-A622-78A78F760FF1@oracle.com>
 <527CDBFC.3070903@RedHat.com>
 <20131108082202.4032f1a2@tlielax.poochiereds.net>
 <20131108150435.GA3533@fieldses.org>
 <08D3FAB2-6163-4C77-9F7E-43DBF55050D6@oracle.com>
 <20131108161409.GC3533@fieldses.org>
In-Reply-To: <20131108161409.GC3533@fieldses.org>
Content-Type: text/plain; charset=us-ascii
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


On Nov 8, 2013, at 8:14 AM, "J. Bruce Fields" <bfields@fieldses.org> wrote:

> On Fri, Nov 08, 2013 at 07:54:19AM -0800, Chuck Lever wrote:
>> 
>> On Nov 8, 2013, at 7:04 AM, J. Bruce Fields <bfields@fieldses.org>
>> wrote:
>> 
>>> On Fri, Nov 08, 2013 at 08:22:02AM -0500, Jeff Layton wrote:
>>>> On Fri, 08 Nov 2013 07:41:32 -0500 Steve Dickson
>>>> <SteveD@redhat.com> wrote:
>>>>> No. I think the concern here, at least my concern, is the lack of
>>>>> management.  We are forcing admins to use krb5i in lease
>>>>> management when its not necessary and there is no way to turn it
>>>>> off.
>>>>> 
>>>> 
>>>> I don't think that's really the case. The idea was to have the
>>>> client attempt to use krb5i if it's available, and then to fall
>>>> back to AUTH_SYS if it isn't. This would be *absolutely* no big
>>>> deal if the GSSAPI upcall succeeded or failed immediately instead
>>>> of requiring this timeout when the daemon isn't running.
>>> 
>>> I'm also still a little confused about the security model.  We
>>> discussed it before but I can't remember if it was really resolved.
>>> 
>>> It makes sense to me as long as we insist on krb5i whenever we find
>>> a keytab.
>>> 
>>> But my understanding was that with the current implementation it's
>>> possible we could find a keytab, attempt the krb5i connection, and
>>> *then* fallback silently on auth_sys if krb5i fails.  Is that right?
>>> 
>>> In that case I don't see the point of the krb5i any more: any
>>> attacker that can spoof rpc replies can force the fallback to
>>> auth_sys.
>> 
>> The point is to use a consistent security flavor for lease management
>> to avoid NFS4ERR_CLID_INUSE.  This really isn't about thwarting a MiTM
>> attack on lease management.
> 
> OK, but then you still do want to ensure you thwart that attack in the
> case krb5 is explicitly asked for.
> 
> So for example does a krb5 mount fail if a previous non-krb5 mount fell
> back on auth_sys for clientid establishment?
> 
>> The fallback mechanism can be fixed, somewhat.  I've got a patch to
>> have gssd return ENOKEY if it can't find a machine credential.  Then
>> the kernel will use AUTH_SYS.
> 
> To get that right you'd then need to fail on errors *other* than ENOKEY.
> Since old gssd doesn't return ENOKEY that would mean failing all
> auth_sys mounts on kernel upgrade, wouldn't it?
> 
>> The issue though is what to do in the other cases.  Can gssd
>> distinguish between the case where the server has no Kerberos
>> principal, and the case where gssd simply failed to establish a GSS
>> context?
> 
> I don't know.  I suppose the client should get some kind of
> no-such-principal error and use that.
> 
>> Or should we simply use the "sec=" setting in this case and
>> call it a day?
> 
> I think falling back works as long as we still are strict in the case
> the mount explicitly requests some security and don't just use
> whatever's already established in that case.

Agreed.  That is what we want to strive for.

So: use the fallback mechanism only if Kerberos was _not_ specified via the mount options, I think?

> And if we do that then I don't think the ENOKEY/no-such-principal cases
> are worth sorting out.
> 
> OK, sorry for the noise.
> 
> --b.
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

--
Chuck Lever
chuck[dot]lever[at]oracle[dot]com




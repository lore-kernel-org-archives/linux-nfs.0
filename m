Return-Path: linux-nfs-owner@vger.kernel.org
Received: from userp1040.oracle.com ([156.151.31.81]:27168 "EHLO
	userp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756405Ab3EFWeF convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 6 May 2013 18:34:05 -0400
Content-Type: text/plain; charset=us-ascii
Mime-Version: 1.0 (Mac OS X Mail 6.3 \(1503\))
Subject: Re: long delay when mounting due to SETCLIENTID AUTH_GSS attempts
From: Chuck Lever <chuck.lever@oracle.com>
In-Reply-To: <8F91C5FB-EE7F-48F8-9ED5-6B5D8503E248@oracle.com>
Date: Mon, 6 May 2013 18:33:48 -0400
Cc: Jeff Layton <jlayton@redhat.com>,
        "Myklebust, Trond" <Trond.Myklebust@netapp.com>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Message-Id: <7F5CD894-42E9-4C65-A1BC-0885C63E560B@oracle.com>
References: <20130503132557.2fdf794d@tlielax.poochiereds.net> <AE700845-4032-4BEC-817C-97EB08A831E8@oracle.com> <20130503142421.19fb3ca6@tlielax.poochiereds.net> <1367606034.3556.25.camel@leira.trondhjem.org> <20130503144437.3a47e476@tlielax.poochiereds.net> <A2E5B3F1-A8F1-4731-A66C-548B9C8FD429@oracle.com> <20130503211810.GF5715@fieldses.org> <8F91C5FB-EE7F-48F8-9ED5-6B5D8503E248@oracle.com>
To: "J. Bruce Fields" <bfields@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


On May 3, 2013, at 5:50 PM, Chuck Lever <chuck.lever@oracle.com> wrote:

> 
> On May 3, 2013, at 5:18 PM, "J. Bruce Fields" <bfields@fieldses.org> wrote:
> 
>> On Fri, May 03, 2013 at 02:48:59PM -0400, Chuck Lever wrote:
>>> We should always use krb5i if a GSS context can be established with
>>> our machine cred.  As I said before, SETCLIENTID and
>>> GETATTR(fs_locations) really should use an integrity-protecting
>>> security flavor no matter what flavor is in effect on the mount points
>>> themselves.
>> 
>> Can you give an example of a threat that could be avoided by this?
>> 
>> My suspicion is that in most cases an attacker with the ability to
>> subvert auth_sys could *also* DOS gssd, and hence force the fallback to
>> auth_sys.
>> 
>> krb5i plus a fallback to auth_sys on failure to authenticate doesn't
>> sound to me much more secure than just auth_sys.
> 
> Our current situation is that the first mount of a server determines the flavor to use for SETCLIENTID.  So if that mount happens to be "sec=sys" the SETCLIENTID is done with AUTH_SYS no matter what the subsequent mounts request.
> 
> That's just about as secure in many cases as falling back.
> 
>> If we really want much security benefit from krb5i on state operations,
>> I think we need to really *require* krb5i.
>> 
>> So I'm inclined towards Jeff's solution: don't do this unless userspace
>> somehow affirmatively states that it requires krb5i on state operations.
> 
> This would have to be on a per-server basis.  Where would an admin specify such an option?  I don't believe either a mount option (too fine) or a module parameter (too coarse) is appropriate.
> 
>> I agree that we should default to this when we can.  But the way to move
>> towards that default is then to get distributions to turn on the new
>> module parm (or whatever it is) by default.  As they do so, they can
>> also ensure that e.g. gssd is started.
> 
> gssd is not all that's required.  A keytab must be provisioned on the client and server for it to work, and that's the main issue I'm trying to address:  We need "sec=krb5" mounts to work when the client has no GSS machine credential.
> 
> And I think we already have a problem with gssd not picking up kernel requests quickly, as Trond pointed out.
> 
> I don't feel like any of this is new, or that any of this is a strong reason to revert.  But it could be a reason to move forward from here.
> 
> Does gssd distinguish between:
> 
>  - no local keytab
> 
>  - no local support for GSS
> 
>  - server doesn't grok GSS
> 
>  - some network problem occurred
> 
> Can it communicate that distinction to the kernel?  What if we fall back only in the "no keytab" and "client's kernel has no GSS support" cases?  In the "server doesn't grok" case, do not fall back if "sec=krb5*" is specified on the mount point?  "A network problem occurred" is an "always fail" case.

After some thought, here's an algorithm for selecting a flavor to use for state management operations:

  Start with krb5i.

  -  If a GSS flavor is specified on the mount point, and if
     there is no local keytab, fall back to AUTH_SYS; otherwise
     if any other issue occurs, fail immediately.  This
     modification should address your security concern.

  -  If a non-GSS flavor is specified on the mount point, or no
     flavor is specified, and there is any problem with krb5i,
     fall back to AUTH_SYS.  This is the current 3.10 behavior,
     and assumes there is a solution to Jeff's 15 second upcall
     delay issue.

We need the client to be more deterministic than "use the security flavor on the first mount operation done by this client" when selecting a flavor for state management.  If the client chooses arbitrarily among multiple flavors, it runs the risk of getting NFS4ERR_CLID_INUSE from servers, since this flavor is no longer part of the nfs_client_id4.id string.

I'm happy to consider a separate setting on the client for this purpose, but I'm having a hard time imagining what the administrative interface might look like.

The prospect of getting a distinctive error code from rpc.gssd on current systems for the "no keytab" case is not good.  I'm looking at process_krb5_upcall() in nfs-utils 1.2.8: from what I can tell, the downcall error is either -EKEYEXPIRED when the user credential has expired, or -EACCES for everything else.

However, I can write a patch to change rpc.gssd to return, say, -ENOKEY, if no keytab is available when the kernel requests a machine credential.

Is that worth pursuing in the long run?


> 
> 
>> 
>> --b.
>> 
>>>> Instead of using AUTH_GSS for SETCLIENTID by default, would it make
>>>> sense to add a switch (module parm?) that turns it on so that it can be
>>>> an opt-in thing rather than doing this by default?
>>> 
>>> Why add another tunable when we really should just fix the delay?
>>> 
>>> Besides, if gssd is running and no keytab exists, then the fallback to AUTH_SYS should be fast. Is that not an effective workaround until we address the delay problem?
>>> 
>>> -- 
>>> Chuck Lever
>>> chuck[dot]lever[at]oracle[dot]com
>>> 
>>> 
>>> 
>>> 
>>> --
>>> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
>>> the body of a message to majordomo@vger.kernel.org
>>> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>> --
>> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
>> the body of a message to majordomo@vger.kernel.org
>> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> 
> -- 
> Chuck Lever
> chuck[dot]lever[at]oracle[dot]com
> 
> 
> 
> 
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

-- 
Chuck Lever
chuck[dot]lever[at]oracle[dot]com





Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-fx0-f227.google.com ([209.85.220.227]:52076 "EHLO
	mail-fx0-f227.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755469AbZJNSUD convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 14 Oct 2009 14:20:03 -0400
Received: by fxm27 with SMTP id 27so58392fxm.17
        for <linux-nfs@vger.kernel.org>; Wed, 14 Oct 2009 11:19:25 -0700 (PDT)
In-Reply-To: <4603e94d7a85c40d7252308f394bb6ba.squirrel@webmail.rainiday.com>
References: <c8e974302190b867ad8ea49d8158f1db.squirrel@webmail.rainiday.com>
	 <20091010090039.4dfd1dfb@tlielax.poochiereds.net>
	 <ee56329e7d86a3e4b15001a39bb7e14a.squirrel@webmail.rainiday.com>
	 <20091013114441.2882c8b9@tlielax.poochiereds.net>
	 <4d569c330910130851o155050djdfed6a52e1f3177a@mail.gmail.com>
	 <1255452985.3711.85.camel@heimdal.trondhjem.org>
	 <20091013132701.72927b4d@tlielax.poochiereds.net>
	 <1255456293.3711.103.camel@heimdal.trondhjem.org>
	 <20091013140306.476b20fd@tlielax.poochiereds.net>
	 <4603e94d7a85c40d7252308f394bb6ba.squirrel@webmail.rainiday.com>
Date: Wed, 14 Oct 2009 14:19:24 -0400
Message-ID: <4d569c330910141119t4baad67eu9bdd6dd8bdc80554@mail.gmail.com>
Subject: Re: [NFS] NFS/krb and batch jobs - doable?
From: Kevin Coffman <kwc@citi.umich.edu>
To: raini@rainiday.com
Cc: Jeff Layton <jlayton@redhat.com>,
        Trond Myklebust <trond.myklebust@fys.uio.no>,
        linux-nfs@vger.kernel.org
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Wed, Oct 14, 2009 at 12:47 PM,  <raini@rainiday.com> wrote:
>> On Tue, 13 Oct 2009 13:51:33 -0400
>> Trond Myklebust <trond.myklebust@fys.uio.no> wrote:
>>
>>> On Tue, 2009-10-13 at 13:27 -0400, Jeff Layton wrote:
>>> > Correct...and gssd actually does check the validity of the cache. If
>>> > TGT has expired or it's not valid for some other reason, then it skips
>>> > it and moves on.
>>> >
>>> > The problem comes when you have more than one valid credcache. In that
>>> > case it picks the one with the latest mtime. It seems that it should
>>> > instead pick the one with the latest TGT expiration time.
>>>
>>> So why do you think that is a problem? The result should be that
>>> rpc.gssd always ends up with a valid credential as long as there is at
>>> least one with a valid TGT.
>>> IOW: Who cares if the GSS session isn't going to last as long, as long
>>> as the RPC client can always instantiate a new one.
>>>
>>
>> Hrm...good point. I suppose that as long as gssd can pick a new
>> credcache if the context expires then this patch is superfluous. Wasn't
>> that support only added fairly recently (around a year ago?)? If so, it
>> may just be that raini isn't using a recent enough nfs-utils...
>
> Hm - well I'm stuck on production machines (RHEL5) so currently on
> nfs-utils 1.0.9 which I'm going to take a wild guess may be problematic
> either way.  Could someone point me to information on this change (I see
> little in http://www.kernel.org/pub/linux/utils/nfs/)?
>
> The reason I thought the new code would be useful is that if default
> tickets are non-renewable and short lifetime, it seems sensible for gssd
> to spot and use a longer lifetime renewable ticket in another ccache file
> - and say use krenew to keep the job alive (or even cope with the user
> renewing the ticket manually).
>
> Seems to me therefore that in the absence of per-session ccaches, gssd
> should prefer long lifetime, and renewable.
>
> Would the newer code you mention cope with this situation already?

The change that adds the check for "valid" credentials caches
(including expiration) was not added until nfs-utils-1.1.3.

With that version of rpc.gssd, Jeff and Trond's descriptions are correct.

K.C.

Return-Path: linux-nfs-owner@vger.kernel.org
Received: from acsinet15.oracle.com ([141.146.126.227]:27648 "EHLO
	acsinet15.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752921Ab2GBUft convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 2 Jul 2012 16:35:49 -0400
Subject: Re: Linux NFSv4 client uses returned delegation in subsequent READ resulting in hang (BAD_STATEID)
Mime-Version: 1.0 (Apple Message framework v1278)
Content-Type: text/plain; charset=US-ASCII
From: Chuck Lever <chuck.lever@oracle.com>
In-Reply-To: <CAPD_G3Lc6F9yUOXLUcPgn1c5n=Hcs2JSXdGPhZ-CjtBLVoibbg@mail.gmail.com>
Date: Mon, 2 Jul 2012 16:35:44 -0400
Cc: linux-nfs@vger.kernel.org
Message-Id: <2F725B49-A089-41E9-BBC9-11B889A62C9D@oracle.com>
References: <CAPD_G3L0wwzCWyoPJp_sKpuQ0J7+avn-ejEn-WnXf81zr=-LqA@mail.gmail.com> <2E097766-1FA2-42E1-B790-B3BBC254B705@oracle.com> <CAPD_G3Lc6F9yUOXLUcPgn1c5n=Hcs2JSXdGPhZ-CjtBLVoibbg@mail.gmail.com>
To: "Charles 'Boyo" <charlesboyo@gmail.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


On Jul 2, 2012, at 4:22 PM, Charles 'Boyo wrote:

> On Mon, Jul 2, 2012 at 3:09 PM, Chuck Lever <chuck.lever@oracle.com> wrote:
>> 
>> Usually we see this behavior because of a race between an OPEN with delegation and a delegation recall.  In this case, however, the client is actively returning a READ
>> delegation, then proceeding to use it anyway.  I don't see the server's recall callback, though, and there are other indications that this trace is not complete. So it's hard
>> to be 100% confident.
>> 
> The trace is not complete, it includes just enough information to
> explain the problem.
> However I can confirm the service did not send a recall callback, the
> client returned the delegation of its own "free will".

The callback would come on a separate TCP connection.  I can't think of a reason that a client would return a delegation by itself and then subsequently start to use it.

>> 
>> As far as I know, the EL6.2 client does not have support for recovering a single bad STATEID, which is why it is looping.  That support is available in mainline kernels 3.0
>> and later.
>> 
>> However, it seems to me that it is a bug for the client to continue using a delegation that it has returned.
>> 
> Is it possible is a scheduling issue of some sort, where the READ
> should have been sent ahead of the DELEGRETURN but somehow got mixed
> up?

Or possibly that the DELEGRETURN doesn't actually remove the delegation state ID until the server has replied, and the READ request was sent before the DELEGRETURN reply arrived at the client.

>> 
>> You have already found one work-around: disable delegations on the NFS server.  Or you could mount with NFSv3.  Or, if feasible, your application could be modified to
>> use fcntl() locking.
>> 
> In my case, disabling delegation is the only feasible work-around.
> NFSv3 creates new issues with identity mapping and the application is
> closed-source.
> With delegation disabled, what else do I stand to lose apart from some
> client-side efficiencies? I have noticed that the client has resorted
> to closing and re-opening commonly used files every few seconds -
> probably an attempt to flush all data out to the server as soon as
> possible.

Delegation allows the client to leave a file open and cache data more aggressively.  The extra CLOSE operations are likely due to close-to-open requirements (NFS optimizes for serial file sharing).

> This hasn't caused me any grief, but I don't know what I'm
> missing.

If you haven't noticed any troubling behavior, then there is probably not going to be a major impact for your workload.

> 
> Regards,
> 
> Charles
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

-- 
Chuck Lever
chuck[dot]lever[at]oracle[dot]com





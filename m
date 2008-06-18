From: Chuck Lever <chuck.lever@oracle.com>
Subject: Re: [PATCH 1/2] NFS: Clean up nfs_update_request()
Date: Wed, 18 Jun 2008 18:05:50 -0400
Message-ID: <485986BE.1030401@oracle.com>
References: <20080616192348.20513.72423.stgit@localhost.localdomain>	 <20080616192348.20513.3284.stgit@localhost.localdomain>	 <B9BACB96-E0DB-4C6D-B55D-A50CC6F94474@oracle.com>	 <1213739807.7288.86.camel@localhost>  <485972AE.9030405@oracle.com> <1213822899.25182.21.camel@localhost>
Reply-To: chuck.lever@oracle.com
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------030902000108030107080601"
Cc: linux-nfs@vger.kernel.org
To: Trond Myklebust <Trond.Myklebust@netapp.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from rgminet01.oracle.com ([148.87.113.118]:22224 "EHLO
	rgminet01.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754201AbYFRWHx (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 18 Jun 2008 18:07:53 -0400
In-Reply-To: <1213822899.25182.21.camel@localhost>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

This is a multi-part message in MIME format.
--------------030902000108030107080601
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit

Trond Myklebust wrote:
> On Wed, 2008-06-18 at 16:40 -0400, Chuck Lever wrote:
>>> No. If the page is being written out, then we _must_ release all locks,
>>> wait on the request, and try again. This is not a change compared to the
>>> previous incarnation.
>> Right, understood... but I think the logic added here is harder to 
>> understand and thus more prone to break when something changes than the 
>> previous incarnation was.
>
> I don't understand: The behaviour and the results are exactly the same
> as before.  All that has happened is that the existing code to update a
> request got shuffled into a separate function. If the request is locked,
> so that we can't update it, we still wait for the request to become
> unlocked, then release it and try the lookup again. There is no new
> logic...

Sorry, I'm not being clear.  I do realize that this patch is intended as 
a clean up and not a behavioral change.

What I'm trying to say is the new function with the EAGAIN return code 
is spaghetti.  Don't get me wrong, I like Italian food.

I do agree that nfs_update_request() in its current state deserves some 
clarification and clean up.  I'm not sure I like the new code any more 
than the old, however.

> One alternative might be to move the code that waits on the lock into
> nfs_try_to_update_request(), but I don't like that idea for two reasons:
> 
>      1. waiting on the lock isn't related to updating the request
>      2. Once the request has been unlocked, you _still_ have to return
>         to nfs_setup_write_request() because the old request might have
>         completed, and been removed from the inode altogether. IOW: you
>         still don't get rid of the need to signal the EAGAIN.

--------------030902000108030107080601
Content-Type: text/x-vcard; charset=utf-8;
 name="chuck_lever.vcf"
Content-Transfer-Encoding: 7bit
Content-Disposition: attachment;
 filename="chuck_lever.vcf"

begin:vcard
fn:Chuck Lever
n:Lever;Chuck
org:Oracle Corporation;Corporate Architecture: Linux Projects Group
adr:;;1015 Granger Avenue;Ann Arbor;MI;48104;USA
title:Principal Member of Staff
tel;work:+1 248 614 5091
x-mozilla-html:FALSE
version:2.1
end:vcard


--------------030902000108030107080601--

Return-Path: <SRS0=zqKC=T6=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 38248C28CC0
	for <linux-nfs@archiver.kernel.org>; Thu, 30 May 2019 10:35:09 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 0D8E225758
	for <linux-nfs@archiver.kernel.org>; Thu, 30 May 2019 10:35:09 +0000 (UTC)
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1726428AbfE3KfI (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Thu, 30 May 2019 06:35:08 -0400
Received: from mx1.redhat.com ([209.132.183.28]:54624 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1725870AbfE3KfI (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Thu, 30 May 2019 06:35:08 -0400
Received: from smtp.corp.redhat.com (int-mx07.intmail.prod.int.phx2.redhat.com [10.5.11.22])
        (using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
        (No client certificate requested)
        by mx1.redhat.com (Postfix) with ESMTPS id 2A4E73179B51;
        Thu, 30 May 2019 10:35:08 +0000 (UTC)
Received: from [10.10.66.66] (ovpn-66-66.rdu2.redhat.com [10.10.66.66])
        by smtp.corp.redhat.com (Postfix) with ESMTPS id CC25E10018F9;
        Thu, 30 May 2019 10:35:07 +0000 (UTC)
From:   "Benjamin Coddington" <bcodding@redhat.com>
To:     "Trond Myklebust" <trondmy@hammerspace.com>
Cc:     linux-nfs@vger.kernel.org
Subject: Re: client lookup_revalidate bug
Date:   Thu, 30 May 2019 06:35:06 -0400
Message-ID: <30D343CF-50AD-4470-84D5-C825EB00B5C9@redhat.com>
In-Reply-To: <b8e9ef022cb5ec1fef01e34890c3119463b0bd4b.camel@hammerspace.com>
References: <D4DAB8F2-CAA7-4BC3-B0A0-4EAF5E9DE261@redhat.com>
 <458733948202ed0fddf37cbb79730b5ebdabd551.camel@hammerspace.com>
 <66FFF553-5DEE-4B49-A207-7B0D63FBAECB@redhat.com>
 <b8e9ef022cb5ec1fef01e34890c3119463b0bd4b.camel@hammerspace.com>
MIME-Version: 1.0
Content-Type: text/plain
X-Scanned-By: MIMEDefang 2.84 on 10.5.11.22
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.41]); Thu, 30 May 2019 10:35:08 +0000 (UTC)
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

On 29 May 2019, at 13:19, Trond Myklebust wrote:
> On Wed, 2019-05-29 at 12:39 -0400, Benjamin Coddington wrote:
>> On 29 May 2019, at 12:21, Trond Myklebust wrote:
>
> Sorry, but that's not the case, because of the abuse of the
> nosharecache flag. You are manipulating the file on the server and
> expecting an immediate cache invalidation. That would require
> information that the client does not have.

Yes, forget about the nosharecache flag.  Let's just assume we move the file
on the server.  The client does perform a GETATTR and sees the updated
change_attr for the directory, but it matches the dentry's new d_time.

I don't expect immediate cache invalidation; invalidation will never happen
as long as B/'s change_attr isn't bumped again.  On the client, B/foo
dentry's d_time is the same as the change_attr for B/, and even though
there's no file at B/foo on the server, the client will keep the B/foo
dentry until something else bumps B/'s change_attr.

Maybe I need to imagine a scenario where this matters more..

But, I think that if we use the method of comparing d_time with the parent's
change_attr to determine if we need to lookup, this is a case where that's
not reliable.

I'll try to come up with something as I have time to work on it since I am
getting pressure about it.  It looks to me like this behavior has been
around for a long time.  Thanks for the look.

Ben


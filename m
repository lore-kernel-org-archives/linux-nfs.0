Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from rcsinet10.oracle.com ([148.87.113.121]:23327 "EHLO
	rcsinet10.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751082Ab1BOAKs convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 14 Feb 2011 19:10:48 -0500
Subject: Re: [PATCH 1/2] mount: move generic functions to utils.c and network.c
Content-Type: text/plain; charset=us-ascii
From: Chuck Lever <chuck.lever@oracle.com>
In-Reply-To: <20110208160823.GA21408@nb.net.home>
Date: Mon, 14 Feb 2011 19:08:37 -0500
Cc: linux-nfs@vger.kernel.org
Message-Id: <AC21B3C6-5A87-4142-AE88-35C6F835ABC0@oracle.com>
References: <1297172717-26431-1-git-send-email-kzak@redhat.com> <1297172717-26431-2-git-send-email-kzak@redhat.com> <D42D29E5-82B4-4786-BB0C-D2672A58F522@oracle.com> <20110208160823.GA21408@nb.net.home>
To: Karel Zak <kzak@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0


On Feb 8, 2011, at 11:08 AM, Karel Zak wrote:

> On Tue, Feb 08, 2011 at 10:43:23AM -0500, Chuck Lever wrote:
>> Nice work, just a few nits so far.
> 
> I'll send updated version later. Thanks for your feedback.
> 
>> I'll wait for utils-linux
>> 2.19... and we have NFS Connectathon (http://www.connectathon.org)
>> in a couple of weeks, so it will be March before I can spend some
>> quality time with this.
>> 
>> Also, I'm cleaning up a version of parse_opt.c and token.c for you,
>> if you want to include these in libmount at some point.
> 
> The library already has some code for mount options parsing, but there
> is not code to create a list from parsed mount options. The library 
> already uses struct list_head (originally probably from e2fsprogs
> and Linux kernel, see include/list.h in util-linux), so maybe we can
> use it for mount options too.

"struct mount_options" is meant to be opaque to callers.  Originally I expected there would be more than just a list in it.  As it turned out, a doubly-linked list is all that is needed.

I can experiment with replacing "struct mount_options" with "struct list_head."  I rather prefer the opacity, as that discourages callers from tinkering with the option lists themselves.  It's a nit, I suppose.

-- 
Chuck Lever
chuck[dot]lever[at]oracle[dot]com





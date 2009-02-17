From: Arto Jantunen <viiru@debian.org>
Subject: Re: Timeout issue (similar to bugs 11061 and 11154), bisected
Date: Tue, 17 Feb 2009 12:38:55 +0200
Message-ID: <87prhh5ow0.fsf@viiru.iki.fi>
References: <87ab8m7i22.fsf@viiru.iki.fi>
	<1234789459.7708.47.camel@heimdal.trondhjem.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail2.dt-link.fi ([217.152.200.15]:40459 "EHLO mail2.dt-link.fi"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750886AbZBQKjF (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 17 Feb 2009 05:39:05 -0500
Received: from localhost (localhost [127.0.0.1])
	by mail2.dt-link.fi (Postfix) with ESMTP id 21F242C1E6831
	for <linux-nfs@vger.kernel.org>; Tue, 17 Feb 2009 12:39:02 +0200 (EET)
Received: from mail2.dt-link.fi ([127.0.0.1])
	by localhost (mail2.dt-link.fi [127.0.0.1]) (amavisd-new, port 10024)
	with ESMTP id xyCq8DxLCyut for <linux-nfs@vger.kernel.org>;
	Tue, 17 Feb 2009 12:39:01 +0200 (EET)
Received: from ryoko (ryoko.zyrain.org [217.152.200.219])
	by mail2.dt-link.fi (Postfix) with ESMTP id DF3972C1E6833
	for <linux-nfs@vger.kernel.org>; Tue, 17 Feb 2009 12:38:55 +0200 (EET)
In-Reply-To: <1234789459.7708.47.camel-rJ7iovZKK19ZJLDQqaL3InhyD016LWXt@public.gmane.org> (sfid-20090216_151423_482241_46FCAF38) (Trond Myklebust's message of "Mon\, 16 Feb 2009 08\:04\:19 -0500")
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Trond Myklebust <trond.myklebust@fys.uio.no> writes:

> On Mon, 2009-02-16 at 13:11 +0200, Arto Jantunen wrote:
>> (I'm not subscribed, so please CC me on any replies)
>> 
>> I seem to have hit a NFS bug while upgrading a machine from Debian
>> Etch to Debian Lenny. I have a NFS server running FreeBSD 7.0 RC1 and
>> a bunch of clients running Linux. The ones running kernel 2.6.18 work
>> perfectly, as do the ones running 2.6.24. The one I upgraded to 2.6.26
>> fails. After 5-15 minutes of working normally the mount dies and I get
>> the usual "nfs: server <server> not responding, still trying" in
>> dmesg. The only way I have found to get the mount back is umount -f &&
>> mount, waiting does not bring it back.
>> 
>> I have tested quite a bunch of different kernel versions, and starting
>> from 25 and ending at the git tree last week they all fail in the same
>> way. Bisecting tracks the problem to commit
>> e06799f958bf7f9f8fae15f0c6f519953fb0257c
>> 
>> I originally thought that it was the same as bug 11154, but the
>> patches attached to that bug do not fix this issue.
>> 
>> Any thoughts, patches, ideas?
>
> That looks like the known problem with the NFS server failing to close
> connections in a timely manner. There is a fix for this in
>
> http://git.kernel.org/?p=linux/kernel/git/torvalds/linux-2.6.git&a=commitdiff&h=69b6ba3712b796a66595cfaf0a5ab4dfe1cf964a
>
> There is also a client side patch that increases the robustness of the
> client when it hits a buggy server, and that causes it to do the
> equivalent of a linger2 timeout. That patch is as of yet not merged into
> mainline, however I've attached it below together with a followup patch
> that makes the timeout configurable...

The client side patch you attached hides the problem on the server,
after applying it the mount sticks around. As previously discussed,
the server is running an apparently buggy version of FreeBSD and I'd
rather not touch it right now since it is in production.

Thanks for your fast response.

-- 
Arto Jantunen

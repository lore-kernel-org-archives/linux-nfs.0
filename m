Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mailgate1.disneyanimation.com ([198.187.190.101]:58569 "EHLO
	mailgate1.disneyanimation.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751369Ab1CQTLF (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 17 Mar 2011 15:11:05 -0400
From: Kevin Constantine <Kevin.Constantine@disneyanimation.com>
Message-ID: <4D825CC8.6040808@disney.com>
Date: Thu, 17 Mar 2011 12:11:04 -0700
To: Jim Rees <rees@umich.edu>
CC: Steve Dickson <SteveD@redhat.com>, linux-nfs@vger.kernel.org
Subject: Re: NFS hanging waiting for a process to be killable?
References: <4D80F8B9.1080900@disney.com> <4D823B81.5040702@RedHat.com> <20110317175256.GA2730@merit.edu>
In-Reply-To: <20110317175256.GA2730@merit.edu>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On 03/17/2011 10:52 AM, Jim Rees wrote:
> Steve Dickson wrote:
>
>    I wonder if this is the same problem Jim was seeing a while back
>    as well as some other people.... Something similar to:
>        https://bugzilla.redhat.com/show_bug.cgi?id=669204
>
> I wondered that too.  The traces are hard to read (someone word-wrapped
> them) but they looked different to me.  Could be the same underlying
> problem.

Yeah, the more i'm looking at the backtraces, the more different they look.

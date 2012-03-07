Return-Path: linux-nfs-owner@vger.kernel.org
Received: from out1-smtp.messagingengine.com ([66.111.4.25]:36812 "EHLO
	out1-smtp.messagingengine.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752048Ab2CGJBl (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 7 Mar 2012 04:01:41 -0500
Received: from compute6.internal (compute6.nyi.mail.srv.osa [10.202.2.46])
	by gateway1.nyi.mail.srv.osa (Postfix) with ESMTP id D51D8208D4
	for <linux-nfs@vger.kernel.org>; Wed,  7 Mar 2012 04:01:39 -0500 (EST)
Message-ID: <4F5723EE.3090208@itwm.fraunhofer.de>
Date: Wed, 07 Mar 2012 10:01:34 +0100
From: Bernd Schubert <bernd.schubert@itwm.fraunhofer.de>
MIME-Version: 1.0
To: "Ted Ts'o" <tytso@mit.edu>
CC: linux-nfs@vger.kernel.org, linux-ext4@vger.kernel.org,
        linux-fsdevel@vger.kernel.org, Fan Yong <yong.fan@whamcloud.com>,
        bfields@redhat.com, sandeen@redhat.com,
        Andreas Dilger <adilger@whamcloud.com>
Subject: Re: [PATCH 5 2/4] Return 32/64-bit dir name hash according to usage
 type
References: <20120109132137.2616029.76288.stgit@localhost.localdomain> <20120109132148.2616029.68798.stgit@localhost.localdomain> <20120305155939.GE21356@thunk.org> <4F555CE5.7050401@itwm.fraunhofer.de> <20120306022838.GA24323@thunk.org> <4F55E01B.3060105@itwm.fraunhofer.de> <20120306151543.GA32282@thunk.org>
In-Reply-To: <20120306151543.GA32282@thunk.org>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 03/06/2012 04:15 PM, Ted Ts'o wrote:
> On Tue, Mar 06, 2012 at 10:59:55AM +0100, Bernd Schubert wrote:
>> Arg, my bad, I introduced this issue when I converted from f_flags
>> to f_mode, seems I forgot all of those above :(
>> Hrm, I thought I had tested sufficiently, but obviously I did not :(
>> Here's the test tool.
>> http://www.pci.uni-heidelberg.de/tc/usr/bernd/downloads/test_seekdir/
>>
>> While quickly looking, I think it only affects NFSv2, which I think
>> I indeed didn't test. I only run tests for 32 bit and 64-bit user
>> space and NFSv3. But yes, NFSv2 is an important test too. Not sure
>> if I will find time for that today.
>
> I think the problem case to worry about would have been on a 32-bit
> NFS server (think embedded/bookshelf NAS servers) and NFSv3, since
> that's where the inconsistency would have meant that hash2pos would
> use the 32-bit codepath, but pos2maj_hash would use the 64-bit
> codepath, and so then...  kablooey.
>
>> Will send an updated version later on.
>
> If it's just those changes, no worries, as I've already fixed up the
> f_flags vs. f_mode issue in my copy of the patches.
>
> Let me know if there are any other changes that you'd like to make or
> issues that you've spotted.

Ted, thanks a bunch! I really will try to be more careful updating 
patches next time. And during the next days I'm also going to review the 
patches again, at least I hope I find the time for that while being on 
vacation).


Thanks again,
Bernd

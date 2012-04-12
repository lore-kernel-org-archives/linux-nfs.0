Return-Path: linux-nfs-owner@vger.kernel.org
Received: from out1-smtp.messagingengine.com ([66.111.4.25]:45240 "EHLO
	out1-smtp.messagingengine.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753150Ab2DLVWp (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 12 Apr 2012 17:22:45 -0400
Received: from compute1.internal (compute1.nyi.mail.srv.osa [10.202.2.41])
	by gateway1.nyi.mail.srv.osa (Postfix) with ESMTP id 01F0E20D83
	for <linux-nfs@vger.kernel.org>; Thu, 12 Apr 2012 17:22:45 -0400 (EDT)
Message-ID: <4F8747A1.8060800@fastmail.fm>
Date: Thu, 12 Apr 2012 23:22:41 +0200
From: Bernd Schubert <bernd.schubert@fastmail.fm>
MIME-Version: 1.0
To: "J. Bruce Fields" <bfields@fieldses.org>
CC: Bernd Schubert <bernd.schubert@itwm.fraunhofer.de>,
        "J. Bruce Fields" <bfields@redhat.com>, "Ted Ts'o" <tytso@mit.edu>,
        Jan Kara <jack@suse.cz>, linux-nfs@vger.kernel.org,
        linux-ext4@vger.kernel.org, linux-fsdevel@vger.kernel.org,
        yong.fan@whamcloud.com, sandeen@redhat.com, adilger@whamcloud.com
Subject: Re: [PATCH 5 3/4] nfsd_open(): rename 'int access' to 'int may_flags'
 in nfsd_open()
References: <20120309205148.GB5635@thunk.org> <20120312150912.GB12440@thunk.org> <20120312154921.GB17153@pad.fieldses.org> <20120312222250.GD8991@fieldses.org> <20120313200117.GA21991@fieldses.org> <4F5FA827.8020606@itwm.fraunhofer.de> <20120313203446.GB21991@fieldses.org> <4F5FB771.9010805@fastmail.fm> <20120313212947.GK31995@pad.fieldses.org> <4F60AC0D.9020204@itwm.fraunhofer.de> <20120412204948.GE6667@fieldses.org>
In-Reply-To: <20120412204948.GE6667@fieldses.org>
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 04/12/2012 10:49 PM, J. Bruce Fields wrote:
> On Wed, Mar 14, 2012 at 03:32:45PM +0100, Bernd Schubert wrote:
>> On 03/13/2012 10:29 PM, J. Bruce Fields wrote:
>>> On Tue, Mar 13, 2012 at 10:09:05PM +0100, Bernd Schubert wrote:
>>>> Hmm, there must have gone something wrong on merging,
>>>
>>> In that case one approach would be to rebase your last-sent patches on
>>> to the same base as Ted's versions, confirm that one still works and the
>>> other doesn't, and do a diff....
>>>
>>>> my own test
>>>> also fails
>>>>
>>>> http://www.pci.uni-heidelberg.de/tc/usr/bernd/downloads/test_seekdir/
>>>>
>>>> (Sorry, it does not say 'failure', but one needs to compare the file
>>>> names and telldir-offset numbers)
>>>>
>>>> I think I will continue in the morning as its already 1 a.m. here.
>>>
>>> OK, thanks for following up!
> 
> Stupid question: is there any fundamental feature of ext4 this depends
> on, or would this fix work equally well for fs/ext3?

First of all, Bruce and Ted, thanks a lot for your patience with those
patches!

I have not looked into it in detail yet, but it should be possible to
back port it to ext3. I don't think there is anything that would depend
on ext4. I also have ext3 on my todo list, but I first wanted to have it
in ext4 (in the sense of stability of ext3, if there still should be a
bug...) and I think for 3.4 it is too late now anyways. So unless there
are objections, lets target the back port to ext3 for 3.5?


Cheers,
Bernd

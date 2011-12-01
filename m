Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-gy0-f174.google.com ([209.85.160.174]:44086 "EHLO
	mail-gy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755791Ab1LARgE convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 1 Dec 2011 12:36:04 -0500
Received: by ghrr1 with SMTP id r1so2036861ghr.19
        for <linux-nfs@vger.kernel.org>; Thu, 01 Dec 2011 09:36:04 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <CAA-yEOLkeCAqfWSeJ1jhA5rVB3B7ha5RVwZX7XM1K5PMs9smUA@mail.gmail.com>
References: <CAA-yEOJ+5NssoCOAXzeCNOCkbbACn0qHrj-BtmMRYwxZFDZgxg@mail.gmail.com>
	<20111201172415.GA27626@janus>
	<CAA-yEOLkeCAqfWSeJ1jhA5rVB3B7ha5RVwZX7XM1K5PMs9smUA@mail.gmail.com>
Date: Thu, 1 Dec 2011 19:36:03 +0200
Message-ID: <CAA-yEOLNVMPWthZkFMwA2-s7b7uXhTV0+nd9Ly-0S0h8OxCOKA@mail.gmail.com>
Subject: Re: NFS - lock failover
From: Pavel A <free.lan.c2.718r@gmail.com>
To: Frank van Maarseveen <frankvm@frankvm.com>
Cc: linux-nfs@vger.kernel.org, wcheng@redhat.com, neilb@suse.de,
        jlayton@redhat.com
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

2011/12/1 Pavel A <free.lan.c2.718r@gmail.com>:
> Thank you very much! This is something I was looking for.
> I only wonder, why isn't it included in packages? - I will be of great
> help to many other people as well.
sorry, _it_ will be of great help to many other people as well.

>
> 2011/12/1 Frank van Maarseveen <frankvm@frankvm.com>:
>> On Thu, Dec 01, 2011 at 07:07:22PM +0200, Pavel A wrote:
>>> Hi everyone!
>>>
>>> I was trying not to create new topics, but it seems that posting to an
>>> old one doesn't bring it up. Here is the original topic I'm referring
>>> to: http://comments.gmane.org/gmane.linux.nfs/13108
>>>
>>> I'm building an A/A cluster using NFS v3 and local file systems, and
>>> looking for
>>> efficient ways for failover (for now I have to restart nfs-kernel-server on
>>> Takeover node to be able to initiate grace period), so the discussed solutions
>>> are very interesting to me.
>>>
>>> Now (4 years after) in current nfs-utils packages (v. 1.2.2-4 and later) I can
>>> see that the ability to release locks was really implemented and is
>>> working well
>>> (I mean interfaces /proc/fs/nfsd/unlock_ip and
>>> /proc/fs/nfsd/unlock_filesystem),
>>> but how about reacquiring locks on the node, share migrates to? - I've been
>>> going through various mailing lists and found a lot of discussions on the topic
>>> (also dated mainly 2007), but don't seem to find any rpc-based mechanism or
>>> interface like /proc/fs/nfsd/nlm_set_grace to do that, was it ever made?
>>
>> I've posted a patch some time ago implementing
>> /proc/fs/nfsd/relock_filesystem:
>>
>>        http://permalink.gmane.org/gmane.linux.nfs/42360
>>        http://permalink.gmane.org/gmane.linux.nfs/42361
>>        http://permalink.gmane.org/gmane.linux.nfs/42362
>>
>> --
>> Frank

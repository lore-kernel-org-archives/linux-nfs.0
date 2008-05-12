From: Jesper Krogh <jesper@krogh.cc>
Subject: Re: Many open/close on same files yeilds "No such file or directory".
Date: Mon, 12 May 2008 08:41:02 +0200
Message-ID: <4827E67E.3050008@krogh.cc>
References: <4819E316.7000607@krogh.cc>	<4823DFA6.9010504@krogh.cc>	<20080508223635.523b8fa7.akpm@linux-foundation.org>	<4823EA9E.6050703@krogh.cc> <18471.41781.164396.385159@notabene.brown>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Cc: Andrew Morton <akpm@linux-foundation.org>,
	linux-kernel@vger.kernel.org, linux-nfs@vger.kernel.org
To: Neil Brown <neilb@suse.de>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1758726AbYELGlY@vger.kernel.org>
In-Reply-To: <18471.41781.164396.385159@notabene.brown>
Sender: linux-kernel-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Neil Brown wrote:
> On Friday May 9, jesper@krogh.cc wrote:
>> When I disabled the NFS-server and rand my "real-world" program on a
>> single processor (make -j 1). It ran through fine. It basically
>> gets around 20 million chunks out of differnet file and assemble the
>> chuncks in a few other files. This processes more or less 5 individual
>> sections, so make can run effectively with a concurrency of 5.
> 
> (For linux-nfs readers: the problem is that repeatedly opening a given
>  file sometimes returns a ENOENT - http://lkml.org/lkml/2008/5/9/15).

This thing really, really irritated me, but I must admit that Andrew 
Morton was very correct about this "not being very likely"- a kernel
bug.

It seem that our central configuration handling system (slack) was being
way to aggressive about updating symlinks in paths of the filesystems
that I was testing upon, that explains why I couldn't reproduce it
on the internal volumes, and not on any of the volumes I created only
for testing purposes. Sometimes you just get too blind..
(I haven't been able to reproduce for 12 hours now)

Just to answer your questions, yes, the 48 clients do hammer on NFS and
now it seems to work excellent.

Sorry for all the noise.

-- 
Jesper

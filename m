Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:61206 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756458Ab3HFRhB (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 6 Aug 2013 13:37:01 -0400
Message-ID: <5201343A.1050105@RedHat.com>
Date: Tue, 06 Aug 2013 13:36:58 -0400
From: Steve Dickson <SteveD@redhat.com>
MIME-Version: 1.0
To: Abhijeet Rastogi <abhijeet.1989@gmail.com>
CC: linux-nfs@vger.kernel.org
Subject: Re: Bug: nfsiostat fails to parse file /proc/self/mountstats in some
 cases
References: <CACXxYfy6ySZOLTRGWfZjnozHP5irHa9N=DS=3AUH8RWgUtY35Q@mail.gmail.com>
In-Reply-To: <CACXxYfy6ySZOLTRGWfZjnozHP5irHa9N=DS=3AUH8RWgUtY35Q@mail.gmail.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>



On 31/07/13 08:11, Abhijeet Rastogi wrote:
> Hi all,
> 
> So, this is what I'm observing.
> 
> $ sudo nfsiostat
> Traceback (most recent call last):
>   File " in="" line="" module="" nfsiostat="" sbin="" usr="">
> iostat_command(prog)
>   File "/usr/sbin/nfsiostat", line 587, in iostat_command
>     devices = list_nfs_mounts(origdevices, mountstats)
>   File "/usr/sbin/nfsiostat", line 490, in list_nfs_mounts
>     stats.parse_stats(descr)
>   File "/usr/sbin/nfsiostat", line 179, in parse_stats
>     self.__parse_rpc_line(words)
>   File "/usr/sbin/nfsiostat", line 163, in __parse_rpc_line
>     self.__rpc_data[op] = [long(word) for word in words[1:]]
> ValueError: invalid literal for long() with base 10: 'device'
> 
> This happens because it's unexpected for nfsiostat to find line "no
> device mounted on /sys/kernel/debug with fstype debugfs" in
> /proc/self/mountstats. http://pb.abhijeetr.com/UREA
What version of nfs-utils are you using?

> 
> For now, I added
> 
>         if line.startswith("no device mounted"):
>             continue
> 
> to fix the issue in parse_stats_file function. http://pb.abhijeetr.com/HUXO
> 
> Please ask if any more info is required. What's the best way to handle
> it so that it can be added to upstream code?
Please post a formal patch. Here are some guidelines to follow
    https://www.kernel.org/doc/Documentation/SubmittingPatches

But in a nutshell, here is what I do. 

git clone git://linux-nfs.org/~steved/nfs-utils.git
cd nfs-utils.git
<make the change to tools/nfs-iostat/nfs-iostat.py>
<test the change to tools/nfs-iostat/nfs-iostat.py>
git commit -s -a 
<describe what that patch does; See section 2 of SubmittingPatches>
git format-patch -1
<there will be a 0001- patch file in the current directory>
git send-email --suppress-cc=all --suppress-from --no-chain-reply-to \
       --from "Abhijeet Rastogi <abhijeet.1989@gmail.com>"
       --to "Steve Dickson <steved@redhat.com>"
       --cc "Linux NFS Mailing List <linux-nfs@vger.kernel.org>" 

Note: I --dry-run flag to test the git send-email command before
  I actually send the mail. 

I hope this helps...

steved.

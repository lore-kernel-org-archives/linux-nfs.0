Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from krichy.tvnetwork.hu ([109.61.101.194]:57942 "EHLO
	krichy.tvnetwork.hu" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753268AbbJZHi5 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 26 Oct 2015 03:38:57 -0400
Date: Mon, 26 Oct 2015 08:38:53 +0100 (CET)
From: krichy@tvnetwork.hu
To: "J. Bruce Fields" <bfields@fieldses.org>
cc: linux-nfs@vger.kernel.org
Subject: Re: nfs lockup
In-Reply-To: <20151023181001.GA15564@fieldses.org>
Message-ID: <alpine.DEB.2.20.1510260834280.24908@krichy.tvnetwork.hu>
References: <alpine.DEB.2.20.1510211715430.5353@krichy.tvnetwork.hu> <20151023181001.GA15564@fieldses.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII; format=flowed
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


I dont have exact measurements, but my observations were that the file 
grew at around a few 100kbyte/s, while after a reboot this file can be 
copied at a few megs/s rate.

I did a kernel upgrade to 4.2 now, and I am trying to collect more 
information upon the hang. Unfortunately I dont know the exact case which 
triggers this hang, thus I cannot reproduce. Measurements before the 
hangs dont show any unusual to me.

Thanks in advance,
Kojedzinszky Richard
Euronet Magyarorszag Informatika Zrt.

On Fri, 23 Oct 2015, J. Bruce Fields wrote:

> Date: Fri, 23 Oct 2015 14:10:01 -0400
> From: J. Bruce Fields <bfields@fieldses.org>
> To: krichy@tvnetwork.hu
> Cc: linux-nfs@vger.kernel.org
> Subject: Re: nfs lockup
> 
> On Wed, Oct 21, 2015 at 05:25:53PM +0200, krichy@tvnetwork.hu wrote:
>> Dear devs,
>>
>> We have an nfs lockup issue. We run a ganeti cluster consisting of 7
>> debian linux nodes and 1 freenas for hosting the vm images. The
>> images are exported via nfsv3. The problem is that randomly we end
>> in a livelock on one of our nodes.
>>
>> That means the nfs share is alive, we can list directories, files,
>> even can read files (very slow, see later). And even can write to
>> files, but the file close operation does not return, it gets
>> blocked.
>>
>> The read is slow in that way that while copying a file from the
>> share to /tmp, the data arrives very fast to the node, but in /tmp
>> it accumulates slowly.
>
> I don't understand what you mean by that.  Do you have some measurements
> to help quantify "very fast" and "slowly"?
>
> --b.
>
>>
>> I've also opened a debian bug report on it, but I think it is not
>> related to debian
>> (https://bugs.debian.org/cgi-bin/bugreport.cgi?bug=801924).
>>
>> The only way is to reboot machine, with all the vm's running on it
>> getting interrupted.
>>
>> I've captured each tasks' stack trace, hopefully it helps someone to
>> find out the issue.
>>
>> Meanwhile the other 6 nodes can access the nfs share right, so I
>> think this is not a networking or server issue. Restarting the nfs
>> server on the server side still does not have any effect, not
>> recovering. The nfs tcp connection is established, listing files
>> works again, but writes not.
>>
>> Some information of the nodes:
>> # uname -a
>> Linux host 3.16.0-4-amd64 #1 SMP Debian 3.16.7-ckt11-1+deb8u4
>> (2015-09-19) x86_64 GNU/Linux
>>
>> They have 1.5G ram allocated to dom0, that should be enough.
>>
>> I know this information is little information, give me advice what
>> to look for next time. Unfortunately I dont know how to reproduce
>> it.
>>
>> Thanks in advance,
>>
>> Kojedzinszky Richard
>> Euronet Magyarorszag Informatika Zrt.
>
>
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>

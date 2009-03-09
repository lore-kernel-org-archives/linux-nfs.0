From: Igor Sola <iglesu@gmail.com>
Subject: Re: NFS significantly slow on uncache data, high %iowait, for kernel
	2.6
Date: Mon, 9 Mar 2009 16:37:35 -0700
Message-ID: <49e80a6a0903091637t35d8468dxf5860acf5dd95877@mail.gmail.com>
References: <49e80a6a0903050918y6043e729weba84715fadb0aaf@mail.gmail.com>
	 <20090306194241.GB32692@fieldses.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: linux-nfs@vger.kernel.org
To: "J. Bruce Fields" <bfields@fieldses.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from rv-out-0506.google.com ([209.85.198.237]:58203 "EHLO
	rv-out-0506.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751914AbZCIXhh convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 9 Mar 2009 19:37:37 -0400
Received: by rv-out-0506.google.com with SMTP id g37so1894133rvb.1
        for <linux-nfs@vger.kernel.org>; Mon, 09 Mar 2009 16:37:35 -0700 (PDT)
In-Reply-To: <20090306194241.GB32692@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi Bruce,

I'm using NFS version 3 (nfs-utils-1.0.9) and both UDP and TCP
protocols, with similar results.

The entry in the exports file is:
/data20  <network1>/24(rw,sync,no_root_squash)
<network2>/24(rw,sync,no_root_squash)

and in the client the mount is

nfsserver:/data20     /data20                 nfs       rw,intr,hard
or
nfsserver:/data20     /data20                 nfs
rw,intr,hard,rsize=3Dxyz,wsize=3Dxyz

where xyz could be any number multiple of 2 raging from 8192 to 32768.

Thanks,

Igor

On Fri, Mar 6, 2009 at 12:42 PM, J. Bruce Fields <bfields@fieldses.org>=
 wrote:
> On Thu, Mar 05, 2009 at 10:18:55AM -0700, Igor Sola wrote:
>> Apologies in advance if this email is inappropriate for this mailing
>> list. If so please let me know of a more suitable one.
>>
>> I noticed a significant performance difference when comparing a
>> Centos5 (kernel 2.6.18) or Ubuntu (2.6.27-11) with a RH8 (kernel 2.4=
).
>> All use NFS v3.
>> The RH8 nfsd is faster than the 2.6 one even though it runs in an
>> older, lower spec machine.
>>
>> See test details below
>>
>> Centos 5 x86_64 kernel 2.6.18-92.1.22.el5
>>
>> RH8 2.4.20-30.8.multi_lun.smp #1 SMP =A0i386 GNU/Linux
>>
>> 1Gb connection between machines
>>
>> File sizes are 1GB. The read speed of these files in the local machi=
ne
>> filesystem (server) is around 98MBs in the Centos5 machine and aroun=
d
>> 65MBs in the old RH8 machine.
>>
>> .- First of all I wanted to measure how the network alone performs
>> while using NFS.
>> So in the server side I run a "cat" command on the 1GB file to
>> /dev/null. =A0At this point the file system has the 1GB file cached =
in
>> memory. In the client side a "cat" on the same file gives me a speed
>> of about 113MBs. Which is consistent with the 1Gb network. There is =
no
>> performance hit. So far so good.
>>
>>
>> .- The second test is reading from disk an uncache (in server and
>> client) file. In the server and client I made sure I flushed the 1GB
>> file from the memory. =A0Between =A0Centos5 machines the performance=
 was
>> about 35MBs (64% drop from the 98MBs disk read). Between RH8 machine=
s
>> the performance was 55MBs (15% drop from the 65MBs)
>>
>> This second test was repeated for ext2, ext3, xfs with no significan=
t
>> differences.
>>
>> Please note that the %iowait more than doubles when reading the file
>> from the NFS partition vs the file system partition in the 2.6 kerne=
ls
>>
>> .- I run a third test just to make sure the problem is somehow relat=
ed
>> to the nfs daemon. I mounted the nfs partition local to the nfs serv=
er
>> so the network was out the equation. I got the same poor results, no
>> difference.
>>
>> Any ideas are most welcome,
>
> What version of nfs are you using, over what transport (tcp or udp)?
> What are the export options?
>
> I wonder if something's going wrong with readahead.
>
> --b.
>

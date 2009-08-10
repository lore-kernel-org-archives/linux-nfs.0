From: =?ISO-8859-1?Q?Carlos_Andr=E9?= <candrecn@gmail.com>
Subject: Re: AutoFS+NFSv4 server down = LOOOOONG timeout.
Date: Mon, 10 Aug 2009 15:29:32 -0300
Message-ID: <f6ce31e30908101129i3a0298b4uf96642872909ede8@mail.gmail.com>
References: <f6ce31e30907291021p769d8bb7jb7a13d0370b87bd6@mail.gmail.com>
	 <f6ce31e30908061718u2c527e2eo5cf35f6eb0800fd4@mail.gmail.com>
	 <4A7BCCCA.4020307@panasas.com> <20090807140425.GA18298@fieldses.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: Benny Halevy <bhalevy@panasas.com>, nfsv4@linux-nfs.org,
	Steve Dickson <steved@redhat.com>,
	NFS list <linux-nfs@vger.kernel.org>
To: "J. Bruce Fields" <bfields@fieldses.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-vw0-f172.google.com ([209.85.212.172]:60878 "EHLO
	mail-vw0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751549AbZHJS3b convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 10 Aug 2009 14:29:31 -0400
Received: by vws2 with SMTP id 2so2858451vws.4
        for <linux-nfs@vger.kernel.org>; Mon, 10 Aug 2009 11:29:32 -0700 (PDT)
In-Reply-To: <20090807140425.GA18298@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Bruce, no... you're right.  I'm describing a situation where my server
died... i need mount fail faster (10 or 15 secs max) than 3 minutes
and 9 seconds...

2009/8/7 J. Bruce Fields <bfields@fieldses.org>:
> On Fri, Aug 07, 2009 at 09:42:18AM +0300, Benny Halevy wrote:
>> On Aug. 07, 2009, 3:18 +0300, Carlos Andr=E9 <candrecn@gmail.com> wr=
ote:
>> > Anyone ?
>> >
>> > 2009/7/29 Carlos Andr=E9 <candrecn@gmail.com>:
>> >> PPL, I need put a CentOS 5.3 (updated) NFSv4 server to work with =
Kerberos
>> >> and AutoFS, but i got a problem: If NFS server goes down i get a =
LOOOOOOONG
>> >> mount timeout on CentOS 5.3 (updated) NFSv4 client...
>> >>
>> >> Since i need mount some (3 to 6) dirs at user logon process, if m=
ount hangs,
>> >> user logon hangs. Then i want configure it to timeout (if server =
down) after
>> >> 10-15 secs (MAX) on each mount attempt.
>> >>
>> >> I already make a lab and tried a LOT of combinations, there my fi=
ndings
>> >> (server DOWN IP: 172.16.0.10 / client IP: 172.16.1.10) using basi=
c command
>> >> (time mount 172.16.0.10:/remotedir /localdir/ -t nfs4 -o
>> >> sec=3Dkrb5,proto=3D<tcp/udp>) from NFS client:
>> >>
>> >> - Once i try access mount point using AutoFS (proto=3Dtcp OR prot=
o=3Dudp) it
>> >> hangs for 189 secs (3m9s: real =A03m9.001s) =A0until show error (=
mount: mount to
>> >> NFS server '172.16.0.10' failed: timed out (giving up))
>>
>> Sounds like you're hitting the server's grace period.
>
> I thought he was describing a situation where the server the server
> is completely gone and isn't coming back, and wondering how to make t=
he
> mount fail faster. =A0But I may be misunderstanding.
>
> --b.
>

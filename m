From: gg-B3jsHfKwJfLR7s880joybQ@public.gmane.org
Subject: Re: nfs + Reiser4
Date: Fri, 09 Apr 2010 14:09:09 +0200
Message-ID: <4BBF18E5.5080306@catking.net>
References: <op.vaq49joctxpshh@localhost.localdomain>	 <20100407173438.GA25614@fieldses.org> <4BBCD271.5040100@oracle.com>	 <20100407185157.GF26072@fieldses.org> <4BBCD618.50301@oracle.com>	 <20100407192025.GH26072@fieldses.org>	 <1270674567.3177.2.camel@localhost.localdomain>	 <4BBCFA28.2030101@catking.net>	 <1270680542.6995.21.camel@localhost.localdomain>	 <4BBE448A.3050408@catking.net> <1270762431.7276.28.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Cc: "J. Bruce Fields" <bfields@fieldses.org>,
	Chuck Lever <chuck.lever@oracle.com>, linux-nfs@vger.kernel.org
To: Trond Myklebust <trond.myklebust@fys.uio.no>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from 63.mail-out.ovh.net ([91.121.185.56]:58463 "HELO
	63.mail-out.ovh.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with SMTP id S1751069Ab0DIMJR (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 9 Apr 2010 08:09:17 -0400
In-Reply-To: <1270762431.7276.28.camel-bi+AKbBUZKY6gyzm1THtWbp2dZbC/Bob@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 04/08/10 23:33, Trond Myklebust wrote:
> On Thu, 2010-04-08 at 23:03 +0200, gg-B3jsHfKwJfLR7s880joybQ@public.gmane.org wrote:
>> OK , I just tried this on ext3 partition and I'm not seeing the erratic
>> behaviour.  So this may be down to a bad reaction between nfs and R4 as
>> I suspected.
>>
>> However, I am still seeing vers=2 , does this indicate some problem in
>> initial negociation and a drop back to nfs2 ?
>>
>> /dev/root on / type nfs
>> (rw,vers=2,rsize=4096,wsize=4096,namlen=255,hard,nointr,nolock,proto=udp,timeo=11,retrans=3,sec=sys,addr=192.168.1.3)
>
> I believe that nfsroot always defaults to vers=2 and udp unless you
> explicitly set the 'nfsvers=3' and 'proto=tcp' mount options.
>
> It also defaults to 4k rsize and wsize (set 'rsize=0,wsize=0' if you
> want the client to autonegotiate their values)...
>
> Cheers
>    Trond
>
>
Thanks,

I was refering to man nfs which states that nfs will always try nfs3 and 
if it fails falls back to ver 2. Maybe man nfs is not the definitive 
reference for what is in the kernel if this has changed recently.

I've pretty much concluded the main issues very nfs not playing well 
with reiser4. The doc suggests this is a gray area and indeed it seems 
to be pretty much untested since this kind of grossly bad behavious 
would not be missed.

I had some anomalies  circa 2.6.20 that were less severe but the current 
state of play is frankly pretty unusable.

Since there seems to be an implied policy of not testing with any fs not 
in mainline kernel I'll just have to copy the nfs structure to an ext3 
partition.

Thanks for you comments and help.

regards.




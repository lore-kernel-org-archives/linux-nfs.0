From: gg-B3jsHfKwJfLR7s880joybQ@public.gmane.org
Subject: Re: nfs + Reiser4
Date: Wed, 07 Apr 2010 23:33:28 +0200
Message-ID: <4BBCFA28.2030101@catking.net>
References: <op.vaq49joctxpshh@localhost.localdomain>	 <20100407173438.GA25614@fieldses.org> <4BBCD271.5040100@oracle.com>	 <20100407185157.GF26072@fieldses.org> <4BBCD618.50301@oracle.com>	 <20100407192025.GH26072@fieldses.org> <1270674567.3177.2.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Cc: "J. Bruce Fields" <bfields@fieldses.org>,
	Chuck Lever <chuck.lever@oracle.com>, linux-nfs@vger.kernel.org
To: Trond Myklebust <trond.myklebust@fys.uio.no>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from 63.mail-out.ovh.net ([91.121.185.56]:39381 "HELO
	63.mail-out.ovh.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with SMTP id S1752003Ab0DGVkP (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 7 Apr 2010 17:40:15 -0400
In-Reply-To: <1270674567.3177.2.camel-bi+AKbBUZKY6gyzm1THtWbp2dZbC/Bob@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 04/07/10 23:09, Trond Myklebust wrote:
> On Wed, 2010-04-07 at 15:20 -0400, J. Bruce Fields wrote:
>> On Wed, Apr 07, 2010 at 02:59:36PM -0400, Chuck Lever wrote:
>>> On 04/07/2010 02:51 PM, J. Bruce Fields wrote:
>>>> On Wed, Apr 07, 2010 at 02:44:01PM -0400, Chuck Lever wrote:
>>>>> On 04/07/2010 01:34 PM, J. Bruce Fields wrote:
>>>>>> On Tue, Apr 06, 2010 at 07:52:21PM +0200, gg-B3jsHfKwJfLR7s880joybQ@public.gmane.org wrote:
>>>>>>> I am having serious headaches using nfs between a reiser4 server and arm
>>>>>>> client.
>>>>>>> Both on 2.6.29 vintage kernels.
>>>>>>>
>>>>>>> Files are constantly getting out of sync.
>>>>>>>
>>>>>>> Example :
>>>>>>>
>>>>>>> boot ARM via nfs
>>>>>>> edit lighttpd.conf on ARM
>>>>>>> check edit is visible on server. OK
>>>>>>>
>>>>>>> reboot ARM
>>>>>>> check file : reverted to an earlier state.
>>>>>>> check server: edited version still showing.
>>>>>>
>>>>>> So, on a freshly booted NFS client, you're opening and reading a file
>>>>>> and seeing file data that isn't even on the NFS server any more?
>>>>>>
>>>>>> That's beyond bizarre.  Do you have a reliable way to reproduce the
>>>>>> problem?
>>>>>
>>>>> Could be XID replay.
>>>>
>>>> I'm not following you.  You're thinking of a read request after the
>>>> reboot that unluckily reuses an old XID and gets stale data from the
>>>> servers reply cache?  Or something else?
>>>
>>> Nothing unlucky about it.  Just after a boot, if the client
>>> implementation isn't careful about choosing an initial XID, (eg it
>>> always starts with a psuedorandom number but uses the same seed every
>>> time), it will hit the server's replay cache.
>>
>> Hm, OK.
>>
>>> This can be quite reproducible for NFSROOT and a quiescent server.
>>
>> The Linux server doesn't cache READ results as far as I can tell.
>>
>> --b.
>
> Is he perhaps using the Debian unfsd or some other user space nfs
> server?
>
> Cheers
>    Trond
>
>

Hi,

thanks for all the activity.

Some more info on the machines in question.

server: gentoo linux 2.6.29 kernel patched for R4 
.net-fs/nfs-utils-1.2.1  Recently added nfs4 to existing nfs3 in kernel. 
This did not seem to improve/deteriorate the problem. This has been an 
issue ever since I used nfs to remote boot the client.

Client. ARM SBC also running 2.6.29 nfs3. Similar issues seen when 
running manufacturer's 2.4 kernel. Suggests problem is on server.

Redboot bootstrap loads kernel via http then boots with nfsroot supplied 
by server.

All specific issues related here are as seen yesterday with both running 
2.6.29.

The set up is damn near unusable as it is behaving now . Files are 
constantly out of sync. Changes seem to stay or disappear in a more or 
less arbitrary fashion (ie no percievable repeatable pattern or cause). 
Files often get some kind of merge state which is neither the state on 
the server , nor the last saved state on the client.

/dev/root on / type nfs
(rw,vers=2,rsize=4096,wsize=4096,namlen=255,hard,nointr,nolock,\proto=udp,timeo=\
11,retrans=3,sec=sys,addr=192.168.1.3)

I note vers=2 here, does this maybe indicate some trouble with the 
initial negotiation and fallback to nfs2 ?

I don't have one clear , reproducible problem because the results are so 
erratic. But just editting a file with vi on the client and reopening it 
will give incorrect results 8 time out of 10.

The reboot issue killed me. I thought is desperation that that would at 
least mean I got a clean copy.

Thanks for your interest.

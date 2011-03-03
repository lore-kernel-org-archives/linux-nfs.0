Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from rcsinet10.oracle.com ([148.87.113.121]:58993 "EHLO
	rcsinet10.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758213Ab1CCPyG convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 3 Mar 2011 10:54:06 -0500
Subject: Re: NFS problem on Microblaze LE
Content-Type: text/plain; charset=us-ascii
From: Chuck Lever <chuck.lever@oracle.com>
In-Reply-To: <4D6FAF02.7020701@monstr.eu>
Date: Thu, 3 Mar 2011 10:51:56 -0500
Cc: "J. Bruce Fields" <bfields@fieldses.org>,
        Trond Myklebust <Trond.Myklebust@netapp.com>,
        Neil Brown <neilb@suse.de>, linux-nfs@vger.kernel.org
Message-Id: <C41E2FF3-AD47-40C4-ADBB-5090665CA104@oracle.com>
References: <4D6E4052.7050201@monstr.eu> <20110302154900.GA29136@fieldses.org> <4D6E6C49.90309@monstr.eu> <20110302173438.GC29136@fieldses.org> <4D6E8A5A.8010307@monstr.eu> <20110302182437.GD29136@fieldses.org> <4D6F5F8E.7040200@monstr.eu> <258A2C12-1389-4437-963D-60F0C88FAE91@oracle.com> <4D6FAF02.7020701@monstr.eu>
To: monstr@monstr.eu
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0


On Mar 3, 2011, at 10:08 AM, Michal Simek wrote:

> Chuck Lever wrote:
>> On Mar 3, 2011, at 4:29 AM, Michal Simek wrote:
>>> J. Bruce Fields wrote:
>>>> On Wed, Mar 02, 2011 at 07:20:10PM +0100, Michal Simek wrote:
>>>>> J. Bruce Fields wrote:
>>>>>> On Wed, Mar 02, 2011 at 05:11:53PM +0100, Michal Simek wrote:
>>>>>>> J. Bruce Fields wrote:
>>>>>>>> On Wed, Mar 02, 2011 at 02:04:18PM +0100, Michal Simek wrote:
>>>>>>>>> Hi,
>>>>>>>>> 
>>>>>>>>> I am getting some troubles to get nfs work on new Microblaze
>>>>>>>>> little-endian platform and I would like to ask you for some
>>>>>>>>> recommendations how to debug it.
>>>>>>>>> 
>>>>>>>>> First of all I need to write that Microblaze big-endian platforms have no problem.
>>>>>>>>> The problem only happen if I use mount without -o nolock option
>>>>>>>>> (mount -t nfs 192.168.0.101:/tftpboot/nfs /mnt)
>>>>>>>>> If I use -o nolock option I have no problem to use nfs.
>>>>>>>>> 
>>>>>>>>> I use xilinx emaclite and axi emac(it is not in the mainline now)
>>>>>>>>> driver and I have no problem to use dhcp, ftp, http, telnet and
>>>>>>>>> other internet protocols.
>>>>>>>>> 
>>>>>>>>> I compared debug logs on big and little endian platform(rootfs has
>>>>>>>>> the same setting) I found that little-endian got packet which is
>>>>>>>>> shorter than on big endian which I have added to the log below.
>>>>>>>>> The second thing, which I think is connected to the previous point,
>>>>>>>>> is that I am getting BADCRED in rpc_verify_headers.
>>>>>>>>> 
>>>>>>>>> Is there any option/macro/recommended debug technique how to see
>>>>>>>>> packets? I need to get some clue how to see packet and then how they
>>>>>>>>> are passed to rpc_verify_header function.
>>>>>>>> A good first step would be to look at the network traffic with
>>>>>>>> wireshark.
>>>>>>> Yes, I am looking at it all the time but I can't see anything weird.
>>>>>>> Look at attachment. 192.168.0.101 - host, 192.168.0.103 target.
>>>>>>> 
>>>>>>> There are two NULL calls and two reply calls.
>>>>>> Yes, looks normal.  I wonder why everything exept portmap is using udp,
>>>>>> but your debugging traces refer to tcp?
>>>>>> 
>>>>>> Oh, wait, it's talking about portmap map/unmap calls: could try try
>>>>>> running wireshark on the loopback interface?  (run with -ilo).
>>>>>> 
>>>>> It is captured by tcpdump (tcpdump -i lo -e -S -n -vvv -x -w nfs)
>>>>> If you want to use different setting please let me know. (I have
>>>>> also verbose node but saving to file should be enough for you).
>>>> A little odd; -s0 to get the whole packet might help.
>>> I can't use -s0 because I use older tcpdump but that shouldn't be a problem.
>>> Packet dumps for LE and BE are attached.
>>> 
>>>> You may also want to take a look at it yourself in wireshark.  Probably
>>>> you'll see the BADCRED error in one of the replies once you manage to
>>>> capture the right stuff.
>>> I have looked at it and I see two things.
>>> 1. TCP checksum is incorrect but BE has the same behavior that's why I think it is fine.
>>> 2. Packet #9 (V2 UNSET Reply (Call In 8)) contains Reply state: denied and AUTH_ERROR
>>> bad credential (seal broken) that's the confirmation what I saw from the kernel debug logs.
>>> 
>>> What does it caused this rejection?
>>> 
>>> I am looking for it in the kernel.
>> Which kernel release is this?  (uname -a)
> 
> I can see this behavior on several kernels 2.6.35-37. Currently I use 2.6.37.2.
> 
>> Which distribution is this?  
> 
> It is petalinux distribution which is embedded distribution for Microblaze and PPC440.
> 
>> In user space, does it use portmap with glibc RPC, or rpcbind with libtirpc?
> 
> I use the latest portmap from git://neil.brown.name/portmap that's why I suspect with glibc RPC.
> 
> Is there any endian changes in glibc implementation? We have done this port (not personally me) but if is I think that we miss this change.

That's the thing.  Both portmapper and glibc's RPC implementation are legacy, and thus fairly stable.  I'm not aware of any significant changes there recently.  I think you might also see a BADAUTH if your TCP wrapper configuration is not correct.  Otherwise, you might want to pursue this with petalinux.

-- 
Chuck Lever
chuck[dot]lever[at]oracle[dot]com





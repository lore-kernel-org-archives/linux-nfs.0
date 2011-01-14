Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from eu1sys200aog112.obsmtp.com ([207.126.144.133]:49175 "EHLO
	eu1sys200aog112.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751294Ab1ANJ4w (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 14 Jan 2011 04:56:52 -0500
Message-ID: <4D301DD1.9070104@st.com>
Date: Fri, 14 Jan 2011 15:26:33 +0530
From: deepaksi <deepak.sikri@st.com>
To: Armando VISCONTI <armando.visconti@st.com>
Cc: Chuck Lever <chuck.lever@oracle.com>,
        "Trond.Myklebust@netapp.com" <Trond.Myklebust@netapp.com>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>,
        Shiraz HASHIM <shiraz.hashim@st.com>,
        Viresh KUMAR <viresh.kumar@st.com>,
        Peppe CAVALLARO <peppe.cavallaro@st.com>, Amit GOEL <amit.goel@st.com>
Subject: Re: STMMAC driver: NFS Problem on 2.6.37
References: <4D2EC133.7010607@st.com> <2D04CF75-CA68-4BDC-99A3-FA1DD6113602@oracle.com> <4D2F4453.4040400@st.com>
In-Reply-To: <4D2F4453.4040400@st.com>
Content-Type: text/plain; charset="ISO-8859-1"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

Hi All,

On 1/13/2011 11:58 PM, Armando VISCONTI wrote:
> Chuck Lever wrote:
>   
>> On Jan 13, 2011, at 4:09 AM, deepaksi wrote:
>>
>>   
>>     
>>> Hi
>>>
>>> I am facing a problem related to nfs boot, while using the stmmac driver
>>> ported on 2.6.37 kernel. When we use a JFFS2 file system and mount the kernel,
>>> the network driver works fine.
>>>
>>> I have been following the mailing list and could find some issues with NFS 
>>> on 2.6.37 but I am not too sure whether the kernel crash I am getting is 
>>> related to that.
>>>
>>> The driver worked fine on 2.6.32 kernel, but while booting the 2.6.37
>>> kernel I get the following log messages:
>>>
>>> stmmac: Rx Checksum Offload Engine supported
>>>        TX Checksum insertion supported
>>> IP-Config: Complete:
>>>     device=eth0, addr=192.168.1.10, mask=255.255.255.0, gw=255.255.255.255,
>>>     host=192.168.1.10, domain=, nis-domain=(none),
>>>     bootserver=192.168.1.1, rootserver=192.168.1.1, rootpath=
>>>     
>>>       
>> Why is rootpath left undefined?
>>   
>>     
>   
Even with dhcp server, we get the same log for rootpath. It never
appears over there.

> Yes, Chuck.
> Good catch.
>
> Deepak,
> Can you possibly verify  your bootargs?
>
> I  see exactly your same problem with kernel 2.6.32 (rc6.3) on my
> board, where the bootargs is defined like this:
>
> bootargs=console=ttyAMA0,115200 mem=128M root=/dev/nfs 
> ip=192.168.1.10:192.168.1
> .1:192.168.1.1:255.255.255.0 nfsroot=192.168.1.1:/home/guest/armv7/target
>
> In fact, rootpath is undefined also in my case...
>
> But if I get the network info from my DHCP server the system is booting 
> correctly.
> (i.e. console=ttyAMA0,115200 mem=128M root=/dev/nfs ip=dhcp)
>
> So, why do we have rootpath undefined in our bootargs?
> I guess we screwed up something someway...
>
> Let's see it tomorrow.
>
> Ciao,
> Arm
>
>
>
>   
The nfs work fine when you use the dhcp server, but still it is a
totally different proposition. The problem comes when we assign a static
IP in the bootargs, and then try to boot the system using NFS. here is
the bootargs setting at the u-boot.

bootargs = console=ttyAMA0,115200 mem=128M root=/dev/nfs
nfsroot=192.168.1.1:/opt/STM/STLinux-2.3/devkit/arm/target
ip=192.168.1.10:192.168.1.1:192.168.1.1:255.255.255.0::eth0

These settings have been working fine for earlier kernels. The tcp dump
while doing the nfs boot is quite different between the 2.6.32 and
2.6.37 kernels.



Regards
Deepak



> .
>
>   


Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from eu1sys200aog116.obsmtp.com ([207.126.144.141]:51723 "EHLO
	eu1sys200aog116.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S932891Ab1AMS3M (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 13 Jan 2011 13:29:12 -0500
Message-ID: <4D2F4453.4040400@st.com>
Date: Thu, 13 Jan 2011 19:28:35 +0100
From: Armando Visconti <armando.visconti@st.com>
To: Chuck Lever <chuck.lever@oracle.com>, Deepak SIKRI <deepak.sikri@st.com>
Cc: "Trond.Myklebust@netapp.com" <Trond.Myklebust@netapp.com>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>,
        Shiraz HASHIM <shiraz.hashim@st.com>,
        Viresh KUMAR <viresh.kumar@st.com>,
        Giuseppe CAVALLARO <peppe.cavallaro@st.com>
Subject: Re: STMMAC driver: NFS Problem on 2.6.37
References: <4D2EC133.7010607@st.com> <2D04CF75-CA68-4BDC-99A3-FA1DD6113602@oracle.com>
In-Reply-To: <2D04CF75-CA68-4BDC-99A3-FA1DD6113602@oracle.com>
Content-Type: text/plain; charset="ISO-8859-1"; format=flowed
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

Chuck Lever wrote:
> On Jan 13, 2011, at 4:09 AM, deepaksi wrote:
>
>   
>> Hi
>>
>> I am facing a problem related to nfs boot, while using the stmmac driver
>> ported on 2.6.37 kernel. When we use a JFFS2 file system and mount the kernel,
>> the network driver works fine.
>>
>> I have been following the mailing list and could find some issues with NFS 
>> on 2.6.37 but I am not too sure whether the kernel crash I am getting is 
>> related to that.
>>
>> The driver worked fine on 2.6.32 kernel, but while booting the 2.6.37
>> kernel I get the following log messages:
>>
>> stmmac: Rx Checksum Offload Engine supported
>>        TX Checksum insertion supported
>> IP-Config: Complete:
>>     device=eth0, addr=192.168.1.10, mask=255.255.255.0, gw=255.255.255.255,
>>     host=192.168.1.10, domain=, nis-domain=(none),
>>     bootserver=192.168.1.1, rootserver=192.168.1.1, rootpath=
>>     
>
> Why is rootpath left undefined?
>   

Yes, Chuck.
Good catch.

Deepak,
Can you possibly verify  your bootargs?

I  see exactly your same problem with kernel 2.6.32 (rc6.3) on my
board, where the bootargs is defined like this:

bootargs=console=ttyAMA0,115200 mem=128M root=/dev/nfs 
ip=192.168.1.10:192.168.1
.1:192.168.1.1:255.255.255.0 nfsroot=192.168.1.1:/home/guest/armv7/target

In fact, rootpath is undefined also in my case...

But if I get the network info from my DHCP server the system is booting 
correctly.
(i.e. console=ttyAMA0,115200 mem=128M root=/dev/nfs ip=dhcp)

So, why do we have rootpath undefined in our bootargs?
I guess we screwed up something someway...

Let's see it tomorrow.

Ciao,
Arm




Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from rcsinet10.oracle.com ([148.87.113.121]:54574 "EHLO
	rcsinet10.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756652Ab1ANPfe convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 14 Jan 2011 10:35:34 -0500
Subject: Re: STMMAC driver: NFS Problem on 2.6.37
Content-Type: text/plain; charset=us-ascii
From: Chuck Lever <chuck.lever@oracle.com>
In-Reply-To: <4D301DD1.9070104@st.com>
Date: Fri, 14 Jan 2011 10:35:11 -0500
Cc: Armando VISCONTI <armando.visconti@st.com>,
        "Trond.Myklebust@netapp.com" <Trond.Myklebust@netapp.com>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>,
        Shiraz HASHIM <shiraz.hashim@st.com>,
        Viresh KUMAR <viresh.kumar@st.com>,
        Peppe CAVALLARO <peppe.cavallaro@st.com>, Amit GOEL <amit.goel@st.com>
Message-Id: <593F2676-CA62-4D77-90AD-41F2FAF13EB6@oracle.com>
References: <4D2EC133.7010607@st.com> <2D04CF75-CA68-4BDC-99A3-FA1DD6113602@oracle.com> <4D2F4453.4040400@st.com> <4D301DD1.9070104@st.com>
To: deepaksi <deepak.sikri@st.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0


On Jan 14, 2011, at 4:56 AM, deepaksi wrote:

> The nfs work fine when you use the dhcp server, but still it is a
> totally different proposition. The problem comes when we assign a static
> IP in the bootargs, and then try to boot the system using NFS. here is
> the bootargs setting at the u-boot.
> 
> bootargs = console=ttyAMA0,115200 mem=128M root=/dev/nfs
> nfsroot=192.168.1.1:/opt/STM/STLinux-2.3/devkit/arm/target
> ip=192.168.1.10:192.168.1.1:192.168.1.1:255.255.255.0::eth0
> 
> These settings have been working fine for earlier kernels. The tcp dump
> while doing the nfs boot is quite different between the 2.6.32 and
> 2.6.37 kernels.

Have you tried any kernel versions between 2.6.32 and 2.6.37?  I made significant changes in 2.6.36, so it would be helpful to know when this stopped working.

Also, in 2.6.36, I added a new debugging feature for NFSROOT.  See "nfsrootdebug" description in Documentation/filesystems/nfs/nfsroot.txt.

-- 
Chuck Lever
chuck[dot]lever[at]oracle[dot]com





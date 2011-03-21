Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:26620 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751376Ab1CUOaw (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 21 Mar 2011 10:30:52 -0400
Message-ID: <4D876119.3090007@RedHat.com>
Date: Mon, 21 Mar 2011 10:30:49 -0400
From: Steve Dickson <SteveD@redhat.com>
To: Vladimir Elisseev <vovan@vovan.nl>
CC: NFS list <linux-nfs@vger.kernel.org>
Subject: Re: rpc.svcgssd problem after updating client 1.2.2->1.2.3
References: <1300387690.2684.23.camel@vovan.net.home>	 <AANLkTim6nptBM40b5Zt2fhr7aiQ47kqX+_RBprnCokRD@mail.gmail.com>	 <1300427036.30472.11.camel@vovan.net.home>	 <AANLkTim7q+-ijBnzWs+zW9X-gfxyrt5kw4Vj_pcrWJFw@mail.gmail.com>	 <20110318145204.20621su4mostcrk4@vovan.nl>	 <AANLkTimLE7gJ_tzi5JOCgM+RA4-8EnHcW8hqB++a5X8X@mail.gmail.com>	 <20110318164828.943007egbodjy3t8@vovan.nl>	 <AANLkTinGHaeF-G+XGj8--+m2NygX7fZ49gdf7sAepN=+@mail.gmail.com>	 <1300521382.15416.18.camel@vovan.net.home>  <4D85642D.3060901@RedHat.com> <1300685799.18075.7.camel@vovan.net.home>
In-Reply-To: <1300685799.18075.7.camel@vovan.net.home>
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0



On 03/21/2011 01:36 AM, Vladimir Elisseev wrote:
> Steve,
> 
> The segfault on the client side is gone after client reboot. This
> segfault occurs when nfs-utils has been updated and then I just restart
> corresponding services (rpcbind, rpc.idmapd, rpc.gssd) without rebooting
> the client. Now client simply exits with the lines below (as I described
> initially in my first mail): 
> mount.nfs: mount(2): Permission denied
> mount.nfs: access denied by server while mounting ...
Ok.. to find out where rpc.gssd is segfaulting do the following:

# debuginfo-install nfs-utils
(assuming Fedora)
# gdb /usr/sbin/rpc.gssd 
gdb> run -f -vvv 
(When the segfault happens)
gdb> bt 
(which will show the backtrace)

steved.

> 
> Regards,
> Vladimir.
> 
> On Sat, 2011-03-19 at 22:19 -0400, Steve Dickson wrote:
>>
>> On 03/19/2011 03:56 AM, Vladimir Elisseev wrote:
>>> Kevin,
>>>
>>> I have some updates. I recompiled nfs-utils and dependencies (libgssglue
>>> keyutils librpcsecgss libtirpc) on the server and on the test client.
>>> Nevertheless, while on the server side I see the same error:
>>> rpc.svcgssd[8390]: qword_eol: fflush failed: errno 22 (Invalid argument)
>>> on the client side rpc.gssd segfault(!):
>>> kernel: rpc.gssd[2107] segfault at 4 ip 0000003ef9430805 sp 00007fff655cdd10 error 4 in libgssapi_krb5.so.2.2[3ef9400000+3e000]
>>> Reverting back to nfs-utils 1.2.2 on the client and everything is fine.
>>> Below are relevant log entries from KDC when using nfs-utils 1.2.2 and 1.2.3 on the client:
>>>
>>> ****** nfs-utils 1.2.2 *******
>>> Mar 19 07:56:27 srv2 krb5kdc[7945]: AS_REQ (7 etypes {18 17 16 23 1 3 2}) 192.168.1.8: ISSUE: authtime 1300517787, etypes {rep=18 tkt=18 ses=18}, host/vbox.xxx.xxx@X.X for krbtgt/X.X@X.X 
>>> Mar 19 07:56:28 srv2 krb5kdc[7945]: TGS_REQ (7 etypes {18 17 16 23 1 3 2}) 192.168.1.8: ISSUE: authtime 1300517787, etypes {rep=18 tkt=18 ses=18}, host/vbox.xxx.xxx@X.X for nfs/nfs.xxx.xxx@X.X 
>>> Mar 19 07:56:28 srv2 krb5kdc[7945]: TGS_REQ (3 etypes {1 3 2}) 192.168.1.8: ISSUE: authtime 1300517787, etypes {rep=18 tkt=18 ses=1}, host/vbox.xxx.xxx@X.X for nfs/nfs.xxx.xxx@X.X 
>>>
>>> ****** nfs-utils 1.2.3 *******
>>> Mar 19 08:22:22 srv2 krb5kdc[7945]: AS_REQ (7 etypes {18 17 16 23 1 3 2}) 192.168.1.2: ISSUE: authtime 1300519342, etypes {rep=18 tkt=18 ses=18}, host/x.x.x@X.X for krbtgt/X.X@X.X 
>>> Mar 19 08:22:22 srv2 krb5kdc[7945]: TGS_REQ (7 etypes {18 17 16 23 1 3 2}) 192.168.1.2: ISSUE: authtime 1300519342, etypes {rep=18 tkt=18 ses=18}, host/x.x.x@X.X for nfs/nfs.x.x@X.X
>>> then
>>> rpc.svcgssd[8390]: qword_eol: fflush failed: errno 22 (Invalid argument) 
>>> and segfault on the client side.
>> Would it be possible to get a back trace from the core?
>>
>> steved.
> 

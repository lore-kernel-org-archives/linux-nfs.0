From: Steve Dickson <SteveD@redhat.com>
Subject: Re: Full IPv6 client and server support (kernel and user commands)
Date: Fri, 21 Nov 2008 10:26:08 -0500
Message-ID: <4926D310.4070505@RedHat.com>
References: <48D39CDE.1040600@bull.net> <48DA228D.9040302@linux.vnet.ibm.com>	<C0657B95-8B13-4D0B-A1D5-B1CDDB1C4AA7@oracle.com>	<48DB4C1C.6000805@bull.net> <48DB5D89.6000407@linux.vnet.ibm.com>	<48DB79A7.2080501@bull.net> <48DB7C51.8000606@linux.vnet.ibm.com>	<54717A2D-9C8B-48EB-AAEF-D6F5FF60E0D5@oracle.com>	<48DC824F.6070701@linux.vnet.ibm.com> <48DC90BD.4070702@bull.net>	<48DCB184.1030406@linux.vnet.ibm.com>	<8B169994-A636-440A-AF7A-7E043D18385E@oracle.com>	<48DDA945.7020800@linux.vnet.ibm.com> <48E06DAC.2030708@linux.vnet.ibm.com> <48E085A7.7040000@bull.net> <48E19A2E.7090005@linux.vnet.ibm.com> <48E62607.80809@bull.net> <48F31FEF.4040907@linux.vnet.ibm.com> <48F347B8.3010201@bull.net> <49269AB3.3020106@RedHat.com> <62401FDC-D996-46F5-837E-9CD47D98D869@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: Le Rouzic <aime.le-rouzic@bull.net>,
	Varun Chandramohan <varunc@linux.vnet.ibm.com>,
	Frank S Filz <ffilz@us.ibm.com>,
	"J. Bruce Fields" <bfields@fieldses.org>,
	Linux NFS Mailing list <linux-nfs@vger.kernel.org>
To: Chuck Lever <chuck.lever@oracle.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.redhat.com ([66.187.237.31]:45141 "EHLO mx2.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752692AbYKUP2s (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 21 Nov 2008 10:28:48 -0500
In-Reply-To: <62401FDC-D996-46F5-837E-9CD47D98D869@oracle.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>



Chuck Lever wrote:
> Hi Steve-
> 
> On Nov 21, 2008, at 6:25 AM, Steve Dickson wrote:
>> Le Rouzic wrote:
>>>  Hi,
>>>  My patches are based on Chuck 's ones for nfs-utils and kernel. So
>>> when those from Chuck
>>>  are committed I will need to review mines if always OK.
>>>  Steve Dickson is planning to integrate most of the mount and statd
>>> command changes done by Chuck for IPV6
>>>  in next package nfs-utils-1.1.4.
>> This is done and can be found in git://linux-nfs.org/nfs-utils git
> 
> I have the latest version of this repo, and there are only the first two
> IPv6 patches in there. These two patches only add new shared
> functionality, none of which is even used yet.  So I have a lot more to
> send you.
Bring them on... ;-)

steved.

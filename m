Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:35507 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751721AbbIOTPK (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 15 Sep 2015 15:15:10 -0400
Subject: Re: Default ports to be used by NFS side-band protocol services
 (lockd, statd, rquotad)
To: Steve Dickson <SteveD@redhat.com>, linux-nfs@vger.kernel.org,
        "nfs-ganesha-devel@lists.sourceforge.net"
	<nfs-ganesha-devel@lists.sourceforge.net>,
        Bruce Fields <bfields@redhat.com>, Niels de Vos <ndevos@redhat.com>
References: <55F6C773.9050007@redhat.com> <55F71073.6090102@RedHat.com>
 <20150914183024.GA1277@us.ibm.com>
From: Soumya Koduri <skoduri@redhat.com>
Message-ID: <55F86E37.1010108@redhat.com>
Date: Wed, 16 Sep 2015 00:45:03 +0530
MIME-Version: 1.0
In-Reply-To: <20150914183024.GA1277@us.ibm.com>
Content-Type: text/plain; charset=windows-1252; format=flowed
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>



On 09/15/2015 12:00 AM, Malahal Naineni wrote:
> Steve Dickson [SteveD@redhat.com] wrote:
>> Hello,
>>
>> On 09/14/2015 09:11 AM, Soumya Koduri wrote:
>>> Hi,
>>>
>>> In the latest Linux distributions (Fedora), ports 2049 (nfs) and 20048 (mountd) are configured to be opened by default by firewalld service.
>>>
>>> Files: '/usr/lib/firewalld/services/nfs.xml' & '/usr/lib/firewalld/services/mountd.xml'.
>> Hmm... I didn't know about this... We should probably
>> set the -p 20048 by default via /etc/sysconfig/nfs file or maybe the systemd script?
>
> I believe, mountd already uses /etc/services file by default. So
> specifying it in /etc/services would be good. I think RHEL7 has one for
> mountd. This is specific to NFSv3 anyway...
>

 From '/etc/services' & [1], looks like port# '20048' has been 
registered to be used by mountd service. Does it help if we have ports 
registered for other services too then? Or is it better to keep them 
dynamic and leave it to admin to choose & edit '/etc/sysconfig/nfs' file 
as required.

[1] http://www.iana.org/assignments/port-numbers

Thanks,
Soumya

>
> Regards, Malahal.
>

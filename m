Return-Path: linux-nfs-owner@vger.kernel.org
Received: from cn.fujitsu.com ([222.73.24.84]:50989 "EHLO song.cn.fujitsu.com"
	rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S1756115Ab2B1Bd5 convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 27 Feb 2012 20:33:57 -0500
Message-ID: <4F4C2EAA.1010505@cn.fujitsu.com>
Date: Tue, 28 Feb 2012 09:32:26 +0800
From: Fu Liankun <fuliankun@cn.fujitsu.com>
MIME-Version: 1.0
To: "J. Bruce Fields" <bfields@fieldses.org>
CC: linux-nfs@vger.kernel.org
Subject: Re: spnfs write performance issue
References: <4F44C071.8010104@cn.fujitsu.com> <20120222172510.GA12708@fieldses.org> <4F4B224C.8030101@cn.fujitsu.com> <20120227120136.GA21384@fieldses.org>
In-Reply-To: <20120227120136.GA21384@fieldses.org>
Content-Type: text/plain; charset=UTF-8; format=flowed
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

J. Bruce Fields 写道:
> On Mon, Feb 27, 2012 at 02:27:24PM +0800, Fu Liankun wrote:
>> J. Bruce Fields 写道:
>>> On Wed, Feb 22, 2012 at 06:16:17PM +0800, Fu Liankun wrote:
>>>> When copy a big file(about 500MB) to nfs server using pnfs, it cost
>>>> obvious longer time as compared with NFSv3 or NFSv4 protocol.
>>>>
>>>> PNFS cost about 300-550s
>>>> NFSv3 cost about 49s
>>>> NFSv4 cost about 49s
>>>>
>>>> My test environment as following:
>>>>
>>>> MDS: 3.1.0-rc8-pnfs   ipaddr1: 192.168.0.100, ipaddr2:192.168.1.100
>>>> DS1: 3.1.0-rc8-pnfs   ipaddr1: 192.168.0.101, ipaddr2:192.168.1.101
>>>> DS2: 3.1.0-rc8-pnfs   ipaddr1: 192.168.0.102, ipaddr2:192.168.1.102
>>>> client: RHEL6.2GA(2.6.32-220.el6.i686)    ipaddr1: 192.168.0.19,
>>> What kind of server are you using?
>> Sorry for late response.
>>
>> Fedora14 + 3.1.0-rc8-pnfs
> 
> And you're exporting gfs2?

No. I'm exporting ext4.
Does the file system type would influence the result?

--b

> 
> --b.
> 
>> --b
>>
>>> --b.
>>>
>>>> ipaddr2:192.168.1.19
>>>>
>>>> 192.168.1.100 <-------- NFS4.1 connection --------->192.168.1.101
>>>> 192.168.0.100 <-------- NFS4.1 connection --------->192.168.0.102
>>>> 192.168.0.19  <-------- NFS4.1 connection --------->192.168.0.100
>>>>
>>>> Dunring the write process, the client output the message:
>>>> FS-Cache: Loaded
>>>> FS-Cache: Netfs 'nfs' registered for caching
>>>> nfs4filelayout_init: NFSv4 File Layout Driver Registering...
>>>> nfs: server 192.168.1.101 not responding, timed out
>>>>
>>>> The message "nfs: server 192.168.1.101 not responding, timed out" was
>>>> output during the COMMIT request.
>>>>
>>>> Who can tell me the reason why pnfs cost so long time.
>>>>
>>>>
>>>>
>>>> --
>>>> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
>>>> the body of a message to majordomo@vger.kernel.org
>>>> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>>> --
>>> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
>>> the body of a message to majordomo@vger.kernel.org
>>> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>>>
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> 


-- 
----
Best wishes
Fu Liankun


Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-ee0-f46.google.com ([74.125.83.46]:46719 "EHLO
	mail-ee0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754007Ab2B1J13 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 28 Feb 2012 04:27:29 -0500
Received: by eekc41 with SMTP id c41so1068117eek.19
        for <linux-nfs@vger.kernel.org>; Tue, 28 Feb 2012 01:27:28 -0800 (PST)
Message-ID: <4F4C9DFD.4080303@tonian.com>
Date: Tue, 28 Feb 2012 11:27:25 +0200
From: Benny Halevy <bhalevy@tonian.com>
MIME-Version: 1.0
To: "J. Bruce Fields" <bfields@fieldses.org>,
        Fu Liankun <fuliankun@cn.fujitsu.com>
CC: linux-nfs@vger.kernel.org
Subject: Re: spnfs write performance issue
References: <4F44C071.8010104@cn.fujitsu.com> <20120222172510.GA12708@fieldses.org> <4F4B224C.8030101@cn.fujitsu.com> <20120227120136.GA21384@fieldses.org> <4F4C2EAA.1010505@cn.fujitsu.com> <20120228014618.GA28042@fieldses.org> <4F4C3262.9050301@cn.fujitsu.com> <20120228015324.GB28042@fieldses.org>
In-Reply-To: <20120228015324.GB28042@fieldses.org>
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 2012-02-28 03:53, J. Bruce Fields wrote:
> On Tue, Feb 28, 2012 at 09:48:18AM +0800, Fu Liankun wrote:
>> J. Bruce Fields 写道:
>>> On Tue, Feb 28, 2012 at 09:32:26AM +0800, Fu Liankun wrote:
>>>> J. Bruce Fields 写道:
>>>>> On Mon, Feb 27, 2012 at 02:27:24PM +0800, Fu Liankun wrote:
>>>>>> J. Bruce Fields 写道:
>>>>>>> On Wed, Feb 22, 2012 at 06:16:17PM +0800, Fu Liankun wrote:
>>>>>>>> When copy a big file(about 500MB) to nfs server using pnfs, it cost
>>>>>>>> obvious longer time as compared with NFSv3 or NFSv4 protocol.
>>>>>>>>
>>>>>>>> PNFS cost about 300-550s
>>>>>>>> NFSv3 cost about 49s
>>>>>>>> NFSv4 cost about 49s
>>>>>>>>
>>>>>>>> My test environment as following:
>>>>>>>>
>>>>>>>> MDS: 3.1.0-rc8-pnfs   ipaddr1: 192.168.0.100, ipaddr2:192.168.1.100
>>>>>>>> DS1: 3.1.0-rc8-pnfs   ipaddr1: 192.168.0.101, ipaddr2:192.168.1.101
>>>>>>>> DS2: 3.1.0-rc8-pnfs   ipaddr1: 192.168.0.102, ipaddr2:192.168.1.102
>>>>>>>> client: RHEL6.2GA(2.6.32-220.el6.i686)    ipaddr1: 192.168.0.19,
>>>>>>> What kind of server are you using?
>>>>>> Sorry for late response.
>>>>>>
>>>>>> Fedora14 + 3.1.0-rc8-pnfs
>>>>> And you're exporting gfs2?
>>>> No. I'm exporting ext4.
>>>> Does the file system type would influence the result?
>>>
>>> So you're using local-pnfs?  Or spnfs?  What setup instructions did you
>>> follow?
>>
>> I'm using spnfs.
> 
> OK, got it.
> 
> I'm not sure if anyone here can talk about the performance of spnfs.
> It's not really maintained as far as I know.

True.  spnfs is unsupported and not maintained by anybody.
Sorry.

Benny

> 
> So, you're the expert.
> 
> --b.
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

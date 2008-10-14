From: Omry Yadan <omry-FZzTFxfWWV5eoWH0uzbU5w@public.gmane.org>
Subject: Re: file open for write fails under stress
Date: Tue, 14 Oct 2008 15:49:53 +0200
Message-ID: <48F4A381.4040700@yadan.net>
References: <48F3D106.9020203@yadan.net> <1223990637.8907.3.camel@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: linux-nfs@vger.kernel.org
To: Trond Myklebust <trond.myklebust@fys.uio.no>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from out4.bezeqint.net ([192.115.188.199]:36225 "EHLO
	out4.bezeqint.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750929AbYJNNtz (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 14 Oct 2008 09:49:55 -0400
In-Reply-To: <1223990637.8907.3.camel@localhost>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Trond Myklebust wrote:

> On Tue, 2008-10-14 at 00:51 +0200, Omry Yadan wrote:
>   
>> I have an application that open many files for writing very fast, in a
>> way - it can almost be looked as a file system stress test.
>>
>>
>> my application is single threaded, and I noticed the following problem
>> when running a single instance of it:
>>
>>
>> at some point, after opening (and closing) many files for writing, the
>> application fails to open a file for writing.
>>
>> if I sleep for 1 second and try again, it works.
>>     
>
> What version of nfs, filesystem on the server, export options, mount
> options,...?
>
>   

/etc/exports:
/var/vizi 38.99.126.160/28(rw,sync,no_subtree_check)
server file system : ext3 on a raid5 (900gb, 3x500gb hd).
server nfs version: 1.0.10

client mount:
nas1:/var/vizi on /var/vizi type nfs (rw,tcp,addr=38.99.126.163)


From: Omry Yadan <omry-FZzTFxfWWV5eoWH0uzbU5w@public.gmane.org>
Subject: Re: file open for write fails under stress
Date: Tue, 14 Oct 2008 16:46:37 +0200
Message-ID: <48F4B0CD.4080203@yadan.net>
References: <48F3D106.9020203@yadan.net> <1223990637.8907.3.camel@localhost>	 <48F4A381.4040700@yadan.net> <1223993459.8907.11.camel@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: linux-nfs@vger.kernel.org
To: Trond Myklebust <trond.myklebust@fys.uio.no>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from out3.bezeqint.net ([192.115.188.198]:51393 "EHLO
	out3.bezeqint.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751121AbYJNOqv (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 14 Oct 2008 10:46:51 -0400
In-Reply-To: <1223993459.8907.11.camel@localhost>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


>> /etc/exports:
>> /var/vizi 38.99.126.160/28(rw,sync,no_subtree_check)
>> server file system : ext3 on a raid5 (900gb, 3x500gb hd).
>> server nfs version: 1.0.10
>>     
>
>   
>> client mount:
>> nas1:/var/vizi on /var/vizi type nfs (rw,tcp,addr=38.99.126.163)
>>     
>
> So I assume it is NFS version 3, then?
>
> What error does the application get when the open() fails?
>   
according to nfsstat, yes - it's NFS v3.
after open fails (I use fstream binary_file(name,ios::out|ios::binary) )
the error message returned from strerror_r(errno, buf, 1000) is
something like "Input Output error".

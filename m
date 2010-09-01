Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from rcsinet10.oracle.com ([148.87.113.121]:32916 "EHLO
	rcsinet10.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751966Ab0IAPrJ convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 1 Sep 2010 11:47:09 -0400
Subject: Re: NFS version4 maximum on-the-wire data size.
Content-Type: text/plain; charset=us-ascii
From: Chuck Lever <chuck.lever@oracle.com>
In-Reply-To: <0FDF651C-4620-4872-9ABA-9F8D8FA2192A@oracle.com>
Date: Wed, 1 Sep 2010 11:46:04 -0400
Cc: "Tayade, Nilesh" <Nilesh.Tayade@netscout.com>, <linux-nfs@vger.kernel.org>
Message-Id: <99E0B37F-C9BE-4349-B68A-4364F4EB9C04@oracle.com>
References: <D3F292ADF945FB49B35E96C94C2061B90CFB48D0@nsmail.netscout.com> <0FDF651C-4620-4872-9ABA-9F8D8FA2192A@oracle.com>
To: Chuck Lever <chuck.lever@oracle.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0


On Sep 1, 2010, at 11:41 AM, Chuck Lever wrote:

> 
> On Sep 1, 2010, at 5:39 AM, Tayade, Nilesh wrote:
> 
>> Hi,
>> 
>> I am unable to get the exact count for the amount of on-the-wire data
>> size that NFSv4 supports. 
>> 
>> I could get exact figures in case of NFSv3 (http://nfs.sourceforge.net).
>> It's 60KB when NFSv3 is used over UDP and implementation dependent in
>> case it is used over TCP. Any idea about NFSv4 statistics? 
>> 
>> Any pointers would be appreciated.
> 
> NFSv4 reads and writes can be as large as the maximum payload size of the underlying transport.  NFSv4 does not support UDP, but on TCP, the maximum payload size is usually approximately (2 ** 31 - 1) - (RPC header + NFS overhead).

But you were probably not asking about the theoretical limits of the underlying transport.

The Linux NFS client limits read and write payload size to a megabyte.  Servers may limit it further.

-- 
chuck[dot]lever[at]oracle[dot]com





Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from rcsinet10.oracle.com ([148.87.113.121]:58026 "EHLO
	rcsinet10.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755284Ab0LPCpr convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 15 Dec 2010 21:45:47 -0500
Subject: Re: [PATCH 13/31] NFS: Introduce new-style XDR decoding functions for NFSv2
Content-Type: text/plain; charset=us-ascii
From: Chuck Lever <chuck.lever@oracle.com>
In-Reply-To: <1292449747.3068.76.camel@heimdal.trondhjem.org>
Date: Wed, 15 Dec 2010 21:44:02 -0500
Cc: linux-nfs@vger.kernel.org
Message-Id: <CF0E157E-8ADF-448E-B849-AD8ADAB555B8@oracle.com>
References: <20101214144747.2293.68070.stgit@matisse.1015granger.net> <20101214145630.2293.21193.stgit@matisse.1015granger.net> <1292449747.3068.76.camel@heimdal.trondhjem.org>
To: Trond Myklebust <Trond.Myklebust@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0


On Dec 15, 2010, at 4:49 PM, Trond Myklebust wrote:

> On Tue, 2010-12-14 at 09:56 -0500, Chuck Lever wrote:
>> We'd like to prevent local buffer overflows caused by malicious or
>> broken servers.  New xdr_stream style decoders can do that.
>> 
>> For efficiency, we also eventually want to be able to pass xdr_streams
>> from call_decode() to all XDR decoding functions, rather than building
>> an xdr_stream in every XDR decoding function in the kernel.
>> 
>> Static helper functions are left without the "inline" directive.  This
>> allows the compiler to choose automatically how to optimize these for
>> size or speed.
>> 
>> Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
>> Tested-by: J. Bruce Fields <bfields@redhat.com>
>> ---
>> 
>> fs/nfs/nfs3xdr.c     | 1534 +++++++++++++++++++++++++++++++++++++++++++++++---
>> include/linux/nfs3.h |    1 
>> 2 files changed, 1451 insertions(+), 84 deletions(-)
> 
> Doesn't look like NFSv2 to me...

You have my permission to correct the short definition.

--
Chuck Lever
chuck[dot]lever[at]oracle[dot]com




Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from rcsinet10.oracle.com ([148.87.113.121]:25533 "EHLO
	rcsinet10.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751541Ab0LWATY (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 22 Dec 2010 19:19:24 -0500
Subject: Re: [PATCH 1/5] NFS: call_sync function
Content-Type: text/plain; charset=us-ascii
From: Chuck Lever <chuck.lever@oracle.com>
In-Reply-To: <1293063267.6422.53.camel@heimdal.trondhjem.org>
Date: Wed, 22 Dec 2010 19:18:21 -0500
Cc: Jim Rees <rees@umich.edu>, Bryan Schumaker <bjschuma@netapp.com>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Message-Id: <01AD75A8-BF38-44C7-9B44-C192FA062858@oracle.com>
References: <4D1272B6.9000907@netapp.com> <20101222235447.GA25778@merit.edu> <1293063267.6422.53.camel@heimdal.trondhjem.org>
To: Trond Myklebust <Trond.Myklebust@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0


On Dec 22, 2010, at 7:14 PM, Trond Myklebust wrote:

> On Wed, 2010-12-22 at 18:54 -0500, Jim Rees wrote:
>> Bryan Schumaker wrote:
>> 
>>  This patch changes nfs4_call_sync() from a macro into a
>>  static inline function.
>> 
>> Makes sense, but why change the arguments?
> 
> Not sure I understand. Do you mean the change from untyped args and res
> to nfs4_sequence_args and nfs4_sequence_res? That would be to enable
> proper type checking.
> 
> That part of the macro was always a dirty hack which relied on the
> sequence related arguments always having the same names, and which only
> served to avoid having to type those 8 characters per argument...

It would be nice to document that improvement in the patch description.

-- 
Chuck Lever
chuck[dot]lever[at]oracle[dot]com





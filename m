Return-Path: linux-nfs-owner@vger.kernel.org
Received: from userp1040.oracle.com ([156.151.31.81]:33072 "EHLO
	userp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755407Ab3A3Uor convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 30 Jan 2013 15:44:47 -0500
Content-Type: text/plain; charset=us-ascii
Mime-Version: 1.0 (Mac OS X Mail 6.2 \(1499\))
Subject: Re: [PATCH] SUNRPC: Pin GSS module while handling flavor lookups
From: Chuck Lever <chuck.lever@oracle.com>
In-Reply-To: <20130130202742.GE14256@fieldses.org>
Date: Wed, 30 Jan 2013 15:44:37 -0500
Cc: linux-nfs@vger.kernel.org
Message-Id: <8EA112A2-AF62-422D-B677-C17F28416F1A@oracle.com>
References: <20130130193120.1289.33936.stgit@seurat.1015granger.net> <20130130202742.GE14256@fieldses.org>
To: "J. Bruce Fields" <bfields@fieldses.org>,
        Trond Myklebust <Trond.Myklebust@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


On Jan 30, 2013, at 3:27 PM, "J. Bruce Fields" <bfields@fieldses.org> wrote:

> On Wed, Jan 30, 2013 at 02:34:30PM -0500, Chuck Lever wrote:
>> Add an API similar to rpcauth_lookup_pseudoflavor().  The NFS server
>> should not call GSS API functions directly without first pinning
>> the GSS module.
>> 
>> Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
>> ---
>> 
>> Bruce-
>> 
>> Are you interested in taking something like this (untested) patch
>> for 3.9?  (This has pre-requisites I posted earlier this week).
> 
> OK.  Let me know what you want me to do.

Since the pre-requisites are going through Trond, I can just send it in through him, as long as you both agree to it.

-- 
Chuck Lever
chuck[dot]lever[at]oracle[dot]com





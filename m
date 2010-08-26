Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from rcsinet10.oracle.com ([148.87.113.121]:45393 "EHLO
	rcsinet10.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754264Ab0HZQLM convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 26 Aug 2010 12:11:12 -0400
Subject: Re: mount.nfs: protocol fallback when server doesn't support TCP
Content-Type: text/plain; charset=us-ascii
From: Chuck Lever <chuck.lever@ORACLE.COM>
In-Reply-To: <20100826152702.GB23940@merit.edu>
Date: Thu, 26 Aug 2010 12:09:56 -0400
Cc: Neil Brown <neilb@suse.de>,
        Linux NFS Mailing list <linux-nfs@vger.kernel.org>
Message-Id: <194FD3F7-442E-4B8F-B29A-714D6423C0F0@oracle.com>
References: <20100826120635.4c3157bc@notabene> <659EE931-F48E-4A5D-9212-D4F8AE421029@oracle.com> <20100826152702.GB23940@merit.edu>
To: Jim Rees <rees@umich.edu>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0


On Aug 26, 2010, at 11:27 AM, Jim Rees wrote:

> Chuck Lever wrote:
> 
>  On Aug 25, 2010, at 10:06 PM, Neil Brown wrote:
>> Maybe the ideal would be to do a portmap probe and only fall back to v3 if
>> portmap confirm that v3 is supported and v4 isn't.
> 
>  What are the risks of checking portmap in this case?  That seems like it
>  would give a better chance of a desirable outcome.
> 
> In general, portmap can't confirm that v4 isn't available, only that v3 is.
> Right?

Registering an NFSv4 service with the local rpcbind is a SHOULD at best, true.  But, if no version-specific mount options are specified, I think establishing any kind of connection is better than failing.

-- 
chuck[dot]lever[at]oracle[dot]com





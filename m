From: Chuck Lever <chuck.lever@oracle.com>
Subject: Re: [PATCH 07/11] NFSD: Use "depends on" for PROC_FS dependency
Date: Wed, 13 Feb 2008 13:22:13 -0500
Message-ID: <47B33555.8000106@oracle.com>
References: <20080211221216.1047.31922.stgit@manray.1015granger.net>	 <20080212212325.GM18625@fieldses.org>	 <1202852836.9228.1.camel@heimdal.trondhjem.org>	 <20080212223235.GP18625@fieldses.org> <1202857069.9228.14.camel@heimdal.trondhjem.org>
Reply-To: chuck.lever@oracle.com
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------010102000604000709060403"
Cc: "J. Bruce Fields" <bfields@fieldses.org>, linux-nfs@vger.kernel.org
To: Trond Myklebust <trond.myklebust@fys.uio.no>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from rgminet01.oracle.com ([148.87.113.118]:61891 "EHLO
	rgminet01.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751818AbYBMSW5 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 13 Feb 2008 13:22:57 -0500
In-Reply-To: <1202857069.9228.14.camel-rJ7iovZKK19ZJLDQqaL3InhyD016LWXt@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

This is a multi-part message in MIME format.
--------------010102000604000709060403
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit

Trond Myklebust wrote:
> On Tue, 2008-02-12 at 17:32 -0500, J. Bruce Fields wrote:
>>>> I assume nobody cares?
>>> You assume wrongly. Patch NAKed...
>> Do you have a use case in mind?  (Just curious.)
> 
> Embedded systems often compile without sysctl and/or procfs support. Why
> shouldn't they be able to run an NFS client with RPCSEC_GSS?
> 
> The other argument is that there is _nothing_ in the actual auth_gss
> code that depends on procfs. The "dependency" (if there is one) is
> between net/sunrpc/cache.c and procfs, and in fact, both sunrpc and the
> auth_gss modules will compile just fine without procfs.

In that case, do we really even need a PROC_FS dependency (forward or 
reverse) for the RPCSEC entries?

It would be simple to split this patch into an NFSD_V4 part and an 
RPCSEC part, and just drop the RPCSEC part.

--------------010102000604000709060403
Content-Type: text/x-vcard; charset=utf-8;
 name="chuck_lever.vcf"
Content-Transfer-Encoding: 7bit
Content-Disposition: attachment;
 filename="chuck_lever.vcf"

begin:vcard
fn:Chuck Lever
n:Lever;Chuck
org:Oracle Corporation;Corporate Architecture: Linux Projects Group
adr:;;1015 Granger Avenue;Ann Arbor;MI;48104;USA
email;internet:chuck dot lever at nospam oracle dot com
title:Principal Member of Staff
tel;work:+1 248 614 5091
x-mozilla-html:FALSE
version:2.1
end:vcard


--------------010102000604000709060403--

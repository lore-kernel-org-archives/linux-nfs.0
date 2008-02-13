From: Chuck Lever <chuck.lever@oracle.com>
Subject: Re: [PATCH 07/11] NFSD: Use "depends on" for PROC_FS dependency
Date: Wed, 13 Feb 2008 13:44:41 -0500
Message-ID: <47B33A99.60400@oracle.com>
References: <20080211221216.1047.31922.stgit@manray.1015granger.net>	 <20080212212325.GM18625@fieldses.org>	 <1202852836.9228.1.camel@heimdal.trondhjem.org>	 <20080212223235.GP18625@fieldses.org> <1202857069.9228.14.camel@heimdal.trondhjem.org>
Reply-To: chuck.lever@oracle.com
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------040004080401000104040201"
Cc: "J. Bruce Fields" <bfields@fieldses.org>, linux-nfs@vger.kernel.org
To: Trond Myklebust <trond.myklebust@fys.uio.no>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from agminet01.oracle.com ([141.146.126.228]:59550 "EHLO
	agminet01.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753330AbYBMSpe (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 13 Feb 2008 13:45:34 -0500
In-Reply-To: <1202857069.9228.14.camel-rJ7iovZKK19ZJLDQqaL3InhyD016LWXt@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

This is a multi-part message in MIME format.
--------------040004080401000104040201
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

OK, it looks like the patch that adds the "depends on SYSCTL" to the 
LOCKD entry will cause NFS-enabled builds to break if CONFIG_SYSCTL is 
disabled, thanks to the recent addition of nlmclnt_init and nlmclnt_done.

Probably the better solution in this case is to ifdef out the 
register_sysctl() call in lockd if CONFIG_SYSCTL isn't set.  In the long 
run, should we make it possible to build the NFS client without lockd?

--------------040004080401000104040201
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


--------------040004080401000104040201--

From: Chuck Lever <chuck.lever@oracle.com>
Subject: Re: [PATCH 0/7] Address kernel bugzilla 12256
Date: Fri, 30 Jan 2009 15:27:09 -0500
Message-ID: <AB33CBC4-C13F-4FD3-B766-BB30BEA27742@oracle.com>
References: <20090130200021.22301.22618.stgit@ingres.1015granger.net> <20090130202112.GF31166@fieldses.org>
Mime-Version: 1.0 (Apple Message framework v930.3)
Content-Type: text/plain; charset=US-ASCII; format=flowed; delsp=yes
Cc: linux-nfs@vger.kernel.org
To: "J. Bruce Fields" <bfields@fieldses.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from rcsinet11.oracle.com ([148.87.113.123]:45087 "EHLO
	rgminet11.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753993AbZA3U1X (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 30 Jan 2009 15:27:23 -0500
In-Reply-To: <20090130202112.GF31166@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Jan 30, 2009, at Jan 30, 2009, 3:21 PM, J. Bruce Fields wrote:
> On Fri, Jan 30, 2009 at 03:10:32PM -0500, Chuck Lever wrote:
>> Updated patch series to remove the SUNRPC_REGISTER_V4 kernel build
>> option.  These address kernel bugzilla 12256 ("RPC: failed to contact
>> local rpcbind server (errno 5)." if CONFIG_SUNRPC_REGISTER_V4 is set
>> to Y").  Please include them in your for-2.6.30 branch, replacing
>> any previous version of this patch series.
>>
>> There may be some problems applying this patch set to linux-next, as
>> that may have recent patches that split up fs/Kconfig.
>
> Actually, those patches are in mainline (and my for-2.6.30 branch);
> would you like to rebase?  It should be trivial.

Ignore that last paragraph, I just copied it from the previous post.   
Today's series should be all set.

--
Chuck Lever
chuck[dot]lever[at]oracle[dot]com

Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from userp1040.oracle.com ([156.151.31.81]:42254 "EHLO
	userp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750953AbcBVSjb (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 22 Feb 2016 13:39:31 -0500
Content-Type: text/plain; charset=us-ascii
Mime-Version: 1.0 (Mac OS X Mail 9.2 \(3112\))
Subject: Re: [PATCH v3 01/10] svcrdma: Do not write xdr_buf::tail in a Write chunk
From: Chuck Lever <chuck.lever@oracle.com>
In-Reply-To: <EF7CD34B-53D8-4657-938C-F19DD5A5A666@oracle.com>
Date: Mon, 22 Feb 2016 13:39:07 -0500
Cc: linux-rdma@vger.kernel.org,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Message-Id: <01D1023C-687F-46A1-98B3-2135F471B0D4@oracle.com>
References: <20160218173840.12825.26769.stgit@klimt.1015granger.net> <20160218174353.12825.14732.stgit@klimt.1015granger.net> <20160222183211.GA22270@fieldses.org> <EF7CD34B-53D8-4657-938C-F19DD5A5A666@oracle.com>
To: "J. Bruce Fields" <bfields@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


> On Feb 22, 2016, at 1:35 PM, Chuck Lever <chuck.lever@oracle.com> wrote:
> 
> 
>> On Feb 22, 2016, at 1:32 PM, bfields@fieldses.org wrote:
>> 
>> On Thu, Feb 18, 2016 at 12:43:53PM -0500, Chuck Lever wrote:
>>> The fix is to send only the contents of the xdr_buf's page list in
>>> a Write chunk.
>> 
>> This isn't quite right either.  A large-enough non-readlike reply will
>> use the page list if that's the only way to fit the reply.
>> 
>> You might be able to hit such cases, for example, using nfs4_getfacl on
>> a file with a sufficiently large ACL.
> 
> Clients provide a write chunk only for READ and READLINK.
> No way to hit this with GETFACL unless the client is doing
> something wrong.

OK, I see your point: and yes, I agree. The next revision
of the patch is more careful about trimming the page list
pad _only_ for the write chunk case, not for the reply case,
which is what you hit with GETFACL.


> Anyway, I've got another revision of this work coming, this
> time it should be a complete fix.
> 
> Thanks as always for your careful review!
> 
> --
> Chuck Lever
> 
> 
> 
> 
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

--
Chuck Lever





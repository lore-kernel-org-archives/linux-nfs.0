From: Peter Staubach <staubach@redhat.com>
Subject: Re: Reference to file size in nfsd_create_v3
Date: Wed, 26 Aug 2009 09:38:46 -0400
Message-ID: <4A953AE6.1030800@redhat.com>
References: <4A449074.6060600@gluster.com> <20090825161845.GD26206@fieldses.org> <4A94DFDA.4040508@gluster.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: "J. Bruce Fields" <bfields@fieldses.org>,
	Linux NFS Mailing List <linux-nfs@vger.kernel.org>
To: Shehjar Tikoo <shehjart-+FkPdpiNhgJBDgjK7y7TUQ@public.gmane.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:8590 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757282AbZHZNir (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 26 Aug 2009 09:38:47 -0400
In-Reply-To: <4A94DFDA.4040508-+FkPdpiNhgJBDgjK7y7TUQ@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Shehjar Tikoo wrote:
> J. Bruce Fields wrote:
>> On Fri, Jun 26, 2009 at 02:40:12PM +0530, Shehjar Tikoo wrote:
>>> Hi All
>>>
>>> I am looking at the fs/nfsd/vfs.c:nfsd_create_v3 function. In
>>> there, a comment says: "furthermore, if the size is nonzero, we
>>> should ignore it according to spec!"
>>>
>>> Could someone please point out the section in RFC1813 where this
>>> particular point is specified?
>>
>> It's referring to the third paragraph of the DESCRIPTION section of
>> the OPEN operation (14.2.16) in rfc 3530.
>>
>> --b.
> Ok.
> 
> For NFSv3, is there a specified way to handle create or mkdir ops where
>  the size is non-zero? The reason this came up is that I was testing
> unfs3 with SpecSFS2k8 and an MKDIR op failed in unfs3 because SFS sent
> the mkdir call with non-zero size in the attributes. I just wanted to
> see how Linux nfsd handled it.
> 

Most servers in the market just ignore the size field for
MKDIR requests.  They also ignore the size field, unless it is
0, for CREATE requests.

Setting the size on a directory does not make sense and the
usual decision point for file creation is whether to truncate
the file to empty or not.

		ps

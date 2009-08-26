From: Shehjar Tikoo <shehjart-+FkPdpiNhgJBDgjK7y7TUQ@public.gmane.org>
Subject: Re: Reference to file size in nfsd_create_v3
Date: Wed, 26 Aug 2009 12:40:18 +0530
Message-ID: <4A94DFDA.4040508@gluster.com>
References: <4A449074.6060600@gluster.com> <20090825161845.GD26206@fieldses.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Cc: Linux NFS Mailing List <linux-nfs@vger.kernel.org>
To: "J. Bruce Fields" <bfields@fieldses.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from saturn.datasyncintra.net ([208.88.241.29]:40668 "EHLO
	saturn.datasyncintra.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753185AbZHZHKY (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 26 Aug 2009 03:10:24 -0400
In-Reply-To: <20090825161845.GD26206@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

J. Bruce Fields wrote:
> On Fri, Jun 26, 2009 at 02:40:12PM +0530, Shehjar Tikoo wrote:
>> Hi All
>> 
>> I am looking at the fs/nfsd/vfs.c:nfsd_create_v3 function. In
>> there, a comment says: "furthermore, if the size is nonzero, we
>> should ignore it according to spec!"
>> 
>> Could someone please point out the section in RFC1813 where this 
>> particular point is specified?
> 
> It's referring to the third paragraph of the DESCRIPTION section of
> the OPEN operation (14.2.16) in rfc 3530.
> 
> --b.
Ok.

For NFSv3, is there a specified way to handle create or mkdir ops where
  the size is non-zero? The reason this came up is that I was testing
unfs3 with SpecSFS2k8 and an MKDIR op failed in unfs3 because SFS sent
the mkdir call with non-zero size in the attributes. I just wanted to
see how Linux nfsd handled it.


Thanks
-Shehjar

From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: [PATCH 1/4] nfs-utils: introduce new statd implementation (1st
	part)
Date: Thu, 10 Sep 2009 12:23:27 -0400
Message-ID: <20090910162327.GE11858@fieldses.org>
References: <1249507356.5428.11.camel@heimdal.trondhjem.org> <D503383F-3D52-4F93-B850-AFE84316435C@oracle.com> <1249515004.5428.34.camel@heimdal.trondhjem.org> <20090909142945.755da393@tlielax.poochiereds.net> <1252521599.8722.53.camel@heimdal.trondhjem.org> <20B7C2F0-E566-4292-91E9-41A3FA6C9D4C@oracle.com> <1252525327.8722.81.camel@heimdal.trondhjem.org> <D2B488FA-2630-4355-8E3B-FE1243E4C3AE@oracle.com> <20090910150319.GA10704@fieldses.org> <AD3CA71A-8A67-4D8E-8138-92A01D672133@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Trond Myklebust <trond.myklebust@fys.uio.no>,
	Jeff Layton <jlayton@redhat.com>, steved@redhat.com,
	linux-nfs@vger.kernel.org
To: Chuck Lever <chuck.lever@oracle.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([174.143.236.118]:45643 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750917AbZIJQXa (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 10 Sep 2009 12:23:30 -0400
In-Reply-To: <AD3CA71A-8A67-4D8E-8138-92A01D672133@oracle.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, Sep 10, 2009 at 12:14:27PM -0400, Chuck Lever wrote:
> On Sep 10, 2009, at 11:03 AM, J. Bruce Fields wrote:
>> On Wed, Sep 09, 2009 at 06:18:11PM -0400, Chuck Lever wrote:
>>> IDNs are UTF16.  /var therefore has to support UTF16 filenames;  
>>> either
>>> byte in a double-byte character can be '/' or '\0'.  That means the
>>> underlying fs implementation has to support UTF16 (FAT32 anyone?),  
>>> and
>>> the system's locale has to be configured correctly.  If we decide  
>>> not to
>>> depend on the file system to support UTF16 filenames, then statd has 
>>> to
>>> be intelligent enough to figure out how to deal with converting UTF16
>>> hostnames before storing them as filenames.  Then, we have to teach
>>> matchhostname() and friends how to deal with double-byte character
>>> strings...
>>
>> Googling around.... Is this accurate?:
>>
>> 	http://en.wikipedia.org/wiki/Internationalized_domain_name
>>
>> That makes it sound like domain names are staying ascii, and they're
>> just adding something on top to allow encoding unicode using ascii,
>> which may optionally be used by applications.
>
> There is a mechanism that provides an ASCII-ized version of domain names 
> that may contain non-ASCII characters, expressly for applications that 
> need to perform DNS queries but can't be easily converted to handle 
> double-byte character strings.  This can be adapted for statd, though I'm 
> not sure if the converted ASCII version of such names specifically 
> exclude '/'.
>
> Internationalized domain names themselves are still expressed in UTF16, 
> as far as I understand it.

>From a quick skim of http://www.ietf.org/rfc/rfc3490.txt, it appears to
me that protocols (at the very least, any preexisting protocols) are all
expected to use the ascii representation on the wire, and that the
translation to unicode is meant by use for applications.

So in our case we'd continue to expect ascii domain names on the wire,
and I believe that's also what we should store in any database.  But if
someone were to write a gui administrative interface to that data, for
example, they might choose to use idna for display.

--b.

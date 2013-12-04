Return-Path: linux-nfs-owner@vger.kernel.org
Received: from userp1040.oracle.com ([156.151.31.81]:39037 "EHLO
	userp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753578Ab3LDS1o convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 4 Dec 2013 13:27:44 -0500
Content-Type: text/plain; charset=us-ascii
Mime-Version: 1.0 (Mac OS X Mail 6.6 \(1510\))
Subject: Re: librpcsecgss: FTBFS on GNU/kFreeBSD
From: Chuck Lever <chuck.lever@oracle.com>
In-Reply-To: <20131204182459.GA17791@fieldses.org>
Date: Wed, 4 Dec 2013 13:27:09 -0500
Cc: Christoph Hellwig <hch@infradead.org>, Jim Rees <rees@umich.edu>,
        linux-nfs@vger.kernel.org
Message-Id: <4C06C10A-3AEC-4A91-9198-B9DBBA544A3A@oracle.com>
References: <20090703133142.14887.33854.reportbug@localhost.localdomain> <20131124051904.GA16651@master.debian.org> <20131124090924.GA29659@infradead.org> <20131124130753.GA15178@umich.edu> <20131204131317.GA7776@infradead.org> <20131204182459.GA17791@fieldses.org>
To: "J. Bruce Fields" <bfields@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


On Dec 4, 2013, at 1:24 PM, "J. Bruce Fields" <bfields@fieldses.org> wrote:

> On Wed, Dec 04, 2013 at 05:13:17AM -0800, Christoph Hellwig wrote:
>> Btw, looks like librpcsecgss is indeed pretty much unmaintained.  The
>> last upstream release is a tarball drop from CITI in 2009 and there
>> doesn't appear to be a source repository of any kind.
> 
> Well, there is this:
> 
> 	git://git.linux-nfs.org/projects/kwc/librpcsecgss.git
> 
> which was probably the source of the tarball?

nfs-utils-lib.spec (Fedora) has this:

Source1: http://www.citi.umich.edu/projects/nfsv4/linux/librpcsecgss/%{librpcsecgss}-%{rpcsecgssvers}.tar.gz



> --b.
> 
>> 
>> I think the best idea would be to merge it into the libtirpc repo,
>> as both the heritage and usage of the codebases is the same.
>> 
>> --
>> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
>> the body of a message to majordomo@vger.kernel.org
>> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

--
Chuck Lever
chuck[dot]lever[at]oracle[dot]com




Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx11.netapp.com ([216.240.18.76]:43117 "EHLO mx11.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750833Ab3KARFK convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 1 Nov 2013 13:05:10 -0400
From: "Myklebust, Trond" <Trond.Myklebust@netapp.com>
To: Jeff Layton <jlayton@redhat.com>
CC: "Myklebust, Trond" <Trond.Myklebust@netapp.com>,
        "cye@redhat.com" <cye@redhat.com>,
        "dpquigl@davequigley.com" <dpquigl@davequigley.com>,
        "Linux NFS Mailing List" <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH] nfs: fix oops when trying to set SELinux label
Date: Fri, 1 Nov 2013 17:05:08 +0000
Message-ID: <A1A30425-FA21-4D8B-ABB4-F7E02C2D5DEA@netapp.com>
References: <1383317372-3373-1-git-send-email-jlayton@redhat.com>
 <20131101120211.586aef7a@corrin.poochiereds.net>
 <1383324599.2911.2.camel@leira.trondhjem.org>
 <20131101125719.38843cfb@tlielax.poochiereds.net>
In-Reply-To: <20131101125719.38843cfb@tlielax.poochiereds.net>
Content-Type: text/plain; charset="Windows-1252"
MIME-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


On Nov 1, 2013, at 12:57, Jeff Layton <jlayton@redhat.com> wrote:

> On Fri, 1 Nov 2013 16:50:00 +0000
> "Myklebust, Trond" <Trond.Myklebust@netapp.com> wrote:
> 
>> On Fri, 2013-11-01 at 12:02 -0400, Jeff Layton wrote:
>>> It looks like _nfs4_get_security_label() has the same problem, but I've
>>> so far been unable to get it to be called, so I didn't patch it. It
>>> seems like getxattr does some special stuff for SELinux labels that
>>> cause them only to ever be fetched once.
>>> 
>>> Is there some trick to it?
>>> 
>> 
>> Doesn't 'ls -Z' cause them to security label to be read again?
>> 
> 
> As best I can tell, security labels are set on the inode when the inode
> is instantiated, and then are reset on changes (i.e. setxattr). If

…and on getxattr, afaics.

> another client changes the label though, it's not clear to me how your
> client would ever notice it until the inode is dropped from the cache.
> 
> ISTR Eric Paris explaining to me that they do that for performance
> reasons but it seems like something that needs to be reconsidered in
> light of labeled NFS. Not picking up a security label change seems like
> a bug, IMO...

To be effective, the security label should normally be set at file creation time. It should rarely, if ever, change. Why would you need to change it from a different client?

Cheers,
  Trond
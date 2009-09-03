From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: POSIX ACL support for NFSV4 (using sideband protocol)
Date: Thu, 3 Sep 2009 12:08:45 -0400
Message-ID: <20090903160845.GF8270@fieldses.org>
References: <524f69650909021156lf181c17uf800eba7c35a6f45@mail.gmail.com> <20090902202206.GJ17884@fieldses.org> <524f69650909021353o1e055cbema16495c57cb9909b@mail.gmail.com> <4A9F6027.9050807@s3group.cz> <524f69650909030654u7653d410kd5cde25ec223a87@mail.gmail.com> <20090903135516.GB4566@fieldses.org> <524f69650909030835s41e78436p4b67594cf91de639@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Ondrej Valousek <webserv-K2D8ygZuxnnrBKCeMvbIDA@public.gmane.org>, linux-nfs@vger.kernel.org,
	nfsv4@linux-nfs.org, Trond Myklebust <Trond.Myklebust@netapp.com>,
	ffilzlnx@linux.vnet.ibm.com, jra@samba.org, agruen@suse.de
To: Steve French <smfrench@gmail.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([174.143.236.118]:36042 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754566AbZICQIp (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 3 Sep 2009 12:08:45 -0400
In-Reply-To: <524f69650909030835s41e78436p4b67594cf91de639-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, Sep 03, 2009 at 10:35:35AM -0500, Steve French wrote:
> On Thu, Sep 3, 2009 at 8:55 AM, J. Bruce Fields<bfields@fieldses.org> wrote:
> > On Thu, Sep 03, 2009 at 08:54:06AM -0500, Steve French wrote:
> >> if someone were able to convince the linux-fsdevel community to change
> >> fs/posix_acls.c
> >> (or add an fs/cifs_acls.c) to handle NFSv4/CIFS/NTFS ACL evaluation, and add
> >> support to store these richer ACLs on disk for the future (e.g. for
> >> btrfs), that would be
> >> great - but with no local file system in kernel which can store NFSv4 ACLs and
> >> no code to evaluate these ACLs in the VFS and with a NACK from fsdevel when
> >
> > I don't remember that--do you have a pointer?
> 
> Aneesh mentioned one strongly worded objection (I remember more resistance
> from others too)
> 
> http://kerneltrap.org/mailarchive/linux-fsdevel/2006/6/24/313526

Yes, Christoph's always been vehemently opposed.  I share his distaste
for NFSv4/NT ACLs, but I agree with Trond that a solid implementation
with a demonstrated need from CIFS, NFSv4, NTFS, etc., would be likely
to overcome such objections.

--b.

Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:49773 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751729Ab2JAPnL (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 1 Oct 2012 11:43:11 -0400
Date: Mon, 1 Oct 2012 11:43:10 -0400
To: NeilBrown <neilb@suse.de>
Cc: NFS <linux-nfs@vger.kernel.org>
Subject: Re: Inconsistency when mounting a directory that 'world' cannot
 access.
Message-ID: <20121001154309.GD18400@fieldses.org>
References: <20120918112329.7d88ed9e@notabene.brown>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20120918112329.7d88ed9e@notabene.brown>
From: "J. Bruce Fields" <bfields@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, Sep 18, 2012 at 11:23:29AM +1000, NeilBrown wrote:
> 
> Suppose that on an NFS server I have a directory
>    /foo/bar/baz
> 
> which I export, and that /foo/bar does not have world access.  e.g.
> permissions are '750' and everyone who owns files in there is a member of the
> group which owns /foo/bar.
> 
> Then with NFSv3 I can
>   mount server:/foo/bar/baz  /somewhere
> because the lookup of /foo/bar/baz happens as root on the server in mountd.
> 
> With NFSv4 using 'sec=sys' I can only do this if I export with
> "no_root_squash", as the lookup happens on the client as root, and if root
> were squashed, it wouldn't have access beyond /foo/bar.
> 
> But if I use NFSv4 using 'sec=krb5', the lookup happens on the client using a
> machine credential which gets mapped to 'nobody/nogroup' (or whatever anonuid
> and anongid are set to for the export).  So I cannot perform the mount at all.
> 
> This is - at best - inconsistent and can cause confusion (hey - I was
> confused for a while there).
> 
> Should something be done?  Can anything be done?

I think nfsd_lookup_dentry() would need a special exception for the
NFSEXP_V4ROOT case.

Looks like the directory permission check is actually done in
lookup_one_len(), so we'd need to either call something else or
temporarily swap credentials?

--b.

> 
> I lean towards thinking that the most restrictive behaviour is most correct
> (though I have a customer who feels that it is too restrictive).
> 
> Should the NFSv4 client always use an anon credential when performing the
> 'mount'?  Is that even possible for auth_sys?
> Should rpc.mountd use set_fsuid before doing the path lookup to ensure that
> everyone has access to the exported directory?
> 
> Or is there some way 'mount' lookups for krb5 could be treated as being
> performed by root?
> 
> Any ideas?

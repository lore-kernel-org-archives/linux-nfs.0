Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:38005 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751174Ab3JDUUk (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 4 Oct 2013 16:20:40 -0400
Date: Fri, 4 Oct 2013 16:20:33 -0400
From: "J. Bruce Fields" <bfields@fieldses.org>
To: David Quigley <selinux@davequigley.com>
Cc: Daniel J Walsh <dwalsh@redhat.com>, Stephen Smalley <sds@tycho.nsa.gov>,
        Eric Paris <eparis@redhat.com>, Steve Dickson <SteveD@redhat.com>,
        linux-nfs@vger.kernel.org
Subject: Re: Hey we are seeing a big problem with Labeled NFS
Message-ID: <20131004202033.GB18051@fieldses.org>
References: <524EB4C2.6070804@redhat.com>
 <a72f70f2dce1409f383d634c06b17b40@countercultured.net>
 <20131004143549.GC1577@fieldses.org>
 <46df4f789cbeb203d1355adbd3a346c6@countercultured.net>
 <20131004150505.GD1577@fieldses.org>
 <7392559a27900ee1dfe69ebbe0fd468e@countercultured.net>
 <20131004152944.GE1577@fieldses.org>
 <cc6c106aa0b1ead440ff70a2ca002f69@countercultured.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <cc6c106aa0b1ead440ff70a2ca002f69@countercultured.net>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, Oct 04, 2013 at 11:39:54AM -0400, David Quigley wrote:
> ( Adding linux-nfs to the list of people)
> 
> Here is a summary of the discussion so far.
> 
> Dan Walsh is seeing issues with Labeled NFS. The issue he is seeing
> is that a label change on the server is not reflected on the client
> until a remount of the client. There should be a delay in the label
> change being reflected in the client as we don't yet have the label
> change notification in. However it should only be until the cache
> for the file attribute is invalidated and the next getfattr call
> revalidates the label. It is unclear why a remount is needed at this
> time.
> 
> Bruce has expressed the concern that the label change notification
> was not designed for this particular use case and the
> protocol/implementation may need to be reworked.
> 
> My understanding of the usecases discussed for Labeled NFS have
> sVirt and NFS mounted home. Both of which will make label changes
> quite often. Part of SVirt is support in libvirt to change the
> category fields on the vm images to match that of the starting qemu
> process. This gives the process separation that just using types
> alone would make difficult. For home directories labels may change
> all the time from a client perspective if another client is
> modifying file labels. I think what we conveyed a while back (I
> don't remember the conversation) is that a whole sale relabel of the
> server from underneath the clients is unlikely to happen. However
> there is definitely a real use case where client A modifies the
> label on a file and Client B needs to see that. Without having full
> support where the server enforces policy we're relying on the client
> to enforce those policies which they can't reliably do without
> knowing about the label change. One thing we had discussed in the
> past though is that the cache timeout could be sufficient in the
> situation where we lack the label change notification under the
> assumption that if the file was opened with that label at least for
> that short time it should still be ok for it to still read/write to
> that file. There are situations where that is not ideal though. Its
> not clear to me why the client is requiring a remount to get the
> label change though. Upon cache invalidation another getfattr call
> for the label should be sent and it should pull it back.

I haven't actually checked, but I suspect we need to implement the
label_change attribute (on both client and server) before that works
well.

--b.

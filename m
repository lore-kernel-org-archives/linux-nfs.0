Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:52484 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752429AbdIAVTU (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Fri, 1 Sep 2017 17:19:20 -0400
Date: Fri, 1 Sep 2017 17:19:19 -0400
From: "J. Bruce Fields" <bfields@redhat.com>
To: Olga Kornievskaia <kolga@netapp.com>
Cc: Olga Kornievskaia <aglo@umich.edu>,
        linux-nfs <linux-nfs@vger.kernel.org>
Subject: Re: [RFC v1 00/17] NFSD support for inter+async COPY
Message-ID: <20170901211918.GD2743@parsley.fieldses.org>
References: <20170302160142.30413-1-kolga@netapp.com>
 <20170901194130.GA27922@parsley.fieldses.org>
 <CAN-5tyGfQu15gPCKy0k=63BHC7tctPi-ebwR0tw9QgJzfLNOYw@mail.gmail.com>
 <20170901195345.GD27922@parsley.fieldses.org>
 <CDD9BC3A-0E15-45B2-8094-A8266EAD432C@netapp.com>
 <20170901200922.GA2743@parsley.fieldses.org>
 <956F5336-01C8-402C-B59C-E94761A8BB90@netapp.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
In-Reply-To: <956F5336-01C8-402C-B59C-E94761A8BB90@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, Sep 01, 2017 at 04:34:16PM -0400, Olga Kornievskaia wrote:
> 
> > On Sep 1, 2017, at 4:09 PM, J. Bruce Fields <bfields@redhat.com> wrote:
> > 
> > On Fri, Sep 01, 2017 at 04:02:48PM -0400, Olga Kornievskaia wrote:
> >> 
> >>> On Sep 1, 2017, at 3:53 PM, J. Bruce Fields <bfields@redhat.com> wrote:
> >>> 
> >>> On Fri, Sep 01, 2017 at 03:48:33PM -0400, Olga Kornievskaia wrote:
> >>>> On Fri, Sep 1, 2017 at 3:41 PM, J. Bruce Fields <bfields@redhat.com> wrote:
> >>>>>       - what currently happens if you try to copy across krb5 mounts?
> >>>> 
> >>>> No GSSv3 is included in these patches.  The destination server will
> >>>> mount the source server using auth_sys.
> >>> 
> >>> Assuming that doesn't work--how is the failure handled?
> >> 
> >> If mount fails? Destination server returns an error in COPY (whatever
> >> vfs_kern_mount can return). Client calls generic nfs4_handle_exception() 
> >> but it’s probably a kind of error it doesn’t handle so it’ll be translated to EIO. 
> >> What kind of error are you thinking about?
> > 
> > I just want to make sure that copy_file_range() caller knows what to do
> > when it encounters this situation.
> > 
> > The typical application probably wants to fall back on a read-write loop
> > in the case inter-server copy isn't supported between the given mounts?
> > 
> > EIO doesn't sound like the most helpful error to me, but whatever error
> > it is, it should be documented in the copy_file_range man page so that
> > callers know how to check for this case.
> 
> On the client side, if we were to receive an error code that signified a connection 
> problem, then COPY implementation could map that to something that would
> trigger the VFS to just fallback to do_splice. 

Oh, right.

> However, I couldn’t find any errors in 15.1 from rfc5661 or 11.1 from 7862 that
> could mean connection errors (that’s typically RPC errors right). 

Looking at 7862....  Shouldn't these sorts of cases result in one of the
new errors described in
https://tools.ietf.org/html/rfc7862#section-11.1.2 ?

--b.

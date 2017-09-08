Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([173.255.197.46]:34988 "EHLO fieldses.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751941AbdIHPGQ (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Fri, 8 Sep 2017 11:06:16 -0400
Date: Fri, 8 Sep 2017 11:06:16 -0400
To: NeilBrown <neilb@suse.com>
Cc: "J. Bruce Fields" <bfields@redhat.com>, linux-nfs@vger.kernel.org,
        linux-fsdevel@vger.kernel.org,
        Trond Myklebust <trond.myklebust@primarydata.com>
Subject: Re: [PATCH 2/3] fs: hide another detail of delegation logic
Message-ID: <20170908150616.GB17817@fieldses.org>
References: <20170830170938.GC24373@parsley.fieldses.org>
 <87wp5kfxi3.fsf@notabene.neil.brown.name>
 <20170831190531.GA8223@parsley.fieldses.org>
 <873787fhc5.fsf@notabene.neil.brown.name>
 <20170901161809.GA22140@parsley.fieldses.org>
 <871snndq04.fsf@notabene.neil.brown.name>
 <20170905195619.GB17828@parsley.fieldses.org>
 <877excde18.fsf@notabene.neil.brown.name>
 <20170906160342.GB28077@parsley.fieldses.org>
 <87tw0fbaoe.fsf@notabene.neil.brown.name>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <87tw0fbaoe.fsf@notabene.neil.brown.name>
From: bfields@fieldses.org (J. Bruce Fields)
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, Sep 07, 2017 at 10:43:29AM +1000, NeilBrown wrote:
> 
> >> +		host_err = nfsd_conflicting_leases(dentry, rqstp);
> >> +		host_err = host_err ?: notify_change(dentry, &size_attr, nfsd_deleg_owner, NULL);
> >
> > And then you recall nfsd delegations and delegations held by
> > (hypothetical) non-nfsd users separately, OK (also ignoring how).
> >
> > There are no such users currently, so nfsd could just pass NULL.
> 
> I don't think so.  If we pass NULL (as the owner), when VFS will recall
> the one nfsd delegation that we want to preserve. ???

Oops, right.--b.

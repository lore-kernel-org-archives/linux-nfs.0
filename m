Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([173.255.197.46]:54050 "EHLO fieldses.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S967470AbdIZNmk (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Tue, 26 Sep 2017 09:42:40 -0400
Date: Tue, 26 Sep 2017 09:42:39 -0400
From: "J. Bruce Fields" <bfields@fieldses.org>
To: NeilBrown <neilb@suse.com>
Cc: "Daniel P. Berrange" <berrange@redhat.com>,
        Chuck Lever <chuck.lever@oracle.com>,
        Steven Whitehouse <swhiteho@redhat.com>,
        Stefan Hajnoczi <stefanha@redhat.com>,
        Steve Dickson <SteveD@redhat.com>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>,
        Matt Benjamin <mbenjami@redhat.com>,
        Jeff Layton <jlayton@redhat.com>,
        Justin Mitchell <jumitche@redhat.com>
Subject: Re: [PATCH nfs-utils v3 00/14] add NFS over AF_VSOCK support
Message-ID: <20170926134239.GC25286@fieldses.org>
References: <3534278B-FC7B-4AA5-AF86-92AA19BFD1DC@oracle.com>
 <20170919164427.GV9536@redhat.com>
 <20170919172452.GB29104@fieldses.org>
 <20170921170017.GK32364@stefanha-x1.localdomain>
 <d760ecdc-988d-8145-f816-6faf8f2abf03@redhat.com>
 <E5B4D2FF-0DB4-417D-998A-6BBFC36C35C5@oracle.com>
 <20170922115524.GN12725@redhat.com>
 <87efqu6wl4.fsf@notabene.neil.brown.name>
 <20170926034026.GA19283@fieldses.org>
 <20170926133949.GB25286@fieldses.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20170926133949.GB25286@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

By the way, do we know anything about likely performance of NFS/VSOCK?

--b.

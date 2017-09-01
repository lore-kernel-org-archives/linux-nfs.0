Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:56360 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752148AbdIATxr (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Fri, 1 Sep 2017 15:53:47 -0400
Date: Fri, 1 Sep 2017 15:53:46 -0400
From: "J. Bruce Fields" <bfields@redhat.com>
To: Olga Kornievskaia <aglo@umich.edu>
Cc: Olga Kornievskaia <kolga@netapp.com>,
        linux-nfs <linux-nfs@vger.kernel.org>
Subject: Re: [RFC v1 00/17] NFSD support for inter+async COPY
Message-ID: <20170901195345.GD27922@parsley.fieldses.org>
References: <20170302160142.30413-1-kolga@netapp.com>
 <20170901194130.GA27922@parsley.fieldses.org>
 <CAN-5tyGfQu15gPCKy0k=63BHC7tctPi-ebwR0tw9QgJzfLNOYw@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <CAN-5tyGfQu15gPCKy0k=63BHC7tctPi-ebwR0tw9QgJzfLNOYw@mail.gmail.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, Sep 01, 2017 at 03:48:33PM -0400, Olga Kornievskaia wrote:
> On Fri, Sep 1, 2017 at 3:41 PM, J. Bruce Fields <bfields@redhat.com> wrote:
> >         - what currently happens if you try to copy across krb5 mounts?
> 
> No GSSv3 is included in these patches.  The destination server will
> mount the source server using auth_sys.

Assuming that doesn't work--how is the failure handled?

--b.

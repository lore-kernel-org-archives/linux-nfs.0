Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx0a-001b2d01.pphosted.com ([148.163.156.1]:49990 "EHLO
        mx0a-001b2d01.pphosted.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S934279AbeFMKER (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Wed, 13 Jun 2018 06:04:17 -0400
Received: from pps.filterd (m0098410.ppops.net [127.0.0.1])
        by mx0a-001b2d01.pphosted.com (8.16.0.22/8.16.0.22) with SMTP id w5D9x1sn116014
        for <linux-nfs@vger.kernel.org>; Wed, 13 Jun 2018 06:04:17 -0400
Received: from e11.ny.us.ibm.com (e11.ny.us.ibm.com [129.33.205.201])
        by mx0a-001b2d01.pphosted.com with ESMTP id 2jjwt0h7sc-1
        (version=TLSv1.2 cipher=AES256-GCM-SHA384 bits=256 verify=NOT)
        for <linux-nfs@vger.kernel.org>; Wed, 13 Jun 2018 06:04:17 -0400
Received: from localhost
        by e11.ny.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
        for <linux-nfs@vger.kernel.org> from <paulmck@linux.vnet.ibm.com>;
        Wed, 13 Jun 2018 06:04:15 -0400
Date: Wed, 13 Jun 2018 03:06:07 -0700
From: "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>
To: NeilBrown <neilb@suse.com>
Cc: Linus Torvalds <torvalds@linux-foundation.org>,
        trondmy@hammerspace.com,
        Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Subject: Re: [GIT PULL] Please pull NFS client changes for 4.18
Reply-To: paulmck@linux.vnet.ibm.com
References: <e5c90488937d14e9df81752a024be9d1e73ed398.camel@hammerspace.com>
 <CA+55aFxYMg+F9Jdi_25X-Qtt=7imqjQhLnjEyQXOQ6+eJvy83A@mail.gmail.com>
 <CA+55aFw+2+xCRAaMo8qgvZ7qNgRMo6D=WkwP7APQndG-y5b3dw@mail.gmail.com>
 <CA+55aFz3jmGST_cOB+qH6qZTFa5HJcw2JoeWxJEZdWgeO4=vNQ@mail.gmail.com>
 <20180613010427.GD3593@linux.vnet.ibm.com>
 <CA+55aFyWS-MC44k=LnGWr-Kq4_DRkJmub00Fj-tVrGxCL-PxGA@mail.gmail.com>
 <20180613013914.GE3593@linux.vnet.ibm.com>
 <87muvzihr8.fsf@notabene.neil.brown.name>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <87muvzihr8.fsf@notabene.neil.brown.name>
Message-Id: <20180613100607.GH3593@linux.vnet.ibm.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, Jun 13, 2018 at 11:42:51AM +1000, NeilBrown wrote:
> On Tue, Jun 12 2018, Paul E. McKenney wrote:
> 
> > On Tue, Jun 12, 2018 at 06:11:50PM -0700, Linus Torvalds wrote:
> >> On Tue, Jun 12, 2018 at 6:02 PM Paul E. McKenney
> >> <paulmck@linux.vnet.ibm.com> wrote:
> >> >
> >> > We did review this one, and Neil did make requested changes to the comment
> >> > header and documentation.
> >> 
> >> Oh, I checked the commit for "acked-by" from you and didn't see any,
> >> so I was assuming this was just Neil and Trond on their own..
> >
> > Hmmm...  I gave them a Reviewed-by, but perhaps it got lost.
> >
> > http://lkml.kernel.org/r/20180501141404.GD26088@linux.vnet.ibm.com
> 
> Sorry about that.  I think I planned to add it after I heard back from
> Trond what he thought of the patch, but I didn't hear anything until it
> landed.  I'll try to be more proactive next time.

Not a problem from my viewpoint.  There may come a time when I need to
care about contribution metrics, but I don't need to at the moment.  ;-)

							Thanx, Paul


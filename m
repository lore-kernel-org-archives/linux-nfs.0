Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx0a-001b2d01.pphosted.com ([148.163.156.1]:32958 "EHLO
        mx0a-001b2d01.pphosted.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1752901AbeFTPbL (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Wed, 20 Jun 2018 11:31:11 -0400
Received: from pps.filterd (m0098394.ppops.net [127.0.0.1])
        by mx0a-001b2d01.pphosted.com (8.16.0.22/8.16.0.22) with SMTP id w5KFOkZd010510
        for <linux-nfs@vger.kernel.org>; Wed, 20 Jun 2018 11:31:11 -0400
Received: from e11.ny.us.ibm.com (e11.ny.us.ibm.com [129.33.205.201])
        by mx0a-001b2d01.pphosted.com with ESMTP id 2jqr2qcth2-1
        (version=TLSv1.2 cipher=AES256-GCM-SHA384 bits=256 verify=NOT)
        for <linux-nfs@vger.kernel.org>; Wed, 20 Jun 2018 11:31:11 -0400
Received: from localhost
        by e11.ny.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
        for <linux-nfs@vger.kernel.org> from <paulmck@linux.vnet.ibm.com>;
        Wed, 20 Jun 2018 11:31:10 -0400
Date: Wed, 20 Jun 2018 08:33:07 -0700
From: "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>
To: NeilBrown <neilb@suse.com>
Cc: Linus Torvalds <torvalds@linux-foundation.org>,
        trondmy@hammerspace.com,
        Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH] rculist: improve documentation for
 list_for_each_entry_from_rcu()
Reply-To: paulmck@linux.vnet.ibm.com
References: <CA+55aFxYMg+F9Jdi_25X-Qtt=7imqjQhLnjEyQXOQ6+eJvy83A@mail.gmail.com>
 <CA+55aFw+2+xCRAaMo8qgvZ7qNgRMo6D=WkwP7APQndG-y5b3dw@mail.gmail.com>
 <CA+55aFz3jmGST_cOB+qH6qZTFa5HJcw2JoeWxJEZdWgeO4=vNQ@mail.gmail.com>
 <20180613010427.GD3593@linux.vnet.ibm.com>
 <CA+55aFyWS-MC44k=LnGWr-Kq4_DRkJmub00Fj-tVrGxCL-PxGA@mail.gmail.com>
 <20180613013914.GE3593@linux.vnet.ibm.com>
 <87muvzihr8.fsf@notabene.neil.brown.name>
 <20180613100607.GH3593@linux.vnet.ibm.com>
 <874li0g1v3.fsf@notabene.neil.brown.name>
 <20180618170111.GB3593@linux.vnet.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20180618170111.GB3593@linux.vnet.ibm.com>
Message-Id: <20180620153306.GA18484@linux.vnet.ibm.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, Jun 18, 2018 at 10:01:11AM -0700, Paul E. McKenney wrote:
> On Mon, Jun 18, 2018 at 02:22:40PM +1000, NeilBrown wrote:
> > 
> > Unfortunately the patch for adding list_for_each_entry_from_rcu()
> > wasn't the final patch after all review.  It is functionally
> > correct but the documentation was incomplete.
> > 
> > This patch adds this missing documentation which includes an update to
> > the documentation for list_for_each_entry_continue_rcu() to match the
> > documentation for the new list_for_each_entry_from_rcu(), and adds
> > list_for_each_entry_from_rcu() and the already existing
> > hlist_for_each_entry_from_rcu() to section 7 of whatisRCU.txt.
> > 
> > Reviewed-by: Paul E. McKenney <paulmck@linux.vnet.ibm.com>
> > Signed-off-by: NeilBrown <neilb@suse.com>
> 
> Once I rebase my commits to v4.18-rc1, I will apply this, thank you!
> 
> (If you were wanting something else to happen with this patch, please
> let me know.)

And hearing no objections, I have applied it.

							Thanx, Paul


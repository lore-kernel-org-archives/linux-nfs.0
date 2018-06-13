Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx0a-001b2d01.pphosted.com ([148.163.156.1]:52698 "EHLO
        mx0a-001b2d01.pphosted.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S935013AbeFMBCg (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Tue, 12 Jun 2018 21:02:36 -0400
Received: from pps.filterd (m0098410.ppops.net [127.0.0.1])
        by mx0a-001b2d01.pphosted.com (8.16.0.22/8.16.0.22) with SMTP id w5D0s4Be090997
        for <linux-nfs@vger.kernel.org>; Tue, 12 Jun 2018 21:02:36 -0400
Received: from e16.ny.us.ibm.com (e16.ny.us.ibm.com [129.33.205.206])
        by mx0a-001b2d01.pphosted.com with ESMTP id 2jjpc6nhva-1
        (version=TLSv1.2 cipher=AES256-GCM-SHA384 bits=256 verify=NOT)
        for <linux-nfs@vger.kernel.org>; Tue, 12 Jun 2018 21:02:35 -0400
Received: from localhost
        by e16.ny.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
        for <linux-nfs@vger.kernel.org> from <paulmck@linux.vnet.ibm.com>;
        Tue, 12 Jun 2018 21:02:34 -0400
Date: Tue, 12 Jun 2018 18:04:27 -0700
From: "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: trondmy@hammerspace.com, NeilBrown <neilb@suse.com>,
        Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Subject: Re: [GIT PULL] Please pull NFS client changes for 4.18
Reply-To: paulmck@linux.vnet.ibm.com
References: <e5c90488937d14e9df81752a024be9d1e73ed398.camel@hammerspace.com>
 <CA+55aFxYMg+F9Jdi_25X-Qtt=7imqjQhLnjEyQXOQ6+eJvy83A@mail.gmail.com>
 <CA+55aFw+2+xCRAaMo8qgvZ7qNgRMo6D=WkwP7APQndG-y5b3dw@mail.gmail.com>
 <CA+55aFz3jmGST_cOB+qH6qZTFa5HJcw2JoeWxJEZdWgeO4=vNQ@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <CA+55aFz3jmGST_cOB+qH6qZTFa5HJcw2JoeWxJEZdWgeO4=vNQ@mail.gmail.com>
Message-Id: <20180613010427.GD3593@linux.vnet.ibm.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, Jun 12, 2018 at 11:08:31AM -0700, Linus Torvalds wrote:
> Final note (for now) on this: I've merged the nfs code, but I really
> am obviously not happy with these crazy random ad-hoc
> cursor-not-cursor list games.

We did review this one, and Neil did make requested changes to the comment
header and documentation.  However, as you say, I will push back harder
on future RCU list traversal macros.

							Thanx, Paul


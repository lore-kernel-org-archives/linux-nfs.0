Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:42828 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1750917AbdEKH1u (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Thu, 11 May 2017 03:27:50 -0400
Date: Thu, 11 May 2017 15:27:47 +0800
From: Eryu Guan <eguan@redhat.com>
To: Anna Schumaker <Anna.Schumaker@Netapp.com>
Cc: "Darrick J. Wong" <darrick.wong@oracle.com>,
        fstests@vger.kernel.org, linux-nfs@vger.kernel.org,
        hch@infradead.org
Subject: Re: [PATCH v6 4/5] generic/432: Add a copy test for overwriting
 small amounts of data
Message-ID: <20170511072747.GH7250@eguan.usersys.redhat.com>
References: <20170510174628.22895-1-Anna.Schumaker@Netapp.com>
 <20170510174628.22895-5-Anna.Schumaker@Netapp.com>
 <20170510183745.GE5970@birch.djwong.org>
 <658f2572-9767-3dd7-c48e-9cb8f2b28510@Netapp.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <658f2572-9767-3dd7-c48e-9cb8f2b28510@Netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, May 10, 2017 at 02:39:46PM -0400, Anna Schumaker wrote:
> 
> 
> On 05/10/2017 02:37 PM, Darrick J. Wong wrote:
> > On Wed, May 10, 2017 at 01:46:27PM -0400, Anna Schumaker wrote:
> >> This test is similar to 345, except that it copies one byte at a time to
> > 
> > 345?  Or is that now 431?  Perhaps amend the commit message to "This
> > test is similar to the previous one, except..."?
> 
> Yeah, I forgot to update that :(   It's supposed to be for the previous test, so that's probably the best wording to use.

I can fix it at commit time. Thanks for the tests! And thanks Darrick
for reviewing!

BTW, seq number should be dropped in summary line too, tests are always
re-numberd on commit anyway, "generic: Add copy to new file test" should
be fine :)

Thanks,
Eryu

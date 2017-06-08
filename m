Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:43930 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751416AbdFHUfv (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Thu, 8 Jun 2017 16:35:51 -0400
Subject: Re: [PATCH 3/3] nfs.conf tidy ups
To: NeilBrown <neilb@suse.com>, Justin Mitchell <jumitche@redhat.com>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
References: <1495468363.4169.13.camel@redhat.com>
 <87shjcbige.fsf@notabene.neil.brown.name>
From: Steve Dickson <SteveD@RedHat.com>
Message-ID: <214aadb1-6dc7-3b8f-f870-b641149bdf31@RedHat.com>
Date: Thu, 8 Jun 2017 16:35:50 -0400
MIME-Version: 1.0
In-Reply-To: <87shjcbige.fsf@notabene.neil.brown.name>
Content-Type: text/plain; charset=utf-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Justin,

On 06/06/2017 11:11 PM, NeilBrown wrote:
> On Mon, May 22 2017, Justin Mitchell wrote:
> 
>> Remove the line length parameter and associated code which
>> led to buffer overruns in the line parsing code.
>> Also drops the undocumented 'include' directive.
> 
> No, please don't drop the "include" directive.
> It was there for a reason.  See commit  be38fd8b8011c6bd.
> 
> Yes, it should be documented.  I'm happy to provide documentation.  But
> please do remove things without first understanding why they are there.
Would you mind posting a patch that adds this back?

steved.

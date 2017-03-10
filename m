Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([173.255.197.46]:60504 "EHLO fieldses.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S932908AbdCJQhA (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Fri, 10 Mar 2017 11:37:00 -0500
Date: Fri, 10 Mar 2017 11:36:59 -0500
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Andy Adamson <androsadamson@gmail.com>
Cc: Trond Myklebust <trond.myklebust@primarydata.com>,
        Anna Schumaker <schumaker.anna@gmail.com>,
        NFS list <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH Version 5 00/17] RPCSEC_GSS3 full mode label kernel patch
 set
Message-ID: <20170310163659.GB29791@fieldses.org>
References: <20170224221953.5502-1-andros@netapp.com>
 <20170309214717.GB12553@fieldses.org>
 <CAHVgHyXr-Amc9vHq+YxL__3jv8xNaZFnAg0RCAFvQMW6GKLSDA@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <CAHVgHyXr-Amc9vHq+YxL__3jv8xNaZFnAg0RCAFvQMW6GKLSDA@mail.gmail.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, Mar 10, 2017 at 09:48:23AM -0500, Andy Adamson wrote:
> On Thu, Mar 9, 2017 at 4:47 PM, J. Bruce Fields <bfields@fieldses.org> wrote:
> > On Fri, Feb 24, 2017 at 05:19:36PM -0500, andros@netapp.com wrote:
> >> From: Andy Adamson <andros@netapp.com>
> >>
> >> This patchset implements RFC 7861  RPCSEC_GSS Version 3 RPCSEC_GSS_CREATE
> >> operation with rgs3_label payloads to provide  full mode Mandatory Access
> >> Control (MAC) when run with NFSv4.2 Labeled NFS using SeLinux.
> >
> > Is GSSv3 also still planned to be used for COPY?  I lost track of that
> > discussion.
> 
> 
> Yes. I'm starting on that now.

Great, thanks.

Also:  do you know if there are any other implementations coming?  And
is wireshark support on the way?

--b.

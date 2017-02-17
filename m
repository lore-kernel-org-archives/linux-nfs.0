Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([173.255.197.46]:33366 "EHLO fieldses.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1754788AbdBQTJ3 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Fri, 17 Feb 2017 14:09:29 -0500
Date: Fri, 17 Feb 2017 14:09:26 -0500
From: "bfields@fieldses.org" <bfields@fieldses.org>
To: Trond Myklebust <trondmy@primarydata.com>
Cc: "kinglongmee@gmail.com" <kinglongmee@gmail.com>,
        "Anna.Schumaker@netapp.com" <Anna.Schumaker@netapp.com>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH 0/7] Some cleanups and updates for sunrpc
Message-ID: <20170217190926.GC10894@fieldses.org>
References: <59432847-8e45-4423-c441-0c67ee645f38@gmail.com>
 <20170217170313.GA9791@fieldses.org>
 <1487352262.11929.4.camel@primarydata.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
In-Reply-To: <1487352262.11929.4.camel@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, Feb 17, 2017 at 05:25:04PM +0000, Trond Myklebust wrote:
> On Fri, 2017-02-17 at 12:03 -0500, J. Bruce Fields wrote:
> > Thanks, these look fine to me.
> > 
> > It's really a mixture of client- and server- side stuff, but seems
> > unlikely to have serious conflicts with either.  For simplicity's
> > sake I
> > think I'll just take them, unless Trond tells me he has.
> > 
> 
> Anna is managing the merge window for the odd-numbered kernel releases
> (Cced).

Got it, thanks.  Anna, I've currently got this queued up in my tree, but
let me know if that's a problem.

(This every-other-kernel scheme would be easier for me to remember if
only one of you was clearly odder than the other.  But I think you're
about equally odd.)

--b.

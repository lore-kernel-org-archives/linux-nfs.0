From: "Chuck Lever" <chuck.lever@oracle.com>
Subject: Re: Performance Diagnosis
Date: Tue, 15 Jul 2008 11:49:11 -0400
Message-ID: <76bd70e30807150849j22ffd428i5e647794289a2c82@mail.gmail.com>
References: <e80abd30807150834m47a1b86cle39885150f1d5bfd@mail.gmail.com>
Reply-To: chucklever@gmail.com
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: linux-nfs@vger.kernel.org
To: "Andrew Bell" <andrew.bell.ia@gmail.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from yw-out-2324.google.com ([74.125.46.30]:27024 "EHLO
	yw-out-2324.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752722AbYGOPtV (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 15 Jul 2008 11:49:21 -0400
Received: by yw-out-2324.google.com with SMTP id 9so2613797ywe.1
        for <linux-nfs@vger.kernel.org>; Tue, 15 Jul 2008 08:49:13 -0700 (PDT)
In-Reply-To: <e80abd30807150834m47a1b86cle39885150f1d5bfd-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, Jul 15, 2008 at 11:34 AM, Andrew Bell <andrew.bell.ia@gmail.com> wrote:
> Hi,
>
> I have a RHEL 5 system that exhibits less than wonderful performance
> when copying large files from/to an NFS filesystem.  When the copy is
> taking place, other access to the filesystem is painfully slow.  I
> would like to have the filesystem react well to small requests while a
> large request is taking place.
>
> A couple of questions:
>
> Is this a reasonable expectation?

Yes, but Linux NFS can't fulfill it.  :-)

There is currently only one RPC transport socket between client and
server for each mount point.  Large file copies (or similar
operations) will queue a lot of I/O, so your small requests will take
a while to get through the queued up writes or reads ahead of them.

> Is this perhaps an I/O scheduling issue that isn't specific to NFS,
> but shows up there because of the latency of my NFS setup?
>
> Is this most likely a client issue, a server issue or a combination?

Well, if your server or network is slow, this kind of thing is more
likely to happen.

> Do you have recomendations on the best way to determine what is
> happening?  Are there existing tools to monitor active IO/NFS
> requests/responses and any relevant queues?

Yes, I wrote some Python tools that are still undocumented (ie you
will likely have to read the Python source to figure out what they
do).  They were recently included in nfs-utils, but you can download
them from:

  http://oss.oracle.com/~cel/linux-2.6/2.6.25/nfs-iostat

and

  http://oss.oracle.com/~cel/linux-2.6/2.6.25/mountstats

>
>
> Thanks for any info/ideas before I get in too deep :)
>
> --
> Andrew Bell
> andrew.bell.ia@gmail.com

-- 
Chuck Lever

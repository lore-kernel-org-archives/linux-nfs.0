From: "Chuck Lever" <chuck.lever@oracle.com>
Subject: Re: Performance Diagnosis
Date: Tue, 15 Jul 2008 12:23:58 -0400
Message-ID: <76bd70e30807150923r31027edxb0394a220bbe879b@mail.gmail.com>
References: <e80abd30807150834m47a1b86cle39885150f1d5bfd@mail.gmail.com>
	 <487CC928.8070908@redhat.com>
Reply-To: chucklever@gmail.com
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: "Andrew Bell" <andrew.bell.ia@gmail.com>, linux-nfs@vger.kernel.org
To: "Peter Staubach" <staubach@redhat.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from yw-out-2324.google.com ([74.125.46.30]:13534 "EHLO
	yw-out-2324.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752814AbYGOQYL (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 15 Jul 2008 12:24:11 -0400
Received: by yw-out-2324.google.com with SMTP id 9so2617200ywe.1
        for <linux-nfs@vger.kernel.org>; Tue, 15 Jul 2008 09:24:00 -0700 (PDT)
In-Reply-To: <487CC928.8070908@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, Jul 15, 2008 at 11:58 AM, Peter Staubach <staubach@redhat.com> wrote:
> If it is the notion described above, sometimes called head
> of line blocking, then we could think about ways to duplex
> operations over multiple TCP connections, perhaps with one
> connection for small, low latency operations, and another
> connection for larger, higher latency operations.

I've dreamed about that for years.  I don't think it would be too
difficult, but one thing that has held it back is the shortage of
ephemeral ports on the client may reduce the number of concurrent
mount points we can support.

One way to avoid the port issue is to construct an SCTP transport for
NFS.  SCTP allows multiple streams on the same connection, effectively
eliminating head of line blocking.

-- 
Chuck Lever

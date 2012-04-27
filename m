Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-qa0-f53.google.com ([209.85.216.53]:51957 "EHLO
	mail-qa0-f53.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1760341Ab2D0Qcr convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 27 Apr 2012 12:32:47 -0400
MIME-Version: 1.0
In-Reply-To: <20120427151057.GA16580@fieldses.org>
References: <20120427010610.GE9541@dastard>
	<20120419140558.17272.74360.stgit@warthog.procyon.org.uk>
	<4111.1335519545@redhat.com>
	<20120427131306.GG9541@dastard>
	<20120427151057.GA16580@fieldses.org>
Date: Fri, 27 Apr 2012 11:32:46 -0500
Message-ID: <CAH2r5msJVo6Li__QWavggzpz5G3A=-qPqzqSYC9vkzG5_dXc7w@mail.gmail.com>
Subject: Re: [PATCH 0/6] Extended file stat system call
From: Steve French <smfrench@gmail.com>
To: "J. Bruce Fields" <bfields@fieldses.org>
Cc: Dave Chinner <david@fromorbit.com>, David Howells <dhowells@redhat.com>,
        linux-fsdevel@vger.kernel.org, linux-nfs@vger.kernel.org,
        linux-cifs@vger.kernel.org, samba-technical@lists.samba.org,
        linux-ext4@vger.kernel.org
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, Apr 27, 2012 at 10:10 AM, J. Bruce Fields <bfields@fieldses.org> wrote:
> On Fri, Apr 27, 2012 at 11:13:06PM +1000, Dave Chinner wrote:
>> Right now it is, but there's ben patches in the past to introduce
>> project quotas to ext4. That didn't go far because it was done in a
>> way that was semantically different to XFS (for no reason that I
>> could understand) and nobody wanted two different sets of semantics
>> for the "same" feature.  The most common use of project quotas is to
>> implement sub-tree quotas,
>
> (Though it's also useful as a way to do safe subtree NFS exports).

Quotas are very important to Samba (and Windows) admins.

See e.g.
http://www.samba.org/samba/docs/man/manpages-3/smbcquotas.1.html

But I would defer to Metze and others on the server side to see
whether XFS or the proposed ext4 quotas match the protocol
requirements which Samba has to support.

Does anyone know whether Samba can handle all of the remote quota
admin operations on Linux/XFS today (and local enforcement)?

-- 
Thanks,

Steve

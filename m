Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-pb0-f44.google.com ([209.85.160.44]:37694 "EHLO
	mail-pb0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752062AbaDZQh1 convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sat, 26 Apr 2014 12:37:27 -0400
Received: by mail-pb0-f44.google.com with SMTP id jt11so2566387pbb.31
        for <linux-nfs@vger.kernel.org>; Sat, 26 Apr 2014 09:37:27 -0700 (PDT)
Content-Type: text/plain; charset=us-ascii
Mime-Version: 1.0 (Mac OS X Mail 7.2 \(1874\))
Subject: Re: Resolving the fate of FATTR4_CHANGE_SEC_LABEL
From: Thomas Haynes <thomas.haynes@primarydata.com>
In-Reply-To: <B05F63D2-8DB8-4FD3-92F9-C3A5B0A99D99@primarydata.com>
Date: Sat, 26 Apr 2014 09:37:25 -0700
Cc: "dpquigl@davequigley.com Quigley" <dpquigl@davequigley.com>
Message-Id: <0C8D4618-0DD5-428A-A68D-863F8A60500C@primarydata.com>
References: <B05F63D2-8DB8-4FD3-92F9-C3A5B0A99D99@primarydata.com>
To: "nfsv4 list (nfsv4@ietf.org)" <nfsv4@ietf.org>,
        Mailing List Linux NFS <linux-nfs@vger.kernel.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

In my issues file, I have:

4) Labeled NFS - FATTR4_CHANGE_SEC_LABEL - how big does it need to
   be?  Is seLinux going to support it?

   The Labeled NFS prototype in use does not currently support
   change_sec_label.

   In the past, we argued about how big it needed to be - we need
   to close down on this.

If we look at the current text in the NFSv4.2 draft, we see:

      The second change is to provide methods for the client to
      determine if the security label has changed. A client which
      needs to know if a label is going to change SHOULD request a
      delegation on that file. In order to change the security
      label, the server will have to recall all delegations. This
      will inform the client of the change. If a client wants to
      detect if the label has changed, it MAY use VERIFY and NVERIFY
      on FATTR4_CHANGE_SEC_LABEL to detect that the FATTR4_SEC_LABEL
      has been modified.

So the first question is do we need two methods for detecting that the label
has changed?

Section 8.3 of http://www.ietf.org/id/draft-ietf-nfsv4-minorversion2-21.txt covers
how the client could use delegations to detect a label change.

To quote Trond out of context:

> but that is the only option I can see for implementing a cache
> consistency model for labels. Without it, the choices are:
>
>   1) always fetch the label as part of every COMPOUND.
>   2) assume the label never changes on the server.
>
> The main use cases that have been presented for Labeled NFS on Linux
> would tend to push me towards door number 2, Monty please...

So a client could assume that the label never changes the majority
of the time. Once it decides it does need to start checking for a change
in the label, it can get a delegation.

If we do need the attribute, what size does it need to be?

There has been mention of it being a hash or a timestamp.